import { apiClient } from '../apiClient';
import { ENDPOINTS } from '../endpoints';

export const financialService = {
  // Dashboard financeiro
  async getDashboard(period = 'month') {
    const response = await apiClient.get(ENDPOINTS.FINANCIAL.DASHBOARD, {
      params: { period }
    });
    return response.data;
  },

  // Listar transações
  async getTransactions(params = {}) {
    const response = await apiClient.get(ENDPOINTS.FINANCIAL.TRANSACTIONS, { params });
    return response.data;
  },

  // Criar transação
  async createTransaction(transactionData) {
    const response = await apiClient.post(ENDPOINTS.FINANCIAL.CREATE_TRANSACTION, transactionData);
    return response.data;
  },

  // Atualizar transação
  async updateTransaction(id, transactionData) {
    const response = await apiClient.put(ENDPOINTS.FINANCIAL.UPDATE_TRANSACTION(id), transactionData);
    return response.data;
  },

  // Deletar transação
  async deleteTransaction(id) {
    const response = await apiClient.delete(ENDPOINTS.FINANCIAL.DELETE_TRANSACTION(id));
    return response.data;
  },

  // Relatórios financeiros
  async getReports(type, params = {}) {
    const response = await apiClient.get(ENDPOINTS.FINANCIAL.REPORTS, {
      params: { type, ...params }
    });
    return response.data;
  },

  // Exportar dados financeiros
  async exportData(format = 'excel', filters = {}) {
    const response = await apiClient.get(ENDPOINTS.FINANCIAL.EXPORT, {
      params: { format, ...filters },
      responseType: 'blob'
    });
    return response.data;
  },
};
