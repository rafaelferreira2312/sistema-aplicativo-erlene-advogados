import React, { useState, useEffect } from 'react';
import PortalLayout from '../../components/portal/layout/PortalLayout';
import {
  ScaleIcon,
  ClockIcon,
  CheckCircleIcon,
  ExclamationCircleIcon,
  CalendarDaysIcon,
  EyeIcon,
  DocumentIcon
} from '@heroicons/react/24/outline';

const PortalProcessos = () => {
  const [clienteData, setClienteData] = useState(null);
  const [processos, setProcessos] = useState([]);
  const [filtro, setFiltro] = useState('todos');

  useEffect(() => {
    const data = localStorage.getItem('clienteData');
    if (data) {
      const cliente = JSON.parse(data);
      setClienteData(cliente);
      
      // Mock de 3 processos para demonstração
      const mockProcessos = [
        {
          id: 1,
          numero: '1234567-89.2024.8.26.0100',
          tipo: 'Ação de Cobrança',
          status: 'Em andamento',
          valor_causa: 25000.00,
          data_distribuicao: '2024-01-10',
          advogado: 'Dra. Erlene Silva',
          proxima_audiencia: '2024-02-15',
          ultima_movimentacao: 'Juntada de documentos - 12/01/2024',
          status_color: 'green'
        },
        {
          id: 2,
          numero: '9876543-21.2023.8.26.0200',
          tipo: 'Ação Trabalhista',
          status: 'Aguardando sentença',
          valor_causa: 15000.00,
          data_distribuicao: '2023-11-05',
          advogado: 'Dr. Carlos Santos',
          proxima_audiencia: null,
          ultima_movimentacao: 'Audiência realizada - 05/01/2024',
          status_color: 'yellow'
        },
        {
          id: 3,
          numero: '5555555-55.2023.8.26.0300',
          tipo: 'Inventário',
          status: 'Finalizado',
          valor_causa: 100000.00,
          data_distribuicao: '2023-03-20',
          advogado: 'Dra. Erlene Silva',
          proxima_audiencia: null,
          ultima_movimentacao: 'Processo arquivado - 20/12/2023',
          status_color: 'blue'
        }
      ].slice(0, cliente.processos);
      
      setProcessos(mockProcessos);
    }
  }, []);

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'Em andamento':
        return <ClockIcon className="h-5 w-5 text-green-500" />;
      case 'Aguardando sentença':
        return <ExclamationCircleIcon className="h-5 w-5 text-yellow-500" />;
      case 'Finalizado':
        return <CheckCircleIcon className="h-5 w-5 text-blue-500" />;
      default:
        return <ScaleIcon className="h-5 w-5 text-gray-500" />;
    }
  };

  const processosFiltrados = processos.filter(processo => {
    if (filtro === 'todos') return true;
    if (filtro === 'andamento') return processo.status === 'Em andamento';
    if (filtro === 'finalizados') return processo.status === 'Finalizado';
    return true;
  });

  if (!clienteData) {
    return (
      <PortalLayout>
        <div className="flex items-center justify-center h-full">
          <div className="animate-spin rounded-full h-8 w-8 border-2 border-red-700 border-t-transparent"></div>
        </div>
      </PortalLayout>
    );
  }

  return (
    <PortalLayout>
      <div className="p-6">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-gray-900">Meus Processos</h1>
          <p className="text-gray-600 mt-1">
            Acompanhe o andamento de todos os seus processos
          </p>
        </div>

        {/* Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ClockIcon className="h-8 w-8 text-green-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-medium text-gray-900">Em Andamento</h3>
                <p className="text-2xl font-bold text-green-600">
                  {processos.filter(p => p.status === 'Em andamento').length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ExclamationCircleIcon className="h-8 w-8 text-yellow-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-medium text-gray-900">Aguardando</h3>
                <p className="text-2xl font-bold text-yellow-600">
                  {processos.filter(p => p.status === 'Aguardando sentença').length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <CheckCircleIcon className="h-8 w-8 text-blue-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-medium text-gray-900">Finalizados</h3>
                <p className="text-2xl font-bold text-blue-600">
                  {processos.filter(p => p.status === 'Finalizado').length}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Filtros */}
        <div className="mb-6">
          <div className="flex space-x-4">
            <button
              onClick={() => setFiltro('todos')}
              className={`px-4 py-2 rounded-lg text-sm font-medium ${
                filtro === 'todos'
                  ? 'bg-red-100 text-red-700'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              Todos ({processos.length})
            </button>
            <button
              onClick={() => setFiltro('andamento')}
              className={`px-4 py-2 rounded-lg text-sm font-medium ${
                filtro === 'andamento'
                  ? 'bg-red-100 text-red-700'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              Em Andamento ({processos.filter(p => p.status === 'Em andamento').length})
            </button>
            <button
              onClick={() => setFiltro('finalizados')}
              className={`px-4 py-2 rounded-lg text-sm font-medium ${
                filtro === 'finalizados'
                  ? 'bg-red-100 text-red-700'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              Finalizados ({processos.filter(p => p.status === 'Finalizado').length})
            </button>
          </div>
        </div>

        {/* Lista de Processos */}
        <div className="space-y-6">
          {processosFiltrados.map((processo) => (
            <div key={processo.id} className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center mb-2">
                    {getStatusIcon(processo.status)}
                    <h3 className="ml-2 text-lg font-medium text-gray-900">
                      {processo.numero}
                    </h3>
                  </div>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div>
                      <p className="text-sm text-gray-500">Tipo de Ação</p>
                      <p className="text-sm font-medium text-gray-900">{processo.tipo}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-500">Status</p>
                      <p className="text-sm font-medium text-gray-900">{processo.status}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-500">Valor da Causa</p>
                      <p className="text-sm font-medium text-gray-900">
                        {formatCurrency(processo.valor_causa)}
                      </p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-500">Advogado Responsável</p>
                      <p className="text-sm font-medium text-gray-900">{processo.advogado}</p>
                    </div>
                  </div>

                  <div className="border-t pt-4">
                    <p className="text-sm text-gray-500 mb-1">Última Movimentação</p>
                    <p className="text-sm text-gray-900">{processo.ultima_movimentacao}</p>
                    
                    {processo.proxima_audiencia && (
                      <div className="mt-2 flex items-center text-sm text-yellow-700">
                        <CalendarDaysIcon className="h-4 w-4 mr-1" />
                        Próxima audiência: {formatDate(processo.proxima_audiencia)}
                      </div>
                    )}
                  </div>
                </div>

                <div className="ml-4 flex flex-col space-y-2">
                  <button className="flex items-center text-red-600 hover:text-red-700 text-sm font-medium">
                    <EyeIcon className="h-4 w-4 mr-1" />
                    Ver detalhes
                  </button>
                  <button className="flex items-center text-red-600 hover:text-red-700 text-sm font-medium">
                    <DocumentIcon className="h-4 w-4 mr-1" />
                    Documentos
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {processosFiltrados.length === 0 && (
          <div className="text-center py-12">
            <ScaleIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum processo encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              Não há processos com o filtro selecionado.
            </p>
          </div>
        )}
      </div>
    </PortalLayout>
  );
};

export default PortalProcessos;
