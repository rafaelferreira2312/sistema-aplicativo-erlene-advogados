#!/bin/bash

# Script 62 - Dashboard Admin Completo no Padrão Erlene
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/62-implementar-dashboard-admin-completo.sh

echo "📊 Implementando Dashboard Admin completo no padrão Erlene..."

# 1. Criar Layout Admin completo
cat > frontend/src/components/layout/AdminLayout/index.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  Bars3Icon,
  XMarkIcon,
  HomeIcon,
  UsersIcon,
  ScaleIcon,
  CalendarIcon,
  CurrencyDollarIcon,
  DocumentIcon,
  ClipboardDocumentListIcon,
  ChartBarIcon,
  UserGroupIcon,
  Cog6ToothIcon,
  ArrowRightOnRectangleIcon,
  BellIcon,
  MagnifyingGlassIcon
} from '@heroicons/react/24/outline';

const AdminLayout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('userType');
    navigate('/login');
  };

  const navigation = [
    { name: 'Dashboard', href: '/admin', icon: HomeIcon, current: location.pathname === '/admin' },
    { name: 'Clientes', href: '/admin/clients', icon: UsersIcon, current: location.pathname === '/admin/clients' },
    { name: 'Processos', href: '/admin/processes', icon: ScaleIcon, current: location.pathname === '/admin/processes' },
    { name: 'Atendimentos', href: '/admin/appointments', icon: CalendarIcon, current: location.pathname === '/admin/appointments' },
    { name: 'Financeiro', href: '/admin/financial', icon: CurrencyDollarIcon, current: location.pathname === '/admin/financial' },
    { name: 'Documentos', href: '/admin/documents', icon: DocumentIcon, current: location.pathname === '/admin/documents' },
    { name: 'Kanban', href: '/admin/kanban', icon: ClipboardDocumentListIcon, current: location.pathname === '/admin/kanban' },
    { name: 'Relatórios', href: '/admin/reports', icon: ChartBarIcon, current: location.pathname === '/admin/reports' },
    { name: 'Usuários', href: '/admin/users', icon: UserGroupIcon, current: location.pathname === '/admin/users' },
    { name: 'Configurações', href: '/admin/settings', icon: Cog6ToothIcon, current: location.pathname === '/admin/settings' },
  ];

  return (
    <div className="h-full flex">
      {/* Sidebar Mobile */}
      {sidebarOpen && (
        <div className="fixed inset-0 flex z-40 md:hidden">
          <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setSidebarOpen(false)} />
          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
            <div className="absolute top-0 right-0 -mr-12 pt-2">
              <button
                className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                onClick={() => setSidebarOpen(false)}
              >
                <XMarkIcon className="h-6 w-6 text-white" />
              </button>
            </div>
            <div className="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
              <div className="flex-shrink-0 flex items-center px-4">
                <div className="h-10 w-10 bg-gradient-erlene rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-lg">E</span>
                </div>
                <span className="ml-3 text-lg font-semibold text-gray-900">Erlene Advogados</span>
              </div>
              <nav className="mt-5 px-2 space-y-1">
                {navigation.map((item) => (
                  <a
                    key={item.name}
                    href={item.href}
                    className={`${
                      item.current
                        ? 'bg-primary-100 text-primary-900'
                        : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                    } group flex items-center px-2 py-2 text-base font-medium rounded-md`}
                  >
                    <item.icon
                      className={`${
                        item.current ? 'text-primary-500' : 'text-gray-400 group-hover:text-gray-500'
                      } mr-4 flex-shrink-0 h-6 w-6`}
                    />
                    {item.name}
                  </a>
                ))}
              </nav>
            </div>
          </div>
        </div>
      )}

      {/* Sidebar Desktop */}
      <div className="hidden md:flex md:flex-shrink-0">
        <div className="flex flex-col w-64">
          <div className="flex flex-col h-0 flex-1 border-r border-gray-200 bg-white">
            <div className="flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
              <div className="flex items-center flex-shrink-0 px-4">
                <div className="h-10 w-10 bg-gradient-erlene rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-lg">E</span>
                </div>
                <span className="ml-3 text-lg font-semibold text-gray-900">Erlene Advogados</span>
              </div>
              <nav className="mt-8 flex-1 px-2 bg-white space-y-1">
                {navigation.map((item) => (
                  <a
                    key={item.name}
                    href={item.href}
                    className={`${
                      item.current
                        ? 'bg-primary-100 text-primary-900 border-r-2 border-primary-500'
                        : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                    } group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-colors duration-150`}
                  >
                    <item.icon
                      className={`${
                        item.current ? 'text-primary-500' : 'text-gray-400 group-hover:text-gray-500'
                      } mr-3 flex-shrink-0 h-5 w-5`}
                    />
                    {item.name}
                  </a>
                ))}
              </nav>
            </div>
            <div className="flex-shrink-0 flex border-t border-gray-200 p-4">
              <button
                onClick={handleLogout}
                className="flex-shrink-0 w-full group block"
              >
                <div className="flex items-center">
                  <ArrowRightOnRectangleIcon className="inline-block h-5 w-5 text-gray-400 group-hover:text-gray-500 mr-3" />
                  <div className="text-sm font-medium text-gray-700 group-hover:text-gray-900">Sair do Sistema</div>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex flex-col w-0 flex-1 overflow-hidden">
        {/* Header */}
        <div className="relative z-10 flex-shrink-0 flex h-16 bg-white shadow border-b border-gray-200">
          <button
            className="px-4 border-r border-gray-200 text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500 md:hidden"
            onClick={() => setSidebarOpen(true)}
          >
            <Bars3Icon className="h-6 w-6" />
          </button>
          <div className="flex-1 px-4 flex justify-between">
            <div className="flex-1 flex">
              <div className="w-full flex md:ml-0">
                <div className="relative w-full text-gray-400 focus-within:text-gray-600">
                  <div className="absolute inset-y-0 left-0 flex items-center pointer-events-none">
                    <MagnifyingGlassIcon className="h-5 w-5" />
                  </div>
                  <input
                    className="block w-full h-full pl-8 pr-3 py-2 border-transparent text-gray-900 placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-0 focus:border-transparent"
                    placeholder="Buscar clientes, processos..."
                  />
                </div>
              </div>
            </div>
            <div className="ml-4 flex items-center md:ml-6">
              <button className="bg-white p-1 rounded-full text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500">
                <BellIcon className="h-6 w-6" />
              </button>
              <div className="ml-3 relative">
                <div className="flex items-center">
                  <div className="h-8 w-8 bg-gradient-erlene rounded-full flex items-center justify-center">
                    <span className="text-white font-medium text-sm">A</span>
                  </div>
                  <span className="ml-3 text-sm font-medium text-gray-700">Admin</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Page Content */}
        <main className="flex-1 relative overflow-y-auto focus:outline-none bg-gray-50">
          <div className="py-6">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
              {children}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;
EOF

# 2. Criar Dashboard Admin completo
cat > frontend/src/pages/admin/Dashboard/index.js << 'EOF'
import React from 'react';
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
  ClockIcon
} from '@heroicons/react/24/outline';

const Dashboard = () => {
  const stats = [
    {
      name: 'Total de Clientes',
      value: '1,247',
      change: '+12%',
      changeType: 'increase',
      icon: UsersIcon,
      color: 'blue',
      description: 'Novos clientes este mês: 47'
    },
    {
      name: 'Processos Ativos',
      value: '891',
      change: '+8%',
      changeType: 'increase',
      icon: ScaleIcon,
      color: 'green',
      description: 'Processos iniciados: 23'
    },
    {
      name: 'Receita Mensal',
      value: 'R$ 125.847',
      change: '+23%',
      changeType: 'increase',
      icon: CurrencyDollarIcon,
      color: 'yellow',
      description: 'Meta: R$ 150.000'
    },
    {
      name: 'Atendimentos Hoje',
      value: '14',
      change: '-2%',
      changeType: 'decrease',
      icon: CalendarIcon,
      color: 'purple',
      description: 'Próximo: 15:30'
    },
  ];

  const recentActivities = [
    {
      id: 1,
      type: 'process',
      title: 'Novo processo cadastrado',
      description: 'Processo 1234567-89.2024 - Maria Silva',
      time: '2 minutos atrás',
      icon: ScaleIcon,
      iconColor: 'text-green-600'
    },
    {
      id: 2,
      type: 'client',
      title: 'Cliente cadastrado',
      description: 'João Santos - Pessoa Física',
      time: '15 minutos atrás',
      icon: UsersIcon,
      iconColor: 'text-blue-600'
    },
    {
      id: 3,
      type: 'appointment',
      title: 'Atendimento agendado',
      description: 'Reunião com Ana Costa - Amanhã 14:00',
      time: '1 hora atrás',
      icon: CalendarIcon,
      iconColor: 'text-purple-600'
    },
    {
      id: 4,
      type: 'payment',
      title: 'Pagamento recebido',
      description: 'R$ 2.500,00 - Honorários Processo 9876543',
      time: '2 horas atrás',
      icon: CurrencyDollarIcon,
      iconColor: 'text-yellow-600'
    }
  ];

  const upcomingDeadlines = [
    {
      id: 1,
      title: 'Petição Inicial - Processo 1234567',
      date: 'Hoje',
      priority: 'high',
      client: 'Maria Silva'
    },
    {
      id: 2,
      title: 'Audiência de Conciliação',
      date: 'Amanhã 09:00',
      priority: 'medium',
      client: 'João Santos'
    },
    {
      id: 3,
      title: 'Recurso Ordinário',
      date: '23/07/2024',
      priority: 'low',
      client: 'Ana Costa'
    }
  ];

  const quickActions = [
    { title: 'Novo Cliente', icon: '👤', color: 'blue', href: '/admin/clients/new' },
    { title: 'Novo Processo', icon: '⚖️', color: 'green', href: '/admin/processes/new' },
    { title: 'Agendar Atendimento', icon: '📅', color: 'purple', href: '/admin/appointments/new' },
    { title: 'Ver Relatórios', icon: '📊', color: 'yellow', href: '/admin/reports' },
    { title: 'Upload Documento', icon: '📄', color: 'red', href: '/admin/documents/upload' },
    { title: 'Lançar Pagamento', icon: '💰', color: 'indigo', href: '/admin/financial/new' }
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
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">
          Bem-vindo ao Sistema Erlene Advogados
        </h1>
        <p className="mt-2 text-lg text-gray-600">
          Aqui está um resumo das atividades do seu escritório hoje.
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((item) => (
          <div key={item.name} className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
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
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Ações Rápidas</h2>
              <EyeIcon className="h-5 w-5 text-gray-400" />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {quickActions.map((action) => (
                <button
                  key={action.title}
                  className="group flex flex-col items-center p-6 border-2 border-dashed border-gray-300 rounded-xl hover:border-primary-500 hover:bg-primary-50 transition-all duration-200"
                >
                  <span className="text-3xl mb-3 group-hover:scale-110 transition-transform duration-200">
                    {action.icon}
                  </span>
                  <span className="text-sm font-medium text-gray-900 group-hover:text-primary-700">
                    {action.title}
                  </span>
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Upcoming Deadlines */}
        <div>
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Próximos Prazos</h2>
              <PlusIcon className="h-5 w-5 text-gray-400" />
            </div>
            <div className="space-y-4">
              {upcomingDeadlines.map((deadline) => {
                const PriorityIcon = getPriorityIcon(deadline.priority);
                return (
                  <div key={deadline.id} className="flex items-start space-x-3 p-3 rounded-lg hover:bg-gray-50 transition-colors">
                    <div className={`p-2 rounded-lg ${getPriorityColor(deadline.priority)}`}>
                      <PriorityIcon className="h-4 w-4" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {deadline.title}
                      </p>
                      <p className="text-sm text-gray-500">{deadline.client}</p>
                      <p className="text-xs text-gray-400 mt-1">{deadline.date}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      {/* Recent Activities */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Atividades Recentes</h2>
          <button className="text-sm text-primary-600 hover:text-primary-700 font-medium">
            Ver todas
          </button>
        </div>
        <div className="space-y-4">
          {recentActivities.map((activity) => (
            <div key={activity.id} className="flex items-start space-x-4 p-4 rounded-lg hover:bg-gray-50 transition-colors">
              <div className="flex-shrink-0">
                <div className="p-2 bg-gray-100 rounded-lg">
                  <activity.icon className={`h-5 w-5 ${activity.iconColor}`} />
                </div>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900">{activity.title}</p>
                <p className="text-sm text-gray-600">{activity.description}</p>
                <p className="text-xs text-gray-400 mt-1">{activity.time}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
EOF

# 3. Atualizar App.js para usar AdminLayout
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/auth/Login';
import AdminLayout from './components/layout/AdminLayout';
import Dashboard from './pages/admin/Dashboard';

// Portal Cliente (temporário)
const ClientPortal = () => {
  const handleLogout = () => {
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('userType');
    window.location.href = '/login';
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="bg-gradient-erlene text-white p-4">
        <div className="flex justify-between items-center max-w-7xl mx-auto">
          <h1 className="text-xl font-bold">Portal do Cliente - Erlene Advogados</h1>
          <button
            onClick={handleLogout}
            className="bg-red-700 hover:bg-red-800 px-4 py-2 rounded text-sm"
          >
            Sair
          </button>
        </div>
      </div>

      <div className="max-w-7xl mx-auto p-6">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900">Portal do Cliente</h2>
          <p className="text-gray-600">Acompanhe seus processos e documentos</p>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {[
            { title: 'Meus Processos', subtitle: '3 processos ativos', color: 'red', icon: '⚖️' },
            { title: 'Documentos', subtitle: '12 documentos disponíveis', color: 'blue', icon: '📄' },
            { title: 'Pagamentos', subtitle: '2 pagamentos pendentes', color: 'green', icon: '💳' }
          ].map((item) => (
            <div key={item.title} className="bg-white overflow-hidden shadow-erlene rounded-lg">
              <div className="p-6">
                <div className="flex items-center mb-4">
                  <span className="text-2xl mr-3">{item.icon}</span>
                  <h3 className="text-lg font-medium text-gray-900">{item.title}</h3>
                </div>
                <p className="text-gray-600 mb-4">{item.subtitle}</p>
                <button className={`bg-${item.color}-600 text-white px-4 py-2 rounded hover:bg-${item.color}-700`}>
                  Ver {item.title}
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

// Componente de proteção de rota
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';
  const userType = localStorage.getItem('userType');

  if (requiredAuth && !isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (!requiredAuth && isAuthenticated) {
    return <Navigate to={userType === 'cliente' ? '/portal' : '/admin'} replace />;
  }

  if (allowedTypes.length > 0 && !allowedTypes.includes(userType)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return children;
};

// Página 404
const NotFoundPage = () => (
  <div className="min-h-screen flex items-center justify-center bg-gray-50">
    <div className="text-center">
      <h1 className="text-6xl font-bold text-gray-400 mb-4">404</h1>
      <p className="text-gray-600 mb-4">Página não encontrada</p>
      <a href="/login" className="bg-gradient-erlene text-white px-4 py-2 rounded hover:shadow-erlene">
        Voltar ao Login
      </a>
    </div>
  </div>
);

// App principal
function App() {
  return (
    <Router>
      <div className="App h-screen">
        <Routes>
          <Route path="/" element={<Navigate to="/login" replace />} />
          
          <Route
            path="/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <Login />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/admin/*"
            element={
              <ProtectedRoute allowedTypes={['admin']}>
                <AdminLayout>
                  <Routes>
                    <Route path="" element={<Dashboard />} />
                    <Route path="dashboard" element={<Dashboard />} />
                  </Routes>
                </AdminLayout>
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <ClientPortal />
              </ProtectedRoute>
            }
          />
          
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
EOF

echo "✅ Dashboard Admin completo implementado!"
echo ""
echo "🎨 LAYOUT ADMINISTRATIVO COMPLETO:"
echo "   • Sidebar responsiva com navegação"
echo "   • Header com busca e notificações"
echo "   • Menu lateral com todas as seções"
echo "   • Sistema de logout integrado"
echo ""
echo "📊 DASHBOARD RICO EM DADOS:"
echo "   • Cards de estatísticas com cores Erlene"
echo "   • Ações rápidas interativas"
echo "   • Lista de prazos importantes"
echo "   • Feed de atividades recentes"
echo "   • Indicadores visuais de performance"
echo ""
echo "🎯 DESIGN SYSTEM ERLENE:"
echo "   • Cores #8B1538 e #F5B041"
echo "   • Sombras shadow-erlene"
echo "   • Ícones Heroicons consistentes"
echo "   • Transições suaves"
echo ""
echo "⏭️  Execute 'npm start' e teste o Dashboard Admin!"
echo "⏭️  Digite 'continuar' para próxima tela: Portal do Cliente!"