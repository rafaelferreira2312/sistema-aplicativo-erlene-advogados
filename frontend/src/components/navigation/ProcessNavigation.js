import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  ScaleIcon,
  CalendarIcon,
  ClockIcon,
  ChartBarIcon,
  Squares2X2Icon
} from '@heroicons/react/24/outline';

const ProcessNavigation = () => {
  const location = useLocation();

  const navigationItems = [
    {
      name: 'Processos',
      href: '/admin/processos',
      icon: ScaleIcon,
      description: 'Lista geral de processos'
    },
    {
      name: 'Audiências',
      href: '/admin/audiencias', 
      icon: CalendarIcon,
      description: 'Audiências agendadas'
    },
    {
      name: 'Prazos',
      href: '/admin/prazos',
      icon: ClockIcon,
      description: 'Prazos vencendo'
    },
    {
      name: 'Kanban',
      href: '/admin/processos/kanban',
      icon: Squares2X2Icon,
      description: 'Visualização em quadros'
    },
    {
      name: 'Relatórios',
      href: '/admin/relatorios/processos',
      icon: ChartBarIcon,
      description: 'Relatórios de processos'
    }
  ];

  return (
    <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6 mb-8">
      <h2 className="text-lg font-semibold text-gray-900 mb-4">Navegação Rápida</h2>
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        {navigationItems.map((item) => {
          const isActive = location.pathname === item.href;
          return (
            <Link
              key={item.name}
              to={item.href}
              className={`flex flex-col items-center p-4 rounded-lg transition-all duration-200 ${
                isActive 
                  ? 'bg-primary-50 border-2 border-primary-200 text-primary-700' 
                  : 'bg-gray-50 border-2 border-transparent hover:bg-gray-100 text-gray-600 hover:text-gray-900'
              }`}
            >
              <item.icon className={`w-6 h-6 mb-2 ${isActive ? 'text-primary-600' : 'text-gray-400'}`} />
              <span className="text-sm font-medium text-center">{item.name}</span>
              <span className="text-xs text-center mt-1 opacity-75">{item.description}</span>
            </Link>
          );
        })}
      </div>
    </div>
  );
};

export default ProcessNavigation;
