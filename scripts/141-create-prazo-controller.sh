#!/bin/bash

# Script 141 - Criar PrazoController com CRUD completo
# Sistema Erlene Advogados - Controller para gestão de prazos
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🎯 Script 141 - Criando PrazoController com CRUD completo..."

# Verificar diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

# Verificar se Model Prazo existe
if [ ! -f "app/Models/Prazo.php" ]; then
    echo "❌ Erro: Model Prazo não encontrado. Execute primeiro o Script 140!"
    exit 1
fi

echo "✅ Model Prazo encontrado"

# Verificar se tabela prazos existe no banco
echo "🔍 Verificando se tabela prazos existe no banco..."
TABELA_EXISTE=$(php artisan tinker --execute="
try {
    \Schema::hasTable('prazos') ? 'true' : 'false';
} catch (Exception \$e) {
    echo 'false';
}
" 2>/dev/null | tail -n1)

if [ "$TABELA_EXISTE" != "true" ]; then
    echo "❌ Tabela prazos não encontrada no banco!"
    exit 1
fi

echo "✅ Tabela prazos confirmada no banco"

# 1. Criar diretório do controller se não existir
mkdir -p "app/Http/Controllers/Api/Admin"

# 2. Fazer backup se controller já existir
if [ -f "app/Http/Controllers/Api/Admin/PrazoController.php" ]; then
    cp "app/Http/Controllers/Api/Admin/PrazoController.php" "app/Http/Controllers/Api/Admin/PrazoController.php.bak.141"
    echo "✅ Backup do controller criado"
fi

# 3. Criar PrazoController seguindo padrão do sistema
echo "📝 Criando PrazoController..."

cat > "app/Http/Controllers/Api/Admin/PrazoController.php" << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Prazo;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class PrazoController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Prazo::with(['client', 'process', 'user']);

            // Filtros
            if ($request->filled('search')) {
                $search = $request->search;
                $query->where(function($q) use ($search) {
                    $q->where('descricao', 'like', "%{$search}%")
                      ->orWhere('tipo_prazo', 'like', "%{$search}%")
                      ->orWhere('observacoes', 'like', "%{$search}%")
                      ->orWhereHas('client', function($clientQuery) use ($search) {
                          $clientQuery->where('nome', 'like', "%{$search}%");
                      })
                      ->orWhereHas('process', function($processQuery) use ($search) {
                          $processQuery->where('numero', 'like', "%{$search}%");
                      });
                });
            }

            // Filtro por prioridade
            if ($request->filled('prioridade') && $request->prioridade !== 'all') {
                $query->where('prioridade', $request->prioridade);
            }

            // Filtro por status
            if ($request->filled('status') && $request->status !== 'all') {
                $query->where('status', $request->status);
            }

            // Filtro por tipo de prazo
            if ($request->filled('tipo_prazo') && $request->tipo_prazo !== 'all') {
                $query->where('tipo_prazo', $request->tipo_prazo);
            }

            // Filtro por dias restantes
            if ($request->filled('dias_restantes')) {
                $dias = $request->dias_restantes;
                switch ($dias) {
                    case 'hoje':
                        $query->whereDate('data_vencimento', Carbon::today());
                        break;
                    case 'amanha':
                        $query->whereDate('data_vencimento', Carbon::tomorrow());
                        break;
                    case '7_dias':
                        $query->vencendoEm(7);
                        break;
                    case 'vencidos':
                        $query->vencidos();
                        break;
                }
            }

            // Filtro por advogado
            if ($request->filled('advogado_id')) {
                $query->where('user_id', $request->advogado_id);
            }

            // Filtro por cliente
            if ($request->filled('client_id')) {
                $query->where('client_id', $request->client_id);
            }

            // Filtro por processo
            if ($request->filled('process_id')) {
                $query->where('process_id', $request->process_id);
            }

            // Ordenação
            $orderBy = $request->get('order_by', 'data_vencimento');
            $orderDirection = $request->get('order_direction', 'asc');
            
            if (in_array($orderBy, ['data_vencimento', 'created_at', 'prioridade', 'status'])) {
                $query->orderBy($orderBy, $orderDirection);
            }

            // Paginação
            $perPage = $request->get('per_page', 15);
            $prazos = $query->paginate($perPage);

            // Adicionar dados computados
            $prazos->getCollection()->transform(function ($prazo) {
                $prazo->dias_restantes = $prazo->dias_restantes;
                $prazo->is_vencido = $prazo->is_vencido;
                $prazo->precisa_alerta = $prazo->precisa_alerta;
                $prazo->cor_prioridade = $prazo->cor_prioridade;
                $prazo->cor_status = $prazo->cor_status;
                return $prazo;
            });

            return response()->json([
                'success' => true,
                'data' => $prazos,
                'message' => 'Prazos listados com sucesso'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao listar prazos: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'client_id' => 'required|exists:clientes,id',
                'process_id' => 'nullable|exists:processos,id',
                'user_id' => 'required|exists:users,id',
                'descricao' => 'required|string|max:255',
                'tipo_prazo' => 'required|string|max:255',
                'data_vencimento' => 'required|date|after_or_equal:today',
                'hora_vencimento' => 'required|date_format:H:i',
                'prioridade' => 'required|in:Normal,Alta,Urgente',
                'observacoes' => 'nullable|string',
                'dias_antecedencia' => 'integer|min:0|max:365'
            ]);

            $prazo = Prazo::create($validated);
            $prazo->load(['client', 'process', 'user']);

            // Adicionar dados computados
            $prazo->dias_restantes = $prazo->dias_restantes;
            $prazo->is_vencido = $prazo->is_vencido;
            $prazo->cor_prioridade = $prazo->cor_prioridade;
            $prazo->cor_status = $prazo->cor_status;

            return response()->json([
                'success' => true,
                'data' => $prazo,
                'message' => 'Prazo criado com sucesso'
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao criar prazo: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id): JsonResponse
    {
        try {
            $prazo = Prazo::with(['client', 'process', 'user'])->findOrFail($id);

            // Adicionar dados computados
            $prazo->dias_restantes = $prazo->dias_restantes;
            $prazo->is_vencido = $prazo->is_vencido;
            $prazo->precisa_alerta = $prazo->precisa_alerta;
            $prazo->cor_prioridade = $prazo->cor_prioridade;
            $prazo->cor_status = $prazo->cor_status;

            return response()->json([
                'success' => true,
                'data' => $prazo,
                'message' => 'Prazo encontrado'
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Prazo não encontrado'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar prazo: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {
            $prazo = Prazo::findOrFail($id);

            $validated = $request->validate([
                'client_id' => 'required|exists:clientes,id',
                'process_id' => 'nullable|exists:processos,id',
                'user_id' => 'required|exists:users,id',
                'descricao' => 'required|string|max:255',
                'tipo_prazo' => 'required|string|max:255',
                'data_vencimento' => 'required|date',
                'hora_vencimento' => 'required|date_format:H:i',
                'status' => 'required|in:Pendente,Em Andamento,Concluído,Vencido',
                'prioridade' => 'required|in:Normal,Alta,Urgente',
                'observacoes' => 'nullable|string',
                'dias_antecedencia' => 'integer|min:0|max:365'
            ]);

            $prazo->update($validated);
            $prazo->load(['client', 'process', 'user']);

            // Adicionar dados computados
            $prazo->dias_restantes = $prazo->dias_restantes;
            $prazo->is_vencido = $prazo->is_vencido;
            $prazo->cor_prioridade = $prazo->cor_prioridade;
            $prazo->cor_status = $prazo->cor_status;

            return response()->json([
                'success' => true,
                'data' => $prazo,
                'message' => 'Prazo atualizado com sucesso'
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Prazo não encontrado'
            ], 404);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar prazo: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id): JsonResponse
    {
        try {
            $prazo = Prazo::findOrFail($id);
            $prazo->delete();

            return response()->json([
                'success' => true,
                'message' => 'Prazo excluído com sucesso'
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Prazo não encontrado'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao excluir prazo: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Marcar prazo como concluído
     */
    public function marcarConcluido(string $id): JsonResponse
    {
        try {
            $prazo = Prazo::findOrFail($id);
            $prazo->marcarComoConcluido();
            $prazo->load(['client', 'process', 'user']);

            return response()->json([
                'success' => true,
                'data' => $prazo,
                'message' => 'Prazo marcado como concluído'
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Prazo não encontrado'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao marcar prazo como concluído: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obter estatísticas dos prazos
     */
    public function estatisticas(): JsonResponse
    {
        try {
            $hoje = Carbon::today();

            $stats = [
                'total' => Prazo::count(),
                'pendentes' => Prazo::pendentes()->count(),
                'vencendo_hoje' => Prazo::vencendoHoje()->count(),
                'vencendo_amanha' => Prazo::whereDate('data_vencimento', Carbon::tomorrow())->count(),
                'vencendo_7_dias' => Prazo::vencendoEm(7)->count(),
                'vencidos' => Prazo::vencidos()->count(),
                'concluidos' => Prazo::where('status', 'Concluído')->count(),
                'por_prioridade' => [
                    'normal' => Prazo::porPrioridade('Normal')->count(),
                    'alta' => Prazo::porPrioridade('Alta')->count(),
                    'urgente' => Prazo::porPrioridade('Urgente')->count()
                ],
                'por_status' => [
                    'pendente' => Prazo::where('status', 'Pendente')->count(),
                    'em_andamento' => Prazo::where('status', 'Em Andamento')->count(),
                    'concluido' => Prazo::where('status', 'Concluído')->count(),
                    'vencido' => Prazo::where('status', 'Vencido')->count()
                ]
            ];

            return response()->json([
                'success' => true,
                'data' => $stats,
                'message' => 'Estatísticas obtidas com sucesso'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao obter estatísticas: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obter dados para formulários (clientes, processos, advogados)
     */
    public function formData(): JsonResponse
    {
        try {
            $data = [
                'clientes' => Cliente::select('id', 'nome', 'cpf_cnpj')
                    ->where('status', 'ativo')
                    ->orderBy('nome')
                    ->get(),
                'processos' => Processo::select('id', 'numero', 'cliente_id')
                    ->with('cliente:id,nome')
                    ->orderBy('numero')
                    ->get(),
                'advogados' => User::select('id', 'name', 'email')
                    ->where('active', true)
                    ->orderBy('name')
                    ->get(),
                'tipos_prazo' => [
                    'Petição Inicial',
                    'Contestação',
                    'Recurso Ordinário',
                    'Recurso Extraordinário',
                    'Recurso Especial',
                    'Alegações Finais',
                    'Impugnação',
                    'Tréplica',
                    'Embargos de Declaração',
                    'Mandado de Segurança',
                    'Habeas Corpus',
                    'Outro'
                ],
                'prioridades' => ['Normal', 'Alta', 'Urgente'],
                'status_options' => ['Pendente', 'Em Andamento', 'Concluído', 'Vencido']
            ];

            return response()->json([
                'success' => true,
                'data' => $data,
                'message' => 'Dados do formulário obtidos com sucesso'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao obter dados do formulário: ' . $e->getMessage()
            ], 500);
        }
    }
}
EOF

echo "✅ PrazoController criado com sucesso!"

# 4. Verificar se o controller foi criado corretamente
if [ -f "app/Http/Controllers/Api/Admin/PrazoController.php" ]; then
    echo "✅ Arquivo do controller confirmado"
    
    # Verificar sintaxe PHP
    php -l "app/Http/Controllers/Api/Admin/PrazoController.php"
    
    if [ $? -eq 0 ]; then
        echo "✅ Sintaxe PHP válida"
    else
        echo "❌ Erro de sintaxe no controller"
        exit 1
    fi
else
    echo "❌ Erro: Controller não foi criado"
    exit 1
fi

echo ""
echo "🎉 ==============================================="
echo "✅ Script 141 - CONTROLLER CRIADO COM SUCESSO!"
echo "==============================================="
echo ""
echo "📋 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • index() - Listagem com filtros avançados"
echo "   • store() - Criação de prazos"
echo "   • show() - Visualização individual"
echo "   • update() - Atualização completa"
echo "   • destroy() - Exclusão"
echo "   • marcarConcluido() - Marcar como concluído"
echo "   • estatisticas() - Dashboard de métricas"
echo "   • formData() - Dados para formulários"
echo ""
echo "🔍 FILTROS DISPONÍVEIS:"
echo "   • Por busca (descrição, tipo, cliente, processo)"
echo "   • Por prioridade (Normal/Alta/Urgente)"
echo "   • Por status (Pendente/Em Andamento/Concluído/Vencido)"
echo "   • Por dias restantes (hoje/amanhã/7 dias/vencidos)"
echo "   • Por advogado, cliente ou processo"
echo ""
echo "📊 DADOS COMPUTADOS:"
echo "   • dias_restantes, is_vencido, precisa_alerta"
echo "   • cor_prioridade, cor_status"
echo ""
echo "🚀 PRÓXIMO SCRIPT: 142-add-prazo-routes.sh"
echo "   Objetivo: Adicionar rotas do PrazoController"
echo ""
echo "⚠️  DIGITE 'continuar' PARA EXECUTAR O PRÓXIMO SCRIPT"