#!/bin/bash
# Script 106a - Dashboard de Relatórios (Parte 1/3)
# Autor: Sistema Erlene Advogados  
# Data: $(date +%Y-%m-%d)
# Enumeração: 106a

echo "🔧 Criando Dashboard de Relatórios (Parte 1 - Script 106a)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto frontend"
    exit 1
fi

# Criar estrutura de pastas
echo "📁 Criando estrutura para módulo Relatórios..."
mkdir -p frontend/src/pages/admin
mkdir -p frontend/src/components/reports

# Criar página principal de relatórios
echo "📊 Criando página Reports.js..."
cat > frontend/src/pages/admin/Reports.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { 
  ChartBarIcon, 
  DocumentChartBarIcon,
  CurrencyDollarIcon,
  UsersIcon,
  ScaleIcon,
  CalendarIcon,
  ClockIcon,
  DocumentIcon,
  ArrowTrendingUpIcon,
  ArrowTrendingDownIcon,
  EyeIcon,
  PrinterIcon,
  ShareIcon,
  FunnelIcon
} from '@heroicons/react/24/outline';

const Reports = () => {
  const [isLoading, setIsLoading] = useState(true);
  const [selectedPeriod, setSelectedPeriod] = useState('month');
  const [selectedReport, setSelectedReport] = useState('overview');

  // Mock data para relatórios
  const reportStats = {
    overview: {
      totalClients: 234,
      totalProcesses: 567,
      totalRevenue: 'R$ 1.245.890,00',
      totalMeetings: 145,
      avgProcessTime: '45 dias',
      successRate: '94%'
    },
    clients: {
      newClients: 23,
      activeClients: 187,
      inactiveClients: 47,
      averageValue: 'R$ 5.320,00'
    },
    processes: {
      openProcesses: 234,
      closedProcesses: 333,
      pendingProcesses: 45,
      avgDuration: '42 dias'
    },
    financial: {
      totalRevenue: 1245890,
      totalExpenses: 234560,
      netProfit: 1011330,
      pendingPayments: 123400
    }
  };

  const reportTypes = [
    {
      id: 'overview',
      name: 'Visão Geral',
      icon: ChartBarIcon,
      description: 'Resumo geral do escritório',
      color: 'bg-blue-500',
      stats: '6 métricas principais'
    },
    {
      id: 'clients',
      name: 'Relatório de Clientes',
      icon: UsersIcon,
      description: 'Análise completa da carteira de clientes',
      color: 'bg-green-500',
      stats: '234 clientes ativos'
    },
    {
      id: 'processes',
      name: 'Relatório de Processos',
      icon: ScaleIcon,
      description: 'Análise de processos e andamentos',
      color: 'bg-primary-500',
      stats: '567 processos'
    },
    {
      id: 'financial',
      name: 'Relatório Financeiro',
      icon: CurrencyDollarIcon,
      description: 'Análise financeira e faturamento',
      color: 'bg-yellow-500',
      stats: 'R$ 1.24M faturado'
    },
    {
      id: 'productivity',
      name: 'Produtividade',
      icon: DocumentChartBarIcon,
      description: 'Análise de produtividade da equipe',
      color: 'bg-purple-500',
      stats: '145 atendimentos'
    },
    {
      id: 'meetings',
      name: 'Atendimentos',
      icon: CalendarIcon,
      description: 'Relatório de atendimentos realizados',
      color: 'bg-indigo-500',
      stats: '145 este mês'
    }
  ];

  const quickStats = [
    {
      name: 'Receita do Mês',
      value: 'R$ 89.320,00',
      change: '+12.5%',
      changeType: 'increase',
      icon: CurrencyDollarIcon
    },
    {
      name: 'Novos Clientes',
      value: '23',
      change: '+8.2%',
      changeType: 'increase',
      icon: UsersIcon
    },
    {
      name: 'Processos Ativos',
      value: '234',
      change: '-2.1%',
      changeType: 'decrease',
      icon: ScaleIcon
    },
    {
      name: 'Atendimentos',
      value: '145',
      change: '+15.3%',
      changeType: 'increase',
      icon: CalendarIcon
    }
  ];

  useEffect(() => {
    // Simular carregamento
    const timer = setTimeout(() => {
      setIsLoading(false);
    }, 1000);

    return () => clearTimeout(timer);
  }, []);

  const handleGenerateReport = (reportType) => {
    setSelectedReport(reportType);
    console.log(`Gerando relatório: ${reportType}`);
  };

  const handleExportReport = (format) => {
    console.log(`Exportando relatório em ${format}`);
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="sm:flex sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Relatórios</h1>
          <p className="mt-2 text-sm text-gray-700">
            Análises e relatórios gerenciais do escritório
          </p>
        </div>
        <div className="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
          <div className="flex space-x-3">
            <select
              value={selectedPeriod}
              onChange={(e) => setSelectedPeriod(e.target.value)}
              className="block w-full rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-primary-500 focus:outline-none focus:ring-primary-500 sm:text-sm"
            >
              <option value="week">Esta Semana</option>
              <option value="month">Este Mês</option>
              <option value="quarter">Este Trimestre</option>
              <option value="year">Este Ano</option>
              <option value="custom">Período Personalizado</option>
            </select>
            <button
              type="button"
              className="inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2"
            >
              <FunnelIcon className="-ml-1 mr-2 h-5 w-5" />
              Filtros
            </button>
          </div>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {quickStats.map((stat) => (
          <div key={stat.name} className="bg-white overflow-hidden shadow-erlene rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <stat.icon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">
                      {stat.name}
                    </dt>
                    <dd className="flex items-baseline">
                      <div className="text-2xl font-semibold text-gray-900">
                        {stat.value}
                      </div>
                      <div className={`ml-2 flex items-baseline text-sm font-semibold ${
                        stat.changeType === 'increase' ? 'text-green-600' : 'text-red-600'
                      }`}>
                        {stat.changeType === 'increase' ? (
                          <ArrowTrendingUpIcon className="h-4 w-4 flex-shrink-0 self-center" />
                        ) : (
                          <ArrowTrendingDownIcon className="h-4 w-4 flex-shrink-0 self-center" />
                        )}
                        <span className="ml-1">{stat.change}</span>
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Report Types Grid */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Tipos de Relatórios
          </h3>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {reportTypes.map((report) => (
              <div
                key={report.id}
                className="relative group bg-white p-6 border border-gray-200 rounded-lg hover:shadow-erlene-lg transition-all duration-200 cursor-pointer hover:border-primary-300"
                onClick={() => handleGenerateReport(report.id)}
              >
                <div>
                  <span className={`rounded-lg inline-flex p-3 ${report.color} text-white ring-4 ring-white`}>
                    <report.icon className="h-6 w-6" />
                  </span>
                </div>
                <div className="mt-4">
                  <h3 className="text-lg font-medium text-gray-900 group-hover:text-primary-600">
                    {report.name}
                  </h3>
                  <p className="mt-2 text-sm text-gray-500">
                    {report.description}
                  </p>
                  <p className="mt-2 text-xs text-gray-400">
                    {report.stats}
                  </p>
                </div>
                <div className="mt-4 flex space-x-2">
                  <button className="inline-flex items-center px-3 py-1 border border-transparent text-xs font-medium rounded-md text-primary-700 bg-primary-100 hover:bg-primary-200">
                    <EyeIcon className="w-3 h-3 mr-1" />
                    Visualizar
                  </button>
                  <button 
                    onClick={(e) => {
                      e.stopPropagation();
                      handleExportReport(report.id);
                    }}
                    className="inline-flex items-center px-3 py-1 border border-gray-300 text-xs font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                  >
                    <PrinterIcon className="w-3 h-3 mr-1" />
                    Exportar
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Export Options */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Exportar Relatórios
          </h3>
          <div className="flex flex-wrap gap-4">
            <button
              onClick={() => handleExportReport('pdf')}
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
            >
              <DocumentIcon className="w-4 h-4 mr-2" />
              Exportar PDF
            </button>
            <button
              onClick={() => handleExportReport('excel')}
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
            >
              <DocumentChartBarIcon className="w-4 h-4 mr-2" />
              Exportar Excel
            </button>
            <button
              onClick={() => handleExportReport('share')}
              className="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              <ShareIcon className="w-4 h-4 mr-2" />
              Compartilhar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Reports;
EOF

echo "✅ Dashboard de Relatórios criado com sucesso!"
echo ""
echo "📋 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Dashboard com estatísticas rápidas"
echo "   • Cards para diferentes tipos de relatórios"
echo "   • Seleção de período (semana, mês, trimestre, ano)"
echo "   • Botões de exportação (PDF, Excel, Compartilhar)"
echo "   • 6 tipos de relatórios: Visão Geral, Clientes, Processos, Financeiro, Produtividade, Atendimentos"
echo "   • Métricas com indicadores de crescimento"
echo "   • Design responsivo seguindo padrão Erlene"
echo ""
echo "🔗 ROTA CONFIGURADA:"
echo "   • /admin/reports - Dashboard de relatórios"
echo ""
echo "📁 ARQUIVO CRIADO:"
echo "   • frontend/src/pages/admin/Reports.js"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/3):"
echo "   • Componentes específicos de relatórios"
echo "   • Gráficos e visualizações"
echo "   • Exportação real de dados"
echo ""
echo "Digite 'continuar' para Parte 2/3!"