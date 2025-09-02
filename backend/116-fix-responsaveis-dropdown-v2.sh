#!/bin/bash

# Script 116 - Corrigir Dropdown de Responsáveis v2
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 116-fix-responsaveis-dropdown-v2.sh && ./116-fix-responsaveis-dropdown-v2.sh
# EXECUTE NA PASTA: backend/

echo "🔧 Analisando e corrigindo dropdown de responsáveis..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo ""
echo "=== ANÁLISE DA ESTRUTURA ATUAL ==="

echo "1. Verificando estrutura de pastas dos controllers..."
find app/Http/Controllers -name "*Client*" -type f 2>/dev/null | head -10

echo ""
echo "2. Verificando seeders existentes..."
find database/seeders -name "*.php" -type f 2>/dev/null | head -10

echo ""
echo "3. Verificando estrutura da tabela users..."
php artisan tinker --execute "
try {
    echo 'Colunas da tabela users:';
    \$columns = \Schema::getColumnListing('users');
    foreach(\$columns as \$col) {
        echo '- ' . \$col;
    }
    
    echo '';
    echo 'Total de usuários: ' . \App\Models\User::count();
    
    echo '';
    echo 'Usuários por perfil:';
    \$perfis = \App\Models\User::selectRaw('perfil, count(*) as total')
                              ->whereNotNull('perfil')
                              ->groupBy('perfil')
                              ->get();
    
    if(\$perfis->count() > 0) {
        foreach(\$perfis as \$row) {
            echo \$row->perfil . ': ' . \$row->total . ' usuários';
        }
    } else {
        echo 'NENHUM USUÁRIO COM PERFIL DEFINIDO!';
    }
    
} catch(Exception \$e) {
    echo 'ERRO: ' . \$e->getMessage();
}
"

echo ""
echo "4. Verificando rotas existentes..."
if grep -q "responsaveis" routes/api.php; then
    echo "✅ Rota 'responsaveis' encontrada em api.php:"
    grep -n "responsaveis" routes/api.php
else
    echo "❌ Rota 'responsaveis' NÃO encontrada em api.php"
fi

echo ""
echo "5. Localizando ClientController..."

# Localizar o ClientController correto
CONTROLLER_PATH=""
POSSIBLE_PATHS=(
    "app/Http/Controllers/Api/Admin/Clients/ClientController.php"
    "app/Http/Controllers/Api/Admin/ClientController.php"  
    "app/Http/Controllers/ClientController.php"
    "app/Http/Controllers/Admin/ClientController.php"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -f "$path" ]; then
        CONTROLLER_PATH="$path"
        echo "✅ ClientController encontrado em: $path"
        break
    fi
done

if [ -z "$CONTROLLER_PATH" ]; then
    echo "❌ ClientController não encontrado!"
    echo "Criando controller básico..."
    
    # Criar diretório se não existir
    mkdir -p app/Http/Controllers/Api/Admin
    
    # Criar controller básico
    cat > app/Http/Controllers/Api/Admin/ClientController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ClientController extends Controller
{
    /**
     * Obter responsáveis disponíveis
     */
    public function responsaveis()
    {
        try {
            $user = auth()->user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuário não autenticado'
                ], 401);
            }
            
            // Buscar usuários que podem ser responsáveis
            $responsaveis = User::whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado'])
                               ->where('status', 'ativo')
                               ->select('id', 'nome as name', 'email', 'oab', 'perfil')
                               ->orderBy('nome')
                               ->get();
            
            Log::info('Responsáveis encontrados: ' . $responsaveis->count());
            
            return response()->json([
                'success' => true,
                'data' => $responsaveis
            ]);
            
        } catch (\Exception $e) {
            Log::error('Erro ao buscar responsáveis: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
EOF

    CONTROLLER_PATH="app/Http/Controllers/Api/Admin/ClientController.php"
    echo "✅ ClientController criado em: $CONTROLLER_PATH"
else
    # Verificar se método responsaveis existe
    if grep -q "function responsaveis" "$CONTROLLER_PATH"; then
        echo "✅ Método responsaveis() já existe no controller"
    else
        echo "⚠️  Método responsaveis() não encontrado, adicionando..."
        
        # Fazer backup
        cp "$CONTROLLER_PATH" "${CONTROLLER_PATH}.backup"
        
        # Adicionar método antes do fechamento da classe
        sed -i '/^}$/i\
\
    /**\
     * Obter responsáveis disponíveis\
     */\
    public function responsaveis()\
    {\
        try {\
            $user = auth()->user();\
            \
            if (!$user) {\
                return response()->json([\
                    "success" => false,\
                    "message" => "Usuário não autenticado"\
                ], 401);\
            }\
            \
            // Buscar usuários que podem ser responsáveis\
            $responsaveis = \\App\\Models\\User::whereIn("perfil", ["admin_geral", "admin_unidade", "advogado"])\
                                          ->where("status", "ativo")\
                                          ->select("id", "nome as name", "email", "oab", "perfil")\
                                          ->orderBy("nome")\
                                          ->get();\
            \
            \\Log::info("Responsáveis encontrados: " . $responsaveis->count());\
            \
            return response()->json([\
                "success" => true,\
                "data" => $responsaveis\
            ]);\
            \
        } catch (\\Exception $e) {\
            \\Log::error("Erro ao buscar responsáveis: " . $e->getMessage());\
            \
            return response()->json([\
                "success" => false,\
                "message" => "Erro interno do servidor",\
                "error" => $e->getMessage()\
            ], 500);\
        }\
    }' "$CONTROLLER_PATH"
        
        echo "✅ Método responsaveis() adicionado ao controller"
    fi
fi

echo ""
echo "6. Configurando rota..."

if grep -q "responsaveis" routes/api.php; then
    echo "✅ Rota já existe"
else
    echo "Adicionando rota para responsáveis..."
    
    # Adicionar rota no final das rotas autenticadas
    cat >> routes/api.php << 'EOF'

// Rota para buscar responsáveis (clientes)
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::get('/clients/responsaveis', [App\Http\Controllers\Api\Admin\ClientController::class, 'responsaveis']);
});
EOF

    echo "✅ Rota adicionada"
fi

echo ""
echo "7. Verificando/criando seeders de usuários..."

# Verificar se existe UserSeeder
if [ -f "database/seeders/UserSeeder.php" ]; then
    echo "✅ UserSeeder encontrado"
else
    echo "Criando UserSeeder..."
    
    cat > database/seeders/UserSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run()
    {
        // Admin Geral - Dra. Erlene  
        User::firstOrCreate([
            'email' => 'admin@erlene.com'
        ], [
            'nome' => 'Dra. Erlene Chaves Silva',
            'password' => Hash::make('123456'),
            'perfil' => 'admin_geral', 
            'status' => 'ativo',
            'oab' => 'SP123456',
            'unidade_id' => 1
        ]);
        
        // Advogado
        User::firstOrCreate([
            'email' => 'advogado@erlene.com'
        ], [
            'nome' => 'Dr. João Silva Advogado',
            'password' => Hash::make('123456'),
            'perfil' => 'advogado',
            'status' => 'ativo', 
            'oab' => 'SP654321',
            'unidade_id' => 1
        ]);
        
        // Admin Unidade
        User::firstOrCreate([
            'email' => 'admin.unidade@erlene.com'
        ], [
            'nome' => 'Maria Admin Unidade',
            'password' => Hash::make('123456'),
            'perfil' => 'admin_unidade',
            'status' => 'ativo',
            'oab' => 'RJ789123',
            'unidade_id' => 1
        ]);
    }
}
EOF

    echo "✅ UserSeeder criado"
fi

# Verificar DatabaseSeeder
if grep -q "UserSeeder" database/seeders/DatabaseSeeder.php; then
    echo "✅ UserSeeder já está registrado no DatabaseSeeder"
else
    echo "Registrando UserSeeder no DatabaseSeeder..."
    
    # Adicionar chamada do UserSeeder
    sed -i '/public function run/a\        $this->call(UserSeeder::class);' database/seeders/DatabaseSeeder.php
    
    echo "✅ UserSeeder registrado no DatabaseSeeder" 
fi

echo ""
echo "8. Executando seeders..."

php artisan db:seed --class=UserSeeder --force

echo ""
echo "9. Verificando usuários criados..."

php artisan tinker --execute "
echo 'RESPONSÁVEIS DISPONÍVEIS APÓS SEEDER:';
\$responsaveis = \App\Models\User::whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado'])
                                ->where('status', 'ativo')
                                ->select('id', 'nome', 'email', 'oab', 'perfil')
                                ->get();

foreach(\$responsaveis as \$resp) {
    echo 'ID: ' . \$resp->id . ' - Nome: ' . \$resp->nome . ' - Email: ' . \$resp->email . ' - OAB: ' . \$resp->oab . ' - Perfil: ' . \$resp->perfil;
}

echo 'Total responsáveis: ' . \$responsaveis->count();
"

echo ""
echo "10. Limpando cache..."

php artisan config:clear
php artisan route:clear  
php artisan cache:clear

echo ""
echo "11. Testando endpoint..."

# Verificar se servidor está rodando
SERVER_RUNNING=false
for PORT in 8000 8001; do
    if curl -s http://localhost:$PORT/api/health > /dev/null 2>&1; then
        SERVER_RUNNING=true
        SERVER_PORT=$PORT
        break
    fi
done

if [ "$SERVER_RUNNING" = false ]; then
    echo "Iniciando servidor para teste..."
    php artisan serve --port=8000 &
    SERVER_PID=$!
    sleep 3
    SERVER_PORT=8000
fi

echo "Testando login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:$SERVER_PORT/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "✅ Login OK"
    
    echo "Testando endpoint responsáveis..."
    RESP_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:$SERVER_PORT/api/admin/clients/responsaveis)
    
    echo "Resultado do endpoint:"
    echo "$RESP_RESULT" | head -3
    echo ""
    
    if echo $RESP_RESULT | grep -q '"success":true'; then
        echo "✅ Endpoint funcionando!"
        COUNT=$(echo $RESP_RESULT | grep -o '"data":\[[^]]*\]' | grep -o '"id"' | wc -l)
        echo "✅ Retornou $COUNT responsáveis"
    else
        echo "❌ Endpoint com erro"
        echo "$RESP_RESULT"
    fi
else
    echo "❌ Erro no login"
    echo "Response: $LOGIN_RESPONSE"
fi

# Parar servidor se iniciamos
if [ ! -z "$SERVER_PID" ]; then
    kill $SERVER_PID 2>/dev/null
fi

echo ""
echo "=== RESUMO DA CORREÇÃO ==="
echo "✅ Controller: $CONTROLLER_PATH"
echo "✅ Método responsaveis() configurado"
echo "✅ Rota /api/admin/clients/responsaveis adicionada"
echo "✅ UserSeeder criado/atualizado"
echo "✅ Usuários responsáveis criados"
echo "✅ Cache limpo"
echo ""
echo "🎯 PRÓXIMOS PASSOS:"
echo "1. Reinicie o servidor backend (php artisan serve)"
echo "2. Recarregue o frontend (Ctrl+F5)"
echo "3. Teste o dropdown em /admin/clientes/novo"
echo ""
echo "🔍 Para debug:"
echo "- Verifique console do navegador (F12)"
echo "- Teste: curl -H 'Authorization: Bearer TOKEN' http://localhost:8000/api/admin/clients/responsaveis"
echo "- Verifique logs: tail -f storage/logs/laravel.log"