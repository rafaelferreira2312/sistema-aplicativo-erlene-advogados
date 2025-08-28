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

  async loginPortal(email, password) {
    try {
      const response = await this.request('/auth/portal/login', {
        method: 'POST',
        auth: false,
        body: JSON.stringify({ 
          email: email,
          password: password 
        })
      });

      if (response.success && response.access_token) {
        this.setToken(response.access_token);
        this.setUser(response.user);
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
      const response = await this.request('/dashboard/stats');
      return response;
    } catch (error) {
      console.error('Dashboard Stats Error:', error);
      throw error;
    }
  }

  // Métodos de teste
  async testConnection() {
    try {
      const response = await this.request('/dashboard/stats', { auth: false });
      return { success: true, data: response };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Gerenciamento de token e usuário
  setToken(token) {
    this.token = token;
    localStorage.setItem('erlene_token', token);
  }

  setUser(user) {
    localStorage.setItem('erlene_user', JSON.stringify(user));
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
}

// Exportar instância singleton
const apiService = new ApiService();
export default apiService;

// Exportar para uso direto
export { apiService };
