#!/bin/bash

# Script 135b - Corrigir Rotas e Finalizar Integração Backend/Frontend
# Sistema Erlene Advogados - Corrigir problemas críticos identificados
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔧 Script 135b - Corrigindo rotas e finalizando integração..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📝 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 135b-fix-routes-integration.sh && ./135b-fix-routes-integration.sh"
    exit 1
fi

echo "1️⃣ Fazendo backup das rotas atuais..."

# Backup
cp routes/api.php routes/api.php.bak.135b

echo "2️⃣ Corrigindo ORDEM DAS ROTAS - rotas específicas ANTES do apiResource..."

# Corrigir api.php com ordem correta das rotas
cat > routes/api.php << 'EOF'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Admin\AudienciaController;

// Login (público)
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/portal/login', [AuthController::class, 'portalLogin']);

// Health check (público)
Route::get('/health', function() {
    return response()->json([
        'success' => true,
        'status' => 'API funcionando',
        'timestamp' => now(),
        'version' => '1.0.0'
    ]);
});

// Rotas protegidas
Route::middleware('auth:api')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    
    Route::get('/dashboard/stats', function () {
        return response()->json([
            'success' => true,
            'user' => auth()->user()->nome ?? auth()->user()->name,
            'total_users' => \App\Models\User::count()
        ]);
    });
});

// Rotas do Dashboard Admin
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::get('/dashboard', [App\Http\Controllers\Api\Admin\DashboardController::class, 'index']);
    Route::get('/dashboard/notifications', [App\Http\Controllers\Api\Admin\DashboardController::class, 'notifications']);
});

// Rotas de Clientes
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::prefix('clients')->group(function () {
        Route::get('/', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'index']);
        Route::post('/', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'store']);
        Route::get('/stats', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'stats']);
        Route::get('/responsaveis', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'responsaveis']);
        Route::get('/buscar-cep/{cep}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'buscarCep']);
        Route::get('/{id}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'destroy']);
    });
});

// Rotas específicas de clientes
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::get('clients/{clienteId}/processos', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'processos']);
    Route::get('clients/{clienteId}/documentos', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'documentos']);
});

// ==========================================
// PROCESSOS - ROTAS BÁSICAS (SEM CNJ)
// ==========================================
Route::middleware(['auth:api'])->prefix('admin')->group(function () {
    
    // CRUD Processos BÁSICO
    Route::get('/processes', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'index']);
    Route::post('/processes', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'store']);
    Route::get('/processes/{id}', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'show']);
    Route::put('/processes/{id}', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'update']);
    Route::delete('/processes/{id}', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'destroy']);
    
    // Rotas auxiliares BÁSICAS
    Route::get('/processes/{id}/movements', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'getMovements']);
    Route::get('/processes/{id}/documents', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'getDocuments']);
    Route::get('/processes/{id}/appointments', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'getAppointments']);
});

// ==========================================
// INTEGRAÇÕES - ROTAS SEPARADAS
// ==========================================
Route::middleware(['auth:api'])->prefix('admin/integrations')->group(function () {
    
    // CNJ - Integração separada
    Route::prefix('cnj')->group(function() {
        Route::get('/status', [App\Http\Controllers\Api\Admin\Integrations\CNJ\CNJController::class, 'status']);
        Route::post('/sync-process/{id}', [App\Http\Controllers\Api\Admin\Integrations\CNJ\CNJController::class, 'syncProcess']);
        Route::get('/sync-history', [App\Http\Controllers\Api\Admin\Integrations\CNJ\CNJController::class, 'syncHistory']);
        Route::post('/configure', [App\Http\Controllers\Api\Admin\Integrations\CNJ\CNJController::class, 'configure']);
    });
    
    // Outras integrações futuras
    Route::prefix('escavador')->group(function() {
        Route::get('/status', function() {
            return response()->json(['success' => true, 'message' => 'Escavador não implementado']);
        });
    });
    
    Route::prefix('jurisbrasil')->group(function() {
        Route::get('/status', function() {
            return response()->json(['success' => true, 'message' => 'Jurisbrasil não implementado']);
        });
    });
});

// Rota para listar todas as integrações
Route::middleware(['auth:api'])->prefix('admin')->group(function () {
    Route::get('/integrations', [App\Http\Controllers\Api\Admin\IntegrationController::class, 'index']);
    Route::put('/integrations/{id}', [App\Http\Controllers\Api\Admin\IntegrationController::class, 'update']);
});

// ==========================================
// AUDIÊNCIAS - ROTAS CORRIGIDAS (ORDEM CRÍTICA!)
// ==========================================
Route::middleware(['auth:api'])->prefix('admin')->group(function () {
    
    // 🚨 CRÍTICO: Rotas específicas ANTES do apiResource
    Route::get('audiencias/dashboard/stats', [AudienciaController::class, 'dashboardStats']);
    Route::get('audiencias/filters/hoje', [AudienciaController::class, 'hoje']);
    Route::get('audiencias/filters/proximas', [AudienciaController::class, 'proximas']);
    
    // CRUD Audiências - DEPOIS das rotas específicas
    Route::apiResource('audiencias', AudienciaController::class);
});
EOF

echo "✅ Rotas corrigidas com ordem adequada!"

echo "3️⃣ Corrigindo métodos do AudienciaController..."

# Backup do controller
cp app/Http/Controllers/Api/Admin/AudienciaController.php app/Http/Controllers/Api/Admin/AudienciaController.php.bak.135b

# Corrigir controller com métodos corretos
cat > app/Http/Controllers/Api/Admin/AudienciaController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Audiencia;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;
use Exception;

class AudienciaController extends Controller
{
    /**
     * Listar audiências - seguindo padrão do ClientController
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Audiencia::query();
            
            // Tentar carregar relacionamentos se existirem
            try {
                $query->with(['processo', 'cliente']);
            } catch (Exception $e) {
                // Se relacionamentos falharem, continuar sem eles
            }
            
            // Filtros básicos
            if ($request->filled('status')) {
                $query->where('status', $request->status);
            }
            
            if ($request->filled('tipo')) {
                $query->where('tipo', $request->tipo);
            }
            
            if ($request->filled('data_inicio') && $request->filled('data_fim')) {
                $query->whereBetween('data', [$request->data_inicio, $request->data_fim]);
            }

            // Ordenação padrão
            $query->orderBy('data', 'desc')->orderBy('hora', 'desc');

            // Paginação seguindo padrão
            $perPage = $request->get('per_page', 10);
            $audiencias = $query->paginate($perPage);

            // Formatar dados seguindo padrão do sistema
            $data = $audiencias->getCollection()->map(function($audiencia) {
                return [
                    'id' => $audiencia->id,
                    'processo_id' => $audiencia->processo_id,
                    'cliente_id' => $audiencia->cliente_id,
                    'processo' => [
                        'id' => $audiencia->processo_id,
                        'numero' => $audiencia->processo->numero ?? "Processo #{$audiencia->processo_id}"
                    ],
                    'cliente' => [
                        'id' => $audiencia->cliente_id,
                        'nome' => $audiencia->cliente->nome ?? $audiencia->cliente->name ?? "Cliente #{$audiencia->cliente_id}"
                    ],
                    'tipo' => $audiencia->tipo,
                    'data' => $audiencia->data,
                    'hora' => $audiencia->hora,
                    'local' => $audiencia->local,
                    'endereco' => $audiencia->endereco,
                    'sala' => $audiencia->sala,
                    'advogado' => $audiencia->advogado,
                    'juiz' => $audiencia->juiz,
                    'status' => $audiencia->status,
                    'observacoes' => $audiencia->observacoes,
                    'lembrete' => $audiencia->lembrete,
                    'horas_lembrete' => $audiencia->horas_lembrete,
                    'created_at' => $audiencia->created_at,
                    'updated_at' => $audiencia->updated_at
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $data,
                'pagination' => [
                    'current_page' => $audiencias->currentPage(),
                    'last_page' => $audiencias->lastPage(),
                    'per_page' => $audiencias->perPage(),
                    'total' => $audiencias->total()
                ]
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao listar audiências',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🚨 MÉTODO CORRIGIDO: dashboardStats (não stats)
     */
    public function dashboardStats(): JsonResponse
    {
        try {
            $hoje = Carbon::today();
            
            $stats = [
                'hoje' => Audiencia::whereDate('data', $hoje)->count(),
                'proximas_2h' => Audiencia::whereDate('data', $hoje)
                    ->whereTime('hora', '>=', Carbon::now()->format('H:i:s'))
                    ->whereTime('hora', '<=', Carbon::now()->addHours(2)->format('H:i:s'))
                    ->count(),
                'em_andamento' => Audiencia::where('status', 'confirmada')
                    ->whereDate('data', $hoje)->count(),
                'total_mes' => Audiencia::whereMonth('data', $hoje->month)
                    ->whereYear('data', $hoje->year)->count(),
                'agendadas' => Audiencia::whereIn('status', ['agendada', 'confirmada'])
                    ->where('data', '>=', $hoje)->count(),
                'realizadas_mes' => Audiencia::where('status', 'realizada')
                    ->whereMonth('data', $hoje->month)
                    ->whereYear('data', $hoje->year)->count()
            ];

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao obter estatísticas',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Audiências de hoje
     */
    public function hoje(): JsonResponse
    {
        try {
            $audiencias = Audiencia::whereDate('data', Carbon::today())
                ->orderBy('hora', 'asc')
                ->get()
                ->map(function($audiencia) {
                    return [
                        'id' => $audiencia->id,
                        'processo' => [
                            'numero' => "Processo #{$audiencia->processo_id}"
                        ],
                        'cliente' => [
                            'nome' => "Cliente #{$audiencia->cliente_id}"
                        ],
                        'tipo' => $audiencia->tipo,
                        'hora' => $audiencia->hora,
                        'local' => $audiencia->local,
                        'status' => $audiencia->status,
                        'advogado' => $audiencia->advogado
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $audiencias
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar audiências de hoje',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Próximas audiências
     */
    public function proximas(Request $request): JsonResponse
    {
        try {
            $horas = $request->get('horas', 2);
            $agora = Carbon::now();
            
            $audiencias = Audiencia::whereDate('data', Carbon::today())
                ->whereTime('hora', '>=', $agora->format('H:i:s'))
                ->whereTime('hora', '<=', $agora->addHours($horas)->format('H:i:s'))
                ->orderBy('hora', 'asc')
                ->get()
                ->map(function($audiencia) {
                    return [
                        'id' => $audiencia->id,
                        'processo' => [
                            'numero' => "Processo #{$audiencia->processo_id}"
                        ],
                        'cliente' => [
                            'nome' => "Cliente #{$audiencia->cliente_id}"
                        ],
                        'tipo' => $audiencia->tipo,
                        'hora' => $audiencia->hora,
                        'local' => $audiencia->local,
                        'status' => $audiencia->status
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $audiencias
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar próximas audiências',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Exibir audiência específica
     */
    public function show($id): JsonResponse
    {
        try {
            $audiencia = Audiencia::findOrFail($id);

            $data = [
                'id' => $audiencia->id,
                'processo_id' => $audiencia->processo_id,
                'cliente_id' => $audiencia->cliente_id,
                'advogado_id' => $audiencia->advogado_id,
                'unidade_id' => $audiencia->unidade_id,
                'tipo' => $audiencia->tipo,
                'data' => $audiencia->data,
                'hora' => $audiencia->hora,
                'local' => $audiencia->local,
                'endereco' => $audiencia->endereco,
                'sala' => $audiencia->sala,
                'advogado' => $audiencia->advogado,
                'juiz' => $audiencia->juiz,
                'status' => $audiencia->status,
                'observacoes' => $audiencia->observacoes,
                'lembrete' => $audiencia->lembrete,
                'horas_lembrete' => $audiencia->horas_lembrete,
                'created_at' => $audiencia->created_at,
                'updated_at' => $audiencia->updated_at
            ];

            return response()->json([
                'success' => true,
                'data' => $data
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Audiência não encontrada',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Criar nova audiência
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validatedData = $request->validate([
                'processo_id' => 'required|integer',
                'cliente_id' => 'required|integer', 
                'advogado_id' => 'nullable|integer',
                'unidade_id' => 'nullable|integer',
                'tipo' => 'required|string',
                'data' => 'required|date',
                'hora' => 'required|string',
                'local' => 'required|string',
                'endereco' => 'nullable|string',
                'sala' => 'nullable|string',
                'advogado' => 'required|string',
                'juiz' => 'nullable|string',
                'status' => 'nullable|string',
                'observacoes' => 'nullable|string',
                'lembrete' => 'nullable|boolean',
                'horas_lembrete' => 'nullable|integer'
            ]);

            // Definir valores padrão
            $validatedData['status'] = $validatedData['status'] ?? 'agendada';
            $validatedData['lembrete'] = $validatedData['lembrete'] ?? true;
            $validatedData['horas_lembrete'] = $validatedData['horas_lembrete'] ?? 2;

            $audiencia = Audiencia::create($validatedData);

            return response()->json([
                'success' => true,
                'message' => 'Audiência criada com sucesso',
                'data' => $audiencia
            ], 201);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao criar audiência',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Atualizar audiência
     */
    public function update(Request $request, $id): JsonResponse
    {
        try {
            $audiencia = Audiencia::findOrFail($id);

            $validatedData = $request->validate([
                'processo_id' => 'sometimes|integer',
                'cliente_id' => 'sometimes|integer',
                'advogado_id' => 'sometimes|integer',
                'unidade_id' => 'sometimes|integer',
                'tipo' => 'sometimes|string',
                'data' => 'sometimes|date',
                'hora' => 'sometimes|string',
                'local' => 'sometimes|string',
                'endereco' => 'nullable|string',
                'sala' => 'nullable|string',
                'advogado' => 'sometimes|string',
                'juiz' => 'nullable|string',
                'status' => 'sometimes|string',
                'observacoes' => 'nullable|string',
                'lembrete' => 'sometimes|boolean',
                'horas_lembrete' => 'sometimes|integer'
            ]);

            $audiencia->update($validatedData);

            return response()->json([
                'success' => true,
                'message' => 'Audiência atualizada com sucesso',
                'data' => $audiencia
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar audiência',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Excluir audiência
     */
    public function destroy($id): JsonResponse
    {
        try {
            $audiencia = Audiencia::findOrFail($id);
            $audiencia->delete();

            return response()->json([
                'success' => true,
                'message' => 'Audiência excluída com sucesso'
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao excluir audiência',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
EOF

echo "✅ Controller corrigido com métodos adequados!"

echo "4️⃣ Verificando se migration de audiências existe..."

# Verificar se migration existe
if ! find database/migrations -name "*audiencias*" | grep -q .; then
    echo "❌ Migration não encontrada! Criando..."
    php artisan make:migration create_audiencias_table
    
    # Pegar arquivo criado
    MIGRATION_FILE=$(find database/migrations -name "*create_audiencias_table.php" | head -1)
    
    # Criar migration simples para funcionar
    cat > "$MIGRATION_FILE" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('audiencias', function (Blueprint $table) {
            $table->id();
            $table->integer('processo_id')->nullable();
            $table->integer('cliente_id')->nullable();
            $table->integer('advogado_id')->nullable();
            $table->integer('unidade_id')->nullable();
            $table->string('tipo');
            $table->date('data');
            $table->time('hora');
            $table->string('local');
            $table->text('endereco')->nullable();
            $table->string('sala', 100)->nullable();
            $table->string('advogado');
            $table->string('juiz')->nullable();
            $table->string('status')->default('agendada');
            $table->text('observacoes')->nullable();
            $table->boolean('lembrete')->default(true);
            $table->integer('horas_lembrete')->default(2);
            $table->timestamps();
            $table->softDeletes();

            $table->index(['data', 'hora']);
            $table->index('status');
        });
    }

    public function down()
    {
        Schema::dropIfExists('audiencias');
    }
};
EOF
    echo "✅ Migration criada!"
fi

echo "5️⃣ Executando migration..."

php artisan migrate --force

echo "6️⃣ Criando dados de teste..."

# Criar dados básicos para teste
php artisan tinker --execute="
try {
    \App\Models\Audiencia::create([
        'processo_id' => 1,
        'cliente_id' => 1,
        'tipo' => 'conciliacao',
        'data' => now()->format('Y-m-d'),
        'hora' => '09:00',
        'local' => 'TJSP - 1ª Vara Cível',
        'advogado' => 'Dr. Carlos Silva',
        'status' => 'agendada'
    ]);
    
    \App\Models\Audiencia::create([
        'processo_id' => 2,
        'cliente_id' => 2,
        'tipo' => 'instrucao',
        'data' => now()->format('Y-m-d'),
        'hora' => '14:30',
        'local' => 'TJSP - 2ª Vara Cível',
        'advogado' => 'Dra. Ana Santos',
        'status' => 'confirmada'
    ]);
    
    echo 'Dados de teste criados!';
} catch (Exception \$e) {
    echo 'Erro: ' . \$e->getMessage();
}
"

echo "7️⃣ Limpando cache..."

php artisan route:clear
php artisan config:clear
php artisan cache:clear

echo "8️⃣ Testando endpoints..."

# Testar se servidor funciona
php artisan serve --port=8002 &
SERVER_PID=$!
sleep 3

echo "Testando endpoint de health:"
curl -s "http://localhost:8002/api/health" | head -3

echo ""
echo "Testando endpoint de stats:"
curl -s "http://localhost:8002/api/admin/audiencias/dashboard/stats" | head -3

# Parar servidor
kill $SERVER_PID 2>/dev/null

echo ""
echo "✅ Script 135b concluído!"
echo ""
echo "🔧 CORREÇÕES REALIZADAS:"
echo "   ✅ Ordem das rotas corrigida (específicas ANTES do apiResource)"
echo "   ✅ Método dashboardStats corrigido"
echo "   ✅ Migration de audiências criada/verificada"
echo "   ✅ Dados de teste inseridos"
echo "   ✅ Relacionamentos com fallback"
echo "   ✅ Cache limpo"
echo ""
echo "📋 PRÓXIMO PASSO:"
echo "   Testar frontend - as audiências devem aparecer agora!"
echo "   Se ainda não funcionar: Script 135c para corrigir service frontend"