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
