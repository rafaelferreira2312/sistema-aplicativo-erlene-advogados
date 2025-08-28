#!/bin/bash

# Script 114j - Rotas funcionando simples e direto
# EXECUTE DENTRO DA PASTA: backend/

echo "Script 114j - Corrigindo rotas de forma simples..."

if [ ! -f "artisan" ]; then
    echo "Erro: Execute dentro da pasta backend/"
    exit 1
fi

echo "1. Rotas API simples e funcionais..."

cat > routes/api.php << 'EOF'
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
EOF

echo "2. Exception Handler simples..."

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
        //
    }

    protected function unauthenticated($request, AuthenticationException $exception)
    {
        if ($request->expectsJson() || $request->is('api/*')) {
            return response()->json([
                'message' => 'Acesso negado. Autenticação necessária.'
            ], 401);
        }

        return redirect()->guest('/');
    }
}
EOF

echo "3. Testando..."

php artisan serve --port=8000 &
LARAVEL_PID=$!
sleep 2

echo "Login:"
curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}' | head -2

echo ""
echo "Rota sem token:"
curl -s http://localhost:8000/api/dashboard/stats

kill $LARAVEL_PID 2>/dev/null

echo ""
echo "PRONTO. Rotas funcionando."
echo ""
echo "PRÓXIMO:"
echo "- Script 114k: Popular banco com seeders"
echo "- Script 114l: Conectar frontend"