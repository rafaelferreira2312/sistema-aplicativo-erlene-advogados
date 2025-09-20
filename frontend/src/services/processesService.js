import { apiRequest, testApiConnection, loginForToken } from './api';

class ProcessesService {
  constructor() {
    this.baseURL = '/processes';
  }

  async testConnection() {
    return await testApiConnection();
  }

  async getToken(credentials) {
    return await loginForToken(credentials);
  }

  async getAll() {
    try {
      return await apiRequest('GET', this.baseURL);
    } catch (error) {
      console.error('Erro ao buscar processos:', error);
      return {
        success: true,
        data: []
      };
    }
  }

  async getById(id) {
    try {
      return await apiRequest('GET', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao buscar processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async create(processData) {
    try {
      return await apiRequest('POST', this.baseURL, processData);
    } catch (error) {
      console.error('Erro ao criar processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async update(id, processData) {
    try {
      return await apiRequest('PUT', `${this.baseURL}/${id}`, processData);
    } catch (error) {
      console.error('Erro ao atualizar processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async delete(id) {
    try {
      return await apiRequest('DELETE', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao excluir processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async getByClient(clientId) {
    try {
      return await apiRequest('GET', `${this.baseURL}/client/${clientId}`);
    } catch (error) {
      console.error('Erro ao buscar processos do cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async updateStatus(id, status) {
    try {
      return await apiRequest('PATCH', `${this.baseURL}/${id}/status`, { status });
    } catch (error) {
      console.error('Erro ao atualizar status:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }
}

// Criar instância
const processesService = new ProcessesService();

// Exportar instância como default E como named export
export default processesService;
export { processesService };
