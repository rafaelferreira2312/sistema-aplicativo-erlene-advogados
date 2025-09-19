# Análise das Rotas Laravel
## Gerado em: 2025-09-19 11:27:07

## Rotas da API (routes/api.php)
```php
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
```

## Resumo das Rotas Encontradas
- **GET**: 25 rotas
- **POST**: 7 rotas
- **PUT**: 3 rotas
- **DELETE**: 2 rotas
- **RESOURCE**: 0
0 rotas

## Controllers Utilizados nas Rotas
- AudienciaController
- AuthController
- CNJController
- ClientController
- DashboardController
- IntegrationController
- ProcessController

## Rotas Web (routes/web.php)
```php
<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});
```
