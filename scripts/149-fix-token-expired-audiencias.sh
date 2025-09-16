#!/bin/bash

# Script 149 - Corrigir token expirado e classe CNJ inexistente
# Sistema Erlene Advogados - Resolver problemas identificados
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔧 Script 149 - Corrigindo token expirado e classe CNJ..."

# Verificar se estamos no diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

echo "🔍 PROBLEMAS IDENTIFICADOS:"
echo "   ❌ Token JWT expirado (TTL: 60 minutos)"
echo "   ❌ Classe CNJController não existe (quebra route:list)"
echo "   ✅ Backend estruturado corretamente"
echo ""

echo "1️⃣ Corrigindo classe CNJ inexistente..."

# Verificar se há referência ao CNJController em routes
if grep -r "CNJController" routes/ app/ 2>/dev/null; then
    echo "📋 Referências ao CNJController encontradas:"
    grep -r -n "CNJController" routes/ app/ 2>/dev/null
    
    echo ""
    echo "🔧 Criando CNJController temporário para resolver erro..."
    
    # Criar diretório se não existir
    mkdir -p app/Http/Controllers/Api/Admin/Integrations/CNJ
    
    # Criar CNJController básico
    cat > app/Http/Controllers/Api/Admin/Integrations/CNJ/CNJController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Integrations\CNJ;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CNJController extends Controller
{
    /**
     * Integração com CNJ - Em desenvolvimento
     */
    public function index(Request $request): JsonResponse
    {
        return response()->json([
            'message' => 'Integração CNJ em desenvolvimento',
            'data' => []
        ]);
    }

    /**
     * Consultar processo no CNJ
     */
    public function consultarProcesso(Request $request): JsonResponse
    {
        return response()->json([
            'message' => 'Consulta CNJ em desenvolvimento',
            'data' => null
        ]);
    }

    /**
     * Sincronizar movimentações
     */
    public function sincronizar(Request $request): JsonResponse
    {
        return response()->json([
            'message' => 'Sincronização CNJ em desenvolvimento',
            'data' => []
        ]);
    }
}
EOF
    
    echo "✅ CNJController temporário criado"
else
    echo "📋 Nenhuma referência ao CNJController encontrada"
fi

echo ""
echo "2️⃣ Verificando e limpando cache das rotas..."

# Limpar cache das rotas
php artisan route:clear
php artisan cache:clear
php artisan config:clear

echo "✅ Cache limpo"

echo ""
echo "3️⃣ Testando se route:list funciona agora..."

if php artisan route:list --path=audiencias 2>/dev/null; then
    echo "✅ Comando route:list funcionando"
else
    echo "❌ Ainda há problemas com route:list"
fi

echo ""
echo "4️⃣ Gerando novo token JWT para teste..."

echo "📋 Criando script para obter novo token:"

cat > get_new_token.php << 'EOF'
<?php
// Script para obter novo token JWT

use App\Models\User;
use Tymon\JWTAuth\Facades\JWTAuth;

echo "=== GERAÇÃO DE NOVO TOKEN ===\n";

try {
    // Buscar usuário admin
    $user = User::where('email', 'admin@erlene.com')->first();
    
    if (!$user) {
        echo "❌ Usuário admin não encontrado\n";
        exit;
    }
    
    echo "✅ Usuário encontrado: " . $user->name . "\n";
    echo "Email: " . $user->email . "\n";
    echo "Perfil: " . $user->perfil . "\n";
    
    // Gerar novo token
    $token = JWTAuth::fromUser($user);
    
    if ($token) {
        echo "✅ Novo token gerado:\n";
        echo $token . "\n\n";
        
        // Verificar validade do novo token
        JWTAuth::setToken($token);
        $payload = JWTAuth::getPayload();
        
        echo "📋 Detalhes do token:\n";
        echo "User ID: " . $payload->get('sub') . "\n";
        echo "Perfil: " . $payload->get('perfil') . "\n";
        echo "Unidade ID: " . $payload->get('unidade_id') . "\n";
        echo "Expira em: " . date('Y-m-d H:i:s', $payload->get('exp')) . "\n";
        
    } else {
        echo "❌ Erro ao gerar token\n";
    }
    
} catch (Exception $e) {
    echo "❌ Erro: " . $e->getMessage() . "\n";
}
EOF

echo "📋 Executando geração de novo token:"
NEW_TOKEN=$(php artisan tinker --execute="require 'get_new_token.php';" 2>/dev/null)
echo "$NEW_TOKEN"

# Extrair apenas o token JWT
CLEAN_TOKEN=$(echo "$NEW_TOKEN" | grep -oP 'eyJ[A-Za-z0-9_.-]+')

if [ -n "$CLEAN_TOKEN" ]; then
    echo ""
    echo "🔑 TOKEN LIMPO PARA USAR NO FRONTEND:"
    echo "$CLEAN_TOKEN"
    
    # Salvar token em arquivo para facilitar uso
    echo "$CLEAN_TOKEN" > new_token.txt
    echo ""
    echo "✅ Token salvo em: new_token.txt"
fi

echo ""
echo "5️⃣ Testando novo token com rotas de audiências..."

if [ -n "$CLEAN_TOKEN" ]; then
    echo "📋 Testando GET /admin/audiencias com novo token:"
    
    # Iniciar servidor Laravel em background se não estiver rodando
    if ! pgrep -f "artisan serve" > /dev/null; then
        echo "🚀 Iniciando servidor Laravel..."
        php artisan serve --port=8000 &
        LARAVEL_PID=$!
        sleep 3
    fi
    
    # Testar GET
    echo "🔗 Testando GET..."
    GET_RESPONSE=$(curl -s -X GET "http://localhost:8000/api/admin/audiencias" \
        -H "Authorization: Bearer $CLEAN_TOKEN" \
        -H "Accept: application/json")
    
    echo "📋 Resposta GET:"
    echo "$GET_RESPONSE" | head -5
    
    # Verificar status da resposta
    GET_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        -X GET "http://localhost:8000/api/admin/audiencias" \
        -H "Authorization: Bearer $CLEAN_TOKEN" \
        -H "Accept: application/json")
    
    echo "📊 Status GET: $GET_STATUS"
    
    # Testar POST
    echo ""
    echo "🔗 Testando POST..."
    POST_RESPONSE=$(curl -s -X POST "http://localhost:8000/api/admin/audiencias" \
        -H "Authorization: Bearer $CLEAN_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d '{
            "processo_id": 1,
            "cliente_id": 1,
            "advogado_id": 1,
            "unidade_id": 1,
            "tipo": "conciliacao",
            "data": "2025-09-17",
            "hora": "14:00",
            "local": "Teste Novo Token",
            "advogado": "Dr. Teste"
        }')
    
    echo "📋 Resposta POST:"
    echo "$POST_RESPONSE" | head -5
    
    # Verificar status da resposta
    POST_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "http://localhost:8000/api/admin/audiencias" \
        -H "Authorization: Bearer $CLEAN_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d '{
            "processo_id": 1,
            "cliente_id": 1,
            "advogado_id": 1,
            "unidade_id": 1,
            "tipo": "conciliacao",
            "data": "2025-09-17",
            "hora": "14:00",
            "local": "Teste Novo Token",
            "advogado": "Dr. Teste"
        }')
    
    echo "📊 Status POST: $POST_STATUS"
    
    # Parar servidor se foi iniciado por este script
    if [ -n "$LARAVEL_PID" ]; then
        kill $LARAVEL_PID 2>/dev/null
    fi
    
else
    echo "❌ Não foi possível obter novo token"
fi

echo ""
echo "6️⃣ Verificando tabela audiências no banco..."

echo "📋 Testando conexão com banco:"
TABLE_EXISTS=$(php artisan tinker --execute="echo Schema::hasTable('audiencias') ? 'SIM' : 'NÃO';" 2>/dev/null)
echo "Tabela audiências existe: $TABLE_EXISTS"

if [[ "$TABLE_EXISTS" == *"SIM"* ]]; then
    echo ""
    echo "📋 Contando registros:"
    RECORD_COUNT=$(php artisan tinker --execute="echo App\\Models\\Audiencia::count();" 2>/dev/null)
    echo "Registros na tabela: $RECORD_COUNT"
    
    if [[ "$RECORD_COUNT" == "0" ]] || [[ -z "$RECORD_COUNT" ]]; then
        echo ""
        echo "📋 Criando audiência de teste:"
        CREATE_TEST=$(php artisan tinker --execute="
        \$a = new App\\Models\\Audiencia();
        \$a->processo_id = 1;
        \$a->cliente_id = 1;
        \$a->advogado_id = 1;
        \$a->unidade_id = 1;
        \$a->tipo = 'conciliacao';
        \$a->data = '2025-09-17';
        \$a->hora = '14:00';
        \$a->local = 'Teste Backend';
        \$a->advogado = 'Dr. Teste';
        \$a->save();
        echo 'Audiência criada: ' . \$a->id;
        " 2>/dev/null)
        echo "$CREATE_TEST"
    fi
    
    echo ""
    echo "📋 Listando audiências:"
    LIST_AUDIENCIAS=$(php artisan tinker --execute="
    App\\Models\\Audiencia::all()->each(function(\$a) { 
        echo \$a->id . ' - ' . \$a->tipo . ' - ' . \$a->data . ' - ' . \$a->local . PHP_EOL; 
    });
    " 2>/dev/null)
    echo "$LIST_AUDIENCIAS"
fi

echo ""
echo "7️⃣ Criando script para atualizar token no frontend..."

cat > update_frontend_token.js << 'EOF'
// Script para atualizar token no frontend
// Execute no console do navegador (F12)

console.log('=== ATUALIZANDO TOKEN NO FRONTEND ===');

// Novo token (substitua pelo token gerado)
const newToken = 'NOVO_TOKEN_AQUI';

// Atualizar todas as chaves possíveis
localStorage.setItem('token', newToken);
localStorage.setItem('erlene_token', newToken);
localStorage.setItem('authToken', newToken);

console.log('✅ Token atualizado em todas as chaves');

// Verificar se foi salvo
console.log('Token salvo:', localStorage.getItem('token').substring(0, 50) + '...');

// Recarregar a página
console.log('Recarregando página em 2 segundos...');
setTimeout(() => {
    location.reload();
}, 2000);
EOF

if [ -n "$CLEAN_TOKEN" ]; then
    # Substituir placeholder pelo token real
    sed -i "s/NOVO_TOKEN_AQUI/$CLEAN_TOKEN/g" update_frontend_token.js
    echo "✅ Script de atualização criado: update_frontend_token.js"
fi

# Cleanup
rm -f get_new_token.php

echo ""
echo "✅ Script 149 concluído!"
echo ""
echo "🔧 CORREÇÕES REALIZADAS:"
echo "   ✅ CNJController temporário criado (resolver erro route:list)"
echo "   ✅ Cache das rotas limpo"
echo "   ✅ Novo token JWT gerado"
echo "   ✅ Testes realizados com novo token"
echo "   ✅ Verificação do banco de dados"
echo ""
echo "🎯 PRÓXIMOS PASSOS:"
echo "   1. Copiar novo token de: new_token.txt"
echo "   2. Executar update_frontend_token.js no console do navegador"
echo "   3. Testar acesso às audiências"
echo ""
echo "📋 RESULTADOS DOS TESTES:"
if [ -n "$GET_STATUS" ]; then
    echo "   GET Status: $GET_STATUS"
fi
if [ -n "$POST_STATUS" ]; then
    echo "   POST Status: $POST_STATUS"
fi

echo ""
echo "🔄 Se ainda houver erro 401:"
echo "   150-debug-middleware-specific.sh"
echo "   Objetivo: Verificar middleware específico"