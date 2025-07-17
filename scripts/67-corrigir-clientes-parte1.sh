#!/bin/bash

# Script 67 - Corrigir Estrutura de Clientes (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "👥 Corrigindo estrutura de clientes (Parte 1/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Criar estrutura correta de clientes
mkdir -p src/pages/admin/Clients

echo "📁 Reorganizando estrutura de clientes..."

# Criar arquivo index.js para exportações
cat > src/pages/admin/Clients/index.js << 'EOF'
export { default as ClientList } from './ClientList';
export { default as NewClient } from './NewClient';
export { default as EditClient } from './EditClient';
EOF

# Recriar ClientList seguindo padrão do projeto
cat > src/pages/admin/Clients/ClientList.jsx << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  FunnelIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  UserIcon,
  BuildingOfficeIcon
} from '@heroicons/react/24/outline';

const ClientList = () => {
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all');
  const [filterStatus, setFilterStatus] = useState('all');

  // Mock data
  const mockClients = [
    {
      id: 1,
      name: 'João Silva Santos',
      document: '123.456.789-00',
      email: 'joao.silva@email.com',
      phone: '(11) 99999-9999',
      type: 'PF',
      status: 'Ativo',
      createdAt: '2024-01-15',
      processes: 3
    },
    {
      id: 2,
      name: 'Empresa ABC Ltda',
      document: '12.345.678/0001-90',
      email: 'contato@empresaabc.com',
      phone: '(11) 3333-3333',
      type: 'PJ',
      status: 'Ativo',
      createdAt: '2024-01-20',
      processes: 5
    },
    {
      id: 3,
      name: 'Maria Oliveira Costa',
      document: '987.654.321-00',
      email: 'maria.oliveira@email.com',
      phone: '(11) 88888-8888',
      type: 'PF',
      status: 'Inativo',
      createdAt: '2024-02-01',
      processes: 1
    },
    {
      id: 4,
      name: 'Tech Solutions S.A.',
      document: '98.765.432/0001-10',
      email: 'admin@techsolutions.com',
      phone: '(11) 4444-4444',
      type: 'PJ',
      status: 'Ativo',
      createdAt: '2024-02-10',
      processes: 8
    }
  ];

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setClients(mockClients);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas
  const stats = {
    total: clients.length,
    active: clients.filter(c => c.status === 'Ativo').length,
    pf: clients.filter(c => c.type === 'PF').length,
    pj: clients.filter(c => c.type === 'PJ').length
  };

  // Filtrar clientes
  const filteredClients = clients.filter(client => {
    const matchesSearch = client.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         client.document.includes(searchTerm) ||
                         client.email.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesType = filterType === 'all' || client.type === filterType;
    const matchesStatus = filterStatus === 'all' || client.status === filterStatus;
    
    return matchesSearch && matchesType && matchesStatus;
  });

  const handleDelete = (id) => {
    if (window.confirm('Tem certeza que deseja excluir este cliente?')) {
      setClients(prev => prev.filter(client => client.id !== id));
    }
  };

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="animate-pulse">
            <div className="h-6 bg-gray-200 rounded w-1/4 mb-4"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-white rounded-lg shadow-sm p-6 animate-pulse">
              <div className="h-12 bg-gray-200 rounded mb-4"></div>
              <div className="h-6 bg-gray-200 rounded mb-2"></div>
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white shadow-sm rounded-lg p-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Clientes</h1>
            <p className="text-gray-600 mt-1">Gerencie todos os clientes do escritório</p>
          </div>
          <Link
            to="/admin/clients/new"
            className="inline-flex items-center px-4 py-2 bg-red-700 text-white rounded-lg hover:bg-red-800 transition-colors"
          >
            <PlusIcon className="w-5 h-5 mr-2" />
            Novo Cliente
          </Link>
        </div>
      </div>

      {/* Estatísticas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-blue-100">
              <UserIcon className="w-6 h-6 text-blue-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-green-100">
              <UserIcon className="w-6 h-6 text-green-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Ativos</p>
              <p className="text-2xl font-bold text-gray-900">{stats.active}</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-yellow-100">
              <UserIcon className="w-6 h-6 text-yellow-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Pessoa Física</p>
              <p className="text-2xl font-bold text-gray-900">{stats.pf}</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-purple-100">
              <BuildingOfficeIcon className="w-6 h-6 text-purple-600" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Pessoa Jurídica</p>
              <p className="text-2xl font-bold text-gray-900">{stats.pj}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Filtros */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Busca */}
          <div className="relative">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar cliente..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
            />
          </div>
          
          {/* Filtro Tipo */}
          <select
            value={filterType}
            onChange={(e) => setFilterType(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
          >
            <option value="all">Todos os tipos</option>
            <option value="PF">Pessoa Física</option>
            <option value="PJ">Pessoa Jurídica</option>
          </select>
          
          {/* Filtro Status */}
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
          >
            <option value="all">Todos os status</option>
            <option value="Ativo">Ativo</option>
            <option value="Inativo">Inativo</option>
          </select>
        </div>
      </div>

      {/* Lista de Clientes */}
      <div className="bg-white rounded-lg shadow-sm overflow-hidden">
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
                  Processos
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredClients.map((client) => (
                <tr key={client.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
                        {client.type === 'PF' ? (
                          <UserIcon className="w-5 h-5 text-red-600" />
                        ) : (
                          <BuildingOfficeIcon className="w-5 h-5 text-red-600" />
                        )}
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{client.name}</div>
                        <div className="text-sm text-gray-500">{client.type}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {client.document}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{client.email}</div>
                    <div className="text-sm text-gray-500">{client.phone}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      client.status === 'Ativo' 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {client.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {client.processes}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex justify-end space-x-2">
                      <button className="text-blue-600 hover:text-blue-900">
                        <EyeIcon className="w-5 h-5" />
                      </button>
                      <Link
                        to={`/admin/clients/${client.id}/edit`}
                        className="text-red-600 hover:text-red-900"
                      >
                        <PencilIcon className="w-5 h-5" />
                      </Link>
                      <button
                        onClick={() => handleDelete(client.id)}
                        className="text-red-600 hover:text-red-900"
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
        
        {filteredClients.length === 0 && (
          <div className="text-center py-12">
            <UserIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum cliente encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || filterType !== 'all' || filterStatus !== 'all'
                ? 'Tente ajustar os filtros de busca.'
                : 'Comece cadastrando um novo cliente.'}
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default ClientList;
EOF

echo "✅ ClientList corrigida (Parte 1/2)!"
echo ""
echo "📊 IMPLEMENTADO:"
echo "   • Lista completa com dados mock"
echo "   • Estatísticas em cards"
echo "   • Filtros funcionais (busca, tipo, status)"
echo "   • Tabela responsiva"
echo "   • Ações (visualizar, editar, excluir)"
echo "   • Estados de loading"
echo ""
echo "⏭️ Execute o script e digite 'continuar' para Parte 2: NewClient e EditClient"