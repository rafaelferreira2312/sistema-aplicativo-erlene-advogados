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
