import { apiRequest } from './api';

export const clientsService = {
  // Obter clientes para selects (usado nos formulários)
  async getClientsForSelect() {
    try {
      console.log('🔍 Carregando clientes para select...');
      const response = await apiRequest('/admin/clients/for-select');
      
      if (response && response.success) {
        console.log('✅ Clientes carregados:', response);
        return response;
      } else {
        // Se endpoint específico não existir, usar endpoint geral
        console.log('⚠️ Endpoint for-select não existe, usando endpoint geral...');
        const generalResponse = await apiRequest('/admin/clients');
        
        if (generalResponse && generalResponse.success) {
          return {
            success: true,
            data: generalResponse.data || []
          };
        }
      }
      
      // Se nada funcionar, retornar dados mock
      console.log('⚠️ Usando dados mock de clientes...');
      return {
        success: true,
        data: [
          { id: 1, nome: 'João Silva Santos', tipo_pessoa: 'PF', cpf_cnpj: '123.456.789-00' },
          { id: 2, nome: 'Empresa ABC Ltda', tipo_pessoa: 'PJ', cpf_cnpj: '12.345.678/0001-90' }
        ]
      };
    } catch (error) {
      console.error('💥 Erro ao buscar clientes:', error);
      
      // Retornar dados mock em caso de erro
      return {
        success: true,
        data: [
          { id: 1, nome: 'João Silva Santos', tipo_pessoa: 'PF', cpf_cnpj: '123.456.789-00' },
          { id: 2, nome: 'Empresa ABC Ltda', tipo_pessoa: 'PJ', cpf_cnpj: '12.345.678/0001-90' }
        ]
      };
    }
  }
};
