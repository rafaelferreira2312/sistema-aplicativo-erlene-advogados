import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  CalendarIcon,
  ClockIcon,
  UserIcon,
  PhoneIcon,
  VideoCameraIcon,
  HomeIcon,
  DocumentTextIcon,
  ScaleIcon,
  BuildingOfficeIcon
} from '@heroicons/react/24/outline';

const NewAtendimento = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [clients, setClients] = useState([]);
  const [processes, setProcesses] = useState([]);
  
  const [formData, setFormData] = useState({
    // Dados básicos
    clienteId: '',
    tipo: '',
    data: '',
    hora: '',
    duracao: '60',
    
    // Detalhes
    advogado: '',
    assunto: '',
    status: 'Agendado',
    observacoes: '',
    
    // Processos relacionados
    processosVinculados: [],
    
    // Configurações
    lembrete: true,
    horasLembrete: '2'
  });

  const [errors, setErrors] = useState({});

  // Mock data
  const mockClients = [
    { id: 1, name: 'João Silva Santos', type: 'PF', document: '123.456.789-00' },
    { id: 2, name: 'Empresa ABC Ltda', type: 'PJ', document: '12.345.678/0001-90' },
    { id: 3, name: 'Maria Oliveira Costa', type: 'PF', document: '987.654.321-00' },
    { id: 4, name: 'Tech Solutions S.A.', type: 'PJ', document: '11.222.333/0001-44' },
    { id: 5, name: 'Carlos Pereira Lima', type: 'PF', document: '555.666.777-88' }
  ];

  const mockProcesses = [
    { id: 1, number: '1001234-56.2024.8.26.0001', client: 'João Silva Santos', clientId: 1 },
    { id: 2, number: '2002345-67.2024.8.26.0002', client: 'Empresa ABC Ltda', clientId: 2 },
    { id: 3, number: '3003456-78.2024.8.26.0003', client: 'Maria Oliveira Costa', clientId: 3 },
    { id: 4, number: '4004567-89.2024.8.26.0004', client: 'Tech Solutions S.A.', clientId: 4 },
    { id: 5, number: '5005678-90.2024.8.26.0005', client: 'Carlos Pereira Lima', clientId: 5 }
  ];

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setClients(mockClients);
      setProcesses(mockProcesses);
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
  };

  const handleProcessToggle = (processId) => {
    setFormData(prev => ({
      ...prev,
      processosVinculados: prev.processosVinculados.includes(processId)
        ? prev.processosVinculados.filter(id => id !== processId)
        : [...prev.processosVinculados, processId]
    }));
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.clienteId) newErrors.clienteId = 'Cliente é obrigatório';
    if (!formData.tipo.trim()) newErrors.tipo = 'Tipo de atendimento é obrigatório';
    if (!formData.data) newErrors.data = 'Data é obrigatória';
    if (!formData.hora) newErrors.hora = 'Hora é obrigatória';
    if (!formData.advogado.trim()) newErrors.advogado = 'Advogado responsável é obrigatório';
    if (!formData.assunto.trim()) newErrors.assunto = 'Assunto é obrigatório';
    
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
      
      alert('Atendimento agendado com sucesso!');
      navigate('/admin/atendimentos');
    } catch (error) {
      alert('Erro ao agendar atendimento');
    } finally {
      setLoading(false);
    }
  };

  const selectedClient = clients.find(c => c.id.toString() === formData.clienteId);
  const clientProcesses = processes.filter(p => p.clientId.toString() === formData.clienteId);

  const tiposAtendimento = [
    'Presencial',
    'Online',
    'Telefone'
  ];

  const advogados = [
    'Dr. Carlos Oliveira',
    'Dra. Maria Santos',
    'Dr. Pedro Costa',
    'Dra. Ana Silva',
    'Dr. João Ferreira',
    'Dra. Erlene Chaves Silva'
  ];

  const duracoes = [
    { value: '30', label: '30 minutos' },
    { value: '45', label: '45 minutos' },
    { value: '60', label: '1 hora' },
    { value: '90', label: '1h 30min' },
    { value: '120', label: '2 horas' },
    { value: '180', label: '3 horas' }
  ];

  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'Presencial': return <HomeIcon className="w-5 h-5" />;
      case 'Online': return <VideoCameraIcon className="w-5 h-5" />;
      case 'Telefone': return <PhoneIcon className="w-5 h-5" />;
      default: return <UserIcon className="w-5 h-5" />;
    }
  };

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/atendimentos"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Novo Atendimento</h1>
              <p className="text-lg text-gray-600 mt-2">Agende um novo atendimento no sistema</p>
            </div>
          </div>
          <UserIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Seleção de Cliente */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Cliente</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Selecione o Cliente *
              </label>
              <select
                name="clienteId"
                value={formData.clienteId}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.clienteId ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione um cliente...</option>
                {clients.map((client) => (
                  <option key={client.id} value={client.id}>
                    {client.name} ({client.document})
                  </option>
                ))}
              </select>
              {errors.clienteId && <p className="text-red-500 text-sm mt-1">{errors.clienteId}</p>}
            </div>

            {/* Preview do Cliente */}
            {selectedClient && (
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-3">Cliente Selecionado:</h3>
                <div className="space-y-2">
                  <div className="flex items-center">
                    {selectedClient.type === 'PF' ? (
                      <UserIcon className="w-4 h-4 text-primary-600 mr-2" />
                    ) : (
                      <BuildingOfficeIcon className="w-4 h-4 text-primary-600 mr-2" />
                    )}
                    <span className="text-sm font-medium text-gray-900">{selectedClient.name}</span>
                  </div>
                  <div className="text-xs text-gray-500">{selectedClient.document}</div>
                  <div className="text-xs text-gray-500">
                    {clientProcesses.length} processo(s) vinculado(s)
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Dados do Atendimento */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Dados do Atendimento</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Atendimento *
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
                {tiposAtendimento.map((tipo) => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
              {errors.tipo && <p className="text-red-500 text-sm mt-1">{errors.tipo}</p>}
              {formData.tipo && (
                <div className="mt-2 flex items-center text-sm text-gray-600">
                  {getTipoIcon(formData.tipo)}
                  <span className="ml-2">
                    {formData.tipo === 'Presencial' && 'Reunião no escritório'}
                    {formData.tipo === 'Online' && 'Videoconferência (Teams/Zoom)'}
                    {formData.tipo === 'Telefone' && 'Ligação telefônica'}
                  </span>
                </div>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <select
                name="status"
                value={formData.status}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Agendado">Agendado</option>
                <option value="Confirmado">Confirmado</option>
                <option value="Realizado">Realizado</option>
                <option value="Cancelado">Cancelado</option>
                <option value="Reagendado">Reagendado</option>
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
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Duração Estimada</label>
              <select
                name="duracao"
                value={formData.duracao}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                {duracoes.map((duracao) => (
                  <option key={duracao.value} value={duracao.value}>{duracao.label}</option>
                ))}
              </select>
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

        {/* Assunto */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Assunto do Atendimento</h2>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Assunto Principal *
            </label>
            <input
              type="text"
              name="assunto"
              value={formData.assunto}
              onChange={handleChange}
              className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                errors.assunto ? 'border-red-300' : 'border-gray-300'
              }`}
              placeholder="Ex: Consulta sobre divórcio consensual"
            />
            {errors.assunto && <p className="text-red-500 text-sm mt-1">{errors.assunto}</p>}
          </div>
        </div>

        {/* Processos Relacionados */}
        {selectedClient && clientProcesses.length > 0 && (
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Processos Relacionados</h2>
            <p className="text-sm text-gray-600 mb-4">
              Selecione os processos que serão discutidos neste atendimento:
            </p>
            <div className="space-y-3">
              {clientProcesses.map((process) => (
                <label key={process.id} className="flex items-center">
                  <input
                    type="checkbox"
                    checked={formData.processosVinculados.includes(process.id)}
                    onChange={() => handleProcessToggle(process.id)}
                    className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                  />
                  <div className="ml-3 flex items-center">
                    <ScaleIcon className="w-4 h-4 text-primary-600 mr-2" />
                    <span className="text-sm font-medium text-gray-900">{process.number}</span>
                  </div>
                </label>
              ))}
            </div>
          </div>
        )}

        {/* Observações e Configurações */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Observações e Configurações</h2>
          
          <div className="space-y-6">
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
                  placeholder="Observações sobre o atendimento, preparação necessária, documentos a trazer..."
                />
              </div>
            </div>
            
            {/* Lembrete */}
            <div>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  name="lembrete"
                  checked={formData.lembrete}
                  onChange={handleChange}
                  className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                />
                <span className="ml-3 text-sm font-medium text-gray-700">
                  Enviar lembrete automático para o cliente
                </span>
              </label>
            </div>
            
            {formData.lembrete && (
              <div>
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
          </div>
        </div>

        {/* Botões */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/atendimentos"
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
                'Agendar Atendimento'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewAtendimento;
