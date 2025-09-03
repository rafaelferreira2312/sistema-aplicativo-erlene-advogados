#!/bin/bash

# Script 117 - Corrigir Campo 'name' no Dropdown de Responsáveis
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 117-fix-responsaveis-name-column.sh && ./117-fix-responsaveis-name-column.sh
# EXECUTE NA PASTA: backend/

echo "🔧 Corrigindo campo 'name' no dropdown de responsáveis..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo ""
echo "1. Confirmando estrutura da tabela users..."
php artisan tinker --execute "
echo 'COLUNAS DA TABELA USERS:';
\$columns = \Schema::getColumnListing('users');
foreach(\$columns as \$col) {
    echo '- ' . \$col;
}

echo '';
echo 'VERIFICAÇÃO ESPECÍFICA:';
echo 'Tem coluna name: ' . (in_array('name', \$columns) ? 'SIM' : 'NÃO');
echo 'Tem coluna nome: ' . (in_array('nome', \$columns) ? 'SIM' : 'NÃO');
"

echo ""
echo "2. Corrigindo ClientController para usar 'name' em vez de 'nome'..."

CONTROLLER_PATH="app/Http/Controllers/Api/Admin/Clients/ClientController.php"

# Fazer backup
cp "$CONTROLLER_PATH" "${CONTROLLER_PATH}.backup-$(date +%Y%m%d-%H%M%S)"

echo "Atualizando método responsaveis()..."

# Substituir o método responsaveis completo
python3 -c "
import re

# Ler arquivo do controller
with open('$CONTROLLER_PATH', 'r') as f:
    content = f.read()

# Método responsaveis corrigido com 'name' em vez de 'nome'
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
            // CORRIGIDO: usar 'name' em vez de 'nome'
            \$responsaveis = \App\Models\User::whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado'])
                                           ->where('status', 'ativo')
                                           ->select('id', 'name', 'email', 'oab', 'perfil')
                                           ->orderBy('name')
                                           ->get();
            
            // Mapear 'name' para 'name' (frontend espera 'name')
            \$responsaveis = \$responsaveis->map(function(\$user) {
                return [
                    'id' => \$user->id,
                    'name' => \$user->name,
                    'email' => \$user->email,
                    'oab' => \$user->oab,
                    'perfil' => \$user->perfil
                ];
            });
            
            \Log::info('Responsáveis encontrados: ' . \$responsaveis->count());
            
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

# Encontrar e substituir método responsaveis existente
pattern = r'\/\*\*.*?Obter responsÃ¡veis.*?\*\/.*?public function responsaveis\(\).*?(?=\n\s*\/\*\*|\n\s*public function|\n\s*\}\s*$)'
if re.search(pattern, content, re.DOTALL):
    content = re.sub(pattern, new_method, content, flags=re.DOTALL)
    print('Método responsaveis() atualizado com campo name')
else:
    # Se não encontrar, procurar padrão mais simples
    pattern2 = r'public function responsaveis\(\).*?(?=\n\s*public function|\n\s*\}\s*$)'
    if re.search(pattern2, content, re.DOTALL):
        content = re.sub(pattern2, new_method.replace('    /**', '/**'), content, flags=re.DOTALL)
        print('Método responsaveis() atualizado (padrão simples)')
    else:
        # Adicionar antes do fechamento da classe
        content = re.sub(r'(\n\s*)\}(\s*)$', r'\1' + new_method + r'\n\1}\2', content)
        print('Método responsaveis() adicionado')

# Salvar arquivo
with open('$CONTROLLER_PATH', 'w') as f:
    f.write(content)
"

echo "✅ Controller atualizado"

echo ""
echo "3. Corrigindo UserSeeder para usar 'name'..."

# Corrigir UserSeeder
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
            'name' => 'Dra. Erlene Chaves Silva',  // CORRIGIDO: 'name' em vez de 'nome'
            'password' => Hash::make('123456'),
            'cpf' => '111.111.111-11',
            'telefone' => '(11) 99999-1111', 
            'perfil' => 'admin_geral', 
            'unidade_id' => 1,
            'status' => 'ativo',
            'oab' => 'SP123456'
        ]);
        
        // Advogado
        User::firstOrCreate([
            'email' => 'advogado@erlene.com'
        ], [
            'name' => 'Dr. João Silva Advogado',  // CORRIGIDO: 'name' em vez de 'nome'
            'password' => Hash::make('123456'),
            'cpf' => '222.222.222-22',
            'telefone' => '(11) 88888-8888',
            'perfil' => 'advogado',
            'unidade_id' => 1,
            'status' => 'ativo', 
            'oab' => 'SP654321'
        ]);
        
        // Admin Unidade
        User::firstOrCreate([
            'email' => 'admin.unidade@erlene.com'
        ], [
            'name' => 'Maria Admin Unidade',  // CORRIGIDO: 'name' em vez de 'nome'
            'password' => Hash::make('123456'),
            'cpf' => '333.333.333-33',
            'telefone' => '(21) 77777-7777',
            'perfil' => 'admin_unidade',
            'unidade_id' => 1,
            'status' => 'ativo',
            'oab' => 'RJ789123'
        ]);
        
        echo "UserSeeder executado com sucesso!\n";
    }
}
EOF

echo "✅ UserSeeder corrigido"

echo ""
echo "4. Executando seeder corrigido..."

php artisan db:seed --class=UserSeeder --force

echo ""
echo "5. Verificando usuários criados..."

php artisan tinker --execute "
echo 'RESPONSÁVEIS DISPONÍVEIS (usando name):';
\$responsaveis = \App\Models\User::whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado'])
                                ->where('status', 'ativo')
                                ->select('id', 'name', 'email', 'oab', 'perfil')
                                ->get();

foreach(\$responsaveis as \$resp) {
    echo 'ID: ' . \$resp->id . ' - Name: ' . \$resp->name . ' - Email: ' . \$resp->email . ' - OAB: ' . \$resp->oab . ' - Perfil: ' . \$resp->perfil;
}

echo '';
echo 'Total responsáveis: ' . \$responsaveis->count();

if (\$responsaveis->count() == 0) {
    echo 'AVISO: Nenhum responsável encontrado!';
}
"

echo ""
echo "6. Limpando cache..."

php artisan config:clear
php artisan route:clear  
php artisan cache:clear

echo ""
echo "7. Testando endpoint corrigido..."

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

echo "Fazendo login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:$SERVER_PORT/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "✅ Login OK"
    
    echo "Testando endpoint responsáveis com campo 'name'..."
    RESP_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:$SERVER_PORT/api/admin/clients/responsaveis)
    
    echo "Resultado:"
    echo "$RESP_RESULT" | head -5
    echo ""
    
    if echo $RESP_RESULT | grep -q '"success":true'; then
        echo "✅ Endpoint funcionando!"
        
        # Contar responsáveis retornados
        COUNT=$(echo $RESP_RESULT | grep -o '"name"' | wc -l)
        echo "✅ Retornou $COUNT responsáveis"
        
        # Mostrar primeiro responsável como exemplo
        echo "Exemplo de responsável retornado:"
        echo $RESP_RESULT | grep -o '"data":\[[^]]*\]' | head -1
        
    else
        echo "❌ Endpoint ainda com erro:"
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
echo "=== CORREÇÃO FINALIZADA ==="
echo "🔧 PROBLEMAS CORRIGIDOS:"
echo "✅ Campo 'nome' → 'name' no controller"
echo "✅ Campo 'nome' → 'name' no seeder"
echo "✅ Select corrigido para usar 'name'"
echo "✅ Mapeamento correto para frontend"
echo ""
echo "🎯 TESTE AGORA:"
echo "1. Recarregue o frontend (Ctrl+F5)"
echo "2. Acesse /admin/clientes/novo"  
echo "3. O dropdown 'Responsável' deve carregar as opções"
echo ""
echo "📋 ESTRUTURA ATUAL:"
echo "- Tabela users usa campo 'name' (não 'nome')"
echo "- Controller retorna 'name' para o frontend"
echo "- Usuários responsáveis criados com perfis corretos"
echo ""
echo "🔍 Se ainda não funcionar, verifique:"
echo "- Console do navegador (F12)"
echo "- Network tab para ver requisição"
echo "- Logs: tail -f storage/logs/laravel.log"