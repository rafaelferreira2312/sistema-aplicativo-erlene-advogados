// API Service principal - compatibilidade com código existente
import { authService } from './auth/authService';
import { clientsService } from './api/clientsService';
import { dashboardService } from './api/dashboardService';
import apiClient from './api/apiClient';

class ApiService {
  constructor() {
    this.client = apiClient;
  }

  // Métodos de autenticação
  async loginAdmin(email, password) {
    try {
      const result = await authService.login(email, password);
      
      if (result.success && result.token) {
        // Salvar token e usuário
        localStorage.setItem('authToken', result.token);
        localStorage.setItem('erlene_token', result.token);
        localStorage.setItem('token', result.token);
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'admin');
        localStorage.setItem('user', JSON.stringify(result.user));
        
        return { 
          success: true, 
          user: result.user,
          access_token: result.token 
        };
      }
      
      return result;
    } catch (error) {
      return { 
        success: false, 
        message: error.message || 'Erro ao fazer login' 
      };
    }
  }

  async loginPortal(cpf_cnpj, password) {
    try {
      const result = await authService.portalLogin(cpf_cnpj, password);
      
      if (result.success && result.token) {
        // Salvar token e usuário do portal
        localStorage.setItem('authToken', result.token);
        localStorage.setItem('erlene_token', result.token);
        localStorage.setItem('token', result.token);
        localStorage.setItem('portalAuth', 'true');
        localStorage.setItem('userType', 'cliente');
        localStorage.setItem('user', JSON.stringify(result.user));
        
        return { 
          success: true, 
          user: result.user,
          access_token: result.token 
        };
      }
      
      return result;
    } catch (error) {
      return { 
        success: false, 
        message: error.message || 'Erro ao fazer login no portal' 
      };
    }
  }

  async logout() {
    try {
      await authService.logout();
    } catch (error) {
      console.error('Erro no logout:', error);
    } finally {
      // Limpar todos os dados de autenticação
      localStorage.removeItem('authToken');
      localStorage.removeItem('erlene_token');
      localStorage.removeItem('token');
      localStorage.removeItem('isAuthenticated');
      localStorage.removeItem('portalAuth');
      localStorage.removeItem('userType');
      localStorage.removeItem('user');
    }
  }

  // Métodos do dashboard
  async getDashboardStats() {
    return await dashboardService.getStats();
  }

  async getDashboardNotifications() {
    return await dashboardService.getNotifications();
  }

  // Método para verificar autenticação
  isAuthenticated() {
    const token = localStorage.getItem('authToken') || 
                  localStorage.getItem('erlene_token') || 
                  localStorage.getItem('token');
    return !!token;
  }

  getUser() {
    const userData = localStorage.getItem('user');
    return userData ? JSON.parse(userData) : null;
  }
}

// Exportar instância singleton
const apiService = new ApiService();
export default apiService;

// Exportar para uso direto
export { apiService };
