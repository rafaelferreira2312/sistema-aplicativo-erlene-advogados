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
