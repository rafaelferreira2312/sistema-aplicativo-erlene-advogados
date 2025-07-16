#!/bin/bash

# Script 42 - Páginas de Processos
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/42-create-processes-pages.sh

echo "⚖️ Criando páginas de processos..."

# src/pages/admin/Processes/index.js
cat > frontend/src/pages/admin/Processes/index.js << 'EOF'
import React, { useState, useMemo } from 'react';
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  FunnelIcon,
  DocumentArrowDownIcon,
  EyeIcon,
  PencilIcon,
  SyncIcon
} from '@heroicons/react/24/outline';
import { useProcesses, useSyncWithCourt } from '../../../hooks/api/useProcesses';
import { formatDate, formatProcessNumber } from '../../../utils/formatters';
import { PROCESS_STATUS_LABELS, PROCESS_STATUS_COLORS } from '../../../config/constants';

import Card from '../../../components/common/Card';
import Button from '../../../components/common/Button';
import Input from '../../../components/common/Input';
import Table from '../../../components/common/Table';
import Badge from '../../../components/common/Badge';
import Loading from '../../../components/common/Loading';

const Processes = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [sortBy, setSortBy] = useState('created_at');
  const [sortDirection, setSortDirection] = useState('desc');
  const [currentPage, setCurrentPage] = useState(1);

  const {
    data: processesData,
    isLoading,
    error,
    refetch
  } = useProcesses({
    page: currentPage,
    search: searchTerm,
    status: statusFilter,
    sort_by: sortBy,
    sort_direction: sortDirection,
    per_page: 20
  });

  const syncWithCourtMutation = useSyncWithCourt();

  const processes = processesData?.data || [];
  const pagination = processesData?.pagination || {};

  const handleSort = (key, direction) => {
    setSortBy(key);
    setSortDirection(direction);
    setCurrentPage(1);
  };

  const handleSyncProcess = async (processId) => {
    try {
      await syncWithCourtMutation.mutateAsync(processId);
      refetch();
    } catch (error) {
      console.error('Erro ao sincronizar processo:', error);
    }
  };

  const filteredProcesses = useMemo(() => {
    return processes.filter(process => {
      const matchesSearch = !searchTerm || 
        process.numero.toLowerCase().includes(searchTerm.toLowerCase()) ||
        process.cliente?.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
        process.assunto.toLowerCase().includes(searchTerm.toLowerCase());
      
      const matchesStatus = !statusFilter || process.status === statusFilter;
      
      return matchesSearch && matchesStatus;
    });
  }, [processes, searchTerm, statusFilter]);

  const columns = [
    {
      key: 'numero',
      title: 'Número do Processo',
      sortable: true,
      render: (process) => (
        <div>
          <div className="font-medium text-gray-900">
            {formatProcessNumber(process.numero)}
          </div>
          <div className="text-sm text-gray-500">
            {process.tribunal}
          </div>
        </div>
      )
    },
    {
      key: 'cliente',
      title: 'Cliente',
      sortable: true,
      render: (process) => (
        <div>
          <div className="font-medium text-gray-900">
            {process.cliente?.nome}
          </div>
          <div className="text-sm text-gray-500">
            {process.cliente?.email}
          </div>
        </div>
      )
    },
    {
      key: 'assunto',
      title: 'Assunto',
      sortable: true,
      render: (process) => (
        <div className="max-w-xs">
          <div className="font-medium text-gray-900 truncate">
            {process.assunto}
          </div>
          <div className="text-sm text-gray-500">
            {process.tipo_acao}
          </div>
        </div>
      )
    },
    {
      key: 'status',
      title: 'Status',
      sortable: true,
      render: (process) => (
        <Badge 
          variant={PROCESS_STATUS_COLORS[process.status]?.includes('green') ? 'success' :
                  PROCESS_STATUS_COLORS[process.status]?.includes('yellow') ? 'warning' :
                  PROCESS_STATUS_COLORS[process.status]?.includes('red') ? 'danger' : 'info'}
        >
          {PROCESS_STATUS_LABELS[process.status] || process.status}
        </Badge>
      )
    },
    {
      key: 'valor_causa',
      title: 'Valor da Causa',
      sortable: true,
      render: (process) => (
        <div className="text-gray-900">
          {process.valor_causa ? 
            new Intl.NumberFormat('pt-BR', {
              style: 'currency',
              currency: 'BRL'
            }).format(process.valor_causa) 
            : '-'
          }
        </div>
      )
    },
    {
      key: 'data_distribuicao',
      title: 'Distribuição',
      sortable: true,
      render: (process) => (
        <div className="text-sm text-gray-900">
          {formatDate(process.data_distribuicao)}
        </div>
      )
    },
    {
      key: 'actions',
      title: 'Ações',
      sortable: false,
      render: (process) => (
        <div className="flex space-x-2">
          <Button 
            variant="ghost" 
            size="small"
            icon={EyeIcon}
            onClick={() => {/* Navigate to detail */}}
          >
            Ver
          </Button>
          <Button 
            variant="ghost" 
            size="small"
            icon={PencilIcon}
            onClick={() => {/* Navigate to edit */}}
          >
            Editar
          </Button>
          <Button 
            variant="ghost" 
            size="small"
            icon={SyncIcon}
            loading={syncWithCourtMutation.isLoading}
            onClick={() => handleSyncProcess(process.id)}
          >
            Sync
          </Button>
        </div>
      )
    },
  ];

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">Erro ao carregar processos</p>
        <Button onClick={() => refetch()} className="mt-4">
          Tentar novamente
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Processos</h1>
          <p className="mt-1 text-gray-600">
            Gerencie todos os processos do escritório
          </p>
        </div>
        <div className="mt-4 sm:mt-0">
          <Button 
            variant="primary" 
            icon={PlusIcon}
            iconPosition="left"
          >
            Novo Processo
          </Button>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="md:col-span-2">
            <Input
              placeholder="Buscar por número, cliente ou assunto..."
              icon={MagnifyingGlassIcon}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <div>
            <select 
              className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              <option value="">Todos os status</option>
              {Object.entries(PROCESS_STATUS_LABELS).map(([key, label]) => (
                <option key={key} value={key}>{label}</option>
              ))}
            </select>
          </div>
          <div className="flex space-x-2">
            <Button variant="outline" icon={FunnelIcon} className="flex-1">
              Mais Filtros
            </Button>
            <Button variant="outline" icon={DocumentArrowDownIcon}>
              Exportar
            </Button>
          </div>
        </div>
      </Card>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="text-center">
          <div className="text-2xl font-bold text-gray-900">
            {processes.length}
          </div>
          <div className="text-sm text-gray-500">Total de Processos</div>
        </Card>
        <Card className="text-center">
          <div className="text-2xl font-bold text-blue-600">
            {processes.filter(p => p.status === 'em_andamento').length}
          </div>
          <div className="text-sm text-gray-500">Em Andamento</div>
        </Card>
        <Card className="text-center">
          <div className="text-2xl font-bold text-green-600">
            {processes.filter(p => p.status === 'sentenca').length}
          </div>
          <div className="text-sm text-gray-500">Com Sentença</div>
        </Card>
        <Card className="text-center">
          <div className="text-2xl font-bold text-red-600">
            {processes.filter(p => p.status === 'suspenso').length}
          </div>
          <div className="text-sm text-gray-500">Suspensos</div>
        </Card>
      </div>

      {/* Table */}
      <Card>
        {isLoading ? (
          <div className="flex justify-center py-12">
            <Loading size="large" />
          </div>
        ) : (
          <>
            <Table
              data={filteredProcesses}
              columns={columns}
              sortBy={sortBy}
              sortDirection={sortDirection}
              onSort={handleSort}
              emptyMessage="Nenhum processo encontrado"
            />
            
            {/* Pagination */}
            {pagination.total > 0 && (
              <div className="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6">
                <div className="flex flex-1 justify-between sm:hidden">
                  <Button 
                    variant="outline"
                    disabled={!pagination.prev_page_url}
                    onClick={() => setCurrentPage(currentPage - 1)}
                  >
                    Anterior
                  </Button>
                  <Button 
                    variant="outline"
                    disabled={!pagination.next_page_url}
                    onClick={() => setCurrentPage(currentPage + 1)}
                  >
                    Próximo
                  </Button>
                </div>
                <div className="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
                  <div>
                    <p className="text-sm text-gray-700">
                      Mostrando <span className="font-medium">{pagination.from || 0}</span> a{' '}
                      <span className="font-medium">{pagination.to || 0}</span> de{' '}
                      <span className="font-medium">{pagination.total || 0}</span> resultados
                    </p>
                  </div>
                  <div>
                    <nav className="isolate inline-flex -space-x-px rounded-md shadow-sm">
                      <Button 
                        variant="outline" 
                        size="small"
                        disabled={!pagination.prev_page_url}
                        onClick={() => setCurrentPage(currentPage - 1)}
                      >
                        Anterior
                      </Button>
                      <Button 
                        variant="outline" 
                        size="small" 
                        className="bg-primary-50 border-primary-500 text-primary-600"
                      >
                        {currentPage}
                      </Button>
                      <Button 
                        variant="outline" 
                        size="small"
                        disabled={!pagination.next_page_url}
                        onClick={() => setCurrentPage(currentPage + 1)}
                      >
                        Próximo
                      </Button>
                    </nav>
                  </div>
                </div>
              </div>
            )}
          </>
        )}
      </Card>
    </div>
  );
};

export default Processes;
EOF

# src/pages/portal/Processes/index.js
cat > frontend/src/pages/portal/Processes/index.js << 'EOF'
import React, { useState } from 'react';
import { 
  MagnifyingGlassIcon,
  DocumentTextIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline';
import { formatDate, formatProcessNumber } from '../../../utils/formatters';
import { PROCESS_STATUS_LABELS } from '../../../config/constants';

import Card from '../../../components/common/Card';
import Input from '../../../components/common/Input';
import Badge from '../../../components/common/Badge';
import Button from '../../../components/common/Button';

const PortalProcesses = () => {
  const [searchTerm, setSearchTerm] = useState('');

  // Mock data - substituir por dados reais da API
  const processes = [
    {
      id: 1,
      numero: '1234567-89.2024.8.02.0001',
      assunto: 'Ação de Cobrança',
      status: 'em_andamento',
      ultima_movimentacao: '2024-03-15',
      proxima_audiencia: '2024-04-20',
      valor_causa: 50000,
      advogado: 'Dr. João Silva',
      movimentacoes_count: 15
    },
    {
      id: 2,
      numero: '9876543-21.2024.8.02.0002',
      assunto: 'Revisão Contratual',
      status: 'distribuido',
      ultima_movimentacao: '2024-03-10',
      proxima_audiencia: null,
      valor_causa: 25000,
      advogado: 'Dra. Maria Santos',
      movimentacoes_count: 3
    },
    {
      id: 3,
      numero: '5555555-55.2024.8.02.0003',
      assunto: 'Ação Trabalhista',
      status: 'sentenca',
      ultima_movimentacao: '2024-03-12',
      proxima_audiencia: null,
      valor_causa: 75000,
      advogado: 'Dr. Pedro Costa',
      movimentacoes_count: 28
    },
  ];

  const getStatusColor = (status) => {
    switch (status) {
      case 'distribuido': return 'info';
      case 'em_andamento': return 'warning';
      case 'sentenca': return 'success';
      case 'arquivado': return 'secondary';
      case 'suspenso': return 'danger';
      default: return 'default';
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'distribuido': return ClockIcon;
      case 'em_andamento': return ExclamationTriangleIcon;
      case 'sentenca': return CheckCircleIcon;
      default: return DocumentTextIcon;
    }
  };

  const filteredProcesses = processes.filter(process =>
    process.numero.toLowerCase().includes(searchTerm.toLowerCase()) ||
    process.assunto.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Meus Processos</h1>
        <p className="mt-1 text-gray-600">
          Acompanhe o andamento de todos os seus processos
        </p>
      </div>

      {/* Search */}
      <Card>
        <Input
          placeholder="Buscar processo por número ou assunto..."
          icon={MagnifyingGlassIcon}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </Card>

      {/* Process List */}
      <div className="grid gap-6">
        {filteredProcesses.map((process) => {
          const StatusIcon = getStatusIcon(process.status);
          
          return (
            <Card key={process.id} hover className="cursor-pointer">
              <div className="p-6">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center space-x-3 mb-3">
                      <StatusIcon className="h-6 w-6 text-gray-400" />
                      <h3 className="text-lg font-semibold text-gray-900">
                        {formatProcessNumber(process.numero)}
                      </h3>
                      <Badge variant={getStatusColor(process.status)}>
                        {PROCESS_STATUS_LABELS[process.status]}
                      </Badge>
                    </div>
                    
                    <h4 className="text-md font-medium text-gray-900 mb-2">
                      {process.assunto}
                    </h4>
                    
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm text-gray-600">
                      <div>
                        <span className="font-medium">Advogado:</span>
                        <br />
                        {process.advogado}
                      </div>
                      <div>
                        <span className="font-medium">Valor da Causa:</span>
                        <br />
                        {new Intl.NumberFormat('pt-BR', {
                          style: 'currency',
                          currency: 'BRL'
                        }).format(process.valor_causa)}
                      </div>
                      <div>
                        <span className="font-medium">Movimentações:</span>
                        <br />
                        {process.movimentacoes_count} registradas
                      </div>
                    </div>
                    
                    <div className="mt-4 flex items-center justify-between text-sm">
                      <div className="flex items-center text-gray-500">
                        <ClockIcon className="h-4 w-4 mr-1" />
                        Última movimentação: {formatDate(process.ultima_movimentacao)}
                      </div>
                      
                      {process.proxima_audiencia && (
                        <div className="flex items-center text-orange-600">
                          <ExclamationTriangleIcon className="h-4 w-4 mr-1" />
                          Próxima audiência: {formatDate(process.proxima_audiencia)}
                        </div>
                      )}
                    </div>
                  </div>
                  
                  <div className="ml-4">
                    <Button variant="outline" size="small">
                      Ver Detalhes
                    </Button>
                  </div>
                </div>
              </div>
            </Card>
          );
        })}
      </div>

      {filteredProcesses.length === 0 && (
        <Card>
          <div className="text-center py-12">
            <DocumentTextIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">
              Nenhum processo encontrado
            </h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm 
                ? 'Tente ajustar os termos de busca'
                : 'Você ainda não possui processos cadastrados'
              }
            </p>
          </div>
        </Card>
      )}
    </div>
  );
};

export default PortalProcesses;
EOF

echo "✅ Páginas de processos criadas com sucesso!"
echo ""
echo "📊 PÁGINAS CRIADAS:"
echo "   • Processes (Admin) - Lista completa com filtros e ações"
echo "   • Processes (Portal) - Visualização simplificada para clientes"
echo ""
echo "⚖️ RECURSOS INCLUÍDOS:"
echo "   • Listagem com paginação e ordenação"
echo "   • Filtros por status e busca por texto"
echo "   • Sincronização com tribunais"
echo "   • Cards de estatísticas"
echo "   • Formatação de números de processo"
echo "   • Interface responsiva e acessível"
echo "   • Estados de loading e erro"
echo ""
echo "⏭️  Próximo: Páginas de Atendimentos!"