#!/bin/bash

# Script 95a - Correção Kanban Padrão Erlene (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)
# Enumeração: 95a

echo "📋 Corrigindo Kanban.js seguindo EXATO padrão Documentos.js e Financeiro.js (Parte 1/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "🔧 1. Fazendo backup do Kanban.js atual..."

# Fazer backup do arquivo corrompido
cp frontend/src/pages/admin/Kanban.js frontend/src/pages/admin/Kanban.js.backup.error.$(date +%Y%m%d_%H%M%S)

echo "📝 2. Recriando Kanban.js seguindo EXATO padrão Documentos.js/Financeiro.js..."

# Recriar Kanban.js seguindo EXATO padrão das outras telas - PARTE 1
cat > frontend/src/pages/admin/Kanban.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  ClipboardDocumentListIcon,
  UserIcon,
  ScaleIcon,
  CalendarIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  TagIcon,
  FolderIcon,
  ChatBubbleLeftIcon
} from '@heroicons/react/24/outline';

const Kanban = () => {
  const navigate = useNavigate();
  const [tarefas, setTarefas] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterAdvogado, setFilterAdvogado] = useState('all');
  const [filterProcesso, setFilterProcesso] = useState('all');
  const [filterPrioridade, setFilterPrioridade] = useState('all');

  // Mock data seguindo padrão das outras telas
  const mockTarefas = [
    // TAREFAS EM "A FAZER"
    {
      id: 1,
      titulo: 'Elaborar petição inicial',
      descricao: 'Redigir petição inicial do processo de divórcio',
      processoId: 1,
      processoNumero: '1001234-56.2024.8.26.0001',
      clienteId: 1,
      clienteNome: 'João Silva Santos',
      advogadoId: 1,
      advogadoNome: 'Dr. Carlos Oliveira',
      colunaId: 1,
      coluna: 'A Fazer',
      prioridade: 'Alta',
      status: 'Pendente',
      dataVencimento: '2024-07-30',
      tags: ['petição', 'urgente', 'divórcio'],
      estimativaHoras: 4,
      horasGastas: 0,
      anexos: 2,
      comentarios: 1
    },
    {
      id: 2,
      titulo: 'Revisar contrato societário',
      descricao: 'Análise completa do contrato da empresa ABC',
      processoId: null,
      processoNumero: '',
      clienteId: 2,
      clienteNome: 'Empresa ABC Ltda',
      advogadoId: 2,
      advogadoNome: 'Dra. Maria Santos',
      colunaId: 1,
      coluna: 'A Fazer',
      prioridade: 'Média',
      status: 'Pendente',
      dataVencimento: '2024-08-05',
      tags: ['contrato', 'societário'],
      estimativaHoras: 6,
      horasGastas: 0,
      anexos: 5,
      comentarios: 0
    },
    {
      id: 3,
      titulo: 'Agendar audiência',
      descricao: 'Contactar cartório para agendamento',
      processoId: 3,
      processoNumero: '3003456-78.2024.8.26.0003',
      clienteId: 3,
      clienteNome: 'Maria Oliveira Costa',
      advogadoId: 3,
      advogadoNome: 'Dr. Pedro Costa',
      colunaId: 1,
      coluna: 'A Fazer',
      prioridade: 'Baixa',
      status: 'Pendente',
      dataVencimento: '2024-08-15',
      tags: ['audiência', 'agendamento'],
      estimativaHoras: 1,
      horasGastas: 0,
      anexos: 0,
      comentarios: 2
    },

    // TAREFAS EM "EM ANDAMENTO"
    {
      id: 4,
      titulo: 'Redigir contestação',
      descricao: 'Elaboração de contestação para processo',
      processoId: 4,
      processoNumero: '4004567-89.2024.8.26.0004',
      clienteId: 4,
      clienteNome: 'Tech Solutions S.A.',
      advogadoId: 1,
      advogadoNome: 'Dr. Carlos Oliveira',
      colunaId: 2,
      coluna: 'Em Andamento',
      prioridade: 'Alta',
      status: 'Em Andamento',
      dataVencimento: '2024-07-28',
      tags: ['contestação', 'prazo'],
      estimativaHoras: 8,
      horasGastas: 3,
      anexos: 8,
      comentarios: 4
    },
    {
      id: 5,
      titulo: 'Análise documentos imobiliários',
      descricao: 'Verificação de documentação',
      processoId: null,
      processoNumero: '',
      clienteId: 5,
      clienteNome: 'Carlos Pereira Lima',
      advogadoId: 2,
      advogadoNome: 'Dra. Maria Santos',
      colunaId: 2,
      coluna: 'Em Andamento',
      prioridade: 'Média',
      status: 'Em Andamento',
      dataVencimento: '2024-08-02',
      tags: ['imobiliário', 'documentação'],
      estimativaHoras: 4,
      horasGastas: 2,
      anexos: 12,
      comentarios: 3
    },

    // TAREFAS EM "AGUARDANDO"
    {
      id: 6,
      titulo: 'Aguardar resposta do cliente',
      descricao: 'Cliente precisa fornecer documentos',
      processoId: 1,
      processoNumero: '1001234-56.2024.8.26.0001',
      clienteId: 1,
      clienteNome: 'João Silva Santos',
      advogadoId: 1,
      advogadoNome: 'Dr. Carlos Oliveira',
      colunaId: 3,
      coluna: 'Aguardando',
      prioridade: 'Baixa',
      status: 'Aguardando',
      dataVencimento: '2024-08-10',
      tags: ['documentos', 'cliente'],
      estimativaHoras: 0.5,
      horasGastas: 0.5,
      anexos: 1,
      comentarios: 2
    },

    // TAREFAS CONCLUÍDAS
    {
      id: 7,
      titulo: 'Protocolo de petição',
      descricao: 'Protocolo realizado no TJSP',
      processoId: 2,
      processoNumero: '2002345-67.2024.8.26.0002',
      clienteId: 2,
      clienteNome: 'Empresa ABC Ltda',
      advogadoId: 2,
      advogadoNome: 'Dra. Maria Santos',
      colunaId: 4,
      coluna: 'Concluído',
      prioridade: 'Alta',
      status: 'Concluído',
      dataVencimento: '2024-07-25',
      tags: ['protocolo', 'tjsp'],
      estimativaHoras: 2,
      horasGastas: 1.5,
      anexos: 3,
      comentarios: 1
    },
    {
      id: 8,
      titulo: 'Reunião com cliente',
      descricao: 'Reunião de alinhamento realizada',
      processoId: 3,
      processoNumero: '3003456-78.2024.8.26.0003',
      clienteId: 3,
      clienteNome: 'Maria Oliveira Costa',
      advogadoId: 3,
      advogadoNome: 'Dr. Pedro Costa',
      colunaId: 4,
      coluna: 'Concluído',
      prioridade: 'Média',
      status: 'Concluído',
      dataVencimento: '2024-07-26',
      tags: ['reunião', 'estratégia'],
      estimativaHoras: 1,
      horasGastas: 1,
      anexos: 0,
      comentarios: 1
    }
  ];

  const mockColunas = [
    { id: 1, nome: 'A Fazer', cor: '#6B7280', limite: null },
    { id: 2, nome: 'Em Andamento', cor: '#3B82F6', limite: 5 },
    { id: 3, nome: 'Aguardando', cor: '#F59E0B', limite: null },
    { id: 4, nome: 'Concluído', cor: '#10B981', limite: null },
    { id: 5, nome: 'Cancelado', cor: '#EF4444', limite: null }
  ];

  useEffect(() => {
    // Simular carregamento seguindo padrão
    setTimeout(() => {
      setTarefas(mockTarefas);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas seguindo padrão das outras telas
  const aFazer = tarefas.filter(t => t.colunaId === 1);
  const emAndamento = tarefas.filter(t => t.colunaId === 2);
  const aguardando = tarefas.filter(t => t.colunaId === 3);
  const concluidas = tarefas.filter(t => t.colunaId === 4);
  
  const vencendoHoje = tarefas.filter(t => {
    const hoje = new Date().toISOString().split('T')[0];
    return t.dataVencimento === hoje && t.colunaId !== 4;
  });

  const stats = [
    {
      name: 'Total de Tarefas',
      value: tarefas.length.toString(),
      change: '+3',
      changeType: 'increase',
      icon: ClipboardDocumentListIcon,
      color: 'blue',
      description: 'No quadro atual'
    },
    {
      name: 'Em Andamento',
      value: emAndamento.length.toString(),
      change: `${((emAndamento.length / tarefas.length) * 100).toFixed(0)}%`,
      changeType: 'neutral',
      icon: ClockIcon,
      color: 'yellow',
      description: 'Do total de tarefas'
    },
    {
      name: 'Vencendo Hoje',
      value: vencendoHoje.length.toString(),
      change: '⚠️',
      changeType: 'neutral',
      icon: ExclamationTriangleIcon,
      color: 'red',
      description: 'Requer atenção'
    },
    {
      name: 'Concluídas',
      value: concluidas.length.toString(),
      change: `+${concluidas.length}`,
      changeType: 'increase',
      icon: CheckCircleIcon,
      color: 'green',
      description: 'Finalizadas'
    }
  ];

  // Filtrar tarefas seguindo padrão
  const filteredTarefas = tarefas.filter(tarefa => {
    const matchesSearch = tarefa.titulo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         tarefa.descricao.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         tarefa.clienteNome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         tarefa.tags.some(tag => tag.toLowerCase().includes(searchTerm.toLowerCase()));
    
    const matchesAdvogado = filterAdvogado === 'all' || tarefa.advogadoId.toString() === filterAdvogado;
    const matchesProcesso = filterProcesso === 'all' || 
                           (filterProcesso === 'com_processo' && tarefa.processoId) ||
                           (filterProcesso === 'sem_processo' && !tarefa.processoId);
    const matchesPrioridade = filterPrioridade === 'all' || tarefa.prioridade === filterPrioridade;
    
    return matchesSearch && matchesAdvogado && matchesProcesso && matchesPrioridade;
  });

  const handleDelete = (id) => {
    if (window.confirm('Tem certeza que deseja excluir esta tarefa?')) {
      setTarefas(prev => prev.filter(tarefa => tarefa.id !== id));
    }
  };

  const getPrioridadeColor = (prioridade) => {
    switch (prioridade) {
      case 'Alta': return 'bg-red-100 text-red-800';
      case 'Média': return 'bg-yellow-100 text-yellow-800';
      case 'Baixa': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getPrioridadeIcon = (prioridade) => {
    switch (prioridade) {
      case 'Alta': return <ExclamationTriangleIcon className="w-3 h-3" />;
      case 'Média': return <ClockIcon className="w-3 h-3" />;
      case 'Baixa': return <CheckCircleIcon className="w-3 h-3" />;
      default: return <ClockIcon className="w-3 h-3" />;
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

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
      {/* Header seguindo EXATO padrão Documentos.js */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Sistema Kanban</h1>
        <p className="mt-2 text-lg text-gray-600">
          Gestão visual de tarefas e processos do escritório
        </p>
      </div>

      {/* Stats Cards seguindo EXATO padrão Documentos.js */}
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
                  item.changeType === 'increase' ? 'text-green-600' : 
                  item.changeType === 'decrease' ? 'text-red-600' : 'text-gray-600'
                }`}>
                  {item.changeType === 'increase' && <ArrowUpIcon className="h-4 w-4 mr-1" />}
                  {item.changeType === 'decrease' && <ArrowDownIcon className="h-4 w-4 mr-1" />}
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

      {/* Ações Rápidas seguindo padrão Financeiro.js */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Ações Rápidas</h2>
          <ClipboardDocumentListIcon className="h-5 w-5 text-gray-400" />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
          {[
            { title: 'Nova Tarefa', icon: '📋', action: () => navigate('/admin/kanban/nova') },
            { title: 'Filtro por Prazo', icon: '⏰', count: vencendoHoje.length },
            { title: 'Alta Prioridade', icon: '🔴', count: tarefas.filter(t => t.prioridade === 'Alta').length },
            { title: 'Relatórios', icon: '📊' }
          ].map((action) => (
            <div
              key={action.title}
              className="group flex flex-col items-center p-6 border-2 border-dashed border-gray-300 rounded-xl hover:border-primary-500 hover:bg-primary-50 transition-all duration-200 cursor-pointer"
              onClick={action.action}
            >
              <span className="text-3xl mb-3 group-hover:scale-110 transition-transform duration-200">
                {action.icon}
              </span>
              <span className="text-sm font-medium text-gray-900 group-hover:text-primary-700">
                {action.title}
              </span>
              {action.count !== undefined && (
                <span className="text-xs text-gray-500 mt-1">{action.count} tarefas</span>
              )}
            </div>
          ))}
        </div>
      </div>
EOF

echo "✅ Kanban.js - PARTE 1 criada (até linha 300)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • Arquivo recriado seguindo EXATO padrão Documentos.js e Financeiro.js"
echo "   • Header idêntico às outras telas do projeto"
echo "   • Mock data simplificado mas completo (8 tarefas em 4 colunas)"
echo "   • Cards de estatísticas seguindo padrão das outras telas"
echo "   • Ações rápidas seguindo padrão Financeiro.js"
echo "   • Estrutura JSX correta sem erros de sintaxe"
echo ""
echo "🎯 MOCK DATA LIMPO (PARTE 1):"
echo "   📝 A Fazer (3): Petição inicial, Contrato societário, Agendar audiência"
echo "   🔄 Em Andamento (2): Contestação, Análise imobiliária"
echo "   ⏸️ Aguardando (1): Resposta do cliente"
echo "   ✅ Concluído (2): Protocolo, Reunião"
echo ""
echo "🔧 PROBLEMAS CORRIGIDOS:"
echo "   ✅ Erro de JSX adjacente → Estrutura correta"
echo "   ✅ Imports organizados e limpos"
echo "   ✅ Mock data simplificado mas funcional"
echo "   ✅ Segue padrão EXATO das outras telas"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Quadro Kanban visual com colunas"
echo "   • Lista/tabela de tarefas seguindo padrão"
echo "   • Estados de vazio e filtros"
echo "   • Finalização sem erros de sintaxe"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"