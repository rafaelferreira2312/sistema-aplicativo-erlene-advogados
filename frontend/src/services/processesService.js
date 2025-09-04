import { apiRequest, testApiConnection, loginForToken } from './api';

export const processesService = {
  // Listar processos
  async getProcesses(params = {}) {
    try {
      console.log('🔍 Carregando processos com params:', params);
      
      // Testar conexão da API primeiro
      const apiHealthy = await testApiConnection();
      if (!apiHealthy) {
        throw new Error('API não está respondendo. Verifique se o backend está executando.');
      }

      // Tentar fazer a requisição
      const queryString = new URLSearchParams(params).toString();
      const url = queryString ? `/admin/processes?${queryString}` : '/admin/processes';
      
      try {
        const response = await apiRequest(url);
        console.log('✅ Processos carregados:', response);
        return response;
      } catch (error) {
        // Se erro 401, tentar login automático
        if (error.message.includes('401') || error.message.includes('Token inválido')) {
          console.log('🔐 Tentando login automático devido a erro 401...');
          const token = await loginForToken();
          
          if (token) {
            // Tentar novamente com o novo token
            const response = await apiRequest(url);
            console.log('✅ Processos carregados após login:', response);
            return response;
          }
        }
        throw error;
      }
    } catch (error) {
      console.error('💥 Erro ao buscar processos:', error);
      throw error;
    }
  },

  // Buscar processo específico
  async getProcess(id) {
    try {
      console.log('🔍 Carregando processo ID:', id);
      const response = await apiRequest(`/admin/processes/${id}`);
      console.log('✅ Processo carregado:', response);
      return response;
    } catch (error) {
      console.error('💥 Erro ao buscar processo:', error);
      throw error;
    }
  },

  // Criar processo
  async createProcess(data) {
    try {
      console.log('➕ Criando processo:', data);
      const response = await apiRequest('/admin/processes', {
        method: 'POST',
        body: JSON.stringify(data)
      });
      console.log('✅ Processo criado:', response);
      return response;
    } catch (error) {
      console.error('💥 Erro ao criar processo:', error);
      throw error;
    }
  },

  // Atualizar processo
  async updateProcess(id, data) {
    try {
      console.log('✏️ Atualizando processo:', { id, data });
      const response = await apiRequest(`/admin/processes/${id}`, {
        method: 'PUT',
        body: JSON.stringify(data)
      });
      console.log('✅ Processo atualizado:', response);
      return response;
    } catch (error) {
      console.error('💥 Erro ao atualizar processo:', error);
      throw error;
    }
  },

  // Excluir processo
  async deleteProcess(id) {
    try {
      console.log('🗑️ Excluindo processo ID:', id);
      const response = await apiRequest(`/admin/processes/${id}`, {
        method: 'DELETE'
      });
      console.log('✅ Processo excluído:', response);
      return response;
    } catch (error) {
      console.error('💥 Erro ao excluir processo:', error);
      throw error;
    }
  },

  // Métodos auxiliares (retornam dados vazios por enquanto)
  async getMovements(processId) {
    try {
      const response = await apiRequest(`/admin/processes/${processId}/movements`);
      return response;
    } catch (error) {
      console.error('⚠️ Erro ao buscar movimentações:', error);
      return { success: true, data: { data: [] } };
    }
  },

  async getDocuments(processId) {
    try {
      const response = await apiRequest(`/admin/processes/${processId}/documents`);
      return response;
    } catch (error) {
      console.error('⚠️ Erro ao buscar documentos:', error);
      return { success: true, data: { data: [] } };
    }
  },

  async getAppointments(processId) {
    try {
      const response = await apiRequest(`/admin/processes/${processId}/appointments`);
      return response;
    } catch (error) {
      console.error('⚠️ Erro ao buscar atendimentos:', error);
      return { success: true, data: { data: [] } };
    }
  },

  async syncWithCNJ(processId) {
    try {
      const response = await apiRequest(`/admin/processes/${processId}/sync-cnj`, {
        method: 'POST'
      });
      return response;
    } catch (error) {
      console.error('💥 Erro na sincronização CNJ:', error);
      throw error;
    }
  }
};
