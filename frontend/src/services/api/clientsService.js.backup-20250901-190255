import apiClient from './apiClient';

export const clientsService = {
  // Listar clientes com filtros e paginação
  async getClients(params = {}) {
    try {
      const response = await apiClient.get('/admin/clients', { params });
      return {
        success: true,
        data: response.data.data || response.data,
        pagination: response.data.pagination || null,
        total: response.data.total || 0
      };
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar clientes',
        data: []
      };
    }
  },

  // Obter estatísticas de clientes
  async getStats() {
    try {
      const response = await apiClient.get('/admin/clients/stats');
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar estatísticas:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar estatísticas',
        data: { total: 0, ativos: 0, pf: 0, pj: 0 }
      };
    }
  },

  // Buscar cliente por ID
  async getClient(id) {
    try {
      const response = await apiClient.get(`/admin/clients/${id}`);
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar cliente:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar cliente'
      };
    }
  },

  // Criar novo cliente
  async createClient(clientData) {
    try {
      const response = await apiClient.post('/admin/clients', clientData);
      return {
        success: true,
        data: response.data.data || response.data,
        message: response.data.message || 'Cliente criado com sucesso'
      };
    } catch (error) {
      console.error('Erro ao criar cliente:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao criar cliente',
        errors: error.response?.data?.errors || {}
      };
    }
  },

  // Atualizar cliente existente
  async updateClient(id, clientData) {
    try {
      const response = await apiClient.put(`/admin/clients/${id}`, clientData);
      return {
        success: true,
        data: response.data.data || response.data,
        message: response.data.message || 'Cliente atualizado com sucesso'
      };
    } catch (error) {
      console.error('Erro ao atualizar cliente:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao atualizar cliente',
        errors: error.response?.data?.errors || {}
      };
    }
  },

  // Excluir cliente
  async deleteClient(id) {
    try {
      const response = await apiClient.delete(`/admin/clients/${id}`);
      return {
        success: true,
        message: response.data.message || 'Cliente excluído com sucesso'
      };
    } catch (error) {
      console.error('Erro ao excluir cliente:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao excluir cliente'
      };
    }
  },

  // Buscar CEP via backend (ViaCEP integrado)
  async buscarCep(cep) {
    try {
      const cepLimpo = cep.replace(/\D/g, '');
      const response = await apiClient.get(`/admin/clients/buscar-cep/${cepLimpo}`);
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar CEP:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'CEP não encontrado'
      };
    }
  },

  // Obter responsáveis disponíveis
  async getResponsaveis() {
    try {
      const response = await apiClient.get('/admin/clients/responsaveis');
      return {
        success: true,
        data: response.data.data || response.data || []
      };
    } catch (error) {
      console.error('Erro ao buscar responsáveis:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar responsáveis',
        data: []
      };
    }
  },

  // Buscar clientes (para autocomplete)
  async searchClients(query, filters = {}) {
    try {
      const params = { search: query, ...filters };
      const response = await apiClient.get('/admin/clients', { params });
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro na busca',
        data: []
      };
    }
  },

  // Validar CPF/CNPJ único
  async validateDocument(document, type, excludeId = null) {
    try {
      const params = { document, type };
      if (excludeId) params.exclude_id = excludeId;
      
      const response = await apiClient.get('/admin/clients/validate-document', { params });
      return {
        success: true,
        valid: response.data.valid || false
      };
    } catch (error) {
      console.error('Erro ao validar documento:', error);
      return {
        success: false,
        valid: false,
        error: error.response?.data?.message || 'Erro na validação'
      };
    }
  }
};

// Export default também para compatibilidade
export default clientsService;
