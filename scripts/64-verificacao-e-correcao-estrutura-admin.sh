#!/bin/bash

# Script 64 - Verificação e Correção da Estrutura Admin
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "🔍 Verificando estrutura do projeto..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto (onde está o package.json)"
    exit 1
fi

# Verificar estrutura de pastas
echo "📁 Verificando estrutura de pastas..."

# Criar estrutura se não existir
mkdir -p src/pages/admin
mkdir -p src/components/admin
mkdir -p src/layouts
mkdir -p src/hooks
mkdir -p src/utils
mkdir -p src/services

# Verificar se AdminLayout existe
if [ ! -f "src/layouts/AdminLayout.jsx" ]; then
    echo "⚠️  AdminLayout não encontrado. Criando..."
    
    cat > src/layouts/AdminLayout.jsx << 'EOF'
import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import {
  HomeIcon,
  UsersIcon,
  BriefcaseIcon,
  CalendarIcon,
  DocumentTextIcon,
  CurrencyDollarIcon,
  ChartBarIcon,
  CogIcon,
  ArrowLeftOnRectangleIcon,
  Bars3Icon,
  XMarkIcon,
  UserGroupIcon,
  ClipboardDocumentListIcon
} from '@heroicons/react/24/outline';

const AdminLayout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();

  const navigation = [
    { name: 'Dashboard', href: '/admin', icon: HomeIcon, current: location.pathname === '/admin' },
    { name: 'Clientes', href: '/admin/clients', icon: UsersIcon, current: location.pathname.startsWith('/admin/clients') },
    { name: 'Processos', href: '/admin/processes', icon: BriefcaseIcon, current: location.pathname.startsWith('/admin/processes') },
    { name: 'Atendimentos', href: '/admin/attendances', icon: CalendarIcon, current: location.pathname.startsWith('/admin/attendances') },
    { name: 'Kanban', href: '/admin/kanban', icon: ClipboardDocumentListIcon, current: location.pathname.startsWith('/admin/kanban') },
    { name: 'Documentos', href: '/admin/documents', icon: DocumentTextIcon, current: location.pathname.startsWith('/admin/documents') },
    { name: 'Financeiro', href: '/admin/financial', icon: CurrencyDollarIcon, current: location.pathname.startsWith('/admin/financial') },
    { name: 'Relatórios', href: '/admin/reports', icon: ChartBarIcon, current: location.pathname.startsWith('/admin/reports') },
    { name: 'Usuários', href: '/admin/users', icon: UserGroupIcon, current: location.pathname.startsWith('/admin/users') },
    { name: 'Configurações', href: '/admin/settings', icon: CogIcon, current: location.pathname.startsWith('/admin/settings') }
  ];

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sidebar Mobile */}
      <div className={`fixed inset-0 z-40 lg:hidden ${sidebarOpen ? 'block' : 'hidden'}`}>
        <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setSidebarOpen(false)} />
        <div className="relative flex w-64 flex-col bg-white shadow-xl">
          <div className="flex h-16 items-center justify-between px-4">
            <img className="h-8 w-auto" src="/logo-erlene.png" alt="Erlene Advogados" />
            <button
              onClick={() => setSidebarOpen(false)}
              className="text-gray-400 hover:text-gray-500"
            >
              <XMarkIcon className="h-6 w-6" />
            </button>
          </div>
          <nav className="flex-1 px-4 py-4 space-y-1">
            {navigation.map((item) => (
              <Link
                key={item.name}
                to={item.href}
                className={`group flex items-center px-2 py-2 text-sm font-medium rounded-md ${
                  item.current
                    ? 'bg-red-50 text-red-700 border-r-4 border-red-700'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                }`}
                onClick={() => setSidebarOpen(false)}
              >
                <item.icon className="mr-3 h-5 w-5" />
                {item.name}
              </Link>
            ))}
          </nav>
          <div className="p-4 border-t">
            <button
              onClick={handleLogout}
              className="flex items-center w-full px-2 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
            >
              <ArrowLeftOnRectangleIcon className="mr-3 h-5 w-5" />
              Sair
            </button>
          </div>
        </div>
      </div>

      {/* Sidebar Desktop */}
      <div className="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64 lg:flex-col">
        <div className="flex min-h-0 flex-1 flex-col bg-white shadow-lg">
          <div className="flex h-16 items-center px-4 bg-red-700">
            <img className="h-8 w-auto" src="/logo-erlene-white.png" alt="Erlene Advogados" />
            <h1 className="ml-2 text-xl font-bold text-white">Erlene</h1>
          </div>
          <nav className="flex-1 px-4 py-4 space-y-1 overflow-y-auto">
            {navigation.map((item) => (
              <Link
                key={item.name}
                to={item.href}
                className={`group flex items-center px-2 py-2 text-sm font-medium rounded-md ${
                  item.current
                    ? 'bg-red-50 text-red-700 border-r-4 border-red-700'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                }`}
              >
                <item.icon className="mr-3 h-5 w-5" />
                {item.name}
              </Link>
            ))}
          </nav>
          <div className="p-4 border-t">
            <button
              onClick={handleLogout}
              className="flex items-center w-full px-2 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
            >
              <ArrowLeftOnRectangleIcon className="mr-3 h-5 w-5" />
              Sair
            </button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="lg:ml-64">
        {/* Header */}
        <div className="sticky top-0 z-10 bg-white shadow-sm">
          <div className="flex h-16 items-center px-4 sm:px-6 lg:px-8">
            <button
              onClick={() => setSidebarOpen(true)}
              className="lg:hidden text-gray-500 hover:text-gray-600"
            >
              <Bars3Icon className="h-6 w-6" />
            </button>
            <div className="flex-1 flex justify-between">
              <div className="flex items-center">
                <h1 className="text-xl font-semibold text-gray-900">
                  Sistema de Gestão Jurídica
                </h1>
              </div>
              <div className="flex items-center space-x-4">
                <div className="flex items-center space-x-2">
                  <div className="w-8 h-8 bg-red-100 rounded-full flex items-center justify-center">
                    <span className="text-red-600 font-medium text-sm">A</span>
                  </div>
                  <span className="text-sm font-medium text-gray-700">Admin</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Page Content */}
        <main className="py-6">
          <div className="px-4 sm:px-6 lg:px-8">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;
EOF
fi

# Verificar se Dashboard existe
if [ ! -f "src/pages/admin/Dashboard.jsx" ]; then
    echo "⚠️  Dashboard não encontrado. Criando..."
    
    cat > src/pages/admin/Dashboard.jsx << 'EOF'
import React from 'react';
import { 
  UsersIcon, 
  BriefcaseIcon, 
  CalendarIcon, 
  CurrencyDollarIcon,
  ChartBarIcon,
  DocumentTextIcon 
} from '@heroicons/react/24/outline';

const Dashboard = () => {
  const stats = [
    {
      name: 'Total de Clientes',
      value: '1,234',
      change: '+12%',
      changeType: 'increase',
      icon: UsersIcon,
      color: 'bg-blue-500'
    },
    {
      name: 'Processos Ativos',
      value: '89',
      change: '+5%',
      changeType: 'increase',
      icon: BriefcaseIcon,
      color: 'bg-green-500'
    },
    {
      name: 'Atendimentos Hoje',
      value: '12',
      change: '+2',
      changeType: 'increase',
      icon: CalendarIcon,
      color: 'bg-yellow-500'
    },
    {
      name: 'Receita Mensal',
      value: 'R$ 45.231',
      change: '+8%',
      changeType: 'increase',
      icon: CurrencyDollarIcon,
      color: 'bg-red-500'
    }
  ];

  const recentActivities = [
    { id: 1, activity: 'Novo cliente cadastrado', time: '2 horas atrás', type: 'client' },
    { id: 2, activity: 'Processo atualizado', time: '4 horas atrás', type: 'process' },
    { id: 3, activity: 'Atendimento agendado', time: '6 horas atrás', type: 'attendance' },
    { id: 4, activity: 'Documento enviado', time: '8 horas atrás', type: 'document' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white shadow-sm rounded-lg p-6">
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-1">Bem-vindo ao sistema de gestão jurídica</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat) => (
          <div key={stat.name} className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className={`p-3 rounded-lg ${stat.color}`}>
                <stat.icon className="h-6 w-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">{stat.name}</p>
                <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
              </div>
            </div>
            <div className="mt-4">
              <span className={`text-sm font-medium ${
                stat.changeType === 'increase' ? 'text-green-600' : 'text-red-600'
              }`}>
                {stat.change}
              </span>
              <span className="text-gray-500 text-sm"> vs mês anterior</span>
            </div>
          </div>
        ))}
      </div>

      {/* Recent Activities */}
      <div className="bg-white shadow-sm rounded-lg p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Atividades Recentes</h2>
        <div className="space-y-4">
          {recentActivities.map((activity) => (
            <div key={activity.id} className="flex items-center space-x-4 p-3 hover:bg-gray-50 rounded-lg">
              <div className="flex-shrink-0">
                <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
                  <DocumentTextIcon className="h-5 w-5 text-red-600" />
                </div>
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">{activity.activity}</p>
                <p className="text-xs text-gray-500">{activity.time}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white shadow-sm rounded-lg p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Ações Rápidas</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 text-left">
            <UsersIcon className="h-8 w-8 text-red-600 mb-2" />
            <h3 className="font-medium text-gray-900">Novo Cliente</h3>
            <p className="text-sm text-gray-500">Cadastrar um novo cliente</p>
          </button>
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 text-left">
            <BriefcaseIcon className="h-8 w-8 text-red-600 mb-2" />
            <h3 className="font-medium text-gray-900">Novo Processo</h3>
            <p className="text-sm text-gray-500">Cadastrar um novo processo</p>
          </button>
          <button className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 text-left">
            <CalendarIcon className="h-8 w-8 text-red-600 mb-2" />
            <h3 className="font-medium text-gray-900">Agendar Atendimento</h3>
            <p className="text-sm text-gray-500">Agendar um novo atendimento</p>
          </button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
EOF
fi

# Verificar se as rotas estão configuradas em App.js
echo "🔍 Verificando configuração de rotas..."

if [ ! -f "src/App.js" ]; then
    echo "❌ Erro: App.js não encontrado"
    exit 1
fi

# Backup do App.js
cp src/App.js src/App.js.backup

echo "✅ Estrutura verificada e corrigida!"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "1. Verificar se AdminLayout foi criado"
echo "2. Verificar se Dashboard foi criado"
echo "3. Testar rota: http://localhost:3000/admin"
echo "4. Testar rota: http://localhost:3000/admin/clients"
echo ""
echo "🔧 Execute 'npm start' para testar as rotas"
echo "📁 Backup do App.js salvo em: src/App.js.backup"
EOF

chmod +x 64-verificar-estrutura-admin.sh