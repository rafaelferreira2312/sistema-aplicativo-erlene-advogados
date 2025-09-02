#!/bin/bash

# Script 126 - Analisar e Corrigir clientsService.js
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 126-analyze-and-fix-service.sh && ./126-analyze-and-fix-service.sh
# EXECUTE NA PASTA: frontend/

echo "Analisando e corrigindo clientsService.js..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

CLIENTS_SERVICE="src/services/api/clientsService.js"

if [ ! -f "$CLIENTS_SERVICE" ]; then
    echo "❌ Arquivo não encontrado: $CLIENTS_SERVICE"
    exit 1
fi

echo "1. Analisando conteúdo atual do arquivo..."
echo "Linhas 185-200:"
sed -n '185,200p' "$CLIENTS_SERVICE"

echo ""
echo "2. Procurando a estrutura do objeto..."

# Verificar se é export const ou export default
if grep -q "export const" "$CLIENTS_SERVICE"; then
    echo "Estrutura: export const"
elif grep -q "export default" "$CLIENTS_SERVICE"; then
    echo "Estrutura: export default"
else
    echo "Estrutura não identificada"
fi

echo ""
echo "3. Restaurando backup e recriando arquivo limpo..."

# Usar backup mais recente
BACKUP_FILE=$(ls -t src/services/api/clientsService.js.backup-* 2>/dev/null | head -1)
if [ -f "$BACKUP_FILE" ]; then
    echo "Restaurando backup: $BACKUP_FILE"
    cp "$BACKUP_FILE" "$CLIENTS_SERVICE"
else
    echo "Sem backup - trabalhando com arquivo atual"
fi

# Remover qualquer linha problemática
sed -i '/getClientProcessos/,/^}/d' "$CLIENTS_SERVICE"
sed -i '/getClientDocumentos/,/^}/d' "$CLIENTS_SERVICE"

echo ""
echo "4. Verificando última linha válida do objeto..."
echo "Últimas 10 linhas após limpeza:"
tail -10 "$CLIENTS_SERVICE"

# Verificar se última linha antes de }; tem vírgula
LAST_METHOD_LINE=$(grep -n "}" "$CLIENTS_SERVICE" | tail -2 | head -1 | cut -d: -f1)
if [ ! -z "$LAST_METHOD_LINE" ]; then
    PREV_LINE=$((LAST_METHOD_LINE - 1))
    PREV_CONTENT=$(sed -n "${PREV_LINE}p" "$CLIENTS_SERVICE")
    echo "Linha anterior ao fechamento: $PREV_CONTENT"
    
    # Se não termina com vírgula, adicionar
    if [[ "$PREV_CONTENT" != *"," ]]; then
        echo "Adicionando vírgula na linha $PREV_LINE"
        sed -i "${PREV_LINE}s/$/,/" "$CLIENTS_SERVICE"
    fi
fi

echo ""
echo "5. Adicionando novos métodos na posição correta..."

# Inserir antes da linha que contém apenas };
LINE_TO_INSERT=$(grep -n "^};" "$CLIENTS_SERVICE" | cut -d: -f1)
if [ ! -z "$LINE_TO_INSERT" ]; then
    BEFORE_LINE=$((LINE_TO_INSERT - 1))
    
    # Criar arquivo temporário com métodos
    cat > temp_methods.txt << 'EOF'

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
EOF
    
    # Inserir métodos antes da linha de fechamento
    {
        head -n "$BEFORE_LINE" "$CLIENTS_SERVICE"
        cat temp_methods.txt
        tail -n +"$LINE_TO_INSERT" "$CLIENTS_SERVICE"
    } > temp_service.js
    
    mv temp_service.js "$CLIENTS_SERVICE"
    rm temp_methods.txt
    
    echo "✅ Métodos inseridos na linha $BEFORE_LINE"
else
    echo "❌ Não encontrou linha de fechamento };"
fi

echo ""
echo "6. Verificando resultado final..."
echo "Últimas 25 linhas do arquivo:"
tail -25 "$CLIENTS_SERVICE"

echo ""
echo "7. Testando sintaxe JavaScript..."
if command -v node >/dev/null 2>&1; then
    if node -c "$CLIENTS_SERVICE" 2>/dev/null; then
        echo "✅ Sintaxe JavaScript válida"
    else
        echo "❌ Erros de sintaxe encontrados:"
        node -c "$CLIENTS_SERVICE"
    fi
else
    echo "⚠️ Node.js não disponível para verificação"
fi

echo ""
echo "8. Tentando compilação de teste..."
echo "Testando npm start por 10 segundos..."

# Matar qualquer processo npm anterior
pkill -f "npm start" 2>/dev/null || true

# Iniciar npm start em background
npm start > npm_output.log 2>&1 &
NPM_PID=$!

# Aguardar 10 segundos
sleep 10

# Verificar se compilou com sucesso
if grep -q "webpack compiled successfully" npm_output.log; then
    echo "✅ Compilação bem-sucedida!"
elif grep -q "Failed to compile" npm_output.log; then
    echo "❌ Ainda há erros de compilação:"
    grep -A 5 "Failed to compile" npm_output.log
else
    echo "⚠️ Status de compilação incerto"
fi

# Parar processo npm
kill $NPM_PID 2>/dev/null || true
rm -f npm_output.log

echo ""
echo "=== ANÁLISE E CORREÇÃO FINALIZADA ==="
echo ""
echo "Se ainda houver erro, preciso que me envie:"
echo "1. Conteúdo das linhas 185-200 do clientsService.js"
echo "2. Como está a estrutura do objeto (export const/default)"
echo ""
echo "Para ver o conteúdo: sed -n '185,200p' src/services/api/clientsService.js"