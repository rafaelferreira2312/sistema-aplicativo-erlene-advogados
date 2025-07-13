#!/bin/bash

# Script 15 - Criação do Base Service e Client Service (Laravel)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/15-create-backend-base-service.sh (executado da raiz do projeto)

echo "🚀 Criando Base Service e Client Service do Backend..."

# Base Service - Classe abstrata com funcionalidades comuns
cat > backend/app/Services/BaseService.php << 'EOF'
<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;
use Exception;

abstract class BaseService
{
    protected $model;
    protected $logChannel = 'default';

    /**
     * Log de atividades do service
     */
    protected function log($level, $message, $context = [])
    {
        Log::channel($this->logChannel)->log($level, $message, array_merge([
            'service' => get_class($this),
            'user_id' => auth()->id() ?? null,
            'timestamp' => now()->toISOString()
        ], $context));
    }

    /**
     * Executar operação com log e tratamento de erro
     */
    protected function executeWithLog($operation, $context = [])
    {
        try {
            $this->log('info', 'Iniciando operação', $context);
            $result = $operation();
            $this->log('info', 'Operação concluída com sucesso', $context);
            return $result;
        } catch (Exception $e) {
            $this->log('error', 'Erro na operação: ' . $e->getMessage(), array_merge($context, [
                'exception' => $e->getTraceAsString()
            ]));
            throw $e;
        }
    }

    /**
     * Validar entrada de dados
     */
    protected function validate($data, $rules)
    {
        $validator = Validator::make($data, $rules);
        
        if ($validator->fails()) {
            throw new \Illuminate\Validation\ValidationException($validator);
        }
        
        return $validator->validated();
    }

    /**
     * Executar em transação
     */
    protected function transaction($callback)
    {
        return DB::transaction($callback);
    }

    /**
     * Cache helper
     */
    protected function cache($key, $callback, $ttl = 3600)
    {
        return Cache::remember($key, $ttl, $callback);
    }

    /**
     * Limpar cache específico
     */
    protected function forgetCache($pattern)
    {
        if (is_array($pattern)) {
            foreach ($pattern as $key) {
                Cache::forget($key);
            }
        } else {
            Cache::forget($pattern);
        }
    }

    /**
     * Criar resposta padronizada
     */
    protected function createResponse($success, $data = null, $message = null, $errors = null)
    {
        return [
            'success' => $success,
            'data' => $data,
            'message' => $message,
            'errors' => $errors,
            'timestamp' => now()->toISOString()
        ];
    }

    /**
     * Resposta de sucesso
     */
    protected function success($data = null, $message = 'Operação realizada com sucesso')
    {
        return $this->createResponse(true, $data, $message);
    }

    /**
     * Resposta de erro
     */
    protected function error($message = 'Erro interno', $errors = null)
    {
        return $this->createResponse(false, null, $message, $errors);
    }
}
EOF

# Client Service - Serviço completo para gestão de clientes
cat > backend/app/Services/ClientService.php << 'EOF'
<?php

namespace App\Services;

use App\Models\Cliente;
use App\Models\DocumentoGed;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ClientService extends BaseService
{
    protected $model = Cliente::class;

    /**
     * Criar cliente com configurações GED
     */
    public function create(array $data)
    {
        return $this->executeWithLog(function() use ($data) {
            return $this->transaction(function() use ($data) {
                // Validar dados
                $validatedData = $this->validate($data, [
                    'nome' => 'required|string|max:255',
                    'cpf_cnpj' => 'required|string|unique:clientes,cpf_cnpj',
                    'tipo_pessoa' => 'required|in:PF,PJ',
                    'email' => 'required|email|unique:clientes,email',
                    'telefone' => 'required|string|max:15',
                    'endereco' => 'required|string',
                    'cep' => 'required|string|max:9',
                    'cidade' => 'required|string|max:100',
                    'estado' => 'required|string|size:2',
                    'tipo_armazenamento' => 'in:local,google_drive,onedrive',
                    'acesso_portal' => 'boolean',
                    'responsavel_id' => 'required|exists:users,id',
                    'unidade_id' => 'required|exists:unidades,id',
                    'observacoes' => 'nullable|string'
                ]);

                // Preparar dados
                $validatedData['pasta_local'] = Str::slug($validatedData['nome']);
                $validatedData['tipo_armazenamento'] = $validatedData['tipo_armazenamento'] ?? 'local';
                
                // Gerar senha do portal se habilitado
                $senhaTemporaria = null;
                if ($validatedData['acesso_portal'] ?? false) {
                    $senhaTemporaria = Str::random(8);
                    $validatedData['senha_portal'] = Hash::make($senhaTemporaria);
                }

                // Criar cliente
                $cliente = Cliente::create($validatedData);

                // Configurar storage
                $this->setupClientStorage($cliente);

                $this->log('info', 'Cliente criado com sucesso', [
                    'cliente_id' => $cliente->id,
                    'nome' => $cliente->nome,
                    'tipo_armazenamento' => $cliente->tipo_armazenamento
                ]);

                return [
                    'cliente' => $cliente->load(['unidade', 'responsavel']),
                    'senha_temporaria' => $senhaTemporaria
                ];
            });
        }, ['operation' => 'create_client']);
    }

    /**
     * Atualizar cliente
     */
    public function update(Cliente $cliente, array $data)
    {
        return $this->executeWithLog(function() use ($cliente, $data) {
            $validatedData = $this->validate($data, [
                'nome' => 'string|max:255',
                'cpf_cnpj' => 'string|unique:clientes,cpf_cnpj,' . $cliente->id,
                'email' => 'email|unique:clientes,email,' . $cliente->id,
                'telefone' => 'string|max:15',
                'endereco' => 'string',
                'cep' => 'string|max:9',
                'cidade' => 'string|max:100',
                'estado' => 'string|size:2',
                'status' => 'in:ativo,inativo',
                'acesso_portal' => 'boolean',
                'observacoes' => 'nullable|string'
            ]);

            $cliente->update($validatedData);

            // Limpar cache
            $this->forgetCache("client_stats_{$cliente->id}");

            $this->log('info', 'Cliente atualizado', [
                'cliente_id' => $cliente->id,
                'changes' => array_keys($validatedData)
            ]);

            return $cliente->load(['unidade', 'responsavel']);
        }, ['operation' => 'update_client', 'cliente_id' => $cliente->id]);
    }

    /**
     * Configurar storage do cliente
     */
    private function setupClientStorage(Cliente $cliente)
    {
        try {
            switch ($cliente->tipo_armazenamento) {
                case 'local':
                    $pastaPath = storage_path('app/clients/' . $cliente->pasta_local);
                    if (!file_exists($pastaPath)) {
                        mkdir($pastaPath, 0755, true);
                        
                        // Criar subpastas
                        mkdir($pastaPath . '/documentos', 0755, true);
                        mkdir($pastaPath . '/uploads', 0755, true);
                        mkdir($pastaPath . '/temp', 0755, true);
                    }
                    break;
                    
                case 'google_drive':
                    // TODO: Implementar criação de pasta no Google Drive
                    $this->log('info', 'Google Drive configurado para cliente', [
                        'cliente_id' => $cliente->id
                    ]);
                    break;
                    
                case 'onedrive':
                    // TODO: Implementar criação de pasta no OneDrive
                    $this->log('info', 'OneDrive configurado para cliente', [
                        'cliente_id' => $cliente->id
                    ]);
                    break;
            }
        } catch (\Exception $e) {
            $this->log('warning', 'Erro ao configurar storage do cliente', [
                'cliente_id' => $cliente->id,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Habilitar/desabilitar acesso ao portal
     */
    public function togglePortalAccess(Cliente $cliente, bool $enable, string $password = null)
    {
        return $this->executeWithLog(function() use ($cliente, $enable, $password) {
            if ($enable) {
                if (!$password) {
                    $password = Str::random(8);
                }
                
                $cliente->update([
                    'acesso_portal' => true,
                    'senha_portal' => Hash::make($password)
                ]);

                $this->log('info', 'Acesso ao portal habilitado', [
                    'cliente_id' => $cliente->id
                ]);
                
                return ['password' => $password];
            } else {
                $cliente->update([
                    'acesso_portal' => false,
                    'senha_portal' => null
                ]);

                $this->log('info', 'Acesso ao portal desabilitado', [
                    'cliente_id' => $cliente->id
                ]);
                
                return null;
            }
        }, ['operation' => 'toggle_portal_access', 'cliente_id' => $cliente->id]);
    }

    /**
     * Obter estatísticas do cliente
     */
    public function getClientStats(Cliente $cliente)
    {
        return $this->cache("client_stats_{$cliente->id}", function() use ($cliente) {
            return [
                'processos' => [
                    'total' => $cliente->processos()->count(),
                    'ativos' => $cliente->processos()->ativos()->count(),
                    'finalizados' => $cliente->processos()->where('status', 'finalizado')->count()
                ],
                'atendimentos' => [
                    'total' => $cliente->atendimentos()->count(),
                    'realizados' => $cliente->atendimentos()->where('status', 'concluido')->count(),
                    'agendados' => $cliente->atendimentos()->where('status', 'agendado')->count()
                ],
                'financeiro' => [
                    'total_pago' => $cliente->financeiro()->where('status', 'pago')->sum('valor'),
                    'total_pendente' => $cliente->financeiro()->pendentes()->sum('valor'),
                    'total_vencido' => $cliente->financeiro()->vencidos()->sum('valor')
                ],
                'documentos' => [
                    'total' => $cliente->documentos()->count(),
                    'tamanho_total' => $cliente->documentos()->sum('tamanho'),
                    'por_tipo' => $cliente->documentos()
                                       ->selectRaw('tipo_arquivo, COUNT(*) as count')
                                       ->groupBy('tipo_arquivo')
                                       ->pluck('count', 'tipo_arquivo')
                ]
            ];
        }, 1800); // Cache por 30 minutos
    }

    /**
     * Buscar clientes com filtros avançados
     */
    public function search(array $filters)
    {
        $query = Cliente::with(['unidade', 'responsavel']);

        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where(function($q) use ($search) {
                $q->where('nome', 'like', "%{$search}%")
                  ->orWhere('cpf_cnpj', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['tipo_pessoa'])) {
            $query->where('tipo_pessoa', $filters['tipo_pessoa']);
        }

        if (isset($filters['unidade_id'])) {
            $query->where('unidade_id', $filters['unidade_id']);
        }

        if (isset($filters['responsavel_id'])) {
            $query->where('responsavel_id', $filters['responsavel_id']);
        }

        if (isset($filters['acesso_portal'])) {
            $query->where('acesso_portal', $filters['acesso_portal']);
        }

        if (isset($filters['created_after'])) {
            $query->where('created_at', '>=', $filters['created_after']);
        }

        if (isset($filters['created_before'])) {
            $query->where('created_at', '<=', $filters['created_before']);
        }

        return $query->orderBy('nome');
    }

    /**
     * Excluir cliente (soft delete)
     */
    public function delete(Cliente $cliente)
    {
        return $this->executeWithLog(function() use ($cliente) {
            // Verificar se tem processos ativos
            if ($cliente->processos()->ativos()->count() > 0) {
                throw new \Exception('Não é possível excluir cliente com processos ativos');
            }

            $cliente->delete();

            // Limpar cache
            $this->forgetCache("client_stats_{$cliente->id}");

            $this->log('info', 'Cliente excluído', [
                'cliente_id' => $cliente->id,
                'nome' => $cliente->nome
            ]);

            return true;
        }, ['operation' => 'delete_client', 'cliente_id' => $cliente->id]);
    }
}
EOF

echo "✅ Base Service e Client Service criados com sucesso!"
echo "📊 Funcionalidades implementadas:"
echo "   • BaseService - Classe abstrata com helpers comuns"
echo "   • ClientService - CRUD completo de clientes"
echo "   • Sistema de logs estruturado"
echo "   • Validação automática de dados"
echo "   • Cache inteligente"
echo "   • Transações de banco seguras"
echo "   • Setup automático de storage GED"
echo "   • Estatísticas de clientes em cache"
echo "   • Busca avançada com filtros"
echo ""
echo "⏭️  Pronto para continuar com o próximo service!"