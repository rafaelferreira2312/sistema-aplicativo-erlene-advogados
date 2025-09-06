#!/bin/bash

# Script 132 - Criar Service Frontend para Audiências
# Sistema Erlene Advogados - Integração Frontend com API real
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🎯 Script 132 - Criando service frontend para audiências..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 132-create-frontend-service.sh && ./132-create-frontend-service.sh"
    exit 1
fi

echo "1️⃣ Criando estrutura de services..."

# Criar diretório services se não existir
mkdir -p src/services

echo "2️⃣ Criando audienciasService.js com conexão real à API..."

# Criar audienciasService.js
cat > src/services/audienciasService.js << 'EOF'
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
EOF

echo "3️⃣ Atualizando arquivo de configuração da API..."

# Verificar se existe arquivo de configuração da API
if [ ! -f "src/services/api.js" ]; then
    echo "📄 Criando arquivo de configuração da API..."
    
    cat > src/services/api.js << 'EOF'
// api.js - Configuração base da API
// Sistema Erlene Advogados

export const API_CONFIG = {
  BASE_URL: process.env.REACT_APP_API_URL || 'http://localhost:8000/api',
  TIMEOUT: 10000,
  
  ENDPOINTS: {
    // Autenticação
    LOGIN: '/auth/login',
    LOGOUT: '/auth/logout',
    ME: '/auth/me',
    
    // Dashboard
    DASHBOARD_STATS: '/dashboard/stats',
    
    // Audiências
    AUDIENCIAS: '/admin/audiencias',
    AUDIENCIAS_STATS: '/admin/audiencias/dashboard/stats',
    AUDIENCIAS_HOJE: '/admin/audiencias/filters/hoje',
    AUDIENCIAS_PROXIMAS: '/admin/audiencias/filters/proximas',
    
    // Clientes
    CLIENTES: '/admin/clients',
    
    // Processos
    PROCESSOS: '/admin/processes'
  }
};

/**
 * Obter token de autenticação
 */
export const getAuthToken = () => {
  return localStorage.getItem('token') || localStorage.getItem('erlene_token');
};

/**
 * Headers padrão para requisições
 */
export const getDefaultHeaders = () => {
  const token = getAuthToken();
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...(token && { 'Authorization': `Bearer ${token}` })
  };
};

/**
 * Configurar interceptors para requisições
 */
export const setupApiInterceptors = () => {
  // Interceptor para adicionar token automaticamente
  const originalFetch = window.fetch;
  
  window.fetch = function(url, options = {}) {
    // Se for uma requisição para nossa API, adicionar headers
    if (url.includes(API_CONFIG.BASE_URL)) {
      options.headers = {
        ...getDefaultHeaders(),
        ...options.headers
      };
    }
    
    return originalFetch(url, options);
  };
};

export default API_CONFIG;
EOF

else
    echo "✅ Arquivo de configuração da API já existe"
fi

echo "4️⃣ Verificando estrutura de pastas do frontend..."

# Verificar se as pastas necessárias existem
echo "📁 Verificando estrutura:"
echo "   src/services/ ✅"
echo "   src/pages/admin/ $([ -d "src/pages/admin" ] && echo "✅" || echo "❌")"
echo "   src/components/audiencias/ $([ -d "src/components/audiencias" ] && echo "✅" || echo "❌")"

echo "5️⃣ Criando arquivo de exemplo de uso..."

# Criar arquivo de exemplo para documentar como usar o service
cat > src/services/audiencias-example.js << 'EOF'
// audiencias-example.js - Exemplo de uso do audienciasService
// Sistema Erlene Advogados

import audienciasService from './audienciasService';

/**
 * Exemplos de como usar o audienciasService
 */

// 1. Listar todas as audiências
async function exemploListarAudiencias() {
  try {
    const resultado = await audienciasService.listarAudiencias();
    
    if (resultado.success) {
      console.log('Audiências:', resultado.audiencias);
      console.log('Total:', resultado.total);
    } else {
      console.error('Erro:', resultado.error);
    }
  } catch (error) {
    console.error('Erro inesperado:', error);
  }
}

// 2. Obter estatísticas do dashboard
async function exemploObterEstatisticas() {
  try {
    const resultado = await audienciasService.obterEstatisticas();
    
    if (resultado.success) {
      console.log('Estatísticas:', resultado.stats);
      // { hoje: 2, proximas_2h: 1, em_andamento: 0, ... }
    }
  } catch (error) {
    console.error('Erro:', error);
  }
}

// 3. Criar nova audiência
async function exemploCriarAudiencia() {
  const dadosAudiencia = {
    processoId: 1,
    clienteId: 1,
    advogadoId: 1,
    unidadeId: 1,
    tipo: 'conciliacao',
    data: '2024-09-10',
    hora: '10:00',
    local: 'TJSP - 1ª Vara Cível',
    advogado: 'Dr. Carlos Silva',
    observacoes: 'Primeira audiência do processo'
  };

  // Validar dados antes de enviar
  const validacao = audienciasService.validarDadosAudiencia(dadosAudiencia);
  
  if (!validacao.valido) {
    console.error('Dados inválidos:', validacao.erros);
    return;
  }

  // Criar audiência
  try {
    const resultado = await audienciasService.criarAudiencia(dadosAudiencia);
    
    if (resultado.success) {
      console.log('Audiência criada:', resultado.audiencia);
      console.log('Mensagem:', resultado.message);
    } else {
      console.error('Erro ao criar:', resultado.error);
    }
  } catch (error) {
    console.error('Erro inesperado:', error);
  }
}

// 4. Listar com filtros
async function exemploListarComFiltros() {
  const filtros = {
    data_inicio: '2024-09-01',
    data_fim: '2024-09-30',
    status: 'agendada',
    tipo: 'conciliacao',
    per_page: 10
  };

  try {
    const resultado = await audienciasService.listarAudiencias(filtros);
    
    if (resultado.success) {
      console.log('Audiências filtradas:', resultado.audiencias);
    }
  } catch (error) {
    console.error('Erro:', error);
  }
}

// 5. Atualizar audiência
async function exemploAtualizarAudiencia() {
  const id = 1;
  const dadosAtualizacao = {
    status: 'confirmada',
    observacoes: 'Audiência confirmada pelo cliente'
  };

  try {
    const resultado = await audienciasService.atualizarAudiencia(id, dadosAtualizacao);
    
    if (resultado.success) {
      console.log('Audiência atualizada:', resultado.audiencia);
    }
  } catch (error) {
    console.error('Erro:', error);
  }
}

export {
  exemploListarAudiencias,
  exemploObterEstatisticas,
  exemploCriarAudiencia,
  exemploListarComFiltros,
  exemploAtualizarAudiencia
};
EOF

echo "✅ Service frontend criado com sucesso!"
echo "✅ Configuração da API atualizada!"
echo "✅ Arquivo de exemplos criado!"
echo ""
echo "📋 Arquivos criados:"
echo "   ✅ src/services/audienciasService.js - Service principal"
echo "   ✅ src/services/api.js - Configuração da API"
echo "   ✅ src/services/audiencias-example.js - Exemplos de uso"
echo ""
echo "📋 Funcionalidades implementadas:"
echo "   ✅ Conexão real com API Laravel"
echo "   ✅ Autenticação automática via token"
echo "   ✅ Tratamento de erros robusto"
echo "   ✅ Validação de dados"
echo "   ✅ Formatação para compatibilidade"
echo "   ✅ Métodos para todas as operações CRUD"
echo "   ✅ Filtros e paginação"
echo "   ✅ Estatísticas do dashboard"
echo ""
echo "📋 Próximo passo: Integrar service com componentes do frontend"
echo "   chmod +x 133-integrate-components.sh && ./133-integrate-components.sh"