import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  ScaleIcon,
  UserIcon,
  BuildingOfficeIcon,
  CurrencyDollarIcon,
  CalendarIcon,
  ExclamationTriangleIcon,
  DocumentTextIcon,
  ClockIcon
} from '@heroicons/react/24/outline';

const NewProcess = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [clients, setClients] = useState([]);
  
  const [formData, setFormData] = useState({
    // Dados básicos
    number: '',
    clientId: '',
    court: '',
    actionType: '',
    
    // Detalhes
    status: 'Em andamento',
    value: '',
    distributionDate: '',
    lawyer: '',
    priority: 'Normal',
    nextDeadline: '',
    
    // Observações
    observations: '',
    internalNotes: ''
  });

  const [errors, setErrors] = useState({});

  // Mock data de clientes
  const mockClients = [
    { id: 1, name: 'João Silva Santos', type: 'PF', document: '123.456.789-00' },
    { id: 2, name: 'Empresa ABC Ltda', type: 'PJ', document: '12.345.678/0001-90' },
    { id: 3, name: 'Maria Oliveira Costa', type: 'PF', document: '987.654.321-00' },
    { id: 4, name: 'Tech Solutions S.A.', type: 'PJ', document: '98.765.432/0001-10' },
    { id: 5, name: 'Ana Costa Advocacia', type: 'PJ', document: '11.222.333/0001-44' }
  ];

  useEffect(() => {
    // Simular carregamento de clientes
    setTimeout(() => {
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
  };

  const formatProcessNumber = (value) => {
    // Formato CNJ: NNNNNNN-DD.AAAA.J.TR.OOOO
    const numbers = value.replace(/\D/g, '');
    if (numbers.length <= 7) {
      return numbers;
    } else if (numbers.length <= 9) {
      return numbers.replace(/(\d{7})(\d{2})/, '$1-$2');
    } else if (numbers.length <= 13) {
      return numbers.replace(/(\d{7})(\d{2})(\d{4})/, '$1-$2.$3');
    } else if (numbers.length <= 14) {
      return numbers.replace(/(\d{7})(\d{2})(\d{4})(\d{1})/, '$1-$2.$3.$4');
    } else if (numbers.length <= 16) {
      return numbers.replace(/(\d{7})(\d{2})(\d{4})(\d{1})(\d{2})/, '$1-$2.$3.$4.$5');
    } else {
      return numbers.replace(/(\d{7})(\d{2})(\d{4})(\d{1})(\d{2})(\d{4})/, '$1-$2.$3.$4.$5.$6');
    }
  };

  const handleProcessNumberChange = (e) => {
    const formatted = formatProcessNumber(e.target.value);
    setFormData(prev => ({
      ...prev,
      number: formatted
    }));
  };

  const formatCurrency = (value) => {
    const numbers = value.replace(/\D/g, '');
    const amount = numbers / 100;
    return amount.toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
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
    if (!formData.clientId) newErrors.clientId = 'Cliente é obrigatório';
    if (!formData.court.trim()) newErrors.court = 'Tribunal/Vara é obrigatório';
    if (!formData.actionType.trim()) newErrors.actionType = 'Tipo de ação é obrigatório';
    if (!formData.distributionDate) newErrors.distributionDate = 'Data de distribuição é obrigatória';
    if (!formData.lawyer.trim()) newErrors.lawyer = 'Advogado responsável é obrigatório';
    
    // Validar formato CNJ (básico)
    if (formData.number && formData.number.length < 20) {
      newErrors.number = 'Número do processo deve seguir padrão CNJ completo';
    }
    
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
      
      // Simular sucesso
      alert('Processo cadastrado com sucesso!');
      navigate('/admin/processos');
    } catch (error) {
      alert('Erro ao cadastrar processo');
    } finally {
      setLoading(false);
    }
  };

  const selectedClient = clients.find(c => c.id.toString() === formData.clientId);

  const courts = [
    'TJSP - 1ª Vara Cível',
    'TJSP - 2ª Vara Cível',
    'TJSP - 3ª Vara Cível',
    'TJSP - 1ª Vara Empresarial',
    'TJSP - 2ª Vara Empresarial',
    'TJSP - 1ª Vara Família',
    'TJSP - 2ª Vara Família',
    'TJSP - 1ª Vara Criminal',
    'TJSP - 2ª Vara Criminal',
    'TJRJ - 1ª Vara Cível',
    'TJRJ - 2ª Vara Cível',
    'TRT - 2ª Região',
    'TRT - 15ª Região',
    'STJ - Superior Tribunal de Justiça',
    'TST - Tribunal Superior do Trabalho'
  ];

  const actionTypes = [
    'Ação de Indenização',
    'Ação de Cobrança',
    'Ação de Despejo',
    'Ação de Divórcio',
    'Ação Trabalhista',
    'Ação Penal',
    'Ação de Execução',
    'Ação de Busca e Apreensão',
    'Ação de Usucapião',
    'Ação de Inventário',
    'Ação Declaratória',
    'Ação Cautelar',
    'Mandado de Segurança',
    'Habeas Corpus',
    'Recurso Especial',
    'Recurso Extraordinário'
  ];

  const lawyers = [
    'Dr. Carlos Oliveira',
    'Dra. Maria Santos',
    'Dr. Pedro Costa',
    'Dra. Ana Silva',
    'Dr. João Ferreira',
    'Dra. Lucia Martins',
    'Dr. Rafael Souza',
    'Dra. Erlene Chaves Silva'
  ];

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
              <h1 className="text-3xl font-bold text-gray-900">Novo Processo</h1>
              <p className="text-lg text-gray-600 mt-2">Cadastre um novo processo jurídico</p>
            </div>
          </div>
          <ScaleIcon className="w-12 h-12 text-primary-600" />
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
                name="clientId"
                value={formData.clientId}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.clientId ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione um cliente...</option>
                {clients.map((client) => (
                  <option key={client.id} value={client.id}>
                    {client.name} ({client.type}) - {client.document}
                  </option>
                ))}
              </select>
              {errors.clientId && <p className="text-red-500 text-sm mt-1">{errors.clientId}</p>}
            </div>

            {/* Preview do Cliente Selecionado */}
            {selectedClient && (
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-2">Cliente Selecionado:</h3>
                <div className="flex items-center">
                  <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center mr-3">
                    {selectedClient.type === 'PF' ? (
                      <UserIcon className="w-4 h-4 text-primary-600" />
                    ) : (
                      <BuildingOfficeIcon className="w-4 h-4 text-primary-600" />
                    )}
                  </div>
                  <div>
                    <div className="font-medium text-gray-900">{selectedClient.name}</div>
                    <div className="text-sm text-gray-500">{selectedClient.document}</div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Dados do Processo */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Dados do Processo</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Número do Processo (CNJ) *
              </label>
              <input
                type="text"
                name="number"
                value={formData.number}
                onChange={handleProcessNumberChange}
                maxLength={25}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.number ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="1234567-89.2024.8.26.0001"
              />
              {errors.number && <p className="text-red-500 text-sm mt-1">{errors.number}</p>}
              <p className="text-xs text-gray-500 mt-1">Formato: NNNNNNN-DD.AAAA.J.TR.OOOO</p>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tribunal/Vara *
              </label>
              <select
                name="court"
                value={formData.court}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.court ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o tribunal...</option>
                {courts.map((court) => (
                  <option key={court} value={court}>{court}</option>
                ))}
              </select>
              {errors.court && <p className="text-red-500 text-sm mt-1">{errors.court}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Ação *
              </label>
              <select
                name="actionType"
                value={formData.actionType}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.actionType ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o tipo...</option>
                {actionTypes.map((type) => (
                  <option key={type} value={type}>{type}</option>
                ))}
              </select>
              {errors.actionType && <p className="text-red-500 text-sm mt-1">{errors.actionType}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Status
              </label>
              <select
                name="status"
                value={formData.status}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Em andamento">Em andamento</option>
                <option value="Urgente">Urgente</option>
                <option value="Suspenso">Suspenso</option>
                <option value="Concluído">Concluído</option>
                <option value="Arquivado">Arquivado</option>
              </select>
            </div>
          </div>
        </div>

        {/* Detalhes Financeiros e Prazos */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Detalhes e Prazos</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Valor da Causa
              </label>
              <div className="relative">
                <CurrencyDollarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  name="value"
                  value={formData.value}
                  onChange={handleValueChange}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="0,00"
                />
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Data de Distribuição *
              </label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="distributionDate"
                  value={formData.distributionDate}
                  onChange={handleChange}
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.distributionDate ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
              </div>
              {errors.distributionDate && <p className="text-red-500 text-sm mt-1">{errors.distributionDate}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Advogado Responsável *
              </label>
              <select
                name="lawyer"
                value={formData.lawyer}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.lawyer ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o advogado...</option>
                {lawyers.map((lawyer) => (
                  <option key={lawyer} value={lawyer}>{lawyer}</option>
                ))}
              </select>
              {errors.lawyer && <p className="text-red-500 text-sm mt-1">{errors.lawyer}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Prioridade
              </label>
              <div className="relative">
                <ExclamationTriangleIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <select
                  name="priority"
                  value={formData.priority}
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
            
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Próximo Prazo
              </label>
              <div className="relative">
                <ClockIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="nextDeadline"
                  value={formData.nextDeadline}
                  onChange={handleChange}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Observações */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Observações</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Observações do Processo
              </label>
              <div className="relative">
                <DocumentTextIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <textarea
                  name="observations"
                  value={formData.observations}
                  onChange={handleChange}
                  rows={4}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Observações sobre o processo..."
                />
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Anotações Internas
              </label>
              <textarea
                name="internalNotes"
                value={formData.internalNotes}
                onChange={handleChange}
                rows={4}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Anotações internas do escritório..."
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
              disabled={loading}
              className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Salvando...
                </div>
              ) : (
                'Salvar Processo'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewProcess;
