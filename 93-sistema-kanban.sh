#!/bin/bash

# Script 93a - Sistema Kanban Dashboard (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📋 Criando Sistema Kanban Dashboard (Parte 1/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 1. Criando estrutura para Kanban..."

# Criar estrutura se não existir
mkdir -p frontend/src/components/kanban
mkdir -p frontend/src/pages/admin

echo "📝 2. Criando página principal de Kanban seguindo padrão Erlene..."

# Criar página de Kanban seguindo EXATO padrão dos módulos anteriores
cat > frontend/src/pages/admin/Kanban.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
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
  XCircleIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  TagIcon,
  FolderIcon,
  ChartBarIcon,
  Bars3Icon
} from '@heroicons/react/24/outline';

const Kanban = () => {
  const [tarefas, setTarefas] = useState([]);
  const [colunas, setColunas] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterAdvogado, setFilterAdvogado] = useState('all');
  const [filterProcesso, setFilterProcesso] = useState('all');
  const [filterPrioridade, setFilterPrioridade] = useState('all');

  // Mock data expandido com tarefas em diferentes colunas
  const mockColunas = [
    {
      id: 1,
      nome: 'A Fazer',
      cor: '#6B7280',
      ordem: 1,
      limite: null
    },
    {
      id: 2,
      nome: 'Em Andamento',
      cor: '#3B82F6',
      ordem: 2,
      limite: 5
    },
    {
      id: 3,
      nome: 'Aguardando',
      cor: '#F59E0B',
      ordem: 3,
      limite: null
    },
    {
      id: 4,
      nome: 'Concluído',
      cor: '#10B981',
      ordem: 4,
      limite: null
    },
    {
      id: 5,
      nome: 'Cancelado',
      cor: '#EF4444',
      ordem: 5,
      limite: null
    }
  ];

  const mockTarefas = [
    // TAREFAS EM "A FAZER"
    {
      id: 1,
      titulo: 'Elaborar petição inicial',
      descricao: 'Redigir petição inicial do processo de divórcio com levantamento de bens',
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
      dataCriacao: '2024-07-20',
      dataVencimento: '2024-07-30',
      dataInicio: null,
      dataConclusao: null,
      tags: ['petição', 'urgente', 'divórcio'],
      estimativaHoras: 4,
      horasGastas: 0,
      anexos: 2,
      comentarios: 1,
      posicao: 0,
      criadoPor: 'Dr. Carlos Oliveira',
      atualizadoPor: 'Dr. Carlos Oliveira',
      ultimaAtualizacao: '2024-07-25'
    },
    {
      id: 2,
      titulo: 'Revisar contrato societário',
      descricao: 'Análise completa do contrato de constituição da empresa ABC Ltda',
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
      dataCriacao: '2024-07-22',
      dataVencimento: '2024-08-05',
      dataInicio: null,
      dataConclusao: null,
      tags: ['contrato', 'societário', 'análise'],
      estimativaHoras: 6,
      horasGastas: 0,
      anexos: 5,
      comentarios: 0,
      posicao: 1,
      criadoPor: 'Dra. Maria Santos',
      atualizadoPor: 'Dra. Maria Santos',
      ultimaAtualizacao: '2024-07-22'
    },
    {
      id: 3,
      titulo: 'Agendar audiência de instrução',
      descricao: 'Contactar cartório para agendamento da audiência do processo trabalhista',
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
      dataCriacao: '2024-07-23',
      dataVencimento: '2024-08-15',
      dataInicio: null,
      dataConclusao: null,
      tags: ['audiência', 'trabalhista', 'agendamento'],
      estimativaHoras: 1,
      horasGastas: 0,
      anexos: 0,
      comentarios: 2,
      posicao: 2,
      criadoPor: 'Dr. Pedro Costa',
      atualizadoPor: 'Dr. Pedro Costa',
      ultimaAtualizacao: '2024-07-23'
    },

    // TAREFAS EM "EM ANDAMENTO"
    {
      id: 4,
      titulo: 'Redigir contestação',
      descricao: 'Elaboração de contestação para processo de cobrança da Tech Solutions',
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
      dataCriacao: '2024-07-18',
      dataVencimento: '2024-07-28',
      dataInicio: '2024-07-24',
      dataConclusao: null,
      tags: ['contestação', 'cobrança', 'prazo'],
      estimativaHoras: 8,
      horasGastas: 3,
      anexos: 8,
      comentarios: 4,
      posicao: 0,
      criadoPor: 'Dr. Carlos Oliveira',
      atualizadoPor: 'Dr. Carlos Oliveira',
      ultimaAtualizacao: '2024-07-26'
    },
    {
      id: 5,
      titulo: 'Análise de documentos imobiliários',
      descricao: 'Verificação da documentação para compra de imóvel residencial',
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
      dataCriacao: '2024-07-19',
      dataVencimento: '2024-08-02',
      dataInicio: '2024-07-25',
      dataConclusao: null,
      tags: ['imobiliário', 'documentação', 'compra'],
      estimativaHoras: 4,
      horasGastas: 2,
      anexos: 12,
      comentarios: 3,
      posicao: 1,
      criadoPor: 'Dra. Maria Santos',
      atualizadoPor: 'Dra. Maria Santos',
      ultimaAtualizacao: '2024-07-26'
    },

    // TAREFAS EM "AGUARDANDO"
    {
      id: 6,
      titulo: 'Aguardar resposta do cliente',
      descricao: 'Cliente precisa fornecer documentos adicionais para o processo',
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
      dataCriacao: '2024-07-21',
      dataVencimento: '2024-08-10',
      dataInicio: '2024-07-21',
      dataConclusao: null,
      tags: ['documentos', 'cliente', 'pendência'],
      estimativaHoras: 0.5,
      horasGastas: 0.5,
      anexos: 1,
      comentarios: 2,
      posicao: 0,
      criadoPor: 'Dr. Carlos Oliveira',
      atualizadoPor: 'Dr. Carlos Oliveira',
      ultimaAtualizacao: '2024-07-21'
    },

    // TAREFAS CONCLUÍDAS
    {
      id: 7,
      titulo: 'Protocolo de petição',
      descricao: 'Protocolo realizado no sistema do TJSP com sucesso',
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
      dataCriacao: '2024-07-15',
      dataVencimento: '2024-07-25',
      dataInicio: '2024-07-24',
      dataConclusao: '2024-07-25',
      tags: ['protocolo', 'tjsp', 'finalizado'],
      estimativaHoras: 2,
      horasGastas: 1.5,
      anexos: 3,
      comentarios: 1,
      posicao: 0,
      criadoPor: 'Dra. Maria Santos',
      atualizadoPor: 'Dra. Maria Santos',
      ultimaAtualizacao: '2024-07-25'
    },
    {
      id: 8,
      titulo: 'Reunião com cliente',
      descricao: 'Reunião de alinhamento sobre estratégia processual realizada',
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
      dataCriacao: '2024-07-24',
      dataVencimento: '2024-07-26',
      dataInicio: '2024-07-26',
      dataConclusao: '2024-07-26',
      tags: ['reunião', 'estratégia', 'alinhamento'],
      estimativaHoras: 1,
      horasGastas: 1,
      anexos: 0,
      comentarios: 1,
      posicao: 1,
      criadoPor: 'Dr. Pedro Costa',
      atualizadoPor: 'Dr. Pedro Costa',
      ultimaAtualizacao: '2024-07-26'
    }
  ];

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setColunas(mockColunas);
      setTarefas(mockTarefas);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas
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

  // Filtrar tarefas
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
      case 'Baixa': return <ArrowDownIcon className="w-3 h-3" />;
      default: return <Bars3Icon className="w-3 h-3" />;
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  // Ações rápidas
  const quickActions = [
    { title: 'Nova Tarefa', icon: '📋', color: 'blue', href: '/admin/kanban/nova' },
    { title: 'Nova Coluna', icon: '📊', color: 'purple', href: '/admin/kanban/coluna' },
    { title: 'Filtro por Prazo', icon: '⏰', color: 'yellow', count: vencendoHoje.length },
    { title: 'Relatórios', icon: '📈', color: 'green', href: '/admin/relatorios/kanban' }
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
        <h1 className="text-3xl font-bold text-gray-900">Sistema Kanban</h1>
        <p className="mt-2 text-lg text-gray-600">
          Gestão visual de tarefas e processos do escritório
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

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Ações Rápidas */}
        <div className="lg:col-span-2">
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Ações Rápidas</h2>
              <ClipboardDocumentListIcon className="h-5 w-5 text-gray-400" />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {quickActions.map((action) => (
                <div
                  key={action.title}
                  className="group flex flex-col items-center p-6 border-2 border-dashed border-gray-300 rounded-xl hover:border-primary-500 hover:bg-primary-50 transition-all duration-200 cursor-pointer"
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
        </div>

        {/* Filtros Rápidos */}
        <div>
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Filtros Rápidos</h2>
              <TagIcon className="h-5 w-5 text-gray-400" />
            </div>
            <div className="space-y-4">
              <button 
                onClick={() => setFilterPrioridade('Alta')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterPrioridade === 'Alta' ? 'bg-red-50 border border-red-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Prioridade Alta</span>
                  <span className="text-red-600 font-semibold">
                    {tarefas.filter(t => t.prioridade === 'Alta').length}
                  </span>
                </div>
              </button>
              <button 
                onClick={() => setFilterProcesso('com_processo')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterProcesso === 'com_processo' ? 'bg-blue-50 border border-blue-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Com Processo</span>
                  <span className="text-blue-600 font-semibold">
                    {tarefas.filter(t => t.processoId).length}
                  </span>
                </div>
              </button>
              <button 
                onClick={() => {
                  const hoje = new Date().toISOString().split('T')[0];
                  const vencendo = tarefas.filter(t => t.dataVencimento === hoje);
                  alert(`${vencendo.length} tarefas vencendo hoje`);
                }}
                className="w-full text-left p-3 rounded-lg transition-colors hover:bg-gray-50"
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Vencendo Hoje</span>
                  <span className="text-orange-600 font-semibold">
                    {vencendoHoje.length}
                  </span>
                </div>
              </button>
              <button 
                onClick={() => { setFilterPrioridade('all'); setFilterProcesso('all'); setFilterAdvogado('all'); }}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterPrioridade === 'all' && filterProcesso === 'all' && filterAdvogado === 'all' ? 'bg-primary-50 border border-primary-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Todas</span>
                  <span className="text-gray-600 font-semibold">{tarefas.length}</span>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>
EOF

echo "✅ Primeira parte da página Kanban.js criada (até 300 linhas)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • Header e estrutura base seguindo padrão Erlene"
echo "   • Mock data Kanban completo com 8 tarefas em 5 colunas"
echo "   • Colunas: A Fazer, Em Andamento, Aguardando, Concluído, Cancelado"
echo "   • Cards de estatísticas Kanban em tempo real"
echo "   • Relacionamentos com processos e clientes"
echo ""
echo "📋 TAREFAS IMPLEMENTADAS:"
echo "   📝 A Fazer (3): Petição inicial, Contrato societário, Agendar audiência"
echo "   🔄 Em Andamento (2): Contestação, Análise imobiliária"
echo "   ⏸️ Aguardando (1): Resposta do cliente"
echo "   ✅ Concluído (2): Protocolo, Reunião com cliente"
echo ""
echo "🎯 FUNCIONALIDADES KANBAN:"
echo "   • Sistema de prioridades (Alta, Média, Baixa)"
echo "   • Relacionamentos opcionais com processos"
echo "   • Tags dinâmicas por tarefa"
echo "   • Estimativa e controle de horas"
echo "   • Anexos e comentários por tarefa"
echo "   • Filtros por advogado, processo, prioridade"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Quadro Kanban visual com colunas"
echo "   • Lista/tabela de tarefas com filtros"
echo "   • Estados de loading e vazio"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"