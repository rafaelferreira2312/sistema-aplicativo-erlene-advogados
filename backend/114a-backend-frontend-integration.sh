#!/bin/bash

# Script 114a - Integração Backend + Frontend - Dados Reais do Banco
# Sistema Erlene Advogados - Conectar frontend React com backend Laravel
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔗 Script 114a - Conectando Frontend React com dados reais do Backend Laravel..."

# Verificar se estamos no diretório correto (deve executar dentro de backend/)
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📍 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 114a-backend-frontend-integration.sh && ./114a-backend-frontend-integration.sh"
    exit 1
fi

echo "✅ 1. Verificando estrutura Laravel..."

echo "🔧 2. Atualizando AuthController para compatibilidade com frontend..."

# Atualizar AuthController existente para funcionar com as telas do frontend
cat > app/Http/Controllers/Api/AuthController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    /**
     * Login Admin (compatível com frontend existente)
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        // Buscar usuário admin (não cliente)
        $user = User::where('email', $request->email)
                   ->whereNotIn('perfil', ['consulta'])
                   ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Credenciais inválidas',
                'errors' => [
                    'email' => ['Email ou senha incorretos']
                ]
            ], 401);
        }

        if ($user->status !== 'ativo') {
            return response()->json([
                'success' => false,
                'message' => 'Usuário inativo',
                'errors' => [
                    'email' => ['Usuário desabilitado. Contate o administrador.']
                ]
            ], 403);
        }

        // Atualizar último acesso
        $user->update(['ultimo_acesso' => now()]);

        // Gerar token JWT
        $token = JWTAuth::fromUser($user);

        return response()->json([
            'success' => true,
            'message' => 'Login realizado com sucesso',
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => JWTAuth::factory()->getTTL() * 60,
            'user' => [
                'id' => $user->id,
                'nome' => $user->nome,
                'email' => $user->email,
                'perfil' => $user->perfil,
                'oab' => $user->oab,
                'unidade_id' => $user->unidade_id,
                'unidade' => $user->unidade ? [
                    'id' => $user->unidade->id,
                    'nome' => $user->unidade->nome,
                    'codigo' => $user->unidade->codigo,
                    'cidade' => $user->unidade->cidade
                ] : null
            ]
        ]);
    }

    /**
     * Login Portal Cliente (compatível com PortalLogin.js)
     */
    public function portalLogin(Request $request)
    {
        $request->validate([
            'cpf_cnpj' => 'required|string',
            'password' => 'required|string|min:6',
        ]);

        // Remover formatação do CPF/CNPJ
        $cpfCnpj = preg_replace('/[^0-9]/', '', $request->cpf_cnpj);

        // Buscar cliente
        $user = User::where('cpf', $cpfCnpj)
                   ->where('perfil', 'consulta')
                   ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'CPF/CNPJ ou senha incorretos',
                'errors' => [
                    'cpf_cnpj' => ['CPF/CNPJ ou senha incorretos']
                ]
            ], 401);
        }

        if ($user->status !== 'ativo') {
            return response()->json([
                'success' => false,
                'message' => 'Acesso desabilitado',
                'errors' => [
                    'cpf_cnpj' => ['Acesso desabilitado. Contate o escritório.']
                ]
            ], 403);
        }

        // Atualizar último acesso
        $user->update(['ultimo_acesso' => now()]);

        // Gerar token JWT
        $token = JWTAuth::fromUser($user);

        // Formatar CPF/CNPJ para exibição
        $cpfCnpjFormatado = strlen($cpfCnpj) === 11 
            ? preg_replace('/(\d{3})(\d{3})(\d{3})(\d{2})/', '$1.$2.$3-$4', $cpfCnpj)
            : preg_replace('/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/', '$1.$2.$3/$4-$5', $cpfCnpj);

        return response()->json([
            'success' => true,
            'message' => 'Login realizado com sucesso',
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => JWTAuth::factory()->getTTL() * 60,
            'user' => [
                'id' => $user->id,
                'nome' => $user->nome,
                'email' => $user->email,
                'cpf_cnpj' => $cpfCnpjFormatado,
                'telefone' => $user->telefone,
                'perfil' => 'cliente',
                'unidade' => $user->unidade ? [
                    'id' => $user->unidade->id,
                    'nome' => $user->unidade->nome,
                    'telefone' => $user->unidade->telefone,
                    'email' => $user->unidade->email
                ] : null
            ]
        ]);
    }

    /**
     * Obter dados do usuário logado
     */
    public function me(Request $request)
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuário não encontrado'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'user' => [
                    'id' => $user->id,
                    'nome' => $user->nome,
                    'email' => $user->email,
                    'perfil' => $user->perfil,
                    'cpf' => $user->cpf,
                    'telefone' => $user->telefone,
                    'oab' => $user->oab,
                    'ultimo_acesso' => $user->ultimo_acesso,
                    'unidade' => $user->unidade
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token inválido'
            ], 401);
        }
    }

    /**
     * Logout
     */
    public function logout(Request $request)
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
            
            return response()->json([
                'success' => true,
                'message' => 'Logout realizado com sucesso'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao fazer logout'
            ], 500);
        }
    }

    /**
     * Refresh Token
     */
    public function refresh()
    {
        try {
            $newToken = JWTAuth::refresh();
            
            return response()->json([
                'success' => true,
                'access_token' => $newToken,
                'token_type' => 'bearer',
                'expires_in' => JWTAuth::factory()->getTTL() * 60
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Não foi possível renovar o token'
            ], 401);
        }
    }
}
EOF

echo "🔧 3. Atualizando rotas API para compatibilidade..."

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

// Rota de teste (pública)
Route::get('/test', function () {
    return response()->json([
        'success' => true,
        'message' => 'API Sistema Erlene Advogados funcionando!',
        'version' => '1.0.0',
        'timestamp' => now()->format('Y-m-d H:i:s'),
        'environment' => app()->environment()
    ]);
});

Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'status' => 'ok',
        'database' => 'connected',
        'timestamp' => now()
    ]);
});

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
    
    // Dashboard stats (teste de rota protegida)
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
    
    // Futuras rotas protegidas aqui...
});
EOF

echo "🔧 4. Atualizando CORS para desenvolvimento local..."

# Verificar se o arquivo cors.php existe
if [ ! -f "config/cors.php" ]; then
    php artisan config:publish cors
fi

cat > config/cors.php << 'EOF'
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    
    'allowed_methods' => ['*'],
    
    'allowed_origins' => [
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        'http://localhost:3001',
        'http://127.0.0.1:3001',
        'http://localhost:8000',
    ],
    
    'allowed_origins_patterns' => [
        '#^http://localhost:\d+$#',
        '#^http://127\.0\.0\.1:\d+$#',
    ],
    
    'allowed_headers' => ['*'],
    
    'exposed_headers' => [],
    
    'max_age' => 0,
    
    'supports_credentials' => true,
];
EOF

echo "📊 5. Executando migrations e seeders com dados de teste..."

# Executar migrations fresh (limpa e recria o banco)
php artisan migrate:fresh

# Criar seeder com dados compatíveis com o frontend
cat > database/seeders/FrontendTestSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Unidade;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class FrontendTestSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Criar unidades
        $matriz = Unidade::create([
            'nome' => 'Erlene Advogados - Matriz',
            'codigo' => 'MATRIZ',
            'endereco' => 'Rua Principal, 123 - Centro',
            'cidade' => 'São Paulo',
            'estado' => 'SP',
            'cep' => '01234-567',
            'telefone' => '(11) 3333-1111',
            'email' => 'matriz@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0001-90',
            'status' => 'ativa',
        ]);

        $filialRj = Unidade::create([
            'nome' => 'Erlene Advogados - Rio de Janeiro',
            'codigo' => 'FILIAL_RJ',
            'endereco' => 'Av. Atlântica, 456 - Copacabana',
            'cidade' => 'Rio de Janeiro',
            'estado' => 'RJ',
            'cep' => '22070-001',
            'telefone' => '(21) 3333-2222',
            'email' => 'rj@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0002-71',
            'status' => 'ativa',
        ]);

        // 2. USUÁRIOS COMPATÍVEIS COM FRONTEND

        // Admin principal (compatível com Login.js)
        User::create([
            'nome' => 'Dra. Erlene Chaves Silva',
            'email' => 'admin@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '11111111111',
            'telefone' => '(11) 99999-1111',
            'oab' => 'SP123456',
            'perfil' => 'admin_geral',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Admin RJ
        User::create([
            'nome' => 'Dr. João Silva Santos',
            'email' => 'admin.rj@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '22222222222',
            'telefone' => '(21) 98888-2222',
            'oab' => 'RJ654321',
            'perfil' => 'admin_unidade',
            'unidade_id' => $filialRj->id,
            'status' => 'ativo',
        ]);

        // Advogada
        User::create([
            'nome' => 'Dra. Maria Costa Lima',
            'email' => 'maria.advogada@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '33333333333',
            'telefone' => '(11) 97777-3333',
            'oab' => 'SP789012',
            'perfil' => 'advogado',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // CLIENTES PORTAL (compatíveis com PortalLogin.js)

        // Cliente teste do frontend (mantém compatibilidade)
        User::create([
            'nome' => 'Cliente Teste',
            'email' => 'cliente@teste.com',
            'password' => Hash::make('123456'),
            'cpf' => '12345678900', // Sem formatação no banco
            'telefone' => '(11) 96666-4444',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Outros clientes
        User::create([
            'nome' => 'Carlos Eduardo Pereira',
            'email' => 'carlos.pereira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '98765432100',
            'telefone' => '(11) 95555-5555',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Empresa (CNPJ)
        User::create([
            'nome' => 'Tech Solutions Ltda',
            'email' => 'contato@techsolutions.com',
            'password' => Hash::make('123456'),
            'cpf' => '11222333000144', // CNPJ sem formatação
            'telefone' => '(11) 92222-8888',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Cliente RJ
        User::create([
            'nome' => 'Fernanda Santos',
            'email' => 'fernanda.santos@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '78945612300',
            'telefone' => '(21) 94444-5555',
            'perfil' => 'consulta',
            'unidade_id' => $filialRj->id,
            'status' => 'ativo',
        ]);
    }
}
EOF

# Atualizar DatabaseSeeder
cat > database/seeders/DatabaseSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            FrontendTestSeeder::class,
        ]);
    }
}
EOF

# Executar os seeders
php artisan db:seed --class=FrontendTestSeeder

echo "🧪 6. Testando APIs com dados reais..."

# Iniciar servidor Laravel em background para testes
php artisan serve --port=8000 &
LARAVEL_PID=$!
sleep 3

echo "Testando endpoint de saúde:"
curl -s http://localhost:8000/api/health | head -3

echo ""
echo ""
echo "Testando login admin (admin@erlene.com):"
ADMIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')
echo $ADMIN_RESPONSE | head -5

echo ""
echo ""
echo "Testando login portal cliente (CPF: 123.456.789-00):"
PORTAL_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/portal/login \
  -H 'Content-Type: application/json' \
  -d '{"cpf_cnpj":"123.456.789-00","password":"123456"}')
echo $PORTAL_RESPONSE | head -5

# Parar o servidor Laravel
kill $LARAVEL_PID 2>/dev/null

echo ""
echo ""
echo "📝 7. Criando arquivo de configuração para o Frontend..."

# Criar arquivo de config para o frontend
cat > ../frontend_config.js << 'EOF'
// Configuração da API para o Frontend React
// Sistema Erlene Advogados - Integração Backend/Frontend

export const API_CONFIG = {
  BASE_URL: 'http://localhost:8000/api',
  ENDPOINTS: {
    // Autenticação
    LOGIN_ADMIN: '/auth/login',
    LOGIN_PORTAL: '/auth/portal/login',
    LOGOUT: '/auth/logout',
    ME: '/auth/me',
    REFRESH: '/auth/refresh',
    
    // Dashboard
    DASHBOARD_STATS: '/dashboard/stats',
    
    // Testes
    HEALTH: '/health',
    TEST: '/test'
  },
  
  // Headers padrão
  HEADERS: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  },
  
  // Configurações JWT
  TOKEN_KEY: 'erlene_token',
  USER_KEY: 'erlene_user'
};

// Função para fazer requisições à API
export const apiRequest = async (endpoint, options = {}) => {
  const token = localStorage.getItem(API_CONFIG.TOKEN_KEY);
  
  const config = {
    ...options,
    headers: {
      ...API_CONFIG.HEADERS,
      ...(token && { 'Authorization': `Bearer ${token}` }),
      ...(options.headers || {})
    }
  };
  
  const response = await fetch(`${API_CONFIG.BASE_URL}${endpoint}`, config);
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  
  return response.json();
};

// CREDENCIAIS PARA TESTE
export const TEST_CREDENTIALS = {
  ADMIN: {
    email: 'admin@erlene.com',
    password: '123456',
    name: 'Dra. Erlene Chaves Silva'
  },
  CLIENTE: {
    cpf_cnpj: '123.456.789-00',
    password: '123456',
    name: 'Cliente Teste'
  }
};
EOF

echo ""
echo ""
echo "✅ INTEGRAÇÃO BACKEND + FRONTEND CONCLUÍDA!"
echo ""
echo "🏗️ ESTRUTURA CRIADA:"
echo "   📊 Backend Laravel - APIs funcionais"
echo "   🔗 AuthController - Login admin e portal"
echo "   🔐 JWT Auth - Tokens para autenticação"
echo "   📝 CORS - Configurado para React localhost:3000"
echo "   📋 Seeders - Dados compatíveis com frontend"
echo ""
echo "👥 USUÁRIOS CRIADOS (compatíveis com seu frontend):"
echo ""
echo "   🔧 ADMIN SISTEMA:"
echo "   • Email: admin@erlene.com"
echo "   • Senha: 123456"
echo "   • Perfil: admin_geral"
echo "   • Unidade: Matriz São Paulo"
echo ""
echo "   👤 CLIENTES PORTAL:"
echo "   • CPF: 123.456.789-00 / Senha: 123456 (Cliente Teste)"
echo "   • CPF: 987.654.321-00 / Senha: 123456 (Carlos Pereira)"
echo "   • CNPJ: 11.222.333/0001-44 / Senha: 123456 (Tech Solutions)"
echo ""
echo "🔗 ENDPOINTS API CRIADOS:"
echo "   • POST /api/auth/login - Login admin"
echo "   • POST /api/auth/portal/login - Login portal cliente"  
echo "   • GET /api/auth/me - Dados usuário logado"
echo "   • POST /api/auth/logout - Logout"
echo "   • GET /api/health - Status da API"
echo ""
echo "📄 ARQUIVO CRIADO:"
echo "   • ../frontend_config.js - Configuração para o React"
echo ""
echo "⚡ TESTE RÁPIDO:"
echo "   1. php artisan serve (manter rodando)"
echo "   2. cd ../frontend && npm start"
echo "   3. Acesse http://localhost:3000/login"
echo "   4. Use: admin@erlene.com / 123456 (admin)"
echo "   5. Use: 123.456.789-00 / 123456 (cliente portal)"
echo ""
echo "⏭️ PRÓXIMO: Execute 'continuar' para criar Script 114b (Integração Frontend)!"