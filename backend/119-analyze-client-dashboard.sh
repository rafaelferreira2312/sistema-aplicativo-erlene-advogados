#!/bin/bash

# Script 119 - Analisar Dashboard de Clientes e Paginação
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 119-analyze-client-dashboard.sh && ./119-analyze-client-dashboard.sh
# EXECUTE NA PASTA: backend/

echo "🔍 Analisando dashboard de clientes e paginação..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo ""
echo "=== ANÁLISE DA ESTRUTURA ATUAL ==="

echo "1. Verificando controller de clientes..."
CONTROLLER_PATH="app/Http/Controllers/Api/Admin/Clients/ClientController.php"

if [ -f "$CONTROLLER_PATH" ]; then
    echo "✅ ClientController encontrado"
    
    echo ""
    echo "2. Analisando método de listagem (index)..."
    if grep -q "function index" "$CONTROLLER_PATH"; then
        echo "Método index encontrado:"
        grep -A 30 "function index" "$CONTROLLER_PATH" | head -35
    else
        echo "❌ Método index não encontrado"
    fi
    
    echo ""
    echo "3. Verificando paginação atual..."
    if grep -q "paginate" "$CONTROLLER_PATH"; then
        echo "✅ Paginação encontrada:"
        grep -n "paginate" "$CONTROLLER_PATH"
    else
        echo "⚠️  Paginação não encontrada - pode ser scroll infinito ou listagem completa"
    fi
    
    echo ""
    echo "4. Verificando campos retornados..."
    if grep -q "select.*documento\|select.*cpf\|select.*cnpj" "$CONTROLLER_PATH"; then
        echo "Campos de documento encontrados:"
        grep -n -A 2 -B 2 "select.*documento\|select.*cpf\|select.*cnpj" "$CONTROLLER_PATH"
    else
        echo "⚠️  Precisa verificar quais campos são retornados"
    fi
    
else
    echo "❌ ClientController não encontrado"
    exit 1
fi

echo ""
echo "5. Verificando estrutura da tabela clientes..."
php artisan tinker --execute "
try {
    echo 'ESTRUTURA DA TABELA CLIENTES:';
    \$columns = \Schema::getColumnListing('clientes');
    foreach(\$columns as \$col) {
        echo '- ' . \$col;
    }
    
    echo '';
    echo 'EXEMPLO DE CLIENTE:';
    \$cliente = \App\Models\Cliente::first();
    if(\$cliente) {
        echo 'ID: ' . \$cliente->id;
        echo 'Nome: ' . (\$cliente->nome ?? \$cliente->name ?? 'N/A');
        echo 'CPF: ' . (\$cliente->cpf ?? 'N/A');
        echo 'CNPJ: ' . (\$cliente->cnpj ?? 'N/A');
        echo 'Documento: ' . (\$cliente->documento ?? 'N/A');
        echo 'Tipo: ' . (\$cliente->tipo ?? 'N/A');
    } else {
        echo 'Nenhum cliente encontrado';
    }
    
    echo '';
    echo 'TOTAL DE CLIENTES: ' . \App\Models\Cliente::count();
    
} catch(Exception \$e) {
    echo 'ERRO: ' . \$e->getMessage();
}
"

echo ""
echo "6. Verificando modelos relacionados (Processo, Documento)..."

# Verificar se existem os modelos
if [ -f "app/Models/Processo.php" ]; then
    echo "✅ Modelo Processo encontrado"
else
    echo "⚠️  Modelo Processo não encontrado"
fi

if [ -f "app/Models/Documento.php" ]; then
    echo "✅ Modelo Documento encontrado"
else
    echo "⚠️  Modelo Documento não encontrado"
fi

echo ""
echo "7. Verificando relacionamentos no modelo Cliente..."
if [ -f "app/Models/Cliente.php" ]; then
    echo "Relacionamentos no modelo Cliente:"
    grep -n "function.*processo\|function.*documento\|belongsTo\|hasMany\|belongsToMany" "app/Models/Cliente.php" || echo "Nenhum relacionamento específico encontrado"
else
    echo "❌ Modelo Cliente não encontrado"
fi

echo ""
echo "8. Verificando estrutura do frontend..."
echo "Procurando arquivos do frontend de clientes..."
find ../frontend -name "*client*" -o -name "*Client*" 2>/dev/null | head -10

echo ""
echo "9. Testando endpoint de listagem atual..."

# Fazer login
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "✅ Login OK"
    
    # Testar listagem de clientes
    echo "Testando GET /api/admin/clients..."
    CLIENT_LIST=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:8000/api/admin/clients)
    
    echo "Resultado da listagem:"
    echo "$CLIENT_LIST" | head -10
    
    # Verificar se tem paginação
    if echo "$CLIENT_LIST" | grep -q '"current_page"\|"per_page"\|"total"'; then
        echo ""
        echo "✅ PAGINAÇÃO DETECTADA:"
        echo "$CLIENT_LIST" | grep -o '"current_page":[^,]*\|"per_page":[^,]*\|"total":[^,]*\|"last_page":[^,]*'
    else
        echo ""
        echo "⚠️  SEM PAGINAÇÃO - Lista simples ou scroll infinito"
    fi
    
else
    echo "❌ Erro no login - não foi possível testar endpoint"
fi

echo ""
echo "=== RESUMO DA ANÁLISE ==="
echo ""
echo "📋 ESTRUTURA ATUAL:"
echo "- Controller: $CONTROLLER_PATH"
echo "- Modelo Cliente: app/Models/Cliente.php"
echo "- Paginação: $(grep -q "paginate" "$CONTROLLER_PATH" && echo "SIM" || echo "NÃO DETECTADA")"
echo ""
echo "🎯 MELHORIAS NECESSÁRIAS:"
echo "1. Alterar coluna 'Documento' para 'CPF/CNPJ'"
echo "2. Adicionar aba 'Processos relacionados'"
echo "3. Adicionar aba 'Documentos relacionados'"
echo "4. Verificar/implementar paginação adequada"
echo ""
echo "💡 PRÓXIMOS PASSOS:"
echo "1. Implementar endpoints para processos e documentos do cliente"
echo "2. Atualizar frontend para mostrar CPF/CNPJ"
echo "3. Criar componentes das abas Processos e Documentos"
echo "4. Configurar paginação se necessário"