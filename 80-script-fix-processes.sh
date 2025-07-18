#!/bin/bash

# Script 80 - Corrigir Estrutura de Processos
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "🔧 Corrigindo estrutura de processos seguindo padrão do projeto..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 Verificando estrutura atual..."

# Verificar se arquivos existem
if [ ! -f "frontend/src/pages/admin/Processes.js" ]; then
    echo "❌ Processes.js não encontrado - criando..."
    
    # Criar Processes.js seguindo EXATO padrão do Clients.js
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
  ExclamationTriangleIcon,
  CheckCircleIcon,
  PauseIcon
} from '@heroicons/react/24/outline';

const Processes = () => {
  const [processes, setProcesses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [filterCourt, setFilterCourt] = useState('all');

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
  const stats = {
    total: processes.length,
    active: processes.filter(p => p.status === 'Em andamento').length,
    urgent: processes.filter(p => p.status === 'Urgente').length,
    completed: processes.filter(p => p.status === 'Concluído').length
  };

  // Filtrar processos
  const filteredProcesses = processes.filter(process => {
    const matchesSearch = process.number.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         process.client.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         process.actionType.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = filterStatus === 'all' || process.status === filterStatus;
    const matchesCourt = filterCourt === 'all' || process.court.includes(filterCourt);
    
    return matchesSearch && matchesStatus && matchesCourt;
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
        <h1 className="text-3xl font-bold text-gray-900">Processos</h1>
        <p className="mt-2 text-lg text-gray-600">
          Gerencie todos os processos jurídicos do escritório
        </p>
      </div>

      {/* Stats Cards seguindo EXATO padrão Dashboard */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-blue-100">
                  <ScaleIcon className="h-6 w-6 text-blue-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Total de Processos</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.total}</p>
              <p className="text-sm text-gray-500 mt-1">Cadastrados no sistema</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-green-100">
                  <ClockIcon className="h-6 w-6 text-green-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Em Andamento</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.active}</p>
              <p className="text-sm text-gray-500 mt-1">Processos ativos</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-red-100">
                  <ExclamationTriangleIcon className="h-6 w-6 text-red-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Urgentes</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.urgent}</p>
              <p className="text-sm text-gray-500 mt-1">Requer atenção imediata</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-purple-100">
                  <CheckCircleIcon className="h-6 w-6 text-purple-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Concluídos</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.completed}</p>
              <p className="text-sm text-gray-500 mt-1">Finalizados este mês</p>
            </div>
          </div>
        </div>
      </div>

      {/* Filtros e Ações */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Lista de Processos</h2>
          <Link
            to="/admin/processos/novo"
            className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <PlusIcon className="w-5 h-5 mr-2" />
            Novo Processo
          </Link>
        </div>
        
        <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-6">
          {/* Busca */}
          <div className="relative flex-1">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar processo, cliente ou tipo..."
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
            <option value="Em andamento">Em andamento</option>
            <option value="Urgente">Urgente</option>
            <option value="Suspenso">Suspenso</option>
            <option value="Concluído">Concluído</option>
          </select>
          
          <select
            value={filterCourt}
            onChange={(e) => setFilterCourt(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os tribunais</option>
            <option value="TJSP">TJSP</option>
            <option value="TJRJ">TJRJ</option>
            <option value="STJ">STJ</option>
            <option value="TST">TST</option>
          </select>
        </div>

        {/* Tabela */}
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
                  Tribunal/Tipo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Valor/Prazo
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredProcesses.map((process) => (
                <tr key={process.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                        <ScaleIcon className="w-5 h-5 text-primary-600" />
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {process.number}
                        </div>
                        <div className={`text-xs font-medium ${getPriorityColor(process.priority)}`}>
                          Prioridade: {process.priority}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{process.client}</div>
                    <div className="text-sm text-gray-500">ID: {process.clientId}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{process.court}</div>
                    <div className="text-sm text-gray-500">{process.actionType}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(process.status)}`}>
                      {getStatusIcon(process.status)}
                      <span className="ml-1">{process.status}</span>
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {process.value > 0 ? `R$ ${process.value.toLocaleString('pt-BR')}` : 'Sem valor'}
                    </div>
                    <div className="text-sm text-gray-500">
                      {process.nextDeadline ? (
                        <span className="flex items-center">
                          <ClockIcon className="w-3 h-3 mr-1" />
                          {new Date(process.nextDeadline).toLocaleDateString('pt-BR')}
                        </span>
                      ) : (
                        'Sem prazo'
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex justify-end space-x-2">
                      <button className="text-blue-600 hover:text-blue-900">
                        <EyeIcon className="w-5 h-5" />
                      </button>
                      <Link
                        to={`/admin/processos/${process.id}`}
                        className="text-primary-600 hover:text-primary-900"
                      >
                        <PencilIcon className="w-5 h-5" />
                      </Link>
                      <button
                        onClick={() => handleDelete(process.id)}
                        className="text-red-600 hover:text-red-900"
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
        
        {filteredProcesses.length === 0 && (
          <div className="text-center py-12">
            <ScaleIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum processo encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || filterStatus !== 'all' || filterCourt !== 'all'
                ? 'Tente ajustar os filtros de busca.'
                : 'Comece cadastrando um novo processo.'}
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default Processes;
EOF
    
    echo "✅ Processes.js criado seguindo padrão correto"
else
    echo "✅ Processes.js já existe"
fi

# Mover NewProcess.js para localização correta (se existir)
if [ -f "frontend/src/components/processes/NewProcess.js" ]; then
    echo "📁 Movendo NewProcess.js para localização correta..."
    
    # Criar NewClient seguindo padrão (componente em components/)
    cp frontend/src/components/processes/NewProcess.js frontend/src/components/processes/NewProcess.js.backup
    
    echo "✅ NewProcess.js mantido em components/processes/"
else
    echo "⚠️  NewProcess.js não encontrado - criando..."
    
    # Criar estrutura
    mkdir -p frontend/src/components/processes
    
    # Criar NewProcess básico seguindo padrão NewClient
    cat > frontend/src/components/processes/NewProcess.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  ScaleIcon,
  UserIcon,
  BuildingOfficeIcon
} from '@heroicons/react/24/outline';

const NewProcess = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  
  const [formData, setFormData] = useState({
    number: '',
    clientId: '',
    court: '',
    actionType: '',
    status: 'Em andamento',
    priority: 'Normal'
  });

  const [errors, setErrors] = useState({});

  // Mock clients
  const mockClients = [
    { id: 1, name: 'João Silva Santos', type: 'PF', document: '123.456.789-00' },
    { id: 2, name: 'Empresa ABC Ltda', type: 'PJ', document: '12.345.678/0001-90' },
    { id: 3, name: 'Maria Oliveira Costa', type: 'PF', document: '987.654.321-00' },
    { id: 4, name: 'Tech Solutions S.A.', type: 'PJ', document: '98.765.432/0001-10' }
  ];

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.number.trim()) newErrors.number = 'Número do processo é obrigatório';
    if (!formData.clientId) newErrors.clientId = 'Cliente é obrigatório';
    if (!formData.court.trim()) newErrors.court = 'Tribunal é obrigatório';
    if (!formData.actionType.trim()) newErrors.actionType = 'Tipo de ação é obrigatório';
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      alert('Processo cadastrado com sucesso!');
      navigate('/admin/processos');
    } catch (error) {
      alert('Erro ao cadastrar processo');
    } finally {
      setLoading(false);
    }
  };

  const selectedClient = mockClients.find(c => c.id.toString() === formData.clientId);

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/processos"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Novo Processo</h1>
              <p className="text-lg text-gray-600 mt-2">Cadastre um novo processo jurídico</p>
            </div>
          </div>
          <ScaleIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Seleção de Cliente */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Cliente</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Selecione o Cliente *
              </label>
              <select
                name="clientId"
                value={formData.clientId}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.clientId ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione um cliente...</option>
                {mockClients.map((client) => (
                  <option key={client.id} value={client.id}>
                    {client.name} ({client.type}) - {client.document}
                  </option>
                ))}
              </select>
              {errors.clientId && <p className="text-red-500 text-sm mt-1">{errors.clientId}</p>}
            </div>

            {selectedClient && (
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-2">Cliente Selecionado:</h3>
                <div className="flex items-center">
                  <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center mr-3">
                    {selectedClient.type === 'PF' ? (
                      <UserIcon className="w-4 h-4 text-primary-600" />
                    ) : (
                      <BuildingOfficeIcon className="w-4 h-4 text-primary-600" />
                    )}
                  </div>
                  <div>
                    <div className="font-medium text-gray-900">{selectedClient.name}</div>
                    <div className="text-sm text-gray-500">{selectedClient.document}</div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Dados do Processo */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Dados do Processo</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Número do Processo (CNJ) *
              </label>
              <input
                type="text"
                name="number"
                value={formData.number}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.number ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="1234567-89.2024.8.26.0001"
              />
              {errors.number && <p className="text-red-500 text-sm mt-1">{errors.number}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tribunal/Vara *
              </label>
              <input
                type="text"
                name="court"
                value={formData.court}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.court ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="TJSP - 1ª Vara Cível"
              />
              {errors.court && <p className="text-red-500 text-sm mt-1">{errors.court}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Ação *
              </label>
              <input
                type="text"
                name="actionType"
                value={formData.actionType}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.actionType ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="Ação de Indenização"
              />
              {errors.actionType && <p className="text-red-500 text-sm mt-1">{errors.actionType}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Status
              </label>
              <select
                name="status"
                value={formData.status}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Em andamento">Em andamento</option>
                <option value="Urgente">Urgente</option>
                <option value="Suspenso">Suspenso</option>
                <option value="Concluído">Concluído</option>
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Prioridade
              </label>
              <select
                name="priority"
                value={formData.priority}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Baixa">Baixa</option>
                <option value="Normal">Normal</option>
                <option value="Alta">Alta</option>
                <option value="Urgente">Urgente</option>
              </select>
            </div>
          </div>
        </div>

        {/* Botões */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/processos"
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              Cancelar
            </Link>
            <button
              type="submit"
              disabled={loading}
              className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? 'Salvando...' : 'Salvar Processo'}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewProcess;
EOF
    
    echo "✅ NewProcess.js criado"
fi

echo "📝 Verificando AdminLayout..."

# Verificar se AdminLayout tem o link de processos
if [ -f "frontend/src/components/layout/AdminLayout/index.js" ]; then
    if grep -q "/admin/processos" frontend/src/components/layout/AdminLayout/index.js; then
        echo "✅ Link de processos já existe no AdminLayout"
    else
        echo "🔧 Adicionando link de processos ao AdminLayout..."
        
        # Fazer backup
        cp frontend/src/components/layout/AdminLayout/index.js frontend/src/components/layout/AdminLayout/index.js.backup.fix
        
        # Buscar linha com clientes e adicionar processos após ela
        sed -i '/href.*\/admin\/clientes/a\            { name: '\''Processos'\'', href: '\''/admin/processos'\'', icon: ScaleIcon },' frontend/src/components/layout/AdminLayout/index.js
        
        # Verificar se ScaleIcon está no import
        if ! grep -q "ScaleIcon" frontend/src/components/layout/AdminLayout/index.js; then
            # Adicionar ScaleIcon ao import
            sed -i 's/} from '\''@heroicons\/react\/24\/outline'\'';/, ScaleIcon } from '\''@heroicons\/react\/24\/outline'\'';/' frontend/src/components/layout/AdminLayout/index.js
        fi
        
        echo "✅ Link de processos adicionado ao AdminLayout"
    fi
else
    echo "⚠️ AdminLayout não encontrado"
fi

echo "📝 Verificando App.js..."

# Verificar e corrigir App.js
if [ -f "frontend/src/App.js" ]; then
    # Fazer backup
    cp frontend/src/App.js frontend/src/App.js.backup.fix
    
    # Verificar se imports estão corretos
    if ! grep -q "import Processes from './pages/admin/Processes'" frontend/src/App.js; then
        echo "🔧 Corrigindo imports no App.js..."
        
        # Adicionar import do Processes
        sed -i '/import Clients from/a import Processes from '\''./pages/admin/Processes'\'';' frontend/src/App.js
    fi
    
    if ! grep -q "import NewProcess from './components/processes/NewProcess'" frontend/src/App.js; then
        # Adicionar import do NewProcess
        sed -i '/import NewClient from/a import NewProcess from '\''./components/processes/NewProcess'\'';' frontend/src/App.js
    fi
    
    # Verificar se rotas estão configuradas
    if ! grep -q 'path="processos"' frontend/src/App.js; then
        echo "🔧 Adicionando rotas de processos..."
        
        # Adicionar rota de processos após clientes
        sed -i '/path="clientes\/novo"/a\                    <Route path="processos" element={<Processes />} />\
                    <Route path="processos/novo" element={<NewProcess />} />' frontend/src/App.js
    fi
    
    echo "✅ App.js verificado e corrigido"
else
    echo "⚠️ App.js não encontrado"
fi

echo ""
echo "🎉 CORREÇÕES APLICADAS!"
echo ""
echo "✅ ESTRUTURA CORRIGIDA:"
echo "   • frontend/src/pages/admin/Processes.js (página principal)"
echo "   • frontend/src/components/processes/NewProcess.js (formulário)"
echo "   • AdminLayout com link 'Processos'"
echo "   • App.js com imports e rotas corretas"
echo ""
echo "📁 PADRÃO SEGUIDO (igual aos clientes):"
echo "   • Página principal: pages/admin/Processes.js"
echo "   • Componente formulário: components/processes/NewProcess.js"
echo "   • Layout idêntico ao Clients.js"
echo "   • Classes CSS: shadow-erlene, primary-600"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "   • /admin/processos → Lista de processos"
echo "   • /admin/processos/novo → Cadastro de processo"
echo ""
echo "🎯 TESTE AGORA:"
echo "   1. http://localhost:3000/admin/processos"
echo "   2. Clique em 'Processos' no menu lateral"
echo "   3. Clique em 'Novo Processo'"
echo ""
echo "💡 SE AINDA NÃO FUNCIONAR:"
echo "   • Verifique o console do navegador (F12)"
echo "   • Recarregue a página (Ctrl+F5)"
echo "   • Verifique se o servidor está rodando"
echo ""
echo "🔧 PRÓXIMO PASSO: Teste e me informe se está funcionando!"
                