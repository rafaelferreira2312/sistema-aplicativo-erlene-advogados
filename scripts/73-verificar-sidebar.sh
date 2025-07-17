#!/bin/bash

# Script 73 - Verificar e Corrigir Links do Sidebar  
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "🔍 Verificando links do sidebar..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar se AdminLayout existe
if [ ! -f "frontend/src/components/layout/AdminLayout/index.js" ]; then
    echo "❌ AdminLayout não encontrado em: frontend/src/components/layout/AdminLayout/index.js"
    exit 1
fi

echo "📁 Verificando AdminLayout..."

# Verificar se link de clientes está correto
if grep -q "/admin/clientes" frontend/src/components/layout/AdminLayout/index.js; then
    echo "✅ Link '/admin/clientes' encontrado no AdminLayout"
elif grep -q "/admin/clients" frontend/src/components/layout/AdminLayout/index.js; then
    echo "⚠️  Link '/admin/clients' encontrado - corrigindo para '/admin/clientes'..."
    
    # Fazer backup
    cp frontend/src/components/layout/AdminLayout/index.js frontend/src/components/layout/AdminLayout/index.js.backup
    
    # Corrigir links
    sed -i 's|/admin/clients|/admin/clientes|g' frontend/src/components/layout/AdminLayout/index.js
    
    echo "✅ Links corrigidos no AdminLayout"
else
    echo "⚠️  Link de clientes não encontrado - verificação manual necessária"
fi

echo ""
echo "🔍 VERIFICAÇÃO COMPLETA:"
echo ""

# Verificar estrutura de arquivos
echo "📁 ESTRUTURA DE ARQUIVOS:"
if [ -f "frontend/src/pages/admin/Clients/index.js" ]; then
    echo "✅ frontend/src/pages/admin/Clients/index.js - EXISTE"
else
    echo "❌ frontend/src/pages/admin/Clients/index.js - NÃO EXISTE"
fi

if [ -f "frontend/src/App.js" ]; then
    echo "✅ frontend/src/App.js - EXISTE"
    
    # Verificar se import está correto
    if grep -q "import Clients from './pages/admin/Clients'" frontend/src/App.js; then
        echo "✅ Import do Clients configurado"
    else
        echo "❌ Import do Clients NÃO configurado"
    fi
    
    # Verificar se rota está configurada
    if grep -q 'path="clientes"' frontend/src/App.js; then
        echo "✅ Rota 'clientes' configurada"
    else
        echo "❌ Rota 'clientes' NÃO configurada"
    fi
else
    echo "❌ frontend/src/App.js - NÃO EXISTE"
fi

echo ""
echo "🔗 TESTE AS ROTAS:"
echo "   1. Acesse: http://localhost:3000/login"
echo "   2. Faça login com: admin@erlene.com / 123456"
echo "   3. Teste: http://localhost:3000/admin (Dashboard)"
echo "   4. Teste: http://localhost:3000/admin/clientes (Clientes)"
echo "   5. Clique no menu 'Clientes' no sidebar"
echo ""
echo "✨ Se ainda não funcionar, verifique:"
echo "   • Console do navegador (F12) para erros"
echo "   • Se o servidor está rodando (npm start)"
echo "   • Se todas as dependências estão instaladas"