import React, { useState, useEffect } from 'react';
import PortalLayout from '../../components/portal/layout/PortalLayout';
import {
  ScaleIcon,
  DocumentIcon,
  CreditCardIcon,
  ExclamationTriangleIcon,
  CalendarDaysIcon
} from '@heroicons/react/24/outline';

const PortalDashboard = () => {
  const [clienteData, setClienteData] = useState(null);
  const [dashboardData, setDashboardData] = useState(null);

  useEffect(() => {
    const data = localStorage.getItem('clienteData');
    if (data) {
      const cliente = JSON.parse(data);
      setClienteData(cliente);
      
      // Simular dados do dashboard baseado no cliente
      setDashboardData({
        processos: {
          total: cliente.processos,
          em_andamento: cliente.processos - 1,
          finalizados: Math.max(0, cliente.processos - 2),
          proximas_audiencias: 1
        },
        documentos: {
          total: cliente.documentos,
          pendentes: Math.floor(cliente.documentos * 0.2),
          recentes: Math.floor(cliente.documentos * 0.3)
        },
        financeiro: {
          pendentes: cliente.pagamentos_pendentes,
          valor_total: cliente.valor_pendente,
          proximos_vencimentos: cliente.pagamentos_pendentes
        },
        atividades_recentes: [
          {
            id: 1,
            tipo: 'processo',
            descricao: 'Nova movimentação no processo 1234567-89.2024.8.26.0100',
            data: '2024-01-15T10:30:00',
            icon: ScaleIcon,
            cor: 'text-blue-600'
          },
          {
            id: 2,
            tipo: 'documento',
            descricao: 'Documento "Contrato Social" foi enviado',
            data: '2024-01-14T16:45:00',
            icon: DocumentIcon,
            cor: 'text-green-600'
          },
          {
            id: 3,
            tipo: 'pagamento',
            descricao: 'Boleto de honorários vence em 5 dias',
            data: '2024-01-13T09:15:00',
            icon: CreditCardIcon,
            cor: 'text-yellow-600'
          }
        ]
      });
    }
  }, []);

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (!clienteData || !dashboardData) {
    return (
      <PortalLayout>
        <div className="flex items-center justify-center h-full">
          <div className="animate-spin rounded-full h-8 w-8 border-2 border-red-700 border-t-transparent"></div>
        </div>
      </PortalLayout>
    );
  }

  const cards = [
    {
      title: 'Meus Processos',
      total: dashboardData.processos.total,
      subtitle: `${dashboardData.processos.em_andamento} em andamento`,
      icon: ScaleIcon,
      color: 'red',
      href: '/portal/processos'
    },
    {
      title: 'Documentos',
      total: dashboardData.documentos.total,
      subtitle: `${dashboardData.documentos.pendentes} pendentes`,
      icon: DocumentIcon,
      color: 'blue',
      href: '/portal/documentos'
    },
    {
      title: 'Pagamentos',
      total: dashboardData.financeiro.pendentes,
      subtitle: formatCurrency(dashboardData.financeiro.valor_total),
      icon: CreditCardIcon,
      color: 'green',
      href: '/portal/pagamentos'
    },
    {
      title: 'Próximas Audiências',
      total: dashboardData.processos.proximas_audiencias,
      subtitle: 'Neste mês',
      icon: CalendarDaysIcon,
      color: 'purple',
      href: '/portal/processos'
    }
  ];

  return (
    <PortalLayout>
      <div className="p-6">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-gray-900">
            Bem-vindo, {clienteData.nome.split(' ')[0]}!
          </h1>
          <p className="text-gray-600 mt-1">
            Acompanhe o andamento dos seus processos e documentos
          </p>
        </div>

        {/* Cards de Estatísticas */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4 mb-8">
          {cards.map((card) => {
            const Icon = card.icon;
            return (
              <div
                key={card.title}
                className="bg-white overflow-hidden shadow-lg shadow-red-100 rounded-lg hover:shadow-xl transition-shadow duration-300 cursor-pointer"
                onClick={() => window.location.href = card.href}
              >
                <div className="p-6">
                  <div className="flex items-center">
                    <div className={`flex-shrink-0 p-3 rounded-lg bg-${card.color}-100`}>
                      <Icon className={`h-6 w-6 text-${card.color}-600`} />
                    </div>
                    <div className="ml-4">
                      <h3 className="text-lg font-medium text-gray-900">
                        {card.title}
                      </h3>
                      <div className="mt-1">
                        <span className="text-3xl font-bold text-gray-900">
                          {card.total}
                        </span>
                        <p className="text-sm text-gray-500 mt-1">
                          {card.subtitle}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Grid Principal */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Atividades Recentes */}
          <div className="lg:col-span-2">
            <div className="bg-white shadow-lg shadow-red-100 rounded-lg">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-medium text-gray-900">
                  Atividades Recentes
                </h2>
              </div>
              <div className="p-6">
                <div className="space-y-4">
                  {dashboardData.atividades_recentes.map((atividade) => {
                    const Icon = atividade.icon;
                    return (
                      <div key={atividade.id} className="flex items-start space-x-3">
                        <div className="flex-shrink-0">
                          <Icon className={`h-5 w-5 ${atividade.cor}`} />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm text-gray-900">
                            {atividade.descricao}
                          </p>
                          <p className="text-xs text-gray-500 mt-1">
                            {formatDate(atividade.data)}
                          </p>
                        </div>
                      </div>
                    );
                  })}
                </div>
                
                <div className="mt-6">
                  <button className="text-sm text-red-600 hover:text-red-700 font-medium">
                    Ver todas as atividades →
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Resumo Rápido */}
          <div className="space-y-6">
            {/* Status dos Processos */}
            <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Status dos Processos
              </h3>
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <div className="w-3 h-3 bg-green-500 rounded-full mr-2"></div>
                    <span className="text-sm text-gray-700">Em andamento</span>
                  </div>
                  <span className="text-sm font-medium text-gray-900">
                    {dashboardData.processos.em_andamento}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <div className="w-3 h-3 bg-blue-500 rounded-full mr-2"></div>
                    <span className="text-sm text-gray-700">Finalizados</span>
                  </div>
                  <span className="text-sm font-medium text-gray-900">
                    {dashboardData.processos.finalizados}
                  </span>
                </div>
              </div>
            </div>

            {/* Pagamentos Pendentes */}
            {dashboardData.financeiro.pendentes > 0 && (
              <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">
                  Pagamentos Pendentes
                </h3>
                <div className="text-center">
                  <ExclamationTriangleIcon className="h-8 w-8 text-yellow-500 mx-auto mb-2" />
                  <p className="text-2xl font-bold text-gray-900">
                    {formatCurrency(dashboardData.financeiro.valor_total)}
                  </p>
                  <p className="text-sm text-gray-500 mt-1">
                    {dashboardData.financeiro.pendentes} pagamento(s) pendente(s)
                  </p>
                  <button className="mt-3 text-sm text-red-600 hover:text-red-700 font-medium">
                    Ver detalhes →
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </PortalLayout>
  );
};

export default PortalDashboard;
