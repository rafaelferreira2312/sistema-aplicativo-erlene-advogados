#!/bin/bash

# Script 115b - Criar Backend PROCESSOS - Parte 2 (Controller e Service CNJ)
# Sistema Erlene Advogados - Implementação funcionalidade PROCESSOS
# Execução: chmod +x 115b-create-processos-backend-part2.sh && ./115b-create-processos-backend-part2.sh
# EXECUTAR DENTRO DA PASTA: backend/

echo "🚀 Script 115b - Implementando Backend PROCESSOS (Parte 2)..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 115b-create-processos-backend-part2.sh && ./115b-create-processos-backend-part2.sh"
    exit 1
fi

echo "1️⃣ Criando Controller ProcessController completo..."

# Criar diretório se não existir
mkdir -p app/Http/Controllers/Api/Admin

cat > app/Http/Controllers/Api/Admin/ProcessController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Processo;
use App\Models\Cliente;
use App\Models\User;
use App\Services\Integration\CNJService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class ProcessController extends Controller
{
    protected $cnjService;

    public function __construct(CNJService $cnjService)
    {
        $this->cnjService = $cnjService;
    }

    /**
     * Listar processos com filtros e paginação
     */
    public function index(Request $request): JsonResponse
    {
        $user = auth()->user();
        $perPage = min($request->get('per_page', 15), 50);

        $query = Processo::with(['cliente', 'advogado', 'unidade'])
                        ->porUnidade($user->unidade_id);

        // Filtros
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('advogado_id')) {
            $query->where('advogado_id', $request->advogado_id);
        }

        if ($request->filled('cliente_id')) {
            $query->where('cliente_id', $request->cliente_id);
        }

        if ($request->filled('prioridade')) {
            $query->where('prioridade', $request->prioridade);
        }

        if ($request->filled('busca')) {
            $query->buscar($request->busca);
        }

        // Ordenação
        $orderBy = $request->get('order_by', 'created_at');
        $orderDirection = $request->get('order_direction', 'desc');
        
        $query->orderBy($orderBy, $orderDirection);

        $processos = $query->paginate($perPage);

        // Adicionar informações extras para cada processo
        $processos->getCollection()->transform(function ($processo) {
            return array_merge($processo->toArray(), [
                'status_formatado' => $processo->status_formatado,
                'prioridade_formatada' => $processo->prioridade_formatada,
                'valor_causa_formatado' => $processo->valor_causa_formatado,
                'dias_ate_vencimento' => $processo->dias_ate_vencimento,
                'status_prazo' => $processo->status_prazo,
                'precisa_sincronizar_cnj' => $processo->precisa_sincronizar_cnj,
                'total_movimentacoes' => $processo->movimentacoes()->count(),
                'total_documentos' => $processo->documentos()->count()
            ]);
        });

        return response()->json([
            'success' => true,
            'data' => $processos,
            'meta' => [
                'total' => $processos->total(),
                'per_page' => $processos->perPage(),
                'current_page' => $processos->currentPage(),
                'last_page' => $processos->lastPage()
            ]
        ]);
    }

    /**
     * Criar novo processo
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'numero' => 'required|string|max:25|unique:processos,numero',
            'cliente_id' => 'required|exists:clientes,id',
            'advogado_id' => 'required|exists:users,id',
            'tipo_acao' => 'required|string|max:100',
            'tribunal' => 'required|string|max:50',
            'vara' => 'nullable|string|max:100',
            'valor_causa' => 'nullable|numeric|min:0',
            'data_distribuicao' => 'required|date',
            'proximo_prazo' => 'nullable|date|after:today',
            'prioridade' => 'in:baixa,media,alta,urgente',
            'observacoes' => 'nullable|string|max:1000',
            'sincronizar_cnj' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            DB::beginTransaction();

            $processo = Processo::create(array_merge(
                $validator->validated(),
                [
                    'unidade_id' => auth()->user()->unidade_id,
                    'status' => 'distribuido',
                    'prioridade' => $request->get('prioridade', 'media')
                ]
            ));

            // Criar movimentação inicial
            $processo->adicionarMovimentacao(
                'Processo cadastrado no sistema',
                'manual'
            );

            // Sincronizar com CNJ se solicitado
            if ($request->get('sincronizar_cnj', false)) {
                $this->sincronizarComCNJ($processo);
            }

            DB::commit();

            $processo->load(['cliente', 'advogado', 'unidade']);

            return response()->json([
                'success' => true,
                'message' => 'Processo criado com sucesso',
                'data' => $processo
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Erro ao criar processo: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Exibir processo específico
     */
    public function show($id): JsonResponse
    {
        $processo = Processo::with([
            'cliente',
            'advogado', 
            'unidade',
            'movimentacoes' => function($query) {
                $query->orderBy('data', 'desc')->limit(10);
            },
            'documentos',
            'atendimentos' => function($query) {
                $query->orderBy('data_hora', 'desc')->limit(5);
            }
        ])
        ->porUnidade(auth()->user()->unidade_id)
        ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => array_merge($processo->toArray(), [
                'status_formatado' => $processo->status_formatado,
                'prioridade_formatada' => $processo->prioridade_formatada,
                'valor_causa_formatado' => $processo->valor_causa_formatado,
                'dias_ate_vencimento' => $processo->dias_ate_vencimento,
                'status_prazo' => $processo->status_prazo,
                'precisa_sincronizar_cnj' => $processo->precisa_sincronizar_cnj
            ])
        ]);
    }

    /**
     * Atualizar processo
     */
    public function update(Request $request, $id): JsonResponse
    {
        $processo = Processo::porUnidade(auth()->user()->unidade_id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'numero' => 'required|string|max:25|unique:processos,numero,' . $id,
            'cliente_id' => 'required|exists:clientes,id',
            'advogado_id' => 'required|exists:users,id',
            'tipo_acao' => 'required|string|max:100',
            'tribunal' => 'required|string|max:50',
            'vara' => 'nullable|string|max:100',
            'valor_causa' => 'nullable|numeric|min:0',
            'data_distribuicao' => 'required|date',
            'proximo_prazo' => 'nullable|date',
            'status' => 'in:distribuido,em_andamento,suspenso,arquivado,finalizado',
            'prioridade' => 'in:baixa,media,alta,urgente',
            'observacoes' => 'nullable|string|max:1000'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            DB::beginTransaction();

            $dadosAnteriores = $processo->toArray();
            $processo->update($validator->validated());

            // Registrar mudanças importantes
            $this->registrarMudancas($processo, $dadosAnteriores);

            DB::commit();

            $processo->load(['cliente', 'advogado', 'unidade']);

            return response()->json([
                'success' => true,
                'message' => 'Processo atualizado com sucesso',
                'data' => $processo
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar processo: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Excluir processo
     */
    public function destroy($id): JsonResponse
    {
        $processo = Processo::porUnidade(auth()->user()->unidade_id)->findOrFail($id);

        try {
            DB::beginTransaction();

            $processo->adicionarMovimentacao(
                'Processo excluído do sistema por ' . auth()->user()->name,
                'manual'
            );

            $processo->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Processo excluído com sucesso'
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Erro ao excluir processo: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Sincronizar processo com CNJ DataJud
     */
    public function syncWithCNJ($id): JsonResponse
    {
        $processo = Processo::porUnidade(auth()->user()->unidade_id)->findOrFail($id);

        try {
            $resultado = $this->sincronizarComCNJ($processo);

            return response()->json([
                'success' => true,
                'message' => 'Sincronização realizada com sucesso',
                'data' => [
                    'processo_id' => $processo->id,
                    'novas_movimentacoes' => $resultado['novas_movimentacoes'] ?? 0,
                    'ultima_sincronizacao' => $processo->fresh()->ultima_consulta_cnj
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro na sincronização: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Métodos auxiliares privados
     */
    private function sincronizarComCNJ(Processo $processo)
    {
        return $this->cnjService->sincronizarProcesso($processo);
    }

    private function registrarMudancas(Processo $processo, array $dadosAnteriores)
    {
        $mudancas = [];

        if ($dadosAnteriores['status'] !== $processo->status) {
            $mudancas[] = "Status alterado de '{$dadosAnteriores['status']}' para '{$processo->status}'";
        }

        if ($dadosAnteriores['advogado_id'] !== $processo->advogado_id) {
            $mudancas[] = "Advogado responsável alterado";
        }

        if ($dadosAnteriores['proximo_prazo'] !== $processo->proximo_prazo?->toDateString()) {
            $mudancas[] = "Próximo prazo alterado";
        }

        if (!empty($mudancas)) {
            $processo->adicionarMovimentacao(
                'Dados atualizados: ' . implode('; ', $mudancas),
                'manual'
            );
        }
    }
}
EOF

echo "2️⃣ Criando Service CNJService para integração com API CNJ DataJud..."

# Criar diretório se não existir
mkdir -p app/Services/Integration

cat > app/Services/Integration/CNJService.php << 'EOF'
<?php

namespace App\Services\Integration;

use App\Models\Processo;
use App\Models\Movimentacao;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class CNJService
{
    protected $baseUrl = 'https://api-publica.datajud.cnj.jus.br';
    protected $apiKey;
    protected $timeout = 30;

    public function __construct()
    {
        $this->apiKey = config('services.cnj.api_key');
    }

    /**
     * Sincronizar processo com dados do CNJ DataJud
     * Documentação: https://datajud-wiki.cnj.jus.br/api-publica/
     */
    public function sincronizarProcesso(Processo $processo)
    {
        try {
            Log::info("Iniciando sincronização CNJ", [
                'processo_id' => $processo->id,
                'numero_processo' => $processo->numero
            ]);

            // Consultar movimentações no CNJ
            $dadosCNJ = $this->consultarMovimentacoes($processo->numero, $processo->tribunal);

            if (!$dadosCNJ['success']) {
                throw new \Exception($dadosCNJ['message'] ?? 'Erro na consulta CNJ');
            }

            $novasMovimentacoes = 0;

            // Processar movimentações retornadas
            if (!empty($dadosCNJ['movimentacoes'])) {
                $novasMovimentacoes = $this->processarMovimentacoes($processo, $dadosCNJ['movimentacoes']);
            }

            // Atualizar metadados do processo
            $metadataCnj = [
                'ultima_consulta' => now()->toISOString(),
                'tribunal_codigo' => $dadosCNJ['tribunal_codigo'] ?? null,
                'total_movimentacoes_cnj' => count($dadosCNJ['movimentacoes'] ?? [])
            ];

            $processo->marcarComoSincronizado($metadataCnj);

            Log::info("Sincronização CNJ concluída", [
                'processo_id' => $processo->id,
                'novas_movimentacoes' => $novasMovimentacoes
            ]);

            return [
                'success' => true,
                'novas_movimentacoes' => $novasMovimentacoes,
                'total_movimentacoes_cnj' => count($dadosCNJ['movimentacoes'] ?? [])
            ];

        } catch (\Exception $e) {
            Log::error("Erro na sincronização CNJ", [
                'processo_id' => $processo->id,
                'erro' => $e->getMessage()
            ]);

            throw $e;
        }
    }

    /**
     * Consultar movimentações no CNJ DataJud (com mock para desenvolvimento)
     */
    protected function consultarMovimentacoes(string $numeroProcesso, string $tribunal)
    {
        try {
            // Para desenvolvimento/teste - mockup de dados
            if (config('app.env') !== 'production' || !$this->apiKey) {
                return $this->mockConsultaCNJ($numeroProcesso, $tribunal);
            }

            // Implementação real da API CNJ DataJud
            $response = Http::timeout($this->timeout)
                          ->withHeaders([
                              'Authorization' => 'APIKey ' . $this->apiKey,
                              'Content-Type' => 'application/json'
                          ])
                          ->get("{$this->baseUrl}/api_publica_v2_process_movements", [
                              'numeroProcesso' => $numeroProcesso,
                              'tribunal' => $this->mapearTribunal($tribunal)
                          ]);

            if ($response->successful()) {
                $data = $response->json();
                
                return [
                    'success' => true,
                    'movimentacoes' => $data['movimentacoes'] ?? [],
                    'tribunal_codigo' => $data['tribunal'] ?? null,
                    'total' => count($data['movimentacoes'] ?? [])
                ];
            }

            return [
                'success' => false,
                'message' => 'Erro na consulta CNJ: ' . $response->status()
            ];

        } catch (\Exception $e) {
            Log::error("Erro ao consultar CNJ", [
                'numero_processo' => $numeroProcesso,
                'erro' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Erro de conexão com CNJ: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Mock de consulta CNJ para desenvolvimento/teste
     */
    protected function mockConsultaCNJ(string $numeroProcesso, string $tribunal)
    {
        // Simular dados CNJ para desenvolvimento
        $movimentacoesMock = [
            [
                'data' => now()->subDays(30)->format('Y-m-d H:i:s'),
                'descricao' => 'Distribuição - Distribuído por Dependência',
                'codigo' => '26',
                'tipo' => 'tribunal'
            ],
            [
                'data' => now()->subDays(25)->format('Y-m-d H:i:s'),
                'descricao' => 'Juntada - Petição inicial juntada aos autos',
                'codigo' => '51',
                'tipo' => 'tribunal'
            ],
            [
                'data' => now()->subDays(20)->format('Y-m-d H:i:s'),
                'descricao' => 'Despacho - Cite-se o requerido',
                'codigo' => '123',
                'tipo' => 'tribunal'
            ]
        ];

        return [
            'success' => true,
            'movimentacoes' => $movimentacoesMock,
            'tribunal_codigo' => $this->mapearTribunal($tribunal),
            'total' => count($movimentacoesMock)
        ];
    }

    /**
     * Mapear nome do tribunal para código CNJ
     */
    protected function mapearTribunal(string $tribunal): string
    {
        $mapeamento = [
            'TJSP' => '8.26',
            'TJRJ' => '8.19',
            'TJMG' => '8.13',
            'TRF3' => '4.03',
            'TST' => '5.00'
        ];

        return $mapeamento[strtoupper($tribunal)] ?? $tribunal;
    }

    /**
     * Processar e salvar movimentações vindas do CNJ
     */
    protected function processarMovimentacoes(Processo $processo, array $movimentacoesCNJ)
    {
        $novasMovimentacoes = 0;

        foreach ($movimentacoesCNJ as $movCNJ) {
            // Verificar se movimentação já existe (evitar duplicatas)
            $dataMovimentacao = Carbon::parse($movCNJ['data']);
            
            $exists = $processo->movimentacoes()
                              ->where('tipo', 'tribunal')
                              ->where('data', $dataMovimentacao)
                              ->where('descricao', $movCNJ['descricao'])
                              ->exists();

            if (!$exists) {
                $processo->movimentacoes()->create([
                    'data' => $dataMovimentacao,
                    'descricao' => $movCNJ['descricao'],
                    'tipo' => 'tribunal',
                    'metadata' => [
                        'codigo_cnj' => $movCNJ['codigo'] ?? null,
                        'fonte' => 'cnj_datajud',
                        'sincronizado_em' => now()->toISOString()
                    ]
                ]);

                $novasMovimentacoes++;

                // Atualizar status do processo baseado na movimentação
                $processo->atualizarStatusPorMovimentacao($movCNJ['descricao']);
            }
        }

        return $novasMovimentacoes;
    }
}
EOF

echo "✅ Parte 2 concluída com sucesso!"
echo ""
echo "📋 O que foi implementado:"
echo "   • ProcessController completo com CRUD"
echo "   • Integração com CNJService"
echo "   • Endpoint para sincronização CNJ"
echo "   • CNJService com mock para desenvolvimento"
echo "   • Logs e tratamento de erros"
echo ""
echo "⏭️ Próximo passo: Executar Parte 3 (Rotas API e configurações)"