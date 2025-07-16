import { APP_CONFIG } from '../../config/constants';

export const tokenService = {
  // Token de acesso
  getToken: () => {
    return localStorage.getItem(APP_CONFIG.STORAGE_KEYS.TOKEN);
  },

  setToken: (token) => {
    localStorage.setItem(APP_CONFIG.STORAGE_KEYS.TOKEN, token);
  },

  removeToken: () => {
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.TOKEN);
  },

  // Refresh token
  getRefreshToken: () => {
    return localStorage.getItem(APP_CONFIG.STORAGE_KEYS.REFRESH_TOKEN);
  },

  setRefreshToken: (refreshToken) => {
    localStorage.setItem(APP_CONFIG.STORAGE_KEYS.REFRESH_TOKEN, refreshToken);
  },

  removeRefreshToken: () => {
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.REFRESH_TOKEN);
  },

  // Dados do usuário
  getUser: () => {
    const userData = localStorage.getItem(APP_CONFIG.STORAGE_KEYS.USER);
    return userData ? JSON.parse(userData) : null;
  },

  setUser: (user) => {
    localStorage.setItem(APP_CONFIG.STORAGE_KEYS.USER, JSON.stringify(user));
  },

  removeUser: () => {
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.USER);
  },

  // Verificar se o token está expirado
  isTokenExpired: (token) => {
    if (!token) return true;

    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const currentTime = Date.now() / 1000;
      
      return payload.exp < currentTime;
    } catch (error) {
      return true;
    }
  },

  // Limpar todos os dados de autenticação
  clearAll: () => {
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.TOKEN);
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.REFRESH_TOKEN);
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.USER);
  },
};
