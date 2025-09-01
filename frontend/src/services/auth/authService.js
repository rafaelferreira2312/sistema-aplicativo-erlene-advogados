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
