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

// Service de processos para integração com backend Laravel
export const processesService = {
  // Listar processos com filtros
  getProcesses: async (params = {}) => {
    try {
      const queryParams = new URLSearchParams();
      
      // Parâmetros de paginação
      if (params.page) queryParams.append('page', params.page);
      if (params.per_page) queryParams.append('per_page', params.per_page || 15);
      
      // Filtros
      if (params.status && params.status !== 'all') {
        queryParams.append('status', params.status);
      }
      if (params.advogado_id && params.advogado_id !== 'all') {
        queryParams.append('advogado_id', params.advogado_id);
      }
      if (params.cliente_id && params.cliente_id !== 'all') {
        queryParams.append('cliente_id', params.cliente_id);
      }
      if (params.prioridade && params.prioridade !== 'all') {
        queryParams.append('prioridade', params.prioridade);
      }
      if (params.busca && params.busca.trim()) {
        queryParams.append('busca', params.busca.trim());
      }
      
      // Ordenação
      if (params.order_by) queryParams.append('order_by', params.order_by);
      if (params.order_direction) queryParams.append('order_direction', params.order_direction);

      const url = `/admin/processes${queryParams.toString() ? `?${queryParams}` : ''}`;
      const response = await api.get(url);
      
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar processos:', error);
      throw error;
    }
  },

  // Obter processo específico
  getProcess: async (id) => {
    try {
      const response = await api.get(`/admin/processes/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar processo:', error);
      throw error;
    }
  },

  // Criar novo processo
  createProcess: async (processData) => {
    try {
      const response = await api.post('/admin/processes', processData);
      return response.data;
    } catch (error) {
      console.error('Erro ao criar processo:', error);
      throw error;
    }
  },

  // Atualizar processo
  updateProcess: async (id, processData) => {
    try {
      const response = await api.put(`/admin/processes/${id}`, processData);
      return response.data;
    } catch (error) {
      console.error('Erro ao atualizar processo:', error);
      throw error;
    }
  },

  // Excluir processo
  deleteProcess: async (id) => {
    try {
      const response = await api.delete(`/admin/processes/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao excluir processo:', error);
      throw error;
    }
  },

  // Sincronizar com CNJ DataJud
  syncWithCNJ: async (id) => {
    try {
      const response = await api.post(`/admin/processes/${id}/sync-cnj`);
      return response.data;
    } catch (error) {
      console.error('Erro na sincronização CNJ:', error);
      throw error;
    }
  },

  // Obter movimentações do processo
  getMovements: async (id, page = 1) => {
    try {
      const response = await api.get(`/admin/processes/${id}/movements?page=${page}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar movimentações:', error);
      throw error;
    }
  },

  // Adicionar movimentação manual
  addMovement: async (id, movementData) => {
    try {
      const response = await api.post(`/admin/processes/${id}/movements`, movementData);
      return response.data;
    } catch (error) {
      console.error('Erro ao adicionar movimentação:', error);
      throw error;
    }
  },

  // Obter documentos do processo
  getDocuments: async (id, page = 1) => {
    try {
      const response = await api.get(`/admin/processes/${id}/documents?page=${page}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar documentos:', error);
      throw error;
    }
  },

  // Obter atendimentos do processo
  getAppointments: async (id, page = 1) => {
    try {
      const response = await api.get(`/admin/processes/${id}/appointments?page=${page}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar atendimentos:', error);
      throw error;
    }
  },

  // Dashboard de processos
  getDashboard: async () => {
    try {
      const response = await api.get('/admin/processes/dashboard');
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar dashboard:', error);
      throw error;
    }
  },

  // Sincronização em lote com CNJ
  batchSyncCNJ: async (processIds) => {
    try {
      const response = await api.post('/admin/processes/batch-sync-cnj', {
        processo_ids: processIds
      });
      return response.data;
    } catch (error) {
      console.error('Erro na sincronização em lote:', error);
      throw error;
    }
  }
};

// Funções auxiliares para formatação
export const processUtils = {
  // Mapear status do backend para frontend
  mapStatus: (status) => {
    const statusMap = {
      'distribuido': 'Distribuído',
      'em_andamento': 'Em Andamento', 
      'suspenso': 'Suspenso',
      'arquivado': 'Arquivado',
      'finalizado': 'Concluído'
    };
    return statusMap[status] || status;
  },

  // Mapear prioridade do backend para frontend
  mapPriority: (prioridade) => {
    const priorityMap = {
      'baixa': 'Baixa',
      'media': 'Média',
      'alta': 'Alta', 
      'urgente': 'Urgente'
    };
    return priorityMap[prioridade] || prioridade;
  },

  // Determinar tipo do processo baseado no tribunal
  mapType: (tribunal) => {
    if (!tribunal) return 'Cível';
    
    const tribunalLower = tribunal.toLowerCase();
    if (tribunalLower.includes('trabalho')) return 'Trabalhista';
    if (tribunalLower.includes('família')) return 'Família';
    if (tribunalLower.includes('sucessões')) return 'Sucessões';
    if (tribunalLower.includes('criminal')) return 'Criminal';
    if (tribunalLower.includes('tributário')) return 'Tributário';
    
    return 'Cível';
  },

  // Transformar processo do backend para formato do frontend
  transformProcess: (processo) => ({
    id: processo.id,
    number: processo.numero,
    client: processo.cliente?.nome || 'Cliente não informado',
    clientId: processo.cliente_id,
    clientType: processo.cliente?.tipo_pessoa === 'PF' ? 'PF' : 'PJ',
    subject: processo.tipo_acao,
    type: processUtils.mapType(processo.tribunal),
    status: processUtils.mapStatus(processo.status),
    advogado: processo.advogado?.name || 'Advogado não informado',
    advogadoId: processo.advogado_id,
    court: `${processo.vara || processo.tribunal}`,
    value: parseFloat(processo.valor_causa) || 0,
    createdAt: processo.created_at,
    lastUpdate: processo.updated_at,
    audiencias: 0, // TODO: implementar contagem quando endpoint estiver pronto
    prazos: processo.dias_ate_vencimento || 0,
    documentos: processo.total_documentos || 0,
    syncCNJ: Boolean(processo.precisa_sincronizar_cnj),
    priority: processUtils.mapPriority(processo.prioridade)
  })
};

export default processesService;
