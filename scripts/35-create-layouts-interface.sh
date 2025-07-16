#!/bin/bash

# Script 35 - Layouts e Interface
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/35-create-layouts-interface.sh

echo "🏗️ Criando layouts e interface..."

# src/components/layout/AuthLayout/index.js
cat > frontend/src/components/layout/AuthLayout/index.js << 'EOF'
import React from 'react';

const AuthLayout = ({ children }) => {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center">
          <div className="mx-auto h-12 w-12 bg-gradient-erlene rounded-lg flex items-center justify-center mb-6">
            <span className="text-white font-bold text-xl">E</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900">
            Sistema Erlene Advogados
          </h1>
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow-erlene sm:rounded-lg sm:px-10">
          {children}
        </div>
      </div>

      <footer className="mt-8 text-center text-sm text-gray-500">
        <p>© 2024 Erlene Advogados. Todos os direitos reservados.</p>
        <p className="mt-1">Desenvolvido por Vancouver Tec</p>
      </footer>
    </div>
  );
};

export default AuthLayout;
EOF

# src/components/common/Header/index.js
cat > frontend/src/components/common/Header/index.js << 'EOF'
import React, { Fragment } from 'react';
import { Menu, Transition } from '@headlessui/react';
import { 
  Bars3Icon, 
  BellIcon, 
  UserCircleIcon,
  ChevronDownIcon,
  Cog6ToothIcon,
  ArrowRightOnRectangleIcon
} from '@heroicons/react/24/outline';
import { useAuth } from '../../../hooks/auth/useAuth';
import Badge from '../Badge';

const Header = ({ onToggleSidebar, title = 'Dashboard' }) => {
  const { user, logout } = useAuth();

  const handleLogout = async () => {
    await logout();
  };

  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="flex items-center justify-between h-16 px-4 sm:px-6 lg:px-8">
        {/* Left side */}
        <div className="flex items-center">
          <button
            type="button"
            className="lg:hidden -ml-0.5 -mt-0.5 h-12 w-12 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500"
            onClick={onToggleSidebar}
          >
            <Bars3Icon className="h-6 w-6" />
          </button>

          <h1 className="ml-4 lg:ml-0 text-xl font-semibold text-gray-900">
            {title}
          </h1>
        </div>

        {/* Right side */}
        <div className="flex items-center space-x-4">
          {/* Notifications */}
          <button
            type="button"
            className="relative p-2 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 rounded-full"
          >
            <BellIcon className="h-6 w-6" />
            <Badge 
              variant="danger" 
              size="small" 
              className="absolute -top-1 -right-1 px-1.5 py-0.5 text-xs"
            >
              3
            </Badge>
          </button>

          {/* User menu */}
          <Menu as="div" className="relative">
            <Menu.Button className="flex items-center text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500">
              <div className="flex items-center space-x-3">
                <div className="flex-shrink-0">
                  <UserCircleIcon className="h-8 w-8 text-gray-400" />
                </div>
                <div className="hidden md:block text-left">
                  <p className="text-sm font-medium text-gray-900">
                    {user?.nome || 'Usuário'}
                  </p>
                  <p className="text-xs text-gray-500">
                    {user?.perfil || 'Perfil'}
                  </p>
                </div>
                <ChevronDownIcon className="h-4 w-4 text-gray-400" />
              </div>
            </Menu.Button>

            <Transition
              as={Fragment}
              enter="transition ease-out duration-100"
              enterFrom="transform opacity-0 scale-95"
              enterTo="transform opacity-100 scale-100"
              leave="transition ease-in duration-75"
              leaveFrom="transform opacity-100 scale-100"
              leaveTo="transform opacity-0 scale-95"
            >
              <Menu.Items className="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                <Menu.Item>
                  {({ active }) => (
                    <a
                      href="#"
                      className={`${
                        active ? 'bg-gray-100' : ''
                      } flex items-center px-4 py-2 text-sm text-gray-700`}
                    >
                      <UserCircleIcon className="mr-3 h-5 w-5 text-gray-400" />
                      Meu Perfil
                    </a>
                  )}
                </Menu.Item>

                <Menu.Item>
                  {({ active }) => (
                    <a
                      href="#"
                      className={`${
                        active ? 'bg-gray-100' : ''
                      } flex items-center px-4 py-2 text-sm text-gray-700`}
                    >
                      <Cog6ToothIcon className="mr-3 h-5 w-5 text-gray-400" />
                      Configurações
                    </a>
                  )}
                </Menu.Item>

                <div className="border-t border-gray-100" />

                <Menu.Item>
                  {({ active }) => (
                    <button
                      onClick={handleLogout}
                      className={`${
                        active ? 'bg-gray-100' : ''
                      } flex w-full items-center px-4 py-2 text-sm text-gray-700`}
                    >
                      <ArrowRightOnRectangleIcon className="mr-3 h-5 w-5 text-gray-400" />
                      Sair
                    </button>
                  )}
                </Menu.Item>
              </Menu.Items>
            </Transition>
          </Menu>
        </div>
      </div>
    </header>
  );
};

export default Header;
EOF

# src/components/common/Sidebar/index.js
cat > frontend/src/components/common/Sidebar/index.js << 'EOF'
import React from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { 
  HomeIcon,
  UsersIcon,
  ScaleIcon,
  CalendarIcon,
  CurrencyDollarIcon,
  DocumentIcon,
  ViewColumnsIcon,
  ChartBarIcon,
  UserGroupIcon,
  Cog6ToothIcon,
  XMarkIcon
} from '@heroicons/react/24/outline';
import { useAuth } from '../../../hooks/auth/useAuth';

const navigation = [
  { name: 'Dashboard', href: '/admin', icon: HomeIcon, permission: 'dashboard.view' },
  { name: 'Clientes', href: '/admin/clientes', icon: UsersIcon, permission: 'clients.view' },
  { name: 'Processos', href: '/admin/processos', icon: ScaleIcon, permission: 'processes.view' },
  { name: 'Atendimentos', href: '/admin/atendimentos', icon: CalendarIcon, permission: 'appointments.view' },
  { name: 'Financeiro', href: '/admin/financeiro', icon: CurrencyDollarIcon, permission: 'financial.view' },
  { name: 'Documentos', href: '/admin/documentos', icon: DocumentIcon, permission: 'documents.view' },
  { name: 'Kanban', href: '/admin/kanban', icon: ViewColumnsIcon, permission: 'kanban.view' },
  { name: 'Relatórios', href: '/admin/relatorios', icon: ChartBarIcon, permission: 'reports.view' },
  { name: 'Usuários', href: '/admin/usuarios', icon: UserGroupIcon, permission: 'users.view' },
  { name: 'Configurações', href: '/admin/configuracoes', icon: Cog6ToothIcon, permission: 'settings.view' },
];

const Sidebar = ({ isOpen, onClose }) => {
  const location = useLocation();
  const { hasPermission } = useAuth();

  const filteredNavigation = navigation.filter(item => 
    !item.permission || hasPermission(item.permission)
  );

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && (
        <div 
          className="fixed inset-0 z-40 bg-black bg-opacity-25 lg:hidden" 
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <div
        className={`
          fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0
          ${isOpen ? 'translate-x-0' : '-translate-x-full'}
        `}
      >
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-center justify-between h-16 px-4 bg-gradient-erlene">
            <div className="flex items-center">
              <div className="flex-shrink-0 w-8 h-8 bg-white rounded-lg flex items-center justify-center">
                <span className="text-primary-800 font-bold text-lg">E</span>
              </div>
              <div className="ml-3 text-white">
                <p className="text-sm font-semibold">Erlene Advogados</p>
                <p className="text-xs opacity-75">Sistema Jurídico</p>
              </div>
            </div>

            <button
              type="button"
              className="lg:hidden text-white hover:text-gray-200"
              onClick={onClose}
            >
              <XMarkIcon className="h-6 w-6" />
            </button>
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
            {filteredNavigation.map((item) => {
              const isActive = location.pathname === item.href || 
                              (item.href !== '/admin' && location.pathname.startsWith(item.href));
              
              return (
                <NavLink
                  key={item.name}
                  to={item.href}
                  className={`
                    group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors
                    ${isActive
                      ? 'bg-primary-50 text-primary-700 border-r-2 border-primary-700'
                      : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                    }
                  `}
                  onClick={() => {
                    // Close mobile sidebar when item is clicked
                    if (window.innerWidth < 1024) {
                      onClose();
                    }
                  }}
                >
                  <item.icon
                    className={`
                      mr-3 h-5 w-5 flex-shrink-0
                      ${isActive ? 'text-primary-500' : 'text-gray-400 group-hover:text-gray-500'}
                    `}
                  />
                  {item.name}
                </NavLink>
              );
            })}
          </nav>

          {/* Footer */}
          <div className="px-4 py-4 border-t border-gray-200">
            <div className="text-xs text-gray-500 text-center">
              <p>© 2024 Erlene Advogados</p>
              <p>v1.0.0</p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Sidebar;
EOF

# src/components/layout/AdminLayout/index.js
cat > frontend/src/components/layout/AdminLayout/index.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import Header from '../../common/Header';
import Sidebar from '../../common/Sidebar';

// Mapeamento de títulos por rota
const routeTitles = {
  '/admin': 'Dashboard',
  '/admin/clientes': 'Clientes',
  '/admin/processos': 'Processos',
  '/admin/atendimentos': 'Atendimentos',
  '/admin/financeiro': 'Financeiro',
  '/admin/documentos': 'Documentos',
  '/admin/kanban': 'Kanban',
  '/admin/relatorios': 'Relatórios',
  '/admin/usuarios': 'Usuários',
  '/admin/configuracoes': 'Configurações',
};

const AdminLayout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();

  // Fechar sidebar em mudanças de rota (mobile)
  useEffect(() => {
    setSidebarOpen(false);
  }, [location.pathname]);

  // Obter título da página atual
  const getPageTitle = () => {
    const path = location.pathname;
    
    // Verificar rotas exatas primeiro
    if (routeTitles[path]) {
      return routeTitles[path];
    }
    
    // Verificar rotas que começam com o path
    for (const [route, title] of Object.entries(routeTitles)) {
      if (path.startsWith(route) && route !== '/admin') {
        return title;
      }
    }
    
    return 'Dashboard';
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <Sidebar 
        isOpen={sidebarOpen} 
        onClose={() => setSidebarOpen(false)} 
      />

      {/* Main content */}
      <div className="flex-1 flex flex-col overflow-hidden lg:ml-0">
        {/* Header */}
        <Header 
          onToggleSidebar={() => setSidebarOpen(!sidebarOpen)}
          title={getPageTitle()}
        />

        {/* Page content */}
        <main className="flex-1 overflow-y-auto bg-gray-50">
          <div className="py-6">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
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

# src/components/layout/PortalLayout/index.js
cat > frontend/src/components/layout/PortalLayout/index.js << 'EOF'
import React, { useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { 
  HomeIcon,
  ScaleIcon,
  DocumentIcon,
  CreditCardIcon,
  ChatBubbleLeftIcon,
  Bars3Icon,
  XMarkIcon,
  ArrowRightOnRectangleIcon
} from '@heroicons/react/24/outline';
import { useAuth } from '../../../hooks/auth/useAuth';

const navigation = [
  { name: 'Dashboard', href: '/portal', icon: HomeIcon },
  { name: 'Meus Processos', href: '/portal/processos', icon: ScaleIcon },
  { name: 'Documentos', href: '/portal/documentos', icon: DocumentIcon },
  { name: 'Pagamentos', href: '/portal/pagamentos', icon: CreditCardIcon },
  { name: 'Mensagens', href: '/portal/mensagens', icon: ChatBubbleLeftIcon },
];

const PortalLayout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();
  const { user, logout } = useAuth();

  const handleLogout = async () => {
    await logout();
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div 
          className="fixed inset-0 z-40 bg-black bg-opacity-25 lg:hidden" 
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div
        className={`
          fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0
          ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
        `}
      >
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-center justify-between h-16 px-4 bg-gradient-erlene">
            <div className="flex items-center">
              <div className="flex-shrink-0 w-8 h-8 bg-white rounded-lg flex items-center justify-center">
                <span className="text-primary-800 font-bold text-lg">E</span>
              </div>
              <div className="ml-3 text-white">
                <p className="text-sm font-semibold">Portal do Cliente</p>
                <p className="text-xs opacity-75">Erlene Advogados</p>
              </div>
            </div>

            <button
              type="button"
              className="lg:hidden text-white hover:text-gray-200"
              onClick={() => setSidebarOpen(false)}
            >
              <XMarkIcon className="h-6 w-6" />
            </button>
          </div>

          {/* User info */}
          <div className="px-4 py-4 border-b border-gray-200">
            <div className="flex items-center">
              <div className="flex-shrink-0 w-10 h-10 bg-gray-300 rounded-full flex items-center justify-center">
                <span className="text-gray-600 font-medium text-sm">
                  {user?.nome?.charAt(0) || 'U'}
                </span>
              </div>
              <div className="ml-3">
                <p className="text-sm font-medium text-gray-900">
                  {user?.nome || 'Cliente'}
                </p>
                <p className="text-xs text-gray-500">
                  {user?.email || 'cliente@email.com'}
                </p>
              </div>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
            {navigation.map((item) => {
              const isActive = location.pathname === item.href;
              
              return (
                <NavLink
                  key={item.name}
                  to={item.href}
                  className={`
                    group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors
                    ${isActive
                      ? 'bg-primary-50 text-primary-700 border-r-2 border-primary-700'
                      : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                    }
                  `}
                  onClick={() => {
                    if (window.innerWidth < 1024) {
                      setSidebarOpen(false);
                    }
                  }}
                >
                  <item.icon
                    className={`
                      mr-3 h-5 w-5 flex-shrink-0
                      ${isActive ? 'text-primary-500' : 'text-gray-400 group-hover:text-gray-500'}
                    `}
                  />
                  {item.name}
                </NavLink>
              );
            })}
          </nav>

          {/* Logout */}
          <div className="px-4 py-4 border-t border-gray-200">
            <button
              onClick={handleLogout}
              className="w-full flex items-center px-3 py-2 text-sm font-medium text-gray-600 rounded-lg hover:bg-gray-50 hover:text-gray-900 transition-colors"
            >
              <ArrowRightOnRectangleIcon className="mr-3 h-5 w-5 text-gray-400" />
              Sair
            </button>
          </div>
        </div>
      </div>

      {/* Main content */}
      <div className="flex-1 flex flex-col overflow-hidden lg:ml-0">
        {/* Header */}
        <header className="bg-white shadow-sm border-b border-gray-200">
          <div className="flex items-center justify-between h-16 px-4 sm:px-6 lg:px-8">
            <button
              type="button"
              className="lg:hidden -ml-0.5 -mt-0.5 h-12 w-12 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-gray-900"
              onClick={() => setSidebarOpen(!sidebarOpen)}
            >
              <Bars3Icon className="h-6 w-6" />
            </button>

            <h1 className="ml-4 lg:ml-0 text-xl font-semibold text-gray-900">
              Portal do Cliente
            </h1>

            <div className="text-sm text-gray-500">
              Bem-vindo, {user?.nome?.split(' ')[0] || 'Cliente'}
            </div>
          </div>
        </header>

        {/* Page content */}
        <main className="flex-1 overflow-y-auto bg-gray-50">
          <div className="py-6">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              {children}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
};

export default PortalLayout;
EOF

echo "✅ Layouts e interface criados com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • AuthLayout - Layout para login/registro"
echo "   • Header - Cabeçalho com menu do usuário"
echo "   • Sidebar - Menu lateral com navegação"
echo "   • AdminLayout - Layout principal do sistema"
echo "   • PortalLayout - Layout do portal do cliente"
echo ""
echo "🏗️ RECURSOS INCLUÍDOS:"
echo "   • Design responsivo mobile-first"
echo "   • Sidebar colapsível e mobile overlay"
echo "   • Menu de usuário com dropdown"
echo "   • Navegação ativa com highlight"
echo "   • Títulos dinâmicos por rota"
echo "   • Verificação de permissões"
echo "   • Portal do cliente diferenciado"
echo "   • Tema Erlene aplicado consistentemente"
echo ""
echo "⏭️  Próximo: Páginas principais (Dashboard, Clientes, etc)!"