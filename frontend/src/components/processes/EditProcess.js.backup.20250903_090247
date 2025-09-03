import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  ScaleIcon,
  UserIcon,
  DocumentTextIcon,
  CurrencyDollarIcon,
  BuildingLibraryIcon,
  CalendarIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  TrashIcon
} from '@heroicons/react/24/outline';

const EditProcess = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [clients, setClients] = useState([]);
  const [advogados, setAdvogados] = useState([]);
  
  const [formData, setFormData] = useState({
    number: '',
    clienteId: '',
    subject: '',
    type: '',
    status: 'Em Andamento',
    advogadoId: '',
    court: '',
    judge: '',
    value: '',
    priority: 'Média',
    confidential: false,
    startDate: '',
    expectedEndDate: '',
    observations: '',
    strategy: ''
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

  const mockAdvogados = [
    { id: 1, name: 'Dr. Carlos Oliveira', oab: 'OAB/SP 123456', specialty: 'Cível' },
    { id: 2, name: 'Dra. Maria Santos', oab: 'OAB/SP 234567', specialty: 'Trabalhista' },
    { id: 3, name: 'Dr. Pedro Costa', oab: 'OAB/SP 345678', specialty: 'Família' },
    { id: 4, name: 'Dra. Ana Silva', oab: 'OAB/SP 456789', specialty: 'Cível' },
    { id: 5, name: 'Dra. Erlene Chaves Silva', oab: 'OAB/SP 567890', specialty: 'Sucessões' }
  ];

  // Simular carregamento dos dados do processo
  useEffect(() => {
    const loadProcess = async () => {
      try {
        // Simular busca por ID
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Dados mock baseados no ID
        const mockData = {
          1: {
            number: '1001234-56.2024.8.26.0001',
            clienteId: '1',
            subject: 'Ação de Cobrança',
            type: 'Cível',
            status: 'Em Andamento',
            advogadoId: '1',
            court: '1ª Vara Cível - SP',
            judge: 'Dr. João da Silva',
            value: 'R$ 50.000,00',
            priority: 'Média',
            confidential: false,
            startDate: '2024-01-15',
            expectedEndDate: '2024-12-15',
            observations: 'Cliente VIP - priorizar andamentos',
            strategy: 'Utilizar jurisprudência do STJ sobre prescrição'
          },
          2: {
            number: '2002345-67.2024.8.26.0002',
            clienteId: '2',
            subject: 'Ação Trabalhista',
            type: 'Trabalhista',
            status: 'Aguardando',
            advogadoId: '2',
            court: '2ª Vara do Trabalho - SP',
            judge: 'Dra. Maria Fernanda',
            value: 'R$ 120.000,00',
            priority: 'Alta',
            confidential: true,
            startDate: '2024-01-20',
            expectedEndDate: '2024-10-20',
            observations: 'Processo complexo com múltiplas testemunhas',
            strategy: 'Foco na comprovação de vínculo empregatício'
          },
          3: {
            number: '3003456-78.2024.8.26.0003',
            clienteId: '3',
            subject: 'Divórcio Consensual',
            type: 'Família',
            status: 'Concluído',
            advogadoId: '3',
            court: '1ª Vara de Família - SP',
            judge: 'Dr. Roberto Santos',
            value: 'R$ 15.000,00',
            priority: 'Baixa',
            confidential: false,
            startDate: '2024-02-01',
            expectedEndDate: '2024-06-01',
            observations: 'Processo finalizado com acordo',
            strategy: 'Divórcio consensual sem filhos menores'
          }
        };
        
        const processData = mockData[id] || mockData[1];
        setFormData(processData);
        setClients(mockClients);
        setAdvogados(mockAdvogados);
      } catch (error) {
        alert('Erro ao carregar dados do processo');
      } finally {
        setLoading(false);
      }
    };

    loadProcess();
  }, [id]);

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

  const formatCurrency = (value) => {
    const cleanValue = value.replace(/[^\d,.-]/g, '');
    const numbers = cleanValue.replace(/\D/g, '');
    
    if (!numbers) return '';
    
    const amount = parseInt(numbers) / 100;
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(amount);
  };

  const handleValueChange = (e) => {
    const formatted = formatCurrency(e.target.value);
    setFormData(prev => ({
      ...prev,
      value: formatted
    }));
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.number.trim()) newErrors.number = 'Número do processo é obrigatório';
    if (!formData.clienteId) newErrors.clienteId = 'Cliente é obrigatório';
    if (!formData.subject.trim()) newErrors.subject = 'Assunto é obrigatório';
    if (!formData.type) newErrors.type = 'Tipo do processo é obrigatório';
    if (!formData.advogadoId) newErrors.advogadoId = 'Advogado responsável é obrigatório';
    if (!formData.startDate) newErrors.startDate = 'Data de início é obrigatória';
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setSaving(true);
    
    try {
      // Simular atualização
      await new Promise(resolve => setTimeout(resolve, 1500));
      alert('Processo atualizado com sucesso!');
      navigate('/admin/processos');
    } catch (error) {
      alert('Erro ao atualizar processo');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      alert('Processo excluído com sucesso!');
      navigate('/admin/processos');
    } catch (error) {
      alert('Erro ao excluir processo');
    }
  };

  const getSelectedClient = () => {
    return clients.find(c => c.id.toString() === formData.clienteId);
  };

  const getSelectedAdvogado = () => {
    return advogados.find(a => a.id.toString() === formData.advogadoId);
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Em Andamento': return 'text-blue-600 bg-blue-100';
      case 'Aguardando': return 'text-yellow-600 bg-yellow-100';
      case 'Concluído': return 'text-green-600 bg-green-100';
      case 'Suspenso': return 'text-red-600 bg-red-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'Urgente': return 'text-red-600 bg-red-100';
      case 'Alta': return 'text-orange-600 bg-orange-100';
      case 'Média': return 'text-yellow-600 bg-yellow-100';
      case 'Baixa': return 'text-green-600 bg-green-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const selectedClient = getSelectedClient();
  const selectedAdvogado = getSelectedAdvogado();

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
        <div className="space-y-4">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="bg-white rounded-xl p-6 animate-pulse">
              <div className="h-6 bg-gray-200 rounded mb-4 w-1/3"></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="h-12 bg-gray-200 rounded"></div>
                <div className="h-12 bg-gray-200 rounded"></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <>
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
                <h1 className="text-3xl font-bold text-gray-900">Editar Processo</h1>
                <p className="text-lg text-gray-600 mt-2">Atualize as informações do processo</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="text-right">
                <div className="text-sm text-gray-500">Status atual</div>
                <div className="flex items-center space-x-2">
                  <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getStatusColor(formData.status)}`}>
                    {formData.status}
                  </span>
                  <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getPriorityColor(formData.priority)}`}>
                    {formData.priority}
                  </span>
                </div>
              </div>
              <button
                onClick={() => setShowDeleteModal(true)}
                className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors flex items-center space-x-2"
              >
                <TrashIcon className="w-4 h-4" />
                <span>Excluir</span>
              </button>
            </div>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Dados Básicos */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Dados Básicos</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Número do Processo *
                </label>
                <input
                  type="text"
                  name="number"
                  value={formData.number}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.number ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
                {errors.number && <p className="text-red-500 text-sm mt-1">{errors.number}</p>}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Cliente *
                </label>
                <select
                  name="clienteId"
                  value={formData.clienteId}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.clienteId ? 'border-red-300' : 'border-gray-300'
                  }`}
                >
                  <option value="">Selecione o cliente...</option>
                  {clients.map((client) => (
                    <option key={client.id} value={client.id}>
                      {client.name} ({client.type}) - {client.document}
                    </option>
                  ))}
                </select>
                {errors.clienteId && <p className="text-red-500 text-sm mt-1">{errors.clienteId}</p>}
                
                {/* Preview do cliente selecionado */}
                {selectedClient && (
                  <div className="mt-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                    <div className="flex items-center space-x-2">
                      <UserIcon className="w-4 h-4 text-blue-600" />
                      <div>
                        <div className="text-sm font-medium text-blue-900">{selectedClient.name}</div>
                        <div className="text-xs text-blue-700">{selectedClient.type} - {selectedClient.document}</div>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Advogado Responsável *
                </label>
                <select
                  name="advogadoId"
                  value={formData.advogadoId}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.advogadoId ? 'border-red-300' : 'border-gray-300'
                  }`}
                >
                  <option value="">Selecione o advogado...</option>
                  {advogados.map((advogado) => (
                    <option key={advogado.id} value={advogado.id}>
                      {advogado.name} ({advogado.oab}) - {advogado.specialty}
                    </option>
                  ))}
                </select>
                {errors.advogadoId && <p className="text-red-500 text-sm mt-1">{errors.advogadoId}</p>}
                
                {/* Preview do advogado selecionado */}
                {selectedAdvogado && (
                  <div className="mt-2 p-3 bg-green-50 border border-green-200 rounded-lg">
                    <div className="flex items-center space-x-2">
                      <ScaleIcon className="w-4 h-4 text-green-600" />
                      <div>
                        <div className="text-sm font-medium text-green-900">{selectedAdvogado.name}</div>
                        <div className="text-xs text-green-700">{selectedAdvogado.oab} - {selectedAdvogado.specialty}</div>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Assunto do Processo *
                </label>
                <input
                  type="text"
                  name="subject"
                  value={formData.subject}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.subject ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
                {errors.subject && <p className="text-red-500 text-sm mt-1">{errors.subject}</p>}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tipo do Processo *
                </label>
                <select
                  name="type"
                  value={formData.type}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.type ? 'border-red-300' : 'border-gray-300'
                  }`}
                >
                  <option value="">Selecione o tipo...</option>
                  <option value="Cível">Cível</option>
                  <option value="Trabalhista">Trabalhista</option>
                  <option value="Família">Família</option>
                  <option value="Sucessões">Sucessões</option>
                  <option value="Criminal">Criminal</option>
                  <option value="Tributário">Tributário</option>
                  <option value="Administrativo">Administrativo</option>
                </select>
                {errors.type && <p className="text-red-500 text-sm mt-1">{errors.type}</p>}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
                <select
                  name="status"
                  value={formData.status}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="Em Andamento">Em Andamento</option>
                  <option value="Aguardando">Aguardando</option>
                  <option value="Concluído">Concluído</option>
                  <option value="Suspenso">Suspenso</option>
                </select>
              </div>
            </div>
          </div>

          {/* Detalhes Jurídicos */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Detalhes Jurídicos</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Vara/Tribunal</label>
                <div className="relative">
                  <BuildingLibraryIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    name="court"
                    value={formData.court}
                    onChange={handleChange}
                    className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                    placeholder="Ex: 1ª Vara Cível - SP"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Juiz</label>
                <input
                  type="text"
                  name="judge"
                  value={formData.judge}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Nome do juiz"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Valor da Causa</label>
                <div className="relative">
                  <CurrencyDollarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    name="value"
                    value={formData.value}
                    onChange={handleValueChange}
                    className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                    placeholder="R$ 0,00"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Prioridade</label>
                <select
                  name="priority"
                  value={formData.priority}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="Baixa">Baixa</option>
                  <option value="Média">Média</option>
                  <option value="Alta">Alta</option>
                  <option value="Urgente">Urgente</option>
                </select>
              </div>
            </div>
            
            {/* Checkbox confidencial */}
            <div className="mt-6">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  name="confidential"
                  checked={formData.confidential}
                  onChange={handleChange}
                  className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                />
                <span className="ml-3 text-sm font-medium text-gray-700">
                  Processo confidencial (acesso restrito)
                </span>
              </label>
            </div>
          </div>

          {/* Cronograma */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Cronograma</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Data de Início *
                </label>
                <div className="relative">
                  <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <input
                    type="date"
                    name="startDate"
                    value={formData.startDate}
                    onChange={handleChange}
                    className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                      errors.startDate ? 'border-red-300' : 'border-gray-300'
                    }`}
                  />
                </div>
                {errors.startDate && <p className="text-red-500 text-sm mt-1">{errors.startDate}</p>}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Previsão de Encerramento
                </label>
                <div className="relative">
                  <ClockIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <input
                    type="date"
                    name="expectedEndDate"
                    value={formData.expectedEndDate}
                    onChange={handleChange}
                    min={formData.startDate}
                    className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Observações e Estratégia */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Observações e Estratégia</h2>
            
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Observações Gerais</label>
                <div className="relative">
                  <DocumentTextIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <textarea
                    name="observations"
                    value={formData.observations}
                    onChange={handleChange}
                    rows={3}
                    className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                    placeholder="Observações sobre o processo..."
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Estratégia Jurídica</label>
                <textarea
                  name="strategy"
                  value={formData.strategy}
                  onChange={handleChange}
                  rows={3}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Estratégia e teses a serem utilizadas..."
                />
              </div>
            </div>
          </div>

          {/* Botões */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex justify-end space-x-4">
              <Link
                to="/admin/processos"
                className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
              >
                Cancelar
              </Link>
              <button
                type="submit"
                disabled={saving}
                className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
              >
                {saving ? (
                  <div className="flex items-center">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Salvando...
                  </div>
                ) : (
                  'Salvar Alterações'
                )}
              </button>
            </div>
          </div>
        </form>
      </div>

      {/* Modal de Confirmação de Exclusão */}
      {showDeleteModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3 text-center">
              <ExclamationTriangleIcon className="w-16 h-16 text-red-600 mx-auto" />
              <h3 className="text-lg font-medium text-gray-900 mt-5">Confirmar Exclusão</h3>
              <div className="mt-4 px-7 py-3">
                <p className="text-sm text-gray-500">
                  Tem certeza que deseja excluir este processo? Esta ação não pode ser desfeita e removerá:
                </p>
                <ul className="mt-2 text-sm text-gray-600 list-disc list-inside text-left">
                  <li>Todos os dados do processo</li>
                  <li>Audiências relacionadas</li>
                  <li>Prazos vinculados</li>
                  <li>Documentos anexados</li>
                  <li>Histórico de andamentos</li>
                </ul>
              </div>
              <div className="items-center px-4 py-3">
                <button
                  onClick={handleDelete}
                  className="px-4 py-2 bg-red-600 text-white text-base font-medium rounded-md w-24 mr-2 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-300"
                >
                  Excluir
                </button>
                <button
                  onClick={() => setShowDeleteModal(false)}
                  className="px-4 py-2 bg-gray-300 text-gray-800 text-base font-medium rounded-md w-24 hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-300"
                >
                  Cancelar
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default EditProcess;
