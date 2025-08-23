import React, { useState, useEffect } from 'react';
import PortalLayout from '../../components/portal/layout/PortalLayout';
import {
  CreditCardIcon,
  BanknotesIcon,
  ClockIcon,
  CheckCircleIcon,
  ExclamationTriangleIcon,
  ArrowDownTrayIcon,
  DocumentIcon,
  CalendarIcon
} from '@heroicons/react/24/outline';

const PortalPagamentos = () => {
  const [clienteData, setClienteData] = useState(null);
  const [pagamentos, setPagamentos] = useState([]);
  const [filtroStatus, setFiltroStatus] = useState('todos');

  useEffect(() => {
    const data = localStorage.getItem('clienteData');
    if (data) {
      const cliente = JSON.parse(data);
      setClienteData(cliente);
      
      // Mock de 3 pagamentos para demonstração
      const mockPagamentos = [
        {
          id: 1,
          descricao: 'Honorários Advocatícios - Janeiro 2024',
          valor: 1500.00,
          vencimento: '2024-02-15',
          status: 'Pendente',
          tipo: 'Honorários',
          processo: '1234567-89.2024.8.26.0100',
          forma_pagamento: 'Boleto',
          codigo_barras: '12345.67890 12345.678901 12345.678901 1 98760000150000',
          observacoes: 'Honorários referente aos serviços prestados no mês de janeiro'
        },
        {
          id: 2,
          descricao: 'Custas Processuais - Ação Trabalhista',
          valor: 1000.00,
          vencimento: '2024-02-20',
          status: 'Pendente',
          tipo: 'Custas',
          processo: '9876543-21.2023.8.26.0200',
          forma_pagamento: 'PIX',
          chave_pix: 'erlene@advogados.com.br',
          observacoes: 'Pagamento das custas processuais da ação trabalhista'
        },
        {
          id: 3,
          descricao: 'Honorários Advocatícios - Dezembro 2023',
          valor: 1500.00,
          vencimento: '2024-01-15',
          status: 'Pago',
          tipo: 'Honorários',
          processo: '1234567-89.2024.8.26.0100',
          forma_pagamento: 'Transferência',
          data_pagamento: '2024-01-12',
          observacoes: 'Pagamento realizado via transferência bancária'
        }
      ];
      
      setPagamentos(mockPagamentos);
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
      case 'Pago':
        return <CheckCircleIcon className="h-5 w-5 text-green-500" />;
      case 'Pendente':
        return <ClockIcon className="h-5 w-5 text-yellow-500" />;
      case 'Vencido':
        return <ExclamationTriangleIcon className="h-5 w-5 text-red-500" />;
      default:
        return <CreditCardIcon className="h-5 w-5 text-gray-500" />;
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Pago':
        return 'bg-green-100 text-green-700';
      case 'Pendente':
        return 'bg-yellow-100 text-yellow-700';
      case 'Vencido':
        return 'bg-red-100 text-red-700';
      default:
        return 'bg-gray-100 text-gray-700';
    }
  };

  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'Honorários':
        return '💼';
      case 'Custas':
        return '⚖️';
      case 'Taxa':
        return '📄';
      default:
        return '💳';
    }
  };

  const pagamentosFiltrados = pagamentos.filter(pagamento => {
    if (filtroStatus === 'todos') return true;
    return pagamento.status.toLowerCase() === filtroStatus;
  });

  const totalPendente = pagamentos
    .filter(p => p.status === 'Pendente' || p.status === 'Vencido')
    .reduce((sum, p) => sum + p.valor, 0);

  const handleDownloadBoleto = (pagamento) => {
    alert(`Gerando boleto para: ${pagamento.descricao}`);
  };

  const handlePagarPix = (pagamento) => {
    alert(`Iniciando pagamento PIX: ${pagamento.chave_pix}`);
  };

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
          <h1 className="text-2xl font-bold text-gray-900">Pagamentos</h1>
          <p className="text-gray-600 mt-1">
            Gerencie seus pagamentos e faturas
          </p>
        </div>

        {/* Resumo Financeiro */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <BanknotesIcon className="h-8 w-8 text-red-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-medium text-gray-900">Total Pendente</h3>
                <p className="text-2xl font-bold text-red-600">{formatCurrency(totalPendente)}</p>
              </div>
            </div>
          </div>

          <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ClockIcon className="h-8 w-8 text-yellow-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-medium text-gray-900">Pendentes</h3>
                <p className="text-2xl font-bold text-yellow-600">
                  {pagamentos.filter(p => p.status === 'Pendente').length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <CheckCircleIcon className="h-8 w-8 text-green-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-medium text-gray-900">Pagos</h3>
                <p className="text-2xl font-bold text-green-600">
                  {pagamentos.filter(p => p.status === 'Pago').length}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Filtros */}
        <div className="mb-6">
          <div className="flex space-x-4">
            <button
              onClick={() => setFiltroStatus('todos')}
              className={`px-4 py-2 rounded-lg text-sm font-medium ${
                filtroStatus === 'todos'
                  ? 'bg-red-100 text-red-700'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              Todos ({pagamentos.length})
            </button>
            <button
              onClick={() => setFiltroStatus('pendente')}
              className={`px-4 py-2 rounded-lg text-sm font-medium ${
                filtroStatus === 'pendente'
                  ? 'bg-red-100 text-red-700'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              Pendentes ({pagamentos.filter(p => p.status === 'Pendente').length})
            </button>
            <button
              onClick={() => setFiltroStatus('pago')}
              className={`px-4 py-2 rounded-lg text-sm font-medium ${
                filtroStatus === 'pago'
                  ? 'bg-red-100 text-red-700'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              Pagos ({pagamentos.filter(p => p.status === 'Pago').length})
            </button>
          </div>
        </div>

        {/* Lista de Pagamentos */}
        <div className="space-y-6">
          {pagamentosFiltrados.map((pagamento) => (
            <div key={pagamento.id} className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center mb-2">
                    <span className="text-2xl mr-2">{getTipoIcon(pagamento.tipo)}</span>
                    {getStatusIcon(pagamento.status)}
                    <h3 className="ml-2 text-lg font-medium text-gray-900">
                      {pagamento.descricao}
                    </h3>
                    <span className={`ml-3 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(pagamento.status)}`}>
                      {pagamento.status}
                    </span>
                  </div>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div>
                      <p className="text-sm text-gray-500">Valor</p>
                      <p className="text-lg font-bold text-gray-900">
                        {formatCurrency(pagamento.valor)}
                      </p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-500">Vencimento</p>
                      <p className="text-sm font-medium text-gray-900">
                        {formatDate(pagamento.vencimento)}
                      </p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-500">Forma de Pagamento</p>
                      <p className="text-sm font-medium text-gray-900">{pagamento.forma_pagamento}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-500">Processo</p>
                      <p className="text-sm font-medium text-gray-900">
                        {pagamento.processo.substring(0, 20)}...
                      </p>
                    </div>
                  </div>

                  <div className="border-t pt-4">
                    <p className="text-sm text-gray-500 mb-1">Observações</p>
                    <p className="text-sm text-gray-900">{pagamento.observacoes}</p>
                    
                    {pagamento.data_pagamento && (
                      <div className="mt-2 flex items-center text-sm text-green-700">
                        <CheckCircleIcon className="h-4 w-4 mr-1" />
                        Pago em: {formatDate(pagamento.data_pagamento)}
                      </div>
                    )}
                  </div>
                </div>

                <div className="ml-4 flex flex-col space-y-2">
                  {pagamento.status === 'Pendente' && (
                    <>
                      {pagamento.forma_pagamento === 'Boleto' && (
                        <button 
                          onClick={() => handleDownloadBoleto(pagamento)}
                          className="flex items-center text-red-600 hover:text-red-700 text-sm font-medium"
                        >
                          <ArrowDownTrayIcon className="h-4 w-4 mr-1" />
                          Baixar Boleto
                        </button>
                      )}
                      {pagamento.forma_pagamento === 'PIX' && (
                        <button 
                          onClick={() => handlePagarPix(pagamento)}
                          className="flex items-center text-red-600 hover:text-red-700 text-sm font-medium"
                        >
                          <CreditCardIcon className="h-4 w-4 mr-1" />
                          Pagar PIX
                        </button>
                      )}
                    </>
                  )}
                  <button className="flex items-center text-red-600 hover:text-red-700 text-sm font-medium">
                    <DocumentIcon className="h-4 w-4 mr-1" />
                    Ver Detalhes
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {pagamentosFiltrados.length === 0 && (
          <div className="text-center py-12">
            <CreditCardIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum pagamento encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              Não há pagamentos com o filtro selecionado.
            </p>
          </div>
        )}
      </div>
    </PortalLayout>
  );
};

export default PortalPagamentos;
