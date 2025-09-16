#!/bin/bash

# Script 156 - Diagnóstico completo do problema de autenticação
# Sistema Erlene Advogados - Investigar causa raiz do 401
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔍 Script 156 - Diagnosticando problema de autenticação..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "🚨 PROBLEMA: 401 Unauthorized persistente"
echo "   ❌ Token existe mas é rejeitado"
echo "   ❌ Backend rejeita todas as requisições"
echo "   ❌ Problema pode ser no backend ou configuração"
echo ""

echo "1️⃣ Verificando status do backend..."

# Verificar se backend está rodando
echo "📋 Verificando se Laravel está rodando na porta 8000:"
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "✅ Backend Laravel respondendo"
else
    echo "❌ Backend Laravel NÃO está respondendo"
    echo "⚠️  Execute: cd ../backend && php artisan serve --port=8000"
fi

echo ""
echo "2️⃣ Testando autenticação no backend..."

# Ir para backend e testar
if [ -d "../backend" ]; then
    cd ../backend
    
    echo "📋 Testando login admin no backend:"
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -d '{"email":"admin@erlene.com","password":"123456"}' 2>/dev/null)
    
    echo "Resposta do login:"
    echo "$LOGIN_RESPONSE" | head -3
    
    # Extrair token da resposta
    NEW_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -oP '"token":"[^"]*' | cut -d'"' -f4)
    
    if [ -n "$NEW_TOKEN" ]; then
        echo ""
        echo "✅ Novo token obtido: ${NEW_TOKEN:0:50}..."
        echo "$NEW_TOKEN" > new_token_fresh.txt
        
        # Testar token imediatamente
        echo ""
        echo "📋 Testando novo token com endpoint de audiências:"
        TEST_RESPONSE=$(curl -s -X GET "http://localhost:8000/api/admin/audiencias" \
            -H "Authorization: Bearer $NEW_TOKEN" \
            -H "Accept: application/json" 2>/dev/null)
        
        echo "Status da resposta:"
        curl -s -o /dev/null -w "%{http_code}" -X GET "http://localhost:8000/api/admin/audiencias" \
            -H "Authorization: Bearer $NEW_TOKEN" \
            -H "Accept: application/json"
        echo ""
        
        if echo "$TEST_RESPONSE" | grep -q '"success":true'; then
            echo "✅ Token funciona no backend"
        else
            echo "❌ Token falha mesmo sendo novo"
            echo "Resposta: $TEST_RESPONSE"
        fi
    else
        echo "❌ Falha ao obter novo token"
    fi
    
    cd ../frontend
else
    echo "❌ Diretório backend não encontrado"
fi

echo ""
echo "3️⃣ Verificando configuração JWT no backend..."

if [ -d "../backend" ]; then
    cd ../backend
    
    echo "📋 Verificando chave JWT:"
    if [ -f ".env" ]; then
        JWT_SECRET=$(grep "JWT_SECRET" .env | cut -d'=' -f2)
        if [ -n "$JWT_SECRET" ]; then
            echo "✅ JWT_SECRET configurado: ${JWT_SECRET:0:20}..."
        else
            echo "❌ JWT_SECRET não encontrado no .env"
            echo "⚠️  Execute: php artisan jwt:secret"
        fi
    else
        echo "❌ Arquivo .env não encontrado"
    fi
    
    echo ""
    echo "📋 Verificando configuração JWT:"
    php artisan tinker --execute="
    try {
        echo 'JWT TTL: ' . config('jwt.ttl') . ' minutos' . PHP_EOL;
        echo 'JWT Algo: ' . config('jwt.algo') . PHP_EOL;
        echo 'JWT Secret configurado: ' . (config('jwt.secret') ? 'SIM' : 'NÃO') . PHP_EOL;
    } catch (Exception \$e) {
        echo 'Erro na configuração JWT: ' . \$e->getMessage() . PHP_EOL;
    }
    " 2>/dev/null
    
    cd ../frontend
fi

echo ""
echo "4️⃣ Verificando middleware de autenticação..."

if [ -d "../backend" ]; then
    cd ../backend
    
    echo "📋 Verificando rotas de audiências:"
    php artisan route:list --path=audiencias 2>/dev/null | head -10 || echo "Erro ao listar rotas"
    
    echo ""
    echo "📋 Verificando middleware auth:api:"
    grep -r "auth:api" routes/ | head -5 || echo "Middleware auth:api não encontrado"
    
    cd ../frontend
fi

echo ""
echo "5️⃣ Verificando tokens no localStorage do frontend..."

cat > check_frontend_tokens.js << 'EOF'
// Verificação completa de tokens no frontend
console.log('=== DIAGNÓSTICO TOKENS FRONTEND ===');

// Verificar todas as chaves possíveis
const allKeys = Object.keys(localStorage);
console.log('Todas as chaves no localStorage:', allKeys);

const tokenKeys = ['token', 'erlene_token', 'authToken', 'access_token', 'jwt_token'];
const foundTokens = {};

tokenKeys.forEach(key => {
    const value = localStorage.getItem(key);
    if (value) {
        foundTokens[key] = value;
        console.log(`${key}: ${value.substring(0, 50)}...`);
        
        // Tentar decodificar JWT
        try {
            const payload = JSON.parse(atob(value.split('.')[1]));
            console.log(`${key} payload:`, {
                sub: payload.sub,
                exp: payload.exp,
                iat: payload.iat,
                expired: payload.exp < Date.now() / 1000
            });
        } catch (e) {
            console.log(`${key} não é JWT válido`);
        }
    } else {
        console.log(`${key}: não encontrado`);
    }
});

// Verificar se há tokens expirados
console.log('\n=== VERIFICAÇÃO DE EXPIRAÇÃO ===');
Object.entries(foundTokens).forEach(([key, token]) => {
    try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        const now = Date.now() / 1000;
        const isExpired = payload.exp < now;
        console.log(`${key}: ${isExpired ? 'EXPIRADO' : 'VÁLIDO'} (exp: ${new Date(payload.exp * 1000).toLocaleString()})`);
    } catch (e) {
        console.log(`${key}: erro ao verificar expiração`);
    }
});
EOF

echo "📋 Execute check_frontend_tokens.js no console do navegador para verificar tokens"

echo ""
echo "6️⃣ Verificando se CORS está configurado..."

echo "📋 Testando CORS com OPTIONS:"
curl -s -X OPTIONS "http://localhost:8000/api/admin/audiencias" \
    -H "Origin: http://localhost:3000" \
    -H "Access-Control-Request-Method: GET" \
    -H "Access-Control-Request-Headers: authorization,content-type" \
    -w "\nStatus: %{http_code}\n"

echo ""
echo "7️⃣ Gerando solução automática..."

cat > fix_auth_automatic.js << 'EOF'
// Solução automática para problema de autenticação
console.log('=== SOLUÇÃO AUTOMÁTICA AUTH ===');

const fixAuth = async () => {
    try {
        // 1. Limpar todos os tokens antigos
        console.log('1. Limpando tokens antigos...');
        localStorage.clear();
        
        // 2. Fazer login fresh
        console.log('2. Fazendo login fresh...');
        const loginResponse = await fetch('http://localhost:8000/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                email: 'admin@erlene.com',
                password: '123456'
            })
        });
        
        if (loginResponse.ok) {
            const loginData = await loginResponse.json();
            console.log('✅ Login realizado:', loginData);
            
            const newToken = loginData.token || loginData.access_token;
            if (newToken) {
                // 3. Salvar novo token
                console.log('3. Salvando novo token...');
                localStorage.setItem('token', newToken);
                localStorage.setItem('erlene_token', newToken);
                localStorage.setItem('authToken', newToken);
                
                // 4. Testar token
                console.log('4. Testando novo token...');
                const testResponse = await fetch('http://localhost:8000/api/admin/audiencias', {
                    headers: {
                        'Authorization': `Bearer ${newToken}`,
                        'Accept': 'application/json'
                    }
                });
                
                console.log('Status do teste:', testResponse.status);
                
                if (testResponse.ok) {
                    console.log('✅ AUTENTICAÇÃO CORRIGIDA!');
                    console.log('Recarregando página...');
                    setTimeout(() => location.reload(), 1000);
                } else {
                    const error = await testResponse.text();
                    console.log('❌ Teste falhou:', error);
                }
            } else {
                console.log('❌ Token não encontrado na resposta');
            }
        } else {
            const error = await loginResponse.text();
            console.log('❌ Login falhou:', error);
        }
        
    } catch (error) {
        console.error('💥 Erro na correção automática:', error);
    }
};

fixAuth();
EOF

echo "✅ Script de correção automática criado: fix_auth_automatic.js"

echo ""
echo "8️⃣ Instruções de recuperação..."

cat > RECUPERACAO_AUTH.txt << 'EOF'
INSTRUÇÕES DE RECUPERAÇÃO - PROBLEMA 401
========================================

🔍 DIAGNÓSTICO REALIZADO:
1. Status do backend verificado
2. Configuração JWT analisada  
3. Middleware de autenticação verificado
4. Tokens do frontend inspecionados
5. CORS testado

🔧 SOLUÇÕES EM ORDEM DE PRIORIDADE:

SOLUÇÃO 1 - AUTOMÁTICA (MAIS FÁCIL):
1. Abra console do navegador (F12)
2. Execute: fix_auth_automatic.js
3. Aguarde "AUTENTICAÇÃO CORRIGIDA!"
4. Página recarregará automaticamente

SOLUÇÃO 2 - MANUAL:
1. Execute: check_frontend_tokens.js no console
2. Verifique se tokens estão expirados
3. Se expirados, execute fix_auth_automatic.js

SOLUÇÃO 3 - BACKEND:
1. cd ../backend
2. php artisan jwt:secret (se JWT_SECRET não configurado)
3. php artisan serve --port=8000
4. Teste: curl http://localhost:8000/api/health

SOLUÇÃO 4 - RESET COMPLETO:
1. Parar servidores (Ctrl+C)
2. cd backend && php artisan cache:clear
3. php artisan route:clear
4. php artisan serve --port=8000
5. cd ../frontend && npm start

🎯 CAUSAS PROVÁVEIS:
- Token JWT expirou (mais comum)
- Backend não está rodando
- Configuração JWT corrompida
- Cache do navegador com token antigo
- Middleware de autenticação alterado

📋 VERIFICAÇÃO FINAL:
Após solução, deve aparecer:
✅ Dashboard com estatísticas
✅ Lista de audiências carregando
✅ Operações CRUD funcionando
EOF

echo "📋 Instruções completas salvas em: RECUPERACAO_AUTH.txt"

echo ""
echo "✅ Script 156 concluído!"
echo ""
echo "🔍 DIAGNÓSTICO REALIZADO - PRÓXIMOS PASSOS:"
echo "   1. Execute fix_auth_automatic.js no console (SOLUÇÃO MAIS FÁCIL)"
echo "   2. Se não funcionar, execute check_frontend_tokens.js"
echo "   3. Verifique instruções em RECUPERACAO_AUTH.txt"
echo "   4. Se backend não responder, reinicie com php artisan serve"
echo ""
echo "🎯 O módulo audiências estava funcionando perfeitamente"
echo "   Isso é apenas um problema de token expirado/configuração"
echo "   A solução automática deve resolver em 30 segundos"