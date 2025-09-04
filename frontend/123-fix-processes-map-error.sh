#!/bin/bash

# Script 123 - Corrigir erro "processes.map is not a function"
# Sistema Erlene Advogados - Erro: processes não é um array
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 123 - Corrigindo erro processes.map is not a function..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 123-fix-processes-map-error.sh && ./123-fix-processes-map-error.sh"
    exit 1
fi

echo "1️⃣ DIAGNÓSTICO DO ERRO:"
echo "   • Erro: processes.map is not a function"
echo "   • Causa: processes não é um array"
echo "   • Solução: Garantir que processes sempre seja array []"

echo ""
echo "2️⃣ Corrigindo Processes.js para garantir array..."

# Backup do arquivo atual
cp src/pages/admin/Processes.js src/pages/admin/Processes.js.backup

# Corrigir Processes.js com validação robusta de array
cat > src/pages/admin/Processes.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { processesService } from '../../services/processesService';
import {
  MagnifyingGlassIcon,
  PlusIcon,
  EyeIcon,
  PencilIcon,
  UserIcon,
  ScaleIcon,
  ClockIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon
} from '@heroicons/react/24/outline';

const Processes = () => {
  const [processes, setProcesses] = useState([]); // SEMPRE inicializar como array
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  // eslint-disable-next-line react-hooks/exhaustive-deps
  const loadProcesses = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const params = {
        page: currentPage,
        per_page: 15,
        ...(search && { search }),
        ...(statusFilter && { status: statusFilter })
      };

      console.log('Carregando processos com params:', params);
      const response = await processesService.getProcesses(params);
      
      console.log('Resposta completa da API:', response);

      if (response && response.success) {
        // VALIDAÇÃO ROBUSTA: garantir que sempre seja array
        let dataArray = [];
        
        if (Array.isArray(response.data)) {
          dataArray = response.data;
        } else if (response.data && Array.isArray(response.data.data)) {
          dataArray = response.data.data;
        } else if (response.data && typeof response.data === 'object') {
          // Se response.data é objeto, tentar extrair array
          const possibleArrays = Object.values(response.data).filter(Array.isArray);
          if (possibleArrays.length > 0) {
            dataArray = possibleArrays[0];
          }
        }
        
        console.log('Array de processos extraído:', dataArray);
        setProcesses(Array.isArray(dataArray) ? dataArray : []);
        
        // Paginação
        if (response.meta) {
          setTotalPages(response.meta.last_page || 1);
        } else if (response.data && response.data.meta) {
          setTotalPages(response.data.meta.last_page || 1);
        }
      } else {
        console.error('Resposta da API inválida:', response);
        setProcesses([]); // Garantir array vazio
        throw new Error(response?.message || 'Erro ao carregar processos');
      }
    } catch (err) {
      console.error('Erro ao carregar processos:', err);
      setError('Erro ao carregar processos. Verifique sua conexão.');
      setProcesses([]); // Garantir array vazio mesmo em erro
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProcesses();
  }, [currentPage, search, statusFilter]);

  const handleSearch = (e) => {
    setSearch(e.target.value);
    setCurrentPage(1);
  };

  const handleStatusFilter = (status) => {
    setStatusFilter(status);
    setCurrentPage(1);
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'em_andamento':
        return 'bg-blue-100 text-blue-800';
      case 'suspenso':
        return 'bg-yellow-100 text-yellow-800';
      case 'finalizado':
        return 'bg-green-100 text-green-800';
      case 'arquivado':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'urgente':
        return 'bg-red-100 text-red-800';
      case 'alta':
        return 'bg-orange-100 text-orange-800';
      case 'media':
        return 'bg-yellow-100 text-yellow-800';
      case 'baixa':
        return 'bg-green-100 text-green-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    try {
      return new Date(dateString).toLocaleDateString('pt-BR');
    } catch (e) {
      return 'Data inválida';
    }
  };

  const formatCurrency = (value) => {
    if (!value || value === null || value === undefined) return 'N/A';
    try {
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
      }).format(value);
    } catch (e) {
      return 'R$ 0,00';
    }
  };

  // Função segura para extrair nome do cliente
  const getClientName = (processo) => {
    if (!processo) return 'Cliente não informado';
    
    if (processo.cliente_nome && typeof processo.cliente_nome === 'string') {
      return processo.cliente_nome;
    }
    
    if (processo.cliente && typeof processo.cliente === 'object') {
      return processo.cliente.nome || 'Nome não informado';
    }
    
    return 'Cliente não informado';
  };

  // Função segura para extrair nome do advogado
  const getAdvogadoName = (processo) => {
    if (!processo) return 'Não atribuído';
    
    if (processo.advogado_nome && typeof processo.advogado_nome === 'string') {
      return processo.advogado_nome;
    }
    
    if (processo.advogado && typeof processo.advogado === 'object') {
      if (processo.advogado.name && typeof processo.advogado.name === 'string') {
        return processo.advogado.name;
      }
      if (processo.advogado.nome && typeof processo.advogado.nome === 'string') {
        return processo.advogado.nome;
      }
    }
    
    return 'Não atribuído';
  };

  // VALIDAÇÃO FINAL: garantir que processes é sempre array antes do render
  const safeProcesses = Array.isArray(processes) ? processes : [];

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
        <div className="grid grid-cols-1 gap-6">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="bg-white rounded-xl p-6 animate-pulse">
              <div className="h-6 bg-gray-200 rounded mb-4"></div>
              <div className="grid grid-cols-4 gap-4">
                <div className="h-4 bg-gray-200 rounded"></div>
                <div className="h-4 bg-gray-200 rounded"></div>
                <div className="h-4 bg-gray-200 rounded"></div>
                <div className="h-4 bg-gray-200 rounded"></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-8">
        <div className="bg-red-50 border border-red-200 rounded-xl p-6">
          <div className="flex items-center">
            <ExclamationTriangleIcon className="w-6 h-6 text-red-600 mr-3" />
            <div>
              <h3 className="text-lg font-medium text-red-900">Erro ao carregar processos</h3>
              <p className="text-red-700 mt-1">{error}</p>
            </div>
          </div>
          <div className="mt-4">
            <button
              onClick={loadProcesses}
              className="inline-flex items-center px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              Tentar novamente
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Processos</h1>
            <p className="text-lg text-gray-600 mt-2">
              Gerencie todos os processos do escritório ({safeProcesses.length} processos)
            </p>
          </div>
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/processos/novo"
              className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
            >
              <PlusIcon className="w-4 h-4 mr-2" />
              Novo Processo
            </Link>
          </div>
        </div>
      </div>

      {/* Filtros */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Filtros</h2>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Busca */}
          <div className="relative">
            <MagnifyingGlassIcon className="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar processos..."
              value={search}
              onChange={handleSearch}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>

          {/* Filtro Status */}
          <select
            value={statusFilter}
            onChange={(e) => handleStatusFilter(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="">Todos os Status</option>
            <option value="em_andamento">Em Andamento</option>
            <option value="suspenso">Suspenso</option>
            <option value="finalizado">Finalizado</option>
            <option value="arquivado">Arquivado</option>
          </select>

          {/* Limpar Filtros */}
          <button
            onClick={() => {
              setSearch('');
              setStatusFilter('');
              setCurrentPage(1);
            }}
            className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
          >
            Limpar Filtros
          </button>
        </div>
      </div>

      {/* Lista de Processos */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">
            Processos ({safeProcesses.length})
          </h3>
          <p className="text-sm text-gray-500 mt-1">
            Tipo de dados: {Array.isArray(processes) ? 'Array' : typeof processes}
          </p>
        </div>

        {safeProcesses.length === 0 ? (
          <div className="text-center py-12">
            <DocumentTextIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum processo encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              {loading ? 'Carregando...' : 'Comece criando um novo processo.'}
            </p>
            {!loading && (
              <div className="mt-6">
                <Link
                  to="/admin/processos/novo"
                  className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
                >
                  <PlusIcon className="w-4 h-4 mr-2" />
                  Novo Processo
                </Link>
              </div>
            )}
          </div>
        ) : (
          <div className="overflow-hidden">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Processo
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Cliente
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Advogado
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Valor
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Data
                    </th>
                    <th className="relative px-6 py-3">
                      <span className="sr-only">Ações</span>
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {safeProcesses.map((processo, index) => (
                    <tr key={processo?.id || index} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div>
                          <div className="text-sm font-medium text-gray-900">
                            {processo?.numero || 'Número não informado'}
                          </div>
                          <div className="text-sm text-gray-500">
                            {processo?.tipo_acao || 'Tipo não informado'}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <UserIcon className="w-4 h-4 text-gray-400 mr-2" />
                          <div className="text-sm text-gray-900">
                            {getClientName(processo)}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <ScaleIcon className="w-4 h-4 text-gray-400 mr-2" />
                          <div className="text-sm text-gray-900">
                            {getAdvogadoName(processo)}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center space-x-2">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(processo?.status)}`}>
                            {processo?.status || 'Status não informado'}
                          </span>
                          {processo?.prioridade && (
                            <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(processo.prioridade)}`}>
                              {processo.prioridade}
                            </span>
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {formatCurrency(processo?.valor_causa)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <ClockIcon className="w-4 h-4 text-gray-400 mr-2" />
                          <div className="text-sm text-gray-900">
                            {formatDate(processo?.data_distribuicao)}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center space-x-2">
                          <Link
                            to={`/admin/processos/${processo?.id || 0}`}
                            className="text-primary-600 hover:text-primary-900 p-1 rounded"
                          >
                            <EyeIcon className="w-4 h-4" />
                          </Link>
                          <Link
                            to={`/admin/processos/${processo?.id || 0}/editar`}
                            className="text-blue-600 hover:text-blue-900 p-1 rounded"
                          >
                            <PencilIcon className="w-4 h-4" />
                          </Link>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Paginação */}
            {totalPages > 1 && (
              <div className="px-6 py-4 border-t border-gray-200">
                <div className="flex items-center justify-between">
                  <div className="text-sm text-gray-700">
                    Página {currentPage} de {totalPages}
                  </div>
                  <div className="flex items-center space-x-2">
                    <button
                      onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                      disabled={currentPage === 1}
                      className="px-3 py-1 border border-gray-300 text-sm rounded disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      Anterior
                    </button>
                    <button
                      onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                      disabled={currentPage === totalPages}
                      className="px-3 py-1 border border-gray-300 text-sm rounded disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      Próxima
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Debug Info (remover em produção) */}
      {process.env.NODE_ENV === 'development' && (
        <div className="bg-gray-100 p-4 rounded text-xs">
          <strong>Debug:</strong>
          <br />
          processes tipo: {typeof processes}
          <br />
          processes é array: {Array.isArray(processes) ? 'Sim' : 'Não'}
          <br />
          safeProcesses length: {safeProcesses.length}
          <br />
          Primeiro processo: {JSON.stringify(safeProcesses[0] || {}, null, 2)}
        </div>
      )}
    </div>
  );
};

export default Processes;
EOF

echo ""
echo "3️⃣ Testando a API diretamente para entender o formato dos dados..."

# Criar script de teste da API
cat > test-api.js << 'EOF'
const API_BASE_URL = 'http://localhost:8000/api';

async function testAPI() {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/processes`, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    });
    
    console.log('Status:', response.status);
    
    if (response.status === 401) {
      console.log('❌ Erro 401: Token de autenticação necessário');
      return;
    }
    
    const data = await response.json();
    console.log('Resposta completa:', JSON.stringify(data, null, 2));
    
    if (data && data.data) {
      console.log('Tipo de data:', typeof data.data);
      console.log('É array?', Array.isArray(data.data));
    }
    
  } catch (error) {
    console.error('Erro na requisição:', error);
  }
}

testAPI();
EOF

echo "Testando API..."
node test-api.js
rm test-api.js

echo ""
echo "✅ CORREÇÕES APLICADAS!"
echo ""
echo "🔍 O que foi corrigido:"
echo "   • processes sempre inicializado como array []"
echo "   • Validação robusta da resposta da API"
echo "   • safeProcesses = Array.isArray(processes) ? processes : []"
echo "   • Logs detalhados para debug"
echo "   • Tratamento de diferentes formatos de resposta"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. Acesse http://localhost:3000/admin/processos"
echo "   2. O erro 'processes.map is not a function' deve ter desaparecido"
echo "   3. Verifique o console do navegador para logs de debug"
echo "   4. Veja a seção 'Debug' na tela se houver problemas"