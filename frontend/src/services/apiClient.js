import axios from 'axios';

// Configurações da API
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

// Função para obter token (compatibilidade com múltiplos formatos)
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
    
    if (response?.status === 401) {
      console.warn('Token expirado, limpando autenticação...');
      
      // Limpar tokens mas manter outros dados de layout
      const layoutPreferences = localStorage.getItem('layoutPreferences');
      
      localStorage.clear();
      
      if (layoutPreferences) {
        localStorage.setItem('layoutPreferences', layoutPreferences);
      }
      
      // Redirecionar para login
      window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);

export default apiClient;
