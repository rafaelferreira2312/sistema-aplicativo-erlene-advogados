import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

// Instância do axios configurada seguindo padrão do projeto
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  timeout: 30000
});

// Interceptor para adicionar token de autenticação
api.interceptors.request.use(
  (config) => {
    // Buscar token seguindo padrão do sistema
    const token = localStorage.getItem('erlene_token') || 
                  localStorage.getItem('authToken') || 
                  localStorage.getItem('token');
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    console.error('Erro na requisição:', error);
    return Promise.reject(error);
  }
);

// Interceptor para tratamento de respostas
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expirado - redirecionar para login
      localStorage.removeItem('erlene_token');
      localStorage.removeItem('authToken');
      localStorage.removeItem('token');
      localStorage.removeItem('isAuthenticated');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Service de clientes para integração com backend Laravel
export const clientsService = {
  // Listar clientes com filtros
  getClients: async (params = {}) => {
    try {
      const queryParams = new URLSearchParams();
      
      // Parâmetros de paginação
      if (params.page) queryParams.append('page', params.page);
      if (params.per_page) queryParams.append('per_page', params.per_page || 15);
      
      // Filtros
      if (params.tipo_pessoa && params.tipo_pessoa !== 'all') {
        queryParams.append('tipo_pessoa', params.tipo_pessoa);
      }
      if (params.status && params.status !== 'all') {
        queryParams.append('status', params.status);
      }
      if (params.busca && params.busca.trim()) {
        queryParams.append('busca', params.busca.trim());
      }
      
      // Ordenação
      if (params.order_by) queryParams.append('order_by', params.order_by);
      if (params.order_direction) queryParams.append('order_direction', params.order_direction);

      const url = `/admin/clients${queryParams.toString() ? `?${queryParams}` : ''}`;
      const response = await api.get(url);
      
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      throw error;
    }
  },

  // Obter cliente específico
  getClient: async (id) => {
    try {
      const response = await api.get(`/admin/clients/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar cliente:', error);
      throw error;
    }
  },

  // Criar novo cliente
  createClient: async (clientData) => {
    try {
      const response = await api.post('/admin/clients', clientData);
      return response.data;
    } catch (error) {
      console.error('Erro ao criar cliente:', error);
      throw error;
    }
  },

  // Atualizar cliente
  updateClient: async (id, clientData) => {
    try {
      const response = await api.put(`/admin/clients/${id}`, clientData);
      return response.data;
    } catch (error) {
      console.error('Erro ao atualizar cliente:', error);
      throw error;
    }
  },

  // Excluir cliente
  deleteClient: async (id) => {
    try {
      const response = await api.delete(`/admin/clients/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao excluir cliente:', error);
      throw error;
    }
  },

  // Dashboard de clientes
  getDashboard: async () => {
    try {
      const response = await api.get('/admin/clients/dashboard');
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar dashboard:', error);
      throw error;
    }
  },

  // Buscar clientes para select (formato simples)
  getClientsForSelect: async () => {
    try {
      const response = await api.get('/admin/clients/select');
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar clientes para select:', error);
      throw error;
    }
  }
};

// Funções auxiliares para formatação
export const clientUtils = {
  // Formatar documento (CPF/CNPJ)
  formatDocument: (document, type) => {
    if (!document) return '';
    
    const clean = document.replace(/\D/g, '');
    
    if (type === 'PF') {
      // CPF: 000.000.000-00
      return clean.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    } else {
      // CNPJ: 00.000.000/0000-00
      return clean.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
    }
  },

  // Validar documento
  validateDocument: (document, type) => {
    if (!document) return false;
    
    const clean = document.replace(/\D/g, '');
    
    if (type === 'PF') {
      return clean.length === 11;
    } else {
      return clean.length === 14;
    }
  },

  // Formatar telefone
  formatPhone: (phone) => {
    if (!phone) return '';
    
    const clean = phone.replace(/\D/g, '');
    
    if (clean.length === 10) {
      // (00) 0000-0000
      return clean.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
    } else if (clean.length === 11) {
      // (00) 00000-0000
      return clean.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
    }
    
    return phone;
  },

  // Transformar cliente do backend para formato do frontend
  transformClient: (cliente) => ({
    id: cliente.id,
    nome: cliente.nome,
    email: cliente.email,
    telefone: cliente.telefone,
    documento: clientUtils.formatDocument(cliente.cpf_cnpj, cliente.tipo_pessoa),
    cpf_cnpj: cliente.cpf_cnpj,
    tipo_pessoa: cliente.tipo_pessoa,
    endereco: cliente.endereco,
    status: cliente.status,
    createdAt: cliente.created_at,
    updatedAt: cliente.updated_at,
    processos_count: cliente.processos_count || 0,
    atendimentos_count: cliente.atendimentos_count || 0
  })
};

export default clientsService;
