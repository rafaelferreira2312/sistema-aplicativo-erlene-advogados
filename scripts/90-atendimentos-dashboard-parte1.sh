#!/bin/bash

# Script 90 - Atendimentos Dashboard e Lista (Parte 1/3)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "👥 Criando módulo completo de Atendimentos (Parte 1/3)..."

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

echo "📁 1. Criando estrutura para atendimentos..."

# Criar estrutura se não existir
mkdir -p frontend/src/components/atendimentos
mkdir -p frontend/src/pages/admin

echo "📝 2. Criando página principal de Atendimentos..."

# Criar página de Atendimentos seguindo EXATO padrão Prazos.js e Audiencias.js
cat > frontend/src/pages/admin/Atendimentos.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  CalendarIcon,
  ClockIcon,
  UserIcon,
  PhoneIcon,
  VideoCameraIcon,
  HomeIcon,
  CheckCircleIcon,
  XCircleIcon,
  ArrowUpIcon,
  ArrowDownIcon
} from '@heroicons/react/24/outline';

const Atendimentos = () => {
  const [atendimentos, setAtendimentos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [filterTipo, setFilterTipo] = useState('all');
  const [filterAdvogado, setFilterAdvogado] = useState('all');
  const [filterData, setFilterData] = useState('todos');

  // Mock data seguindo padrão do projeto
  const mockAtendimentos = [
    {
      id: 1,
      cliente: 'João Silva Santos',
      clienteId: 1,
      tipo: 'Presencial',
      data: '2024-07-25', // Hoje
      hora: '09:00',
      advogado: 'Dr. Carlos Oliveira',
      assunto: 'Consulta sobre divórcio consensual',
      status: 'Agendado',
      observacoes: 'Cliente quer saber sobre documentação necessária',
      duracao: '60 minutos',
      processos: ['1001234-56.2024.8.26.0001'],
      createdAt: '2024-07-20'
    },
    {
      id: 2,
      cliente: 'Empresa ABC Ltda',
      clienteId: 2,
      tipo: 'Online',
      data: '2024-07-25', // Hoje
      hora: '14:30',
      advogado: 'Dra. Maria Santos',
      assunto: 'Revisão de contrato empresarial',
      status: 'Confirmado',
      observacoes: 'Reunião via Teams, revisar cláusulas específicas',
      duracao: '90 minutos',
      processos: ['2002345-67.2024.8.26.0002'],
      createdAt: '2024-07-18'
    },
    {
      id: 3,
      cliente: 'Maria Oliveira Costa',
      clienteId: 3,
      tipo: 'Telefone',
      data: '2024-07-25', // Hoje
      hora: '16:00',
      advogado: 'Dr. Pedro Costa',
      assunto: 'Acompanhamento de processo trabalhista',
      status: 'Realizado',
      observacoes: 'Cliente informada sobre andamento do processo',
      duracao: '30 minutos',
      processos: ['3003456-78.2024.8.26.0003'],
      createdAt: '2024-07-15'
    },
    {
      id: 4,
      cliente: 'Tech Solutions S.A.',
      clienteId: 4,
      tipo: 'Presencial',
      data: '2024-07-26', // Amanhã
      hora: '10:00',
      advogado: 'Dra. Ana Silva',
      assunto: 'Assessoria jurídica para fusão',
      status: 'Agendado',
      observacoes: 'Reunião estratégica com diretoria',
      duracao: '120 minutos',
      processos: [],
      createdAt: '2024-07-10'
    },
    {
      id: 5,
      cliente: 'Carlos Pereira Lima',
      clienteId: 5,
      tipo: 'Online',
      data: '2024-07-24', // Ontem
      hora: '15:00',
      advogado: 'Dra. Erlene Chaves Silva',
      assunto: 'Consulta sobre inventário',
      status: 'Realizado',
      observacoes: 'Cliente orientado sobre próximos passos',
      duracao: '45 minutos',
      processos: ['5005678-90.2024.8.26.0005'],
      createdAt: '2024-07-12'
    },
    {
      id: 6,
      cliente: 'Startup Inovação Ltda',
      clienteId: 6,
      tipo: 'Presencial',
      data: '2024-07-27',
      hora: '11:00',
      advogado: 'Dr. Carlos Oliveira',
      assunto: 'Registro de marca e propriedade intelectual',
      status: 'Agendado',
      observacoes: 'Primeira reunião com cliente novo',
      duracao: '60 minutos',
      processos: [],
      createdAt: '2024-07-22'
    }
  ];

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setAtendimentos(mockAtendimentos);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas
  const hoje = new Date().toISOString().split('T')[0];
  const ontem = new Date();
  ontem.setDate(ontem.getDate() - 1);
  const ontemStr = ontem.toISOString().split('T')[0];
  
  const amanha = new Date();
  amanha.setDate(amanha.getDate() + 1);
  const amanhaStr = amanha.toISOString().split('T')[0];

  const stats = [
    {
      name: 'Atendimentos Hoje',
      value: atendimentos.filter(a => a.data === hoje).length.toString(),
      change: '+2',
      changeType: 'increase',
      icon: CalendarIcon,
      color: 'green',
      description: 'Agendados para hoje'
    },
    {
      name: 'Próximas 2h',
      value: atendimentos.filter(a => {
        if (a.data !== hoje) return false;
        const now = new Date();
        const atendimentoTime = new Date(`${a.data}T${a.hora}`);
        const diff = atendimentoTime.getTime() - now.getTime();
        return diff > 0 && diff <= 2 * 60 * 60 * 1000;
      }).length.toString(),
      change: '0',
      changeType: 'neutral',
      icon: ClockIcon,
      color: 'yellow',
      description: 'Próximos atendimentos'
    },
    {
      name: 'Realizados Ontem',
      value: atendimentos.filter(a => a.data === ontemStr && a.status === 'Realizado').length.toString(),
      change: '+1',
      changeType: 'increase',
      icon: CheckCircleIcon,
      color: 'blue',
      description: 'Concluídos ontem'
    },
    {
      name: 'Total do Mês',
      value: atendimentos.length.toString(),
      change: '+18%',
      changeType: 'increase',
      icon: UserIcon,
      color: 'purple',
      description: 'Atendimentos este mês'
    }
  ];

  // Filtrar atendimentos
  const filteredAtendimentos = atendimentos.filter(atendimento => {
    const matchesSearch = atendimento.cliente.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         atendimento.assunto.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         atendimento.advogado.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = filterStatus === 'all' || atendimento.status === filterStatus;
    const matchesTipo = filterTipo === 'all' || atendimento.tipo === filterTipo;
    const matchesAdvogado = filterAdvogado === 'all' || atendimento.advogado === filterAdvogado;
    
    // Filtro por data
    let matchesData = true;
    if (filterData === 'hoje') {
      matchesData = atendimento.data === hoje;
    } else if (filterData === 'amanha') {
      matchesData = atendimento.data === amanhaStr;
    } else if (filterData === 'semana') {
      const dataAtendimento = new Date(atendimento.data);
      const inicioSemana = new Date();
      const fimSemana = new Date();
      fimSemana.setDate(inicioSemana.getDate() + 7);
      matchesData = dataAtendimento >= inicioSemana && dataAtendimento <= fimSemana;
    }
    
    return matchesSearch && matchesStatus && matchesTipo && matchesAdvogado && matchesData;
  });

  const handleDelete = (id) => {
    if (window.confirm('Tem certeza que deseja excluir este atendimento?')) {
      setAtendimentos(prev => prev.filter(atendimento => atendimento.id !== id));
    }
  };

  const handleMarkRealizado = (id) => {
    if (window.confirm('Marcar este atendimento como realizado?')) {
      setAtendimentos(prev => prev.map(atendimento => 
        atendimento.id === id ? { ...atendimento, status: 'Realizado' } : atendimento
      ));
    }
  };

  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'Presencial': return <HomeIcon className="w-4 h-4" />;
      case 'Online': return <VideoCameraIcon className="w-4 h-4" />;
      case 'Telefone': return <PhoneIcon className="w-4 h-4" />;
      default: return <UserIcon className="w-4 h-4" />;
    }
  };

  const getTipoColor = (tipo) => {
    switch (tipo) {
      case 'Presencial': return 'bg-blue-100 text-blue-800';
      case 'Online': return 'bg-green-100 text-green-800';
      case 'Telefone': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Agendado': return 'bg-blue-100 text-blue-800';
      case 'Confirmado': return 'bg-green-100 text-green-800';
      case 'Realizado': return 'bg-gray-100 text-gray-800';
      case 'Cancelado': return 'bg-red-100 text-red-800';
      case 'Reagendado': return 'bg-orange-100 text-orange-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR');
  };

  const isToday = (dateString) => {
    return dateString === hoje;
  };

  const isTomorrow = (dateString) => {
    return dateString === amanhaStr;
  };

  // Ações rápidas
  const quickActions = [
    { title: 'Novo Atendimento', icon: '👥', color: 'blue', href: '/admin/atendimentos/novo' },
    { title: 'Hoje', icon: '📅', color: 'green', count: atendimentos.filter(a => a.data === hoje).length },
    { title: 'Esta Semana', icon: '📋', color: 'purple', count: atendimentos.filter(a => {
      const dataAtendimento = new Date(a.data);
      const inicioSemana = new Date();
      const fimSemana = new Date();
      fimSemana.setDate(inicioSemana.getDate() + 7);
      return dataAtendimento >= inicioSemana && dataAtendimento <= fimSemana;
    }).length },
    { title: 'Relatórios', icon: '📊', color: 'yellow', href: '/admin/relatorios/atendimentos' }
  ];

  // Advogados únicos para filtro
  const advogados = [...new Set(atendimentos.map(a => a.advogado))];

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
        <h1 className="text-3xl font-bold text-gray-900">Gestão de Atendimentos</h1>
        <p className="mt-2 text-lg text-gray-600">
          Gerencie todos os atendimentos do escritório
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
EOF

echo "✅ Primeira parte da página Atendimentos.js criada (até 280 linhas)!"

echo ""
echo "📊 IMPLEMENTADO ATÉ AGORA:"
echo "   • Header e estrutura base seguindo padrão Erlene"
echo "   • Mock data completo com relacionamentos"
echo "   • Cards de estatísticas em tempo real"
echo "   • Filtros inteligentes por tipo, status, advogado e data"
echo "   • Funções de manipulação e estados de loading"
echo "   • Ícones específicos por tipo de atendimento"
echo ""
echo "📋 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Dashboard com métricas de hoje, próximas 2h, ontem e mês"
echo "   • Diferenciação visual por tipo (Presencial, Online, Telefone)"
echo "   • Estados por status (Agendado, Confirmado, Realizado, etc.)"
echo "   • Cálculos automáticos de estatísticas"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/3):"
echo "   • Ações rápidas e filtros laterais"
echo "   • Lista/tabela completa de atendimentos"
echo "   • CRUD actions (visualizar, editar, excluir, marcar como realizado)"
echo ""
echo "Digite 'continuar' para Parte 2/3!"