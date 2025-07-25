#!/bin/bash

# Script 85 - Audiências CRUD Completo (Parte 2/4)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📅 Criando CRUD completo de Audiências (Parte 2/4)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 1. Atualizando Audiencias.js com CRUD completo..."

# Fazer backup da página atual
cp frontend/src/pages/admin/Audiencias.js frontend/src/pages/admin/Audiencias.js.backup.$(date +%Y%m%d_%H%M%S)

# Criar página completa de Audiências seguindo padrão Clients.js
cat > frontend/src/pages/admin/Audiencias.js << 'EOF'
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
  MapPinIcon,
  UserIcon,
  ScaleIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  XCircleIcon
} from '@heroicons/react/24/outline';

const Audiencias = () => {
  const [audiencias, setAudiencias] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [filterDate, setFilterDate] = useState('hoje');
  const [filterType, setFilterType] = useState('all');

  // Mock data seguindo padrão do projeto
  const mockAudiencias = [
    {
      id: 1,
      processo: '1001234-56.2024.8.26.0001',
      cliente: 'João Silva Santos',
      tipo: 'Audiência de Conciliação',
      data: '2024-07-25', // Hoje
      hora: '09:00',
      local: 'TJSP - 1ª Vara Cível',
      endereco: 'Praça da Sé, 200 - Centro, São Paulo - SP',
      sala: 'Sala 101',
      status: 'Confirmada',
      advogado: 'Dr. Carlos Oliveira',
      juiz: 'Dr. José Silva',
      observacoes: 'Audiência de tentativa de acordo',
      createdAt: '2024-07-20'
    },
    {
      id: 2,
      processo: '2002345-67.2024.8.26.0002',
      cliente: 'Empresa ABC Ltda',
      tipo: 'Audiência de Instrução',
      data: '2024-07-25', // Hoje
      hora: '14:30',
      local: 'TJSP - 2ª Vara Empresarial',
      endereco: 'Rua da Consolação, 1500 - Consolação, São Paulo - SP',
      sala: 'Sala 205',
      status: 'Agendada',
      advogado: 'Dra. Maria Santos',
      juiz: 'Dra. Ana Costa',
      observacoes: 'Oitiva de testemunhas',
      createdAt: '2024-07-18'
    },
    {
      id: 3,
      processo: '3003456-78.2024.8.26.0003',
      cliente: 'Maria Oliveira Costa',
      tipo: 'Audiência Preliminar',
      data: '2024-07-26', // Amanhã
      hora: '10:00',
      local: 'TJSP - 3ª Vara Família',
      endereco: 'Av. Liberdade, 800 - Liberdade, São Paulo - SP',
      sala: 'Sala 302',
      status: 'Agendada',
      advogado: 'Dr. Pedro Costa',
      juiz: 'Dr. Roberto Lima',
      observacoes: 'Primeira audiência do processo',
      createdAt: '2024-07-15'
    },
    {
      id: 4,
      processo: '4004567-89.2024.8.26.0004',
      cliente: 'Tech Solutions S.A.',
      tipo: 'Audiência de Conciliação',
      data: '2024-07-24', // Ontem
      hora: '15:00',
      local: 'TJSP - 4ª Vara Empresarial',
      endereco: 'Rua Boa Vista, 150 - Centro, São Paulo - SP',
      sala: 'Sala 401',
      status: 'Concluída',
      advogado: 'Dra. Ana Silva',
      juiz: 'Dr. Carlos Pereira',
      observacoes: 'Acordo realizado com sucesso',
      createdAt: '2024-07-10'
    }
  ];

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setAudiencias(mockAudiencias);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas
  const hoje = new Date().toISOString().split('T')[0];
  const stats = [
    {
      name: 'Audiências Hoje',
      value: audiencias.filter(a => a.data === hoje).length.toString(),
      change: '+2',
      changeType: 'increase',
      icon: CalendarIcon,
      color: 'green',
      description: 'Agendadas para hoje'
    },
    {
      name: 'Próximas 2h',
      value: audiencias.filter(a => {
        if (a.data !== hoje) return false;
        const now = new Date();
        const audienciaTime = new Date(`${a.data}T${a.hora}`);
        const diff = audienciaTime.getTime() - now.getTime();
        return diff > 0 && diff <= 2 * 60 * 60 * 1000;
      }).length.toString(),
      change: '0',
      changeType: 'neutral',
      icon: ClockIcon,
      color: 'yellow',
      description: 'Nas próximas 2 horas'
    },
    {
      name: 'Em Andamento',
      value: '0',
      change: '0',
      changeType: 'neutral',
      icon: UserIcon,
      color: 'blue',
      description: 'Acontecendo agora'
    },
    {
      name: 'Total do Mês',
      value: audiencias.length.toString(),
      change: '+15%',
      changeType: 'increase',
      icon: ScaleIcon,
      color: 'purple',
      description: 'Audiências este mês'
    }
  ];

  // Filtrar audiências
  const filteredAudiencias = audiencias.filter(audiencia => {
    const matchesSearch = audiencia.processo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         audiencia.cliente.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         audiencia.tipo.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         audiencia.local.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = filterStatus === 'all' || audiencia.status === filterStatus;
    const matchesType = filterType === 'all' || audiencia.tipo === filterType;
    
    // Filtro por data
    let matchesDate = true;
    if (filterDate === 'hoje') {
      matchesDate = audiencia.data === hoje;
    } else if (filterDate === 'amanha') {
      const amanha = new Date();
      amanha.setDate(amanha.getDate() + 1);
      matchesDate = audiencia.data === amanha.toISOString().split('T')[0];
    } else if (filterDate === 'semana') {
      const dataAudiencia = new Date(audiencia.data);
      const inicioSemana = new Date();
      const fimSemana = new Date();
      fimSemana.setDate(inicioSemana.getDate() + 7);
      matchesDate = dataAudiencia >= inicioSemana && dataAudiencia <= fimSemana;
    }
    
    return matchesSearch && matchesStatus && matchesType && matchesDate;
  });

  const handleDelete = (id) => {
    if (window.confirm('Tem certeza que deseja excluir esta audiência?')) {
      setAudiencias(prev => prev.filter(audiencia => audiencia.id !== id));
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'Agendada': return <CalendarIcon className="w-4 h-4" />;
      case 'Confirmada': return <CheckCircleIcon className="w-4 h-4" />;
      case 'Em andamento': return <ClockIcon className="w-4 h-4" />;
      case 'Concluída': return <CheckCircleIcon className="w-4 h-4" />;
      case 'Cancelada': return <XCircleIcon className="w-4 h-4" />;
      case 'Adiada': return <ExclamationTriangleIcon className="w-4 h-4" />;
      default: return <CalendarIcon className="w-4 h-4" />;
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Agendada': return 'bg-blue-100 text-blue-800';
      case 'Confirmada': return 'bg-green-100 text-green-800';
      case 'Em andamento': return 'bg-yellow-100 text-yellow-800';
      case 'Concluída': return 'bg-gray-100 text-gray-800';
      case 'Cancelada': return 'bg-red-100 text-red-800';
      case 'Adiada': return 'bg-orange-100 text-orange-800';
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

  // Ações rápidas
  const quickActions = [
    { title: 'Nova Audiência', icon: '📅', color: 'blue', href: '/admin/audiencias/nova' },
    { title: 'Audiências Hoje', icon: '🕒', color: 'green', count: audiencias.filter(a => a.data === hoje).length },
    { title: 'Próximas', icon: '📋', color: 'purple', count: audiencias.filter(a => a.data > hoje).length },
    { title: 'Relatórios', icon: '📊', color: 'yellow', href: '/admin/relatorios/audiencias' }
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
        <h1 className="text-3xl font-bold text-gray-900">Gestão de Audiências</h1>
        <p className="mt-2 text-lg text-gray-600">
          Gerencie todas as audiências do escritório
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
              <EyeIcon className="h-5 w-5 text-gray-400" />
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
                    <span className="text-xs text-gray-500 mt-1">{action.count} audiências</span>
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
              <PlusIcon className="h-5 w-5 text-gray-400" />
            </div>
            <div className="space-y-4">
              <button 
                onClick={() => setFilterDate('hoje')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterDate === 'hoje' ? 'bg-primary-50 border-primary-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Hoje</span>
                  <span className="text-primary-600 font-semibold">
                    {audiencias.filter(a => a.data === hoje).length}
                  </span>
                </div>
              </button>
              <button 
                onClick={() => setFilterDate('amanha')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterDate === 'amanha' ? 'bg-primary-50 border-primary-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Amanhã</span>
                  <span className="text-blue-600 font-semibold">
                    {audiencias.filter(a => {
                      const amanha = new Date();
                      amanha.setDate(amanha.getDate() + 1);
                      return a.data === amanha.toISOString().split('T')[0];
                    }).length}
                  </span>
                </div>
              </button>
              <button 
                onClick={() => setFilterDate('semana')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterDate === 'semana' ? 'bg-primary-50 border-primary-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Esta Semana</span>
                  <span className="text-purple-600 font-semibold">
                    {audiencias.filter(a => {
                      const dataAudiencia = new Date(a.data);
                      const hoje = new Date();
                      const fimSemana = new Date();
                      fimSemana.setDate(hoje.getDate() + 7);
                      return dataAudiencia >= hoje && dataAudiencia <= fimSemana;
                    }).length}
                  </span>
                </div>
              </button>
              <button 
                onClick={() => setFilterDate('all')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterDate === 'all' ? 'bg-primary-50 border-primary-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Todas</span>
                  <span className="text-gray-600 font-semibold">{audiencias.length}</span>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>
EOF

echo "✅ Parte 1 da página Audiencias.js criada!"

echo ""
echo "⏭️ Continuando com a lista de audiências..."

# Continuar o arquivo (parte 2)
cat >> frontend/src/pages/admin/Audiencias.js << 'EOF'

      {/* Lista de Audiências */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Lista de Audiências</h2>
          <Link
            to="/admin/audiencias/nova"
            className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <PlusIcon className="w-5 h-5 mr-2" />
            Nova Audiência
          </Link>
        </div>
        
        <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-6">
          {/* Busca */}
          <div className="relative flex-1">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar audiência, processo, cliente..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          
          {/* Filtros */}
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os status</option>
            <option value="Agendada">Agendada</option>
            <option value="Confirmada">Confirmada</option>
            <option value="Em andamento">Em andamento</option>
            <option value="Concluída">Concluída</option>
            <option value="Cancelada">Cancelada</option>
            <option value="Adiada">Adiada</option>
          </select>
          
          <select
            value={filterType}
            onChange={(e) => setFilterType(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os tipos</option>
            <option value="Audiência de Conciliação">Conciliação</option>
            <option value="Audiência de Instrução">Instrução</option>
            <option value="Audiência Preliminar">Preliminar</option>
          </select>
        </div>

        {/* Tabela de Audiências */}
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Data/Hora
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Processo/Cliente
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo/Local
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Advogado
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredAudiencias.map((audiencia) => (
                <tr key={audiencia.id} className={`hover:bg-gray-50 ${isToday(audiencia.data) ? 'bg-blue-50' : ''}`}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                        isToday(audiencia.data) ? 'bg-green-100' : 'bg-blue-100'
                      }`}>
                        <CalendarIcon className={`w-5 h-5 ${
                          isToday(audiencia.data) ? 'text-green-600' : 'text-blue-600'
                        }`} />
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {formatDate(audiencia.data)}
                          {isToday(audiencia.data) && (
                            <span className="ml-2 inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                              Hoje
                            </span>
                          )}
                        </div>
                        <div className="text-sm text-gray-500 flex items-center">
                          <ClockIcon className="w-3 h-3 mr-1" />
                          {audiencia.hora}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900 flex items-center">
                      <ScaleIcon className="w-4 h-4 mr-2 text-primary-600" />
                      {audiencia.processo}
                    </div>
                    <div className="text-sm text-gray-500">{audiencia.cliente}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{audiencia.tipo}</div>
                    <div className="text-sm text-gray-500 flex items-center">
                      <MapPinIcon className="w-3 h-3 mr-1" />
                      {audiencia.local}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(audiencia.status)}`}>
                      {getStatusIcon(audiencia.status)}
                      <span className="ml-1">{audiencia.status}</span>
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{audiencia.advogado}</div>
                    {audiencia.juiz && (
                      <div className="text-sm text-gray-500">Juiz: {audiencia.juiz}</div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex justify-end space-x-2">
                      <button 
                        className="text-blue-600 hover:text-blue-900"
                        title="Visualizar"
                      >
                        <EyeIcon className="w-5 h-5" />
                      </button>
                      <Link
                        to={`/admin/audiencias/${audiencia.id}/editar`}
                        className="text-primary-600 hover:text-primary-900"
                        title="Editar"
                      >
                        <PencilIcon className="w-5 h-5" />
                      </Link>
                      <button
                        onClick={() => handleDelete(audiencia.id)}
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
        
        {/* Estado vazio */}
        {filteredAudiencias.length === 0 && (
          <div className="text-center py-12">
            <CalendarIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhuma audiência encontrada</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || filterStatus !== 'all' || filterType !== 'all' || filterDate !== 'all'
                ? 'Tente ajustar os filtros de busca.'
                : 'Comece agendando uma nova audiência.'}
            </p>
            <div className="mt-6">
              <Link
                to="/admin/audiencias/nova"
                className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <PlusIcon className="w-5 h-5 mr-2" />
                Nova Audiência
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Audiencias;
EOF

echo "✅ Audiencias.js completo criado!"

echo "📝 2. Atualizando App.js para incluir rota de nova audiência..."

# Fazer backup do App.js
cp frontend/src/App.js frontend/src/App.js.backup.$(date +%Y%m%d_%H%M%S)

# Atualizar App.js para incluir NewAudiencia
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/auth/Login';
import AdminLayout from './components/layout/AdminLayout';
import Dashboard from './pages/admin/Dashboard';
import Clients from './pages/admin/Clients';
import NewClient from './components/clients/NewClient';
import Processes from './pages/admin/Processes';
import NewProcess from './components/processes/NewProcess';
import Audiencias from './pages/admin/Audiencias';
import NewAudiencia from './components/audiencias/NewAudiencia';
import Prazos from './pages/admin/Prazos';

// Portal Cliente (temporário)
const ClientPortal = () => {
  const handleLogout = () => {
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('userType');
    window.location.href = '/login';
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="bg-gradient-erlene text-white p-4">
        <div className="flex justify-between items-center max-w-7xl mx-auto">
          <h1 className="text-xl font-bold">Portal do Cliente - Erlene Advogados</h1>
          <button
            onClick={handleLogout}
            className="bg-red-700 hover:bg-red-800 px-4 py-2 rounded text-sm"
          >
            Sair
          </button>
        </div>
      </div>

      <div className="max-w-7xl mx-auto p-6">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900">Portal do Cliente</h2>
          <p className="text-gray-600">Acompanhe seus processos e documentos</p>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {[
            { title: 'Meus Processos', subtitle: '3 processos ativos', color: 'red', icon: '⚖️' },
            { title: 'Documentos', subtitle: '12 documentos disponíveis', color: 'blue', icon: '📄' },
            { title: 'Pagamentos', subtitle: '2 pagamentos pendentes', color: 'green', icon: '💳' }
          ].map((item) => (
            <div key={item.title} className="bg-white overflow-hidden shadow-erlene rounded-lg">
              <div className="p-6">
                <div className="flex items-center mb-4">
                  <span className="text-2xl mr-3">{item.icon}</span>
                  <h3 className="text-lg font-medium text-gray-900">{item.title}</h3>
                </div>
                <p className="text-gray-600 mb-4">{item.subtitle}</p>
                <button className={`bg-${item.color}-600 text-white px-4 py-2 rounded hover:bg-${item.color}-700`}>
                  Ver {item.title}
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

// Componente de proteção de rota
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';
  const userType = localStorage.getItem('userType');

  if (requiredAuth && !isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (!requiredAuth && isAuthenticated) {
    return <Navigate to={userType === 'cliente' ? '/portal' : '/admin'} replace />;
  }

  if (allowedTypes.length > 0 && !allowedTypes.includes(userType)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return children;
};

// Página 404
const NotFoundPage = () => (
  <div className="min-h-screen flex items-center justify-center bg-gray-50">
    <div className="text-center">
      <h1 className="text-6xl font-bold text-gray-400 mb-4">404</h1>
      <p className="text-gray-600 mb-4">Página não encontrada</p>
      <a href="/login" className="bg-gradient-erlene text-white px-4 py-2 rounded hover:shadow-erlene">
        Voltar ao Login
      </a>
    </div>
  </div>
);

// App principal
function App() {
  return (
    <Router>
      <div className="App h-screen">
        <Routes>
          <Route path="/" element={<Navigate to="/login" replace />} />
          
          <Route
            path="/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <Login />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/admin/*"
            element={
              <ProtectedRoute allowedTypes={['admin']}>
                <AdminLayout>
                  <Routes>
                    <Route path="" element={<Dashboard />} />
                    <Route path="dashboard" element={<Dashboard />} />
                    <Route path="clientes" element={<Clients />} />
                    <Route path="clientes/novo" element={<NewClient />} />
                    <Route path="processos" element={<Processes />} />
                    <Route path="processos/novo" element={<NewProcess />} />
                    <Route path="audiencias" element={<Audiencias />} />
                    <Route path="audiencias/nova" element={<NewAudiencia />} />
                    <Route path="prazos" element={<Prazos />} />
                  </Routes>
                </AdminLayout>
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <ClientPortal />
              </ProtectedRoute>
            }
          />
          
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
EOF

echo "✅ App.js atualizado com rota de nova audiência!"

echo ""
echo "🎉 PARTE 2/4 CONCLUÍDA!"
echo ""
echo "✅ AUDIÊNCIAS CRUD IMPLEMENTADO:"
echo "   • Página principal com lista completa"
echo "   • Filtros por data (hoje, amanhã, semana)"
echo "   • Estatísticas em tempo real"
echo "   • Tabela responsiva com todas as informações"
echo "   • Destaque visual para audiências de hoje"
echo "   • Ações de visualizar, editar e excluir"
echo "   • Estado vazio com call-to-action"
echo ""
echo "📋 FUNCIONALIDADES:"
echo "   • Dashboard com cards de estatísticas"
echo "   • Ações rápidas com contadores"
echo "   • Filtros inteligentes por data e status"
echo "   • Busca por processo, cliente ou local"
echo "   • Design seguindo padrão Erlene"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "   • /admin/audiencias - Lista de audiências"
echo "   • /admin/audiencias/nova - Nova audiência"
echo ""
echo "⏭️ PRÓXIMA PARTE (3/4):"
echo "   • Componente EditAudiencia"
echo "   • CRUD completo de Prazos"
echo "   • Página de relatórios"
echo ""
echo "Digite 'continuar' para Parte 3/4!"
