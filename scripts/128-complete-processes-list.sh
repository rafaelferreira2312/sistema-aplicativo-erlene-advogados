#!/bin/bash

# Script 128 - Completar Lista de Processos
# Sistema Erlene Advogados - Adicionar ícones de ação e corrigir dados reais
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 128 - Completando lista de processos com ícones de ação..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 128-complete-processes-list.sh && ./128-complete-processes-list.sh"
    exit 1
fi

echo "1️⃣ DIAGNÓSTICO DO PROBLEMA:"
echo "   • Lista de processos carrega dados da API ✅"  
echo "   • Dashboard com estatísticas funcionais ✅"
echo "   • Faltam ícones de ação na coluna Ações ❌"
echo "   • UserIcon (verde): link para /admin/clientes/cliente_id"
echo "   • FolderIcon (azul): modal para documentos do processo"

echo ""
echo "2️⃣ Fazendo backup do arquivo atual..."

# Backup do Processes.js atual
if [ -f "src/pages/admin/Processes.js" ]; then
    cp src/pages/admin/Processes.js src/pages/admin/Processes.js.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup criado: Processes.js.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo ""
echo "3️⃣ Atualizando Processes.js com ícones de ação..."

cat > src/pages/admin/Processes.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { processesService } from '../../services/processesService';
import {
  MagnifyingGlassIcon,
  PlusIcon,
  EyeIcon,
  PencilIcon,
  EllipsisVerticalIcon,
  ClockIcon,
  ScaleIcon,
  UserIcon,
  FolderIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon,
  FunnelIcon
} from '@heroicons/react/24/outline';

const Processes = () => {
  const [processes, setProcesses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [advogadoFilter, setAdvogadoFilter] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalProcessos, setTotalProcessos] = useState(0);

  // Stats para o dashboard
  const [stats, setStats] = useState({
    total: 0,
    em_andamento: 0,
    aguardando: 0,
    valor_total: 0
  });

  const loadProcesses = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const params = {
        page: currentPage,
        per_page: 15,
        ...(search && { search }),
        ...(statusFilter && { status: statusFilter }),
        ...(advogadoFilter && { advogado_id: advogadoFilter })
      };

      console.log('🔄 Carregando processos com params:', params);
      const response = await processesService.getProcesses(params);
      
      if (response && response.success) {
        // Garantir que sempre seja array
        const dataArray = Array.isArray(response.data) ? response.data : [];
        setProcesses(dataArray);
        setTotalProcessos(dataArray.length);
        
        // Calcular estatísticas
        const newStats = {
          total: dataArray.length,
          em_andamento: dataArray.filter(p => p.status === 'em_andamento').length,
          aguardando: dataArray.filter(p => p.status === 'distribuido' || p.status === 'suspenso').length,
          valor_total: dataArray.reduce((sum, p) => sum + (parseFloat(p.valor_causa) || 0), 0)
        };
        setStats(newStats);
        
        // Paginação
        if (response.meta) {
          setTotalPages(response.meta.last_page || 1);
        }
        
        console.log('✅ Processos carregados:', dataArray.length);
      } else {
        throw new Error(response?.message || 'Erro ao carregar processos');
      }
    } catch (err) {
      console.error('💥 Erro ao carregar processos:', err);
      setError('Erro ao carregar processos. Verifique sua conexão.');
      setProcesses([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProcesses();
  }, [currentPage, search, statusFilter, advogadoFilter]);

  const handleSearch = (e) => {
    setSearch(e.target.value);
    setCurrentPage(1);
  };

  const handleStatusFilter = (status) => {
    setStatusFilter(status);
    setCurrentPage(1);
  };

  const handleAdvogadoFilter = (advogadoId) => {
    setAdvogadoFilter(advogadoId);
    setCurrentPage(1);
  };

  // Função segura para extrair nome do cliente
  const getClientName = (processo) => {
    if (!processo) return 'Cliente não informado';
    
    if (processo.cliente && typeof processo.cliente === 'object' && processo.cliente.nome) {
      return processo.cliente.nome;
    }
    
    return 'Cliente não informado';
  };

  // Função segura para extrair nome do advogado  
  const getAdvogadoName = (processo) => {
    if (!processo) return 'Não atribuído';
    
    if (processo.advogado && typeof processo.advogado === 'object' && processo.advogado.name) {
      return processo.advogado.name;
    }
    
    return 'Não atribuído';
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'em_andamento':
        return 'text-blue-600 bg-blue-100';
      case 'distribuido':
        return 'text-purple-600 bg-purple-100';
      case 'suspenso':
        return 'text-yellow-600 bg-yellow-100';
      case 'finalizado':
        return 'text-green-600 bg-green-100';
      case 'arquivado':
        return 'text-red-600 bg-red-100';
      default:
        return 'text-gray-600 bg-gray-100';
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'em_andamento': return 'Em Andamento';
      case 'distribuido': return 'Distribuído';
      case 'suspenso': return 'Suspenso';
      case 'finalizado': return 'Finalizado';
      case 'arquivado': return 'Arquivado';
      default: return status || 'Status não informado';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'urgente':
        return 'text-red-600 bg-red-100';
      case 'alta':
        return 'text-orange-600 bg-orange-100';
      case 'media':
        return 'text-yellow-600 bg-yellow-100';
      case 'baixa':
        return 'text-green-600 bg-green-100';
      default:
        return 'text-gray-600 bg-gray-100';
    }
  };

  const getPriorityText = (priority) => {
    switch (priority) {
      case 'urgente': return 'Urgente';
      case 'alta': return 'Alta';
      case 'media': return 'Média';
      case 'baixa': return 'Baixa';
      default: return priority || 'Média';
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
      const numValue = typeof value === 'string' ? parseFloat(value) : value;
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
      }).format(numValue);
    } catch (e) {
      return 'R$ 0,00';
    }
  };

  // Garantir que processes é sempre array
  const safeProcesses = Array.isArray(processes) ? processes : [];

  if (loading) {
    return (
      <div className="space-y-8">
        {/* Header Loading */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          </div>
        </div>
        
        {/* Stats Loading */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6 animate-pulse">
              <div className="h-16 bg-gray-200 rounded mb-4"></div>
              <div className="h-4 bg-gray-200 rounded w-1/2"></div>
            </div>
          ))}
        </div>
        
        {/* Table Loading */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="animate-pulse space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="h-16 bg-gray-200 rounded"></div>
              ))}
            </div>
          </div>
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
              Gerencie todos os processos do escritório
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
EOF

echo "4️⃣ Verificando se arquivo foi atualizado..."

if [ -f "src/pages/admin/Processes.js" ]; then
    echo "✅ Processes.js atualizado - primeira parte"
    echo "📊 Linhas do arquivo: $(wc -l < src/pages/admin/Processes.js)"
else
    echo "❌ Erro ao atualizar Processes.js"
    exit 1
fi

echo ""
echo "✅ SCRIPT 128 - PRIMEIRA PARTE CONCLUÍDA!"
echo ""
echo "🔄 O que foi implementado:"
echo "   • Backup do arquivo original criado"
echo "   • Header e estrutura base do componente"
echo "   • Integração com processesService (dados reais)"
echo "   • Funções de formatação seguras"
echo "   • Estados de loading e error"
echo "   • Filtros básicos implementados"
echo ""
echo "⏳ AGUARDANDO CONFIRMAÇÃO:"
echo "Digite 'continuar' para implementar:"
echo "   • Dashboard com estatísticas"
echo "   • Tabela com ícones de ação"
echo "   • Paginação completa"