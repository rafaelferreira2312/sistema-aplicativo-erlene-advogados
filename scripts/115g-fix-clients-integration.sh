#!/bin/bash

# Script 115g - Integração Direta de Clientes (sem loop infinito)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115g-fix-clients-integration.sh && ./115g-fix-clients-integration.sh
# EXECUTE NA PASTA: frontend/

echo "Corrigindo integração da lista de clientes..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "Execute este script na pasta frontend/"
    exit 1
fi

echo "1. Corrigindo useClients para evitar loop infinito..."

# Substituir useClients completamente para evitar loop
cat > src/hooks/useClients.js << 'EOF'
import { useState, useEffect, useCallback } from 'react';
import { clientsService } from '../services/api/clientsService';
import toast from 'react-hot-toast';

export const useClients = (initialParams = {}) => {
  const [clients, setClients] = useState([]);
  const [stats, setStats] = useState({ total: 0, ativos: 0, pf: 0, pj: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Carregar clientes - função estável
  const loadClients = useCallback(async (params = {}) => {
    try {
      setLoading(true);
      setError(null);
      
      console.log('Carregando clientes com parâmetros:', params);
      const response = await clientsService.getClients(params);
      
      console.log('Resposta da API:', response);
      
      // Extrair dados da resposta
      let clientsData = [];
      if (response?.data) {
        if (Array.isArray(response.data)) {
          clientsData = response.data;
        } else if (response.data.data && Array.isArray(response.data.data)) {
          clientsData = response.data.data;
        }
      }
      
      console.log('Clientes extraídos:', clientsData);
      setClients(clientsData);
    } catch (err) {
      console.error('Erro ao carregar clientes:', err);
      setError(err.message);
      setClients([]);
      toast.error('Erro ao carregar clientes');
    } finally {
      setLoading(false);
    }
  }, []);

  // Carregar estatísticas
  const loadStats = useCallback(async () => {
    try {
      const response = await clientsService.getStats();
      if (response?.data) {
        setStats(response.data);
      }
    } catch (err) {
      console.error('Erro ao carregar estatísticas:', err);
    }
  }, []);

  // Carregar dados apenas uma vez
  useEffect(() => {
    loadClients();
    loadStats();
  }, []); // Array vazio para carregar apenas uma vez

  // Aplicar filtros
  const applyFilters = useCallback((params) => {
    loadClients(params);
  }, [loadClients]);

  // Criar cliente
  const createClient = useCallback(async (clientData) => {
    try {
      const response = await clientsService.createClient(clientData);
      toast.success('Cliente criado com sucesso!');
      await loadClients();
      await loadStats();
      return response;
    } catch (err) {
      toast.error('Erro ao criar cliente');
      throw err;
    }
  }, [loadClients, loadStats]);

  // Atualizar cliente
  const updateClient = useCallback(async (id, clientData) => {
    try {
      const response = await clientsService.updateClient(id, clientData);
      toast.success('Cliente atualizado com sucesso!');
      await loadClients();
      return response;
    } catch (err) {
      toast.error('Erro ao atualizar cliente');
      throw err;
    }
  }, [loadClients]);

  // Deletar cliente
  const deleteClient = useCallback(async (id) => {
    try {
      await clientsService.deleteClient(id);
      toast.success('Cliente excluído com sucesso!');
      await loadClients();
      await loadStats();
    } catch (err) {
      toast.error('Erro ao excluir cliente');
      throw err;
    }
  }, [loadClients, loadStats]);

  return {
    clients: Array.isArray(clients) ? clients : [],
    stats,
    loading,
    error,
    loadClients,
    createClient,
    updateClient,
    deleteClient,
    applyFilters,
    refresh: () => {
      loadClients();
      loadStats();
    }
  };
};
EOF

echo "2. Simplificando página Clients para usar dados reais..."

cat > src/pages/admin/Clients.js << 'EOF'
import React, { useState } from 'react';
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
import { formatDocument, formatPhone } from '../../utils/formatters';

const Clients = () => {
  const {
    clients,
    stats,
    loading,
    error,
    deleteClient,
    applyFilters
  } = useClients();

  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all');
  const [filterStatus, setFilterStatus] = useState('all');

  // Aplicar filtros quando mudarem
  const handleFilterChange = () => {
    const filters = {};
    
    if (searchTerm) filters.search = searchTerm;
    if (filterType !== 'all') filters.tipo_pessoa = filterType;
    if (filterStatus !== 'all') filters.status = filterStatus;

    applyFilters(filters);
  };

  const handleDelete = async (id, name) => {
    if (window.confirm(`Tem certeza que deseja excluir o cliente ${name}?`)) {
      try {
        await deleteClient(id);
      } catch (error) {
        console.error('Erro ao excluir cliente:', error);
      }
    }
  };

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
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
        <div className="bg-white overflow-hidden shadow rounded-xl border border-gray-100 p-6">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-blue-100">
              <UserIcon className="h-6 w-6 text-blue-600" />
            </div>
          </div>
          <div className="mt-4">
            <h3 className="text-sm font-medium text-gray-500">Total de Clientes</h3>
            <p className="text-3xl font-bold text-gray-900 mt-1">{stats.total || 0}</p>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow rounded-xl border border-gray-100 p-6">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-green-100">
              <UserIcon className="h-6 w-6 text-green-600" />
            </div>
          </div>
          <div className="mt-4">
            <h3 className="text-sm font-medium text-gray-500">Clientes Ativos</h3>
            <p className="text-3xl font-bold text-gray-900 mt-1">{stats.ativos || 0}</p>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow rounded-xl border border-gray-100 p-6">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-yellow-100">
              <UserIcon className="h-6 w-6 text-yellow-600" />
            </div>
          </div>
          <div className="mt-4">
            <h3 className="text-sm font-medium text-gray-500">Pessoa Física</h3>
            <p className="text-3xl font-bold text-gray-900 mt-1">{stats.pf || 0}</p>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow rounded-xl border border-gray-100 p-6">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-purple-100">
              <BuildingOfficeIcon className="h-6 w-6 text-purple-600" />
            </div>
          </div>
          <div className="mt-4">
            <h3 className="text-sm font-medium text-gray-500">Pessoa Jurídica</h3>
            <p className="text-3xl font-bold text-gray-900 mt-1">{stats.pj || 0}</p>
          </div>
        </div>
      </div>

      {/* Lista de Clientes */}
      <div className="bg-white shadow rounded-xl border border-gray-100 p-6">
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
        
        {/* Filtros */}
        <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-6">
          <div className="relative flex-1">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar cliente por nome, documento ou email..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleFilterChange()}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          
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

          <button
            onClick={handleFilterChange}
            className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
          >
            Buscar
          </button>
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
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex justify-end space-x-2">
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
        
        {clients.length === 0 && (
          <div className="text-center py-12">
            <UserIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum cliente encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              Comece cadastrando um novo cliente.
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

echo "3. Testando se clientsService está funcionando..."

# Verificar se clientsService existe
if [ ! -f "src/services/api/clientsService.js" ]; then
    echo "ClientsService não encontrado, criando..."
    
    cat > src/services/api/clientsService.js << 'EOF'
import { apiClient } from '../apiClient';

export const clientsService = {
  async getClients(params = {}) {
    try {
      console.log('Fazendo request para /admin/clients com params:', params);
      const response = await apiClient.get('/admin/clients', { params });
      console.log('Resposta recebida:', response);
      return response.data;
    } catch (error) {
      console.error('Erro no getClients:', error);
      throw error;
    }
  },

  async getStats() {
    try {
      const response = await apiClient.get('/admin/clients/stats');
      return response.data;
    } catch (error) {
      console.error('Erro no getStats:', error);
      throw error;
    }
  },

  async getClient(id) {
    try {
      const response = await apiClient.get(`/admin/clients/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro no getClient:', error);
      throw error;
    }
  },

  async createClient(clientData) {
    try {
      const response = await apiClient.post('/admin/clients', clientData);
      return response.data;
    } catch (error) {
      console.error('Erro no createClient:', error);
      throw error;
    }
  },

  async updateClient(id, clientData) {
    try {
      const response = await apiClient.put(`/admin/clients/${id}`, clientData);
      return response.data;
    } catch (error) {
      console.error('Erro no updateClient:', error);
      throw error;
    }
  },

  async deleteClient(id) {
    try {
      const response = await apiClient.delete(`/admin/clients/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro no deleteClient:', error);
      throw error;
    }
  }
};
EOF
fi

echo "Script concluído!"
echo ""
echo "CORREÇÕES APLICADAS:"
echo "• useClients sem loop infinito"
echo "• Página Clients simplificada"
echo "• clientsService verificado"
echo ""
echo "TESTE AGORA:"
echo "1. Abra o console do navegador (F12)"
echo "2. Acesse /admin/clientes"
echo "3. Veja os logs no console"
echo "4. Os 3 clientes do banco devem aparecer"