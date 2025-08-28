#!/bin/bash

# Script 113a-migrations - Corrigir migrations duplicadas
# Sistema Erlene Advogados - Fix migrations
# Data: $(date +%Y-%m-%d)

echo "Corrigindo migrations duplicadas..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "Erro: Execute no diretório backend/"
    exit 1
fi

echo "1. Limpando banco de dados..."
php artisan migrate:reset 2>/dev/null || true

echo "2. Removendo migrations duplicadas..."

# Listar migrations
echo "Migrations encontradas:"
ls -la database/migrations/

# Remover migration duplicada de users do sistema original
if [ -f "database/migrations/2024_01_01_000002_create_users_table.php" ]; then
    echo "Removendo migration duplicada de users..."
    rm database/migrations/2024_01_01_000002_create_users_table.php
fi

# Verificar outras migrations duplicadas
find database/migrations/ -name "*users*" -type f

echo "3. Usando apenas migration padrão do Laravel..."

# Verificar se existe a migration padrão do Laravel
if [ -f "database/migrations/0001_01_01_000000_create_users_table.php" ]; then
    echo "Migration padrão do Laravel encontrada"
else
    echo "Criando migration padrão de users..."
    php artisan make:migration create_users_table_default
fi

echo "4. Executando script de autenticação..."

# Re-executar o script 113a para criar APIs de auth
if [ -f "113a-auth-apis.sh" ]; then
    ./113a-auth-apis.sh
else
    echo "Criando AuthController e estruturas de autenticação..."
    
    # Criar AuthController novamente
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
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Credenciais inválidas'
            ], 401);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role ?? 'admin'
            ]
        ]);
    }

    public function portalLogin(Request $request)
    {
        $request->validate([
            'cpf_cnpj' => 'required',
            'password' => 'required',
        ]);

        $user = User::where('cpf_cnpj', $request->cpf_cnpj)
                   ->where('role', 'cliente')
                   ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'CPF/CNPJ ou senha incorretos'
            ], 401);
        }

        $token = $user->createToken('portal-token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'nome' => $user->name,
                'email' => $user->email,
                'cpf_cnpj' => $user->cpf_cnpj,
                'role' => 'cliente'
            ]
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'user' => $request->user()
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout realizado com sucesso'
        ]);
    }
}
EOF

    # Atualizar rotas API
    cat > routes/api.php << 'EOF'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

// Rotas de autenticação (públicas)
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/portal/login', [AuthController::class, 'portalLogin']);

// Rotas protegidas
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
});

// Rota de teste
Route::get('/test', function () {
    return response()->json([
        'message' => 'API funcionando!',
        'timestamp' => now()
    ]);
});
EOF

fi

echo "5. Executando migrations limpo..."

php artisan migrate:fresh

echo "6. Criando seeders de usuários..."

cat > database/seeders/UserSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Admin de teste
        User::create([
            'name' => 'Administrador Sistema',
            'email' => 'admin@erlene.com',
            'password' => Hash::make('123456'),
            'cpf_cnpj' => null,
            'role' => 'admin'
        ]);

        // Clientes de teste
        User::create([
            'name' => 'Maria Silva Santos',
            'email' => 'maria@teste.com',
            'cpf_cnpj' => '123.456.789-00',
            'password' => Hash::make('123456'),
            'role' => 'cliente'
        ]);

        User::create([
            'name' => 'João Costa Lima', 
            'email' => 'joao@teste.com',
            'cpf_cnpj' => '987.654.321-00',
            'password' => Hash::make('123456'),
            'role' => 'cliente'
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
            UserSeeder::class,
        ]);
    }
}
EOF

echo "7. Executando seeders..."
php artisan db:seed

echo "8. Verificando usuários criados..."
mysql -u root -p12345678 erlene_advogados -e "SELECT id, name, email, role FROM users;"

echo "9. Testando API..."
php artisan serve &
SERVER_PID=$!
sleep 3

echo "Testando login admin..."
curl -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}' | head -3

kill $SERVER_PID 2>/dev/null

echo ""
echo "MIGRATIONS CORRIGIDAS!"
echo ""
echo "USUÁRIOS CRIADOS:"
echo "• Admin: admin@erlene.com / 123456"
echo "• Cliente: CPF 123.456.789-00 / 123456"
echo "• Cliente: CPF 987.654.321-00 / 123456"
echo ""
echo "PRÓXIMO PASSO:"
echo "php artisan serve"
echo "curl -X POST http://localhost:8000/api/auth/login -H 'Content-Type: application/json' -d '{\"email\":\"admin@erlene.com\",\"password\":\"123456\"}'"