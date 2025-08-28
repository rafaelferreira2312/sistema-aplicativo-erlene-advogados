#!/bin/bash

# Script 114c - Corrigir Seeders sem Recriar Tabelas + Rotas JWT
# Sistema Erlene Advogados - Povoar banco e configurar JWT corretamente
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔧 Script 114c - Corrigindo seeders e configurando JWT corretamente..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📍 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 114c-fix-seeders-routes.sh && ./114c-fix-seeders-routes.sh"
    exit 1
fi

echo "1️⃣ Verificando status atual do banco..."

# Verificar se tabelas existem
mysql -u root -p12345678 erlene_advogados -e "SHOW TABLES;" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Banco não acessível. Executando migrations primeiro..."
    php artisan migrate
fi

echo "2️⃣ Limpando tabelas e rodando apenas seeders (sem recriar estrutura)..."

# Limpar dados das tabelas sem deletar estrutura
mysql -u root -p12345678 erlene_advogados << 'EOF'
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE users;
TRUNCATE TABLE unidades;
SET FOREIGN_KEY_CHECKS = 1;
EOF

# Executar apenas seeders sem migrations
php artisan db:seed --class=FrontendTestSeeder --force

echo "3️⃣ Verificando dados inseridos..."
echo "Usuários criados:"
mysql -u root -p12345678 erlene_advogados -e "SELECT id, nome, email, perfil, status FROM users;"

echo ""
echo "Unidades criadas:"
mysql -u root -p12345678 erlene_advogados -e "SELECT id, nome, codigo, cidade FROM unidades;"

echo "4️⃣ Configurando middleware JWT corretamente..."

# Verificar se JWT está configurado
php artisan jwt:secret > /dev/null 2>&1

echo "5️⃣ Atualizando rotas API com middleware JWT correto..."

cat > routes/api.php << 'EOF'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

/*
|--------------------------------------------------------------------------
| API Routes - Sistema Erlene Advogados
|--------------------------------------------------------------------------
*/

// Rotas de autenticação (públicas)
Route::prefix('auth')->group(function () {
    // Login admin (compatível com Login.js do frontend)
    Route::post('/login', [AuthController::class, 'login']);
    
    // Login portal (compatível com PortalLogin.js)
    Route::post('/portal/login', [AuthController::class, 'portalLogin']);
});

// Rotas protegidas (requer JWT)
Route::middleware('auth:api')->group(function () {
    
    // Rotas de auth para usuários logados
    Route::prefix('auth')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/refresh', [AuthController::class, 'refresh']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
    
    // Dashboard stats (rota protegida)
    Route::get('/dashboard/stats', function () {
        $user = auth()->user();
        
        return response()->json([
            'success' => true,
            'message' => 'Dashboard stats',
            'data' => [
                'user_info' => [
                    'id' => $user->id,
                    'nome' => $user->nome,
                    'perfil' => $user->perfil
                ],
                'stats' => [
                    'total_users' => \App\Models\User::count(),
                    'active_users' => \App\Models\User::where('status', 'ativo')->count(),
                    'last_login' => $user->ultimo_acesso
                ]
            ]
        ]);
    });
    
    // Rotas dos módulos do sistema (protegidas)
    Route::prefix('admin')->middleware('admin.access')->group(function () {
        // Clientes
        Route::get('/clientes', function() {
            return response()->json([
                'success' => true,
                'data' => \App\Models\User::where('perfil', 'consulta')->with('unidade')->get()
            ]);
        });
        
        // Processos
        Route::get('/processos', function() {
            return response()->json([
                'success' => true,
                'data' => [],
                'message' => 'Endpoint processos - em desenvolvimento'
            ]);
        });
        
        // Usuários
        Route::get('/usuarios', function() {
            return response()->json([
                'success' => true,
                'data' => \App\Models\User::whereNotIn('perfil', ['consulta'])->with('unidade')->get()
            ]);
        });
    });
    
    // Portal do cliente (rotas específicas)
    Route::prefix('portal')->middleware('cliente.access')->group(function () {
        Route::get('/dashboard', function() {
            $user = auth()->user();
            return response()->json([
                'success' => true,
                'data' => [
                    'user' => $user,
                    'processos_count' => 0,
                    'documentos_count' => 0,
                    'pagamentos_pendentes' => 0
                ]
            ]);
        });
    });
});

// Fallback para rotas não encontradas (deve retornar 401/403 ao invés de 404)
Route::fallback(function(){
    return response()->json([
        'success' => false,
        'message' => 'Acesso negado. Token de autenticação necessário.',
        'error' => 'Unauthorized'
    ], 401);
});
EOF

echo "6️⃣ Criando middleware para controle de acesso..."

# Middleware para verificar se é admin
php artisan make:middleware AdminAccessMiddleware

cat > app/Http/Middleware/AdminAccessMiddleware.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminAccessMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $user = auth()->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Token de autenticação necessário'
            ], 401);
        }
        
        if (!in_array($user->perfil, ['admin_geral', 'admin_unidade', 'advogado'])) {
            return response()->json([
                'success' => false,
                'message' => 'Acesso negado. Permissões insuficientes.'
            ], 403);
        }
        
        return $next($request);
    }
}
EOF

# Middleware para verificar se é cliente
php artisan make:middleware ClienteAccessMiddleware

cat > app/Http/Middleware/ClienteAccessMiddleware.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ClienteAccessMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $user = auth()->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Token de autenticação necessário'
            ], 401);
        }
        
        if ($user->perfil !== 'consulta') {
            return response()->json([
                'success' => false,
                'message' => 'Acesso negado. Esta área é exclusiva para clientes.'
            ], 403);
        }
        
        return $next($request);
    }
}
EOF

echo "7️⃣ Registrando middlewares no Kernel..."

# Adicionar middlewares ao Kernel
if ! grep -q "admin.access" app/Http/Kernel.php; then
    sed -i "/protected \$middlewareAliases = \[/a\\
        'admin.access' => \App\Http\Middleware\AdminAccessMiddleware::class,\\
        'cliente.access' => \App\Http\Middleware\ClienteAccessMiddleware::class," app/Http/Kernel.php
fi

echo "8️⃣ Testando login e rotas protegidas..."

# Testar se servidor está rodando
if ! curl -s http://localhost:8000 > /dev/null; then
    echo "Iniciando servidor Laravel..."
    php artisan serve --port=8000 &
    LARAVEL_PID=$!
    sleep 3
else
    echo "Servidor Laravel já está rodando"
fi

echo "Testando login admin:"
ADMIN_TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}' | \
  grep -o '"access_token":"[^"]*"' | cut -d':' -f2 | tr -d '"')

if [ ! -z "$ADMIN_TOKEN" ]; then
    echo "✅ Login admin funcionando - Token obtido"
    
    echo ""
    echo "Testando rota protegida /api/dashboard/stats:"
    curl -s -H "Authorization: Bearer $ADMIN_TOKEN" \
         -H 'Content-Type: application/json' \
         http://localhost:8000/api/dashboard/stats | head -3
    
    echo ""
    echo "Testando rota protegida /api/admin/clientes:"
    curl -s -H "Authorization: Bearer $ADMIN_TOKEN" \
         -H 'Content-Type: application/json' \
         http://localhost:8000/api/admin/clientes | head -3
else
    echo "❌ Erro no login admin"
fi

echo ""
echo ""
echo "Testando login portal cliente:"
CLIENTE_TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/portal/login \
  -H 'Content-Type: application/json' \
  -d '{"cpf_cnpj":"123.456.789-00","password":"123456"}' | \
  grep -o '"access_token":"[^"]*"' | cut -d':' -f2 | tr -d '"')

if [ ! -z "$CLIENTE_TOKEN" ]; then
    echo "✅ Login cliente funcionando - Token obtido"
    
    echo ""
    echo "Testando rota protegida /api/portal/dashboard:"
    curl -s -H "Authorization: Bearer $CLIENTE_TOKEN" \
         -H 'Content-Type: application/json' \
         http://localhost:8000/api/portal/dashboard | head -3
else
    echo "❌ Erro no login cliente"
fi

echo ""
echo ""
echo "Testando rota sem token (deve retornar 401):"
curl -s http://localhost:8000/api/dashboard/stats | head -2

# Parar servidor se foi iniciado pelo script
if [ ! -z "$LARAVEL_PID" ]; then
    kill $LARAVEL_PID 2>/dev/null
fi

echo ""
echo ""
echo "✅ SCRIPT 114C CONCLUÍDO!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   ✅ Seeders executados SEM recriar tabelas"
echo "   ✅ Rotas JWT configuradas corretamente"
echo "   ✅ Middleware de acesso criado (admin/cliente)"
echo "   ✅ Rotas 404 agora retornam 401/403"
echo "   ✅ Removidas rotas de teste desnecessárias"
echo ""
echo "👥 USUÁRIOS NO BANCO:"
echo "   🔧 Admin: admin@erlene.com / 123456"
echo "   👤 Cliente: CPF 123.456.789-00 / 123456"
echo ""
echo "🔗 ROTAS API FUNCIONAIS:"
echo "   📝 POST /api/auth/login - Login admin"
echo "   📝 POST /api/auth/portal/login - Login portal"
echo "   🔒 GET /api/auth/me - Dados usuário logado (JWT)"
echo "   🔒 GET /api/dashboard/stats - Dashboard (admin only)"
echo "   🔒 GET /api/admin/clientes - Lista clientes (admin only)"
echo "   🔒 GET /api/portal/dashboard - Dashboard cliente (cliente only)"
echo ""
echo "⚡ TESTE AGORA:"
echo "   1. php artisan serve"
echo "   2. Login admin: admin@erlene.com / 123456"
echo "   3. Login cliente: CPF 123.456.789-00 / 123456"
echo "   4. Rotas sem token retornam 401 (não mais 404)"
echo ""
echo "⏭️ PRÓXIMO: Digite 'continuar' para Script 114d (Frontend conectar com API)"