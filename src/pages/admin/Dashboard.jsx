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
