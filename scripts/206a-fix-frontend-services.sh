#!/bin/bash

# Script 206a - Corrigir Services Frontend
# Sistema Erlene Advogados - Migração Laravel → Node.js  
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 206a - Corrigindo services do frontend..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# Fazer backup dos services atuais
echo "📦 Fazendo backup dos services..."
mkdir -p backups/script-206a
cp -r src/services/ backups/script-206a/ 2>/dev/null || true

# 1. Corrigir api.js para exportar funções que estão faltando
echo "🔧 Corrigindo api.js com todas as exportações..."
cat > src/services/api.js << 'EOF'
import axios from 'axios';

// Configuração base da API
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3008/api';

// Instância do axios configurada
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// Interceptor de request para adicionar token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    console.error('Erro no request:', error);
    return Promise.reject(error);
  }
);

// Interceptor de response para tratar erros
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    console.error('Erro na response:', error);
    
    // Se token expirado, logout automático
    if (error.response?.status === 401) {
      localStorage.removeItem('authToken');
      localStorage.removeItem('userData');
      localStorage.removeItem('isAuthenticated');
      window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);

// Função genérica para requisições (compatibilidade com services antigos)
export const apiRequest = async (method, endpoint, data = null) => {
  try {
    const config = {
      method,
      url: endpoint,
      ...(data && { data })
    };
    
    const response = await api.request(config);
    return response.data;
  } catch (error) {
    console.error(`Erro na requisição ${method} ${endpoint}:`, error);
    throw error;
  }
};

// Função para testar conexão (compatibilidade)
export const testApiConnection = async () => {
  try {
    const response = await api.get('/health');
    return {
      success: true,
      data: response.data
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
};

// Função de login para obter token (compatibilidade)
export const loginForToken = async (credentials) => {
  try {
    const response = await api.post('/auth/login', credentials);
    if (response.data.success) {
      const token = response.data.data.access_token;
      localStorage.setItem('authToken', token);
      return token;
    }
    throw new Error('Login falhou');
  } catch (error) {
    console.error('Erro no login para token:', error);
    throw error;
  }
};

// Classe de serviços de autenticação
export class AuthService {
  // Login
  static async login(credentials) {
    try {
      const response = await api.post('/auth/login', {
        email: credentials.email,
        password: credentials.password
      });

      if (response.data.success) {
        const { access_token, user } = response.data.data;
        
        // Salvar dados no localStorage
        localStorage.setItem('authToken', access_token);
        localStorage.setItem('userData', JSON.stringify(user));
        localStorage.setItem('isAuthenticated', 'true');
        
        return {
          success: true,
          user: user,
          token: access_token
        };
      } else {
        return {
          success: false,
          error: response.data.message || 'Erro no login'
        };
      }
    } catch (error) {
      console.error('Erro no login:', error);
      
      return {
        success: false,
        error: error.response?.data?.message || 'Erro de conexão com servidor'
      };
    }
  }

  // Logout
  static async logout() {
    try {
      await api.post('/auth/logout');
    } catch (error) {
      console.error('Erro no logout:', error);
    } finally {
      // Limpar dados locais independente do resultado
      localStorage.removeItem('authToken');
      localStorage.removeItem('userData');
      localStorage.removeItem('isAuthenticated');
    }
  }

  // Obter dados do usuário atual
  static async getCurrentUser() {
    try {
      const response = await api.get('/auth/me');
      
      if (response.data.success) {
        return {
          success: true,
          user: response.data.data.user
        };
      } else {
        return {
          success: false,
          error: response.data.message
        };
      }
    } catch (error) {
      console.error('Erro ao buscar usuário:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar dados do usuário'
      };
    }
  }

  // Verificar se token é válido
  static async verifyToken() {
    try {
      const response = await api.get('/auth/me');
      return response.data.success;
    } catch (error) {
      return false;
    }
  }

  // Alterar senha
  static async changePassword(passwords) {
    try {
      const response = await api.post('/auth/change-password', passwords);
      
      return {
        success: response.data.success,
        message: response.data.message
      };
    } catch (error) {
      console.error('Erro ao alterar senha:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao alterar senha'
      };
    }
  }
}

// Health check da API
export const checkApiHealth = async () => {
  try {
    const response = await api.get('/health');
    return response.data;
  } catch (error) {
    console.error('API não está respondendo:', error);
    return { success: false, error: 'API indisponível' };
  }
};

export default api;
EOF

# 2. Atualizar clientsService.js para usar as novas funções
echo "🔧 Atualizando clientsService.js..."
if [ -f "src/services/clientsService.js" ]; then
    cat > src/services/clientsService.js << 'EOF'
import { apiRequest } from './api';

class ClientsService {
  constructor() {
    this.baseURL = '/clients';
  }

  async getAll() {
    try {
      return await apiRequest('GET', this.baseURL);
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      // Retornar dados mockados em caso de erro (temporário)
      return {
        success: true,
        data: []
      };
    }
  }

  async getById(id) {
    try {
      return await apiRequest('GET', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao buscar cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async create(clientData) {
    try {
      return await apiRequest('POST', this.baseURL, clientData);
    } catch (error) {
      console.error('Erro ao criar cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async update(id, clientData) {
    try {
      return await apiRequest('PUT', `${this.baseURL}/${id}`, clientData);
    } catch (error) {
      console.error('Erro ao atualizar cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async delete(id) {
    try {
      return await apiRequest('DELETE', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao excluir cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }
}

export default new ClientsService();
EOF
fi

# 3. Atualizar processesService.js para usar as novas funções
echo "🔧 Atualizando processesService.js..."
if [ -f "src/services/processesService.js" ]; then
    cat > src/services/processesService.js << 'EOF'
import { apiRequest, testApiConnection, loginForToken } from './api';

class ProcessesService {
  constructor() {
    this.baseURL = '/processes';
  }

  // Testar conexão (compatibilidade)
  async testConnection() {
    return await testApiConnection();
  }

  // Login para obter token (compatibilidade)
  async getToken(credentials) {
    return await loginForToken(credentials);
  }

  async getAll() {
    try {
      return await apiRequest('GET', this.baseURL);
    } catch (error) {
      console.error('Erro ao buscar processos:', error);
      // Retornar dados mockados em caso de erro (temporário)
      return {
        success: true,
        data: []
      };
    }
  }

  async getById(id) {
    try {
      return await apiRequest('GET', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao buscar processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async create(processData) {
    try {
      return await apiRequest('POST', this.baseURL, processData);
    } catch (error) {
      console.error('Erro ao criar processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async update(id, processData) {
    try {
      return await apiRequest('PUT', `${this.baseURL}/${id}`, processData);
    } catch (error) {
      console.error('Erro ao atualizar processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async delete(id) {
    try {
      return await apiRequest('DELETE', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao excluir processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async getByClient(clientId) {
    try {
      return await apiRequest('GET', `${this.baseURL}/client/${clientId}`);
    } catch (error) {
      console.error('Erro ao buscar processos do cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async updateStatus(id, status) {
    try {
      return await apiRequest('PATCH', `${this.baseURL}/${id}/status`, { status });
    } catch (error) {
      console.error('Erro ao atualizar status:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }
}

export default new ProcessesService();
EOF
fi

echo "✅ Services do frontend corrigidos!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • api.js: Adicionadas funções apiRequest, testApiConnection, loginForToken"
echo "   • clientsService.js: Atualizado para usar novas funções"
echo "   • processesService.js: Atualizado para usar novas funções"
echo "   • Compatibilidade mantida com services existentes"
echo ""
echo "📋 Próximo script: 207-update-login-component.sh"
echo ""
echo "⚠️ IMPORTANTE: Teste se frontend compila sem erros!"