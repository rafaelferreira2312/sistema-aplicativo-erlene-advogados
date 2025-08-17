#!/bin/bash
# Script 106b - Componentes de Relatórios (Parte 2/3)
# Autor: Sistema Erlene Advogados  
# Data: $(date +%Y-%m-%d)
# Enumeração: 106b

echo "🔧 Criando Componentes de Relatórios (Parte 2 - Script 106b)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto frontend"
    exit 1
fi

# Criar componente de relatório de clientes
echo "📊 Criando ReportClients.js..."
cat > frontend/src/components/reports/ReportClients.js << 'EOF'
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
EOF

# Criar componente de relatório financeiro
echo "💰 Criando ReportFinancial.js..."
cat > frontend/src/components/reports/ReportFinancial.js << 'EOF'
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
EOF

echo "✅ Componentes de Relatórios criados com sucesso!"
echo ""
echo "📋 COMPONENTES CRIADOS:"
echo "   • ReportClients.js - Relatório detalhado de clientes"
echo "   • ReportFinancial.js - Relatório financeiro completo"
echo ""
echo "🔍 FUNCIONALIDADES DOS COMPONENTES:"
echo "   • Estatísticas detalhadas com cards informativos"
echo "   • Gráficos simplificados em barras"
echo "   • Tabelas com top clientes/dados financeiros"
echo "   • Distribuição por tipo de cliente"
echo "   • Evolução mensal de receitas e despesas"
echo "   • Formatação monetária brasileira"
echo "   • Indicadores de crescimento com ícones"
echo ""
echo "📁 ARQUIVOS CRIADOS:"
echo "   • frontend/src/components/reports/ReportClients.js"
echo "   • frontend/src/components/reports/ReportFinancial.js"
echo ""
echo "⏭️ PRÓXIMA PARTE (3/3):"
echo "   • Relatório de processos"
echo "   • Integração dos componentes na página principal"
echo "   • Atualização das rotas"
echo ""
echo "Digite 'continuar' para Parte 3/3!"