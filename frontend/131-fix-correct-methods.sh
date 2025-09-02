#!/bin/bash

# Script 131 - Corrigir Métodos com Nomes Corretos
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 131-fix-correct-methods.sh && ./131-fix-correct-methods.sh
# EXECUTE NA PASTA: frontend/

echo "Corrigindo clientsService com nomes corretos dos métodos..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

CLIENTS_SERVICE="src/services/api/clientsService.js"

echo "1. Usando backup limpo anterior para evitar erros de sintaxe..."

# Usar o backup mais recente que funcionava
BACKUP_FILE=$(ls -t "${CLIENTS_SERVICE}.backup-"* | grep -v "methods" | head -1)
if [ -f "$BACKUP_FILE" ]; then
    echo "Restaurando backup: $BACKUP_FILE"
    cp "$BACKUP_FILE" "$CLIENTS_SERVICE"
else
    echo "Nenhum backup encontrado - usando arquivo atual"
fi

echo ""
echo "2. Removendo métodos problemáticos..."
# Limpar arquivo de métodos quebrados
sed -i '/getClientProcessos/,/^}/d' "$CLIENTS_SERVICE" 2>/dev/null || true
sed -i '/getClientDocumentos/,/^}/d' "$CLIENTS_SERVICE" 2>/dev/null || true
sed -i '/getAll/,/^}/d' "$CLIENTS_SERVICE" 2>/dev/null || true
sed -i '/responsaveis()/,/^}/d' "$CLIENTS_SERVICE" 2>/dev/null || true

echo ""
echo "3. Criando arquivo com métodos corretos baseado no frontend..."

cat > "$CLIENTS_SERVICE" << 'EOF'
import apiClient from './apiClient';

export const clientsService = {
  // Buscar todos os clientes (nome correto que frontend usa)
  async getClients(params = {}) {
    try {
      const response = await apiClient.get('/admin/clients', { params });
      return {
        success: true,
        data: response.data.data || response.data,
        pagination: response.data.pagination || null
      };
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar clientes'
      };
    }
  },

  // Criar cliente (nome correto que frontend usa)
  async createClient(data) {
    try {
      const response = await apiClient.post('/admin/clients', data);
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao criar cliente:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao criar cliente',
        errors: error.response?.data?.errors || {}
      };
    }
  },

  // Atualizar cliente (nome correto que frontend usa)
  async updateClient(id, data) {
    try {
      const response = await apiClient.put(`/admin/clients/${id}`, data);
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao atualizar cliente:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao atualizar cliente',
        errors: error.response?.data?.errors || {}
      };
    }
  },

  // Deletar cliente (nome correto que frontend usa)
  async deleteClient(id) {
    try {
      await apiClient.delete(`/admin/clients/${id}`);
      return {
        success: true,
        message: 'Cliente deletado com sucesso'
      };
    } catch (error) {
      console.error('Erro ao deletar cliente:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao deletar cliente'
      };
    }
  },

  // Buscar responsáveis (nome correto que frontend usa)
  async getResponsaveis() {
    try {
      const response = await apiClient.get('/admin/clients/responsaveis');
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar responsáveis:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar responsáveis'
      };
    }
  },

  // Buscar CEP (nome correto que frontend usa)
  async buscarCep(cep) {
    try {
      const response = await apiClient.get(`/admin/clients/buscar-cep/${cep}`);
      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      console.error('Erro ao buscar CEP:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'CEP não encontrado'
      };
    }
  },

  // Obter estatísticas (nome correto que frontend usa)
  async getStats() {
    try {
      const response = await apiClient.get('/admin/clients/stats');
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar estatísticas:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar estatísticas'
      };
    }
  },

  // Validar documento
  async validateDocument(document, type, excludeId = null) {
    try {
      const params = { document, type };
      if (excludeId) params.exclude_id = excludeId;
      
      const response = await apiClient.get('/admin/clients/validate-document', { params });
      return {
        success: true,
        valid: response.data.valid || false
      };
    } catch (error) {
      console.error('Erro ao validar documento:', error);
      return {
        success: false,
        valid: false,
        error: error.response?.data?.message || 'Erro na validação'
      };
    }
  },

  // Obter processos do cliente (novos métodos)
  async getClientProcessos(clienteId) {
    try {
      const response = await apiClient.get(`/admin/clients/${clienteId}/processos`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar processos:', error);
      throw error;
    }
  },

  // Obter documentos do cliente (novos métodos)
  async getClientDocumentos(clienteId) {
    try {
      const response = await apiClient.get(`/admin/clients/${clienteId}/documentos`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar documentos:', error);
      throw error;
    }
  }
};

// Export default para compatibilidade
export default clientsService;
EOF

echo "✅ Arquivo recriado com nomes corretos dos métodos"

echo ""
echo "4. Verificando se apiClient.js existe..."
if [ ! -f "src/services/api/apiClient.js" ]; then
    echo "Criando apiClient.js..."
    cat > src/services/api/apiClient.js << 'EOF'
import axios from 'axios';

const apiClient = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8000/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// Interceptor para token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor para respostas
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default apiClient;
EOF
    echo "✅ apiClient.js criado"
fi

echo ""
echo "5. Testando sintaxe final..."
if node -c "$CLIENTS_SERVICE" 2>/dev/null; then
    echo "✅ Sintaxe JavaScript válida"
else
    echo "❌ Ainda há erros de sintaxe:"
    node -c "$CLIENTS_SERVICE"
fi

echo ""
echo "6. Testando compilação final..."

pkill -f "npm start" 2>/dev/null || true
sleep 2

timeout 15s npm start > final_compile.log 2>&1 &
sleep 15

if grep -q "webpack compiled successfully" final_compile.log; then
    echo "✅ COMPILAÇÃO FUNCIONANDO!"
elif grep -q "Failed to compile" final_compile.log; then
    echo "❌ Erros de compilação:"
    grep -A 10 "Failed to compile" final_compile.log
else
    echo "⚠️ Verificar manualmente"
fi

pkill -f "npm start" 2>/dev/null || true
rm -f final_compile.log

echo ""
echo "=== CORREÇÃO FINAL DOS MÉTODOS ==="
echo ""
echo "MÉTODOS CORRIGIDOS PARA COINCIDIR COM FRONTEND:"
echo "✅ getClients() - buscar clientes"
echo "✅ createClient() - criar cliente"  
echo "✅ updateClient() - atualizar cliente"
echo "✅ deleteClient() - deletar cliente"
echo "✅ getResponsaveis() - buscar responsáveis"
echo "✅ buscarCep() - buscar CEP"
echo "✅ getStats() - estatísticas"
echo "✅ getClientProcessos() - processos do cliente"
echo "✅ getClientDocumentos() - documentos do cliente"
echo ""
echo "TESTE AGORA: npm start"
echo "A tela de clientes deve funcionar sem erros!"