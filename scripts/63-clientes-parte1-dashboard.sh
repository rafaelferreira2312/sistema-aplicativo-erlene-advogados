#!/bin/bash

# Script 63 - Parte 1: Dashboard de Clientes 
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: cd frontend && ./63-clientes-parte1-dashboard.sh

echo "👥 Implementando dashboard de clientes (Parte 1/3)..."

# 1. Verificar/criar diretório Clients
if [ ! -d "src/pages/admin/Clients" ]; then
  mkdir -p src/pages/admin/Clients
  echo "📁 Diretório src/pages/admin/Clients criado"
fi

# 2. Sobrescrever dashboard de clientes existente
cat > src/pages/admin/Clients/index.js << 'EOF'
import React, { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  FunnelIcon,
  DocumentArrowDownIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
  UserIcon,
  BuildingOfficeIcon,
  PhoneIcon,
  EnvelopeIcon
} from '@heroicons/react/24/outline';

const Clients = () => {
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  // Mock data - substituir por dados reais da API
  const clientsData = [
    {
      id: 1,
      nome: 'Maria Silva Santos',
      email: 'maria.silva@email.com',
      telefone: '(11) 99999-9999',
      cpf_cnpj: '123.456.789-00',
      tipo_pessoa: 'PF',
      status: 'ativo',
      endereco: 'Rua das Flores, 123 - São Paulo/SP',
      data_cadastro: '2024-01-15',
      processos_count: 3,
      ultima_interacao: '2024-07-10'
    },
    {
      id: 2,
      nome: 'Empresa ABC Ltda',
      email: 'contato@empresaabc.com.br',
      telefone: '(11) 3333-4444',
      cpf_cnpj: '12.345.678/0001-90',
      tipo_pessoa: 'PJ',
      status: 'ativo',
      endereco: 'Av. Paulista, 1000 - São Paulo/SP',
      data_cadastro: '2024-02-20',
      processos_count: 7,
      ultima_interacao: '2024-07-12'
    },
    {
      id: 3,
      nome: 'João Carlos Oliveira',
      email: 'joao.oliveira@email.com',
      telefone: '(11) 88888-7777',
      cpf_cnpj: '987.654.321-00',
      tipo_pessoa: 'PF',
      status: 'inativo',
      endereco: 'Rua dos Santos, 456 - São Paulo/SP',
      data_cadastro: '2024-03-05',
      processos_count: 1,
      ultima_interacao: '2024-06-15'
    },
    {
      id: 4,
      nome: 'Ana Costa Silva',
      email: 'ana.costa@email.com',
      telefone: '(11) 77777-6666',
      cpf_cnpj: '456.789.123-00',
      tipo_pessoa: 'PF',
      status: 'ativo',
      endereco: 'Rua da Paz, 789 - São Paulo/SP',
      data_cadastro: '2024-04-10',
      processos_count: 2,
      ultima_interacao: '2024-07-14'
    },
    {
      id: 5,
      nome: 'Consultoria XYZ S/A',
      email: 'juridico@consultoriaxyz.com.br',
      telefone: '(11) 5555-4444',
      cpf_cnpj: '98.765.432/0001-10',
      tipo_pessoa: 'PJ',
      status: 'ativo',
      endereco: 'Rua Comercial, 321 - São Paulo/SP',
      data_cadastro: '2024-05-01',
      processos_count: 5,
      ultima_interacao: '2024-07-13'
    }
  ];

  const filteredClients = useMemo(() => {
    return clientsData.filter(client => {
      const matchesSearch = !searchTerm || 
        client.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
        client.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
        client.cpf_cnpj.includes(searchTerm);
      
      const matchesType = !typeFilter || client.tipo_pessoa === typeFilter;
      const matchesStatus = !statusFilter || client.status === statusFilter;
      
      return matchesSearch && matchesType && matchesStatus;
    });
  }, [clientsData, searchTerm, typeFilter, statusFilter]);

  const paginatedClients = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    return filteredClients.slice(startIndex, startIndex + itemsPerPage);
  }, [filteredClients, currentPage]);

  const totalPages = Math.ceil(filteredClients.length / itemsPerPage);

  const getStatusBadge = (status) => {
    return status === 'ativo' ? (
      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
        Ativo
      </span>
    ) : (
      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
        Inativo
      </span>
    );
  };

  const getTipoPessoaIcon = (tipo) => {
    return tipo === 'PF' ? (
      <UserIcon className="h-5 w-5 text-blue-500" />
    ) : (
      <BuildingOfficeIcon className="h-5 w-5 text-green-500" />
    );
  };

  const stats = {
    total: clientsData.length,
    ativos: clientsData.filter(c => c.status === 'ativo').length,
    pf: clientsData.filter(c => c.tipo_pessoa === 'PF').length,
    pj: clientsData.filter(c => c.tipo_pessoa === 'PJ').length
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Gestão de Clientes</h1>
          <p className="mt-2 text-lg text-gray-600">
            Gerencie todos os clientes do escritório
          </p>
        </div>
        <div className="mt-4 sm:mt-0">
          <button
            onClick={() => navigate('/admin/clients/new')}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-gradient-erlene hover:shadow-erlene-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-all duration-200"
          >
            <PlusIcon className="h-5 w-5 mr-2" />
            Novo Cliente
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {[
          { label: 'Total de Clientes', value: stats.total, color: 'blue', icon: UserIcon },
          { label: 'Clientes Ativos', value: stats.ativos, color: 'green', icon: UserIcon },
          { label: 'Pessoa Física', value: stats.pf, color: 'purple', icon: UserIcon },
          { label: 'Pessoa Jurídica', value: stats.pj, color: 'yellow', icon: BuildingOfficeIcon }
        ].map((stat, index) => (
          <div key={index} className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center">
              <div className={`p-3 rounded-lg bg-${stat.color}-100`}>
                <stat.icon className={`h-6 w-6 text-${stat.color}-600`} />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">{stat.label}</p>
                <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="md:col-span-2">
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <MagnifyingGlassIcon className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                placeholder="Buscar por nome, email ou CPF/CNPJ..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
          </div>
          <div>
            <select 
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
            >
              <option value="">Todos os tipos</option>
              <option value="PF">Pessoa Física</option>
              <option value="PJ">Pessoa Jurídica</option>
            </select>
          </div>
          <div>
            <select 
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
            >
              <option value="">Todos os status</option>
              <option value="ativo">Ativo</option>
              <option value="inativo">Inativo</option>
            </select>
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-medium text-gray-900">
              Lista de Clientes ({filteredClients.length})
            </h3>
            <div className="flex space-x-2">
              <button className="inline-flex items-center px-3 py-1 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
                <FunnelIcon className="h-4 w-4 mr-1" />
                Filtros
              </button>
              <button className="inline-flex items-center px-3 py-1 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
                <DocumentArrowDownIcon className="h-4 w-4 mr-1" />
                Exportar
              </button>
            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cliente
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Contato
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Processos
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {paginatedClients.map((client) => (
                <tr key={client.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10">
                        <div className="h-10 w-10 rounded-full bg-gradient-erlene flex items-center justify-center">
                          <span className="text-white font-medium text-sm">
                            {client.nome.charAt(0).toUpperCase()}
                          </span>
                        </div>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{client.nome}</div>
                        <div className="text-sm text-gray-500">{client.cpf_cnpj}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex flex-col space-y-1">
                      <div className="flex items-center text-sm text-gray-900">
                        <EnvelopeIcon className="h-4 w-4 mr-2 text-gray-400" />
                        {client.email}
                      </div>
                      <div className="flex items-center text-sm text-gray-500">
                        <PhoneIcon className="h-4 w-4 mr-2 text-gray-400" />
                        {client.telefone}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      {getTipoPessoaIcon(client.tipo_pessoa)}
                      <span className="ml-2 text-sm text-gray-900">
                        {client.tipo_pessoa === 'PF' ? 'Pessoa Física' : 'Pessoa Jurídica'}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {getStatusBadge(client.status)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      {client.processos_count} processo{client.processos_count !== 1 ? 's' : ''}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex items-center justify-end space-x-2">
                      <button
                        onClick={() => navigate(`/admin/clients/${client.id}`)}
                        className="text-primary-600 hover:text-primary-900 p-1"
                        title="Visualizar"
                      >
                        <EyeIcon className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => navigate(`/admin/clients/${client.id}/edit`)}
                        className="text-indigo-600 hover:text-indigo-900 p-1"
                        title="Editar"
                      >
                        <PencilIcon className="h-4 w-4" />
                      </button>
                      <button
                        className="text-red-600 hover:text-red-900 p-1"
                        title="Excluir"
                      >
                        <TrashIcon className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination - será implementada na próxima parte */}
        {totalPages > 1 && (
          <div className="bg-white px-4 py-3 border-t border-gray-200">
            <div className="text-center">
              <p className="text-sm text-gray-700">
                Página {currentPage} de {totalPages} - {filteredClients.length} clientes
              </p>
            </div>
          </div>
        )}
      </div>

      {filteredClients.length === 0 && (
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-12">
          <div className="text-center">
            <UserIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum cliente encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || typeFilter || statusFilter 
                ? 'Tente ajustar os filtros de busca'
                : 'Comece cadastrando seu primeiro cliente'
              }
            </p>
            <div className="mt-6">
              <button
                onClick={() => navigate('/admin/clients/new')}
                className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-gradient-erlene hover:shadow-erlene-lg"
              >
                <PlusIcon className="h-5 w-5 mr-2" />
                Novo Cliente
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Clients;
EOF

echo "✅ Dashboard de clientes criado (Parte 1/3)!"
echo ""
echo "📊 IMPLEMENTADO:"
echo "   • Lista completa de clientes com dados mock"
echo "   • Cards de estatísticas (Total, Ativos, PF, PJ)"
echo "   • Filtros por busca, tipo e status"
echo "   • Tabela responsiva com ações"
echo "   • Navegação para /admin/clients/new"
echo "   • Design system Erlene aplicado"
echo ""
echo "⏭️  Execute o script e digite 'continuar' para Parte 2: Formulário de Cadastro"