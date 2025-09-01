#!/bin/bash

# Script 115a - Frontend Clientes List Integration
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115a-clientes-list-integration.sh && ./115a-clientes-list-integration.sh
# EXECUTE NA PASTA: frontend/

echo "🚀 Integrando Lista de Clientes com API Real..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "📝 1. Atualizando página principal de Clientes..."

# Atualizar a página principal de clientes para usar API real
cat > src/pages/admin/Clients.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  UserIcon,
  BuildingOfficeIcon
} from '@heroicons/react/24/outline';
import { useClients } from '../../hooks/useClients';
import { formatDocument, formatPhone, getInitials } from '../../utils/formatters';

const Clients = () => {
  const {
    clients,
    stats,
    loading,
    error,
    deleteClient,
    applyFilters,
    clearFilters
  } = useClients();

  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all');
  const [filterStatus, setFilterStatus] = useState('all');

  // Aplicar filtros quando mudarem
  useEffect(() => {
    const filters = {};
    
    if (searchTerm) filters.search = searchTerm;
    if (filterType !== 'all') filters.tipo_pessoa = filterType;
    if (filterStatus !== 'all') filters.status = filterStatus;

    applyFilters(filters);
  }, [searchTerm, filterType, filterStatus, applyFilters]);

  const handleDelete = async (id, name) => {
    if (window.confirm(`Tem certeza que deseja excluir o cliente ${name}?`)) {
      try {
        await deleteClient(id);
      } catch (error) {
        console.error('Erro ao excluir cliente:', error);
      }
    }
  };

  if (loading && clients.length === 0) {
    return (
      <div className="space-y-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100 p-6 animate-pulse">
              <div className="h-12 bg-gray-200 rounded mb-4"></div>
              <div className="h-6 bg-gray-200 rounded mb-2"></div>
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-8">
        <div className="text-center py-12">
          <div className="text-red-500 text-lg mb-2">Erro ao carregar clientes</div>
          <div className="text-gray-600">{error}</div>
          <button 
            onClick={() => window.location.reload()} 
            className="mt-4 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
          >
            Tentar Novamente
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Clientes</h1>
        <p className="mt-2 text-lg text-gray-600">
          Gerencie todos os clientes do escritório
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-blue-100">
                  <UserIcon className="h-6 w-6 text-blue-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Total de Clientes</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.total || 0}</p>
              <p className="text-sm text-gray-500 mt-1">Cadastrados no sistema</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-green-100">
                  <UserIcon className="h-6 w-6 text-green-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Clientes Ativos</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.ativos || 0}</p>
              <p className="text-sm text-gray-500 mt-1">Com processos em andamento</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-yellow-100">
                  <UserIcon className="h-6 w-6 text-yellow-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Pessoa Física</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.pf || 0}</p>
              <p className="text-sm text-gray-500 mt-1">CPF cadastrados</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-purple-100">
                  <BuildingOfficeIcon className="h-6 w-6 text-purple-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Pessoa Jurídica</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.pj || 0}</p>
              <p className="text-sm text-gray-500 mt-1">CNPJ cadastrados</p>
            </div>
          </div>
        </div>
      </div>

      {/* Filtros e Ações */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Lista de Clientes</h2>
          <Link
            to="/admin/clientes/novo"
            className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <PlusIcon className="w-5 h-5 mr-2" />
            Novo Cliente
          </Link>
        </div>
        
        <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-6">
          {/* Busca */}
          <div className="relative flex-1">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar cliente por nome, documento ou email..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          
          {/* Filtros */}
          <select
            value={filterType}
            onChange={(e) => setFilterType(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os tipos</option>
            <option value="PF">Pessoa Física</option>
            <option value="PJ">Pessoa Jurídica</option>
          </select>
          
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os status</option>
            <option value="ativo">Ativo</option>
            <option value="inativo">Inativo</option>
          </select>

          {(searchTerm || filterType !== 'all' || filterStatus !== 'all') && (
            <button
              onClick={() => {
                setSearchTerm('');
                setFilterType('all');
                setFilterStatus('all');
                clearFilters();
              }}
              className="px-4 py-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200"
            >
              Limpar
            </button>
          )}
        </div>

        {/* Loading */}
        {loading && (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
          </div>
        )}

        {/* Tabela */}
        {!loading && (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Cliente
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Documento
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Contato
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Responsável
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {clients.map((client) => (
                  <tr key={client.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                          {client.tipo_pessoa === 'PF' ? (
                            <UserIcon className="w-5 h-5 text-primary-600" />
                          ) : (
                            <BuildingOfficeIcon className="w-5 h-5 text-primary-600" />
                          )}
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">{client.nome}</div>
                          <div className="text-sm text-gray-500">{client.tipo_pessoa}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatDocument(client.cpf_cnpj, client.tipo_pessoa)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{client.email}</div>
                      <div className="text-sm text-gray-500">{formatPhone(client.telefone)}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        client.status === 'ativo' 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {client.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {client.responsavel ? client.responsavel.nome : '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <div className="flex justify-end space-x-2">
                        <Link
                          to={`/admin/clientes/${client.id}/visualizar`}
                          className="text-blue-600 hover:text-blue-900"
                          title="Visualizar"
                        >
                          <EyeIcon className="w-5 h-5" />
                        </Link>
                        <Link
                          to={`/admin/clientes/${client.id}`}
                          className="text-primary-600 hover:text-primary-900"
                          title="Editar"
                        >
                          <PencilIcon className="w-5 h-5" />
                        </Link>
                        <button
                          onClick={() => handleDelete(client.id, client.nome)}
                          className="text-red-600 hover:text-red-900"
                          title="Excluir"
                        >
                          <TrashIcon className="w-5 h-5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        
        {!loading && clients.length === 0 && (
          <div className="text-center py-12">
            <UserIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum cliente encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || filterType !== 'all' || filterStatus !== 'all'
                ? 'Tente ajustar os filtros de busca.'
                : 'Comece cadastrando um novo cliente.'}
            </p>
            <div className="mt-6">
              <Link
                to="/admin/clientes/novo"
                className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
              >
                <PlusIcon className="w-5 h-5 mr-2" />
                Novo Cliente
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Clients;
EOF

echo "📝 2. Criando componente de carregamento reutilizável..."

# Criar componente de loading para listas
cat > src/components/common/LoadingTable.js << 'EOF'
import React from 'react';

const LoadingTable = ({ rows = 5, columns = 6 }) => {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {[...Array(columns)].map((_, i) => (
              <th key={i} className="px-6 py-3">
                <div className="h-4 bg-gray-200 rounded animate-pulse"></div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {[...Array(rows)].map((_, i) => (
            <tr key={i}>
              {[...Array(columns)].map((_, j) => (
                <td key={j} className="px-6 py-4">
                  <div className="h-4 bg-gray-200 rounded animate-pulse"></div>
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default LoadingTable;
EOF

echo "📝 3. Criando componente de filtros avançados..."

# Criar componente para filtros avançados
cat > src/components/clients/ClientFilters.js << 'EOF'
import React, { useState } from 'react';
import { MagnifyingGlassIcon, FunnelIcon, XMarkIcon } from '@heroicons/react/24/outline';

const ClientFilters = ({ 
  onApplyFilters, 
  onClearFilters, 
  loading = false,
  initialFilters = {} 
}) => {
  const [filters, setFilters] = useState({
    search: '',
    tipo_pessoa: 'all',
    status: 'all',
    acesso_portal: 'all',
    tipo_armazenamento: 'all',
    ...initialFilters
  });

  const [showAdvanced, setShowAdvanced] = useState(false);

  const handleFilterChange = (field, value) => {
    const newFilters = { ...filters, [field]: value };
    setFilters(newFilters);
    
    // Aplicar filtros automaticamente
    const apiFilters = {};
    Object.keys(newFilters).forEach(key => {
      if (newFilters[key] && newFilters[key] !== 'all') {
        apiFilters[key] = newFilters[key];
      }
    });
    
    onApplyFilters(apiFilters);
  };

  const clearAllFilters = () => {
    const clearedFilters = {
      search: '',
      tipo_pessoa: 'all',
      status: 'all',
      acesso_portal: 'all',
      tipo_armazenamento: 'all'
    };
    
    setFilters(clearedFilters);
    onClearFilters();
  };

  const hasActiveFilters = Object.values(filters).some(value => value && value !== 'all');

  return (
    <div className="space-y-4">
      {/* Filtros principais */}
      <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4">
        {/* Busca */}
        <div className="relative flex-1">
          <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
          <input
            type="text"
            placeholder="Buscar por nome, documento ou email..."
            value={filters.search}
            onChange={(e) => handleFilterChange('search', e.target.value)}
            className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            disabled={loading}
          />
        </div>

        {/* Tipo de pessoa */}
        <select
          value={filters.tipo_pessoa}
          onChange={(e) => handleFilterChange('tipo_pessoa', e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          disabled={loading}
        >
          <option value="all">Todos os tipos</option>
          <option value="PF">Pessoa Física</option>
          <option value="PJ">Pessoa Jurídica</option>
        </select>

        {/* Status */}
        <select
          value={filters.status}
          onChange={(e) => handleFilterChange('status', e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          disabled={loading}
        >
          <option value="all">Todos os status</option>
          <option value="ativo">Ativo</option>
          <option value="inativo">Inativo</option>
        </select>

        {/* Botão filtros avançados */}
        <button
          onClick={() => setShowAdvanced(!showAdvanced)}
          className="px-4 py-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 flex items-center"
          disabled={loading}
        >
          <FunnelIcon className="w-4 h-4 mr-2" />
          Avançado
        </button>

        {/* Limpar filtros */}
        {hasActiveFilters && (
          <button
            onClick={clearAllFilters}
            className="px-4 py-2 bg-red-100 text-red-600 rounded-lg hover:bg-red-200 flex items-center"
            disabled={loading}
          >
            <XMarkIcon className="w-4 h-4 mr-2" />
            Limpar
          </button>
        )}
      </div>

      {/* Filtros avançados */}
      {showAdvanced && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 p-4 bg-gray-50 rounded-lg">
          {/* Acesso ao portal */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Acesso ao Portal
            </label>
            <select
              value={filters.acesso_portal}
              onChange={(e) => handleFilterChange('acesso_portal', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              disabled={loading}
            >
              <option value="all">Todos</option>
              <option value="true">Habilitado</option>
              <option value="false">Desabilitado</option>
            </select>
          </div>

          {/* Tipo de armazenamento */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Armazenamento
            </label>
            <select
              value={filters.tipo_armazenamento}
              onChange={(e) => handleFilterChange('tipo_armazenamento', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              disabled={loading}
            >
              <option value="all">Todos</option>
              <option value="local">Local</option>
              <option value="google_drive">Google Drive</option>
              <option value="onedrive">OneDrive</option>
            </select>
          </div>
        </div>
      )}
    </div>
  );
};

export default ClientFilters;
EOF

echo "✅ Script 115a concluído!"
echo "📝 Página de Clientes integrada com API real"
echo "📝 Hook useClients implementado com filtros funcionais"
echo "📝 Componentes de loading e filtros criados"
echo "📝 Formatação de dados integrada"
echo "📝 Estados de loading, erro e vazio tratados"
echo ""
echo "Digite 'continuar' para prosseguir com o Script 115b (Formulários de Cliente)..."