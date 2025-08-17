import React, { useState } from 'react';
import { 
  UsersIcon, 
  ArrowTrendingUpIcon,
  ArrowTrendingDownIcon,
  EyeIcon,
  DocumentArrowDownIcon
} from '@heroicons/react/24/outline';

const ReportClients = ({ period = 'month' }) => {
  const [viewType, setViewType] = useState('chart');

  // Mock data para relatório de clientes
  const clientStats = {
    total: 234,
    new: 23,
    active: 187,
    inactive: 47,
    averageValue: 5320.50,
    growth: 12.5
  };

  const clientsByType = [
    { type: 'Pessoa Física', count: 156, percentage: 66.7, color: 'bg-blue-500' },
    { type: 'Pessoa Jurídica', count: 78, percentage: 33.3, color: 'bg-green-500' }
  ];

  const topClients = [
    { name: 'João Silva Santos', type: 'PF', processes: 12, value: 45000, status: 'Ativo' },
    { name: 'Empresa ABC Ltda', type: 'PJ', processes: 8, value: 78000, status: 'Ativo' },
    { name: 'Maria Oliveira Costa', type: 'PF', processes: 6, value: 23000, status: 'Ativo' },
    { name: 'Tech Solutions S.A.', type: 'PJ', processes: 15, value: 125000, status: 'Ativo' },
    { name: 'Carlos Roberto Lima', type: 'PF', processes: 4, value: 18000, status: 'Inativo' }
  ];

  const clientsByMonth = [
    { month: 'Jan', new: 18, total: 201 },
    { month: 'Fev', new: 15, total: 216 },
    { month: 'Mar', new: 22, total: 238 },
    { month: 'Abr', new: 19, total: 257 },
    { month: 'Mai', new: 25, total: 282 },
    { month: 'Jun', new: 23, total: 305 }
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="sm:flex sm:items-center sm:justify-between">
        <div>
          <h2 className="text-xl font-bold text-gray-900">Relatório de Clientes</h2>
          <p className="mt-1 text-sm text-gray-600">
            Análise detalhada da carteira de clientes - {period === 'month' ? 'Este Mês' : 'Período Selecionado'}
          </p>
        </div>
        <div className="mt-4 sm:mt-0 flex space-x-3">
          <button
            onClick={() => setViewType(viewType === 'chart' ? 'table' : 'chart')}
            className="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
          >
            <EyeIcon className="h-4 w-4 mr-2" />
            {viewType === 'chart' ? 'Ver Tabela' : 'Ver Gráficos'}
          </button>
          <button className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700">
            <DocumentArrowDownIcon className="h-4 w-4 mr-2" />
            Exportar
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <UsersIcon className="h-6 w-6 text-blue-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Total de Clientes</dt>
                  <dd className="text-2xl font-bold text-gray-900">{clientStats.total}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ArrowTrendingUpIcon className="h-6 w-6 text-green-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Novos Clientes</dt>
                  <dd className="text-2xl font-bold text-green-600">+{clientStats.new}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <UsersIcon className="h-6 w-6 text-primary-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Clientes Ativos</dt>
                  <dd className="text-2xl font-bold text-gray-900">{clientStats.active}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ArrowTrendingUpIcon className="h-6 w-6 text-yellow-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Ticket Médio</dt>
                  <dd className="text-2xl font-bold text-gray-900">
                    R$ {clientStats.averageValue.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Distribution by Type */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Distribuição por Tipo
          </h3>
          <div className="space-y-4">
            {clientsByType.map((item) => (
              <div key={item.type}>
                <div className="flex items-center justify-between text-sm">
                  <span className="font-medium text-gray-900">{item.type}</span>
                  <span className="text-gray-600">{item.count} clientes ({item.percentage}%)</span>
                </div>
                <div className="mt-2 bg-gray-200 rounded-full h-2">
                  <div 
                    className={`h-2 rounded-full ${item.color}`}
                    style={{ width: `${item.percentage}%` }}
                  ></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Top Clients Table */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Top 5 Clientes por Valor
          </h3>
          <div className="overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Cliente
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Tipo
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Processos
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Valor Total
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {topClients.map((client, index) => (
                  <tr key={index} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">{client.name}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        client.type === 'PF' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'
                      }`}>
                        {client.type}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {client.processes}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      R$ {client.value.toLocaleString('pt-BR')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        client.status === 'Ativo' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {client.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Growth Chart (Simplified) */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Evolução de Clientes (Últimos 6 Meses)
          </h3>
          <div className="space-y-4">
            {clientsByMonth.map((month) => (
              <div key={month.month} className="flex items-center space-x-4">
                <div className="w-12 text-sm font-medium text-gray-700">
                  {month.month}
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between text-sm mb-1">
                    <span className="text-gray-600">Novos: {month.new}</span>
                    <span className="text-gray-900 font-medium">Total: {month.total}</span>
                  </div>
                  <div className="bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-primary-500 h-2 rounded-full"
                      style={{ width: `${(month.total / 400) * 100}%` }}
                    ></div>
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

export default ReportClients;
