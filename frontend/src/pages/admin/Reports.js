import React, { useState, useEffect } from 'react';
import { 
  ChartBarIcon, 
  DocumentChartBarIcon,
  CurrencyDollarIcon,
  UsersIcon,
  ScaleIcon,
  CalendarIcon,
  ArrowLeftIcon
} from '@heroicons/react/24/outline';
import ReportClients from '../../components/reports/ReportClients';
import ReportFinancial from '../../components/reports/ReportFinancial';
import ReportProcesses from '../../components/reports/ReportProcesses';

const Reports = () => {
  const [selectedReport, setSelectedReport] = useState('overview');
  const [selectedPeriod, setSelectedPeriod] = useState('month');

  const reportTypes = [
    {
      id: 'clients',
      name: 'Relatório de Clientes',
      icon: UsersIcon,
      description: 'Análise completa da carteira de clientes',
      component: ReportClients
    },
    {
      id: 'processes',
      name: 'Relatório de Processos',
      icon: ScaleIcon,
      description: 'Análise de processos e andamentos',
      component: ReportProcesses
    },
    {
      id: 'financial',
      name: 'Relatório Financeiro',
      icon: CurrencyDollarIcon,
      description: 'Análise financeira e faturamento',
      component: ReportFinancial
    }
  ];

  const renderReportComponent = () => {
    const report = reportTypes.find(r => r.id === selectedReport);
    if (report && report.component) {
      const Component = report.component;
      return <Component period={selectedPeriod} />;
    }
    return null;
  };

  if (selectedReport !== 'overview') {
    return (
      <div className="space-y-6">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => setSelectedReport('overview')}
            className="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
          >
            <ArrowLeftIcon className="h-4 w-4 mr-2" />
            Voltar
          </button>
          <select
            value={selectedPeriod}
            onChange={(e) => setSelectedPeriod(e.target.value)}
            className="block rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-primary-500 focus:outline-none focus:ring-primary-500 sm:text-sm"
          >
            <option value="week">Esta Semana</option>
            <option value="month">Este Mês</option>
            <option value="quarter">Este Trimestre</option>
            <option value="year">Este Ano</option>
          </select>
        </div>
        {renderReportComponent()}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Relatórios</h1>
        <p className="mt-2 text-sm text-gray-700">
          Análises e relatórios gerenciais do escritório
        </p>
      </div>

      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {reportTypes.map((report) => (
          <div
            key={report.id}
            className="relative group bg-white p-6 border border-gray-200 rounded-lg hover:shadow-erlene-lg transition-all duration-200 cursor-pointer hover:border-primary-300"
            onClick={() => setSelectedReport(report.id)}
          >
            <div>
              <span className="rounded-lg inline-flex p-3 bg-primary-600 text-white">
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
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Reports;
