import { apiClient } from '../apiClient';
import { ENDPOINTS } from '../endpoints';

export const clientService = {
  // Listar clientes
  async getClients(params = {}) {
    const response = await apiClient.get(ENDPOINTS.CLIENTS.LIST, { params });
    return response.data;
  },

  // Obter cliente por ID
  async getClient(id) {
    const response = await apiClient.get(ENDPOINTS.CLIENTS.SHOW(id));
    return response.data;
  },

  // Criar cliente
  async createClient(clientData) {
    const response = await apiClient.post(ENDPOINTS.CLIENTS.CREATE, clientData);
    return response.data;
  },

  // Atualizar cliente
  async updateClient(id, clientData) {
    const response = await apiClient.put(ENDPOINTS.CLIENTS.UPDATE(id), clientData);
    return response.data;
  },

  // Deletar cliente
  async deleteClient(id) {
    const response = await apiClient.delete(ENDPOINTS.CLIENTS.DELETE(id));
    return response.data;
  },

  // Buscar clientes
  async searchClients(query, filters = {}) {
    const response = await apiClient.get(ENDPOINTS.CLIENTS.SEARCH, {
      params: { q: query, ...filters }
    });
    return response.data;
  },

  // Exportar clientes
  async exportClients(format = 'excel', filters = {}) {
    const response = await apiClient.get(ENDPOINTS.CLIENTS.EXPORT, {
      params: { format, ...filters },
      responseType: 'blob'
    });
    return response.data;
  },

  // Gerenciar acesso ao portal
  async updatePortalAccess(id, accessData) {
    const response = await apiClient.put(ENDPOINTS.CLIENTS.PORTAL_ACCESS(id), accessData);
    return response.data;
  },
};
