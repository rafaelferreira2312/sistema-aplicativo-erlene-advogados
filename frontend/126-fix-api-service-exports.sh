#!/bin/bash

# Script 126 - Corrigir API Service Exports/Imports
# Sistema Erlene Advogados - Resolver erro de export default não encontrado
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 126 - Corrigindo API Service Exports/Imports..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 126-fix-api-service-exports.sh && ./126-fix-api-service-exports.sh"
    exit 1
fi

echo "1️⃣ DIAGNÓSTICO DO PROBLEMA:"
echo "   • Erro: export 'default' (imported as 'apiService') was not found"
echo "   • Causa: api.js só tem exports nomeados, falta export default"
echo "   • Arquivos afetados: Login/index.js e PortalLogin.js"
echo "   • Solução: Criar api.js com export default correto"

echo ""
echo "2️⃣ Fazendo backup dos arquivos atuais..."

# Backup dos arquivos existentes
cp src/services/api.js src/services/api.js.backup-126 2>/dev/null || echo "   • api.js será criado do zero"
cp src/pages/auth/Login/index.js src/pages/auth/Login/index.js.backup-126 2>/dev/null || echo "   • Login/index.js será criado"
cp src/pages/portal/PortalLogin.js src/pages/portal/PortalLogin.js.backup-126 2>/dev/null || echo "   • PortalLogin.js será criado"

echo ""
echo "3️⃣ Criando estrutura de diretórios..."

# Criar diretórios necessários
mkdir -p src/services
mkdir -p src/pages/auth/Login
mkdir -p src/pages/portal

echo ""
echo "4️⃣ Criando api.js com export default e métodos completos..."

cat > src/services/api.js << 'EOF'
// API Service - Sistema Erlene Advogados
// Serviço principal para comunicação com backend Laravel

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

class ApiService {
  constructor() {
    this.token = null;
    this.baseURL = API_BASE_URL;
  }

  // Obter token do localStorage
  getToken() {
    if (this.token) return this.token;
    
    const possibleKeys = ['token', 'auth_token', 'access_token', 'jwt_token', 'erlene_token'];
    
    for (const key of possibleKeys) {
      const token = localStorage.getItem(key);
      if (token) {
        console.log(`Token encontrado na chave: ${key}`);
        this.token = token;
        return token;
      }
    }
    
    return null;
  }

  // Salvar token no localStorage
  setToken(token) {
    this.token = token;
    localStorage.setItem('token', token);
    localStorage.setItem('erlene_token', token);
  }

  // Limpar autenticação
  clearAuth() {
    this.token = null;
    localStorage.clear();
  }

  // Verificar se está autenticado
  isAuthenticated() {
    return !!this.getToken();
  }

  // Fazer requisição HTTP genérica
  async request(endpoint, options = {}) {
    try {
      const token = this.getToken();
      
      const config = {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...(token && { 'Authorization': `Bearer ${token}` }),
          ...(options.headers || {})
        },
        ...options
      };

      const url = `${this.baseURL}${endpoint}`;
      console.log('🌐 API Request:', { url, method: config.method, hasToken: !!token });

      const response = await fetch(url, config);
      
      if (!response.ok) {
        if (response.status === 401) {
          console.error('❌ Token inválido - limpando autenticação');
          this.clearAuth();
          throw new Error('Token inválido. Faça login novamente.');
        }
        
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log('✅ API Response:', data);
      
      return data;
    } catch (error) {
      console.error('💥 API Request Error:', error);
      throw error;
    }
  }

  // Login administrativo (admin/advogados)
  async loginAdmin(email, password) {
    try {
      console.log('🔐 Login admin:', { email });
      
      const response = await this.request('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password })
      });

      if (response.token || response.access_token) {
        const token = response.token || response.access_token;
        this.setToken(token);
        
        if (response.user) {
          localStorage.setItem('user', JSON.stringify(response.user));
        }
        
        return {
          success: true,
          user: response.user,
          token: token,
          message: 'Login realizado com sucesso'
        };
      }

      return {
        success: false,
        message: response.message || 'Credenciais inválidas'
      };

    } catch (error) {
      console.error('💥 Erro login admin:', error);
      return {
        success: false,
        message: error.message || 'Erro ao fazer login'
      };
    }
  }

  // Login do portal (clientes)
  async loginPortal(email, password) {
    try {
      console.log('🔐 Login portal:', { email });
      
      // Tentar endpoint específico do portal primeiro
      let response;
      try {
        response = await this.request('/auth/portal/login', {
          method: 'POST',
          body: JSON.stringify({ email, password })
        });
      } catch (portalError) {
        // Se endpoint do portal não existir, usar login normal
        console.log('⚠️ Usando endpoint de login normal...');
        response = await this.request('/auth/login', {
          method: 'POST',
          body: JSON.stringify({ email, password })
        });
      }

      if (response.token || response.access_token) {
        const token = response.token || response.access_token;
        this.setToken(token);
        
        if (response.user) {
          localStorage.setItem('user', JSON.stringify(response.user));
        }
        
        return {
          success: true,
          user: response.user,
          token: token,
          message: 'Login realizado com sucesso'
        };
      }

      return {
        success: false,
        message: response.message || 'Credenciais inválidas'
      };

    } catch (error) {
      console.error('💥 Erro login portal:', error);
      return {
        success: false,
        message: error.message || 'Erro ao fazer login'
      };
    }
  }

  // Logout
  async logout() {
    try {
      await this.request('/auth/logout', { method: 'POST' });
    } catch (error) {
      console.error('Erro no logout:', error);
    } finally {
      this.clearAuth();
    }
  }

  // Teste de saúde da API
  async testApiConnection() {
    try {
      const response = await fetch(`${this.baseURL}/health`);
      if (response.ok) {
        const data = await response.json();
        console.log('✅ API Health Check:', data);
        return true;
      }
      return false;
    } catch (error) {
      console.error('❌ API Health Check Failed:', error);
      return false;
    }
  }

  // Login automático para obter token
  async loginForToken() {
    try {
      console.log('🔄 Login automático...');
      
      const result = await this.loginAdmin('admin@erlene.com', '123456');
      
      if (result.success) {
        console.log('✅ Login automático realizado');
        return result.token;
      }
      return null;
    } catch (error) {
      console.error('💥 Erro login automático:', error);
      return null;
    }
  }

  // Buscar dados do dashboard
  async getDashboardStats() {
    try {
      const response = await this.request('/admin/dashboard');
      return response;
    } catch (error) {
      console.error('Erro ao buscar dashboard:', error);
      throw error;
    }
  }

  // Buscar processos
  async getProcesses(params = {}) {
    try {
      const queryString = new URLSearchParams(params).toString();
      const url = queryString ? `/admin/processes?${queryString}` : '/admin/processes';
      
      const response = await this.request(url);
      return response;
    } catch (error) {
      console.error('Erro ao buscar processos:', error);
      throw error;
    }
  }

  // Buscar clientes
  async getClients(params = {}) {
    try {
      const queryString = new URLSearchParams(params).toString();
      const url = queryString ? `/admin/clients?${queryString}` : '/admin/clients';
      
      const response = await this.request(url);
      return response;
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      throw error;
    }
  }
}

// Criar instância singleton
const apiService = new ApiService();

// Export default (PRINCIPAL - resolve o erro de import)
export default apiService;

// Exports nomeados para compatibilidade com código anterior
export const apiRequest = apiService.request.bind(apiService);
export const testApiConnection = apiService.testApiConnection.bind(apiService);
export const loginForToken = apiService.loginForToken.bind(apiService);
export { apiService };
EOF

echo ""
echo "✅ SCRIPT 126 CONCLUÍDO!"
echo ""
echo "📋 O que foi criado:"
echo "   • src/services/api.js com export default apiService"
echo "   • Classe ApiService completa com todos os métodos"
echo "   • Compatibilidade com imports existentes"
echo "   • Métodos de login admin e portal"
echo "   • Sistema de token automático"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. npm start (dentro da pasta frontend)"
echo "   2. O erro de export 'default' deve desaparecer"
echo "   3. Verifique no console se não há erros de compilação"
echo ""
echo "✋ AGUARDANDO SUA CONFIRMAÇÃO para continuar com o próximo script..."