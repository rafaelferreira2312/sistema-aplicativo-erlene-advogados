// audienciasService.js - Service para integração com API de audiências
// Sistema Erlene Advogados

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

/**
 * Classe para gerenciar todas as operações relacionadas a audiências
 */
class AudienciasService {
  
  /**
   * Obter token de autenticação do localStorage
   */
  getAuthToken() {
    return localStorage.getItem('token') || localStorage.getItem('erlene_token');
  }

  /**
   * Headers padrão para requisições
   */
  getHeaders() {
    const token = this.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...(token && { 'Authorization': `Bearer ${token}` })
    };
  }

  /**
   * Fazer requisição para a API
   */
  async makeRequest(endpoint, options = {}) {
    try {
      const url = `${API_BASE_URL}${endpoint}`;
      const config = {
        headers: this.getHeaders(),
        ...options
      };

      console.log(`🔗 Fazendo requisição para: ${url}`);
      
      const response = await fetch(url, config);
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      console.error(`❌ Erro na requisição ${endpoint}:`, error);
      throw error;
    }
  }

  /**
   * Listar todas as audiências com filtros opcionais
   */
  async listarAudiencias(filtros = {}) {
    try {
      const params = new URLSearchParams();
      
      // Adicionar filtros se fornecidos
      if (filtros.data_inicio) params.append('data_inicio', filtros.data_inicio);
      if (filtros.data_fim) params.append('data_fim', filtros.data_fim);
      if (filtros.status) params.append('status', filtros.status);
      if (filtros.tipo) params.append('tipo', filtros.tipo);
      if (filtros.advogado_id) params.append('advogado_id', filtros.advogado_id);
      if (filtros.cliente_id) params.append('cliente_id', filtros.cliente_id);
      if (filtros.per_page) params.append('per_page', filtros.per_page);
      
      const queryString = params.toString();
      const endpoint = `/admin/audiencias${queryString ? `?${queryString}` : ''}`;
      
      const response = await this.makeRequest(endpoint, { method: 'GET' });
      
      return {
        success: true,
        audiencias: response.data || [],
        pagination: response.pagination || {},
        total: response.pagination?.total || response.data?.length || 0
      };
    } catch (error) {
      console.error('❌ Erro ao listar audiências:', error);
      return {
        success: false,
        error: error.message,
        audiencias: [],
        pagination: {},
        total: 0
      };
    }
  }

  /**
   * Obter estatísticas do dashboard de audiências
   */
  async obterEstatisticas() {
    try {
      const response = await this.makeRequest('/admin/audiencias/dashboard/stats', { 
        method: 'GET' 
      });
      
      return {
        success: true,
        stats: response.data || {
          hoje: 0,
          proximas_2h: 0,
          em_andamento: 0,
          total_mes: 0,
          agendadas: 0,
          realizadas_mes: 0
        }
      };
    } catch (error) {
      console.error('❌ Erro ao obter estatísticas:', error);
      return {
        success: false,
        error: error.message,
        stats: {
          hoje: 0,
          proximas_2h: 0,
          em_andamento: 0,
          total_mes: 0,
          agendadas: 0,
          realizadas_mes: 0
        }
      };
    }
  }

  /**
   * Obter audiências de hoje
   */
  async obterAudienciasHoje() {
    try {
      const response = await this.makeRequest('/admin/audiencias/filters/hoje', { 
        method: 'GET' 
      });
      
      return {
        success: true,
        audiencias: response.data || []
      };
    } catch (error) {
      console.error('❌ Erro ao obter audiências de hoje:', error);
      return {
        success: false,
        error: error.message,
        audiencias: []
      };
    }
  }

  /**
   * Obter próximas audiências
   */
  async obterProximasAudiencias(horas = 2) {
    try {
      const response = await this.makeRequest(
        `/admin/audiencias/filters/proximas?horas=${horas}`, 
        { method: 'GET' }
      );
      
      return {
        success: true,
        audiencias: response.data || []
      };
    } catch (error) {
      console.error('❌ Erro ao obter próximas audiências:', error);
      return {
        success: false,
        error: error.message,
        audiencias: []
      };
    }
  }

  /**
   * Obter audiência específica por ID
   */
  async obterAudiencia(id) {
    try {
      const response = await this.makeRequest(`/admin/audiencias/${id}`, { 
        method: 'GET' 
      });
      
      return {
        success: true,
        audiencia: response.data || {}
      };
    } catch (error) {
      console.error(`❌ Erro ao obter audiência ${id}:`, error);
      return {
        success: false,
        error: error.message,
        audiencia: {}
      };
    }
  }

  /**
   * Criar nova audiência
   */
  async criarAudiencia(dadosAudiencia) {
    try {
      const response = await this.makeRequest('/admin/audiencias', {
        method: 'POST',
        body: JSON.stringify(dadosAudiencia)
      });
      
      return {
        success: true,
        audiencia: response.data || {},
        message: response.message || 'Audiência criada com sucesso'
      };
    } catch (error) {
      console.error('❌ Erro ao criar audiência:', error);
      return {
        success: false,
        error: error.message,
        audiencia: {}
      };
    }
  }

  /**
   * Atualizar audiência existente
   */
  async atualizarAudiencia(id, dadosAudiencia) {
    try {
      const response = await this.makeRequest(`/admin/audiencias/${id}`, {
        method: 'PUT',
        body: JSON.stringify(dadosAudiencia)
      });
      
      return {
        success: true,
        audiencia: response.data || {},
        message: response.message || 'Audiência atualizada com sucesso'
      };
    } catch (error) {
      console.error(`❌ Erro ao atualizar audiência ${id}:`, error);
      return {
        success: false,
        error: error.message,
        audiencia: {}
      };
    }
  }

  /**
   * Excluir audiência
   */
  async excluirAudiencia(id) {
    try {
      const response = await this.makeRequest(`/admin/audiencias/${id}`, {
        method: 'DELETE'
      });
      
      return {
        success: true,
        message: response.message || 'Audiência excluída com sucesso'
      };
    } catch (error) {
      console.error(`❌ Erro ao excluir audiência ${id}:`, error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Validar dados de audiência antes do envio
   */
  validarDadosAudiencia(dados) {
    const erros = [];

    if (!dados.processo_id) erros.push('Processo é obrigatório');
    if (!dados.cliente_id) erros.push('Cliente é obrigatório');
    if (!dados.tipo) erros.push('Tipo de audiência é obrigatório');
    if (!dados.data) erros.push('Data é obrigatória');
    if (!dados.hora) erros.push('Hora é obrigatória');
    if (!dados.local) erros.push('Local é obrigatório');
    if (!dados.advogado) erros.push('Advogado responsável é obrigatório');

    // Validar data não ser no passado
    if (dados.data) {
      const dataAudiencia = new Date(dados.data);
      const hoje = new Date();
      hoje.setHours(0, 0, 0, 0);
      
      if (dataAudiencia < hoje) {
        erros.push('Data da audiência não pode ser no passado');
      }
    }

    // Validar formato da hora
    if (dados.hora && !/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/.test(dados.hora)) {
      erros.push('Formato de hora inválido (use HH:MM)');
    }

    return {
      valido: erros.length === 0,
      erros
    };
  }

  /**
   * Formatar dados para envio à API
   */
  formatarDadosParaAPI(dados) {
    return {
      processo_id: parseInt(dados.processoId || dados.processo_id),
      cliente_id: parseInt(dados.clienteId || dados.cliente_id),
      advogado_id: parseInt(dados.advogadoId || dados.advogado_id),
      unidade_id: parseInt(dados.unidadeId || dados.unidade_id),
      tipo: dados.tipo,
      data: dados.data,
      hora: dados.hora,
      local: dados.local,
      endereco: dados.endereco || '',
      sala: dados.sala || '',
      advogado: dados.advogado,
      juiz: dados.juiz || '',
      status: dados.status || 'agendada',
      observacoes: dados.observacoes || '',
      lembrete: Boolean(dados.lembrete !== false),
      horas_lembrete: parseInt(dados.horasLembrete || dados.horas_lembrete || 2)
    };
  }
}

// Exportar instância única do service
const audienciasService = new AudienciasService();
export default audienciasService;
