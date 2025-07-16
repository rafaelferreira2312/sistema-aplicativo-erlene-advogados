#!/bin/bash

# Script 36 - Páginas Principais
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/36-create-main-pages.sh

echo "📄 Criando páginas principais..."

# src/pages/admin/Dashboard/index.js
cat > frontend/src/pages/admin/Dashboard/index.js << 'EOF'
import React from 'react';
import { 
  UsersIcon, 
  ScaleIcon, 
  CurrencyDollarIcon,
  CalendarIcon,
  TrendingUpIcon,
  ArrowUpIcon,
  ArrowDownIcon
} from '@heroicons/react/24/outline';
import Card from '../../../components/common/Card';
import Badge from '../../../components/common/Badge';

const Dashboard = () => {
  // Mock data - substituir por dados reais da API
  const stats = [
    {
      name: 'Total de Clientes',
      value: '1,247',
      change: '+12%',
      changeType: 'increase',
      icon: UsersIcon,
    },
    {
      name: 'Processos Ativos',
      value: '891',
      change: '+8%',
      changeType: 'increase',
      icon: ScaleIcon,
    },
    {
      name: 'Receita Mensal',
      value: 'R$ 125.847',
      change: '+23%',
      changeType: 'increase',
      icon: CurrencyDollarIcon,
    },
    {
      name: 'Atendimentos Hoje',
      value: '14',
      change: '-2%',
      changeType: 'decrease',
      icon: CalendarIcon,
    },
  ];

  const recentActivities = [
    {
      id: 1,
      type: 'process',
      title: 'Novo processo cadastrado',
      description: 'Processo 1234567-89.2024.8.02.0001 para Maria Silva',
      time: '2 minutos atrás',
      status: 'new'
    },
    {
      id: 2,
      type: 'appointment',
      title: 'Atendimento concluído',
      description: 'Consulta com João Santos finalizada',
      time: '15 minutos atrás',
      status: 'completed'
    },
    {
      id: 3,
      type: 'payment',
      title: 'Pagamento recebido',
      description: 'R$ 2.500,00 de honorários - Cliente Ana Costa',
      time: '1 hora atrás',
      status: 'success'
    },
    {
      id: 4,
      type: 'document',
      title: 'Documento anexado',
      description: 'Contrato social anexado ao processo 9876543-21',
      time: '2 horas atrás',
      status: 'info'
    },
  ];

  const upcomingAppointments = [
    {
      id: 1,
      client: 'Maria Oliveira',
      time: '14:00',
      type: 'Presencial',
      subject: 'Revisão de contrato'
    },
    {
      id: 2,
      client: 'João Santos',
      time: '15:30',
      type: 'Online',
      subject: 'Acompanhamento processual'
    },
    {
      id: 3,
      client: 'Ana Costa',
      time: '16:00',
      type: 'Telefone',
      subject: 'Orientação jurídica'
    },
  ];

  return (
    <div className="space-y-6">
      {/* Welcome */}
      <div>
        <h2 className="text-2xl font-bold text-gray-900">
          Bem-vindo ao Sistema Erlene Advogados
        </h2>
        <p className="mt-1 text-gray-600">
          Aqui está um resumo das atividades do seu escritório hoje.
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((item) => (
          <Card key={item.name} className="overflow-hidden">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <item.icon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">
                      {item.name}
                    </dt>
                    <dd className="flex items-baseline">
                      <div className="text-2xl font-semibold text-gray-900">
                        {item.value}
                      </div>
                      <div className={`ml-2 flex items-baseline text-sm font-semibold ${
                        item.changeType === 'increase' ? 'text-green-600' : 'text-red-600'
                      }`}>
                        {item.changeType === 'increase' ? (
                          <ArrowUpIcon className="h-3 w-3 flex-shrink-0 self-center" />
                        ) : (
                          <ArrowDownIcon className="h-3 w-3 flex-shrink-0 self-center" />
                        )}
                        <span className="sr-only">
                          {item.changeType === 'increase' ? 'Increased' : 'Decreased'} by
                        </span>
                        {item.change}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 gap-5 lg:grid-cols-2">
        {/* Recent Activities */}
        <Card 
          title="Atividades Recentes"
          actions={
            <button className="text-sm text-primary-600 hover:text-primary-900">
              Ver todas
            </button>
          }
        >
          <div className="flow-root">
            <ul className="-my-5 divide-y divide-gray-200">
              {recentActivities.map((activity) => (
                <li key={activity.id} className="py-5">
                  <div className="flex items-center space-x-4">
                    <div className="flex-shrink-0">
                      <Badge 
                        variant={
                          activity.status === 'new' ? 'info' :
                          activity.status === 'completed' ? 'success' :
                          activity.status === 'success' ? 'success' : 'default'
                        }
                        size="small"
                      >
                        {activity.type}
                      </Badge>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {activity.title}
                      </p>
                      <p className="text-sm text-gray-500 truncate">
                        {activity.description}
                      </p>
                    </div>
                    <div className="flex-shrink-0 text-sm text-gray-500">
                      {activity.time}
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        </Card>

        {/* Upcoming Appointments */}
        <Card 
          title="Próximos Atendimentos"
          subtitle="Hoje"
          actions={
            <button className="text-sm text-primary-600 hover:text-primary-900">
              Ver agenda
            </button>
          }
        >
          <div className="space-y-4">
            {upcomingAppointments.map((appointment) => (
              <div key={appointment.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                <div className="flex items-center space-x-3">
                  <div className="flex-shrink-0">
                    <div className="w-2 h-2 bg-primary-600 rounded-full"></div>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      {appointment.client}
                    </p>
                    <p className="text-sm text-gray-500">
                      {appointment.subject}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-sm font-medium text-gray-900">
                    {appointment.time}
                  </p>
                  <Badge variant="outline" size="small">
                    {appointment.type}
                  </Badge>
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Quick Actions */}
      <Card title="Ações Rápidas">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors">
            <UsersIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Novo Cliente</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors">
            <ScaleIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Novo Processo</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors">
            <CalendarIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Agendar Atendimento</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors">
            <TrendingUpIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Ver Relatórios</span>
          </button>
        </div>
      </Card>
    </div>
  );
};

export default Dashboard;
EOF

# src/pages/admin/Clients/index.js
cat > frontend/src/pages/admin/Clients/index.js << 'EOF'
import React, { useState } from 'react';
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  FunnelIcon,
  DocumentArrowDownIcon
} from '@heroicons/react/24/outline';
import Card from '../../../components/common/Card';
import Button from '../../../components/common/Button';
import Input from '../../../components/common/Input';
import Table from '../../../components/common/Table';
import Badge from '../../../components/common/Badge';

const Clients = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [sortBy, setSortBy] = useState('nome');
  const [sortDirection, setSortDirection] = useState('asc');

  // Mock data - substituir por dados reais da API
  const clients = [
    {
      id: 1,
      nome: 'Maria Silva Santos',
      email: 'maria.silva@email.com',
      telefone: '(11) 99999-1234',
      cpf_cnpj: '123.456.789-00',
      tipo_pessoa: 'PF',
      status: 'ativo',
      processos_count: 3,
      created_at: '2024-01-15'
    },
    {
      id: 2,
      nome: 'Empresa ABC Ltda',
      email: 'contato@empresaabc.com.br',
      telefone: '(11) 3333-5555',
      cpf_cnpj: '12.345.678/0001-90',
      tipo_pessoa: 'PJ',
      status: 'ativo',
      processos_count: 1,
      created_at: '2024-02-20'
    },
    {
      id: 3,
      nome: 'João Carlos Oliveira',
      email: 'joao.oliveira@email.com',
      telefone: '(11) 88888-4321',
      cpf_cnpj: '987.654.321-00',
      tipo_pessoa: 'PF',
      status: 'inativo',
      processos_count: 0,
      created_at: '2024-01-30'
    },
  ];

  const columns = [
    {
      key: 'nome',
      title: 'Nome/Razão Social',
      sortable: true,
      render: (client) => (
        <div>
          <div className="font-medium text-gray-900">{client.nome}</div>
          <div className="text-sm text-gray-500">{client.email}</div>
        </div>
      )
    },
    {
      key: 'cpf_cnpj',
      title: 'CPF/CNPJ',
      sortable: true,
      render: (client) => (
        <div>
          <div className="text-gray-900">{client.cpf_cnpj}</div>
          <Badge 
            variant={client.tipo_pessoa === 'PF' ? 'info' : 'secondary'} 
            size="small"
          >
            {client.tipo_pessoa}
          </Badge>
        </div>
      )
    },
    {
      key: 'telefone',
      title: 'Telefone',
      sortable: false,
    },
    {
      key: 'processos_count',
      title: 'Processos',
      sortable: true,
      render: (client) => (
        <Badge variant="default">
          {client.processos_count}
        </Badge>
      )
    },
    {
      key: 'status',
      title: 'Status',
      sortable: true,
      render: (client) => (
        <Badge 
          variant={client.status === 'ativo' ? 'success' : 'danger'}
        >
          {client.status}
        </Badge>
      )
    },
    {
      key: 'actions',
      title: 'Ações',
      sortable: false,
      render: (client) => (
        <div className="flex space-x-2">
          <Button variant="ghost" size="small">
            Ver
          </Button>
          <Button variant="ghost" size="small">
            Editar
          </Button>
        </div>
      )
    },
  ];

  const handleSort = (key, direction) => {
    setSortBy(key);
    setSortDirection(direction);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Clientes</h1>
          <p className="mt-1 text-gray-600">
            Gerencie todos os clientes do escritório
          </p>
        </div>
        <div className="mt-4 sm:mt-0">
          <Button 
            variant="primary" 
            icon={PlusIcon}
            iconPosition="left"
          >
            Novo Cliente
          </Button>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="md:col-span-2">
            <Input
              placeholder="Buscar por nome, email ou CPF/CNPJ..."
              icon={MagnifyingGlassIcon}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <div>
            <select className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500">
              <option value="">Todos os tipos</option>
              <option value="PF">Pessoa Física</option>
              <option value="PJ">Pessoa Jurídica</option>
            </select>
          </div>
          <div className="flex space-x-2">
            <Button variant="outline" icon={FunnelIcon} className="flex-1">
              Filtros
            </Button>
            <Button variant="outline" icon={DocumentArrowDownIcon}>
              Exportar
            </Button>
          </div>
        </div>
      </Card>

      {/* Table */}
      <Card>
        <Table
          data={clients}
          columns={columns}
          sortBy={sortBy}
          sortDirection={sortDirection}
          onSort={handleSort}
          emptyMessage="Nenhum cliente encontrado"
        />
        
        {/* Pagination */}
        <div className="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6">
          <div className="flex flex-1 justify-between sm:hidden">
            <Button variant="outline">Anterior</Button>
            <Button variant="outline">Próximo</Button>
          </div>
          <div className="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
            <div>
              <p className="text-sm text-gray-700">
                Mostrando <span className="font-medium">1</span> a{' '}
                <span className="font-medium">3</span> de{' '}
                <span className="font-medium">3</span> resultados
              </p>
            </div>
            <div>
              <nav className="isolate inline-flex -space-x-px rounded-md shadow-sm">
                <Button variant="outline" size="small">
                  Anterior
                </Button>
                <Button variant="outline" size="small" className="bg-primary-50 border-primary-500 text-primary-600">
                  1
                </Button>
                <Button variant="outline" size="small">
                  Próximo
                </Button>
              </nav>
            </div>
          </div>
        </div>
      </Card>
    </div>
  );
};

export default Clients;
EOF

# src/pages/portal/Dashboard/index.js
cat > frontend/src/pages/portal/Dashboard/index.js << 'EOF'
import React from 'react';
import { 
  ScaleIcon, 
  DocumentIcon, 
  CreditCardIcon,
  ClockIcon,
  CheckCircleIcon,
  ExclamationTriangleIcon
} from '@heroicons/react/24/outline';
import Card from '../../../components/common/Card';
import Badge from '../../../components/common/Badge';
import { useAuth } from '../../../hooks/auth/useAuth';

const PortalDashboard = () => {
  const { user } = useAuth();

  // Mock data - substituir por dados reais da API
  const stats = [
    {
      name: 'Processos Ativos',
      value: '3',
      icon: ScaleIcon,
      color: 'text-blue-600'
    },
    {
      name: 'Documentos',
      value: '12',
      icon: DocumentIcon,
      color: 'text-green-600'
    },
    {
      name: 'Pagamentos Pendentes',
      value: '1',
      icon: CreditCardIcon,
      color: 'text-yellow-600'
    },
  ];

  const processes = [
    {
      id: 1,
      numero: '1234567-89.2024.8.02.0001',
      assunto: 'Ação de Cobrança',
      status: 'em_andamento',
      ultima_movimentacao: '2024-03-15',
      proxima_audiencia: '2024-04-20'
    },
    {
      id: 2,
      numero: '9876543-21.2024.8.02.0002',
      assunto: 'Revisão Contratual',
      status: 'distribuido',
      ultima_movimentacao: '2024-03-10',
      proxima_audiencia: null
    },
    {
      id: 3,
      numero: '5555555-55.2024.8.02.0003',
      assunto: 'Ação Trabalhista',
      status: 'sentenca',
      ultima_movimentacao: '2024-03-12',
      proxima_audiencia: null
    },
  ];

  const recentMessages = [
    {
      id: 1,
      from: 'Dr. João Advogado',
      subject: 'Atualização do processo 1234567-89',
      preview: 'Informamos que houve nova movimentação no seu processo...',
      date: '2024-03-15',
      read: false
    },
    {
      id: 2,
      from: 'Sistema Erlene',
      subject: 'Lembrete: Pagamento pendente',
      preview: 'Você possui um pagamento pendente no valor de R$ 1.500,00...',
      date: '2024-03-14',
      read: true
    },
  ];

  const getStatusColor = (status) => {
    switch (status) {
      case 'distribuido': return 'info';
      case 'em_andamento': return 'warning';
      case 'sentenca': return 'success';
      default: return 'default';
    }
  };

  const getStatusLabel = (status) => {
    switch (status) {
      case 'distribuido': return 'Distribuído';
      case 'em_andamento': return 'Em Andamento';
      case 'sentenca': return 'Sentença';
      default: return status;
    }
  };

  return (
    <div className="space-y-6">
      {/* Welcome */}
      <div className="bg-gradient-erlene rounded-lg p-6 text-white">
        <h1 className="text-2xl font-bold">
          Bem-vindo, {user?.nome?.split(' ')[0] || 'Cliente'}!
        </h1>
        <p className="mt-2 opacity-90">
          Acompanhe seus processos, documentos e mantenha-se atualizado sobre seu caso.
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-3">
        {stats.map((item) => (
          <Card key={item.name}>
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <item.icon className={`h-8 w-8 ${item.color}`} />
              </div>
              <div className="ml-4">
                <div className="text-2xl font-bold text-gray-900">
                  {item.value}
                </div>
                <div className="text-sm text-gray-500">
                  {item.name}
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {/* Meus Processos */}
        <Card 
          title="Meus Processos" 
          actions={
            <button className="text-sm text-primary-600 hover:text-primary-900">
              Ver todos
            </button>
          }
        >
          <div className="space-y-4">
            {processes.map((process) => (
              <div key={process.id} className="border border-gray-200 rounded-lg p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h4 className="text-sm font-medium text-gray-900">
                      {process.numero}
                    </h4>
                    <p className="text-sm text-gray-600 mt-1">
                      {process.assunto}
                    </p>
                    <div className="flex items-center mt-2 text-xs text-gray-500">
                      <ClockIcon className="h-4 w-4 mr-1" />
                      Última movimentação: {process.ultima_movimentacao}
                    </div>
                    {process.proxima_audiencia && (
                      <div className="flex items-center mt-1 text-xs text-orange-600">
                        <ExclamationTriangleIcon className="h-4 w-4 mr-1" />
                        Próxima audiência: {process.proxima_audiencia}
                      </div>
                    )}
                  </div>
                  <Badge variant={getStatusColor(process.status)} size="small">
                    {getStatusLabel(process.status)}
                  </Badge>
                </div>
              </div>
            ))}
          </div>
        </Card>

        {/* Mensagens Recentes */}
        <Card 
          title="Mensagens Recentes"
          actions={
            <button className="text-sm text-primary-600 hover:text-primary-900">
              Ver todas
            </button>
          }
        >
          <div className="space-y-4">
            {recentMessages.map((message) => (
              <div key={message.id} className={`p-4 rounded-lg border ${message.read ? 'bg-white border-gray-200' : 'bg-blue-50 border-blue-200'}`}>
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2">
                      <h4 className={`text-sm font-medium ${message.read ? 'text-gray-900' : 'text-blue-900'}`}>
                        {message.from}
                      </h4>
                      {!message.read && (
                        <div className="w-2 h-2 bg-blue-600 rounded-full"></div>
                      )}
                    </div>
                    <p className={`text-sm mt-1 ${message.read ? 'text-gray-600' : 'text-blue-800'}`}>
                      {message.subject}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      {message.preview}
                    </p>
                  </div>
                  <span className="text-xs text-gray-500">
                    {message.date}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Ações Rápidas */}
      <Card title="Ações Rápidas">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors">
            <DocumentIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Ver Documentos</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors">
            <CreditCardIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Pagamentos</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors">
            <ScaleIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Acompanhar Processo</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors">
            <CheckCircleIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Agendar Reunião</span>
          </button>
        </div>
      </Card>
    </div>
  );
};

export default PortalDashboard;
EOF

echo "✅ Páginas principais criadas com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • Dashboard Admin - Visão geral do sistema"
echo "   • Clients - Listagem e gestão de clientes"
echo "   • Portal Dashboard - Dashboard do cliente"
echo ""
echo "📄 RECURSOS INCLUÍDOS:"
echo "   • Cards de estatísticas com ícones"
echo "   • Tabelas responsivas com sorting"
echo "   • Atividades recentes e próximos eventos"
echo "   • Ações rápidas com hover effects"
echo "   • Badges para status e categorias"
echo "   • Filtros e busca integrados"
echo "   • Paginação configurável"
echo "   • Layout responsivo mobile-first"
echo ""
echo "⏭️  Próximo: Hooks customizados e Context providers!"