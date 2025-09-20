import { apiRequest } from './api';

class ClientsService {
  constructor() {
    this.baseURL = '/clients';
  }

  async getAll() {
    try {
      return await apiRequest('GET', this.baseURL);
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
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
      console.error('Erro ao buscar cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async create(clientData) {
    try {
      return await apiRequest('POST', this.baseURL, clientData);
    } catch (error) {
      console.error('Erro ao criar cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async update(id, clientData) {
    try {
      return await apiRequest('PUT', `${this.baseURL}/${id}`, clientData);
    } catch (error) {
      console.error('Erro ao atualizar cliente:', error);
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
      console.error('Erro ao excluir cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }
}

// Criar instância
const clientsService = new ClientsService();

// Exportar instância como default E como named export
export default clientsService;
export { clientsService };
