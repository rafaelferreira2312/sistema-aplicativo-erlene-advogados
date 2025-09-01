import axios from 'axios';

// Configuração base da API
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

// Criar instância do axios
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Função para obter token (compatibilidade múltipla)
const getAuthToken = () => {
  return localStorage.getItem('authToken') || 
         localStorage.getItem('erlene_token') || 
         localStorage.getItem('token');
};

// Request interceptor - adicionar token automaticamente
apiClient.interceptors.request.use(
  (config) => {
    const token = getAuthToken();
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - tratar erros
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    const { response } = error;
    
    // Token expirado
    if (response?.status === 401) {
      console.warn('Token expirado, redirecionando para login...');
      
      // Limpar autenticação
      localStorage.removeItem('authToken');
      localStorage.removeItem('erlene_token');
      localStorage.removeItem('token');
      localStorage.removeItem('isAuthenticated');
      localStorage.removeItem('portalAuth');
      
      // Redirecionar para login se não estiver na página de login
      if (window.location.pathname !== '/login') {
        window.location.href = '/login';
      }
    }
    
    return Promise.reject(error);
  }
);

export default apiClient;
