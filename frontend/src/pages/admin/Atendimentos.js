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
                  onClick={() => action.href && (window.location.href = action.href)}
                >
                  <span className="text-3xl mb-3 group-hover:scale-110 transition-transform duration-200">
                    {action.icon}
                  </span>
                  <span className="text-sm font-medium text-gray-900 group-hover:text-primary-700">
                    {action.title}
                  </span>
                  {action.count !== undefined && (
                    <span className="text-xs text-gray-500 mt-1">{action.count} atendimentos</span>
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
                onClick={() => setFilterData('hoje')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterData === 'hoje' ? 'bg-green-50 border border-green-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Hoje</span>
                  <span className="text-green-600 font-semibold">
                    {atendimentos.filter(a => a.data === hoje).length}
                  </span>
                </div>
              </button>
              <button 
                onClick={() => setFilterData('amanha')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterData === 'amanha' ? 'bg-blue-50 border border-blue-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Amanhã</span>
                  <span className="text-blue-600 font-semibold">
                    {atendimentos.filter(a => a.data === amanhaStr).length}
                  </span>
                </div>
              </button>
              <button 
                onClick={() => setFilterData('semana')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterData === 'semana' ? 'bg-purple-50 border border-purple-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Esta Semana</span>
                  <span className="text-purple-600 font-semibold">
                    {atendimentos.filter(a => {
                      const dataAtendimento = new Date(a.data);
                      const hoje = new Date();
                      const fimSemana = new Date();
                      fimSemana.setDate(hoje.getDate() + 7);
                      return dataAtendimento >= hoje && dataAtendimento <= fimSemana;
                    }).length}
                  </span>
                </div>
              </button>
              <button 
                onClick={() => setFilterData('todos')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterData === 'todos' ? 'bg-primary-50 border border-primary-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Todos</span>
                  <span className="text-gray-600 font-semibold">{atendimentos.length}</span>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Lista de Atendimentos */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Lista de Atendimentos</h2>
          <Link
            to="/admin/atendimentos/novo"
            className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <PlusIcon className="w-5 h-5 mr-2" />
            Novo Atendimento
          </Link>
        </div>
        
        <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-6">
          {/* Busca */}
          <div className="relative flex-1">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar cliente, assunto, advogado..."
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
            <option value="Agendado">Agendado</option>
            <option value="Confirmado">Confirmado</option>
            <option value="Realizado">Realizado</option>
            <option value="Cancelado">Cancelado</option>
            <option value="Reagendado">Reagendado</option>
          </select>
          
          <select
            value={filterTipo}
            onChange={(e) => setFilterTipo(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os tipos</option>
            <option value="Presencial">Presencial</option>
            <option value="Online">Online</option>
            <option value="Telefone">Telefone</option>
          </select>
          
          <select
            value={filterAdvogado}
            onChange={(e) => setFilterAdvogado(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os advogados</option>
            {advogados.map((advogado) => (
              <option key={advogado} value={advogado}>{advogado}</option>
            ))}
          </select>
        </div>

        {/* Tabela de Atendimentos */}
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Data/Hora
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cliente
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Assunto
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo
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
              {filteredAtendimentos.map((atendimento) => (
                <tr key={atendimento.id} className={`hover:bg-gray-50 ${
                  isToday(atendimento.data) ? 'bg-green-50' : 
                  isTomorrow(atendimento.data) ? 'bg-blue-50' : ''
                }`}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                        isToday(atendimento.data) ? 'bg-green-100' :
                        isTomorrow(atendimento.data) ? 'bg-blue-100' : 'bg-gray-100'
                      }`}>
                        <CalendarIcon className={`w-5 h-5 ${
                          isToday(atendimento.data) ? 'text-green-600' :
                          isTomorrow(atendimento.data) ? 'text-blue-600' : 'text-gray-600'
                        }`} />
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {formatDate(atendimento.data)}
                          {isToday(atendimento.data) && (
                            <span className="ml-2 inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                              Hoje
                            </span>
                          )}
                          {isTomorrow(atendimento.data) && (
                            <span className="ml-2 inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                              Amanhã
                            </span>
                          )}
                        </div>
                        <div className="text-sm text-gray-500 flex items-center">
                          <ClockIcon className="w-3 h-3 mr-1" />
                          {atendimento.hora} ({atendimento.duracao})
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <UserIcon className="w-4 h-4 mr-2 text-primary-600" />
                      <div>
                        <div className="text-sm font-medium text-gray-900">{atendimento.cliente}</div>
                        {atendimento.processos.length > 0 && (
                          <div className="text-xs text-gray-500">{atendimento.processos.length} processo(s)</div>
                        )}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900">{atendimento.assunto}</div>
                    {atendimento.observacoes && (
                      <div className="text-xs text-gray-500 mt-1 truncate max-w-xs">
                        {atendimento.observacoes}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2 py-1 text-xs font-semibold rounded-full ${getTipoColor(atendimento.tipo)}`}>
                      {getTipoIcon(atendimento.tipo)}
                      <span className="ml-1">{atendimento.tipo}</span>
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(atendimento.status)}`}>
                      {atendimento.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {atendimento.advogado}
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
                        to={`/admin/atendimentos/${atendimento.id}/editar`}
                        className="text-primary-600 hover:text-primary-900"
                        title="Editar"
                      >
                        <PencilIcon className="w-5 h-5" />
                      </Link>
                      {(atendimento.status === 'Agendado' || atendimento.status === 'Confirmado') && (
                        <button
                          onClick={() => handleMarkRealizado(atendimento.id)}
                          className="text-green-600 hover:text-green-900"
                          title="Marcar como Realizado"
                        >
                          <CheckCircleIcon className="w-5 h-5" />
                        </button>
                      )}
                      <button
                        onClick={() => handleDelete(atendimento.id)}
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
        {filteredAtendimentos.length === 0 && (
          <div className="text-center py-12">
            <UserIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum atendimento encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || filterStatus !== 'all' || filterTipo !== 'all' || filterAdvogado !== 'all' || filterData !== 'todos'
                ? 'Tente ajustar os filtros de busca.'
                : 'Comece agendando um novo atendimento.'}
            </p>
            <div className="mt-6">
              <Link
                to="/admin/atendimentos/novo"
                className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <PlusIcon className="w-5 h-5 mr-2" />
                Novo Atendimento
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Atendimentos;
