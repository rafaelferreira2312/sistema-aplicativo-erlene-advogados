import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  CalendarIcon,
  ClockIcon,
  MapPinIcon,
  DocumentTextIcon
} from '@heroicons/react/24/outline';

const EditAudiencia = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(true);
  
  const [formData, setFormData] = useState({
    tipo: '',
    data: '',
    hora: '',
    local: '',
    sala: '',
    endereco: '',
    advogado: '',
    juiz: '',
    status: 'Agendada',
    observacoes: ''
  });

  const [errors, setErrors] = useState({});

  // Mock data da audiência
  const mockAudiencia = {
    id: 1,
    tipo: 'Audiência de Conciliação',
    data: '2024-07-25',
    hora: '09:00',
    local: 'TJSP - 1ª Vara Cível',
    sala: 'Sala 101',
    endereco: 'Praça da Sé, 200 - Centro, São Paulo - SP',
    advogado: 'Dr. Carlos Oliveira',
    juiz: 'Dr. José Silva',
    status: 'Confirmada',
    observacoes: 'Audiência de tentativa de acordo'
  };

  useEffect(() => {
    // Simular carregamento dos dados
    setTimeout(() => {
      setFormData(mockAudiencia);
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
    
    if (!formData.tipo.trim()) newErrors.tipo = 'Tipo de audiência é obrigatório';
    if (!formData.data) newErrors.data = 'Data é obrigatória';
    if (!formData.hora) newErrors.hora = 'Hora é obrigatória';
    if (!formData.local.trim()) newErrors.local = 'Local é obrigatório';
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
      
      alert('Audiência atualizada com sucesso!');
      navigate('/admin/audiencias');
    } catch (error) {
      alert('Erro ao atualizar audiência');
    } finally {
      setLoading(false);
    }
  };

  const tiposAudiencia = [
    'Audiência de Conciliação',
    'Audiência de Instrução e Julgamento',
    'Audiência Preliminar',
    'Audiência de Justificação',
    'Audiência de Interrogatório'
  ];

  const advogados = [
    'Dr. Carlos Oliveira',
    'Dra. Maria Santos',
    'Dr. Pedro Costa',
    'Dra. Ana Silva',
    'Dra. Erlene Chaves Silva'
  ];

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
              to="/admin/audiencias"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Editar Audiência</h1>
              <p className="text-lg text-gray-600 mt-2">Atualize os dados da audiência #{id}</p>
            </div>
          </div>
          <CalendarIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
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
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Local</h2>
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
              <label className="block text-sm font-medium text-gray-700 mb-2">Sala</label>
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
              <label className="block text-sm font-medium text-gray-700 mb-2">Endereço</label>
              <textarea
                name="endereco"
                value={formData.endereco}
                onChange={handleChange}
                rows={2}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Endereço completo..."
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
              <label className="block text-sm font-medium text-gray-700 mb-2">Juiz</label>
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
              placeholder="Observações sobre a audiência..."
            />
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
                'Atualizar Audiência'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default EditAudiencia;
