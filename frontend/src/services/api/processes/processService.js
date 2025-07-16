import { apiClient } from '../apiClient';
import { ENDPOINTS } from '../endpoints';

export const processService = {
  // Listar processos
  async getProcesses(params = {}) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.LIST, { params });
    return response.data;
  },

  // Obter processo por ID
  async getProcess(id) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.SHOW(id));
    return response.data;
  },

  // Criar processo
  async createProcess(processData) {
    const response = await apiClient.post(ENDPOINTS.PROCESSES.CREATE, processData);
    return response.data;
  },

  // Atualizar processo
  async updateProcess(id, processData) {
    const response = await apiClient.put(ENDPOINTS.PROCESSES.UPDATE(id), processData);
    return response.data;
  },

  // Deletar processo
  async deleteProcess(id) {
    const response = await apiClient.delete(ENDPOINTS.PROCESSES.DELETE(id));
    return response.data;
  },

  // Obter movimentações do processo
  async getProcessMovements(id) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.MOVEMENTS(id));
    return response.data;
  },

  // Sincronizar com tribunal
  async syncWithCourt(id) {
    const response = await apiClient.post(ENDPOINTS.PROCESSES.SYNC_COURT(id));
    return response.data;
  },

  // Buscar processos
  async searchProcesses(query, filters = {}) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.SEARCH, {
      params: { q: query, ...filters }
    });
    return response.data;
  },

  // Exportar processos
  async exportProcesses(format = 'excel', filters = {}) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.EXPORT, {
      params: { format, ...filters },
      responseType: 'blob'
    });
    return response.data;
  },
};
