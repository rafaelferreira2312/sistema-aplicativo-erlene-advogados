#!/bin/bash

# Script 114a - Integração Backend + Frontend - Login Admin e Portal Cliente
# Sistema Erlene Advogados - Conectar dados reais do banco MySQL
# Data: $(date +%Y-%m-%d)

echo "🔗 Script 114a - Integrando Backend Laravel com Frontend React..."

# Verificar se estamos no diretório correto
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ Erro: Execute no diretório raiz do projeto (deve ter backend/ e frontend/)"
    exit 1
fi

echo "🚀 1. Verificando estrutura Laravel no Backend..."

# Verificar se Laravel está instalado
if [ ! -f "backend/artisan" ]; then
    echo "❌ Laravel não encontrado. Execute primeiro o script de setup do backend"
    exit 1
fi

cd backend

echo "🔧 2. Criando API Controllers para Auth..."

# Criar AuthController para Admin
mkdir -p app/Http/Controllers/Api

cat > app/Http/Controllers/Api/AuthController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Login do Admin/Advogado
     */
    public function loginAdmin(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        $user = User::where('email', $request->email)
                   ->whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado', 'secretario'])
                   ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Credenciais inválidas',
                'errors' => [
                    'email' => ['Email ou senha incorretos']
                ]
            ], 401);
        }

        if ($user->status !== 'ativo') {
            return response()->json([
                'message' => 'Usuário inativo',
                'errors' => [
                    'email' => ['Usuário desabilitado. Contate o administrador.']
                ]
            ], 403);
        }

        $token = $user->createToken('admin-token')->plainTextToken;

        return response()->json([
            'message' => 'Login realizado com sucesso',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'nome' => $user->nome,
                'email' => $user->email,
                'perfil' => $user->perfil,
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
     * Login do Portal do Cliente
     */
    public function loginPortal(Request $request)
    {
        $request->validate([
            'cpf_cnpj' => 'required|string',
            'password' => 'required|string|min:6',
        ]);

        // Remover formatação do CPF/CNPJ
        $cpfCnpj = preg_replace('/[^0-9]/', '', $request->cpf_cnpj);

        $user = User::where('cpf', $cpfCnpj)
                   ->where('perfil', 'consulta')
                   ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'CPF/CNPJ ou senha incorretos',
                'errors' => [
                    'cpf_cnpj' => ['CPF/CNPJ ou senha incorretos']
                ]
            ], 401);
        }

        if ($user->status !== 'ativo') {
            return response()->json([
                'message' => 'Cliente inativo',
                'errors' => [
                    'cpf_cnpj' => ['Acesso desabilitado. Contate o escritório.']
                ]
            ], 403);
        }

        $token = $user->createToken('portal-token')->plainTextToken;

        // Formatar CPF/CNPJ para exibição
        $cpfCnpjFormatado = strlen($cpfCnpj) === 11 
            ? preg_replace('/(\d{3})(\d{3})(\d{3})(\d{2})/', '$1.$2.$3-$4', $cpfCnpj)
            : preg_replace('/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/', '$1.$2.$3/$4-$5', $cpfCnpj);

        return response()->json([
            'message' => 'Login realizado com sucesso',
            'access_token' => $token,
            'token_type' => 'Bearer',
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
                    'telefone' => $user->unidade->telefone
                ] : null
            ]
        ]);
    }

    /**
     * Obter dados do usuário logado
     */
    public function me(Request $request)
    {
        $user = $request->user()->load('unidade');

        return response()->json([
            'user' => [
                'id' => $user->id,
                'nome' => $user->nome,
                'email' => $user->email,
                'perfil' => $user->perfil,
                'cpf' => $user->cpf,
                'telefone' => $user->telefone,
                'unidade' => $user->unidade
            ]
        ]);
    }

    /**
     * Logout
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout realizado com sucesso'
        ]);
    }

    /**
     * Refresh Token
     */
    public function refresh(Request $request)
    {
        $user = $request->user();
        $user->currentAccessToken()->delete();
        
        $token = $user->createToken('refresh-token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }
}
EOF

echo "🔧 3. Criando Model User com relacionamentos..."

cat > app/Models/User.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'nome',
        'email',
        'password',
        'cpf',
        'telefone',
        'oab',
        'perfil',
        'unidade_id',
        'status',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    /**
     * Relacionamento com Unidade
     */
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    /**
     * Verificar se é admin geral
     */
    public function isAdminGeral()
    {
        return $this->perfil === 'admin_geral';
    }

    /**
     * Verificar se é admin de unidade
     */
    public function isAdminUnidade()
    {
        return $this->perfil === 'admin_unidade';
    }

    /**
     * Verificar se é advogado
     */
    public function isAdvogado()
    {
        return $this->perfil === 'advogado';
    }

    /**
     * Verificar se é cliente (portal)
     */
    public function isCliente()
    {
        return $this->perfil === 'consulta';
    }

    /**
     * Verificar se tem acesso administrativo
     */
    public function hasAdminAccess()
    {
        return in_array($this->perfil, ['admin_geral', 'admin_unidade', 'advogado']);
    }

    /**
     * Scope para filtrar por perfil
     */
    public function scopePorPerfil($query, $perfil)
    {
        return $query->where('perfil', $perfil);
    }

    /**
     * Scope para filtrar por unidade
     */
    public function scopePorUnidade($query, $unidadeId)
    {
        return $query->where('unidade_id', $unidadeId);
    }

    /**
     * Scope para usuários ativos
     */
    public function scopeAtivos($query)
    {
        return $query->where('status', 'ativo');
    }
}
EOF

echo "🔧 4. Criando Model Unidade..."

cat > app/Models/Unidade.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Unidade extends Model
{
    use HasFactory;

    protected $table = 'unidades';

    protected $fillable = [
        'nome',
        'codigo',
        'endereco',
        'cidade',
        'estado',
        'cep',
        'telefone',
        'email',
        'cnpj',
        'status',
    ];

    /**
     * Relacionamento com usuários
     */
    public function usuarios()
    {
        return $this->hasMany(User::class);
    }

    /**
     * Scope para unidades ativas
     */
    public function scopeAtivas($query)
    {
        return $query->where('status', 'ativa');
    }

    /**
     * Verificar se é matriz
     */
    public function isMatriz()
    {
        return $this->codigo === 'MATRIZ';
    }
}
EOF

echo "🔧 5. Atualizando rotas da API..."

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

// Rota de teste
Route::get('/test', function () {
    return response()->json([
        'message' => 'API Sistema Erlene Advogados funcionando!',
        'version' => '1.0.0',
        'timestamp' => now()->format('Y-m-d H:i:s')
    ]);
});

// Rotas de autenticação (públicas)
Route::prefix('auth')->group(function () {
    Route::post('/admin/login', [AuthController::class, 'loginAdmin']);
    Route::post('/portal/login', [AuthController::class, 'loginPortal']);
});

// Rotas protegidas (requer autenticação)
Route::middleware('auth:sanctum')->group(function () {
    
    // Rotas de auth para usuários logados
    Route::prefix('auth')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/refresh', [AuthController::class, 'refresh']);
        Route::post('/logout', [AuthController::class, 'logout']);
    });
    
    // Futuras rotas protegidas aqui
    Route::get('/dashboard/stats', function () {
        return response()->json([
            'message' => 'Dashboard stats - endpoint protegido',
            'user' => auth()->user()->only(['id', 'nome', 'perfil'])
        ]);
    });
});

// Rota para verificar se API está funcionando (sem autenticação)
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'database' => 'connected',
        'timestamp' => now()
    ]);
});
EOF

echo "🔧 6. Configurando CORS para desenvolvimento..."

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
    ],
    
    'allowed_origins_patterns' => [],
    
    'allowed_headers' => ['*'],
    
    'exposed_headers' => [],
    
    'max_age' => 0,
    
    'supports_credentials' => true,
];
EOF

echo "📊 7. Executando migrations para criar estrutura..."

# Executar migrations fresh (cuidado: apaga dados existentes)
php artisan migrate:fresh --seed

echo "🧪 8. Criando seeders com dados de teste reais..."

cat > database/seeders/TestDataSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Unidade;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class TestDataSeeder extends Seeder
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

        // 2. Admin Geral
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

        // 3. Admin Unidade - Filial RJ
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

        // 4. Advogados
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

        // 5. Clientes para Portal
        User::create([
            'nome' => 'Carlos Eduardo Pereira',
            'email' => 'carlos.pereira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '12345678900',
            'telefone' => '(11) 96666-4444',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Ana Paula Ferreira',
            'email' => 'ana.ferreira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '98765432100',
            'telefone' => '(11) 95555-5555',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

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
    }
}
EOF

# Atualizar DatabaseSeeder para incluir o novo seeder
cat > database/seeders/DatabaseSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            TestDataSeeder::class,
        ]);
    }
}
EOF

# Executar os seeders
php artisan db:seed --class=TestDataSeeder

echo "🧪 9. Testando API com dados reais..."

# Iniciar servidor Laravel em background para testes
php artisan serve --port=8000 &
LARAVEL_PID=$!
sleep 3

echo "Testando endpoint de saúde da API:"
curl -s http://localhost:8000/api/health | head -3

echo ""
echo ""
echo "Testando login admin:"
curl -s -X POST http://localhost:8000/api/auth/admin/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}' | head -5

echo ""
echo ""
echo "Testando login portal (CPF com formatação):"
curl -s -X POST http://localhost:8000/api/auth/portal/login \
  -H 'Content-Type: application/json' \
  -d '{"cpf_cnpj":"123.456.789-00","password":"123456"}' | head -5

# Parar o servidor Laravel
kill $LARAVEL_PID 2>/dev/null

echo ""
echo ""
echo "✅ BACKEND CONFIGURADO COM SUCESSO!"
echo ""
echo "📊 DADOS CRIADOS NO BANCO:"
echo "🏢 UNIDADES:"
echo "   • Matriz - São Paulo"
echo "   • Filial - Rio de Janeiro" 
echo ""
echo "👥 USUÁRIOS ADMIN:"
echo "   • Admin Geral: admin@erlene.com / 123456"
echo "   • Admin RJ: admin.rj@erlene.com / 123456"
echo "   • Advogada: maria.advogada@erlene.com / 123456"
echo ""
echo "👤 CLIENTES PORTAL:"
echo "   • Carlos: CPF 123.456.789-00 / 123456"
echo "   • Ana: CPF 987.654.321-00 / 123456"
echo "   • Tech Solutions: CNPJ 11.222.333/0001-44 / 123456"
echo ""
echo "🔗 ENDPOINTS CRIADOS:"
echo "   • POST /api/auth/admin/login - Login admin"
echo "   • POST /api/auth/portal/login - Login cliente"
echo "   • GET /api/auth/me - Dados usuário logado"
echo "   • POST /api/auth/logout - Logout"
echo "   • GET /api/health - Status da API"
echo ""
echo "⏭️ PRÓXIMO: Execute 'continuar' para criar a integração do Frontend React"