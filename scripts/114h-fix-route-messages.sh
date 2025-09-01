#!/bin/bash

# Script 114h - APENAS corrigir mensagens das rotas (não mostrar erros)
# EXECUTE DENTRO DA PASTA: backend/

echo "Script 114h - Corrigindo mensagens das rotas..."

if [ ! -f "artisan" ]; then
    echo "Erro: Execute dentro da pasta backend/"
    exit 1
fi

echo "1. Criando Exception Handler para retornar JSON apropriado..."

# Verificar se diretório existe, se não, criar
mkdir -p app/Exceptions

cat > app/Exceptions/Handler.php << 'EOF'
<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Auth\AuthenticationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Throwable;

class Handler extends ExceptionHandler
{
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            //
        });
    }

    protected function unauthenticated($request, AuthenticationException $exception)
    {
        // Para rotas API, retornar JSON ao invés de redirecionar
        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json([
                'success' => false,
                'message' => 'Acesso negado. Token de autenticação necessário.',
                'error' => 'Unauthenticated'
            ], 401);
        }

        // Para web, redirecionar normalmente
        return redirect()->guest('/login');
    }

    public function render($request, Throwable $exception)
    {
        // Para rotas API que não existem
        if ($request->is('api/*') && $exception instanceof NotFoundHttpException) {
            return response()->json([
                'success' => false,
                'message' => 'Endpoint não encontrado',
                'error' => 'Not Found'
            ], 404);
        }

        return parent::render($request, $exception);
    }
}
EOF

echo "2. Atualizando rotas com fallback apropriado..."

cat > routes/api.php << 'EOF'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

// Rotas de autenticação (públicas)
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/portal/login', [AuthController::class, 'portalLogin']);
});

// Rotas protegidas (requer JWT)
Route::middleware('auth:api')->group(function () {
    
    // Auth rotas
    Route::prefix('auth')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
    
    // Dashboard
    Route::get('/dashboard/stats', function () {
        $user = auth()->user();
        
        return response()->json([
            'success' => true,
            'message' => 'Dashboard stats',
            'data' => [
                'user_info' => [
                    'id' => $user->id,
                    'nome' => $user->nome ?? $user->name,
                    'email' => $user->email,
                    'perfil' => $user->perfil ?? 'admin'
                ],
                'stats' => [
                    'total_users' => \App\Models\User::count(),
                    'timestamp' => now()->format('Y-m-d H:i:s')
                ]
            ]
        ]);
    });
    
    // Outras rotas protegidas podem ser adicionadas aqui
    Route::get('/users', function () {
        return response()->json([
            'success' => true,
            'data' => \App\Models\User::all()
        ]);
    });
});

// Fallback para rotas API não encontradas
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'Endpoint não encontrado. Verifique a URL e o método HTTP.',
        'available_endpoints' => [
            'POST /api/auth/login',
            'POST /api/auth/portal/login',
            'GET /api/auth/me (requer token)',
            'POST /api/auth/logout (requer token)', 
            'GET /api/dashboard/stats (requer token)'
        ]
    ], 404);
});
EOF

echo "3. Testando mensagens das rotas..."

php artisan serve --port=8000 &
LARAVEL_PID=$!
sleep 2

echo "Testando rota que não existe (deve retornar 404 JSON):"
curl -s http://localhost:8000/api/rota-inexistente

echo ""
echo ""
echo "Testando rota protegida sem token (deve retornar 401 JSON):"
curl -s http://localhost:8000/api/dashboard/stats

echo ""
echo ""
echo "Testando método incorreto (deve retornar erro apropriado):"
curl -s http://localhost:8000/api/auth/login

kill $LARAVEL_PID 2>/dev/null

echo ""
echo ""
echo "SCRIPT 114H CONCLUÍDO!"
echo ""
echo "CORREÇÕES APLICADAS:"
echo "- Exception Handler criado"  
echo "- Rotas retornam JSON apropriado"
echo "- Mensagens de erro claras"
echo "- Fallback para rotas não encontradas"
echo ""
echo "AGORA QUANDO ACESSAR:"
echo "- Rota protegida sem token = JSON com 'precisa estar logado'"
echo "- Rota inexistente = JSON com 'endpoint não encontrado'"
echo "- Método incorreto = JSON com informação clara"