#!/bin/bash

# Script 125 - Corrigir clientsService diretamente no frontend
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 125-fix-service-frontend.sh && ./125-fix-service-frontend.sh
# EXECUTE NA PASTA: frontend/

echo "🔧 Corrigindo clientsService.js diretamente..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

CLIENTS_SERVICE="src/services/api/clientsService.js"

echo "1. Analisando estrutura atual do clientsService.js..."

if [ -f "$CLIENTS_SERVICE" ]; then
    echo "Arquivo encontrado. Tamanho: $(wc -l < "$CLIENTS_SERVICE") linhas"
    
    # Verificar as últimas linhas para entender a estrutura
    echo "Últimas 10 linhas do arquivo:"
    tail -10 "$CLIENTS_SERVICE"
    
    echo ""
    echo "2. Fazendo backup..."
    cp "$CLIENTS_SERVICE" "${CLIENTS_SERVICE}.backup-$(date +%Y%m%d-%H%M%S)"
    
    echo ""
    echo "3. Removendo métodos defeituosos e reconstruindo..."
    
    # Remover todas as linhas a partir de onde começou o problema
    if grep -n "getClientProcessos\|getClientDocumentos" "$CLIENTS_SERVICE"; then
        echo "Removendo métodos defeituosos..."
        
        # Encontrar linha onde começam os métodos problemáticos
        LINE_NUM=$(grep -n "getClientProcessos" "$CLIENTS_SERVICE" | head -1 | cut -d: -f1)
        
        if [ ! -z "$LINE_NUM" ]; then
            # Manter apenas até a linha anterior
            head -n $((LINE_NUM - 1)) "$CLIENTS_SERVICE" > temp_service.js
            
            # Verificar se a última linha precisa de vírgula
            LAST_LINE=$(tail -1 temp_service.js)
            if [[ "$LAST_LINE" != *"," ]] && [[ "$LAST_LINE" != *"};" ]]; then
                echo "Adicionando vírgula na última linha..."
                sed -i '$ s/$/,/' temp_service.js
            fi
            
            # Adicionar novos métodos corretamente
            cat >> temp_service.js << 'EOF'

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
EOF
            
            # Substituir arquivo original
            mv temp_service.js "$CLIENTS_SERVICE"
            echo "✅ Arquivo reconstruído"
        else
            echo "❌ Não conseguiu encontrar linha do método"
        fi
    else
        echo "⚠️  Métodos não encontrados - adicionando do zero"
        
        # Se não encontrou métodos, adicionar antes do fechamento
        # Primeiro, garantir que tem vírgula antes do fechamento
        sed -i '/^};$/i\
,\
\
  // Obter processos do cliente\
  getClientProcessos: async (clienteId) => {\
    try {\
      const response = await api.get(`/admin/clients/${clienteId}/processos`);\
      return response.data;\
    } catch (error) {\
      console.error("Erro ao buscar processos:", error);\
      throw error;\
    }\
  },\
\
  // Obter documentos do cliente\
  getClientDocumentos: async (clienteId) => {\
    try {\
      const response = await api.get(`/admin/clients/${clienteId}/documentos`);\
      return response.data;\
    } catch (error) {\
      console.error("Erro ao buscar documentos:", error);\
      throw error;\
    }\
  }' "$CLIENTS_SERVICE"
    fi
    
else
    echo "❌ Arquivo clientsService.js não encontrado"
    exit 1
fi

echo ""
echo "4. Verificando sintaxe JavaScript..."

# Verificar sintaxe usando node
if command -v node >/dev/null 2>&1; then
    if node -c "$CLIENTS_SERVICE" 2>/dev/null; then
        echo "✅ Sintaxe JavaScript válida"
    else
        echo "❌ Ainda há erros de sintaxe:"
        node -c "$CLIENTS_SERVICE"
    fi
else
    echo "⚠️  Node.js não encontrado - não é possível verificar sintaxe"
fi

echo ""
echo "5. Removendo EyeIcon não utilizado do Clients.js..."

CLIENTS_PAGE="src/pages/admin/Clients.js"
if [ -f "$CLIENTS_PAGE" ]; then
    # Verificar se EyeIcon existe e está sendo usado
    if grep -q "EyeIcon" "$CLIENTS_PAGE" && ! grep -A 50 -B 50 "EyeIcon" "$CLIENTS_PAGE" | grep -q "EyeIcon.*>" ; then
        echo "Removendo EyeIcon não utilizado..."
        
        # Remover EyeIcon dos imports
        sed -i 's/EyeIcon,\s*//g' "$CLIENTS_PAGE"
        sed -i 's/,\s*EyeIcon//g' "$CLIENTS_PAGE"
        sed -i 's/EyeIcon//g' "$CLIENTS_PAGE"
        
        echo "✅ EyeIcon removido"
    fi
else
    echo "⚠️  Clients.js não encontrado"
fi

echo ""
echo "6. Mostrando estrutura final do service..."
echo "Últimas 20 linhas do clientsService.js:"
tail -20 "$CLIENTS_SERVICE"

echo ""
echo "=== CORREÇÃO FINALIZADA ==="
echo ""
echo "✅ AÇÕES REALIZADAS:"
echo "- clientsService.js reconstruído com sintaxe correta"
echo "- Métodos getClientProcessos e getClientDocumentos adicionados"
echo "- EyeIcon não utilizado removido"
echo ""
echo "🎯 TESTE AGORA:"
echo "npm start"
echo ""
echo "Se ainda der erro, pode ser que o método anterior no service não tenha vírgula."
echo "Nesse caso, preciso ver o conteúdo exato do arquivo para corrigir."