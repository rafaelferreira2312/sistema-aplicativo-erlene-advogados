#!/bin/bash

# Script 146 - Investigação completa do módulo audiências frontend
# Sistema Erlene Advogados - Status atual e próximos passos
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔍 Script 146 - Investigando status completo do módulo audiências..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "📋 ANÁLISE DO PROBLEMA REPORTADO:"
echo "   ✅ GET /admin/audiencias → 200 OK (funciona)"
echo "   ❌ POST /admin/audiencias → 401 Unauthorized (falha)"
echo "   Backend tem controller e rotas completos"
echo ""

echo "1️⃣ Verificando estrutura atual de arquivos audiências..."

echo "📂 Estrutura de pastas:"
find src/ -type d -name "*audienc*" 2>/dev/null || echo "   Nenhuma pasta específica encontrada"

echo ""
echo "📄 Páginas principais:"
find src/pages/ -type f -name "*audienc*" 2>/dev/null || echo "   Nenhuma página encontrada"

echo ""
echo "🎛️ Componentes:"
find src/components/ -type f -name "*audienc*" 2>/dev/null || echo "   Nenhum componente encontrado"

echo ""
echo "🔧 Services:"
find src/services/ -type f -name "*audienc*" 2>/dev/null || echo "   Nenhum service encontrado"

echo ""
echo "2️⃣ Verificando conteúdo do audienciasService.js..."

if [ -f "src/services/audienciasService.js" ]; then
    echo "✅ audienciasService.js encontrado"
    echo ""
    echo "📋 Método getAuthToken:"
    grep -n -A5 "getAuthToken" src/services/audienciasService.js || echo "   Método não encontrado"
    
    echo ""
    echo "📋 Método criarAudiencia:"
    grep -n -A10 "criarAudiencia\|POST" src/services/audienciasService.js || echo "   Método não encontrado"
    
    echo ""
    echo "📋 Headers das requisições:"
    grep -n -A5 "headers\|Authorization" src/services/audienciasService.js || echo "   Headers não encontrados"
    
else
    echo "❌ audienciasService.js NÃO encontrado"
fi

echo ""
echo "3️⃣ Verificando página principal Audiencias.js..."

if [ -f "src/pages/admin/Audiencias.js" ]; then
    echo "✅ Audiencias.js encontrado"
    echo ""
    echo "📋 Imports do service:"
    grep -n "import.*audiencias" src/pages/admin/Audiencias.js || echo "   Import não encontrado"
    
    echo ""
    echo "📋 Uso do service na página:"
    grep -n "audienciasService\." src/pages/admin/Audiencias.js || echo "   Uso não encontrado"
    
else
    echo "❌ Audiencias.js NÃO encontrado"
fi

echo ""
echo "4️⃣ Verificando formulários de criação/edição..."

if [ -f "src/components/audiencias/NewAudiencia.js" ]; then
    echo "✅ NewAudiencia.js encontrado"
    echo ""
    echo "📋 Import do service:"
    grep -n "import.*audienciasService" src/components/audiencias/NewAudiencia.js || echo "   Import não encontrado"
    
    echo ""
    echo "📋 Método handleSubmit:"
    grep -n -A3 "handleSubmit\|criarAudiencia" src/components/audiencias/NewAudiencia.js || echo "   Método não encontrado"
    
else
    echo "❌ NewAudiencia.js NÃO encontrado"
fi

if [ -f "src/components/audiencias/EditAudiencia.js" ]; then
    echo "✅ EditAudiencia.js encontrado"
    echo ""
    echo "📋 Import do service:"
    grep -n "import.*audienciasService" src/components/audiencias/EditAudiencia.js || echo "   Import não encontrado"
    
else
    echo "❌ EditAudiencia.js NÃO encontrado"
fi

echo ""
echo "5️⃣ Verificando rotas em App.js..."

if [ -f "src/App.js" ]; then
    echo "✅ App.js encontrado"
    echo ""
    echo "📋 Rotas de audiências:"
    grep -n -A2 -B2 "audienc" src/App.js || echo "   Rotas não encontradas"
    
else
    echo "❌ App.js NÃO encontrado"
fi

echo ""
echo "6️⃣ Comparando com módulos funcionais (clientes/processos)..."

echo "📋 Verificando clientsService.js:"
if [ -f "src/services/clientsService.js" ]; then
    echo "   ✅ clientsService.js existe"
    echo "   📋 Como faz autenticação:"
    grep -n -A3 "Authorization\|Bearer\|token" src/services/clientsService.js | head -5 || echo "   Método de auth não encontrado"
else
    echo "   ❌ clientsService.js NÃO existe"
fi

echo ""
echo "📋 Verificando processesService.js:"
if [ -f "src/services/processesService.js" ]; then
    echo "   ✅ processesService.js existe"
    echo "   📋 Como faz autenticação:"
    grep -n -A3 "Authorization\|Bearer\|token" src/services/processesService.js | head -5 || echo "   Método de auth não encontrado"
else
    echo "   ❌ processesService.js NÃO existe"
fi

echo ""
echo "7️⃣ Verificando apiClient ou configuração central..."

if [ -f "src/services/apiClient.js" ]; then
    echo "✅ apiClient.js encontrado"
    echo ""
    echo "📋 Configuração de autenticação:"
    grep -n -A5 "Authorization\|Bearer\|token" src/services/apiClient.js || echo "   Configuração não encontrada"
else
    echo "❌ apiClient.js NÃO encontrado"
fi

if [ -f "src/services/api.js" ]; then
    echo "✅ api.js encontrado"
    echo ""
    echo "📋 Configuração de autenticação:"
    grep -n -A5 "Authorization\|Bearer\|token" src/services/api.js || echo "   Configuração não encontrada"
else
    echo "❌ api.js NÃO encontrado"
fi

echo ""
echo "8️⃣ Verificando localStorage usage nos components..."

echo "📋 Como outros components salvam/recuperam token:"
find src/ -name "*.js" -type f -exec grep -l "localStorage.*token\|token.*localStorage" {} \; | head -5

echo ""
echo "9️⃣ Gerando diagnóstico das diferenças..."

echo "📊 RESUMO DO DIAGNÓSTICO:"
echo "=========================="

# Verificar se audienciasService existe
if [ -f "src/services/audienciasService.js" ]; then
    echo "✅ audienciasService.js existe"
else
    echo "❌ audienciasService.js MISSING - PRECISA CRIAR"
fi

# Verificar se página principal existe
if [ -f "src/pages/admin/Audiencias.js" ]; then
    echo "✅ Página Audiencias.js existe"
else
    echo "❌ Página Audiencias.js MISSING - PRECISA CRIAR"
fi

# Verificar se formulários existem
if [ -f "src/components/audiencias/NewAudiencia.js" ]; then
    echo "✅ NewAudiencia.js existe"
else
    echo "❌ NewAudiencia.js MISSING - PRECISA CRIAR"
fi

if [ -f "src/components/audiencias/EditAudiencia.js" ]; then
    echo "✅ EditAudiencia.js existe"
else
    echo "❌ EditAudiencia.js MISSING - PRECISA CRIAR"
fi

echo ""
echo "🔍 PROBLEMAS IDENTIFICADOS:"
echo "=========================="

# Verificar se há inconsistência na autenticação
if [ -f "src/services/audienciasService.js" ] && [ -f "src/services/clientsService.js" ]; then
    echo "🔐 Comparando métodos de autenticação..."
    
    AUDIENCIAS_AUTH=$(grep -n "Authorization\|Bearer" src/services/audienciasService.js | head -1)
    CLIENTS_AUTH=$(grep -n "Authorization\|Bearer" src/services/clientsService.js | head -1)
    
    if [ -n "$AUDIENCIAS_AUTH" ] && [ -n "$CLIENTS_AUTH" ]; then
        echo "✅ Ambos services têm configuração de auth"
    else
        echo "❌ INCONSISTÊNCIA: Métodos de auth diferentes entre services"
    fi
fi

echo ""
echo "🎯 PRÓXIMOS PASSOS SUGERIDOS:"
echo "============================="

echo "1. Verificar se audienciasService usa mesma auth dos outros modules"
echo "2. Testar endpoints isoladamente no console do navegador"
echo "3. Comparar headers enviados em GET vs POST"
echo "4. Verificar se token está sendo enviado corretamente"
echo "5. Verificar permissões do usuário no backend"

echo ""
echo "🧪 SCRIPT DE TESTE MANUAL:"
echo "=========================="

cat > test_audiencias_auth.js << 'EOF'
// Cole este código no console do navegador (F12)
console.log('=== TESTE MANUAL DE AUTENTICAÇÃO AUDIÊNCIAS ===');

// 1. Verificar tokens disponíveis
const tokens = {
    token: localStorage.getItem('token'),
    erlene_token: localStorage.getItem('erlene_token'),
    authToken: localStorage.getItem('authToken'),
    access_token: localStorage.getItem('access_token')
};

console.log('Tokens encontrados:', tokens);

// 2. Testar GET (que funciona)
const testGET = async () => {
    const token = tokens.token || tokens.erlene_token || tokens.authToken;
    try {
        const response = await fetch('http://localhost:8000/api/admin/audiencias', {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Accept': 'application/json'
            }
        });
        console.log('GET Status:', response.status);
        if (response.ok) {
            const data = await response.json();
            console.log('GET Data:', data);
        }
    } catch (error) {
        console.error('GET Error:', error);
    }
};

// 3. Testar POST (que falha)
const testPOST = async () => {
    const token = tokens.token || tokens.erlene_token || tokens.authToken;
    try {
        const response = await fetch('http://localhost:8000/api/admin/audiencias', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                processo_id: 1,
                cliente_id: 1,
                tipo: 'conciliacao',
                data: '2025-09-16',
                hora: '10:00',
                local: 'Teste Debug',
                advogado: 'Dr. Teste'
            })
        });
        console.log('POST Status:', response.status);
        if (!response.ok) {
            const error = await response.text();
            console.log('POST Error:', error);
        } else {
            const data = await response.json();
            console.log('POST Success:', data);
        }
    } catch (error) {
        console.error('POST Error:', error);
    }
};

// Executar testes
console.log('Executando GET...');
testGET().then(() => {
    console.log('Executando POST...');
    testPOST();
});
EOF

echo "📋 Execute o arquivo test_audiencias_auth.js no console do navegador"

echo ""
echo "✅ Script 146 concluído!"
echo ""
echo "📄 PRÓXIMO SCRIPT SUGERIDO:"
echo "   147-fix-audiencias-auth-issue.sh"
echo "   Objetivo: Corrigir problema específico de autenticação POST"