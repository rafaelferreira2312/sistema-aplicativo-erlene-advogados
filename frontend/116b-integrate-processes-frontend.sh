#!/bin/bash

# Script 116b - Integrar Frontend Processes com Backend Laravel
# Sistema Erlene Advogados - Remover dados mockados e usar API real
# Execução: chmod +x 116b-integrate-processes-frontend.sh && ./116b-integrate-processes-frontend.sh
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔗 Script 116b - Integrando processos com backend Laravel..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 116b-integrate-processes-frontend.sh && ./116b-integrate-processes-frontend.sh"
    exit 1
fi

echo "1️⃣ Verificando estrutura existente..."

# Verificar se processesService.js existe
if [ ! -f "src/services/processesService.js" ]; then
    echo "❌ Erro: processesService.js não encontrado. Execute primeiro o script 116a"
    exit 1
fi

# Verificar se componente Processes existe
if [ ! -f "src/pages/admin/Processes.js" ]; then
    echo "📄 Processes.js não encontrado, será criado"
else
    echo "✅ Processes.js encontrado, será atualizado"
fi

echo "2️⃣ Atualizando página principal de Processes..."

cat > src/pages/admin/Processes.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { processesService } from '../../services/processesService';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  ScaleIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  XCircleIcon,
  PauseIcon,
  RefreshIcon,
  UserIcon,
  BuildingLibraryIcon
} from '@heroicons/react/24/outline';

const Processes = () => {
  const [processes, setProcesses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [filterAdvogado, setFilterAdvogado] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState(null);

  // Estados para filtros
  const [advogados, setAdvogados] = useState([]);
  const [stats, setStats] = useState({
    total: 0,
    em_andamento: 0,
    vencidos: 0,
    vencendo: 0
  });

  // Carregar dados iniciais
  useEffect(() => {
    loadProcesses();
    loadStats();
  }, [currentPage, filterStatus, filterAdvogado, searchTerm]);

  const loadProcesses = async () => {
    try {
      setLoading(true);
      setError(null);

      const params = {
        page: currentPage,
        per_page: 15
      };

      // Aplicar filtros
      if (filterStatus && filterStatus !== 'all') {
        params.status = filterStatus;
      }
      if (filterAdvogado && filterAdvogado !== 'all') {
        params.advogado_id = filterAdvogado;
      }
      if (searchTerm.trim()) {
        params.busca = searchTerm.trim();
      }

      const response = await processesService.getProcesses(params);
      
      if (response.success) {
        setProcesses(response.data.data);
        setCurrentPage(response.data.current_page);
        setTotalPages(response.data.last_page);
        
        // Extrair lista de advogados única
        const uniqueAdvogados = [...new Map(
          response.data.data
            .filter(p => p.advogado)
            .map(p => [p.advogado_id, { id: p.advogado_id, name: p.advogado.name }])
        ).values()];
        
        setAdvogados(uniqueAdvogados);
      } else {
        setError('Erro ao carregar processos');
      }
    } catch (err) {
      console.error('Erro ao carregar processos:', err);
      setError('Erro de conexão. Verifique sua internet.');
    } finally {
      setLoading(false);
    }
  };

  const loadStats = async () => {
    try {
      const response = await processesService.getDashboard();
      if (response.success) {
        setStats(response.data);
      }
    } catch (err) {
      console.error('Erro ao carregar estatísticas:', err);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadProcesses();
    await loadStats();
    setRefreshing(false);
  };

  const handleDelete = async (processId) => {
    if (!window.confirm('Tem certeza que deseja excluir este processo?')) {
      return;
    }

    try {
      const response = await processesService.deleteProcess(processId);
      if (response.success) {
        alert('Processo excluído com sucesso!');
        loadProcesses();
        loadStats();
      } else {
        alert('Erro ao excluir processo');
      }
    } catch (error) {
      console.error('Erro ao excluir processo:', error);
      alert('Erro ao excluir processo');
    }
  };

  const syncWithCNJ = async (processId) => {
    try {
      setRefreshing(true);
      const response = await processesService.syncWithCNJ(processId);
      
      if (response.success) {
        alert(`Sincronização concluída! ${response.data.novas_movimentacoes} novas movimentações`);
        loadProcesses();
      } else {
        alert('Erro na sincronização CNJ');
      }
    } catch (error) {
      console.error('Erro na sincronização CNJ:', error);
      alert('Erro na sincronização CNJ');
    } finally {
      setRefreshing(false);
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'em_andamento': return CheckCircleIcon;
      case 'suspenso': return PauseIcon;
      case 'arquivado': return XCircleIcon;
      case 'finalizado': return CheckCircleIcon;
      default: return ClockIcon;
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'distribuido': return 'text-blue-600 bg-blue-100';
      case 'em_andamento': return 'text-green-600 bg-green-100';
      case 'suspenso': return 'text-yellow-600 bg-yellow-100';
      case 'arquivado': return 'text-gray-600 bg-gray-100';
      case 'finalizado': return 'text-purple-600 bg-purple-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'urgente': return 'text-red-600 bg-red-100';
      case 'alta': return 'text-orange-600 bg-orange-100';
      case 'media': return 'text-yellow-600 bg-yellow-100';
      case 'baixa': return 'text-green-600 bg-green-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const formatCurrency = (value) => {
    if (!value) return 'N/A';
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  if (loading && processes.length === 0) {
    return (
      <div className="space-y-8">
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-white rounded-xl p-6 animate-pulse">
              <div className="h-12 bg-gray-200 rounded mb-4"></div>
              <div className="h-6 bg-gray-200 rounded"></div>
            </div>
          ))}
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
              Gerencie os processos judiciais do escritório
            </p>
          </div>
          <div className="flex items-center space-x-4">
            <button
              onClick={handleRefresh}
              disabled={refreshing}
              className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors"
              title="Atualizar"
            >
              <RefreshIcon className={`w-5 h-5 ${refreshing ? 'animate-spin' : ''}`} />
            </button>
            <ScaleIcon className="w-12 h-12 text-primary-600" />
          </div>
        </div>
      </div>

      {/* Estatísticas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-900">{stats.total_processos || 0}</h3>
              <p className="text-sm text-gray-600">Total de Processos</p>
            </div>
            <ScaleIcon className="w-8 h-8 text-blue-600" />
          </div>
        </div>

        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-900">{stats.processos_ativos || 0}</h3>
              <p className="text-sm text-gray-600">Em Andamento</p>
            </div>
            <CheckCircleIcon className="w-8 h-8 text-green-600" />
          </div>
        </div>

        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-900">{stats.processos_vencendo || 0}</h3>
              <p className="text-sm text-gray-600">Vencendo</p>
            </div>
            <ClockIcon className="w-8 h-8 text-yellow-600" />
          </div>
        </div>

        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-900">{stats.processos_vencidos || 0}</h3>
              <p className="text-sm text-gray-600">Vencidos</p>
            </div>
            <ExclamationTriangleIcon className="w-8 h-8 text-red-600" />
          </div>
        </div>
      </div>

      {/* Filtros e Busca */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4">
          {/* Busca */}
          <div className="relative flex-1">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar por número, cliente ou tipo..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          
          {/* Filtro por Status */}
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os Status</option>
            <option value="distribuido">Distribuído</option>
            <option value="em_andamento">Em Andamento</option>
            <option value="suspenso">Suspenso</option>
            <option value="arquivado">Arquivado</option>
            <option value="finalizado">Finalizado</option>
          </select>

          {/* Filtro por Advogado */}
          <select
            value={filterAdvogado}
            onChange={(e) => setFilterAdvogado(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os Advogados</option>
            {advogados.map((advogado) => (
              <option key={advogado.id} value={advogado.id}>
                {advogado.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Error State */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-4">
          <div className="flex items-center">
            <ExclamationTriangleIcon className="w-5 h-5 text-red-600 mr-2" />
            <span className="text-red-800">{error}</span>
            <button
              onClick={handleRefresh}
              className="ml-4 text-red-600 hover:text-red-800 underline"
            >
              Tentar novamente
            </button>
          </div>
        </div>
      )}
EOF

echo "3️⃣ Script 116b concluído - Primeira parte!"
echo ""
echo "📋 O que foi implementado:"
echo "   • Integração real com processesService"
echo "   • Remoção de dados mockados"
echo "   • Estados de loading e erro"
echo "   • Filtros funcionais (status, advogado, busca)"
echo "   • Estatísticas do dashboard"
echo "   • Sincronização CNJ"
echo ""
echo "⭐ Próximo: Digite 'continuar' para completar a lista de processos"