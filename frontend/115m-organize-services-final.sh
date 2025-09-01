#!/bin/bash

# Script 115m - Organizar Services Frontend (Versão Final)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115m-organize-services-final.sh && ./115m-organize-services-final.sh
# EXECUTE NA PASTA: frontend/

echo "🔧 ORGANIZANDO SERVICES FRONTEND - VERSÃO FINAL"
echo "=============================================="

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "1. Analisando estrutura atual..."

# Mostrar arquivos de services existentes
echo ""
echo "📁 ESTRUTURA ATUAL:"
find src -name "*.js" -path "*/services/*" 2>/dev/null | head -20 || echo "Nenhum arquivo de service encontrado"

echo ""
echo "2. Fazendo backup dos arquivos existentes..."

# Criar pasta de backup
BACKUP_DIR="backup_services_$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# Fazer backup se existir pasta services
if [ -d "src/services" ]; then
    cp -r src/services $BACKUP_DIR/
    echo "✅ Backup criado em: $BACKUP_DIR"
fi

echo ""
echo "3. Criando estrutura final organizada..."

# Remover estrutura antiga
rm -rf src/services

# Criar estrutura nova e definitiva
mkdir -p src/services/api
mkdir -p src/services/auth
mkdir -p src/utils
mkdir -p src/config

echo "✅ Estrutura de pastas criada"

echo ""
echo "4. Criando apiClient.js DEFINITIVO..."

# Criar apiClient único e definitivo
cat > src/services/api/apiClient.js << 'EOF'
import axios from 'axios';

// Configuração base da API
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

// Criar instância do axios
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Função para obter token (compatibilidade múltipla)
const getAuthToken = () => {
  return localStorage.getItem('authToken') || 
         localStorage.getItem('erlene_token') || 
         localStorage.getItem('token');
};

// Request interceptor - adicionar token automaticamente
apiClient.interceptors.request.use(
  (config) => {
    const token = getAuthToken();
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - tratar erros
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    const { response } = error;
    
    // Token expirado
    if (response?.status === 401) {
      console.warn('Token expirado, redirecionando para login...');
      
      // Limpar autenticação
      localStorage.removeItem('authToken');
      localStorage.removeItem('erlene_token');
      localStorage.removeItem('token');
      localStorage.removeItem('isAuthenticated');
      localStorage.removeItem('portalAuth');
      
      // Redirecionar para login se não estiver na página de login
      if (window.location.pathname !== '/login') {
        window.location.href = '/login';
      }
    }
    
    return Promise.reject(error);
  }
);

export default apiClient;
EOF

echo "✅ apiClient.js criado"

echo ""
echo "5. Criando clientsService.js DEFINITIVO..."

# Criar clientsService único e definitivo
cat > src/services/api/clientsService.js << 'EOF'
import apiClient from './apiClient';

export const clientsService = {
  // Listar clientes com filtros e paginação
  async getClients(params = {}) {
    try {
      const response = await apiClient.get('/admin/clients', { params });
      return {
        success: true,
        data: response.data.data || response.data,
        pagination: response.data.pagination || null,
        total: response.data.total || 0
      };
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar clientes',
        data: []
      };
    }
  },

  // Obter estatísticas de clientes
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
        error: error.response?.data?.message || 'Erro ao buscar estatísticas',
        data: { total: 0, ativos: 0, pf: 0, pj: 0 }
      };
    }
  },

  // Buscar cliente por ID
  async getClient(id) {
    try {
      const response = await apiClient.get(`/admin/clients/${id}`);
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar cliente:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar cliente'
      };
    }
  },

  // Criar novo cliente
  async createClient(clientData) {
    try {
      const response = await apiClient.post('/admin/clients', clientData);
      return {
        success: true,
        data: response.data.data || response.data,
        message: response.data.message || 'Cliente criado com sucesso'
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

  // Atualizar cliente existente
  async updateClient(id, clientData) {
    try {
      const response = await apiClient.put(`/admin/clients/${id}`, clientData);
      return {
        success: true,
        data: response.data.data || response.data,
        message: response.data.message || 'Cliente atualizado com sucesso'
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

  // Excluir cliente
  async deleteClient(id) {
    try {
      const response = await apiClient.delete(`/admin/clients/${id}`);
      return {
        success: true,
        message: response.data.message || 'Cliente excluído com sucesso'
      };
    } catch (error) {
      console.error('Erro ao excluir cliente:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao excluir cliente'
      };
    }
  },

  // Buscar CEP via backend (ViaCEP integrado)
  async buscarCep(cep) {
    try {
      const cepLimpo = cep.replace(/\D/g, '');
      const response = await apiClient.get(`/admin/clients/buscar-cep/${cepLimpo}`);
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar CEP:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'CEP não encontrado'
      };
    }
  },

  // Obter responsáveis disponíveis
  async getResponsaveis() {
    try {
      const response = await apiClient.get('/admin/clients/responsaveis');
      return {
        success: true,
        data: response.data.data || response.data || []
      };
    } catch (error) {
      console.error('Erro ao buscar responsáveis:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar responsáveis',
        data: []
      };
    }
  },

  // Buscar clientes (para autocomplete)
  async searchClients(query, filters = {}) {
    try {
      const params = { search: query, ...filters };
      const response = await apiClient.get('/admin/clients', { params });
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro na busca',
        data: []
      };
    }
  },

  // Validar CPF/CNPJ único
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
  }
};

// Export default também para compatibilidade
export default clientsService;
EOF

echo "✅ clientsService.js criado"

echo ""
echo "6. Criando authService.js simplificado..."

# Criar authService simplificado
cat > src/services/auth/authService.js << 'EOF'
import apiClient from '../api/apiClient';

export const authService = {
  // Login administrativo
  async login(email, password) {
    try {
      const response = await apiClient.post('/auth/login', { 
        email, 
        password 
      });
      
      return {
        success: true,
        data: response.data,
        token: response.data.access_token || response.data.token,
        user: response.data.user
      };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao fazer login'
      };
    }
  },

  // Login do portal do cliente
  async portalLogin(cpf_cnpj, password) {
    try {
      const response = await apiClient.post('/auth/portal/login', { 
        cpf_cnpj, 
        password 
      });
      
      return {
        success: true,
        data: response.data,
        token: response.data.access_token || response.data.token,
        user: response.data.user
      };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao fazer login no portal'
      };
    }
  },

  // Logout
  async logout() {
    try {
      await apiClient.post('/auth/logout');
    } catch (error) {
      console.error('Erro no logout:', error);
    }
  },

  // Obter perfil do usuário
  async getProfile() {
    try {
      const response = await apiClient.get('/auth/me');
      return {
        success: true,
        data: response.data.user || response.data
      };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar perfil'
      };
    }
  }
};

export default authService;
EOF

echo "✅ authService.js criado"

echo ""
echo "7. Verificando se os arquivos foram criados corretamente..."

# Verificar arquivos criados
FILES=(
  "src/services/api/apiClient.js"
  "src/services/api/clientsService.js"
  "src/services/auth/authService.js"
)

echo ""
echo "📄 ARQUIVOS CRIADOS:"
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "✅ $file"
  else
    echo "❌ $file"
  fi
done

echo ""
echo "🎉 ORGANIZAÇÃO CONCLUÍDA!"
echo ""
echo "ESTRUTURA FINAL:"
echo "src/services/"
echo "├── api/"
echo "│   ├── apiClient.js (ÚNICO)"
echo "│   └── clientsService.js (ÚNICO)"
echo "└── auth/"
echo "    └── authService.js (ÚNICO)"
echo ""
echo "✨ PRÓXIMOS PASSOS:"
echo "1. Recarregue o frontend (Ctrl+C e npm start)"
echo "2. Teste a importação: import { clientsService } from './services/api/clientsService';"
echo "3. Verifique se não há mais erros de importação"
echo ""
echo "💾 Backup disponível em: $BACKUP_DIR"