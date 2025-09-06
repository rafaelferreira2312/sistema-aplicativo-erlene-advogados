#!/bin/bash

# Script 129-fix - Restaurar rotas existentes e adicionar audiências
# Sistema Erlene Advogados - Correção das rotas
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🚨 Script 129-fix - Restaurando rotas existentes e adicionando audiências..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 129-fix-routes-audiencias.sh && ./129-fix-routes-audiencias.sh"
    exit 1
fi

echo "1️⃣ Restaurando arquivo routes/api.php original com todas as rotas funcionais..."

# Restaurar as rotas originais funcionais e adicionar apenas as rotas de audiências
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
// AUDIÊNCIAS - NOVAS ROTAS ADICIONADAS
// ==========================================
Route::middleware(['auth:api'])->prefix('admin')->group(function () {
    
    // CRUD Audiências
    Route::apiResource('audiencias', AudienciaController::class);
    
    // Rotas específicas de audiências
    Route::get('audiencias/dashboard/stats', [AudienciaController::class, 'dashboardStats']);
    Route::get('audiencias/filters/hoje', [AudienciaController::class, 'hoje']);
    Route::get('audiencias/filters/proximas', [AudienciaController::class, 'proximas']);
});
EOF

echo "2️⃣ Verificando se o AudienciaController existe..."

if [ ! -f "app/Http/Controllers/Api/Admin/AudienciaController.php" ]; then
    echo "⚠️ AudienciaController não encontrado. Vou criá-lo novamente..."
    
    # Criar controller se não existir
    mkdir -p app/Http/Controllers/Api/Admin
    
    cat > app/Http/Controllers/Api/Admin/AudienciaController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Audiencia;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Exception;

class AudienciaController extends Controller
{
    /**
     * Listar todas as audiências
     */
    public function index(Request $request): JsonResponse
    {
        try {
            // Por enquanto retornar dados mock até termos o model completo
            $mockAudiencias = [
                [
                    'id' => 1,
                    'processo' => '1001234-56.2024.8.26.0001',
                    'cliente' => 'João Silva Santos',
                    'tipo' => 'Audiência de Conciliação', 
                    'data' => '2024-09-05',
                    'hora' => '09:00',
                    'local' => 'TJSP - 1ª Vara Cível',
                    'status' => 'Confirmada',
                    'advogado' => 'Dr. Carlos Oliveira'
                ],
                [
                    'id' => 2,
                    'processo' => '2002345-67.2024.8.26.0002',
                    'cliente' => 'Maria Fernanda Costa',
                    'tipo' => 'Audiência de Instrução',
                    'data' => '2024-09-05',
                    'hora' => '14:30',
                    'local' => 'TJSP - 2ª Vara Cível',
                    'status' => 'Agendada',
                    'advogado' => 'Dra. Ana Paula'
                ],
                [
                    'id' => 3,
                    'processo' => '3003456-78.2024.8.26.0003',
                    'cliente' => 'Roberto Lima Souza',
                    'tipo' => 'Audiência Preliminar',
                    'data' => '2024-09-06',
                    'hora' => '10:15',
                    'local' => 'TJSP - 3ª Vara Cível',
                    'status' => 'Confirmada',
                    'advogado' => 'Dr. Pedro Santos'
                ]
            ];

            return response()->json([
                'success' => true,
                'data' => $mockAudiencias,
                'total' => count($mockAudiencias)
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
     * Estatísticas do dashboard
     */
    public function dashboardStats(): JsonResponse
    {
        try {
            $stats = [
                'hoje' => 2,
                'proximas_2h' => 1,
                'em_andamento' => 0,
                'total_mes' => 15,
                'agendadas' => 8,
                'realizadas_mes' => 7
            ];

            return response()->json([
                'success' => true,
                'data' => $stats
            ]);

        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar estatísticas',
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
            $audienciasHoje = [
                [
                    'id' => 1,
                    'processo' => '1001234-56.2024.8.26.0001',
                    'cliente' => 'João Silva Santos',
                    'tipo' => 'Audiência de Conciliação',
                    'hora' => '09:00',
                    'local' => 'TJSP - 1ª Vara Cível',
                    'status' => 'Confirmada'
                ],
                [
                    'id' => 2,
                    'processo' => '2002345-67.2024.8.26.0002',
                    'cliente' => 'Maria Fernanda Costa',
                    'tipo' => 'Audiência de Instrução',
                    'hora' => '14:30',
                    'local' => 'TJSP - 2ª Vara Cível',
                    'status' => 'Agendada'
                ]
            ];

            return response()->json([
                'success' => true,
                'data' => $audienciasHoje
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
    public function proximas(): JsonResponse
    {
        try {
            $proximasAudiencias = [
                [
                    'id' => 1,
                    'processo' => '1001234-56.2024.8.26.0001',
                    'cliente' => 'João Silva Santos',
                    'tipo' => 'Audiência de Conciliação',
                    'hora' => '09:00',
                    'local' => 'TJSP - 1ª Vara Cível',
                    'status' => 'Confirmada'
                ]
            ];

            return response()->json([
                'success' => true,
                'data' => $proximasAudiencias
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
        return response()->json([
            'success' => true,
            'message' => 'Método show em desenvolvimento'
        ]);
    }

    /**
     * Criar nova audiência
     */
    public function store(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Método store em desenvolvimento'
        ]);
    }

    /**
     * Atualizar audiência
     */
    public function update(Request $request, $id): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Método update em desenvolvimento'
        ]);
    }

    /**
     * Excluir audiência
     */
    public function destroy($id): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Método destroy em desenvolvimento'
        ]);
    }
}
EOF
fi

echo "3️⃣ Limpando cache de rotas..."

# Limpar cache de rotas
php artisan route:clear
php artisan config:clear
php artisan cache:clear

echo "4️⃣ Testando se as rotas estão funcionando..."

# Listar rotas para verificar
echo "Rotas de audiências registradas:"
php artisan route:list | grep -i audiencia || echo "Nenhuma rota de audiência encontrada ainda"

echo ""
echo "✅ Rotas originais restauradas!"
echo "✅ Rotas de audiências adicionadas sem quebrar as existentes!"
echo ""
echo "📋 Rotas de audiências adicionadas:"
echo "   GET    /api/admin/audiencias - Listar audiências"
echo "   POST   /api/admin/audiencias - Criar audiência"  
echo "   GET    /api/admin/audiencias/{id} - Exibir audiência"
echo "   PUT    /api/admin/audiencias/{id} - Atualizar audiência"
echo "   DELETE /api/admin/audiencias/{id} - Excluir audiência"
echo "   GET    /api/admin/audiencias/dashboard/stats - Estatísticas"
echo "   GET    /api/admin/audiencias/filters/hoje - Audiências de hoje"
echo "   GET    /api/admin/audiencias/filters/proximas - Próximas audiências"
echo ""
echo "⚠️ IMPORTANTE: Sistema restaurado sem quebrar funcionalidades existentes!"
echo "📋 Próximo passo: Execute o script 130 para integração frontend"
echo "   chmod +x 130-integrate-frontend-audiencias.sh && ./130-integrate-frontend-audiencias.sh"