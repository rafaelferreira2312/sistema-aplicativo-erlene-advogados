import React, { useState } from 'react';
import { 
  CurrencyDollarIcon,
  ArrowTrendingUpIcon,
  ArrowTrendingDownIcon,
  BanknotesIcon,
  CreditCardIcon
} from '@heroicons/react/24/outline';

const ReportFinancial = ({ period = 'month' }) => {
  const [viewType, setViewType] = useState('overview');

  // Mock data financeiro
  const financialData = {
    revenue: {
      total: 245890,
      growth: 15.3,
      thisMonth: 89320,
      lastMonth: 77450
    },
    expenses: {
      total: 89450,
      growth: -5.2,
      thisMonth: 32100,
      lastMonth: 33850
    },
    profit: {
      net: 156440,
      margin: 63.5,
      growth: 23.8
    },
    pending: {
      receivable: 123400,
      payable: 45600,
      overdue: 23400
    }
  };

  const monthlyData = [
    { month: 'Jan', revenue: 78900, expenses: 28900, profit: 50000 },
    { month: 'Fev', revenue: 85200, expenses: 31200, profit: 54000 },
    { month: 'Mar', revenue: 92300, expenses: 29800, profit: 62500 },
    { month: 'Abr', revenue: 88700, expenses: 33100, profit: 55600 },
    { month: 'Mai', revenue: 95400, expenses: 32400, profit: 63000 },
    { month: 'Jun', revenue: 89320, expenses: 32100, profit: 57220 }
  ];

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-xl font-bold text-gray-900">Relatório Financeiro</h2>
        <p className="mt-1 text-sm text-gray-600">
          Análise financeira detalhada - {period === 'month' ? 'Este Mês' : 'Período Selecionado'}
        </p>
      </div>

      {/* Financial KPIs */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white overflow-hidden shadow-erlene rounded-lg border-l-4 border-green-500">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <CurrencyDollarIcon className="h-6 w-6 text-green-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Receita Total</dt>
                  <dd className="text-xl font-bold text-green-600">
                    {formatCurrency(financialData.revenue.total)}
                  </dd>
                  <dd className="text-sm text-green-600 flex items-center">
                    <ArrowTrendingUpIcon className="h-4 w-4 mr-1" />
                    +{financialData.revenue.growth}%
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg border-l-4 border-red-500">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <BanknotesIcon className="h-6 w-6 text-red-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Despesas</dt>
                  <dd className="text-xl font-bold text-red-600">
                    {formatCurrency(financialData.expenses.total)}
                  </dd>
                  <dd className="text-sm text-green-600 flex items-center">
                    <ArrowTrendingDownIcon className="h-4 w-4 mr-1" />
                    {financialData.expenses.growth}%
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg border-l-4 border-blue-500">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ArrowTrendingUpIcon className="h-6 w-6 text-blue-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Lucro Líquido</dt>
                  <dd className="text-xl font-bold text-blue-600">
                    {formatCurrency(financialData.profit.net)}
                  </dd>
                  <dd className="text-sm text-blue-600">
                    Margem: {financialData.profit.margin}%
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg border-l-4 border-yellow-500">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <CreditCardIcon className="h-6 w-6 text-yellow-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">A Receber</dt>
                  <dd className="text-xl font-bold text-yellow-600">
                    {formatCurrency(financialData.pending.receivable)}
                  </dd>
                  <dd className="text-sm text-red-600">
                    Vencido: {formatCurrency(financialData.pending.overdue)}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Monthly Evolution */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Evolução Mensal (Últimos 6 Meses)
          </h3>
          <div className="space-y-4">
            {monthlyData.map((month) => (
              <div key={month.month} className="border-b border-gray-100 pb-4 last:border-b-0">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium text-gray-700">{month.month}</span>
                  <span className="text-sm font-bold text-gray-900">
                    Lucro: {formatCurrency(month.profit)}
                  </span>
                </div>
                <div className="grid grid-cols-3 gap-4 text-sm">
                  <div>
                    <span className="text-gray-500">Receita:</span>
                    <span className="ml-2 font-medium text-green-600">
                      {formatCurrency(month.revenue)}
                    </span>
                  </div>
                  <div>
                    <span className="text-gray-500">Despesas:</span>
                    <span className="ml-2 font-medium text-red-600">
                      {formatCurrency(month.expenses)}
                    </span>
                  </div>
                  <div>
                    <span className="text-gray-500">Margem:</span>
                    <span className="ml-2 font-medium text-blue-600">
                      {((month.profit / month.revenue) * 100).toFixed(1)}%
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

export default ReportFinancial;
