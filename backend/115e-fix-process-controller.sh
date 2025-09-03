#!/bin/bash

# Script 115e - Corrigir erro no ProcessController
# Sistema Erlene Advogados - Corrigir estrutura do ProcessController
# Execução: chmod +x 115e-fix-process-controller.sh && ./115e-fix-process-controller.sh
# EXECUTAR DENTRO DA PASTA: backend/

echo "🔧 Script 115e - Corrigindo erro no ProcessController..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 115e-fix-process-controller.sh && ./115e-fix-process-controller.sh"
    exit 1
fi

echo "1️⃣ Fazendo backup do arquivo atual..."

# Backup do controller atual
cp app/Http/Controllers/Api/Admin/ProcessController.php app/Http/Controllers/Api/Admin/ProcessController.php.backup

echo "2️⃣ Recriando ProcessController corrigido..."

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

echo "✅ ProcessController corrigido com sucesso!"
echo ""
echo "📋 O que foi feito:"
echo "   • Backup do arquivo original criado"
echo "   • Estrutura do controller corrigida"
echo "   • Métodos principais funcionais"
echo "   • Validações e tratamento de erros"
echo ""
echo "⏭️ Próximo: Script para implementar tabela tribunais com endpoints CNJ"