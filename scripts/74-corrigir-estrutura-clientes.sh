#!/bin/bash

# Script 74 - Corrigir Estrutura de Clientes (Mover para .js)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "🔧 Corrigindo estrutura de clientes - movendo para Clients.js..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar estrutura frontend
if [ ! -d "frontend/src/pages/admin" ]; then
    echo "❌ Erro: Estrutura frontend não encontrada"
    exit 1
fi

echo "📁 Fazendo backup e movendo arquivos..."

# Fazer backup do Clients.js atual
if [ -f "frontend/src/pages/admin/Clients.js" ]; then
    cp frontend/src/pages/admin/Clients.js frontend/src/pages/admin/Clients.js.backup
    echo "✅ Backup criado: Clients.js.backup"
fi

# Verificar se existe a pasta Clients com index.js
if [ -f "frontend/src/pages/admin/Clients/index.js" ]; then
    echo "✅ Encontrada página completa em: Clients/index.js"
    
    # Copiar conteúdo da pasta para o arquivo .js
    cp frontend/src/pages/admin/Clients/index.js frontend/src/pages/admin/Clients.js
    echo "✅ Conteúdo copiado para: Clients.js"
    
    # Remover pasta Clients
    rm -rf frontend/src/pages/admin/Clients/
    echo "✅ Pasta Clients/ removida"
else
    echo "⚠️  Pasta Clients/index.js não encontrada - criando página completa..."
    
    # Criar página completa no Clients.js
    cat > frontend/src/pages/admin/Clients.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  UserIcon,
  BuildingOfficeIcon,
  ArrowUpIcon,
  ArrowDownIcon
} from '@heroicons/react/24/outline';

const Clients = () => {
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all');
  const [filterStatus, setFilterStatus] = useState('all');

  // Mock data seguindo padrão do Dashboard
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
    },
    {
      id: 5,
      name: 'Ana Costa Advocacia',
      document: '11.222.333/0001-44',
      email: 'ana@costa.adv.br',
      phone: '(11) 5555-5555',
      type: 'PJ',
      status: 'Ativo',
      createdAt: '2024-02-15',
      processes: 12
    }
  ];

  useEffect(() => {
    // Simular carregamento seguindo padrão
    setTimeout(() => {
      setClients(mockClients);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas
  const stats = [
    {
      name: 'Total de Clientes',
      value: clients.length.toString(),
      change: '+12%',
      changeType: 'increase',
      icon: UserIcon,
      color: 'blue',
      description: 'Cadastrados no sistema'
    },
    {
      name: 'Clientes Ativos',
      value: clients.filter(c => c.status === 'Ativo').length.toString(),
      change: '+8%',
      changeType: 'increase',
      icon: UserIcon,
      color: 'green',
      description: 'Com processos em andamento'
    },
    {
      name: 'Pessoa Física',
      value: clients.filter(c => c.type === 'PF').length.toString(),
      change: '+15%',
      changeType: 'increase',
      icon: UserIcon,
      color: 'yellow',
      description: 'CPF cadastrados'
    },
    {
      name: 'Pessoa Jurídica',
      value: clients.filter(c => c.type === 'PJ').length.toString(),
      change: '+5%',
      changeType: 'increase',
      icon: BuildingOfficeIcon,
      color: 'purple',
      description: 'CNPJ cadastrados'
    }
  ];

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

  // Ações rápidas
  const quickActions = [
    { title: 'Novo Cliente', icon: '👤', color: 'blue', href: '/admin/clientes/novo' },
    { title: 'Importar Clientes', icon: '📥', color: 'green', href: '/admin/clientes/importar' },
    { title: 'Relatório de Clientes', icon: '📊', color: 'purple', href: '/admin/relatorios/clientes' },
    { title: 'Exportar Lista', icon: '📤', color: 'yellow', href: '/admin/clientes/exportar' }
  ];

  if (loading) {
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

  return (
    <div className="space-y-8">
      {/* Header seguindo padrão Dashboard */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Gestão de Clientes</h1>
        <p className="mt-2 text-lg text-gray-600">
          Gerencie todos os clientes do escritório com facilidade
        </p>
      </div>

      {/* Stats Cards seguindo EXATO padrão Dashboard */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((item) => (
          <div key={item.name} className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
            <div className="p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className={`p-3 rounded-lg bg-${item.color}-100`}>
                    <item.icon className={`h-6 w-6 text-${item.color}-600`} />
                  </div>
                </div>
                <div className={`flex items-center text-sm font-semibold ${
                  item.changeType === 'increase' ? 'text-green-600' : 'text-red-600'
                }`}>
                  {item.changeType === 'increase' ? (
                    <ArrowUpIcon className="h-4 w-4 mr-1" />
                  ) : (
                    <ArrowDownIcon className="h-4 w-4 mr-1" />
                  )}
                  {item.change}
                </div>
              </div>
              <div className="mt-4">
                <h3 className="text-sm font-medium text-gray-500">{item.name}</h3>
                <p className="text-3xl font-bold text-gray-900 mt-1">{item.value}</p>
                <p className="text-sm text-gray-500 mt-1">{item.description}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Ações Rápidas */}
        <div className="lg:col-span-2">
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Ações Rápidas</h2>
              <EyeIcon className="h-5 w-5 text-gray-400" />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {quickActions.map((action) => (
                <Link
                  key={action.title}
                  to={action.href}
                  className="group flex flex-col items-center p-6 border-2 border-dashed border-gray-300 rounded-xl hover:border-primary-500 hover:bg-primary-50 transition-all duration-200"
                >
                  <span className="text-3xl mb-3 group-hover:scale-110 transition-transform duration-200">
                    {action.icon}
                  </span>
                  <span className="text-sm font-medium text-gray-900 group-hover:text-primary-700">
                    {action.title}
                  </span>
                </Link>
              ))}
            </div>
          </div>
        </div>

        {/* Filtros Rápidos */}
        <div>
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Filtros Rápidos</h2>
              <PlusIcon className="h-5 w-5 text-gray-400" />
            </div>
            <div className="space-y-4">
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Clientes Ativos</span>
                  <span className="text-primary-600 font-semibold">{clients.filter(c => c.status === 'Ativo').length}</span>
                </div>
              </button>
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Pessoa Física</span>
                  <span className="text-blue-600 font-semibold">{clients.filter(c => c.type === 'PF').length}</span>
                </div>
              </button>
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Pessoa Jurídica</span>
                  <span className="text-purple-600 font-semibold">{clients.filter(c => c.type === 'PJ').length}</span>
                </div>
              </button>
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Novos (30 dias)</span>
                  <span className="text-green-600 font-semibold">2</span>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Lista de Clientes */}
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
              placeholder="Buscar cliente..."
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
            <option value="Ativo">Ativo</option>
            <option value="Inativo">Inativo</option>
          </select>
        </div>

        {/* Tabela */}
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
                      <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                        {client.type === 'PF' ? (
                          <UserIcon className="w-5 h-5 text-primary-600" />
                        ) : (
                          <BuildingOfficeIcon className="w-5 h-5 text-primary-600" />
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
                      <button 
                        className="text-blue-600 hover:text-blue-900"
                        title="Visualizar"
                      >
                        <EyeIcon className="w-5 h-5" />
                      </button>
                      <Link
                        to={`/admin/clientes/${client.id}/editar`}
                        className="text-primary-600 hover:text-primary-900"
                        title="Editar"
                      >
                        <PencilIcon className="w-5 h-5" />
                      </Link>
                      <button
                        onClick={() => handleDelete(client.id)}
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

export default Clients;
EOF
fi

echo ""
echo "✅ ESTRUTURA CORRIGIDA!"
echo ""
echo "📁 ARQUIVOS ATUALIZADOS:"
echo "   • frontend/src/pages/admin/Clients.js (página completa)"
echo "   • Pasta frontend/src/pages/admin/Clients/ removida"
echo ""
echo "🎨 PÁGINA COMPLETA INCLUI:"
echo "   • Dashboard com estatísticas"
echo "   • Cards de ações rápidas"
echo "   • Filtros inteligentes"
echo "   • Lista completa de clientes"
echo "   • Botões para cadastro/edição/exclusão"
echo "   • Design seguindo padrão Erlene"
echo ""
echo "🔗 TESTE:"
echo "   • http://localhost:3000/admin/clientes"
echo ""
echo "💾 BACKUP SALVO:"
echo "   • frontend/src/pages/admin/Clients.js.backup"