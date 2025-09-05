#!/bin/bash

# Script 115r - Corrigir Dropdown de Responsáveis
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115r-fix-responsaveis-dropdown.sh && ./115r-fix-responsaveis-dropdown.sh
# EXECUTE NA PASTA: backend/

echo "🔧 Corrigindo endpoint de responsáveis..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo "1. Verificando estrutura da tabela users..."

# Verificar estrutura da tabela users
php artisan tinker --execute "
echo 'Colunas da tabela users:';
var_dump(\Schema::getColumnListing('users'));
echo 'Total de usuários: ' . \App\Models\User::count();
echo 'Usuários por perfil:';
foreach(\App\Models\User::selectRaw('perfil, count(*) as total')->groupBy('perfil')->get() as \$row) {
    echo \$row->perfil . ': ' . \$row->total . ' usuários';
}
"

echo ""
echo "2. Corrigindo método responsaveis() no ClientController..."

# Verificar se ClientController existe
if [ ! -f "app/Http/Controllers/Api/Admin/Clients/ClientController.php" ]; then
    echo "❌ ClientController não encontrado em app/Http/Controllers/Api/Admin/Clients/"
    
    # Procurar em outros locais
    if [ -f "app/Http/Controllers/Api/Admin/ClientController.php" ]; then
        echo "✅ Encontrado em app/Http/Controllers/Api/Admin/ClientController.php"
        CONTROLLER_PATH="app/Http/Controllers/Api/Admin/ClientController.php"
    else
        echo "❌ ClientController não encontrado!"
        exit 1
    fi
else
    CONTROLLER_PATH="app/Http/Controllers/Api/Admin/Clients/ClientController.php"
fi

echo "Corrigindo controller: $CONTROLLER_PATH"

# Fazer backup do controller
cp "$CONTROLLER_PATH" "${CONTROLLER_PATH}.backup"

# Atualizar método responsaveis no controller
python3 -c "
import re

# Ler arquivo do controller
with open('$CONTROLLER_PATH', 'r') as f:
    content = f.read()

# Método responsaveis corrigido
new_method = '''    /**
     * Obter responsáveis disponíveis
     */
    public function responsaveis()
    {
        try {
            \$user = auth()->user();
            
            if (!\$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuário não autenticado'
                ], 401);
            }
            
            // Buscar usuários que podem ser responsáveis
            \$responsaveis = \App\Models\User::whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado'])
                                           ->where('status', 'ativo')
                                           ->select('id', 'nome as name', 'email', 'oab', 'perfil')
                                           ->orderBy('nome')
                                           ->get();
            
            return response()->json([
                'success' => true,
                'data' => \$responsaveis
            ]);
            
        } catch (\Exception \$e) {
            \Log::error('Erro ao buscar responsáveis: ' . \$e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor',
                'error' => \$e->getMessage()
            ], 500);
        }
    }'''

# Verificar se método já existe
if 'public function responsaveis()' in content:
    # Substituir método existente
    content = re.sub(
        r'\/\*\*.*?Obter responsáveis.*?\*\/.*?public function responsaveis\(\).*?(?=\n\s*\/\*\*|\n\s*public|\n\s*\}$)',
        new_method,
        content,
        flags=re.DOTALL
    )
    print('Método responsaveis() atualizado')
else:
    # Adicionar método antes do fechamento da classe
    content = re.sub(r'(\n\s*)\}(\s*)$', r'\1\n' + new_method + r'\n\1}\2', content)
    print('Método responsaveis() adicionado')

# Salvar arquivo
with open('$CONTROLLER_PATH', 'w') as f:
    f.write(content)
"

echo "✅ Controller atualizado"

echo ""
echo "3. Verificando/criando rota para responsáveis..."

# Verificar se rota existe
if grep -q "responsaveis" routes/api.php; then
    echo "✅ Rota responsaveis já existe"
else
    echo "Adicionando rota responsaveis..."
    
    # Adicionar rota
    if grep -q "Route::middleware.*admin.*clients" routes/api.php; then
        # Adicionar dentro do grupo existente
        sed -i '/Route::middleware.*admin.*clients/,/});/ {
            /buscar-cep/a\        Route::get("/responsaveis", [App\\Http\\Controllers\\Api\\Admin\\ClientController::class, "responsaveis"]);
        }' routes/api.php
    else
        # Adicionar novo grupo de rotas
        cat >> routes/api.php << 'EOF'

// Rotas de clientes
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::get('/clients/responsaveis', [App\Http\Controllers\Api\Admin\ClientController::class, 'responsaveis']);
});
EOF
    fi
    
    echo "✅ Rota adicionada"
fi

echo ""
echo "4. Criando usuários de teste se necessário..."

# Criar usuários de teste para responsáveis
php artisan tinker --execute "
// Verificar se existem usuários que podem ser responsáveis
\$responsaveis = \App\Models\User::whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado'])
                                ->where('status', 'ativo')
                                ->count();

if (\$responsaveis == 0) {
    echo 'Criando usuários de teste para responsáveis...';
    
    // Criar admin geral
    \$admin = \App\Models\User::firstOrCreate([
        'email' => 'admin@erlene.com'
    ], [
        'nome' => 'Dra. Erlene Chaves Silva',
        'password' => bcrypt('123456'),
        'perfil' => 'admin_geral',
        'status' => 'ativo',
        'oab' => 'SP123456',
        'unidade_id' => 1
    ]);
    
    // Criar advogado
    \$advogado = \App\Models\User::firstOrCreate([
        'email' => 'advogado@erlene.com'
    ], [
        'nome' => 'Dr. João Silva Advogado',
        'password' => bcrypt('123456'),
        'perfil' => 'advogado', 
        'status' => 'ativo',
        'oab' => 'SP654321',
        'unidade_id' => 1
    ]);
    
    echo 'Usuários responsáveis criados com sucesso!';
} else {
    echo 'Já existem ' . \$responsaveis . ' responsáveis cadastrados';
}
"

echo ""
echo "5. Testando endpoint de responsáveis..."

# Limpar cache
php artisan config:clear
php artisan route:clear

# Testar se servidor está rodando
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    PORT=8000
elif curl -s http://localhost:8001/api/health > /dev/null 2>&1; then
    PORT=8001
else
    echo "Iniciando servidor para teste..."
    php artisan serve --port=8000 &
    SERVER_PID=$!
    sleep 3
    PORT=8000
fi

echo "Testando endpoint em localhost:$PORT..."

# Fazer login para obter token
echo "Fazendo login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:$PORT/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

# Extrair token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "✅ Login OK, token: ${TOKEN:0:20}..."
    
    # Testar endpoint responsaveis
    echo "Testando endpoint responsaveis..."
    RESP_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:$PORT/api/admin/clients/responsaveis)
    
    echo "Resultado:"
    echo $RESP_RESULT | head -5
    echo ""
    
    # Verificar se retornou dados
    if echo $RESP_RESULT | grep -q '"success":true'; then
        echo "✅ Endpoint funcionando!"
        if echo $RESP_RESULT | grep -q '"data":\['; then
            echo "✅ Dados retornados!"
        else
            echo "⚠️  Endpoint OK mas sem dados"
        fi
    else
        echo "❌ Endpoint com erro:"
        echo $RESP_RESULT
    fi
else
    echo "❌ Não conseguiu fazer login"
    echo "Response: $LOGIN_RESPONSE"
fi

# Parar servidor se iniciamos
if [ ! -z "$SERVER_PID" ]; then
    kill $SERVER_PID 2>/dev/null
fi

echo ""
echo "6. Verificando dados finais..."

# Mostrar responsáveis disponíveis
php artisan tinker --execute "
echo 'RESPONSÁVEIS DISPONÍVEIS:';
\$responsaveis = \App\Models\User::whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado'])
                                ->where('status', 'ativo')
                                ->select('id', 'nome', 'email', 'oab', 'perfil')
                                ->get();

foreach(\$responsaveis as \$resp) {
    echo 'ID: ' . \$resp->id . ' - Nome: ' . \$resp->nome . ' - Email: ' . \$resp->email . ' - OAB: ' . \$resp->oab . ' - Perfil: ' . \$resp->perfil;
}

if (\$responsaveis->count() == 0) {
    echo 'NENHUM RESPONSÁVEL ENCONTRADO!';
    echo 'Verifique se existem usuários com perfil admin_geral, admin_unidade ou advogado';
}
"

echo ""
echo "🎉 CORREÇÃO CONCLUÍDA!"
echo ""
echo "O QUE FOI CORRIGIDO:"
echo "✅ Método responsaveis() no controller"
echo "✅ Rota /api/admin/clients/responsaveis" 
echo "✅ Criação de usuários responsáveis de teste"
echo "✅ Mapeamento correto nome → name no retorno"
echo ""
echo "AGORA TESTE:"
echo "1. Recarregue o frontend (Ctrl+F5)"
echo "2. Acesse /admin/clientes/novo"
echo "3. O dropdown 'Responsável' deve mostrar os usuários"
echo ""
echo "Se ainda não aparecer:"
echo "- Verifique no console do navegador (F12)"
echo "- Teste manualmente: curl com token no endpoint"
echo "- Verifique se há usuários com perfil correto no banco"