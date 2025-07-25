#!/bin/bash

# Script 89 - EditPrazo Completo
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "✏️ Criando EditPrazo completo (Script 89)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 Criando EditPrazo.js..."

# Criar EditPrazo.js seguindo padrão NewPrazo
cat > frontend/src/components/prazos/EditPrazo.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  ClockIcon,
  CalendarIcon,
  UserIcon,
  ScaleIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline';

const EditPrazo = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(true);
  
  const [formData, setFormData] = useState({
    processoId: '',
    descricao: '',
    tipoPrazo: '',
    dataVencimento: '',
    horaVencimento: '17:00',
    advogado: '',
    prioridade: 'Normal',
    status: 'Pendente',
    observacoes: ''
  });

  const [errors, setErrors] = useState({});
  const [processes, setProcesses] = useState([]);

  // Mock data do prazo
  const mockPrazo = {
    id: 1,
    processoId: '1',
    processo: '1001234-56.2024.8.26.0001',
    cliente: 'João Silva Santos',
    descricao: 'Petição Inicial',
    tipoPrazo: 'Petição Inicial',
    dataVencimento: '2024-07-25',
    horaVencimento: '17:00',
    advogado: 'Dr. Carlos Oliveira',
    prioridade: 'Urgente',
    status: 'Pendente',
    observacoes: 'Prazo fatal para protocolo'
  };

  // Mock data de processos
  const mockProcesses = [
    { id: 1, number: '1001234-56.2024.8.26.0001', client: 'João Silva Santos' },
    { id: 2, number: '2002345-67.2024.8.26.0002', client: 'Empresa ABC Ltda' },
    { id: 3, number: '3003456-78.2024.8.26.0003', client: 'Maria Oliveira Costa' }
  ];

  useEffect(() => {
    // Simular carregamento dos dados
    setTimeout(() => {
      setFormData(mockPrazo);
      setProcesses(mockProcesses);
      setLoadingData(false);
    }, 1000);
  }, [id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Limpar erro do campo
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.processoId) newErrors.processoId = 'Processo é obrigatório';
    if (!formData.descricao.trim()) newErrors.descricao = 'Descrição é obrigatória';
    if (!formData.tipoPrazo.trim()) newErrors.tipoPrazo = 'Tipo de prazo é obrigatório';
    if (!formData.dataVencimento) newErrors.dataVencimento = 'Data é obrigatória';
    if (!formData.advogado.trim()) newErrors.advogado = 'Advogado é obrigatório';
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setLoading(true);
    
    try {
      // Simular salvamento
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      alert('Prazo atualizado com sucesso!');
      navigate('/admin/prazos');
    } catch (error) {
      alert('Erro ao atualizar prazo');
    } finally {
      setLoading(false);
    }
  };

  const selectedProcess = processes.find(p => p.id.toString() === formData.processoId);

  const tiposPrazo = [
    'Petição Inicial',
    'Contestação',
    'Tréplica',
    'Recurso Ordinário',
    'Recurso Especial',
    'Embargos de Declaração',
    'Alegações Finais',
    'Cumprimento de Sentença',
    'Outro'
  ];

  const advogados = [
    'Dr. Carlos Oliveira',
    'Dra. Maria Santos',
    'Dr. Pedro Costa',
    'Dra. Ana Silva',
    'Dra. Erlene Chaves Silva'
  ];

  const getStatusIcon = (status) => {
    switch (status) {
      case 'Pendente': return <ClockIcon className="w-5 h-5 text-yellow-600" />;
      case 'Concluído': return <CheckCircleIcon className="w-5 h-5 text-green-600" />;
      case 'Vencido': return <ExclamationTriangleIcon className="w-5 h-5 text-red-600" />;
      default: return <ClockIcon className="w-5 h-5 text-gray-600" />;
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

  if (loadingData) {
    return (
      <div className="space-y-8">
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6 animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="h-6 bg-gray-200 rounded w-1/3 mb-6"></div>
          <div className="space-y-4">
            <div className="h-12 bg-gray-200 rounded"></div>
            <div className="h-12 bg-gray-200 rounded"></div>
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
              to="/admin/prazos"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Editar Prazo</h1>
              <p className="text-lg text-gray-600 mt-2">Atualize os dados do prazo #{id}</p>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            {getStatusIcon(formData.status)}
            <ClockIcon className="w-12 h-12 text-primary-600" />
          </div>
        </div>
      </div>

      {/* Info Card do Prazo */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Informações do Prazo</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="bg-gray-50 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-gray-500">Status Atual</span>
              {getStatusIcon(formData.status)}
            </div>
            <p className="text-lg font-semibold text-gray-900 mt-1">{formData.status}</p>
          </div>
          <div className="bg-gray-50 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-gray-500">Prioridade</span>
              <ExclamationTriangleIcon className={`w-5 h-5 ${getPriorityColor(formData.prioridade)}`} />
            </div>
            <p className={`text-lg font-semibold mt-1 ${getPriorityColor(formData.prioridade)}`}>
              {formData.prioridade}
            </p>
          </div>
          <div className="bg-gray-50 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-gray-500">Vencimento</span>
              <CalendarIcon className="w-5 h-5 text-gray-600" />
            </div>
            <p className="text-lg font-semibold text-gray-900 mt-1">
              {new Date(formData.dataVencimento).toLocaleDateString('pt-BR')}
            </p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Processo */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Processo</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Processo *
              </label>
              <select
                name="processoId"
                value={formData.processoId}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.processoId ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione um processo...</option>
                {processes.map((process) => (
                  <option key={process.id} value={process.id}>
                    {process.number} - {process.client}
                  </option>
                ))}
              </select>
              {errors.processoId && <p className="text-red-500 text-sm mt-1">{errors.processoId}</p>}
            </div>

            {/* Preview do Processo */}
            {selectedProcess && (
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-3">Processo Vinculado:</h3>
                <div className="flex items-center">
                  <ScaleIcon className="w-4 h-4 text-primary-600 mr-2" />
                  <div>
                    <div className="font-medium text-gray-900">{selectedProcess.number}</div>
                    <div className="text-sm text-gray-500">{selectedProcess.client}</div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Dados do Prazo */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Dados do Prazo</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Descrição do Prazo *
              </label>
              <input
                type="text"
                name="descricao"
                value={formData.descricao}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.descricao ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="Ex: Petição Inicial"
              />
              {errors.descricao && <p className="text-red-500 text-sm mt-1">{errors.descricao}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Prazo *
              </label>
              <select
                name="tipoPrazo"
                value={formData.tipoPrazo}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.tipoPrazo ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o tipo...</option>
                {tiposPrazo.map((tipo) => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
              {errors.tipoPrazo && <p className="text-red-500 text-sm mt-1">{errors.tipoPrazo}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Data de Vencimento *
              </label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="dataVencimento"
                  value={formData.dataVencimento}
                  onChange={handleChange}
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.dataVencimento ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
              </div>
              {errors.dataVencimento && <p className="text-red-500 text-sm mt-1">{errors.dataVencimento}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Hora Limite</label>
              <div className="relative">
                <ClockIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="time"
                  name="horaVencimento"
                  value={formData.horaVencimento}
                  onChange={handleChange}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Status e Prioridade */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Status e Prioridade</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <select
                name="status"
                value={formData.status}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Pendente">Pendente</option>
                <option value="Concluído">Concluído</option>
                <option value="Vencido">Vencido</option>
                <option value="Cancelado">Cancelado</option>
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Prioridade</label>
              <div className="relative">
                <ExclamationTriangleIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <select
                  name="prioridade"
                  value={formData.prioridade}
                  onChange={handleChange}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="Baixa">Baixa</option>
                  <option value="Normal">Normal</option>
                  <option value="Alta">Alta</option>
                  <option value="Urgente">Urgente</option>
                </select>
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Advogado Responsável *
              </label>
              <select
                name="advogado"
                value={formData.advogado}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.advogado ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o advogado...</option>
                {advogados.map((advogado) => (
                  <option key={advogado} value={advogado}>{advogado}</option>
                ))}
              </select>
              {errors.advogado && <p className="text-red-500 text-sm mt-1">{errors.advogado}</p>}
            </div>
          </div>
        </div>

        {/* Observações */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Observações</h2>
          <div className="relative">
            <DocumentTextIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <textarea
              name="observacoes"
              value={formData.observacoes}
              onChange={handleChange}
              rows={4}
              className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="Observações sobre o prazo..."
            />
          </div>
        </div>

        {/* Botões */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/prazos"
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              Cancelar
            </Link>
            <button
              type="submit"
              disabled={loading}
              className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Salvando...
                </div>
              ) : (
                'Atualizar Prazo'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default EditPrazo;
EOF

echo "✅ EditPrazo.js criado!"

echo "📝 Atualizando App.js para incluir rota de edição..."

# Fazer backup do App.js
cp frontend/src/App.js frontend/src/App.js.backup.$(date +%Y%m%d_%H%M%S)

# Adicionar import do EditPrazo
sed -i '/import NewPrazo/a import EditPrazo from '\''./components/prazos/EditPrazo'\'';' frontend/src/App.js

# Adicionar rota de edição de prazo
sed -i '/path="prazos\/novo"/a\                    <Route path="prazos/:id/editar" element={<EditPrazo />} />' frontend/src/App.js

echo "✅ App.js atualizado!"

echo ""
echo "🎉 SCRIPT 89 CONCLUÍDO!"
echo ""
echo "✅ EDITPRAZO CRIADO:"
echo "   • Formulário completo de edição"
echo "   • Cards informativos com status atual"
echo "   • Carregamento de dados simulado"
echo "   • Validações completas"
echo "   • Preview do processo vinculado"
echo "   • Ícones dinâmicos por status/prioridade"
echo ""
echo "📋 FUNCIONALIDADES AVANÇADAS:"
echo "   • Card de informações do prazo"
echo "   • Status visual com ícones coloridos"
echo "   • Prioridade com cores diferenciadas"
echo "   • Formulário responsivo"
echo "   • Estados de loading elegantes"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "   • /admin/prazos/:id/editar - Edição de prazo"
echo ""
echo "📁 ARQUIVOS CRIADOS/ATUALIZADOS:"
echo "   • frontend/src/components/prazos/EditPrazo.js"
echo "   • App.js com nova rota"
echo ""
echo "🧪 TESTE AGORA:"
echo "   • http://localhost:3000/admin/prazos/1/editar"
echo "   • Clique em 'Editar' na lista de prazos"
echo ""
echo "✅ MÓDULO PRAZOS 100% COMPLETO!"
echo ""
echo "⏭️ PRÓXIMO SCRIPT 90:"
echo "   • Tela de Relatórios de Processos"
echo "   • Dashboard com gráficos e métricas"
echo ""
echo "Digite 'continuar' para o Script 90!"