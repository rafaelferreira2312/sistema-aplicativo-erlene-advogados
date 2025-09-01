import apiClient from './apiClient';
import { API_ENDPOINTS } from '../../config/api';

export const authService = {
  // Login administrativo
  async login(credentials) {
    try {
      const response = await apiClient.post(API_ENDPOINTS.AUTH.LOGIN, credentials);
      const { access_token, refresh_token, user } = response.data;
      
      // Salvar tokens
      localStorage.setItem('auth_token', access_token);
      localStorage.setItem('refresh_token', refresh_token);
      localStorage.setItem('isAuthenticated', 'true');
      localStorage.setItem('userType', 'admin');
      localStorage.setItem('user', JSON.stringify(user));
      
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  },

  // Login do portal
  async portalLogin(credentials) {
    try {
      const response = await apiClient.post(API_ENDPOINTS.AUTH.PORTAL_LOGIN, credentials);
      const { access_token, user } = response.data;
      
      // Salvar tokens
      localStorage.setItem('portal_token', access_token);
      localStorage.setItem('portalAuth', 'true');
      localStorage.setItem('userType', 'cliente');
      localStorage.setItem('user', JSON.stringify(user));
      
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  },

  // Logout
  async logout() {
    try {
      await apiClient.post(API_ENDPOINTS.AUTH.LOGOUT);
    } catch (error) {
      console.error('Erro no logout:', error);
    } finally {
      // Limpar localStorage
      localStorage.removeItem('auth_token');
      localStorage.removeItem('refresh_token');
      localStorage.removeItem('portal_token');
      localStorage.removeItem('isAuthenticated');
      localStorage.removeItem('portalAuth');
      localStorage.removeItem('userType');
      localStorage.removeItem('user');
    }
  },

  // Obter dados do usuário
  async getMe() {
    try {
      const response = await apiClient.get(API_ENDPOINTS.AUTH.ME);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  },

  // Verificar se está logado
  isAuthenticated() {
    const token = localStorage.getItem('auth_token');
    const portalToken = localStorage.getItem('portal_token');
    return !!(token || portalToken);
  },

  // Obter usuário do localStorage
  getCurrentUser() {
    try {
      const userData = localStorage.getItem('user');
      return userData ? JSON.parse(userData) : null;
    } catch (error) {
      return null;
    }
  },

  // Tratar erros
  handleError(error) {
    const message = error.response?.data?.message || 
                   error.response?.data?.error || 
                   error.message || 
                   'Erro desconhecido';
    
    const status = error.response?.status;
    const errors = error.response?.data?.errors;
    
    return {
      message,
      status,
      errors,
      originalError: error
    };
  }
};

export default authService;
