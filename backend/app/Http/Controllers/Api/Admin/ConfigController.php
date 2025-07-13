<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Configuracao;
use App\Models\Integracao;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Cache;

class ConfigController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/config",
     *     summary="Obter configurações do sistema",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Configurações do sistema")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        
        $query = Configuracao::query();
        
        // Admin geral vê configurações globais e da unidade
        // Admin unidade vê apenas da sua unidade
        if ($user->perfil === 'admin_geral') {
            if ($request->global) {
                $query->whereNull('unidade_id');
            } elseif ($request->unidade_id) {
                $query->where('unidade_id', $request->unidade_id);
            }
        } else {
            $query->where('unidade_id', $user->unidade_id);
        }

        if ($request->categoria) {
            $query->where('categoria', $request->categoria);
        }

        $configuracoes = $query->orderBy('categoria')
                             ->orderBy('chave')
                             ->get()
                             ->groupBy('categoria');

        return $this->success($configuracoes);
    }

    /**
     * @OA\Put(
     *     path="/admin/config/{chave}",
     *     summary="Atualizar configuração",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="chave", in="path", required=true, @OA\Schema(type="string")),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"valor"},
     *             @OA\Property(property="valor", type="string")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Configuração atualizada com sucesso")
     * )
     */
    public function update(Request $request, $chave)
    {
        $validator = Validator::make($request->all(), [
            'valor' => 'required'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        $query = Configuracao::where('chave', $chave);
        
        if ($user->perfil !== 'admin_geral') {
            $query->where('unidade_id', $user->unidade_id);
        }

        $config = $query->first();
        
        if (!$config) {
            return $this->error('Configuração não encontrada', 404);
        }

        // Validar tipo de dados
        $valor = $request->valor;
        switch ($config->tipo) {
            case 'boolean':
                $valor = filter_var($valor, FILTER_VALIDATE_BOOLEAN);
                break;
            case 'integer':
                $valor = (int) $valor;
                break;
            case 'json':
                if (is_string($valor)) {
                    $decoded = json_decode($valor, true);
                    if (json_last_error() !== JSON_ERROR_NONE) {
                        return $this->error('JSON inválido', 422);
                    }
                    $valor = $decoded;
                }
                $valor = json_encode($valor);
                break;
        }

        $config->update(['valor' => $valor]);

        // Limpar cache se necessário
        if ($config->categoria === 'cache') {
            Cache::flush();
        }

        return $this->success($config, 'Configuração atualizada com sucesso');
    }

    /**
     * @OA\Get(
     *     path="/admin/config/integrations",
     *     summary="Obter configurações de integrações",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Configurações de integrações")
     * )
     */
    public function integrations()
    {
        $user = auth()->user();
        
        $integracoes = Integracao::where('unidade_id', $user->unidade_id)
                                ->get()
                                ->keyBy('nome');

        // Estrutura padrão para integrações não configuradas
        $integracoesDisponiveis = [
            'cnj' => ['nome' => 'CNJ', 'descricao' => 'Consulta Nacional de Justiça'],
            'escavador' => ['nome' => 'Escavador', 'descricao' => 'Pesquisa jurisprudencial'],
            'jurisbrasil' => ['nome' => 'Jurisbrasil', 'descricao' => 'Acompanhamento processual'],
            'google_drive' => ['nome' => 'Google Drive', 'descricao' => 'Armazenamento em nuvem'],
            'onedrive' => ['nome' => 'OneDrive', 'descricao' => 'Armazenamento Microsoft'],
            'google_calendar' => ['nome' => 'Google Calendar', 'descricao' => 'Sincronização de agenda'],
            'gmail' => ['nome' => 'Gmail', 'descricao' => 'Envio de emails'],
            'stripe' => ['nome' => 'Stripe', 'descricao' => 'Pagamentos internacionais'],
            'mercadopago' => ['nome' => 'Mercado Pago', 'descricao' => 'Pagamentos nacionais'],
            'chatgpt' => ['nome' => 'ChatGPT', 'descricao' => 'Assistente de IA']
        ];

        $resultado = [];
        foreach ($integracoesDisponiveis as $key => $info) {
            $integracao = $integracoes->get($key);
            
            $resultado[$key] = [
                'nome' => $info['nome'],
                'descricao' => $info['descricao'],
                'ativo' => $integracao ? $integracao->ativo : false,
                'status' => $integracao ? $integracao->status : 'inativo',
                'ultima_sincronizacao' => $integracao ? $integracao->ultima_sincronizacao : null,
                'configurado' => $integracao ? !empty($integracao->configuracoes) : false,
                'estatisticas' => $integracao ? [
                    'total_requisicoes' => $integracao->total_requisicoes,
                    'requisicoes_sucesso' => $integracao->requisicoes_sucesso,
                    'requisicoes_erro' => $integracao->requisicoes_erro,
                    'taxa_sucesso' => $integracao->total_requisicoes > 0 
                                    ? round(($integracao->requisicoes_sucesso / $integracao->total_requisicoes) * 100, 2) 
                                    : 0
                ] : null
            ];
        }

        return $this->success($resultado);
    }

    /**
     * @OA\Put(
     *     path="/admin/config/integrations/{nome}",
     *     summary="Configurar integração",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="nome", in="path", required=true, @OA\Schema(type="string")),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"configuracoes"},
     *             @OA\Property(property="configuracoes", type="object"),
     *             @OA\Property(property="ativo", type="boolean")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Integração configurada com sucesso")
     * )
     */
    public function updateIntegration(Request $request, $nome)
    {
        $validator = Validator::make($request->all(), [
            'configuracoes' => 'required|array',
            'ativo' => 'boolean'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        // Validar se integração existe
        $integracoesPermitidas = [
            'cnj', 'escavador', 'jurisbrasil', 'google_drive', 'onedrive',
            'google_calendar', 'gmail', 'stripe', 'mercadopago', 'chatgpt'
        ];

        if (!in_array($nome, $integracoesPermitidas)) {
            return $this->error('Integração não encontrada', 404);
        }

        // Validar configurações específicas por integração
        $configValidation = $this->validateIntegrationConfig($nome, $request->configuracoes);
        if (!$configValidation['valid']) {
            return $this->error($configValidation['message'], 422);
        }

        $integracao = Integracao::updateOrCreate(
            [
                'nome' => $nome,
                'unidade_id' => $user->unidade_id
            ],
            [
                'ativo' => $request->ativo ?? true,
                'configuracoes' => $request->configuracoes,
                'status' => 'inativo' // Será atualizado pelo teste de conexão
            ]
        );

        // Testar conexão
        $testeConexao = $this->testIntegrationConnection($nome, $request->configuracoes);
        $integracao->update([
            'status' => $testeConexao['success'] ? 'funcionando' : 'erro',
            'ultimo_erro' => $testeConexao['success'] ? null : $testeConexao['error']
        ]);

        return $this->success($integracao, 'Integração configurada com sucesso');
    }

    /**
     * Validar configurações específicas por integração
     */
    private function validateIntegrationConfig($nome, $configuracoes)
    {
        switch ($nome) {
            case 'stripe':
                if (empty($configuracoes['public_key']) || empty($configuracoes['secret_key'])) {
                    return ['valid' => false, 'message' => 'Public Key e Secret Key são obrigatórios'];
                }
                break;
                
            case 'mercadopago':
                if (empty($configuracoes['public_key']) || empty($configuracoes['access_token'])) {
                    return ['valid' => false, 'message' => 'Public Key e Access Token são obrigatórios'];
                }
                break;
                
            case 'chatgpt':
                if (empty($configuracoes['api_key'])) {
                    return ['valid' => false, 'message' => 'API Key é obrigatória'];
                }
                break;
                
            case 'google_drive':
            case 'google_calendar':
            case 'gmail':
                if (empty($configuracoes['client_id']) || empty($configuracoes['client_secret'])) {
                    return ['valid' => false, 'message' => 'Client ID e Client Secret são obrigatórios'];
                }
                break;
                
            case 'onedrive':
                if (empty($configuracoes['client_id']) || empty($configuracoes['client_secret'])) {
                    return ['valid' => false, 'message' => 'Client ID e Client Secret são obrigatórios'];
                }
                break;
        }

        return ['valid' => true];
    }

    /**
     * Testar conexão com integração
     */
    private function testIntegrationConnection($nome, $configuracoes)
    {
        try {
            switch ($nome) {
                case 'stripe':
                    // TODO: Implementar teste real do Stripe
                    return ['success' => true];
                    
                case 'mercadopago':
                    // TODO: Implementar teste real do Mercado Pago
                    return ['success' => true];
                    
                case 'chatgpt':
                    // TODO: Implementar teste real do ChatGPT
                    return ['success' => true];
                    
                default:
                    return ['success' => true];
            }
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }

    /**
     * Obter categorias de configuração
     */
    public function categories()
    {
        $categorias = [
            'sistema' => 'Configurações do Sistema',
            'email' => 'Configurações de Email',
            'integracao' => 'Integrações',
            'backup' => 'Backup e Segurança',
            'notificacao' => 'Notificações',
            'aparencia' => 'Aparência'
        ];

        return $this->success($categorias);
    }
}
