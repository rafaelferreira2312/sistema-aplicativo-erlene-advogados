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
    { title: 'Novo Cliente', icon: '👤', color: 'blue', href: '/admin/clientes/novo' },
    { title: 'Novo Processo', icon: '⚖️', color: 'green', href: '/admin/processos/novo' },
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
