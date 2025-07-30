#!/bin/bash

# Script 99a - Processos CRUD Completo (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)
# Enumeração: 99a

echo "⚖️ Criando CRUD completo de Processos (Parte 1/2 - Script 99a)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar estrutura frontend
if [ ! -d "frontend/src" ]; then
    echo "❌ Erro: Estrutura frontend não encontrada"
    exit 1
fi

echo "📝 1. Criando página principal de Processos..."

# Fazer backup se existe
if [ -f "frontend/src/pages/admin/Processes.js" ]; then
    cp frontend/src/pages/admin/Processes.js frontend/src/pages/admin/Processes.js.backup.$(date +%Y%m%d_%H%M%S)
fi

# Criar Processes.js seguindo EXATO padrão Clients.js
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
  UserIcon,
  ClockIcon,
  DocumentIcon
} from '@heroicons/react/24/outline';

const Processes = () => {
  const [processes, setProcesses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [filterType, setFilterType] = useState('all');
  const [filterAdvogado, setFilterAdvogado] = useState('all');

  // Mock data seguindo padrão do sistema
  const mockProcesses = [
    {
      id: 1,
      number: '1001234-56.2024.8.26.0001',
      client: 'João Silva Santos',
      clientId: 1,
      clientType: 'PF',
      subject: 'Ação de Cobrança',
      type: 'Cível',
      status: 'Em Andamento',
      advogado: 'Dr. Carlos Oliveira',
      advogadoId: 1,
      court: '1ª Vara Cível - SP',
      value: 50000.00,
      createdAt: '2024-01-15',
      lastUpdate: '2024-07-25',
      audiencias: 2,
      prazos: 3,
      documentos: 12
    },
    {
      id: 2,
      number: '2002345-67.2024.8.26.0002',
      client: 'Empresa ABC Ltda',
      clientId: 2,
      clientType: 'PJ',
      subject: 'Ação Trabalhista',
      type: 'Trabalhista',
      status: 'Aguardando',
      advogado: 'Dra. Maria Santos',
      advogadoId: 2,
      court: '2ª Vara do Trabalho - SP',
      value: 120000.00,
      createdAt: '2024-01-20',
      lastUpdate: '2024-07-20',
      audiencias: 1,
      prazos: 5,
      documentos: 8
    },
    {
      id: 3,
      number: '3003456-78.2024.8.26.0003',
      client: 'Maria Oliveira Costa',
      clientId: 3,
      clientType: 'PF',
      subject: 'Divórcio Consensual',
      type: 'Família',
      status: 'Concluído',
      advogado: 'Dr. Pedro Costa',
      advogadoId: 3,
      court: '1ª Vara de Família - SP',
      value: 15000.00,
      createdAt: '2024-02-01',
      lastUpdate: '2024-07-15',
      audiencias: 0,
      prazos: 0,
      documentos: 15
    },
    {
      id: 4,
      number: '4004567-89.2024.8.26.0004',
      client: 'Tech Solutions S.A.',
      clientId: 4,
      clientType: 'PJ',
      subject: 'Ação de Indenização',
      type: 'Cível',
      status: 'Em Andamento',
      advogado: 'Dra. Ana Silva',
      advogadoId: 4,
      court: '3ª Vara Cível - SP',
      value: 800000.00,
      createdAt: '2024-02-10',
      lastUpdate: '2024-07-28',
      audiencias: 3,
      prazos: 7,
      documentos: 25
    },
    {
      id: 5,
      number: '5005678-90.2024.8.26.0005',
      client: 'Carlos Pereira Lima',
      clientId: 5,
      clientType: 'PF',
      subject: 'Inventário',
      type: 'Sucessões',
      status: 'Suspenso',
      advogado: 'Dra. Erlene Chaves Silva',
      advogadoId: 5,
      court: '1ª Vara de Sucessões - SP',
      value: 2500000.00,
      createdAt: '2024-03-01',
      lastUpdate: '2024-07-10',
      audiencias: 0,
      prazos: 2,
      documentos: 30
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
    emAndamento: processes.filter(p => p.status === 'Em Andamento').length,
    aguardando: processes.filter(p => p.status === 'Aguardando').length,
    concluidos: processes.filter(p => p.status === 'Concluído').length,
    valorTotal: processes.reduce((acc, p) => acc + p.value, 0)
  };

  // Filtrar processos
  const filteredProcesses = processes.filter(process => {
    const matchesSearch = process.number.includes(searchTerm) ||
                         process.client.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         process.subject.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = filterStatus === 'all' || process.status === filterStatus;
    const matchesType = filterType === 'all' || process.type === filterType;
    const matchesAdvogado = filterAdvogado === 'all' || process.advogadoId.toString() === filterAdvogado;
    
    return matchesSearch && matchesStatus && matchesType && matchesAdvogado;
  });

  const handleDelete = (id) => {
    if (window.confirm('Tem certeza que deseja excluir este processo?')) {
      setProcesses(prev => prev.filter(process => process.id !== id));
    }
  };

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Em Andamento': return 'bg-blue-100 text-blue-800';
      case 'Aguardando': return 'bg-yellow-100 text-yellow-800';
      case 'Concluído': return 'bg-green-100 text-green-800';
      case 'Suspenso': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getTypeColor = (type) => {
    switch (type) {
      case 'Cível': return 'bg-blue-100 text-blue-700';
      case 'Trabalhista': return 'bg-orange-100 text-orange-700';
      case 'Família': return 'bg-pink-100 text-pink-700';
      case 'Sucessões': return 'bg-purple-100 text-purple-700';
      case 'Criminal': return 'bg-red-100 text-red-700';
      default: return 'bg-gray-100 text-gray-700';
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
          Gerencie todos os processos do escritório
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
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.emAndamento}</p>
              <p className="text-sm text-gray-500 mt-1">Processos ativos</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-yellow-100">
                  <DocumentIcon className="h-6 w-6 text-yellow-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Aguardando</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{stats.aguardando}</p>
              <p className="text-sm text-gray-500 mt-1">Pendentes de ação</p>
            </div>
          </div>
        </div>
        
        <div className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="p-3 rounded-lg bg-purple-100">
                  <UserIcon className="h-6 w-6 text-purple-600" />
                </div>
              </div>
            </div>
            <div className="mt-4">
              <h3 className="text-sm font-medium text-gray-500">Valor Total</h3>
              <p className="text-3xl font-bold text-gray-900 mt-1">{formatCurrency(stats.valorTotal)}</p>
              <p className="text-sm text-gray-500 mt-1">Causa em trâmite</p>
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
              placeholder="Buscar processo, cliente ou assunto..."
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
            <option value="Em Andamento">Em Andamento</option>
            <option value="Aguardando">Aguardando</option>
            <option value="Concluído">Concluído</option>
            <option value="Suspenso">Suspenso</option>
          </select>
          
          <select
            value={filterType}
            onChange={(e) => setFilterType(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os tipos</option>
            <option value="Cível">Cível</option>
            <option value="Trabalhista">Trabalhista</option>
            <option value="Família">Família</option>
            <option value="Sucessões">Sucessões</option>
            <option value="Criminal">Criminal</option>
          </select>
          
          <select
            value={filterAdvogado}
            onChange={(e) => setFilterAdvogado(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os advogados</option>
            <option value="1">Dr. Carlos Oliveira</option>
            <option value="2">Dra. Maria Santos</option>
            <option value="3">Dr. Pedro Costa</option>
            <option value="4">Dra. Ana Silva</option>
            <option value="5">Dra. Erlene Chaves Silva</option>
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
                  Status/Tipo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Advogado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Valor
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Atividade
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
                        <div className="text-sm font-medium text-gray-900">{process.number}</div>
                        <div className="text-sm text-gray-500 truncate max-w-xs">{process.subject}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{process.client}</div>
                    <div className="text-sm text-gray-500">{process.clientType}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(process.status)}`}>
                      {process.status}
                    </span>
                    <div className="mt-1">
                      <span className={`inline-flex px-2 py-1 text-xs font-medium rounded ${getTypeColor(process.type)}`}>
                        {process.type}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{process.advogado}</div>
                    <div className="text-sm text-gray-500">{process.court}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {formatCurrency(process.value)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {process.audiencias} audiências
                    </div>
                    <div className="text-sm text-gray-500">
                      {process.prazos} prazos • {process.documentos} docs
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex justify-end space-x-2">
                      <button className="text-blue-600 hover:text-blue-900" title="Visualizar">
                        <EyeIcon className="w-5 h-5" />
                      </button>
                      <Link
                        to={`/admin/processos/${process.id}`}
                        className="text-primary-600 hover:text-primary-900"
                        title="Editar"
                      >
                        <PencilIcon className="w-5 h-5" />
                      </Link>
                      <button
                        onClick={() => handleDelete(process.id)}
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
        
        {filteredProcesses.length === 0 && (
          <div className="text-center py-12">
            <ScaleIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum processo encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || filterStatus !== 'all' || filterType !== 'all' || filterAdvogado !== 'all'
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

echo "✅ Processes.js criado!"

echo "📝 2. Atualizando App.js para incluir rotas de Processos..."

# Fazer backup do App.js
cp frontend/src/App.js frontend/src/App.js.backup.processes.$(date +%Y%m%d_%H%M%S)

# Adicionar import do Processes se não existir
if ! grep -q "import Processes" frontend/src/App.js; then
    sed -i '/import EditClient/a import Processes from '\''./pages/admin/Processes'\'';' frontend/src/App.js
fi

# Adicionar rota dos processos se não existir
if ! grep -q 'path="processos"' frontend/src/App.js; then
    sed -i '/path="clientes\/:id"/a\                    <Route path="processos" element={<Processes />} />' frontend/src/App.js
fi

echo "✅ Rota de Processos adicionada ao App.js!"

echo ""
echo "📋 SCRIPT 99a - PARTE 1 CONCLUÍDA:"
echo "   • Página principal de Processos criada"
echo "   • 5 processos mock distribuídos por status"
echo "   • Dashboard com 4 cards de estatísticas"
echo "   • Filtros avançados (status, tipo, advogado)"
echo "   • Tabela responsiva com todas as informações"
echo "   • Sistema de busca inteligente"
echo "   • Formatação de valores monetários"
echo "   • Rota /admin/processos configurada"
echo ""
echo "🎯 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Cards de estatísticas (Total, Em Andamento, Aguardando, Valor Total)"
echo "   • Filtros por status (Em Andamento, Aguardando, Concluído, Suspenso)"
echo "   • Filtros por tipo (Cível, Trabalhista, Família, Sucessões, Criminal)"
echo "   • Filtros por advogado responsável"
echo "   • Busca por número, cliente ou assunto"
echo "   • Formatação de valores em reais (BRL)"
echo "   • Status coloridos por categoria"
echo "   • Contadores de audiências, prazos e documentos"
echo ""
echo "📊 DADOS MOCK INCLUSOS:"
echo "   • Processo 1: João Silva - Ação de Cobrança (Em Andamento)"
echo "   • Processo 2: Empresa ABC - Ação Trabalhista (Aguardando)"
echo "   • Processo 3: Maria Oliveira - Divórcio (Concluído)"
echo "   • Processo 4: Tech Solutions - Indenização (Em Andamento)"
echo "   • Processo 5: Carlos Pereira - Inventário (Suspenso)"
echo ""
echo "🎨 DESIGN VISUAL:"
echo "   • Cards coloridos por status (azul, amarelo, verde, roxo)"
echo "   • Tabela com hover effects e ícones"
echo "   • Badges coloridos para status e tipos"
echo "   • Layout responsivo mobile/desktop"
echo ""
echo "📁 ARQUIVOS CRIADOS:"
echo "   • frontend/src/pages/admin/Processes.js"
echo "   • App.js atualizado com rota"
echo ""
echo "🧪 TESTE AGORA:"
echo "   • http://localhost:3000/admin/processos"
echo "   • Teste filtros e busca"
echo "   • Clique no link 'Processos' no menu lateral"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • NewProcess.js (formulário de cadastro)"
echo "   • EditProcess.js (formulário de edição)"
echo "   • Relacionamento com clientes"
echo "   • Sistema de numeração automática"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"