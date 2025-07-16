import axios from 'axios';
import { toast } from 'react-hot-toast';
import { APP_CONFIG } from '../../config/constants';
import { tokenService } from '../auth/tokenService';

// Criar instância do axios
export const apiClient = axios.create({
  baseURL: APP_CONFIG.API_BASE_URL,
  timeout: APP_CONFIG.REQUEST_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Request interceptor - adicionar token automaticamente
apiClient.interceptors.request.use(
  (config) => {
    const token = tokenService.getToken();
    
    if (token && !tokenService.isTokenExpired(token)) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - tratar erros e refresh token
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    const originalRequest = error.config;

    // Token expirado - tentar refresh
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = tokenService.getRefreshToken();
        
        if (refreshToken) {
          const response = await axios.post(`${APP_CONFIG.API_BASE_URL}/auth/refresh`, {
            refresh_token: refreshToken
          });

          const { token: newToken } = response.data;
          
          tokenService.setToken(newToken);
          originalRequest.headers.Authorization = `Bearer ${newToken}`;
          
          return apiClient(originalRequest);
        }
      } catch (refreshError) {
        // Refresh falhou - fazer logout
        tokenService.clearAll();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    // Tratar outros erros
    handleApiError(error);
    
    return Promise.reject(error);
  }
);

// Função para tratar erros da API
const handleApiError = (error) => {
  const { response } = error;
  
  if (!response) {
    toast.error('Erro de conexão. Verifique sua internet.');
    return;
  }

  const { status, data } = response;
  
  switch (status) {
    case 400:
      toast.error(data?.message || 'Dados inválidos');
      break;
    case 401:
      toast.error('Acesso não autorizado');
      break;
    case 403:
      toast.error('Você não tem permissão para esta ação');
      break;
    case 404:
      toast.error('Recurso não encontrado');
      break;
    case 422:
      // Erros de validação
      if (data?.errors) {
        Object.values(data.errors).flat().forEach(error => {
          toast.error(error);
        });
      } else {
        toast.error(data?.message || 'Erro de validação');
      }
      break;
    case 429:
      toast.error('Muitas tentativas. Tente novamente em alguns minutos.');
      break;
    case 500:
      toast.error('Erro interno do servidor');
      break;
    default:
      toast.error(data?.message || 'Erro inesperado');
  }
};

export default apiClient;
