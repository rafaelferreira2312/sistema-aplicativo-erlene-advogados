import { apiClient } from '../apiClient';

export const clientsService = {
  // Listar clientes com filtros
  async getClients(params = {}) {
    try {
      const response = await apiClient.get('/admin/clients', { params });
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      throw error;
    }
  },

  // Obter estatísticas de clientes
  async getStats() {
    try {
      const response = await apiClient.get('/admin/clients/stats');
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar estatísticas:', error);
      throw error;
    }
  },

  // Obter cliente por ID
  async getClient(id) {
    try {
      const response = await apiClient.get(`/admin/clients/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar cliente:', error);
      throw error;
    }
  },

  // Criar cliente
  async createClient(clientData) {
    try {
      const response = await apiClient.post('/admin/clients', clientData);
      return response.data;
    } catch (error) {
      console.error('Erro ao criar cliente:', error);
      throw error;
    }
  },

  // Atualizar cliente
  async updateClient(id, clientData) {
    try {
      const response = await apiClient.put(`/admin/clients/${id}`, clientData);
      return response.data;
    } catch (error) {
      console.error('Erro ao atualizar cliente:', error);
      throw error;
    }
  },

  // Deletar cliente
  async deleteClient(id) {
    try {
      const response = await apiClient.delete(`/admin/clients/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao deletar cliente:', error);
      throw error;
    }
  },

  // Buscar CEP via backend
  async buscarCep(cep) {
    try {
      // Limpar CEP antes de enviar
      const cepLimpo = cep.replace(/\D/g, '');
      const response = await apiClient.get(`/admin/clients/buscar-cep/${cepLimpo}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar CEP:', error);
      throw error;
    }
  },

  // Obter responsáveis disponíveis
  async getResponsaveis() {
    try {
      const response = await apiClient.get('/admin/clients/responsaveis');
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar responsáveis:', error);
      throw error;
    }
  },

  // Buscar clientes (para autocomplete)
  async searchClients(query, filters = {}) {
    try {
      const params = { search: query, ...filters };
      const response = await apiClient.get('/admin/clients', { params });
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      throw error;
    }
  },

  // Exportar clientes
  async exportClients(format = 'excel', filters = {}) {
    try {
      const response = await apiClient.get('/admin/clients/export', {
        params: { format, ...filters },
        responseType: 'blob'
      });
      return response.data;
    } catch (error) {
      console.error('Erro ao exportar clientes:', error);
      throw error;
    }
  },

  // Gerenciar acesso ao portal
  async updatePortalAccess(id, accessData) {
    try {
      const response = await apiClient.put(`/admin/clients/${id}/portal-access`, accessData);
      return response.data;
    } catch (error) {
      console.error('Erro ao atualizar acesso portal:', error);
      throw error;
    }
  },

  // Validar CPF/CNPJ
  async validateDocument(document, type, excludeId = null) {
    try {
      const params = { document, type };
      if (excludeId) params.exclude_id = excludeId;
      
      const response = await apiClient.get('/admin/clients/validate-document', { params });
      return response.data;
    } catch (error) {
      console.error('Erro ao validar documento:', error);
      throw error;
    }
  }
};
