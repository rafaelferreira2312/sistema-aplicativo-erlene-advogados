<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

// Login (público)
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/portal/login', [AuthController::class, 'portalLogin']);

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

// Rotas de Processos - Sistema Erlene Advogados
Route::middleware(['auth:api'])->prefix('admin')->group(function () {
    
    // CRUD Processos
    Route::get('/processes', [App\Http\Controllers\Api\Admin\ProcessController::class, 'index']);
    Route::post('/processes', [App\Http\Controllers\Api\Admin\ProcessController::class, 'store']);
    Route::get('/processes/{id}', [App\Http\Controllers\Api\Admin\ProcessController::class, 'show']);
    Route::put('/processes/{id}', [App\Http\Controllers\Api\Admin\ProcessController::class, 'update']);
    Route::delete('/processes/{id}', [App\Http\Controllers\Api\Admin\ProcessController::class, 'destroy']);
    
    // Sincronização CNJ
    Route::post('/processes/{id}/sync-cnj', [App\Http\Controllers\Api\Admin\ProcessController::class, 'syncWithCNJ']);
    
    // Rotas auxiliares para processos
    Route::get('/processes/{id}/movements', [App\Http\Controllers\Api\Admin\ProcessController::class, 'getMovements']);
    Route::post('/processes/{id}/movements', [App\Http\Controllers\Api\Admin\ProcessController::class, 'addMovement']);
    Route::get('/processes/{id}/documents', [App\Http\Controllers\Api\Admin\ProcessController::class, 'getDocuments']);
    Route::get('/processes/{id}/appointments', [App\Http\Controllers\Api\Admin\ProcessController::class, 'getAppointments']);
});
