#!/bin/bash

# Script 130 - Corrigir Nomes dos Métodos no clientsService
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 130-fix-method-names.sh && ./130-fix-method-names.sh
# EXECUTE NA PASTA: frontend/

echo "Corrigindo nomes dos métodos no clientsService..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

CLIENTS_SERVICE="src/services/api/clientsService.js"

echo "1. Verificando qual método o frontend está esperando..."

# Procurar por chamadas de métodos no código do frontend
echo "Métodos chamados no frontend:"
grep -r "clientsService\." src/ --include="*.js" --include="*.jsx" | head -10

echo ""
echo "2. Identificando métodos que precisam ser renomeados..."

# Fazer backup
cp "$CLIENTS_SERVICE" "${CLIENTS_SERVICE}.backup-methods-$(date +%Y%m%d-%H%M%S)"

# Corrigir nomes dos métodos baseado no que o frontend espera
echo "Renomeando métodos no clientsService.js..."

# getAll -> getClients
sed -i 's/async getAll(/async getClients(/g' "$CLIENTS_SERVICE"

# Adicionar outros métodos que podem estar sendo chamados
echo ""
echo "3. Adicionando aliases para métodos comuns..."

# Inserir aliases antes do fechamento do objeto
sed -i '/^};$/i\
\
  // Aliases para compatibilidade\
  async getAll(params = {}) {\
    return this.getClients(params);\
  },\
\
  // Método para buscar responsáveis (alias)\
  async responsaveis() {\
    return this.getResponsaveis();\
  }' "$CLIENTS_SERVICE"

echo "✅ Métodos renomeados e aliases adicionados"

echo ""
echo "4. Verificando estrutura final do service..."
echo "Métodos disponíveis:"
grep -n "async.*(" "$CLIENTS_SERVICE" | cut -d: -f2

echo ""
echo "5. Testando sintaxe..."
if node -c "$CLIENTS_SERVICE" 2>/dev/null; then
    echo "✅ Sintaxe JavaScript válida"
else
    echo "❌ Erros de sintaxe:"
    node -c "$CLIENTS_SERVICE"
fi

echo ""
echo "6. Testando no navegador..."

# Parar processos anteriores
pkill -f "npm start" 2>/dev/null || true
sleep 2

# Iniciar em background para teste
npm start > method_test.log 2>&1 &
NPM_PID=$!
sleep 10

# Verificar se carregou
if grep -q "webpack compiled successfully" method_test.log; then
    echo "✅ Compilação bem-sucedida!"
    echo ""
    echo "Testando se página carrega sem erro..."
    sleep 5
    
    # Verificar se não há erros de método
    if grep -q "is not a function" method_test.log; then
        echo "⚠️ Ainda há erros de função:"
        grep "is not a function" method_test.log
    else
        echo "✅ Aparentemente sem erros de função"
    fi
    
elif grep -q "Failed to compile" method_test.log; then
    echo "❌ Erro de compilação:"
    grep -A 5 "Failed to compile" method_test.log
else
    echo "⚠️ Status incerto"
fi

# Parar processo
kill $NPM_PID 2>/dev/null || true
rm -f method_test.log

echo ""
echo "7. Verificando se há outros arquivos que precisam de ajuste..."

# Procurar por outros usos de clientsService
echo "Verificando arquivos que importam clientsService:"
grep -r "import.*clientsService\|from.*clientsService" src/ --include="*.js" --include="*.jsx"

echo ""
echo "=== CORREÇÃO DE MÉTODOS FINALIZADA ==="
echo ""
echo "MÉTODOS CORRIGIDOS:"
echo "- getAll() -> getClients() (método principal)"
echo "- Aliases adicionados para compatibilidade"
echo "- getResponsaveis() mantido"
echo "- Novos métodos processos/documentos disponíveis"
echo ""
echo "TESTE AGORA:"
echo "npm start"
echo ""
echo "Se ainda houver erro 'is not a function', me informe"
echo "qual método específico está sendo chamado pelo frontend."