import { apiClient } from '../api/apiClient';
import { tokenService } from './tokenService';

export const authService = {
  // Login
  async login(credentials) {
    const response = await apiClient.post('/auth/login', credentials);
    return response.data;
  },

  // Login do portal do cliente
  async portalLogin(credentials) {
    const response = await apiClient.post('/auth/portal/login', credentials);
    return response.data;
  },

  // Logout
  async logout() {
    try {
      await apiClient.post('/auth/logout');
    } catch (error) {
      console.error('Erro no logout:', error);
    }
  },

  // Refresh token
  async refreshToken() {
    const refreshToken = tokenService.getRefreshToken();
    
    if (!refreshToken) {
      throw new Error('Refresh token não encontrado');
    }

    const response = await apiClient.post('/auth/refresh', {
      refresh_token: refreshToken
    });

    return response.data;
  },

  // Validar token
  async validateToken(token) {
    try {
      const response = await apiClient.get('/auth/validate', {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      return response.data.valid;
    } catch (error) {
      return false;
    }
  },

  // Esqueci minha senha
  async forgotPassword(email) {
    const response = await apiClient.post('/auth/forgot-password', { email });
    return response.data;
  },

  // Resetar senha
  async resetPassword(token, password, passwordConfirmation) {
    const response = await apiClient.post('/auth/reset-password', {
      token,
      password,
      password_confirmation: passwordConfirmation
    });
    return response.data;
  },

  // Alterar senha
  async changePassword(currentPassword, newPassword, newPasswordConfirmation) {
    const response = await apiClient.post('/auth/change-password', {
      current_password: currentPassword,
      new_password: newPassword,
      new_password_confirmation: newPasswordConfirmation
    });
    return response.data;
  },

  // Verificar email
  async verifyEmail(token) {
    const response = await apiClient.post('/auth/verify-email', { token });
    return response.data;
  },

  // Reenviar verificação de email
  async resendEmailVerification() {
    const response = await apiClient.post('/auth/resend-email-verification');
    return response.data;
  },

  // Obter perfil do usuário
  async getProfile() {
    const response = await apiClient.get('/auth/profile');
    return response.data;
  },

  // Atualizar perfil
  async updateProfile(profileData) {
    const response = await apiClient.put('/auth/profile', profileData);
    return response.data;
  },

  // Configurar header de autenticação
  setAuthHeader(token) {
    if (token) {
      apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    }
  },

  // Remover header de autenticação
  removeAuthHeader() {
    delete apiClient.defaults.headers.common['Authorization'];
  },
};
