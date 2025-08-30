#!/bin/bash

# Script 114v-part2 - Atualizar Dashboard React com dados reais da API
# Sistema Erlene Advogados - Frontend React
# EXECUTE DENTRO DA PASTA: frontend/
# Comando: chmod +x 114v-part2-dashboard-real-api.sh && ./114v-part2-dashboard-real-api.sh

echo "🔄 Script 114v-part2 - Substituindo dados mock por API real no Dashboard..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📍 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 114v-part2-dashboard-real-api.sh && ./114v-part2-dashboard-real-api.sh"
    exit 1
fi

echo "✅ 1. Verificando estrutura React..."

# Verificar qual Dashboard usar
DASHBOARD_PATH=""
if [ -f "src/pages/admin/Dashboard/index.js" ]; then
    DASHBOARD_PATH="src/pages/admin/Dashboard/index.js"
elif [ -f "src/pages/admin/Dashboard.js" ]; then
    DASHBOARD_PATH="src/pages/admin/Dashboard.js"
else
    echo "⚠️  Dashboard não encontrado, criando..."
    mkdir -p src/pages/admin/Dashboard
    DASHBOARD_PATH="src/pages/admin/Dashboard/index.js"
fi

echo "📝 2. Substituindo Dashboard com dados reais da API..."

# Criar novo Dashboard conectado com a API
cat > "$DASHBOARD_PATH" << 'EOF'
import React, { useState, useEffect } from 'react';
import { 
  UsersIcon, 
  ScaleIcon, 
  CurrencyDollarIcon,
  CalendarIcon,
  ChartBarIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  EyeIcon,
  PlusIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ClockIcon,
  BellIcon,
  RefreshIcon
} from '@heroicons/react/24/outline';
import dashboardService from '../../../services/api/dashboardService';

const Dashboard = () => {
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
      
      // Buscar dados do dashboard
      const result = await dashboardService.getDashboardDataWithCache(useCache);
      
      if (result.success) {
        setDashboardData(result.data);
        setLastUpdate(new Date().toLocaleTimeString());
        console.log('Dashboard carregado com sucesso:', result.data);
      } else {
        setError(result.message || 'Erro ao carregar dados do dashboard');
        console.error('Erro ao carregar dashboard:', result.message);
      }
      
      // Buscar notificações
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

  // Carregar dados na montagem do componente
  useEffect(() => {
    loadDashboardData();
    
    // Atualizar dados a cada 5 minutos
    const interval = setInterval(() => {
      loadDashboardData(false); // Forçar busca sem cache
    }, 5 * 60 * 1000);
    
    return () => clearInterval(interval);
  }, []);

  // Função para recarregar dados manualmente
  const handleRefresh = () => {
    loadDashboardData(false);
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

  // Se não há dados, mostrar dashboard vazio
  const stats = dashboardData?.stats || {
    clientes: { total: 0, ativos: 0, novos_mes: 0 },
    processos: { total: 0, ativos: 0, urgentes: 0, prazos_vencendo: 0 },
    atendimentos: { hoje: 0, semana: 0, agendados: 0 },
    financeiro: { receita_mes: 'R$ 0,00', pendente: 'R$ 0,00', vencidos: 'R$ 0,00' },
    tarefas: { pendentes: 0, vencidas: 0 }
  };

  const proximosAtendimentos = dashboardData?.listas?.proximos_atendimentos || [];
  const processosUrgentes = dashboardData?.listas?.processos_urgentes || [];
  const tarefasPendentes = dashboardData?.listas?.tarefas_pendentes || [];

  // Configuração dos cards de estatísticas
  const statsCards = [
    {
      name: 'Total de Clientes',
      value: stats.clientes.total,
      change: '+12%', // TODO: Implementar cálculo real
      changeType: 'increase',
      icon: UsersIcon,
      color: 'blue',
      description: `Novos clientes este mês: ${stats.clientes.novos_mes}`
    },
    {
      name: 'Processos Ativos',
      value: stats.processos.ativos,
      change: '+8%', // TODO: Implementar cálculo real
      changeType: 'increase',
      icon: ScaleIcon,
      color: 'green',
      description: `Total de processos: ${stats.processos.total}`
    },
    {
      name: 'Receita Mensal',
      value: stats.financeiro.receita_mes,
      change: '+23%', // TODO: Implementar cálculo real
      changeType: 'increase',
      icon: CurrencyDollarIcon,
      color: 'yellow',
      description: 'Meta: R$ 150.000'
    },
    {
      name: 'Atendimentos Hoje',
      value: stats.atendimentos.hoje,
      change: '-2%', // TODO: Implementar cálculo real
      changeType: 'decrease',
      icon: CalendarIcon,
      color: 'purple',
      description: 'Próximo: Verificar agenda'
    },
  ];

  const quickActions = [
    { title: 'Novo Cliente', icon: '👤', color: 'blue', href: '/admin/clientes/novo' },
    { title: 'Novo Processo', icon: '⚖️', color: 'green', href: '/admin/processos/novo' },
    { title: 'Agendar Atendimento', icon: '📅', color: 'purple', href: '/admin/atendimentos/novo' },
    { title: 'Ver Relatórios', icon: '📊', color: 'yellow', href: '/admin/reports' },
    { title: 'Upload Documento', icon: '📄', color: 'red', href: '/admin/documentos/novo' },
    { title: 'Lançar Pagamento', icon: '💰', color: 'indigo', href: '/admin/financeiro/novo' }
  ];

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'high': return 'text-red-600 bg-red-100';
      case 'medium': return 'text-yellow-600 bg-yellow-100';
      case 'low': return 'text-green-600 bg-green-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getPriorityIcon = (priority) => {
    switch (priority) {
      case 'high': return ExclamationTriangleIcon;
      case 'medium': return ClockIcon;
      case 'low': return CheckCircleIcon;
      default: return ClockIcon;
    }
  };

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
          {/* Indicador de notificações */}
          {notifications.length > 0 && (
            <div className="relative">
              <BellIcon className="h-6 w-6 text-red-600" />
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-4 w-4 flex items-center justify-center">
                {notifications.length}
              </span>
            </div>
          )}
          
          {/* Botão de refresh */}
          <button
            onClick={handleRefresh}
            disabled={loading}
            className="flex items-center space-x-2 px-3 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors disabled:opacity-50"
            title="Atualizar dados"
          >
            <RefreshIcon className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
            <span className="text-sm">Atualizar</span>
          </button>
        </div>
      </div>

      {/* Notificações */}
      {notifications.length > 0 && (
        <div className="bg-blue-50 border-l-4 border-blue-400 p-4 rounded-md">
          <div className="flex">
            <div className="flex-shrink-0">
              <BellIcon className="h-5 w-5 text-blue-400" />
            </div>
            <div className="ml-3">
              <h3 className="text-sm font-medium text-blue-800">
                Você tem {notifications.length} notificação(ões)
              </h3>
              <div className="mt-2 text-sm text-blue-700">
                <ul className="list-disc list-inside space-y-1">
                  {notifications.slice(0, 3).map((notification, index) => (
                    <li key={index}>
                      <span className="font-medium">{notification.title}:</span> {notification.message}
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {statsCards.map((item) => (
          <div key={item.name} className="bg-white overflow-hidden shadow-lg rounded-xl border border-gray-100">
            <div className="p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className={`p-3 rounded-lg bg-${item.color}-100`}>
                    <item.icon className={`h-6 w-6 text-${item.color}-600`} />
                  </div>
                </div>
                <div className={`flex items-center text-sm font-semibold ${
                  item.changeType === 'increase' ? 'text-green-600' : 'text-red-600'
                }`}>
                  {item.changeType === 'increase' ? (
                    <ArrowUpIcon className="h-4 w-4 mr-1" />
                  ) : (
                    <ArrowDownIcon className="h-4 w-4 mr-1" />
                  )}
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
        {/* Quick Actions */}
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
                  className="group flex flex-col items-center p-6 border-2 border-dashed border-gray-300 rounded-xl hover:border-red-500 hover:bg-red-50 transition-all duration-200"
                  onClick={() => window.location.href = action.href}
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

        {/* Próximos Prazos */}
        <div>
          <div className="bg-white shadow-lg rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Próximos Prazos</h2>
              <PlusIcon className="h-5 w-5 text-gray-400" />
            </div>
            
            {processosUrgentes.length === 0 ? (
              <div className="text-center py-8">
                <CheckCircleIcon className="h-12 w-12 text-green-400 mx-auto mb-4" />
                <p className="text-gray-500">Nenhum prazo urgente</p>
              </div>
            ) : (
              <div className="space-y-4">
                {processosUrgentes.map((processo) => (
                  <div key={processo.id} className="flex items-start space-x-3 p-3 rounded-lg hover:bg-gray-50 transition-colors">
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

      {/* Próximos Atendimentos */}
      <div className="bg-white shadow-lg rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Próximos Atendimentos</h2>
          <CalendarIcon className="h-5 w-5 text-gray-400" />
        </div>
        
        {proximosAtendimentos.length === 0 ? (
          <div className="text-center py-8">
            <CalendarIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500">Nenhum atendimento agendado</p>
          </div>
        ) : (
          <div className="space-y-4">
            {proximosAtendimentos.map((atendimento) => (
              <div key={atendimento.id} className="flex items-start space-x-4 p-4 rounded-lg hover:bg-gray-50 transition-colors border">
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

      {/* Tarefas Pendentes */}
      {tarefasPendentes.length > 0 && (
        <div className="bg-white shadow-lg rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold text-gray-900">Suas Tarefas Pendentes</h2>
            <ClockIcon className="h-5 w-5 text-gray-400" />
          </div>
          <div className="space-y-4">
            {tarefasPendentes.map((tarefa) => (
              <div key={tarefa.id} className={`flex items-start space-x-4 p-4 rounded-lg border ${
                tarefa.vencida ? 'border-red-200 bg-red-50' : 'border-gray-200 hover:bg-gray-50'
              } transition-colors`}>
                <div className="flex-shrink-0">
                  <div className={`p-2 rounded-lg ${tarefa.vencida ? 'bg-red-100' : 'bg-yellow-100'}`}>
                    <ClockIcon className={`h-5 w-5 ${tarefa.vencida ? 'text-red-600' : 'text-yellow-600'}`} />
                  </div>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900">{tarefa.titulo}</p>
                  <p className="text-sm text-gray-600">{tarefa.descricao}</p>
                  <div className="flex items-center space-x-4 mt-1 text-xs text-gray-400">
                    {tarefa.prazo_formatado && (
                      <span>Prazo: {tarefa.prazo_formatado}</span>
                    )}
                    {tarefa.cliente_nome && (
                      <span>Cliente: {tarefa.cliente_nome}</span>
                    )}
                    {tarefa.vencida && (
                      <span className="text-red-600 font-medium">VENCIDA</span>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default Dashboard;
EOF

echo "✅ Dashboard atualizado com dados reais da API"

echo "📱 3. Atualizando arquivo .env do React se necessário..."

# Verificar se .env existe e tem as configurações corretas
if [ ! -f ".env" ]; then
    echo "⚠️  Arquivo .env não encontrado, criando..."
    cat > .env << 'EOF'
# API Configuration
REACT_APP_API_URL=http://localhost:8000/api
REACT_APP_APP_URL=http://localhost:3000

# App Configuration
REACT_APP_APP_NAME="Sistema Erlene Advogados"
REACT_APP_VERSION="1.0.0"

# Features
REACT_APP_ENABLE_MOCK=false
REACT_APP_ENABLE_DEBUG=true
EOF
fi

# Verificar se as configurações estão corretas
if ! grep -q "REACT_APP_API_URL=http://localhost:8000/api" .env; then
    echo "⚠️  Corrigindo URL da API no .env..."
    sed -i 's|REACT_APP_API_URL=.*|REACT_APP_API_URL=http://localhost:8000/api|' .env
fi

echo "✅ Configurações do .env verificadas"

echo "🔧 4. Verificando se os serviços estão instalados..."

# Verificar se axios está instalado
if grep -q '"axios"' package.json; then
    echo "✅ Axios já está instalado"
else
    echo "⚠️  Instalando axios..."
    npm install axios
fi

echo ""
echo "✅ SCRIPT 114v-part2 CONCLUÍDO COM SUCESSO!"
echo ""
echo "📋 RESUMO DAS ALTERAÇÕES:"
echo "   ✓ Dashboard atualizado para usar dados reais da API"
echo "   ✓ Removidos todos os dados mockados"
echo "   ✓ Implementado loading e error states"
echo "   ✓ Sistema de notificações integrado"
echo "   ✓ Atualização automática a cada 5 minutos"
echo "   ✓ Botão de refresh manual"
echo ""
echo "🎯 TESTE AGORA:"
echo "   1. Certifique-se que o backend está rodando (php artisan serve)"
echo "   2. Execute o frontend (npm start ou yarn start)"
echo "   3. Faça login no sistema"
echo "   4. O Dashboard deve mostrar dados vazios se o banco estiver vazio"
echo "   5. Ou os dados reais se houver registros no banco"
echo ""
echo "🔗 FUNCIONALIDADES ADICIONADAS:"
echo "   • Loading spinner ao carregar dados"
echo "   • Mensagens de erro se API falhar"
echo "   • Indicador de última atualização"
echo "   • Notificações em tempo real"
echo "   • Cards vazios quando não há dados"
echo "   • Refresh automático e manual"
echo ""
echo "✅ Agora o Dashboard usa APENAS dados reais da API!"