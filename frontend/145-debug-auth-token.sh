#!/bin/bash

# Script 145 - Debug específico do token de autenticação
# Sistema Erlene Advogados - Comparar auth GET vs POST
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔐 Script 145 - Debug específico do token de autenticação..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "🔍 PROBLEMA ESPECÍFICO:"
echo "   ✅ GET /admin/audiencias → 200 OK (funciona)"
echo "   ❌ POST /admin/audiencias → 401 Unauthorized (falha)"
echo "   Backend tem controller e rotas completos"
echo ""

echo "1️⃣ Analisando token atual no localStorage..."

# Criar script temporário para verificar localStorage
cat > temp_check_token.js << 'EOF'
console.log('=== DEBUG TOKEN DE AUTENTICAÇÃO ===');

// Verificar todas as chaves de token possíveis
const possibleKeys = ['token', 'erlene_token', 'authToken', 'access_token', 'isAuthenticated'];
const foundTokens = {};

possibleKeys.forEach(key => {
    const value = localStorage.getItem(key);
    if (value) {
        foundTokens[key] = value;
        console.log(`✅ ${key}:`, value.substring(0, 50) + '...');
    } else {
        console.log(`❌ ${key}: não encontrado`);
    }
});

// Verificar qual token o audienciasService está usando
console.log('\n=== TOKEN QUE AUDIENCIASSERVICE USA ===');
const getAuthToken = () => {
    return localStorage.getItem('token') || 
           localStorage.getItem('erlene_token') || 
           localStorage.getItem('authToken') ||
           localStorage.getItem('access_token');
};

const currentToken = getAuthToken();
console.log('Token atual do service:', currentToken ? currentToken.substring(0, 50) + '...' : 'NENHUM');

// Verificar headers que seriam enviados
console.log('\n=== HEADERS QUE SERIAM ENVIADOS ===');
if (currentToken) {
    console.log('Authorization: Bearer', currentToken.substring(0, 50) + '...');
} else {
    console.log('❌ NENHUM HEADER DE AUTORIZAÇÃO SERIA ENVIADO');
}

// Comparar com apiClient
console.log('\n=== COMPARAÇÃO COM APICLIENT ===');
// Simular como apiClient pega o token
const apiClientToken = localStorage.getItem('authToken') || 
                      localStorage.getItem('erlene_token') || 
                      localStorage.getItem('token');
                      
console.log('Token que apiClient usaria:', apiClientToken ? apiClientToken.substring(0, 50) + '...' : 'NENHUM');

if (currentToken !== apiClientToken) {
    console.log('🚨 TOKENS DIFERENTES!');
    console.log('audienciasService usa:', currentToken ? 'SIM' : 'NENHUM');
    console.log('apiClient usaria:', apiClientToken ? 'SIM' : 'NENHUM');
} else {
    console.log('✅ Tokens são iguais');
}
EOF

echo "📋 Execute este script no console do navegador para debug:"
echo "    (abra DevTools → Console → cole o código abaixo)"
echo ""
cat temp_check_token.js

echo ""
echo "2️⃣ Verificando diferença entre services..."

echo "📋 audienciasService.js - como pega token:"
grep -n -A5 "getAuthToken" src/services/audienciasService.js

echo ""
echo "📋 apiClient.js - como pega token:"  
grep -n -A5 "getAuthToken\|localStorage.getItem" src/services/apiClient.js

echo ""
echo "3️⃣ Testando diferença na prática..."

# Criar script de teste para executar no console
cat > temp_test_requests.js << 'EOF'
console.log('=== TESTE PRÁTICO GET vs POST ===');

// Simular GET (que funciona)
const testGET = async () => {
    try {
        const response = await fetch('http://localhost:8000/api/admin/audiencias', {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token') || localStorage.getItem('erlene_token') || localStorage.getItem('authToken')}`,
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        });
        console.log('✅ GET Status:', response.status);
        return response;
    } catch (error) {
        console.log('❌ GET Error:', error);
    }
};

// Simular POST (que falha)
const testPOST = async () => {
    try {
        const response = await fetch('http://localhost:8000/api/admin/audiencias', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token') || localStorage.getItem('erlene_token') || localStorage.getItem('authToken')}`,
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                processo_id: 1,
                cliente_id: 1,
                tipo: 'conciliacao',
                data: '2025-09-16',
                hora: '10:00',
                local: 'Teste',
                advogado: 'Dr. Teste'
            })
        });
        console.log('Status POST:', response.status);
        if (!response.ok) {
            const error = await response.text();
            console.log('❌ POST Error Body:', error);
        }
        return response;
    } catch (error) {
        console.log('❌ POST Error:', error);
    }
};

// Executar testes
console.log('Testando GET...');
testGET().then(() => {
    console.log('Testando POST...');
    testPOST();
});
EOF

echo "📋 Para testar requests diretos, execute no console:"
echo ""
cat temp_test_requests.js

echo ""
echo "4️⃣ Verificando se usuário atual tem permissão..."

echo "📋 Verificar no backend se usuário tem role adequado:"
echo "   1. Vá para /admin/users"
echo "   2. Verifique seu perfil de usuário"
echo "   3. Confirme se tem permissão 'create_audiencias'"

echo ""
echo "5️⃣ Solução mais simples - Verificar real diferença..."

echo "📋 Modelos funcionais que devemos comparar:"
if [ -f "src/services/clientsService.js" ]; then
    echo "✅ clientsService.js existe"
    echo "    Como ele faz POST:"
    grep -n -A3 "POST.*clients\|createClient" src/services/clientsService.js | head -5
fi

echo ""
echo "📋 Como audienciasService faz POST:"
grep -n -A3 "POST.*audiencias\|criarAudiencia" src/services/audienciasService.js | head -5

echo ""
echo "🎯 PLANO DE AÇÃO FOCADO:"
echo "   1. Executar scripts de debug no console do navegador"
echo "   2. Comparar tokens GET vs POST"  
echo "   3. Verificar se usuário tem role adequado"
echo "   4. Se necessário, corrigir token ou permissões"

echo ""
rm temp_check_token.js temp_test_requests.js
echo "✅ Debug concluído - execute os scripts no console para diagnóstico completo"