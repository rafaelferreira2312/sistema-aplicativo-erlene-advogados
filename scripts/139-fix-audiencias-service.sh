#!/bin/bash

# Script 139 - Corrigir audienciasService para usar apiClient padrão
# Sistema Erlene Advogados - Padronizar com módulos funcionais
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 139 - Corrigindo audienciasService para usar apiClient padrão..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📝 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 139-fix-audiencias-service.sh && ./139-fix-audiencias-service.sh"
    exit 1
fi

echo "1️⃣ Fazendo backup do service atual..."

# Fazer backup
if [ -f "src/services/audienciasService.js" ]; then
    cp "src/services/audienciasService.js" "src/services/audienciasService.js.bak.139"
    echo "✅ Backup criado: audienciasService.js.bak.139"
fi

echo "2️⃣ Verificando se apiClient existe..."

if [ ! -f "src/services/apiClient.js" ]; then
    echo "❌ Erro: apiClient.js não encontrado"
    echo "Este arquivo é necessário para padronizar a autenticação"
    exit 1
fi

echo "✅ apiClient.js encontrado"

echo "3️⃣ Criando audienciasService.js padronizado..."

# Criar service padronizado seguindo o padrão de clientsService.js
cat > src/services/audienciasService.js << 'EOF'
import apiClient from './apiClient';

export const audienciasService = {
  // Buscar todas as audiências (nome correto que frontend usa)
  async getAudiencias(params = {}) {
    try {
      const response = await apiClient.get('/admin/audiencias', { params });
      return {
        success: true,
        data: response.data.data || response.data,
        pagination: response.data.pagination || response.data.meta || null
      };
    } catch (error) {
      console.error('Erro ao buscar audiências:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar audiências'
      };
    }
  },

  // Alias para compatibilidade com código existente
  async listarAudiencias(filtros = {}) {
    return await this.getAudiencias(filtros);
  },

  // Obter estatísticas do dashboard
  async obterEstatisticas() {
    try {
      const response = await apiClient.get('/admin/audiencias/dashboard/stats');
      return {
        success: true,
        stats: response.data.data || response.data || {
          hoje: 0,
          proximas_2h: 0,
          em_andamento: 0,
          total_mes: 0,
          agendadas: 0,
          realizadas_mes: 0
        }
      };
    } catch (error) {
      console.error('Erro ao obter estatísticas:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao obter estatísticas',
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
  },

  // Obter audiência específica por ID
  async obterAudiencia(id) {
    try {
      const response = await apiClient.get(`/admin/audiencias/${id}`);
      return {
        success: true,
        audiencia: response.data.data || response.data
      };
    } catch (error) {
      console.error(`Erro ao obter audiência ${id}:`, error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao obter audiência',
        audiencia: {}
      };
    }
  },

  // Criar audiência (nome correto que frontend usa)
  async createAudiencia(data) {
    try {
      const response = await apiClient.post('/admin/audiencias', data);
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao criar audiência:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao criar audiência',
        errors: error.response?.data?.errors || {}
      };
    }
  },

  // Alias para compatibilidade
  async criarAudiencia(dadosAudiencia) {
    return await this.createAudiencia(dadosAudiencia);
  },

  // Atualizar audiência (nome correto que frontend usa)
  async updateAudiencia(id, data) {
    try {
      const response = await apiClient.put(`/admin/audiencias/${id}`, data);
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao atualizar audiência:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao atualizar audiência',
        errors: error.response?.data?.errors || {}
      };
    }
  },

  // Alias para compatibilidade
  async atualizarAudiencia(id, dadosAudiencia) {
    return await this.updateAudiencia(id, dadosAudiencia);
  },

  // Deletar audiência (nome correto que frontend usa)
  async deleteAudiencia(id) {
    try {
      await apiClient.delete(`/admin/audiencias/${id}`);
      return {
        success: true,
        message: 'Audiência deletada com sucesso'
      };
    } catch (error) {
      console.error('Erro ao deletar audiência:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao deletar audiência'
      };
    }
  },

  // Alias para compatibilidade
  async excluirAudiencia(id) {
    return await this.deleteAudiencia(id);
  },

  // Métodos auxiliares para compatibilidade com código existente
  async obterAudienciasHoje() {
    try {
      const response = await apiClient.get('/admin/audiencias/filters/hoje');
      return {
        success: true,
        audiencias: response.data.data || response.data || []
      };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao obter audiências de hoje',
        audiencias: []
      };
    }
  },

  async obterProximasAudiencias(horas = 2) {
    try {
      const response = await apiClient.get(`/admin/audiencias/filters/proximas?horas=${horas}`);
      return {
        success: true,
        audiencias: response.data.data || response.data || []
      };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao obter próximas audiências',
        audiencias: []
      };
    }
  },

  // Validação e formatação (mantidas para compatibilidade)
  validarDadosAudiencia(dados) {
    const erros = [];

    if (!dados.processo_id && !dados.processoId) erros.push('Processo é obrigatório');
    if (!dados.cliente_id && !dados.clienteId) erros.push('Cliente é obrigatório');
    if (!dados.tipo) erros.push('Tipo de audiência é obrigatório');
    if (!dados.data) erros.push('Data é obrigatória');
    if (!dados.hora) erros.push('Hora é obrigatória');
    if (!dados.local) erros.push('Local é obrigatório');
    if (!dados.advogado) erros.push('Advogado responsável é obrigatório');

    return {
      valido: erros.length === 0,
      erros
    };
  },

  formatarDadosParaAPI(dados) {
    return {
      processo_id: parseInt(dados.processoId || dados.processo_id || 1),
      cliente_id: parseInt(dados.clienteId || dados.cliente_id || 1),
      advogado_id: parseInt(dados.advogadoId || dados.advogado_id || 1),
      unidade_id: parseInt(dados.unidadeId || dados.unidade_id || 1),
      tipo: dados.tipo || 'conciliacao',
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
};

// Export default para compatibilidade com import existente
export default audienciasService;
EOF

echo "4️⃣ Verificando se a correção foi aplicada..."

if grep -q "import apiClient from './apiClient'" src/services/audienciasService.js; then
    echo "✅ Service atualizado com sucesso!"
    echo "✅ Agora usa apiClient padrão como outros módulos"
else
    echo "❌ Erro na atualização, restaurando backup..."
    if [ -f "src/services/audienciasService.js.bak.139" ]; then
        cp "src/services/audienciasService.js.bak.139" "src/services/audienciasService.js"
    fi
    exit 1
fi

echo "5️⃣ Verificando compatibilidade com código existente..."

# Verificar se todas as funções usadas no componente existem
echo "Verificando funções utilizadas no componente Audiencias.js:"

if [ -f "src/pages/admin/Audiencias.js" ]; then
    echo "📋 Funções encontradas no componente:"
    grep -o "audienciasService\.[a-zA-Z]*" src/pages/admin/Audiencias.js | sort | uniq
    
    echo ""
    echo "📋 Funções disponíveis no service:"
    grep -o "async [a-zA-Z]*(" src/services/audienciasService.js | sed 's/async //' | sed 's/(//' | sort
fi

echo "6️⃣ Testando sintaxe do arquivo..."

# Verificar se não há erros de sintaxe
if node -c src/services/audienciasService.js 2>/dev/null; then
    echo "✅ Sintaxe do arquivo está correta"
else
    echo "❌ Erro de sintaxe detectado"
    node -c src/services/audienciasService.js
    exit 1
fi

echo ""
echo "✅ Script 139 concluído!"
echo ""
echo "🔧 CORREÇÕES REALIZADAS:"
echo "   ✅ audienciasService.js agora usa apiClient padrão"
echo "   ✅ Mesma autenticação de processos e clientes"
echo "   ✅ Mantém compatibilidade com código existente"
echo "   ✅ Todas as funções originais preservadas"
echo ""
echo "📋 DIFERENÇAS PRINCIPAIS:"
echo "   ❌ ANTES: fetch() customizado + autenticação manual"
echo "   ✅ AGORA: apiClient + interceptors automáticos"
echo ""
echo "🎯 RESOLUÇÃO DO PROBLEMA:"
echo "   • Erro 401 deve estar resolvido"
echo "   • Usa mesmo token dos módulos funcionais"
echo "   • Interceptors automáticos para refresh token"
echo ""
echo "📋 TESTE:"
echo "   1. Recarregue a página /admin/audiencias"
echo "   2. Verifique se não há mais erro 401"
echo "   3. Confirme se dados aparecem na tabela"
echo ""
echo "🔄 Se ainda houver problema:"
echo "   1. Verificar se backend está rodando"
echo "   2. Verificar se usuário está logado"
echo "   3. Comparar token com módulos funcionais"