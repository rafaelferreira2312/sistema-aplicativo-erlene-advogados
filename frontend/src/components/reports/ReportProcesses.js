import React, { useState } from 'react';
import { 
  ScaleIcon,
  ClockIcon,
  CheckCircleIcon,
  ExclamationTriangleIcon,
  DocumentIcon,
  ArrowTrendingUpIcon
} from '@heroicons/react/24/outline';

const ReportProcesses = ({ period = 'month' }) => {
  // Mock data para relatório de processos
  const processStats = {
    total: 567,
    active: 234,
    completed: 333,
    pending: 45,
    avgDuration: 42,
    successRate: 94.2
  };

  const processByStatus = [
    { status: 'Em Andamento', count: 234, percentage: 41.3, color: 'bg-blue-500' },
    { status: 'Concluídos', count: 333, percentage: 58.7, color: 'bg-green-500' },
    { status: 'Pendentes', count: 45, percentage: 7.9, color: 'bg-yellow-500' },
    { status: 'Suspensos', count: 12, percentage: 2.1, color: 'bg-red-500' }
  ];

  const processByArea = [
    { area: 'Direito Civil', count: 145, value: 'R$ 345.000', color: 'bg-blue-500' },
    { area: 'Direito Trabalhista', count: 98, value: 'R$ 234.000', color: 'bg-green-500' },
    { area: 'Direito Criminal', count: 87, value: 'R$ 189.000', color: 'bg-red-500' },
    { area: 'Direito Empresarial', count: 76, value: 'R$ 298.000', color: 'bg-purple-500' },
    { area: 'Direito de Família', count: 161, value: 'R$ 423.000', color: 'bg-yellow-500' }
  ];

  const recentProcesses = [
    { 
      number: '5001234-56.2024.8.02.0001', 
      client: 'João Silva Santos', 
      area: 'Direito Civil',
      status: 'Em Andamento',
      lastUpdate: '2024-03-15',
      priority: 'Alta'
    },
    { 
      number: '5001235-67.2024.8.02.0001', 
      client: 'Maria Oliveira Costa', 
      area: 'Direito Trabalhista',
      status: 'Concluído',
      lastUpdate: '2024-03-14',
      priority: 'Média'
    },
    { 
      number: '5001236-78.2024.8.02.0001', 
      client: 'Empresa ABC Ltda', 
      area: 'Direito Empresarial',
      status: 'Pendente',
      lastUpdate: '2024-03-13',
      priority: 'Alta'
    }
  ];

  const monthlyProcesses = [
    { month: 'Jan', new: 23, completed: 18, active: 89 },
    { month: 'Fev', new: 28, completed: 22, active: 95 },
    { month: 'Mar', new: 31, completed: 25, active: 101 },
    { month: 'Abr', new: 26, completed: 29, active: 98 },
    { month: 'Mai', new: 34, completed: 31, active: 101 },
    { month: 'Jun', new: 29, completed: 27, active: 103 }
  ];

  const getStatusColor = (status) => {
    switch (status) {
      case 'Em Andamento': return 'bg-blue-100 text-blue-800';
      case 'Concluído': return 'bg-green-100 text-green-800';
      case 'Pendente': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'Alta': return 'bg-red-100 text-red-800';
      case 'Média': return 'bg-yellow-100 text-yellow-800';
      case 'Baixa': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-xl font-bold text-gray-900">Relatório de Processos</h2>
        <p className="mt-1 text-sm text-gray-600">
          Análise detalhada dos processos judiciais - {period === 'month' ? 'Este Mês' : 'Período Selecionado'}
        </p>
      </div>

      {/* Process Stats */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ScaleIcon className="h-6 w-6 text-primary-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Total de Processos</dt>
                  <dd className="text-2xl font-bold text-gray-900">{processStats.total}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ClockIcon className="h-6 w-6 text-blue-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Em Andamento</dt>
                  <dd className="text-2xl font-bold text-blue-600">{processStats.active}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <CheckCircleIcon className="h-6 w-6 text-green-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Concluídos</dt>
                  <dd className="text-2xl font-bold text-green-600">{processStats.completed}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ArrowTrendingUpIcon className="h-6 w-6 text-purple-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Taxa de Sucesso</dt>
                  <dd className="text-2xl font-bold text-purple-600">{processStats.successRate}%</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Process by Area */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Processos por Área Jurídica
          </h3>
          <div className="space-y-4">
            {processByArea.map((area) => (
              <div key={area.area} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
                <div className="flex items-center space-x-3">
                  <div className={`w-4 h-4 rounded-full ${area.color}`}></div>
                  <div>
                    <div className="text-sm font-medium text-gray-900">{area.area}</div>
                    <div className="text-sm text-gray-500">{area.count} processos</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-sm font-medium text-gray-900">{area.value}</div>
                  <div className="text-sm text-gray-500">Valor total</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Recent Processes */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Processos Recentes
          </h3>
          <div className="overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Número do Processo
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Cliente
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Área
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Prioridade
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {recentProcesses.map((process, index) => (
                  <tr key={index} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-mono text-gray-900">{process.number}</div>
                      <div className="text-sm text-gray-500">{process.lastUpdate}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">{process.client}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{process.area}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(process.status)}`}>
                        {process.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(process.priority)}`}>
                        {process.priority}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Monthly Evolution */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Evolução Mensal de Processos
          </h3>
          <div className="space-y-4">
            {monthlyProcesses.map((month) => (
              <div key={month.month} className="border-b border-gray-100 pb-4 last:border-b-0">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium text-gray-700">{month.month}</span>
                  <span className="text-sm font-bold text-gray-900">
                    Ativos: {month.active}
                  </span>
                </div>
                <div className="grid grid-cols-3 gap-4 text-sm">
                  <div>
                    <span className="text-gray-500">Novos:</span>
                    <span className="ml-2 font-medium text-blue-600">{month.new}</span>
                  </div>
                  <div>
                    <span className="text-gray-500">Concluídos:</span>
                    <span className="ml-2 font-medium text-green-600">{month.completed}</span>
                  </div>
                  <div>
                    <span className="text-gray-500">Taxa:</span>
                    <span className="ml-2 font-medium text-purple-600">
                      {((month.completed / (month.new + month.completed)) * 100).toFixed(1)}%
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ReportProcesses;
