import React, { useState, useEffect } from 'react';
import PortalLayout from '../../components/portal/layout/PortalLayout';
import {
  DocumentIcon,
  ArrowDownTrayIcon,
  EyeIcon,
  FolderIcon,
  CalendarIcon,
  MagnifyingGlassIcon,
  CheckCircleIcon,
  ClockIcon,
  ExclamationCircleIcon
} from '@heroicons/react/24/outline';

const PortalDocumentos = () => {
  const [clienteData, setClienteData] = useState(null);
  const [documentos, setDocumentos] = useState([]);
  const [filtroTipo, setFiltroTipo] = useState('todos');
  const [busca, setBusca] = useState('');

  useEffect(() => {
    const data = localStorage.getItem('clienteData');
    if (data) {
      const cliente = JSON.parse(data);
      setClienteData(cliente);
      
      // Mock de 3 documentos para demonstração
      const mockDocumentos = [
        {
          id: 1,
          nome: 'Contrato Social Atualizado.pdf',
          tipo: 'Contrato',
          tamanho: '2.5 MB',
          data_upload: '2024-01-15',
          processo: '1234567-89.2024.8.26.0100',
          categoria: 'Documentos Empresariais',
          status: 'Aprovado',
          descricao: 'Contrato social com última alteração registrada na Junta Comercial'
        },
        {
          id: 2,
          nome: 'Procuração Específica.pdf',
          tipo: 'Procuração',
          tamanho: '1.2 MB',
          data_upload: '2024-01-10',
          processo: '1234567-89.2024.8.26.0100',
          categoria: 'Documentos Processuais',
          status: 'Pendente',
          descricao: 'Procuração para representação no processo de cobrança'
        },
        {
          id: 3,
          nome: 'Comprovante de Residência.pdf',
          tipo: 'Comprovante',
          tamanho: '0.8 MB',
          data_upload: '2024-01-08',
          processo: null,
          categoria: 'Documentos Pessoais',
          status: 'Aprovado',
          descricao: 'Conta de luz referente ao mês de dezembro/2023'
        }
      ];
      
      setDocumentos(mockDocumentos);
    }
  }, []);

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Aprovado':
        return 'bg-green-100 text-green-700';
      case 'Pendente':
        return 'bg-yellow-100 text-yellow-700';
      case 'Em Análise':
        return 'bg-blue-100 text-blue-700';
      case 'Rejeitado':
        return 'bg-red-100 text-red-700';
      default:
        return 'bg-gray-100 text-gray-700';
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'Aprovado':
        return <CheckCircleIcon className="h-4 w-4 text-green-500" />;
      case 'Pendente':
        return <ClockIcon className="h-4 w-4 text-yellow-500" />;
      case 'Em Análise':
        return <ExclamationCircleIcon className="h-4 w-4 text-blue-500" />;
      case 'Rejeitado':
        return <ExclamationCircleIcon className="h-4 w-4 text-red-500" />;
      default:
        return <DocumentIcon className="h-4 w-4 text-gray-500" />;
    }
  };

  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'Contrato':
        return '📄';
      case 'Procuração':
        return '📋';
      case 'Comprovante':
        return '🧾';
      case 'Certidão':
        return '📜';
      case 'Planilha':
        return '📊';
      default:
        return '📄';
    }
  };

  const documentosFiltrados = documentos.filter(doc => {
    const matchTipo = filtroTipo === 'todos' || doc.categoria === filtroTipo;
    const matchBusca = busca === '' || doc.nome.toLowerCase().includes(busca.toLowerCase());
    return matchTipo && matchBusca;
  });

  const categorias = [...new Set(documentos.map(doc => doc.categoria))];

  const handleDownload = (documento) => {
    alert(`Iniciando download: ${documento.nome}`);
  };

  const handleVisualizacao = (documento) => {
    alert(`Abrindo visualização: ${documento.nome}`);
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
          <h1 className="text-2xl font-bold text-gray-900">Meus Documentos</h1>
          <p className="text-gray-600 mt-1">
            Acesse e gerencie todos os seus documentos
          </p>
        </div>

        {/* Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <DocumentIcon className="h-8 w-8 text-blue-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-medium text-gray-900">Total</h3>
                <p className="text-2xl font-bold text-blue-600">{documentos.length}</p>
              </div>
            </div>
          </div>

          <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <CheckCircleIcon className="h-8 w-8 text-green-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-medium text-gray-900">Aprovados</h3>
                <p className="text-2xl font-bold text-green-600">
                  {documentos.filter(d => d.status === 'Aprovado').length}
                </p>
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
                  {documentos.filter(d => d.status === 'Pendente').length}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Filtros e Busca */}
        <div className="mb-6 space-y-4">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-3 sm:space-y-0">
            <div className="flex space-x-4">
              <button
                onClick={() => setFiltroTipo('todos')}
                className={`px-4 py-2 rounded-lg text-sm font-medium ${
                  filtroTipo === 'todos'
                    ? 'bg-red-100 text-red-700'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                Todos ({documentos.length})
              </button>
              {categorias.map(categoria => (
                <button
                  key={categoria}
                  onClick={() => setFiltroTipo(categoria)}
                  className={`px-4 py-2 rounded-lg text-sm font-medium ${
                    filtroTipo === categoria
                      ? 'bg-red-100 text-red-700'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  {categoria.split(' ')[1]} ({documentos.filter(d => d.categoria === categoria).length})
                </button>
              ))}
            </div>

            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <MagnifyingGlassIcon className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                placeholder="Buscar documentos..."
                value={busca}
                onChange={(e) => setBusca(e.target.value)}
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-red-500 focus:border-red-500 sm:text-sm"
              />
            </div>
          </div>
        </div>

        {/* Lista de Documentos */}
        <div className="bg-white shadow-lg shadow-red-100 rounded-lg overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-medium text-gray-900">
              Documentos ({documentosFiltrados.length})
            </h2>
          </div>
          
          <div className="divide-y divide-gray-200">
            {documentosFiltrados.map((documento) => (
              <div key={documento.id} className="px-6 py-4 hover:bg-gray-50">
                <div className="flex items-center justify-between">
                  <div className="flex items-center flex-1 min-w-0">
                    <div className="flex-shrink-0 text-2xl mr-3">
                      {getTipoIcon(documento.tipo)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center space-x-2">
                        <p className="text-sm font-medium text-gray-900 truncate">
                          {documento.nome}
                        </p>
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(documento.status)}`}>
                          {getStatusIcon(documento.status)}
                          <span className="ml-1">{documento.status}</span>
                        </span>
                      </div>
                      <p className="text-xs text-gray-500 mt-1 truncate">
                        {documento.descricao}
                      </p>
                      <div className="mt-1 flex items-center space-x-4 text-sm text-gray-500">
                        <span>{documento.tamanho}</span>
                        <span className="flex items-center">
                          <CalendarIcon className="h-4 w-4 mr-1" />
                          {formatDate(documento.data_upload)}
                        </span>
                        {documento.processo && (
                          <span className="flex items-center">
                            <FolderIcon className="h-4 w-4 mr-1" />
                            Proc. {documento.processo.substring(0, 15)}...
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="ml-4 flex items-center space-x-2">
                    <button 
                      onClick={() => handleVisualizacao(documento)}
                      className="text-red-600 hover:text-red-700 p-1" 
                      title="Visualizar"
                    >
                      <EyeIcon className="h-5 w-5" />
                    </button>
                    <button 
                      onClick={() => handleDownload(documento)}
                      className="text-red-600 hover:text-red-700 p-1" 
                      title="Download"
                    >
                      <ArrowDownTrayIcon className="h-5 w-5" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {documentosFiltrados.length === 0 && (
          <div className="text-center py-12">
            <DocumentIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum documento encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              Não há documentos com os filtros selecionados.
            </p>
          </div>
        )}
      </div>
    </PortalLayout>
  );
};

export default PortalDocumentos;
