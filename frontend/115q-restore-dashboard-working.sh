#!/bin/bash

# Script 115q - Restaurar Dashboard Funcionando
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115q-restore-dashboard-working.sh && ./115q-restore-dashboard-working.sh
# EXECUTE NA PASTA: frontend/

echo "🔧 Restaurando Dashboard funcionando..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "1. Verificando estrutura atual do Dashboard..."

# Verificar onde está o Dashboard
DASHBOARD_PATH=""
if [ -f "src/pages/admin/Dashboard/index.js" ]; then
    DASHBOARD_PATH="src/pages/admin/Dashboard/index.js"
    echo "✅ Dashboard encontrado em: $DASHBOARD_PATH"
elif [ -f "src/pages/admin/Dashboard.js" ]; then
    DASHBOARD_PATH="src/pages/admin/Dashboard.js"
    echo "✅ Dashboard encontrado em: $DASHBOARD_PATH"
else
    echo "⚠️  Dashboard não encontrado, criando estrutura..."
    mkdir -p src/pages/admin/Dashboard
    DASHBOARD_PATH="src/pages/admin/Dashboard/index.js"
fi

echo "2. Criando Dashboard funcionando baseado nos scripts 114w/114x..."

# Restaurar Dashboard funcionando (baseado no script 114x que funcionava)
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

const Dashboard = () => {
  const navigate = useNavigate();
  
  // Estados para dados
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
      
      // Tentar buscar dados da API
      const response = await fetch('http://localhost:8000/api/admin/dashboard', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('authToken') || localStorage.getItem('erlene_token')}`,
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        }
      });
      
      if (response.ok) {
        const result = await response.json();
        
        if (result.success) {
          setDashboardData(result.data);
          setLastUpdate(new Date().toLocaleTimeString());
          console.log('Dashboard carregado:', result.data);
        } else {
          throw new Error(result.message || 'Erro ao carregar dashboard');
        }
      } else if (response.status === 401) {
        // Token expirado
        localStorage.clear();
        navigate('/login');
        return;
      } else {
        throw new Error(`Erro ${response.status}: ${response.statusText}`);
      }
      
    } catch (err) {
      console.error('Erro no carregamento:', err);
      setError('Erro de conexão com o servidor');
      
      // Usar dados padrão em caso de erro
      setDashboardData({
        stats: {
          clientes: { total: 0, ativos: 0, novos_mes: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
          processos: { total: 0, ativos: 0, urgentes: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
          atendimentos: { hoje: 0, semana: 0, agendados: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
          financeiro: { receita_mes_formatada: 'R$ 0,00', porcentagem: '0%', tipo_mudanca: 'stable' },
          tarefas: { pendentes: 0, vencidas: 0 }
        },
        listas: {
          proximos_atendimentos: [],
          processos_urgentes: [],
          tarefas_pendentes: []
        }
      });
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

  // Configuração dos cards com porcentagens
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

      {/* Alerta de erro se API não conectar */}
      {error && (
        <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4 rounded-md">
          <div className="flex">
            <div className="flex-shrink-0">
              <ExclamationTriangleIcon className="h-5 w-5 text-yellow-400" />
            </div>
            <div className="ml-3">
              <h3 className="text-sm font-medium text-yellow-800">
                Erro de conexão com o servidor
              </h3>
              <p className="mt-1 text-sm text-yellow-700">
                {error}. Exibindo dados padrão.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Stats Cards - CLICÁVEIS COM PORCENTAGENS */}
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

echo "3. Verificando se o App.js está importando corretamente..."

# Verificar se o App.js tem o import correto
if [ -f "src/App.js" ]; then
    if ! grep -q "Dashboard.*from.*pages/admin/Dashboard" src/App.js; then
        echo "⚠️  Corrigindo import do Dashboard no App.js..."
        
        # Adicionar import se não existir
        if ! grep -q "import Dashboard" src/App.js; then
            sed -i '/import AdminLayout/a import Dashboard from "./pages/admin/Dashboard";' src/App.js
        fi
    fi
    
    echo "✅ App.js verificado"
fi

echo "4. Verificando se todas as dependências estão instaladas..."

# Verificar dependências essenciais
MISSING_DEPS=""

if ! grep -q '"react-router-dom"' package.json; then
    MISSING_DEPS="$MISSING_DEPS react-router-dom"
fi

if ! grep -q '"@heroicons/react"' package.json; then
    MISSING_DEPS="$MISSING_DEPS @heroicons/react"
fi

if [ ! -z "$MISSING_DEPS" ]; then
    echo "⚠️  Instalando dependências faltantes: $MISSING_DEPS"
    npm install $MISSING_DEPS
fi

echo "5. Testando se o backend está respondendo..."

# Testar conexão com backend
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "✅ Backend respondendo na porta 8000"
elif curl -s http://localhost:8001/api/health > /dev/null 2>&1; then
    echo "✅ Backend respondendo na porta 8001"
    echo "⚠️  Atualizando URL no Dashboard para porta 8001..."
    sed -i 's|http://localhost:8000|http://localhost:8001|g' "$DASHBOARD_PATH"
else
    echo "⚠️  Backend não está respondendo!"
    echo ""
    echo "INICIE O BACKEND:"
    echo "   cd ../backend"
    echo "   php artisan serve"
    echo ""
fi

echo ""
echo "🎉 DASHBOARD RESTAURADO!"
echo ""
echo "FUNCIONALIDADES RESTAURADAS:"
echo "✅ Dashboard com dados reais da API"
echo "✅ Cards clicáveis que navegam para páginas"
echo "✅ Ações rápidas funcionais"
echo "✅ Botões + e ícones funcionais"
echo "✅ Loading states e tratamento de erro"
echo "✅ Porcentagens vindas do backend"
echo "✅ Fallback para dados vazios se API falhar"
echo ""
echo "🔄 PRÓXIMOS PASSOS:"
echo "1. Recarregue o frontend (Ctrl+C e npm start)"
echo "2. Verifique se não há erros no console"
echo "3. Teste se o dashboard aparece"
echo "4. Teste se os botões navegam corretamente"
echo ""
echo "Se ainda houver problemas:"
echo "- Verifique o console do navegador (F12)"
echo "- Certifique-se que o backend está rodando"
echo "- Verifique se o login está funcionando"