#!/bin/bash

# Script 84 - Audiências CRUD Completo (Parte 1/4)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📅 Criando CRUD completo de Audiências (Parte 1/4)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar estrutura frontend
if [ ! -d "frontend/src/pages/admin" ]; then
    echo "❌ Erro: Estrutura frontend não encontrada"
    exit 1
fi

echo "📁 1. Criando componente NewAudiencia..."

# Criar estrutura para audiências
mkdir -p frontend/src/components/audiencias

# Criar NewAudiencia.js seguindo padrão NewClient/NewProcess
cat > frontend/src/components/audiencias/NewAudiencia.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  CalendarIcon,
  ClockIcon,
  UserIcon,
  MapPinIcon,
  ScaleIcon,
  BuildingOfficeIcon,
  DocumentTextIcon
} from '@heroicons/react/24/outline';

const NewAudiencia = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [processes, setProcesses] = useState([]);
  const [clients, setClients] = useState([]);
  
  const [formData, setFormData] = useState({
    // Dados básicos
    processoId: '',
    clienteId: '',
    tipo: '',
    data: '',
    hora: '',
    
    // Local
    local: '',
    endereco: '',
    sala: '',
    
    // Responsáveis
    advogado: '',
    juiz: '',
    
    // Detalhes
    status: 'Agendada',
    observacoes: '',
    lembrete: true,
    horasLembrete: '2'
  });

  const [errors, setErrors] = useState({});

  // Mock data
  const mockProcesses = [
    { id: 1, number: '1001234-56.2024.8.26.0001', client: 'João Silva Santos', clientId: 1 },
    { id: 2, number: '2002345-67.2024.8.26.0002', client: 'Empresa ABC Ltda', clientId: 2 },
    { id: 3, number: '3003456-78.2024.8.26.0003', client: 'Maria Oliveira Costa', clientId: 3 }
  ];

  const mockClients = [
    { id: 1, name: 'João Silva Santos', type: 'PF', document: '123.456.789-00' },
    { id: 2, name: 'Empresa ABC Ltda', type: 'PJ', document: '12.345.678/0001-90' },
    { id: 3, name: 'Maria Oliveira Costa', type: 'PF', document: '987.654.321-00' }
  ];

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setProcesses(mockProcesses);
      setClients(mockClients);
    }, 500);
  }, []);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    // Limpar erro do campo
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }

    // Auto-preencher cliente quando processo for selecionado
    if (name === 'processoId' && value) {
      const selectedProcess = mockProcesses.find(p => p.id.toString() === value);
      if (selectedProcess) {
        setFormData(prev => ({
          ...prev,
          clienteId: selectedProcess.clientId.toString()
        }));
      }
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.processoId) newErrors.processoId = 'Processo é obrigatório';
    if (!formData.tipo.trim()) newErrors.tipo = 'Tipo de audiência é obrigatório';
    if (!formData.data) newErrors.data = 'Data é obrigatória';
    if (!formData.hora) newErrors.hora = 'Hora é obrigatória';
    if (!formData.local.trim()) newErrors.local = 'Local é obrigatório';
    if (!formData.advogado.trim()) newErrors.advogado = 'Advogado responsável é obrigatório';
    
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
      
      alert('Audiência agendada com sucesso!');
      navigate('/admin/audiencias');
    } catch (error) {
      alert('Erro ao agendar audiência');
    } finally {
      setLoading(false);
    }
  };

  const selectedProcess = processes.find(p => p.id.toString() === formData.processoId);
  const selectedClient = clients.find(c => c.id.toString() === formData.clienteId);

  const tiposAudiencia = [
    'Audiência de Conciliação',
    'Audiência de Instrução e Julgamento',
    'Audiência Preliminar',
    'Audiência de Justificação',
    'Audiência de Interrogatório',
    'Audiência de Oitiva de Testemunhas',
    'Audiência de Tentativa de Conciliação',
    'Audiência Una'
  ];

  const advogados = [
    'Dr. Carlos Oliveira',
    'Dra. Maria Santos',
    'Dr. Pedro Costa',
    'Dra. Ana Silva',
    'Dr. João Ferreira',
    'Dra. Erlene Chaves Silva'
  ];

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/audiencias"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Nova Audiência</h1>
              <p className="text-lg text-gray-600 mt-2">Agende uma nova audiência no sistema</p>
            </div>
          </div>
          <CalendarIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Seleção de Processo */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Processo e Cliente</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Selecione o Processo *
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

            {/* Preview do Processo e Cliente */}
            {selectedProcess && selectedClient && (
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-3">Processo Selecionado:</h3>
                <div className="space-y-2">
                  <div className="flex items-center">
                    <ScaleIcon className="w-4 h-4 text-primary-600 mr-2" />
                    <span className="text-sm font-medium text-gray-900">{selectedProcess.number}</span>
                  </div>
                  <div className="flex items-center">
                    {selectedClient.type === 'PF' ? (
                      <UserIcon className="w-4 h-4 text-primary-600 mr-2" />
                    ) : (
                      <BuildingOfficeIcon className="w-4 h-4 text-primary-600 mr-2" />
                    )}
                    <span className="text-sm text-gray-700">{selectedClient.name}</span>
                  </div>
                  <div className="text-xs text-gray-500">{selectedClient.document}</div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Dados da Audiência */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Dados da Audiência</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Audiência *
              </label>
              <select
                name="tipo"
                value={formData.tipo}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.tipo ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o tipo...</option>
                {tiposAudiencia.map((tipo) => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
              {errors.tipo && <p className="text-red-500 text-sm mt-1">{errors.tipo}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <select
                name="status"
                value={formData.status}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Agendada">Agendada</option>
                <option value="Confirmada">Confirmada</option>
                <option value="Em andamento">Em andamento</option>
                <option value="Concluída">Concluída</option>
                <option value="Cancelada">Cancelada</option>
                <option value="Adiada">Adiada</option>
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Data *</label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="data"
                  value={formData.data}
                  onChange={handleChange}
                  min={new Date().toISOString().split('T')[0]}
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.data ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
              </div>
              {errors.data && <p className="text-red-500 text-sm mt-1">{errors.data}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Hora *</label>
              <div className="relative">
                <ClockIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="time"
                  name="hora"
                  value={formData.hora}
                  onChange={handleChange}
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.hora ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
              </div>
              {errors.hora && <p className="text-red-500 text-sm mt-1">{errors.hora}</p>}
            </div>
          </div>
        </div>

        {/* Local */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Local da Audiência</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tribunal/Fórum *
              </label>
              <div className="relative">
                <MapPinIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  name="local"
                  value={formData.local}
                  onChange={handleChange}
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.local ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="TJSP - 1ª Vara Cível"
                />
              </div>
              {errors.local && <p className="text-red-500 text-sm mt-1">{errors.local}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Sala/Gabinete</label>
              <input
                type="text"
                name="sala"
                value={formData.sala}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Sala 101"
              />
            </div>
            
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">Endereço Completo</label>
              <textarea
                name="endereco"
                value={formData.endereco}
                onChange={handleChange}
                rows={2}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Endereço completo do fórum/tribunal..."
              />
            </div>
          </div>
        </div>

        {/* Responsáveis */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Responsáveis</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
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
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Juiz/Magistrado</label>
              <input
                type="text"
                name="juiz"
                value={formData.juiz}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Dr(a). Nome do Juiz"
              />
            </div>
          </div>
        </div>

        {/* Lembrete e Observações */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Configurações</h2>
          
          {/* Lembrete */}
          <div className="mb-6">
            <label className="flex items-center">
              <input
                type="checkbox"
                name="lembrete"
                checked={formData.lembrete}
                onChange={handleChange}
                className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
              />
              <span className="ml-3 text-sm font-medium text-gray-700">
                Enviar lembrete automático
              </span>
            </label>
          </div>
          
          {formData.lembrete && (
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Enviar lembrete com antecedência de:
              </label>
              <select
                name="horasLembrete"
                value={formData.horasLembrete}
                onChange={handleChange}
                className="w-full md:w-1/3 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="1">1 hora</option>
                <option value="2">2 horas</option>
                <option value="4">4 horas</option>
                <option value="8">8 horas</option>
                <option value="24">1 dia</option>
                <option value="48">2 dias</option>
              </select>
            </div>
          )}
          
          {/* Observações */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Observações</label>
            <div className="relative">
              <DocumentTextIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
              <textarea
                name="observacoes"
                value={formData.observacoes}
                onChange={handleChange}
                rows={4}
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Observações sobre a audiência..."
              />
            </div>
          </div>
        </div>

        {/* Botões */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/audiencias"
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
                'Agendar Audiência'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewAudiencia;
EOF

echo "✅ NewAudiencia criado!"

echo ""
echo "✅ PARTE 1/4 CONCLUÍDA!"
echo ""
echo "📝 CRIADO:"
echo "   • NewAudiencia.js - Formulário completo de cadastro"
echo "   • Seleção de processo com auto-preenchimento de cliente"
echo "   • Tipos de audiência jurídicos"
echo "   • Local, responsáveis e configurações"
echo "   • Validações completas"
echo ""
echo "📋 FUNCIONALIDADES:"
echo "   • Formulário seguindo padrão Erlene"
echo "   • Validação em tempo real"
echo "   • Preview do processo/cliente selecionado"
echo "   • Sistema de lembretes"
echo "   • Design responsivo"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/4):"
echo "   • Tela principal de Audiências com lista filtrada"
echo "   • Ações de edição e exclusão"
echo "   • Integração com NewAudiencia"
echo ""
echo "Digite 'continuar' para Parte 2/4!"