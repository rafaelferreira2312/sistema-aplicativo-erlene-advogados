#!/bin/bash

# Script 79 - Telas de Audiências e Prazos (Parte 2/3)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📅 Criando telas de Audiências e Prazos (Parte 2/3)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 1. Criando página de Audiências..."

# Criar página de Audiências seguindo padrão do projeto
cat > frontend/src/pages/admin/Audiencias.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  CalendarIcon,
  ClockIcon,
  MapPinIcon,
  UserIcon,
  ScaleIcon,
  ArrowUpIcon,
  EyeIcon,
  PlusIcon
} from '@heroicons/react/24/outline';

const Audiencias = () => {
  const [audiencias, setAudiencias] = useState([]);
  const [loading, setLoading] = useState(true);

  // Mock data seguindo padrão do projeto
  const mockAudiencias = [
    {
      id: 1,
      processo: '1001234-56.2024.8.26.0001',
      cliente: 'João Silva Santos',
      tipo: 'Audiência de Conciliação',
      data: '2024-07-18',
      hora: '09:00',
      local: 'TJSP - 1ª Vara Cível',
      status: 'Hoje',
      advogado: 'Dr. Carlos Oliveira'
    },
    {
      id: 2,
      processo: '2002345-67.2024.8.26.0002',
      cliente: 'Empresa ABC Ltda',
      tipo: 'Audiência de Instrução',
      data: '2024-07-18',
      hora: '14:30',
      local: 'TJSP - 2ª Vara Empresarial',
      status: 'Hoje',
      advogado: 'Dra. Maria Santos'
    },
    {
      id: 3,
      processo: '3003456-78.2024.8.26.0003',
      cliente: 'Maria Oliveira Costa',
      tipo: 'Audiência Preliminar',
      data: '2024-07-18',
      hora: '16:00',
      local: 'TJSP - 3ª Vara Família',
      status: 'Hoje',
      advogado: 'Dr. Pedro Costa'
    }
  ];

  useEffect(() => {
    // Simular carregamento seguindo padrão
    setTimeout(() => {
      setAudiencias(mockAudiencias);
      setLoading(false);
    }, 1000);
  }, []);

  // Estatísticas
  const stats = [
    {
      name: 'Audiências Hoje',
      value: audiencias.length.toString(),
      change: '+2',
      changeType: 'increase',
      icon: CalendarIcon,
      color: 'green',
      description: 'Agendadas para hoje'
    },
    {
      name: 'Próximas 2h',
      value: '1',
      change: '0',
      changeType: 'neutral',
      icon: ClockIcon,
      color: 'yellow',
      description: 'Audiência às 14:30'
    },
    {
      name: 'Em Andamento',
      value: '0',
      change: '0',
      changeType: 'neutral',
      icon: UserIcon,
      color: 'blue',
      description: 'Nenhuma em andamento'
    },
    {
      name: 'Concluídas',
      value: '0',
      change: '0',
      changeType: 'neutral',
      icon: ScaleIcon,
      color: 'purple',
      description: 'Concluídas hoje'
    }
  ];

  const getStatusColor = (status) => {
    switch (status) {
      case 'Hoje': return 'bg-green-100 text-green-800';
      case 'Amanhã': return 'bg-blue-100 text-blue-800';
      case 'Em andamento': return 'bg-yellow-100 text-yellow-800';
      case 'Concluída': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="bg-white rounded-lg shadow-sm p-6 animate-pulse">
          <div className="h-6 bg-gray-200 rounded w-1/4 mb-4"></div>
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
      {/* Header seguindo padrão */}
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
              <h1 className="text-3xl font-bold text-gray-900">Audiências de Hoje</h1>
              <p className="text-lg text-gray-600 mt-2">Audiências agendadas para hoje - {new Date().toLocaleDateString('pt-BR')}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Stats Cards seguindo padrão Dashboard */}
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
                  item.changeType === 'increase' ? 'text-green-600' : 'text-gray-600'
                }`}>
                  {item.changeType === 'increase' && (
                    <ArrowUpIcon className="h-4 w-4 mr-1" />
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

      {/* Lista de Audiências */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Lista de Audiências</h2>
          <div className="flex items-center space-x-4">
            <span className="text-sm text-gray-500">
              {audiencias.length} audiência(s) hoje
            </span>
            <EyeIcon className="h-5 w-5 text-gray-400" />
          </div>
        </div>

        {audiencias.length > 0 ? (
          <div className="space-y-4">
            {audiencias.map((audiencia) => (
              <div key={audiencia.id} className="border border-gray-200 rounded-lg p-6 hover:bg-gray-50 transition-colors">
                <div className="flex items-start justify-between">
                  <div className="flex items-start space-x-4">
                    <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                      <CalendarIcon className="w-6 h-6 text-green-600" />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center justify-between mb-2">
                        <h3 className="text-lg font-semibold text-gray-900">{audiencia.tipo}</h3>
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(audiencia.status)}`}>
                          {audiencia.status}
                        </span>
                      </div>
                      
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
                        <div>
                          <p className="flex items-center mb-1">
                            <ScaleIcon className="w-4 h-4 mr-2" />
                            <strong>Processo:</strong> {audiencia.processo}
                          </p>
                          <p className="flex items-center mb-1">
                            <UserIcon className="w-4 h-4 mr-2" />
                            <strong>Cliente:</strong> {audiencia.cliente}
                          </p>
                          <p className="flex items-center">
                            <UserIcon className="w-4 h-4 mr-2" />
                            <strong>Advogado:</strong> {audiencia.advogado}
                          </p>
                        </div>
                        <div>
                          <p className="flex items-center mb-1">
                            <ClockIcon className="w-4 h-4 mr-2" />
                            <strong>Horário:</strong> {audiencia.hora}
                          </p>
                          <p className="flex items-center mb-1">
                            <CalendarIcon className="w-4 h-4 mr-2" />
                            <strong>Data:</strong> {new Date(audiencia.data).toLocaleDateString('pt-BR')}
                          </p>
                          <p className="flex items-center">
                            <MapPinIcon className="w-4 h-4 mr-2" />
                            <strong>Local:</strong> {audiencia.local}
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <CalendarIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhuma audiência hoje</h3>
            <p className="mt-1 text-sm text-gray-500">
              Não há audiências agendadas para hoje.
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default Audiencias;
EOF

echo "✅ Audiências criada!"

echo "📁 2. Criando página de Prazos..."

# Criar página de Prazos seguindo padrão do projeto
cat > frontend/src/pages/admin/Prazos.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  ExclamationTriangleIcon,
  ClockIcon,
  ScaleIcon,
  UserIcon,
  CalendarIcon,
  ArrowUpIcon,
  EyeIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline';

const Prazos = () => {
  const [prazos, setPrazos] = useState([]);
  const [loading, setLoading] = useState(true);

  // Mock data seguindo padrão do projeto
  const mockPrazos = [
    {
      id: 1,
      processo: '1001234-56.2024.8.26.0001',
      cliente: 'João Silva Santos',
      descricao: 'Petição Inicial',
      prazo: '2024-07-18',
      prioridade: 'Urgente',
      status: 'Vence Hoje',
      advogado: 'Dr. Carlos Oliveira',
      diasRestantes: 0
    },
    {
      id: 2,
      processo: '2002345-67.2024.8.26.0002',
      cliente: 'Empresa ABC Ltda',
      descricao: 'Contestação',
      prazo: '2024-07-19',
      prioridade: 'Alta',
      status: 'Vence Amanhã',
      advogado: 'Dra. Maria Santos',
      diasRestantes: 1
    },
    {
      id: 3,
      processo: '3003456-78.2024.8.26.0003',
      cliente: 'Maria Oliveira Costa',
      descricao: 'Recurso Ordinário',
      prazo: '2024-07-20',
      prioridade: 'Normal',
      status: 'Próximos Dias',
      advogado: 'Dr. Pedro Costa',
      diasRestantes: 2
    },
    {
      id: 4,
      processo: '4004567-89.2024.8.26.0004',
      cliente: 'Tech Solutions S.A.',
      descricao: 'Tréplica',
      prazo: '2024-07-22',
      prioridade: 'Normal',
      status: 'Próximos Dias',
      advogado: 'Dra. Ana Silva',
      diasRestantes: 4
    }
  ];

  useEffect(() => {
    // Simular carregamento seguindo padrão
    setTimeout(() => {
      setPrazos(mockPrazos);
      setLoading(false);
    }, 1000);
  }, []);

  // Estatísticas
  const stats = [
    {
      name: 'Vencendo Hoje',
      value: prazos.filter(p => p.diasRestantes === 0).length.toString(),
      change: '+1',
      changeType: 'increase',
      icon: ExclamationTriangleIcon,
      color: 'red',
      description: 'Atenção imediata'
    },
    {
      name: 'Vencendo Amanhã',
      value: prazos.filter(p => p.diasRestantes === 1).length.toString(),
      change: '0',
      changeType: 'neutral',
      icon: ClockIcon,
      color: 'yellow',
      description: 'Preparar documentos'
    },
    {
      name: 'Próximos 7 dias',
      value: prazos.filter(p => p.diasRestantes <= 7).length.toString(),
      change: '+2',
      changeType: 'increase',
      icon: CalendarIcon,
      color: 'blue',
      description: 'Organizar agenda'
    },
    {
      name: 'Total de Prazos',
      value: prazos.length.toString(),
      change: '+3',
      changeType: 'increase',
      icon: ScaleIcon,
      color: 'purple',
      description: 'Em acompanhamento'
    }
  ];

  const getPriorityColor = (prioridade) => {
    switch (prioridade) {
      case 'Urgente': return 'bg-red-100 text-red-800';
      case 'Alta': return 'bg-orange-100 text-orange-800';
      case 'Normal': return 'bg-blue-100 text-blue-800';
      case 'Baixa': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusColor = (diasRestantes) => {
    if (diasRestantes === 0) return 'bg-red-100 text-red-800';
    if (diasRestantes === 1) return 'bg-yellow-100 text-yellow-800';
    if (diasRestantes <= 3) return 'bg-orange-100 text-orange-800';
    return 'bg-blue-100 text-blue-800';
  };

  const getPriorityIcon = (prioridade) => {
    switch (prioridade) {
      case 'Urgente': return ExclamationTriangleIcon;
      case 'Alta': return ClockIcon;
      case 'Normal': return CheckCircleIcon;
      default: return CheckCircleIcon;
    }
  };

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="bg-white rounded-lg shadow-sm p-6 animate-pulse">
          <div className="h-6 bg-gray-200 rounded w-1/4 mb-4"></div>
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
      {/* Header seguindo padrão */}
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
              <h1 className="text-3xl font-bold text-gray-900">Prazos Vencendo</h1>
              <p className="text-lg text-gray-600 mt-2">Prazos que vencem nos próximos dias</p>
            </div>
          </div>
        </div>
      </div>

      {/* Stats Cards seguindo padrão Dashboard */}
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
                  item.changeType === 'increase' ? 'text-green-600' : 'text-gray-600'
                }`}>
                  {item.changeType === 'increase' && (
                    <ArrowUpIcon className="h-4 w-4 mr-1" />
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

      {/* Lista de Prazos */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Lista de Prazos</h2>
          <div className="flex items-center space-x-4">
            <span className="text-sm text-gray-500">
              {prazos.length} prazo(s) em acompanhamento
            </span>
            <EyeIcon className="h-5 w-5 text-gray-400" />
          </div>
        </div>

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
                  Descrição
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Prazo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Prioridade
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Advogado
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {prazos.map((prazo) => {
                const PriorityIcon = getPriorityIcon(prazo.prioridade);
                return (
                  <tr key={prazo.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <ScaleIcon className="w-5 h-5 text-primary-600 mr-2" />
                        <span className="text-sm font-medium text-gray-900">
                          {prazo.processo}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <UserIcon className="w-4 h-4 text-gray-400 mr-2" />
                        <span className="text-sm text-gray-900">{prazo.cliente}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {prazo.descricao}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <ClockIcon className="w-4 h-4 text-red-500 mr-2" />
                        <div>
                          <div className="text-sm text-gray-900">
                            {new Date(prazo.prazo).toLocaleDateString('pt-BR')}
                          </div>
                          <div className={`text-xs px-2 py-1 rounded-full inline-flex ${getStatusColor(prazo.diasRestantes)}`}>
                            {prazo.diasRestantes === 0 ? 'Hoje' : 
                             prazo.diasRestantes === 1 ? 'Amanhã' : 
                             `${prazo.diasRestantes} dias`}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(prazo.prioridade)}`}>
                        <PriorityIcon className="w-3 h-3 mr-1" />
                        {prazo.prioridade}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {prazo.advogado}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {prazos.length === 0 && (
          <div className="text-center py-12">
            <ClockIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum prazo vencendo</h3>
            <p className="mt-1 text-sm text-gray-500">
              Não há prazos vencendo nos próximos dias.
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default Prazos;
EOF

echo "✅ Prazos criada!"

echo ""
echo "✅ TELAS CRIADAS (Parte 2/3)!"
echo ""
echo "📅 AUDIÊNCIAS:"
echo "   • Dashboard com estatísticas"
echo "   • Lista de audiências de hoje"
echo "   • Cards com informações completas"
echo "   • Status e horários"
echo ""
echo "⏰ PRAZOS:"
echo "   • Dashboard com prazos vencendo"
echo "   • Tabela com prioridades"
echo "   • Cores por urgência"
echo "   • Contagem de dias restantes"
echo ""
echo "🔗 ROTAS:"
echo "   • /admin/audiencias"
echo "   • /admin/prazos"
echo ""
echo "⏭️ Execute o script e digite 'continuar' para Parte 3: Relatórios e Rotas no App.js"