import axios from 'axios';
import { API_CONFIG, HTTP_STATUS } from '../../config/api';

// Criar instância do Axios
const apiClient = axios.create({
  baseURL: API_CONFIG.BASE_URL,
  timeout: API_CONFIG.TIMEOUT,
  headers: API_CONFIG.HEADERS
});

// Interceptor para adicionar token nas requisições
apiClient.interceptors.request.use(
  (config) => {
    // Pegar token do localStorage
    const token = localStorage.getItem('auth_token');
    const portalToken = localStorage.getItem('portal_token');
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    } else if (portalToken) {
      config.headers.Authorization = `Bearer ${portalToken}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor para tratar respostas e erros
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    const originalRequest = error.config;
    
    // Token expirado
    if (error.response?.status === HTTP_STATUS.UNAUTHORIZED && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        // Tentar renovar token
        const refreshToken = localStorage.getItem('refresh_token');
        if (refreshToken) {
          const response = await axios.post(`${API_CONFIG.BASE_URL}/auth/refresh`, {
            refresh_token: refreshToken
          });
          
          const { access_token } = response.data;
          localStorage.setItem('auth_token', access_token);
          
          // Repetir requisição original
          originalRequest.headers.Authorization = `Bearer ${access_token}`;
          return apiClient(originalRequest);
        }
      } catch (refreshError) {
        // Refresh falhou, fazer logout
        localStorage.removeItem('auth_token');
        localStorage.removeItem('refresh_token');
        localStorage.removeItem('portal_token');
        localStorage.removeItem('isAuthenticated');
        localStorage.removeItem('portalAuth');
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }
    
    return Promise.reject(error);
  }
);

export default apiClient;
