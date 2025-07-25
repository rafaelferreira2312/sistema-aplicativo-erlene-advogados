#!/bin/bash

# Script 88 - Lista de Prazos Completa com CRUD
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "⏰ Criando lista completa de Prazos com CRUD (Script 88)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Atualizando Prazos.js com lista completa e CRUD..."

# Fazer backup da página atual
cp frontend/src/pages/admin/Prazos.js frontend/src/pages/admin/Prazos.js.backup.$(date +%Y%m%d_%H%M%S)

# Criar página completa de Prazos seguindo padrão Audiencias.js
cat > frontend/src/pages/admin/Prazos.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  ClockIcon,
  CalendarIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  UserIcon,
  ScaleIcon,
  ArrowUpIcon,
  ArrowDownIcon
} from '@heroicons/react/24/outline';

const Prazos = () => {
  const [prazos, setPrazos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterPrioridade, setFilterPrioridade] = useState('all');
  const [filterDias, setFilterDias] = useState('todos');
  const [filterTipo, setFilterTipo] = useState('all');

  // Mock data seguindo padrão do projeto
  const mockPrazos = [
    {
      id: 1,
      processo: '1001234-56.2024.8.26.0001',
      cliente: 'João Silva Santos',
      descricao: 'Petição Inicial',
      tipoPrazo: 'Petição Inicial',
      dataVencimento: '2024-07-25', // Hoje
      horaVencimento: '17:00',
      prioridade: 'Urgente',
      advogado: 'Dr. Carlos Oliveira',
      observacoes: 'Prazo fatal para protocolo',
      status: 'Pendente',
      diasRestantes: 0,
      createdAt: '2024-07-20'
    },
    {
      id: 2,
      processo: '2002345-67.2024.8.26.0002',
      cliente: 'Empresa ABC Ltda',
      descricao: 'Contestação',
      tipoPrazo: 'Contestação',
      dataVencimento: '2024-07-26', // Amanhã
      horaVencimento: '17:00',
      prioridade: 'Alta',
      advogado: 'Dra. Maria Santos',
      observacoes: 'Revisar documentos anexos',
      status: 'Pendente',
      diasRestantes: 1,
      createdAt: '2024-07-18'
    },
    {
      id: 3,
      processo: '3003456-78.2024.8.26.0003',
      cliente: 'Maria Oliveira Costa',
      descricao: 'Recurso Ordinário',
      tipoPrazo: 'Recurso Ordinário',
      dataVencimento: '2024-07-30',
      horaVencimento: '17:00',
      prioridade: 'Normal',
      advogado: 'Dr. Pedro Costa',
      observacoes: 'Aguardando publicação oficial',
      status: 'Pendente',
      diasRestantes: 5,
      createdAt: '2024-07-15'
    },
    {
      id: 4,
      processo: '4004567-89.2024.8.26.0004',
      cliente: 'Tech Solutions S.A.',
      descricao: 'Alegações Finais',
      tipoPrazo: 'Alegações Finais',
      dataVencimento: '2024-07-24', // Ontem
      horaVencimento: '17:00',
      prioridade: 'Alta',
      advogado: 'Dra. Ana Silva',
      observacoes: 'Protocolado com sucesso',
      status: 'Concluído',
      diasRestantes: -1,
      createdAt: '2024-07-10'
    },
    {
      id: 5,
      processo: '5005678-90.2024.8.26.0005',
      cliente: 'João Silva Santos',
      descricao: 'Tréplica',
      tipoPrazo: 'Tréplica',
      dataVencimento: '2024-08-02',
      horaVencimento: '17:00',
      prioridade: 'Normal',
      advogado: 'Dr. Carlos Oliveira',
      observacoes: 'Em elaboração',
      status: 'Pendente',
      diasRestantes: 8,
      createdAt: '2024-07-12'
    }
  ];

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setPrazos(mockPrazos);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas
  const hoje = new Date().toISOString().split('T')[0];
  const stats = [
    {
      name: 'Vencendo Hoje',
      value: prazos.filter(p => p.diasRestantes === 0 && p.status === 'Pendente').length.toString(),
      change: '+1',
      changeType: 'increase',
      icon: ExclamationTriangleIcon,
      color: 'red',
      description: 'Atenção imediata'
    },
    {
      name: 'Vencendo Amanhã',
      value: prazos.filter(p => p.diasRestantes === 1 && p.status === 'Pendente').length.toString(),
      change: '0',
      changeType: 'neutral',
      icon: ClockIcon,
      color: 'yellow',
      description: 'Preparar documentos'
    },
    {
      name: 'Próximos 7 dias',
      value: prazos.filter(p => p.diasRestantes <= 7 && p.diasRestantes > 0 && p.status === 'Pendente').length.toString(),
      change: '+2',
      changeType: 'increase',
      icon: CalendarIcon,
      color: 'blue',
      description: 'Organizar agenda'
    },
    {
      name: 'Total Pendentes',
      value: prazos.filter(p => p.status === 'Pendente').length.toString(),
      change: '+3',
      changeType: 'increase',
      icon: ScaleIcon,
      color: 'purple',
      description: 'Em acompanhamento'
    }
  ];

  // Filtrar prazos
  const filteredPrazos = prazos.filter(prazo => {
    const matchesSearch = prazo.processo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         prazo.cliente.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         prazo.descricao.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         prazo.tipoPrazo.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesPrioridade = filterPrioridade === 'all' || prazo.prioridade === filterPrioridade;
    const matchesTipo = filterTipo === 'all' || prazo.tipoPrazo === filterTipo;
    
    // Filtro por dias
    let matchesDias = true;
    if (filterDias === 'hoje') {
      matchesDias = prazo.diasRestantes === 0 && prazo.status === 'Pendente';
    } else if (filterDias === 'amanha') {
      matchesDias = prazo.diasRestantes === 1 && prazo.status === 'Pendente';
    } else if (filterDias === 'semana') {
      matchesDias = prazo.diasRestantes <= 7 && prazo.diasRestantes >= 0 && prazo.status === 'Pendente';
    } else if (filterDias === 'vencidos') {
      matchesDias = prazo.diasRestantes < 0 && prazo.status === 'Pendente';
    }
    
    return matchesSearch && matchesPrioridade && matchesTipo && matchesDias;
  });

  const handleDelete = (id) => {
    if (window.confirm('Tem certeza que deseja excluir este prazo?')) {
      setPrazos(prev => prev.filter(prazo => prazo.id !== id));
    }
  };

  const handleMarkComplete = (id) => {
    if (window.confirm('Marcar este prazo como concluído?')) {
      setPrazos(prev => prev.map(prazo => 
        prazo.id === id ? { ...prazo, status: 'Concluído' } : prazo
      ));
    }
  };

  const getPriorityColor = (prioridade) => {
    switch (prioridade) {
      case 'Urgente': return 'bg-red-100 text-red-800';
      case 'Alta': return 'bg-orange-100 text-orange-800';
      case 'Normal': return 'bg-blue-100 text-blue-800';
      case 'Baixa': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusColor = (status, diasRestantes) => {
    if (status === 'Concluído') return 'bg-green-100 text-green-800';
    if (diasRestantes < 0) return 'bg-red-100 text-red-800';
    if (diasRestantes === 0) return 'bg-orange-100 text-orange-800';
    if (diasRestantes === 1) return 'bg-yellow-100 text-yellow-800';
    return 'bg-blue-100 text-blue-800';
  };

  const getStatusText = (status, diasRestantes) => {
    if (status === 'Concluído') return 'Concluído';
    if (diasRestantes < 0) return 'Vencido';
    if (diasRestantes === 0) return 'Vence Hoje';
    if (diasRestantes === 1) return 'Vence Amanhã';
    return `${diasRestantes} dias`;
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR');
  };

  // Ações rápidas
  const quickActions = [
    { title: 'Novo Prazo', icon: '⏰', color: 'blue', href: '/admin/prazos/novo' },
    { title: 'Vencendo Hoje', icon: '🚨', color: 'red', count: prazos.filter(p => p.diasRestantes === 0 && p.status === 'Pendente').length },
    { title: 'Próximos', icon: '📋', color: 'purple', count: prazos.filter(p => p.diasRestantes > 0 && p.status === 'Pendente').length },
    { title: 'Relatórios', icon: '📊', color: 'yellow', href: '/admin/relatorios/prazos' }
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
        <h1 className="text-3xl font-bold text-gray-900">Gestão de Prazos</h1>
        <p className="mt-2 text-lg text-gray-600">
          Acompanhe todos os prazos processuais do escritório
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

echo "✅ Primeira parte da página Prazos.js criada (até 300 linhas)!"
echo ""
echo "📊 IMPLEMENTADO ATÉ AGORA:"
echo "   • Header e estrutura base"
echo "   • Mock data completo com relacionamentos"
echo "   • Cards de estatísticas em tempo real"
echo "   • Filtros inteligentes por prioridade e dias"
echo "   • Estados de loading"
echo ""
echo "⏭️ PRÓXIMA PARTE:"
echo "   • Ações rápidas e filtros laterais"
echo "   • Lista/tabela completa de prazos"
echo "   • CRUD actions (editar, excluir, marcar como concluído)"
echo ""
echo "Digite 'continuar' para a Parte 2!"