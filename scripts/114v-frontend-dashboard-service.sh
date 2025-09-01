#!/bin/bash

# Script 114v - Frontend Dashboard Service - Conectar com Backend Real
# Sistema Erlene Advogados - Frontend React
# EXECUTE DENTRO DA PASTA: frontend/
# Comando: chmod +x 114v-frontend-dashboard-service.sh && ./114v-frontend-dashboard-service.sh

echo "React Frontend Dashboard Service - Conectando com dados reais do backend..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "Erro: Execute este script dentro da pasta frontend/"
    echo "Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 114v-frontend-dashboard-service.sh && ./114v-frontend-dashboard-service.sh"
    exit 1
fi

echo "1. Verificando estrutura React..."

# Criar diretório services se não existir
mkdir -p src/services
mkdir -p src/services/api

echo "2. Criando serviço de API atualizado..."

# Criar api.js atualizado
cat > src/services/api.js << 'EOF'
// API Service - Sistema Erlene Advogados
// Serviço para comunicação com o backend Laravel

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

class ApiService {
  constructor() {
    this.baseURL = API_BASE_URL;
    this.token = localStorage.getItem('erlene_token');
  }

  // Headers padrão para requisições
  getHeaders(includeAuth = true) {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    return headers;
  }

  // Método genérico para fazer requisições
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      ...options,
      headers: {
        ...this.getHeaders(options.auth !== false),
        ...(options.headers || {})
      }
    };

    try {
      const response = await fetch(url, config);
      
      // Se resposta não é JSON, retornar texto
      const contentType = response.headers.get('content-type');
      let data;
      
      if (contentType && contentType.includes('application/json')) {
        data = await response.json();
      } else {
        data = { message: await response.text() };
      }

      if (!response.ok) {
        // Se token expirou, limpar autenticação
        if (response.status === 401) {
          this.clearAuth();
          window.location.href = '/login';
        }
        throw new Error(data.message || `HTTP error! status: ${response.status}`);
      }

      return data;
    } catch (error) {
      console.error('API Request Error:', error);
      throw error;
    }
  }

  // Métodos de autenticação
  async loginAdmin(email, password) {
    try {
      const response = await this.request('/auth/login', {
        method: 'POST',
        auth: false,
        body: JSON.stringify({ email, password })
      });

      if (response.success && response.access_token) {
        this.setToken(response.access_token);
        this.setUser(response.user);
        
        // Manter compatibilidade com sistema antigo
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'admin');
        
        return { success: true, user: response.user };
      }

      return response;
    } catch (error) {
      console.error('Login Admin Error:', error);
      return { 
        success: false, 
        message: error.message || 'Erro ao fazer login. Verifique suas credenciais.' 
      };
    }
  }

  async loginPortal(cpf_cnpj, password) {
    try {
      const response = await this.request('/auth/portal/login', {
        method: 'POST',
        auth: false,
        body: JSON.stringify({ 
          cpf_cnpj: cpf_cnpj,
          password: password 
        })
      });

      if (response.success && response.access_token) {
        this.setToken(response.access_token);
        this.setUser(response.user);
        
        // Manter compatibilidade com sistema antigo
        localStorage.setItem('portalAuth', 'true');
        localStorage.setItem('userType', 'cliente');
        
        return { success: true, user: response.user };
      }

      return response;
    } catch (error) {
      console.error('Login Portal Error:', error);
      return { 
        success: false, 
        message: error.message || 'Erro ao fazer login no portal. Verifique suas credenciais.' 
      };
    }
  }

  async logout() {
    try {
      await this.request('/auth/logout', {
        method: 'POST'
      });
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      this.clearAuth();
    }
  }

  async getMe() {
    try {
      const response = await this.request('/auth/me');
      return response;
    } catch (error) {
      console.error('Get Me Error:', error);
      throw error;
    }
  }

  // Métodos de dashboard
  async getDashboardStats() {
    try {
      const response = await this.request('/admin/dashboard');
      return response;
    } catch (error) {
      console.error('Dashboard Stats Error:', error);
      throw error;
    }
  }

  async getDashboardNotifications() {
    try {
      const response = await this.request('/admin/dashboard/notifications');
      return response;
    } catch (error) {
      console.error('Dashboard Notifications Error:', error);
      throw error;
    }
  }

  // Gerenciamento de token e usuário
  setToken(token) {
    this.token = token;
    localStorage.setItem('erlene_token', token);
  }

  setUser(user) {
    localStorage.setItem('erlene_user', JSON.stringify(user));
    // Manter compatibilidade
    localStorage.setItem('user', JSON.stringify(user));
  }

  getUser() {
    const user = localStorage.getItem('erlene_user');
    return user ? JSON.parse(user) : null;
  }

  getToken() {
    return this.token || localStorage.getItem('erlene_token');
  }

  clearAuth() {
    this.token = null;
    localStorage.removeItem('erlene_token');
    localStorage.removeItem('erlene_user');
    // Manter compatibilidade com sistema antigo
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('portalAuth');
    localStorage.removeItem('userType');
    localStorage.removeItem('user');
  }

  isAuthenticated() {
    return !!this.getToken();
  }

  // Método para teste de conexão
  async testConnection() {
    try {
      const response = await this.request('/admin/dashboard', { 
        method: 'GET'
      });
      return { success: true, data: response };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}

// Exportar instância singleton
const apiService = new ApiService();
export default apiService;

// Exportar para uso direto
export { apiService };
EOF

echo "3. Criando serviço específico para Dashboard..."

# Criar dashboardService.js
cat > src/services/api/dashboardService.js << 'EOF'
// Dashboard Service - Sistema Erlene Advogados
// Serviço específico para dados do dashboard administrativo

import apiService from '../api';

class DashboardService {
  constructor() {
    this.api = apiService;
  }

  /**
   * Buscar dados completos do dashboard
   */
  async getDashboardData() {
    try {
      console.log('Buscando dados do dashboard...');
      
      const response = await this.api.getDashboardStats();
      
      if (response.success) {
        console.log('Dados do dashboard carregados:', response.data);
        return {
          success: true,
          data: this.formatDashboardData(response.data)
        };
      }
      
      return {
        success: false,
        message: response.message || 'Erro ao carregar dados do dashboard'
      };
      
    } catch (error) {
      console.error('Erro no DashboardService:', error);
      return {
        success: false,
        message: error.message || 'Erro de conexão com o servidor'
      };
    }
  }

  /**
   * Buscar notificações do dashboard
   */
  async getNotifications() {
    try {
      console.log('Buscando notificações...');
      
      const response = await this.api.getDashboardNotifications();
      
      if (response.success) {
        return {
          success: true,
          data: response.data || []
        };
      }
      
      return {
        success: false,
        message: response.message || 'Erro ao carregar notificações',
        data: []
      };
      
    } catch (error) {
      console.error('Erro ao buscar notificações:', error);
      return {
        success: false,
        message: error.message || 'Erro de conexão',
        data: []
      };
    }
  }

  /**
   * Formatar dados do dashboard vindos da API
   */
  formatDashboardData(data) {
    try {
      return {
        // Estatísticas principais
        stats: {
          clientes: {
            total: data.stats?.clientes?.total || 0,
            ativos: data.stats?.clientes?.ativos || 0,
            novos_mes: data.stats?.clientes?.novos_mes || 0
          },
          processos: {
            total: data.stats?.processos?.total || 0,
            ativos: data.stats?.processos?.ativos || 0,
            urgentes: data.stats?.processos?.urgentes || 0,
            prazos_vencendo: data.stats?.processos?.prazos_vencendo || 0
          },
          atendimentos: {
            hoje: data.stats?.atendimentos?.hoje || 0,
            semana: data.stats?.atendimentos?.semana || 0,
            agendados: data.stats?.atendimentos?.agendados || 0
          },
          financeiro: {
            receita_mes: this.formatCurrency(data.stats?.financeiro?.receita_mes || 0),
            receita_mes_valor: data.stats?.financeiro?.receita_mes || 0,
            pendente: this.formatCurrency(data.stats?.financeiro?.pendente || 0),
            pendente_valor: data.stats?.financeiro?.pendente || 0,
            vencidos: this.formatCurrency(data.stats?.financeiro?.vencidos || 0),
            vencidos_valor: data.stats?.financeiro?.vencidos || 0
          },
          tarefas: {
            pendentes: data.stats?.tarefas?.pendentes || 0,
            vencidas: data.stats?.tarefas?.vencidas || 0
          }
        },
        
        // Dados para gráficos
        graficos: {
          atendimentos: data.graficos?.atendimentos || [],
          receitas: data.graficos?.receitas?.map(item => ({
            ...item,
            receita_formatada: this.formatCurrency(item.receita)
          })) || []
        },
        
        // Listas para widgets
        listas: {
          proximos_atendimentos: data.listas?.proximos_atendimentos || [],
          processos_urgentes: data.listas?.processos_urgentes || [],
          tarefas_pendentes: data.listas?.tarefas_pendentes || []
        }
      };
    } catch (error) {
      console.error('Erro ao formatar dados do dashboard:', error);
      return this.getEmptyDashboardData();
    }
  }

  /**
   * Formatar valores monetários
   */
  formatCurrency(value) {
    try {
      const numberValue = parseFloat(value) || 0;
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
      }).format(numberValue);
    } catch (error) {
      return 'R$ 0,00';
    }
  }

  /**
   * Retornar estrutura vazia em caso de erro
   */
  getEmptyDashboardData() {
    return {
      stats: {
        clientes: { total: 0, ativos: 0, novos_mes: 0 },
        processos: { total: 0, ativos: 0, urgentes: 0, prazos_vencendo: 0 },
        atendimentos: { hoje: 0, semana: 0, agendados: 0 },
        financeiro: { 
          receita_mes: 'R$ 0,00', receita_mes_valor: 0,
          pendente: 'R$ 0,00', pendente_valor: 0,
          vencidos: 'R$ 0,00', vencidos_valor: 0
        },
        tarefas: { pendentes: 0, vencidas: 0 }
      },
      graficos: {
        atendimentos: [],
        receitas: []
      },
      listas: {
        proximos_atendimentos: [],
        processos_urgentes: [],
        tarefas_pendentes: []
      }
    };
  }

  /**
   * Calcular mudanças percentuais (para implementar futuramente)
   */
  calculatePercentageChange(current, previous) {
    if (!previous || previous === 0) return 0;
    return Math.round(((current - previous) / previous) * 100);
  }

  /**
   * Verificar se dados estão atualizados (cache simples)
   */
  isDataFresh(timestamp, maxAge = 5 * 60 * 1000) { // 5 minutos
    if (!timestamp) return false;
    return (Date.now() - timestamp) < maxAge;
  }

  /**
   * Cache simples para dados do dashboard
   */
  getCachedData() {
    try {
      const cached = localStorage.getItem('dashboard_cache');
      if (!cached) return null;
      
      const data = JSON.parse(cached);
      if (this.isDataFresh(data.timestamp)) {
        return data.data;
      }
      
      // Limpar cache expirado
      localStorage.removeItem('dashboard_cache');
      return null;
    } catch (error) {
      console.error('Erro ao acessar cache:', error);
      return null;
    }
  }

  setCachedData(data) {
    try {
      const cacheData = {
        data: data,
        timestamp: Date.now()
      };
      localStorage.setItem('dashboard_cache', JSON.stringify(cacheData));
    } catch (error) {
      console.error('Erro ao salvar cache:', error);
    }
  }

  /**
   * Buscar dados com cache
   */
  async getDashboardDataWithCache(useCache = true) {
    // Tentar usar cache primeiro
    if (useCache) {
      const cachedData = this.getCachedData();
      if (cachedData) {
        console.log('Usando dados do cache');
        return { success: true, data: cachedData, fromCache: true };
      }
    }

    // Buscar dados novos
    const result = await this.getDashboardData();
    
    // Salvar no cache se bem-sucedido
    if (result.success) {
      this.setCachedData(result.data);
    }
    
    return { ...result, fromCache: false };
  }
}

// Exportar instância singleton
const dashboardService = new DashboardService();
export default dashboardService;

// Exportar para uso direto
export { dashboardService };
EOF

echo "4. Atualizando página Dashboard para usar dados reais..."

# Fazer backup do Dashboard atual se existir
if [ -f "src/pages/admin/Dashboard/index.js" ]; then
    cp src/pages/admin/Dashboard/index.js src/pages/admin/Dashboard/index.js.backup
    echo "Backup do Dashboard atual criado"
elif [ -f "src/pages/admin/Dashboard.js" ]; then
    cp src/pages/admin/Dashboard.js src/pages/admin/Dashboard.js.backup
    echo "Backup do Dashboard atual criado"
fi

echo "5. Verificando estrutura do Dashboard existente..."

# Verificar qual estrutura usar
DASHBOARD_PATH=""
if [ -f "src/pages/admin/Dashboard/index.js" ]; then
    DASHBOARD_PATH="src/pages/admin/Dashboard/index.js"
elif [ -f "src/pages/admin/Dashboard.js" ]; then
    DASHBOARD_PATH="src/pages/admin/Dashboard.js"
else
    echo "Dashboard não encontrado, criando estrutura..."
    mkdir -p src/pages/admin/Dashboard
    DASHBOARD_PATH="src/pages/admin/Dashboard/index.js"
fi

echo "Dashboard será atualizado em: $DASHBOARD_PATH"