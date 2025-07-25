import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  ClockIcon,
  CalendarIcon,
  UserIcon,
  ScaleIcon,
  BuildingOfficeIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon
} from '@heroicons/react/24/outline';

const NewPrazo = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [processes, setProcesses] = useState([]);
  
  const [formData, setFormData] = useState({
    processoId: '',
    descricao: '',
    tipoPrazo: '',
    dataVencimento: '',
    horaVencimento: '17:00',
    advogado: '',
    prioridade: 'Normal',
    observacoes: ''
  });

  const [errors, setErrors] = useState({});

  // Mock data
  const mockProcesses = [
    { id: 1, number: '1001234-56.2024.8.26.0001', client: 'João Silva Santos' },
    { id: 2, number: '2002345-67.2024.8.26.0002', client: 'Empresa ABC Ltda' },
    { id: 3, number: '3003456-78.2024.8.26.0003', client: 'Maria Oliveira Costa' }
  ];

  useEffect(() => {
    setTimeout(() => {
      setProcesses(mockProcesses);
    }, 500);
  }, []);

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
      await new Promise(resolve => setTimeout(resolve, 1500));
      alert('Prazo cadastrado com sucesso!');
      navigate('/admin/prazos');
    } catch (error) {
      alert('Erro ao cadastrar prazo');
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
              <h1 className="text-3xl font-bold text-gray-900">Novo Prazo</h1>
              <p className="text-lg text-gray-600 mt-2">Cadastre um novo prazo processual</p>
            </div>
          </div>
          <ClockIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Seleção de Processo */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Processo</h2>
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

            {/* Preview do Processo */}
            {selectedProcess && (
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-3">Processo Selecionado:</h3>
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
                  min={new Date().toISOString().split('T')[0]}
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

        {/* Responsável e Prioridade */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Responsável e Prioridade</h2>
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
                'Cadastrar Prazo'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewPrazo;
