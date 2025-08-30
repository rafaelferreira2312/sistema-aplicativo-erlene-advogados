#!/bin/bash

# Script 114x - Frontend Dashboard Links Funcionais e Navegação
# Sistema Erlene Advogados - Frontend React
# EXECUTE DENTRO DA PASTA: frontend/
# Comando: chmod +x 114x-frontend-dashboard-links.sh && ./114x-frontend-dashboard-links.sh

echo "Script 114x - Frontend Dashboard com Links Funcionais..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "Erro: Execute este script dentro da pasta frontend/"
    echo "Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 114x-frontend-dashboard-links.sh && ./114x-frontend-dashboard-links.sh"
    exit 1
fi

echo "1. Verificando estrutura React..."

# Verificar qual Dashboard usar
DASHBOARD_PATH=""
if [ -f "src/pages/admin/Dashboard/index.js" ]; then
    DASHBOARD_PATH="src/pages/admin/Dashboard/index.js"
elif [ -f "src/pages/admin/Dashboard.js" ]; then
    DASHBOARD_PATH="src/pages/admin/Dashboard.js"
else
    echo "Dashboard não encontrado!"
    exit 1
fi

echo "2. Atualizando Dashboard com navegação funcional e porcentagens reais..."

# Criar Dashboard com links funcionais
cat > "$DASHBOARD_PATH" << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  UsersIcon, 
  ScaleIcon, 
  CurrencyDollarIcon,
  CalendarIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  EyeIcon,
  PlusIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ClockIcon,
  BellIcon,
  ArrowPathIcon
} from '@heroicons/react/24/outline';
import dashboardService from '../../../services/api/dashboardService';

const Dashboard = () => {
  const navigate = useNavigate();
  
  // Estados para dados da API
  const [dashboardData, setDashboardData] = useState(null);
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastUpdate, setLastUpdate] = useState(null);

  // Carregar dados do dashboard
  const loadDashboardData = async (useCache = true) => {
    try {
      setLoading(true);
      setError(null);
      
      console.log('Carregando dados do dashboard...');
      
      const result = await dashboardService.getDashboardDataWithCache(useCache);
      
      if (result.success) {
        setDashboardData(result.data);
        setLastUpdate(new Date().toLocaleTimeString());
        console.log('Dashboard carregado:', result.data);
      } else {
        setError(result.message || 'Erro ao carregar dados do dashboard');
        console.error('Erro ao carregar dashboard:', result.message);
      }
      
      const notifResult = await dashboardService.getNotifications();
      if (notifResult.success) {
        setNotifications(notifResult.data);
      }
      
    } catch (err) {
      console.error('Erro no carregamento:', err);
      setError('Erro de conexão com o servidor');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDashboardData();
    
    const interval = setInterval(() => {
      loadDashboardData(false);
    }, 5 * 60 * 1000);
    
    return () => clearInterval(interval);
  }, []);

  const handleRefresh = () => {
    loadDashboardData(false);
  };

  // Função para navegar para páginas específicas
  const navigateTo = (path) => {
    navigate(path);
  };

  // Componente de Loading
  if (loading && !dashboardData) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-red-700 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando dados do dashboard...</p>
        </div>
      </div>
    );
  }

  // Componente de Erro
  if (error && !dashboardData) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <ExclamationTriangleIcon className="h-12 w-12 text-red-500 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Erro ao carregar dados</h2>
          <p className="text-gray-600 mb-4">{error}</p>
          <button
            onClick={handleRefresh}
            className="bg-red-700 text-white px-4 py-2 rounded hover:bg-red-800 transition-colors"
          >
            Tentar Novamente
          </button>
        </div>
      </div>
    );
  }

  // Dados do dashboard (reais da API ou vazios)
  const stats = dashboardData?.stats || {
    clientes: { total: 0, ativos: 0, novos_mes: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
    processos: { total: 0, ativos: 0, urgentes: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
    atendimentos: { hoje: 0, semana: 0, agendados: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
    financeiro: { 
      receita_mes_formatada: 'R$ 0,00', 
      pendente: 0, 
      vencidos: 0,
      porcentagem: '0%',
      tipo_mudanca: 'stable'
    },
    tarefas: { pendentes: 0, vencidas: 0 }
  };

  const proximosAtendimentos = dashboardData?.listas?.proximos_atendimentos || [];
  const processosUrgentes = dashboardData?.listas?.processos_urgentes || [];
  const tarefasPendentes = dashboardData?.listas?.tarefas_pendentes || [];

  // URLs das ações rápidas (funcionais)
  const quickActions = [
    { 
      title: 'Novo Cliente', 
      icon: '👤', 
      color: 'blue', 
      action: () => navigateTo('/admin/clientes/novo')
    },
    { 
      title: 'Novo Processo', 
      icon: '⚖️', 
      color: 'green', 
      action: () => navigateTo('/admin/processos/novo')
    },
    { 
      title: 'Agendar Atendimento', 
      icon: '📅', 
      color: 'purple', 
      action: () => navigateTo('/admin/atendimentos/novo')
    },
    { 
      title: 'Ver Relatórios', 
      icon: '📊', 
      color: 'yellow', 
      action: () => navigateTo('/admin/reports')
    },
    { 
      title: 'Upload Documento', 
      icon: '📄', 
      color: 'red', 
      action: () => navigateTo('/admin/documentos/novo')
    },
    { 
      title: 'Lançar Pagamento', 
      icon: '💰', 
      color: 'indigo', 
      action: () => navigateTo('/admin/financeiro/novo')
    }
  ];

  // Configuração dos cards com porcentagens reais da API
  const statsCards = [
    {
      name: 'Total de Clientes',
      value: stats.clientes.total,
      change: stats.clientes.porcentagem,
      changeType: stats.clientes.tipo_mudanca,
      icon: UsersIcon,
      color: 'blue',
      description: `Novos clientes este mês: ${stats.clientes.novos_mes}`,
      onClick: () => navigateTo('/admin/clientes')
    },
    {
      name: 'Processos Ativos',
      value: stats.processos.ativos,
      change: stats.processos.porcentagem,
      changeType: stats.processos.tipo_mudanca,
      icon: ScaleIcon,
      color: 'green',
      description: `Total de processos: ${stats.processos.total}`,
      onClick: () => navigateTo('/admin/processos')
    },
    {
      name: 'Receita Mensal',
      value: stats.financeiro.receita_mes_formatada,
      change: stats.financeiro.porcentagem,
      changeType: stats.financeiro.tipo_mudanca,
      icon: CurrencyDollarIcon,
      color: 'yellow',
      description: 'Meta: R$ 150.000',
      onClick: () => navigateTo('/admin/financeiro')
    },
    {
      name: 'Atendimentos Hoje',
      value: stats.atendimentos.hoje,
      change: stats.atendimentos.porcentagem,
      changeType: stats.atendimentos.tipo_mudanca,
      icon: CalendarIcon,
      color: 'purple',
      description: 'Próximo: Verificar agenda',
      onClick: () => navigateTo('/admin/atendimentos')
    }
  ];

  return (
    <div className="space-y-8">
      {/* Header com botão de refresh */}
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">
            Bem-vindo ao Sistema Erlene Advogados
          </h1>
          <p className="mt-2 text-lg text-gray-600">
            Aqui está um resumo das atividades do seu escritório hoje.
          </p>
          {lastUpdate && (
            <p className="mt-1 text-sm text-gray-500">
              Última atualização: {lastUpdate}
            </p>
          )}
        </div>
        
        <div className="flex space-x-2">
          {notifications.length > 0 && (
            <div className="relative">
              <BellIcon className="h-6 w-6 text-red-600" />
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-4 w-4 flex items-center justify-center">
                {notifications.length}
              </span>
            </div>
          )}
          
          <button
            onClick={handleRefresh}
            disabled={loading}
            className="flex items-center space-x-2 px-3 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors disabled:opacity-50"
            title="Atualizar dados"
          >
            <ArrowPathIcon className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
            <span className="text-sm">Atualizar</span>
          </button>
        </div>
      </div>

      {/* Stats Cards - CLICÁVEIS COM PORCENTAGENS REAIS */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {statsCards.map((item) => (
          <div 
            key={item.name} 
            className="bg-white overflow-hidden shadow-lg rounded-xl border border-gray-100 cursor-pointer hover:shadow-xl transition-all duration-200"
            onClick={item.onClick}
          >
            <div className="p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className={`p-3 rounded-lg bg-${item.color}-100`}>
                    <item.icon className={`h-6 w-6 text-${item.color}-600`} />
                  </div>
                </div>
                <div className={`flex items-center text-sm font-semibold ${
                  item.changeType === 'increase' ? 'text-green-600' : 
                  item.changeType === 'decrease' ? 'text-red-600' : 'text-gray-500'
                }`}>
                  {item.changeType === 'increase' && <ArrowUpIcon className="h-4 w-4 mr-1" />}
                  {item.changeType === 'decrease' && <ArrowDownIcon className="h-4 w-4 mr-1" />}
                  {item.change}
                </div>
              </div>
              <div className="mt-4">
                <h3 className="text-sm font-medium text-gray-500">{item.name}</h3>
                <p className="text-3xl font-bold text-gray-900 mt-1">{item.value}</p>
                <p className="text-sm text-gray-500 mt-1">{item.description}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Quick Actions - FUNCIONAIS */}
        <div className="lg:col-span-2">
          <div className="bg-white shadow-lg rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Ações Rápidas</h2>
              <EyeIcon className="h-5 w-5 text-gray-400" />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {quickActions.map((action) => (
                <button
                  key={action.title}
                  onClick={action.action}
                  className="group flex flex-col items-center p-6 border-2 border-dashed border-gray-300 rounded-xl hover:border-red-500 hover:bg-red-50 transition-all duration-200"
                >
                  <span className="text-3xl mb-3 group-hover:scale-110 transition-transform duration-200">
                    {action.icon}
                  </span>
                  <span className="text-sm font-medium text-gray-900 group-hover:text-red-700">
                    {action.title}
                  </span>
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Próximos Prazos - COM BOTÃO + FUNCIONAL */}
        <div>
          <div className="bg-white shadow-lg rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Próximos Prazos</h2>
              <button
                onClick={() => navigateTo('/admin/prazos/novo')}
                className="p-1 text-gray-400 hover:text-red-600 transition-colors"
                title="Cadastrar novo prazo"
              >
                <PlusIcon className="h-5 w-5" />
              </button>
            </div>
            
            {processosUrgentes.length === 0 ? (
              <div className="text-center py-8">
                <CheckCircleIcon className="h-12 w-12 text-green-400 mx-auto mb-4" />
                <p className="text-gray-500 mb-4">Nenhum prazo urgente</p>
                <button
                  onClick={() => navigateTo('/admin/prazos/novo')}
                  className="text-sm text-red-600 hover:text-red-700 font-medium"
                >
                  Cadastrar novo prazo
                </button>
              </div>
            ) : (
              <div className="space-y-4">
                {processosUrgentes.map((processo) => (
                  <div 
                    key={processo.id} 
                    className="flex items-start space-x-3 p-3 rounded-lg hover:bg-gray-50 transition-colors cursor-pointer"
                    onClick={() => navigateTo(`/admin/processos/${processo.id}`)}
                  >
                    <div className="p-2 rounded-lg bg-red-100">
                      <ExclamationTriangleIcon className="h-4 w-4 text-red-600" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        Processo: {processo.numero}
                      </p>
                      <p className="text-sm text-gray-500">{processo.cliente_nome}</p>
                      <p className="text-xs text-gray-400 mt-1">
                        Prazo: {processo.prazo_formatado} ({processo.dias_restantes} dias)
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Próximos Atendimentos - COM ÍCONE DE CALENDÁRIO FUNCIONAL */}
      <div className="bg-white shadow-lg rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Próximos Atendimentos</h2>
          <button
            onClick={() => navigateTo('/admin/atendimentos/novo')}
            className="p-1 text-gray-400 hover:text-red-600 transition-colors"
            title="Agendar novo atendimento"
          >
            <CalendarIcon className="h-5 w-5" />
          </button>
        </div>
        
        {proximosAtendimentos.length === 0 ? (
          <div className="text-center py-8">
            <CalendarIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500 mb-4">Nenhum atendimento agendado</p>
            <button
              onClick={() => navigateTo('/admin/atendimentos/novo')}
              className="text-sm text-red-600 hover:text-red-700 font-medium"
            >
              Agendar atendimento
            </button>
          </div>
        ) : (
          <div className="space-y-4">
            {proximosAtendimentos.map((atendimento) => (
              <div 
                key={atendimento.id} 
                className="flex items-start space-x-4 p-4 rounded-lg hover:bg-gray-50 transition-colors border cursor-pointer"
                onClick={() => navigateTo(`/admin/atendimentos/${atendimento.id}`)}
              >
                <div className="flex-shrink-0">
                  <div className="p-2 bg-blue-100 rounded-lg">
                    <CalendarIcon className="h-5 w-5 text-blue-600" />
                  </div>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900">{atendimento.cliente_nome}</p>
                  <p className="text-sm text-gray-600">{atendimento.assunto}</p>
                  <p className="text-xs text-gray-400 mt-1">
                    {atendimento.data_formatada} - {atendimento.advogado_nome}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
EOF

echo "3. Atualizando dashboardService.js para usar porcentagens da API..."

cat > src/services/api/dashboardService.js << 'EOF'
import apiService from '../api';

class DashboardService {
  constructor() {
    this.api = apiService;
  }

  async getDashboardData() {
    try {
      console.log('Buscando dados do dashboard...');
      
      const response = await this.api.getDashboardStats();
      
      if (response.success) {
        console.log('Dados do dashboard carregados:', response.data);
        return {
          success: true,
          data: this.formatDashboardData(response.data)
        };
      }
      
      return {
        success: false,
        message: response.message || 'Erro ao carregar dados do dashboard'
      };
      
    } catch (error) {
      console.error('Erro no DashboardService:', error);
      return {
        success: false,
        message: error.message || 'Erro de conexão com o servidor'
      };
    }
  }

  async getNotifications() {
    try {
      const response = await this.api.getDashboardNotifications();
      
      if (response.success) {
        return {
          success: true,
          data: response.data || []
        };
      }
      
      return {
        success: false,
        message: response.message || 'Erro ao carregar notificações',
        data: []
      };
      
    } catch (error) {
      console.error('Erro ao buscar notificações:', error);
      return {
        success: false,
        message: error.message || 'Erro de conexão',
        data: []
      };
    }
  }

  formatDashboardData(data) {
    try {
      return {
        // Usar dados exatos da API (incluindo porcentagens calculadas no backend)
        stats: {
          clientes: {
            total: data.stats?.clientes?.total || 0,
            ativos: data.stats?.clientes?.ativos || 0,
            novos_mes: data.stats?.clientes?.novos_mes || 0,
            porcentagem: data.stats?.clientes?.porcentagem || '0%',
            tipo_mudanca: data.stats?.clientes?.tipo_mudanca || 'stable'
          },
          processos: {
            total: data.stats?.processos?.total || 0,
            ativos: data.stats?.processos?.ativos || 0,
            urgentes: data.stats?.processos?.urgentes || 0,
            prazos_vencendo: data.stats?.processos?.prazos_vencendo || 0,
            porcentagem: data.stats?.processos?.porcentagem || '0%',
            tipo_mudanca: data.stats?.processos?.tipo_mudanca || 'stable'
          },
          atendimentos: {
            hoje: data.stats?.atendimentos?.hoje || 0,
            semana: data.stats?.atendimentos?.semana || 0,
            agendados: data.stats?.atendimentos?.agendados || 0,
            porcentagem: data.stats?.atendimentos?.porcentagem || '0%',
            tipo_mudanca: data.stats?.atendimentos?.tipo_mudanca || 'stable'
          },
          financeiro: {
            receita_mes_formatada: data.stats?.financeiro?.receita_mes_formatada || 'R$ 0,00',
            receita_mes_valor: data.stats?.financeiro?.receita_mes || 0,
            pendente: data.stats?.financeiro?.pendente || 0,
            vencidos: data.stats?.financeiro?.vencidos || 0,
            porcentagem: data.stats?.financeiro?.porcentagem || '0%',
            tipo_mudanca: data.stats?.financeiro?.tipo_mudanca || 'stable'
          },
          tarefas: {
            pendentes: data.stats?.tarefas?.pendentes || 0,
            vencidas: data.stats?.tarefas?.vencidas || 0
          }
        },
        
        graficos: {
          atendimentos: data.graficos?.atendimentos || [],
          receitas: data.graficos?.receitas || []
        },
        
        listas: {
          proximos_atendimentos: data.listas?.proximos_atendimentos || [],
          processos_urgentes: data.listas?.processos_urgentes || [],
          tarefas_pendentes: data.listas?.tarefas_pendentes || []
        },

        acoes_rapidas: data.acoes_rapidas || {},
        ultima_atualizacao: data.ultima_atualizacao
      };
    } catch (error) {
      console.error('Erro ao formatar dados do dashboard:', error);
      return this.getEmptyDashboardData();
    }
  }

  getEmptyDashboardData() {
    return {
      stats: {
        clientes: { total: 0, ativos: 0, novos_mes: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
        processos: { total: 0, ativos: 0, urgentes: 0, prazos_vencendo: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
        atendimentos: { hoje: 0, semana: 0, agendados: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
        financeiro: { 
          receita_mes_formatada: 'R$ 0,00', 
          receita_mes_valor: 0,
          pendente: 0, 
          vencidos: 0,
          porcentagem: '0%',
          tipo_mudanca: 'stable'
        },
        tarefas: { pendentes: 0, vencidas: 0 }
      },
      graficos: { atendimentos: [], receitas: [] },
      listas: { proximos_atendimentos: [], processos_urgentes: [], tarefas_pendentes: [] }
    };
  }

  isDataFresh(timestamp, maxAge = 5 * 60 * 1000) {
    if (!timestamp) return false;
    return (Date.now() - timestamp) < maxAge;
  }

  getCachedData() {
    try {
      const cached = localStorage.getItem('dashboard_cache');
      if (!cached) return null;
      
      const data = JSON.parse(cached);
      if (this.isDataFresh(data.timestamp)) {
        return data.data;
      }
      
      localStorage.removeItem('dashboard_cache');
      return null;
    } catch (error) {
      return null;
    }
  }

  setCachedData(data) {
    try {
      const cacheData = { data: data, timestamp: Date.now() };
      localStorage.setItem('dashboard_cache', JSON.stringify(cacheData));
    } catch (error) {
      console.error('Erro ao salvar cache:', error);
    }
  }

  async getDashboardDataWithCache(useCache = true) {
    if (useCache) {
      const cachedData = this.getCachedData();
      if (cachedData) {
        console.log('Usando dados do cache');
        return { success: true, data: cachedData, fromCache: true };
      }
    }

    const result = await this.getDashboardData();
    
    if (result.success) {
      this.setCachedData(result.data);
    }
    
    return { ...result, fromCache: false };
  }
}

const dashboardService = new DashboardService();
export default dashboardService;
export { dashboardService };
EOF

echo ""
echo "SCRIPT 114x CONCLUÍDO COM SUCESSO!"
echo ""
echo "FUNCIONALIDADES IMPLEMENTADAS:"
echo "   ✓ Cards clicáveis navegam para páginas específicas"
echo "   ✓ Porcentagens reais vindas do backend (verde/vermelho)"
echo "   ✓ Botão + nos Próximos Prazos leva para cadastro"
echo "   ✓ Ícone calendário em Atendimentos leva para novo"
echo "   ✓ Todos os links das ações rápidas funcionais"
echo "   ✓ Navegação com useNavigate do React Router"
echo "   ✓ Dados formatados do backend (R$ brasileiros)"
echo ""
echo "AGORA TESTE:"
echo "   1. Execute npm start (ou yarn start)"
echo "   2. Clique nos cards - deve navegar"
echo "   3. Clique nas ações rápidas - deve navegar"
echo "   4. Botão + e ícones cinzas - devem navegar"
echo "   5. Porcentagens verde/vermelho baseadas no backend"
echo ""
echo "Digite 'continuar' para o próximo script (114y - Backend Clientes API)"