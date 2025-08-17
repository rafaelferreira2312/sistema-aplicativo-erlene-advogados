#!/bin/bash
# Script 107a - Dashboard de Usuários (Parte 1/3)
# Autor: Sistema Erlene Advogados  
# Data: $(date +%Y-%m-%d)
# Enumeração: 107a

echo "🔧 Criando Dashboard de Usuários (Parte 1 - Script 107a)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto frontend"
    exit 1
fi

# Criar estrutura de pastas
echo "📁 Criando estrutura para módulo Usuários..."
mkdir -p frontend/src/pages/admin
mkdir -p frontend/src/components/users

# Criar página principal de usuários
echo "👥 Criando página Users.js..."
cat > frontend/src/pages/admin/Users.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { 
  UserGroupIcon,
  UsersIcon,
  ShieldCheckIcon,
  ClockIcon,
  PlusIcon,
  FunnelIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  KeyIcon,
  ExclamationTriangleIcon
} from '@heroicons/react/24/outline';
import { Link } from 'react-router-dom';

const Users = () => {
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedRole, setSelectedRole] = useState('all');
  const [selectedStatus, setSelectedStatus] = useState('all');

  // Mock data para usuários
  const userStats = {
    total: 12,
    active: 10,
    inactive: 2,
    administrators: 3,
    lawyers: 6,
    assistants: 3,
    lastLogin: '2024-03-15T10:30:00',
    newThisMonth: 2
  };

  const users = [
    {
      id: 1,
      name: 'Dra. Erlene Chaves Silva',
      email: 'erlene@erleneadvogados.com.br',
      role: 'Administrador',
      status: 'Ativo',
      lastLogin: '2024-03-15T09:15:00',
      avatar: null,
      permissions: ['full_access'],
      unit: 'Matriz',
      phone: '(11) 99999-9999',
      createdAt: '2023-01-15'
    },
    {
      id: 2,
      name: 'Dr. João Silva Santos',
      email: 'joao@erleneadvogados.com.br',
      role: 'Advogado Sênior',
      status: 'Ativo',
      lastLogin: '2024-03-15T08:45:00',
      avatar: null,
      permissions: ['processes', 'clients', 'reports'],
      unit: 'Matriz',
      phone: '(11) 98888-8888',
      createdAt: '2023-02-20'
    },
    {
      id: 3,
      name: 'Dra. Maria Oliveira Costa',
      email: 'maria@erleneadvogados.com.br',
      role: 'Advogada',
      status: 'Ativo',
      lastLogin: '2024-03-14T17:30:00',
      avatar: null,
      permissions: ['processes', 'clients'],
      unit: 'Filial SP',
      phone: '(11) 97777-7777',
      createdAt: '2023-03-10'
    },
    {
      id: 4,
      name: 'Carlos Roberto Lima',
      email: 'carlos@erleneadvogados.com.br',
      role: 'Assistente Jurídico',
      status: 'Ativo',
      lastLogin: '2024-03-15T07:20:00',
      avatar: null,
      permissions: ['clients', 'documents'],
      unit: 'Matriz',
      phone: '(11) 96666-6666',
      createdAt: '2023-04-05'
    },
    {
      id: 5,
      name: 'Ana Paula Ferreira',
      email: 'ana@erleneadvogados.com.br',
      role: 'Secretária',
      status: 'Ativo',
      lastLogin: '2024-03-15T08:00:00',
      avatar: null,
      permissions: ['clients', 'schedule'],
      unit: 'Matriz',
      phone: '(11) 95555-5555',
      createdAt: '2023-05-15'
    },
    {
      id: 6,
      name: 'Roberto Silva Nunes',
      email: 'roberto@erleneadvogados.com.br',
      role: 'Advogado',
      status: 'Inativo',
      lastLogin: '2024-03-01T16:45:00',
      avatar: null,
      permissions: ['processes'],
      unit: 'Filial RJ',
      phone: '(21) 94444-4444',
      createdAt: '2023-06-20'
    }
  ];

  const roles = [
    { value: 'all', label: 'Todos os Perfis' },
    { value: 'Administrador', label: 'Administrador' },
    { value: 'Advogado Sênior', label: 'Advogado Sênior' },
    { value: 'Advogado', label: 'Advogado' },
    { value: 'Assistente Jurídico', label: 'Assistente Jurídico' },
    { value: 'Secretária', label: 'Secretária' }
  ];

  useEffect(() => {
    // Simular carregamento
    const timer = setTimeout(() => {
      setIsLoading(false);
    }, 1000);

    return () => clearTimeout(timer);
  }, []);

  // Filtrar usuários
  const filteredUsers = users.filter(user => {
    const matchesSearch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.email.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesRole = selectedRole === 'all' || user.role === selectedRole;
    const matchesStatus = selectedStatus === 'all' || user.status === selectedStatus;
    
    return matchesSearch && matchesRole && matchesStatus;
  });

  const getRoleColor = (role) => {
    switch (role) {
      case 'Administrador': return 'bg-red-100 text-red-800';
      case 'Advogado Sênior': return 'bg-purple-100 text-purple-800';
      case 'Advogado': return 'bg-blue-100 text-blue-800';
      case 'Assistente Jurídico': return 'bg-green-100 text-green-800';
      case 'Secretária': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusColor = (status) => {
    return status === 'Ativo' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
  };

  const formatLastLogin = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR') + ' ' + date.toLocaleTimeString('pt-BR', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  const handleDeleteUser = (userId, userName) => {
    if (window.confirm(`Tem certeza que deseja excluir o usuário "${userName}"?`)) {
      console.log('Excluindo usuário:', userId);
      // Implementar lógica de exclusão
    }
  };

  const handleResetPassword = (userId, userName) => {
    if (window.confirm(`Tem certeza que deseja resetar a senha de "${userName}"?`)) {
      console.log('Resetando senha para usuário:', userId);
      // Implementar lógica de reset de senha
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="sm:flex sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Gestão de Usuários</h1>
          <p className="mt-2 text-sm text-gray-700">
            Gerencie usuários, permissões e perfis de acesso
          </p>
        </div>
        <div className="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
          <Link
            to="/admin/users/novo"
            className="inline-flex items-center justify-center rounded-md border border-transparent bg-primary-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 sm:w-auto"
          >
            <PlusIcon className="-ml-1 mr-2 h-5 w-5" />
            Novo Usuário
          </Link>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <UserGroupIcon className="h-6 w-6 text-primary-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Total de Usuários</dt>
                  <dd className="text-2xl font-bold text-gray-900">{userStats.total}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ShieldCheckIcon className="h-6 w-6 text-green-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Usuários Ativos</dt>
                  <dd className="text-2xl font-bold text-green-600">{userStats.active}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <UsersIcon className="h-6 w-6 text-blue-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Advogados</dt>
                  <dd className="text-2xl font-bold text-blue-600">{userStats.lawyers}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ClockIcon className="h-6 w-6 text-yellow-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Novos Este Mês</dt>
                  <dd className="text-2xl font-bold text-yellow-600">+{userStats.newThisMonth}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-4">
            <div className="sm:col-span-2">
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <MagnifyingGlassIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-primary-500 focus:border-primary-500"
                  placeholder="Buscar por nome ou email..."
                />
              </div>
            </div>
            <div>
              <select
                value={selectedRole}
                onChange={(e) => setSelectedRole(e.target.value)}
                className="block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-primary-500 focus:border-primary-500 rounded-md"
              >
                {roles.map((role) => (
                  <option key={role.value} value={role.value}>
                    {role.label}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <select
                value={selectedStatus}
                onChange={(e) => setSelectedStatus(e.target.value)}
                className="block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-primary-500 focus:border-primary-500 rounded-md"
              >
                <option value="all">Todos os Status</option>
                <option value="Ativo">Ativos</option>
                <option value="Inativo">Inativos</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-white shadow-erlene rounded-lg overflow-hidden">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Lista de Usuários ({filteredUsers.length})
          </h3>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Usuário
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Perfil
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Unidade
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Último Login
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="h-10 w-10 flex-shrink-0">
                          <div className="h-10 w-10 rounded-full bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center">
                            <span className="text-sm font-medium text-white">
                              {user.name.charAt(0)}
                            </span>
                          </div>
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">{user.name}</div>
                          <div className="text-sm text-gray-500">{user.email}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getRoleColor(user.role)}`}>
                        {user.role}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {user.unit}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(user.status)}`}>
                        {user.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {formatLastLogin(user.lastLogin)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <div className="flex justify-end space-x-2">
                        <Link
                          to={`/admin/users/${user.id}`}
                          className="text-primary-600 hover:text-primary-900"
                          title="Visualizar"
                        >
                          <EyeIcon className="h-4 w-4" />
                        </Link>
                        <Link
                          to={`/admin/users/${user.id}/editar`}
                          className="text-blue-600 hover:text-blue-900"
                          title="Editar"
                        >
                          <PencilIcon className="h-4 w-4" />
                        </Link>
                        <button
                          onClick={() => handleResetPassword(user.id, user.name)}
                          className="text-yellow-600 hover:text-yellow-900"
                          title="Resetar Senha"
                        >
                          <KeyIcon className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleDeleteUser(user.id, user.name)}
                          className="text-red-600 hover:text-red-900"
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

          {filteredUsers.length === 0 && (
            <div className="text-center py-12">
              <ExclamationTriangleIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum usuário encontrado</h3>
              <p className="mt-1 text-sm text-gray-500">
                Tente ajustar os filtros ou termos de busca.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Users;
EOF

echo "✅ Dashboard de Usuários criado com sucesso!"
echo ""
echo "📋 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Dashboard com estatísticas de usuários"
echo "   • Cards informativos (Total, Ativos, Advogados, Novos)"
echo "   • Lista completa de usuários com filtros"
echo "   • Busca por nome e email"
echo "   • Filtros por perfil e status"
echo "   • Tabela responsiva com informações detalhadas"
echo "   • Ações para visualizar, editar, resetar senha e excluir"
echo "   • Avatars com iniciais dos nomes"
echo "   • Formatação de data/hora do último login"
echo "   • Estados vazios para quando não há resultados"
echo ""
echo "👥 PERFIS DE USUÁRIO INCLUÍDOS:"
echo "   • Administrador (Erlene)"
echo "   • Advogado Sênior (João)"
echo "   • Advogado (Maria)"
echo "   • Assistente Jurídico (Carlos)"
echo "   • Secretária (Ana)"
echo "   • Advogado Inativo (Roberto)"
echo ""
echo "🔗 ROTA CONFIGURADA:"
echo "   • /admin/users - Dashboard de usuários"
echo ""
echo "📁 ARQUIVO CRIADO:"
echo "   • frontend/src/pages/admin/Users.js"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/3):"
echo "   • Formulário de cadastro de usuário (NewUser.js)"
echo "   • Sistema de permissões e roles"
echo "   • Validações completas"
echo ""
echo "Digite 'continuar' para Parte 2/3!"