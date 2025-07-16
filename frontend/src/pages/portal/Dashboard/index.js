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
