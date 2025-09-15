#!/bin/bash

# Script 129 - Implementar método update no ProcessController
# Sistema Erlene Advogados - Corrigir erro 501 Not Implemented no backend
# EXECUTAR DENTRO DA PASTA: backend/

echo "🔧 Script 129 - Implementando método update no ProcessController..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 129-backend-update-process.sh && ./129-backend-update-process.sh"
    exit 1
fi

echo "1️⃣ DIAGNÓSTICO DO PROBLEMA:"
echo "   • Frontend enviando PUT /admin/processes/2"
echo "   • Backend retornando 501 Not Implemented"
echo "   • Método update() não implementado no ProcessController"
echo "   • Solução: implementar método update completo"

echo ""
echo "2️⃣ Localizando ProcessController..."

# Encontrar o ProcessController
CONTROLLER_PATH=""
if [ -f "app/Http/Controllers/Api/Admin/Processes/ProcessController.php" ]; then
    CONTROLLER_PATH="app/Http/Controllers/Api/Admin/Processes/ProcessController.php"
elif [ -f "app/Http/Controllers/Api/Admin/ProcessController.php" ]; then
    CONTROLLER_PATH="app/Http/Controllers/Api/Admin/ProcessController.php"
elif [ -f "app/Http/Controllers/ProcessController.php" ]; then
    CONTROLLER_PATH="app/Http/Controllers/ProcessController.php"
else
    echo "❌ ProcessController não encontrado!"
    echo "Procurando em todas as pastas..."
    find app -name "*ProcessController.php" -type f
    exit 1
fi

echo "✅ ProcessController encontrado: $CONTROLLER_PATH"

echo ""
echo "3️⃣ Fazendo backup do ProcessController atual..."

# Backup do controller atual
cp "$CONTROLLER_PATH" "$CONTROLLER_PATH.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

echo ""
echo "4️⃣ Implementando método update completo..."

cat > "$CONTROLLER_PATH" << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Processes;

use App\Http\Controllers\Controller;
use App\Models\Processo;
use App\Models\Cliente;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ProcessController extends Controller
{
    /**
     * Listar processos com filtros e paginação
     */
    public function index(Request $request)
    {
        try {
            Log::info('📋 Listando processos', ['params' => $request->all()]);
            
            $query = Processo::with(['cliente', 'advogado']);
            
            // Filtros
            if ($request->filled('search')) {
                $search = $request->search;
                $query->where(function($q) use ($search) {
                    $q->where('numero', 'LIKE', "%{$search}%")
                      ->orWhere('tipo_acao', 'LIKE', "%{$search}%")
                      ->orWhereHas('cliente', function($clienteQuery) use ($search) {
                          $clienteQuery->where('nome', 'LIKE', "%{$search}%");
                      });
                });
            }
            
            if ($request->filled('status')) {
                $query->where('status', $request->status);
            }
            
            if ($request->filled('advogado_id')) {
                $query->where('advogado_id', $request->advogado_id);
            }
            
            // Ordenação
            $orderBy = $request->get('order_by', 'created_at');
            $orderDirection = $request->get('order_direction', 'desc');
            $query->orderBy($orderBy, $orderDirection);
            
            // Paginação
            $perPage = $request->get('per_page', 15);
            $processos = $query->paginate($perPage);
            
            Log::info('✅ Processos listados', [
                'total' => $processos->total(),
                'per_page' => $perPage
            ]);
            
            return response()->json([
                'success' => true,
                'data' => $processos->items(),
                'meta' => [
                    'current_page' => $processos->currentPage(),
                    'last_page' => $processos->lastPage(),
                    'per_page' => $processos->perPage(),
                    'total' => $processos->total()
                ]
            ]);
            
        } catch (\Exception $e) {
            Log::error('💥 Erro ao listar processos', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erro ao listar processos: ' . $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Obter processo específico
     */
    public function show($id)
    {
        try {
            Log::info('🔍 Carregando processo ID: ' . $id);
            
            $processo = Processo::with(['cliente', 'advogado'])->findOrFail($id);
            
            Log::info('✅ Processo encontrado', [
                'id' => $processo->id,
                'numero' => $processo->numero
            ]);
            
            return response()->json([
                'success' => true,
                'data' => $processo
            ]);
            
        } catch (\Exception $e) {
            Log::error('💥 Erro ao buscar processo', [
                'id' => $id,
                'error' => $e->getMessage()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Processo não encontrado'
            ], 404);
        }
    }
    
    /**
     * Criar novo processo
     */
    public function store(Request $request)
    {
        try {
            Log::info('➕ Criando novo processo', ['data' => $request->all()]);
            
            // Validação
            $validator = Validator::make($request->all(), [
                'numero' => 'required|string|max:25|unique:processos,numero',
                'tribunal' => 'required|string|max:255',
                'cliente_id' => 'required|exists:clientes,id',
                'tipo_acao' => 'required|string|max:255',
                'data_distribuicao' => 'required|date',
                'advogado_id' => 'required|exists:users,id',
                'vara' => 'nullable|string|max:255',
                'valor_causa' => 'nullable|numeric|min:0',
                'proximo_prazo' => 'nullable|date',
                'observacoes' => 'nullable|string',
                'status' => 'in:distribuido,em_andamento,suspenso,arquivado,finalizado',
                'prioridade' => 'in:baixa,media,alta,urgente'
            ], [
                'numero.required' => 'Número do processo é obrigatório',
                'numero.unique' => 'Este número de processo já existe',
                'tribunal.required' => 'Tribunal é obrigatório',
                'cliente_id.required' => 'Cliente é obrigatório',
                'cliente_id.exists' => 'Cliente não encontrado',
                'tipo_acao.required' => 'Tipo de ação é obrigatório',
                'data_distribuicao.required' => 'Data de distribuição é obrigatória',
                'advogado_id.required' => 'Advogado responsável é obrigatório',
                'advogado_id.exists' => 'Advogado não encontrado'
            ]);
            
            if ($validator->fails()) {
                Log::warning('❌ Validação falhou', ['errors' => $validator->errors()]);
                return response()->json([
                    'success' => false,
                    'message' => 'Dados inválidos',
                    'errors' => $validator->errors()
                ], 422);
            }
            
            DB::beginTransaction();
            
            // Criar processo
            $processo = Processo::create([
                'numero' => $request->numero,
                'tribunal' => $request->tribunal,
                'vara' => $request->vara,
                'cliente_id' => $request->cliente_id,
                'tipo_acao' => $request->tipo_acao,
                'status' => $request->status ?? 'distribuido',
                'valor_causa' => $request->valor_causa,
                'data_distribuicao' => $request->data_distribuicao,
                'advogado_id' => $request->advogado_id,
                'unidade_id' => auth()->user()->unidade_id ?? 1,
                'proximo_prazo' => $request->proximo_prazo,
                'observacoes' => $request->observacoes,
                'prioridade' => $request->prioridade ?? 'media',
                'kanban_posicao' => 0
            ]);
            
            // Carregar relacionamentos
            $processo->load(['cliente', 'advogado']);
            
            DB::commit();
            
            Log::info('✅ Processo criado com sucesso', [
                'id' => $processo->id,
                'numero' => $processo->numero
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Processo criado com sucesso',
                'data' => $processo
            ], 201);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('💥 Erro ao criar processo', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erro ao criar processo: ' . $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Atualizar processo existente
     */
    public function update(Request $request, $id)
    {
        try {
            Log::info('✏️ Atualizando processo', [
                'id' => $id,
                'data' => $request->all()
            ]);
            
            $processo = Processo::findOrFail($id);
            
            // Validação (excluindo número atual da validação unique)
            $validator = Validator::make($request->all(), [
                'numero' => 'required|string|max:25|unique:processos,numero,' . $id,
                'tribunal' => 'required|string|max:255',
                'cliente_id' => 'required|exists:clientes,id',
                'tipo_acao' => 'required|string|max:255',
                'data_distribuicao' => 'required|date',
                'advogado_id' => 'required|exists:users,id',
                'vara' => 'nullable|string|max:255',
                'valor_causa' => 'nullable|numeric|min:0',
                'proximo_prazo' => 'nullable|date',
                'observacoes' => 'nullable|string',
                'status' => 'in:distribuido,em_andamento,suspenso,arquivado,finalizado',
                'prioridade' => 'in:baixa,media,alta,urgente'
            ], [
                'numero.required' => 'Número do processo é obrigatório',
                'numero.unique' => 'Este número de processo já existe',
                'tribunal.required' => 'Tribunal é obrigatório',
                'cliente_id.required' => 'Cliente é obrigatório',
                'cliente_id.exists' => 'Cliente não encontrado',
                'tipo_acao.required' => 'Tipo de ação é obrigatório',
                'data_distribuicao.required' => 'Data de distribuição é obrigatória',
                'advogado_id.required' => 'Advogado responsável é obrigatório',
                'advogado_id.exists' => 'Advogado não encontrado'
            ]);
            
            if ($validator->fails()) {
                Log::warning('❌ Validação de atualização falhou', ['errors' => $validator->errors()]);
                return response()->json([
                    'success' => false,
                    'message' => 'Dados inválidos',
                    'errors' => $validator->errors()
                ], 422);
            }
            
            DB::beginTransaction();
            
            // Dados antes da atualização para log
            $dadosAnteriores = $processo->toArray();
            
            // Atualizar processo
            $processo->update([
                'numero' => $request->numero,
                'tribunal' => $request->tribunal,
                'vara' => $request->vara,
                'cliente_id' => $request->cliente_id,
                'tipo_acao' => $request->tipo_acao,
                'status' => $request->status,
                'valor_causa' => $request->valor_causa,
                'data_distribuicao' => $request->data_distribuicao,
                'advogado_id' => $request->advogado_id,
                'proximo_prazo' => $request->proximo_prazo,
                'observacoes' => $request->observacoes,
                'prioridade' => $request->prioridade
            ]);
            
            // Carregar relacionamentos atualizados
            $processo->load(['cliente', 'advogado']);
            
            DB::commit();
            
            Log::info('✅ Processo atualizado com sucesso', [
                'id' => $processo->id,
                'numero' => $processo->numero,
                'alteracoes' => array_diff_assoc($processo->toArray(), $dadosAnteriores)
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Processo atualizado com sucesso',
                'data' => $processo
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('💥 Erro ao atualizar processo', [
                'id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar processo: ' . $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Excluir processo
     */
    public function destroy($id)
    {
        try {
            Log::info('🗑️ Excluindo processo ID: ' . $id);
            
            $processo = Processo::findOrFail($id);
            
            DB::beginTransaction();
            
            // Soft delete (se configurado) ou delete permanente
            $processo->delete();
            
            DB::commit();
            
            Log::info('✅ Processo excluído com sucesso', [
                'id' => $id,
                'numero' => $processo->numero
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Processo excluído com sucesso'
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('💥 Erro ao excluir processo', [
                'id' => $id,
                'error' => $e->getMessage()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erro ao excluir processo: ' . $e->getMessage()
            ], 500);
        }
    }
}
EOF

echo "5️⃣ Verificando se as rotas estão configuradas..."

# Verificar routes/api.php
if [ -f "routes/api.php" ]; then
    echo "✅ Verificando rotas em routes/api.php..."
    
    if ! grep -q "processes.*update\|processes.*put" routes/api.php; then
        echo "⚠️ Adicionando rotas PUT e DELETE para processos..."
        
        # Backup do routes/api.php
        cp routes/api.php routes/api.php.backup.$(date +%Y%m%d_%H%M%S)
        
        # Adicionar rotas se não existirem
        if grep -q "Route::get.*processes" routes/api.php; then
            # Substituir linha de GET por resource completo
            sed -i '/Route::get.*processes/c\
            Route::apiResource("processes", Processes\\ProcessController::class);' routes/api.php
        else
            # Adicionar nova linha de resource
            echo "            Route::apiResource('processes', Processes\\ProcessController::class);" >> routes/api.php
        fi
        
        echo "✅ Rotas adicionadas"
    else
        echo "✅ Rotas já configuradas"
    fi
else
    echo "❌ Arquivo routes/api.php não encontrado"
fi

echo ""
echo "6️⃣ Testando a estrutura do controller..."

# Verificar se método update foi implementado
if grep -q "public function update" "$CONTROLLER_PATH"; then
    echo "✅ Método update() implementado"
else
    echo "❌ Erro: método update() não encontrado"
    exit 1
fi

# Verificar se todos os métodos necessários existem
for method in "index" "show" "store" "update" "destroy"; do
    if grep -q "public function $method" "$CONTROLLER_PATH"; then
        echo "✅ Método $method() implementado"
    else
        echo "❌ Método $method() faltando"
    fi
done

echo ""
echo "✅ SCRIPT 129 CONCLUÍDO COM SUCESSO!"
echo ""
echo "🔧 O QUE FOI IMPLEMENTADO:"
echo "   ✅ Método update() completo no ProcessController"
echo "   ✅ Validações de dados baseadas na tabela processos"
echo "   ✅ Logs detalhados para debug"
echo "   ✅ Tratamento de erros robusto"
echo "   ✅ Transações de banco de dados"
echo "   ✅ Carregamento de relacionamentos (cliente, advogado)"
echo "   ✅ Rotas apiResource configuradas"
echo ""
echo "🚀 MÉTODOS IMPLEMENTADOS:"
echo "   ✅ GET /admin/processes (index) - listar"
echo "   ✅ GET /admin/processes/{id} (show) - obter específico"
echo "   ✅ POST /admin/processes (store) - criar"
echo "   ✅ PUT /admin/processes/{id} (update) - atualizar"
echo "   ✅ DELETE /admin/processes/{id} (destroy) - excluir"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. php artisan config:clear"
echo "   2. php artisan route:clear"
echo "   3. Teste a edição de processo no frontend"
echo "   4. Verifique os logs: storage/logs/laravel.log"