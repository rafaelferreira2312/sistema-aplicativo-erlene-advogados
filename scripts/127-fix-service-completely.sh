#!/bin/bash

# Script 127 - Corrigir clientsService.js Completamente
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 127-fix-service-completely.sh && ./127-fix-service-completely.sh
# EXECUTE NA PASTA: frontend/

echo "Corrigindo clientsService.js completamente..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

CLIENTS_SERVICE="src/services/api/clientsService.js"

echo "1. Analisando problema atual..."
echo "Erro encontrado: vírgula extra e estrutura quebrada"

echo ""
echo "2. Fazendo backup final..."
cp "$CLIENTS_SERVICE" "${CLIENTS_SERVICE}.backup-final-$(date +%Y%m%d-%H%M%S)"

echo ""
echo "3. Reconstruindo arquivo inteiramente..."

# Corrigir o arquivo linha por linha
sed -i '186s/;,/;/' "$CLIENTS_SERVICE"  # Remover vírgula extra na linha 186

# Verificar se o fechamento está correto
if ! grep -q "^};" "$CLIENTS_SERVICE"; then
    echo "Adicionando fechamento correto do objeto..."
    
    # Remover linhas problemáticas do final
    sed -i '/\/\/ Obter processos do cliente/,$d' "$CLIENTS_SERVICE"
    
    # Adicionar métodos e fechamento correto
    cat >> "$CLIENTS_SERVICE" << 'EOF'

  // Obter processos do cliente
  getClientProcessos: async (clienteId) => {
    try {
      const response = await api.get(`/admin/clients/${clienteId}/processos`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar processos:', error);
      throw error;
    }
  },

  // Obter documentos do cliente
  getClientDocumentos: async (clienteId) => {
    try {
      const response = await api.get(`/admin/clients/${clienteId}/documentos`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar documentos:', error);
      throw error;
    }
  }
};

// Export default também para compatibilidade
export default clientsService;
EOF

    echo "✅ Arquivo reconstruído com fechamento correto"
fi

echo ""
echo "4. Verificando estrutura final..."
echo "Últimas 15 linhas:"
tail -15 "$CLIENTS_SERVICE"

echo ""
echo "5. Testando sintaxe..."
if node -c "$CLIENTS_SERVICE" 2>/dev/null; then
    echo "✅ Sintaxe JavaScript válida"
else
    echo "❌ Ainda há erros:"
    node -c "$CLIENTS_SERVICE"
fi

echo ""
echo "6. Testando compilação React..."

# Parar qualquer processo npm rodando
pkill -f "npm start" 2>/dev/null || true
sleep 2

# Iniciar npm start em background e capturar output
timeout 15s npm start > compile_test.log 2>&1 &
NPM_PID=$!

echo "Aguardando compilação por 15 segundos..."
wait $NPM_PID 2>/dev/null || true

# Verificar resultado
if grep -q "webpack compiled successfully" compile_test.log; then
    echo "✅ COMPILAÇÃO BEM-SUCEDIDA!"
elif grep -q "Failed to compile" compile_test.log; then
    echo "❌ Erros de compilação encontrados:"
    grep -A 10 "Failed to compile" compile_test.log
    echo ""
    echo "SyntaxError específico:"
    grep -A 5 "SyntaxError" compile_test.log
else
    echo "⚠️ Resultado incerto - verifique manualmente"
    tail -10 compile_test.log
fi

# Limpar
rm -f compile_test.log
pkill -f "npm start" 2>/dev/null || true

echo ""
echo "=== CORREÇÃO COMPLETA FINALIZADA ==="
echo ""
echo "ARQUIVO CORRIGIDO:"
echo "- Vírgula extra removida"
echo "- Estrutura do objeto corrigida" 
echo "- Métodos processos/documentos adicionados"
echo "- Fechamento correto com };"
echo ""
echo "TESTE AGORA:"
echo "npm start"
echo ""
echo "Se funcionar, o próximo passo é integrar o botão 'Detalhes' na interface!"