#!/bin/bash

# Script 114i - Corrigir mensagens de autenticação
# EXECUTE DENTRO DA PASTA: backend/

echo "Script 114i - Corrigindo mensagens de autenticação..."

if [ ! -f "artisan" ]; then
    echo "Erro: Execute dentro da pasta backend/"
    exit 1
fi

echo "1. Atualizando Exception Handler..."

cat > app/Exceptions/Handler.php << 'EOF'
<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Auth\AuthenticationException;
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
        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json([
                'success' => false,
                'message' => 'Você precisa estar autenticado para acessar esta rota.',
                'rota_acessada' => $request->getPathInfo(),
                'metodo' => $request->getMethod(),
                'instrucoes' => 'Faça login em POST /api/auth/login e use o token Bearer'
            ], 401);
        }

        return redirect()->guest('/login');
    }
}
EOF

echo "2. Removendo fallback das rotas..."

cat > routes/api.php << 'EOF'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

// Rotas públicas
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/portal/login', [AuthController::class, 'portalLogin']);
});

// Rotas protegidas
Route::middleware('auth:api')->group(function () {
    
    Route::prefix('auth')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
    
    Route::get('/dashboard/stats', function () {
        $user = auth()->user();
        
        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'nome' => $user->nome ?? $user->name,
                    'email' => $user->email
                ],
                'stats' => [
                    'total_users' => \App\Models\User::count(),
                    'timestamp' => now()
                ]
            ]
        ]);
    });
    
    Route::get('/users', function () {
        return response()->json([
            'success' => true,
            'data' => \App\Models\User::select('id', 'nome', 'name', 'email')->get()
        ]);
    });
});
EOF

echo "3. Testando mensagens..."

php artisan serve --port=8000 &
LARAVEL_PID=$!
sleep 2

echo "Testando rota protegida sem token:"
curl -s http://localhost:8000/api/dashboard/stats | head -3

kill $LARAVEL_PID 2>/dev/null

echo ""
echo "SCRIPT 114I CONCLUÍDO!"
echo ""
echo "Agora quando acessar rota protegida sem token:"
echo "- Mostra rota que tentou acessar"
echo "- Informa que precisa estar autenticado"
echo "- Dá instruções claras"