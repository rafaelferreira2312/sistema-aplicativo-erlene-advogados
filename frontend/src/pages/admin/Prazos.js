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
