#!/bin/bash

# Script 77 - Tela de Processos (Parte 1/3)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "⚖️ Criando tela de processos (Parte 1/3)..."

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

echo "📁 Criando página principal de processos..."

# Criar Processes.js seguindo EXATO padrão dos clientes
cat > frontend/src/pages/admin/Processes.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  ScaleIcon,
  ClockIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  XCircleIcon,
  PauseIcon
} from '@heroicons/react/24/outline';

const Processes = () => {
  const [processes, setProcesses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [filterCourt, setFilterCourt] = useState('all');
  const [filterClient, setFilterClient] = useState('all');

  // Mock data seguindo padrão do Dashboard
  const mockProcesses = [
    {
      id: 1,
      number: '1001234-56.2024.8.26.0001',
      client: 'João Silva Santos',
      clientId: 1,
      court: 'TJSP - 1ª Vara Cível',
      actionType: 'Ação de Indenização',
      status: 'Em andamento',
      value: 50000.00,
      distributionDate: '2024-01-15',
      lawyer: 'Dr. Carlos Oliveira',
      priority: 'Normal',
      nextDeadline: '2024-03-15',
      createdAt: '2024-01-15'
    },
    {
      id: 2,
      number: '2002345-67.2024.8.26.0002',
      client: 'Empresa ABC Ltda',
      clientId: 2,
      court: 'TJSP - 2ª Vara Empresarial',
      actionType: 'Ação de Cobrança',
      status: 'Urgente',
      value: 120000.00,
      distributionDate: '2024-01-20',
      lawyer: 'Dra. Maria Santos',
      priority: 'Alta',
      nextDeadline: '2024-02-20',
      createdAt: '2024-01-20'
    },
    {
      id: 3,
      number: '3003456-78.2024.8.26.0003',
      client: 'Maria Oliveira Costa',
      clientId: 3,
      court: 'TJSP - 3ª Vara Família',
      actionType: 'Ação de Divórcio',
      status: 'Suspenso',
      value: 0.00,
      distributionDate: '2024-02-01',
      lawyer: 'Dr. Pedro Costa',
      priority: 'Baixa',
      nextDeadline: '2024-04-01',
      createdAt: '2024-02-01'
    },
    {
      id: 4,
      number: '4004567-89.2024.8.26.0004',
      client: 'Tech Solutions S.A.',
      clientId: 4,
      court: 'TJSP - 4ª Vara Empresarial',
      actionType: 'Ação Trabalhista',
      status: 'Concluído',
      value: 75000.00,
      distributionDate: '2024-02-10',
      lawyer: 'Dra. Ana Silva',
      priority: 'Normal',
      nextDeadline: null,
      createdAt: '2024-02-10'
    },
    {
      id: 5,
      number: '5005678-90.2024.8.26.0005',
      client: 'João Silva Santos',
      clientId: 1,
      court: 'TJSP - 5ª Vara Criminal',
      actionType: 'Ação Penal',
      status: 'Em andamento',
      value: 0.00,
      distributionDate: '2024-02-15',
      lawyer: 'Dr. Carlos Oliveira',
      priority: 'Urgente',
      nextDeadline: '2024-03-01',
      createdAt: '2024-02-15'
    }
  ];

  useEffect(() => {
    // Simular carregamento seguindo padrão
    setTimeout(() => {
      setProcesses(mockProcesses);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas
  const stats = [
    {
      name: 'Total de Processos',
      value: processes.length.toString(),
      change: '+18%',
      changeType: 'increase',
      icon: ScaleIcon,
      color: 'blue',
      description: 'Cadastrados no sistema'
    },
    {
      name: 'Em Andamento',
      value: processes.filter(p => p.status === 'Em andamento').length.toString(),
      change: '+12%',
      changeType: 'increase',
      icon: ClockIcon,
      color: 'green',
      description: 'Processos ativos'
    },
    {
      name: 'Urgentes',
      value: processes.filter(p => p.status === 'Urgente').length.toString(),
      change: '+25%',
      changeType: 'increase',
      icon: ExclamationTriangleIcon,
      color: 'red',
      description: 'Requer atenção imediata'
    },
    {
      name: 'Concluídos',
      value: processes.filter(p => p.status === 'Concluído').length.toString(),
      change: '+8%',
      changeType: 'increase',
      icon: CheckCircleIcon,
      color: 'purple',
      description: 'Finalizados este mês'
    }
  ];

  // Filtrar processos
  const filteredProcesses = processes.filter(process => {
    const matchesSearch = process.number.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         process.client.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         process.actionType.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = filterStatus === 'all' || process.status === filterStatus;
    const matchesCourt = filterCourt === 'all' || process.court.includes(filterCourt);
    const matchesClient = filterClient === 'all' || process.clientId.toString() === filterClient;
    
    return matchesSearch && matchesStatus && matchesCourt && matchesClient;
  });

  const handleDelete = (id) => {
    if (window.confirm('Tem certeza que deseja excluir este processo?')) {
      setProcesses(prev => prev.filter(process => process.id !== id));
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'Em andamento': return <ClockIcon className="w-4 h-4" />;
      case 'Urgente': return <ExclamationTriangleIcon className="w-4 h-4" />;
      case 'Suspenso': return <PauseIcon className="w-4 h-4" />;
      case 'Concluído': return <CheckCircleIcon className="w-4 h-4" />;
      default: return <ScaleIcon className="w-4 h-4" />;
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Em andamento': return 'bg-blue-100 text-blue-800';
      case 'Urgente': return 'bg-red-100 text-red-800';
      case 'Suspenso': return 'bg-yellow-100 text-yellow-800';
      case 'Concluído': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'Urgente': return 'text-red-600';
      case 'Alta': return 'text-orange-600';
      case 'Normal': return 'text-blue-600';
      case 'Baixa': return 'text-gray-600';
      default: return 'text-gray-600';
    }
  };

  // Ações rápidas
  const quickActions = [
    { title: 'Novo Processo', icon: '⚖️', color: 'blue', href: '/admin/processos/novo' },
    { title: 'Audiências Hoje', icon: '📅', color: 'green', href: '/admin/audiencias' },
    { title: 'Prazos Vencendo', icon: '⏰', color: 'red', href: '/admin/prazos' },
    { title: 'Relatórios', icon: '📊', color: 'purple', href: '/admin/relatorios/processos' }
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
        <h1 className="text-3xl font-bold text-gray-900">Gestão de Processos</h1>
        <p className="mt-2 text-lg text-gray-600">
          Acompanhe todos os processos jurídicos do escritório
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
                  <span className="font-medium text-gray-900">Em Andamento</span>
                  <span className="text-blue-600 font-semibold">
                    {processes.filter(p => p.status === 'Em andamento').length}
                  </span>
                </div>
              </button>
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Urgentes</span>
                  <span className="text-red-600 font-semibold">
                    {processes.filter(p => p.status === 'Urgente').length}
                  </span>
                </div>
              </button>
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Prazos Hoje</span>
                  <span className="text-orange-600 font-semibold">3</span>
                </div>
              </button>
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Audiências</span>
                  <span className="text-purple-600 font-semibold">5</span>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>
EOF

echo "✅ Processes.js criado (Parte 1 - até linha 300)!"
echo ""
echo "📊 IMPLEMENTADO ATÉ AGORA:"
echo "   • Estrutura base seguindo padrão clientes"
echo "   • Mock data de processos com relacionamento a clientes"
echo "   • Cards de estatísticas com ícones específicos"
echo "   • Ações rápidas para processos"
echo "   • Filtros rápidos funcionais"
echo "   • Estados de loading"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/3):"
echo "   • Lista de processos com tabela"
echo "   • Filtros avançados"
echo "   • Ações de CRUD"
echo "   • Relacionamento com clientes"
echo ""
echo "Digite 'continuar' para Parte 2/3!"