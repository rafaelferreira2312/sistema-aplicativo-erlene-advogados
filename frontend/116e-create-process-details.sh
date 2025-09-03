#!/bin/bash

# Script 116e - Criar ProcessDetails.js com Dados Reais
# Sistema Erlene Advogados - Remover dados mockados e integrar com backend
# Execução: chmod +x 116e-create-process-details.sh && ./116e-create-process-details.sh
# EXECUTAR DENTRO DA PASTA: frontend/

echo "📋 Script 116e - Criando ProcessDetails.js integrado com backend..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 116e-create-process-details.sh && ./116e-create-process-details.sh"
    exit 1
fi

echo "1️⃣ Verificando estrutura anterior..."

# Verificar se processesService.js existe
if [ ! -f "src/services/processesService.js" ]; then
    echo "❌ Erro: processesService.js não encontrado. Execute scripts anteriores primeiro"
    exit 1
fi

echo "2️⃣ Criando ProcessDetails.js com dados reais do backend..."

# Garantir que diretório existe
mkdir -p src/components/processes

cat > src/components/processes/ProcessDetails.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import { processesService } from '../../services/processesService';
import {
  ArrowLeftIcon,
  ScaleIcon,
  UserIcon,
  DocumentTextIcon,
  CurrencyDollarIcon,
  BuildingLibraryIcon,
  CalendarIcon,
  ClockIcon,
  PencilIcon,
  RefreshIcon,
  DocumentIcon,
  ChatBubbleBottomCenterTextIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  InformationCircleIcon
} from '@heroicons/react/24/outline';

const ProcessDetails = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [process, setProcess] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [syncing, setSyncing] = useState(false);
  const [movements, setMovements] = useState([]);
  const [documents, setDocuments] = useState([]);
  const [appointments, setAppointments] = useState([]);

  useEffect(() => {
    loadProcessDetails();
  }, [id]);

  const loadProcessDetails = async () => {
    try {
      setLoading(true);
      setError(null);

      // Carregar detalhes do processo usando dados reais
      const response = await processesService.getProcess(id);
      
      if (response.success) {
        setProcess(response.data);
        
        // Carregar dados relacionados em paralelo
        Promise.all([
          loadMovements(),
          loadDocuments(),
          loadAppointments()
        ]);
      } else {
        setError('Processo não encontrado');
      }
    } catch (err) {
      console.error('Erro ao carregar processo:', err);
      setError('Erro ao carregar detalhes do processo');
    } finally {
      setLoading(false);
    }
  };

  const loadMovements = async () => {
    try {
      const response = await processesService.getMovements(id);
      if (response.success) {
        setMovements(response.data.data || []);
      }
    } catch (err) {
      console.error('Erro ao carregar movimentações:', err);
    }
  };

  const loadDocuments = async () => {
    try {
      const response = await processesService.getDocuments(id);
      if (response.success) {
        setDocuments(response.data.data || []);
      }
    } catch (err) {
      console.error('Erro ao carregar documentos:', err);
    }
  };

  const loadAppointments = async () => {
    try {
      const response = await processesService.getAppointments(id);
      if (response.success) {
        setAppointments(response.data.data || []);
      }
    } catch (err) {
      console.error('Erro ao carregar atendimentos:', err);
    }
  };

  const handleSyncCNJ = async () => {
    try {
      setSyncing(true);
      const response = await processesService.syncWithCNJ(id);
      
      if (response.success) {
        alert(`Sincronização concluída! ${response.data.novas_movimentacoes || 0} novas movimentações`);
        loadProcessDetails();
      } else {
        alert('Erro na sincronização CNJ');
      }
    } catch (error) {
      console.error('Erro na sincronização CNJ:', error);
      alert('Erro na sincronização CNJ');
    } finally {
      setSyncing(false);
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'distribuido': return 'text-blue-600 bg-blue-100';
      case 'em_andamento': return 'text-green-600 bg-green-100';
      case 'suspenso': return 'text-yellow-600 bg-yellow-100';
      case 'arquivado': return 'text-gray-600 bg-gray-100';
      case 'finalizado': return 'text-purple-600 bg-purple-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'urgente': return 'text-red-600 bg-red-100';
      case 'alta': return 'text-orange-600 bg-orange-100';
      case 'media': return 'text-yellow-600 bg-yellow-100';
      case 'baixa': return 'text-green-600 bg-green-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const formatCurrency = (value) => {
    if (!value) return 'N/A';
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  const formatDateTime = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleString('pt-BR');
  };

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="bg-white rounded-xl p-6 animate-pulse">
              <div className="h-6 bg-gray-200 rounded mb-4"></div>
              <div className="h-4 bg-gray-200 rounded"></div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-8">
        <div className="bg-red-50 border border-red-200 rounded-xl p-6">
          <div className="flex items-center">
            <ExclamationTriangleIcon className="w-6 h-6 text-red-600 mr-3" />
            <div>
              <h3 className="text-lg font-medium text-red-900">Erro ao carregar processo</h3>
              <p className="text-red-700 mt-1">{error}</p>
            </div>
          </div>
          <div className="mt-4">
            <Link
              to="/admin/processos"
              className="inline-flex items-center px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              <ArrowLeftIcon className="w-4 h-4 mr-2" />
              Voltar à Lista
            </Link>
          </div>
        </div>
      </div>
    );
  }

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
              <h1 className="text-3xl font-bold text-gray-900">Detalhes do Processo</h1>
              <p className="text-lg text-gray-600 mt-2">{process.numero}</p>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <button
              onClick={handleSyncCNJ}
              disabled={syncing}
              className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors"
              title="Sincronizar com CNJ"
            >
              <RefreshIcon className={`w-5 h-5 ${syncing ? 'animate-spin' : ''}`} />
            </button>
            <Link
              to={`/admin/processos/${id}/editar`}
              className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
            >
              <PencilIcon className="w-4 h-4 mr-2" />
              Editar
            </Link>
          </div>
        </div>
      </div>

      {/* Informações Principais */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Dados Básicos */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Dados Básicos</h3>
          
          <div className="space-y-4">
            <div className="flex items-start space-x-3">
              <UserIcon className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <div className="text-sm font-medium text-gray-900">Cliente</div>
                <div className="text-sm text-gray-600">{process.cliente?.nome || 'N/A'}</div>
                <div className="text-xs text-gray-500">
                  {process.cliente?.tipo_pessoa} - {process.cliente?.cpf_cnpj}
                </div>
              </div>
            </div>

            <div className="flex items-start space-x-3">
              <ScaleIcon className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <div className="text-sm font-medium text-gray-900">Advogado</div>
                <div className="text-sm text-gray-600">{process.advogado?.name || 'Não atribuído'}</div>
              </div>
            </div>

            <div className="flex items-start space-x-3">
              <BuildingLibraryIcon className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <div className="text-sm font-medium text-gray-900">Tribunal</div>
                <div className="text-sm text-gray-600">{process.tribunal || 'N/A'}</div>
                <div className="text-xs text-gray-500">{process.vara || 'Vara não informada'}</div>
              </div>
            </div>

            <div className="flex items-start space-x-3">
              <CurrencyDollarIcon className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <div className="text-sm font-medium text-gray-900">Valor da Causa</div>
                <div className="text-sm text-gray-600">{formatCurrency(process.valor_causa)}</div>
              </div>
            </div>
          </div>
        </div>

        {/* Status e Prazos */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Status e Prazos</h3>
          
          <div className="space-y-4">
            <div>
              <div className="text-sm font-medium text-gray-900 mb-2">Status Atual</div>
              <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getStatusColor(process.status)}`}>
                {process.status}
              </span>
            </div>

            <div>
              <div className="text-sm font-medium text-gray-900 mb-2">Prioridade</div>
              <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getPriorityColor(process.prioridade)}`}>
                {process.prioridade}
              </span>
            </div>

            <div className="flex items-start space-x-3">
              <CalendarIcon className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <div className="text-sm font-medium text-gray-900">Data Distribuição</div>
                <div className="text-sm text-gray-600">{formatDate(process.data_distribuicao)}</div>
              </div>
            </div>

            <div className="flex items-start space-x-3">
              <ClockIcon className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <div className="text-sm font-medium text-gray-900">Última Atualização</div>
                <div className="text-sm text-gray-600">{formatDateTime(process.updated_at)}</div>
              </div>
            </div>
          </div>
        </div>

        {/* Estatísticas */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Estatísticas</h3>
          
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Movimentações</span>
              <span className="text-sm font-medium text-gray-900">{movements.length}</span>
            </div>

            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Documentos</span>
              <span className="text-sm font-medium text-gray-900">{documents.length}</span>
            </div>

            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Atendimentos</span>
              <span className="text-sm font-medium text-gray-900">{appointments.length}</span>
            </div>

            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">CNJ Sync</span>
              <span className={`text-sm font-medium ${process.precisa_sincronizar_cnj ? 'text-yellow-600' : 'text-green-600'}`}>
                {process.precisa_sincronizar_cnj ? 'Pendente' : 'Atualizado'}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Observações */}
      {process.observacoes && (
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Observações</h3>
          <div className="flex items-start space-x-3">
            <InformationCircleIcon className="w-5 h-5 text-blue-500 mt-0.5" />
            <p className="text-gray-700 leading-relaxed">{process.observacoes}</p>
          </div>
        </div>
      )}
EOF

echo "3️⃣ Atualizando App.js para incluir rota ProcessDetails..."

# Criar backup do App.js
cp src/App.js src/App.js.backup.details.$(date +%Y%m%d_%H%M%S)

# Adicionar import do ProcessDetails no App.js
sed -i '/import EditProcess from/a import ProcessDetails from '\''./components/processes/ProcessDetails'\'';' src/App.js

# Adicionar rota do ProcessDetails no App.js (antes da rota de editar)
sed -i '/Route path="processos\/novo"/a \                    <Route path="processos\/:id" element={<ProcessDetails \/>} \/>' src/App.js

echo "4️⃣ Verificando se arquivos foram criados corretamente..."

if [ -f "src/components/processes/ProcessDetails.js" ]; then
    echo "✅ ProcessDetails.js criado com dados reais"
    echo "📊 Linhas do arquivo: $(wc -l < src/components/processes/ProcessDetails.js)"
else
    echo "❌ Erro ao criar ProcessDetails.js"
    exit 1
fi

if grep -q "ProcessDetails" src/App.js; then
    echo "✅ App.js atualizado com rota ProcessDetails"
else
    echo "❌ Erro ao atualizar App.js"
    exit 1
fi

echo ""
echo "📋 ProcessDetails.js Integrado com Backend:"
echo "   • Usa processesService.getProcess() para dados reais"
echo "   • Remove dependência de dados mockados"
echo "   • Carrega movimentações, documentos e atendimentos"
echo "   • Sincronização CNJ funcional"
echo "   • Estados de loading e erro"
echo ""
echo "🔗 Rota Configurada:"
echo "   • /admin/processos/:id → ProcessDetails.js"
echo ""
echo "✅ Script 116e concluído!"
echo "⭐ Próximo: Script para remover mocks dos modais existentes"
echo ""
echo "Digite 'continuar' para remover dados mockados dos modais"