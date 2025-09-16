#!/bin/bash

# Script 147 - Corrigir integração de autenticação do audienciasService
# Sistema Erlene Advogados - Usar mesmo sistema de auth dos módulos funcionais
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 147 - Corrigindo autenticação do módulo audiências..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "🔍 PROBLEMA IDENTIFICADO:"
echo "   ❌ Tanto GET quanto POST retornam 401 Unauthorized"
echo "   ❌ audienciasService usa sistema de auth diferente dos outros módulos"
echo "   ✅ Token JWT válido existe no localStorage"
echo ""

echo "1️⃣ Fazendo backup do audienciasService atual..."

if [ -f "src/services/audienciasService.js" ]; then
    cp "src/services/audienciasService.js" "src/services/audienciasService.js.bak.147"
    echo "✅ Backup criado: audienciasService.js.bak.147"
else
    echo "❌ audienciasService.js não encontrado"
    exit 1
fi

echo ""
echo "2️⃣ Analisando api.js para usar mesmo sistema..."

if [ -f "src/services/api.js" ]; then
    echo "✅ api.js encontrado - será usado como base"
    
    echo "📋 Verificando método de autenticação do api.js:"
    grep -n -A5 "getToken\|Authorization" src/services/api.js | head -10
else
    echo "❌ api.js não encontrado"
    exit 1
fi

echo ""
echo "3️⃣ Substituindo audienciasService para usar api.js..."

# Criar novo audienciasService que usa api.js
cat > src/services/audienciasService.js << 'EOF'
// audienciasService.js - Integrado com api.js (Sistema funcionando)
// Sistema Erlene Advogados - Módulo Audiências
// Usa o mesmo sistema de autenticação dos módulos funcionais

import apiInstance from './api';

class AudienciasService {
  constructor() {
    this.api = apiInstance;
  }

  // ====== MÉTODOS DE LISTAGEM ======
  
  async listarAudiencias() {
    try {
      const response = await this.api.apiRequest('/admin/audiencias');
      
      return {
        success: true,
        audiencias: response.data || response || [],
        message: 'Audiências carregadas com sucesso'
      };
    } catch (error) {
      console.error('❌ Erro ao listar audiências:', error);
      return {
        success: false,
        audiencias: [],
        error: error.message || 'Erro ao carregar audiências'
      };
    }
  }

  async obterAudiencia(id) {
    try {
      const response = await this.api.apiRequest(`/admin/audiencias/${id}`);
      
      return {
        success: true,
        audiencia: response.data || response,
        message: 'Audiência carregada com sucesso'
      };
    } catch (error) {
      console.error('❌ Erro ao obter audiência:', error);
      return {
        success: false,
        audiencia: null,
        error: error.message || 'Erro ao carregar audiência'
      };
    }
  }

  // ====== MÉTODOS DE CRIAÇÃO ======
  
  async criarAudiencia(dadosAudiencia) {
    try {
      const response = await this.api.apiRequest('/admin/audiencias', {
        method: 'POST',
        body: JSON.stringify(dadosAudiencia)
      });
      
      return {
        success: true,
        audiencia: response.data || response,
        message: response.message || 'Audiência criada com sucesso'
      };
    } catch (error) {
      console.error('❌ Erro ao criar audiência:', error);
      return {
        success: false,
        audiencia: null,
        error: error.message || 'Erro ao criar audiência'
      };
    }
  }

  // ====== MÉTODOS DE ATUALIZAÇÃO ======
  
  async atualizarAudiencia(id, dadosAudiencia) {
    try {
      const response = await this.api.apiRequest(`/admin/audiencias/${id}`, {
        method: 'PUT',
        body: JSON.stringify(dadosAudiencia)
      });
      
      return {
        success: true,
        audiencia: response.data || response,
        message: response.message || 'Audiência atualizada com sucesso'
      };
    } catch (error) {
      console.error('❌ Erro ao atualizar audiência:', error);
      return {
        success: false,
        audiencia: null,
        error: error.message || 'Erro ao atualizar audiência'
      };
    }
  }

  // ====== MÉTODOS DE EXCLUSÃO ======
  
  async excluirAudiencia(id) {
    try {
      const response = await this.api.apiRequest(`/admin/audiencias/${id}`, {
        method: 'DELETE'
      });
      
      return {
        success: true,
        message: response.message || 'Audiência excluída com sucesso'
      };
    } catch (error) {
      console.error('❌ Erro ao excluir audiência:', error);
      return {
        success: false,
        error: error.message || 'Erro ao excluir audiência'
      };
    }
  }

  // ====== MÉTODOS DE ESTATÍSTICAS ======
  
  async obterEstatisticas() {
    try {
      const response = await this.api.apiRequest('/admin/audiencias/dashboard/stats');
      
      return {
        success: true,
        stats: response.data || response,
        message: 'Estatísticas carregadas com sucesso'
      };
    } catch (error) {
      console.error('❌ Erro ao obter estatísticas:', error);
      return {
        success: false,
        stats: {
          hoje: 0,
          proximasSemana: 0,
          total: 0,
          realizadas: 0
        },
        error: error.message || 'Erro ao carregar estatísticas'
      };
    }
  }

  // ====== MÉTODOS DE FILTROS ======
  
  async obterAudienciasHoje() {
    try {
      const response = await this.api.apiRequest('/admin/audiencias/filters/hoje');
      
      return {
        success: true,
        audiencias: response.data || response || [],
        message: 'Audiências de hoje carregadas'
      };
    } catch (error) {
      console.error('❌ Erro ao obter audiências de hoje:', error);
      return {
        success: false,
        audiencias: [],
        error: error.message
      };
    }
  }

  async obterProximasAudiencias() {
    try {
      const response = await this.api.apiRequest('/admin/audiencias/filters/proximas');
      
      return {
        success: true,
        audiencias: response.data || response || [],
        message: 'Próximas audiências carregadas'
      };
    } catch (error) {
      console.error('❌ Erro ao obter próximas audiências:', error);
      return {
        success: false,
        audiencias: [],
        error: error.message
      };
    }
  }

  // ====== MÉTODOS DE VALIDAÇÃO E FORMATAÇÃO ======
  
  validarDadosAudiencia(dados) {
    const erros = [];
    
    if (!dados.processo_id) erros.push('Processo é obrigatório');
    if (!dados.cliente_id) erros.push('Cliente é obrigatório');
    if (!dados.tipo) erros.push('Tipo de audiência é obrigatório');
    if (!dados.data) erros.push('Data é obrigatória');
    if (!dados.hora) erros.push('Hora é obrigatória');
    if (!dados.local) erros.push('Local é obrigatório');
    if (!dados.advogado) erros.push('Advogado responsável é obrigatório');
    
    return {
      valido: erros.length === 0,
      erros
    };
  }
  
  formatarDadosParaAPI(dados) {
    return {
      processo_id: parseInt(dados.processoId || dados.processo_id),
      cliente_id: parseInt(dados.clienteId || dados.cliente_id),
      tipo: dados.tipo,
      data: dados.data,
      hora: dados.hora,
      local: dados.local,
      sala: dados.sala || '',
      endereco: dados.endereco || '',
      advogado: dados.advogado,
      juiz: dados.juiz || '',
      status: dados.status || 'agendada',
      observacoes: dados.observacoes || ''
    };
  }

  // ====== MÉTODOS DE FORMATAÇÃO PARA EXIBIÇÃO ======
  
  formatarDataHora(data, hora) {
    if (!data) return '';
    
    const dataObj = new Date(data + 'T' + (hora || '00:00'));
    return dataObj.toLocaleString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }
  
  formatarTipoAudiencia(tipo) {
    const tipos = {
      'conciliacao': 'Conciliação',
      'instrucao': 'Instrução',
      'julgamento': 'Julgamento',
      'inicial': 'Audiência Inicial',
      'una': 'Audiência Una',
      'virtual': 'Virtual',
      'presencial': 'Presencial'
    };
    
    return tipos[tipo] || tipo;
  }
  
  formatarStatusAudiencia(status) {
    const statusMap = {
      'agendada': { label: 'Agendada', class: 'bg-blue-100 text-blue-800' },
      'confirmada': { label: 'Confirmada', class: 'bg-green-100 text-green-800' },
      'realizada': { label: 'Realizada', class: 'bg-gray-100 text-gray-800' },
      'cancelada': { label: 'Cancelada', class: 'bg-red-100 text-red-800' },
      'adiada': { label: 'Adiada', class: 'bg-yellow-100 text-yellow-800' }
    };
    
    return statusMap[status] || { label: status, class: 'bg-gray-100 text-gray-800' };
  }

  // ====== MÉTODOS DE UTILIDADE ======
  
  obterCorPorTipo(tipo) {
    const cores = {
      'conciliacao': 'bg-blue-500',
      'instrucao': 'bg-green-500',
      'julgamento': 'bg-red-500',
      'inicial': 'bg-purple-500',
      'una': 'bg-yellow-500',
      'virtual': 'bg-indigo-500',
      'presencial': 'bg-pink-500'
    };
    
    return cores[tipo] || 'bg-gray-500';
  }
  
  calcularTempoRestante(data, hora) {
    if (!data || !hora) return null;
    
    const agora = new Date();
    const dataAudiencia = new Date(data + 'T' + hora);
    const diff = dataAudiencia.getTime() - agora.getTime();
    
    if (diff < 0) return 'Expirado';
    
    const dias = Math.floor(diff / (1000 * 60 * 60 * 24));
    const horas = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    
    if (dias > 0) return `${dias} dia(s)`;
    if (horas > 0) return `${horas} hora(s)`;
    
    return 'Hoje';
  }
}

// Exportar instância única
export default new AudienciasService();
EOF

echo "✅ Novo audienciasService criado com integração ao api.js!"

echo ""
echo "4️⃣ Verificando sintaxe do novo service..."

if node -c src/services/audienciasService.js 2>/dev/null; then
    echo "✅ Sintaxe correta do novo audienciasService"
else
    echo "❌ Erro de sintaxe no novo audienciasService"
    node -c src/services/audienciasService.js
    echo "Restaurando backup..."
    cp "src/services/audienciasService.js.bak.147" "src/services/audienciasService.js"
    exit 1
fi

echo ""
echo "5️⃣ Testando nova integração de autenticação..."

echo "📋 Criando script de teste para o console do navegador..."

cat > test_new_audiencias_auth.js << 'EOF'
// Teste da nova integração audienciasService
console.log('=== TESTE NOVA INTEGRAÇÃO AUDIÊNCIAS ===');

// Verificar se audienciasService foi recarregado
if (typeof audienciasService !== 'undefined') {
    console.log('Service local encontrado, testando...');
} else {
    console.log('Recarregue a página para carregar novo service');
}

// Testar diretamente via fetch usando mesmo método do api.js
const testNewAuth = async () => {
    // Buscar token como api.js faz
    const possibleKeys = ['token', 'auth_token', 'access_token', 'jwt_token', 'erlene_token'];
    let token = null;
    
    for (const key of possibleKeys) {
        const foundToken = localStorage.getItem(key);
        if (foundToken) {
            console.log(`Token encontrado na chave: ${key}`);
            token = foundToken;
            break;
        }
    }
    
    if (!token) {
        console.log('❌ Nenhum token encontrado');
        return;
    }
    
    console.log('🔑 Token a ser usado:', token.substring(0, 50) + '...');
    
    // Testar GET com método do api.js
    try {
        const response = await fetch('http://localhost:8000/api/admin/audiencias', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': `Bearer ${token}`
            }
        });
        
        console.log('✅ GET Status:', response.status);
        
        if (response.ok) {
            const data = await response.json();
            console.log('✅ GET Success - Dados:', data);
        } else {
            const error = await response.text();
            console.log('❌ GET Error:', error);
        }
    } catch (error) {
        console.error('💥 GET Exception:', error);
    }
    
    // Testar POST com método do api.js
    try {
        const response = await fetch('http://localhost:8000/api/admin/audiencias', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                processo_id: 1,
                cliente_id: 1,
                tipo: 'conciliacao',
                data: '2025-09-17',
                hora: '14:00',
                local: 'Teste Nova Auth',
                advogado: 'Dr. Teste'
            })
        });
        
        console.log('✅ POST Status:', response.status);
        
        if (response.ok) {
            const data = await response.json();
            console.log('✅ POST Success - Dados:', data);
        } else {
            const error = await response.text();
            console.log('❌ POST Error:', error);
        }
    } catch (error) {
        console.error('💥 POST Exception:', error);
    }
};

testNewAuth();
EOF

echo "📋 Execute test_new_audiencias_auth.js no console após recarregar a página"

echo ""
echo "6️⃣ Verificando se outras dependências estão corretas..."

echo "📋 Verificando imports nos componentes..."

# Verificar se os componentes ainda importam audienciasService corretamente
if grep -q "import audienciasService" src/pages/admin/Audiencias.js; then
    echo "✅ Audiencias.js - import correto"
else
    echo "❌ Audiencias.js - import não encontrado"
fi

if grep -q "import audienciasService" src/components/audiencias/NewAudiencia.js; then
    echo "✅ NewAudiencia.js - import correto"
else
    echo "❌ NewAudiencia.js - import não encontrado"
fi

if grep -q "import audienciasService" src/components/audiencias/EditAudiencia.js; then
    echo "✅ EditAudiencia.js - import correto"
else
    echo "❌ EditAudiencia.js - import não encontrado"
fi

echo ""
echo "✅ Script 147 concluído!"
echo ""
echo "🔧 CORREÇÕES REALIZADAS:"
echo "   ✅ audienciasService reescrito para usar api.js"
echo "   ✅ Mesmo sistema de autenticação dos módulos funcionais"
echo "   ✅ Métodos adaptados para apiRequest() do api.js"
echo "   ✅ Mantidas todas as funcionalidades existentes"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. Recarregue a página (F5 ou Ctrl+R)"
echo "   2. Execute test_new_audiencias_auth.js no console"
echo "   3. Teste acesso a /admin/audiencias"
echo "   4. Teste criação de nova audiência"
echo ""
echo "📋 PRÓXIMO SCRIPT (se ainda houver erro):"
echo "   148-debug-backend-audiencias-auth.sh"
echo "   Objetivo: Verificar configuração de auth no backend"
echo ""
echo "🔄 Se funcionar:"
echo "   149-finalize-audiencias-integration.sh"
echo "   Objetivo: Finalizar integração e remover dados mock"