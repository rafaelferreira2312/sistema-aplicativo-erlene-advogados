import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  UserIcon,
  BuildingOfficeIcon,
  EnvelopeIcon,
  PhoneIcon,
  MapPinIcon,
  EyeIcon,
  EyeSlashIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon,
  TrashIcon
} from '@heroicons/react/24/outline';

const EditClient = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [responsaveis, setResponsaveis] = useState([]);
  
  const [formData, setFormData] = useState({
    type: 'PF',
    name: '',
    document: '',
    email: '',
    phone: '',
    cep: '',
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: 'SP',
    status: 'Ativo',
    portalAccess: false,
    password: '',
    storageType: 'local',
    observations: ''
  });

  const [errors, setErrors] = useState({});

  // Simular carregamento dos dados do cliente
  useEffect(() => {
    const loadClient = async () => {
      try {
        // Simular busca por ID
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Dados mock baseados no ID
        const mockData = {
          1: {
            type: 'PF',
            name: 'João Silva Santos',
            document: '123.456.789-00',
            email: 'joao.silva@email.com',
            phone: '(11) 99999-9999',
            cep: '01310-100',
            street: 'Av. Paulista',
            number: '1000',
            complement: 'Apto 101',
            neighborhood: 'Bela Vista',
            city: 'São Paulo',
            state: 'SP',
            status: 'Ativo',
            portalAccess: true,
            password: '',
            storageType: 'googledrive',
            observations: 'Cliente VIP - atendimento prioritário'
          },
          2: {
            type: 'PJ',
            name: 'Empresa ABC Ltda',
            document: '12.345.678/0001-90',
            email: 'contato@empresaabc.com',
            phone: '(11) 3333-3333',
            cep: '04038-001',
            street: 'Rua Vergueiro',
            number: '2000',
            complement: 'Sala 205',
            neighborhood: 'Vila Mariana',
            city: 'São Paulo',
            state: 'SP',
            status: 'Ativo',
            portalAccess: false,
            password: '',
            storageType: 'local',
            observations: 'Empresa parceira'
          },
          3: {
            type: 'PF',
            name: 'Maria Oliveira Costa',
            document: '987.654.321-00',
            email: 'maria.oliveira@email.com',
            phone: '(11) 88888-8888',
            cep: '01234-567',
            street: 'Rua das Flores',
            number: '123',
            complement: '',
            neighborhood: 'Centro',
            city: 'São Paulo',
            state: 'SP',
            status: 'Inativo',
            portalAccess: false,
            password: '',
            storageType: 'onedrive',
            observations: 'Cliente com pendências'
          }
        };
        
        const clientData = mockData[id] || mockData[1];
        setFormData(clientData);
      } catch (error) {
        alert('Erro ao carregar dados do cliente');
      } finally {
        setLoading(false);
      }
    };

    loadClient();
  }, [id]);

  // Carregar responsáveis
  useEffect(() => {
    const loadResponsaveis = async () => {
      try {
        const response = await clientsService.getResponsaveis();
        setResponsaveis(response.data || []);
      } catch (error) {
        console.error('Erro ao carregar responsáveis:', error);
      }
    };
    
    loadResponsaveis();
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

  const formatDocument = (value, type) => {
    const numbers = value.replace(/\D/g, '');
    
    if (type === 'PF') {
      return numbers.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    } else {
      return numbers.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
    }
  };

  const formatPhone = (value) => {
    const numbers = value.replace(/\D/g, '');
    return numbers.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
  };

  const formatCEP = (value) => {
    const numbers = value.replace(/\D/g, '');
    return numbers.replace(/(\d{5})(\d{3})/, '$1-$2');
  };

  const handleDocumentChange = (e) => {
    const formatted = formatDocument(e.target.value, formData.type);
    setFormData(prev => ({
      ...prev,
      document: formatted
    }));
  };

  const handlePhoneChange = (e) => {
    const formatted = formatPhone(e.target.value);
    setFormData(prev => ({
      ...prev,
      phone: formatted
    }));
  };

  const handleCEPChange = async (e) => {
    const formatted = formatCEP(e.target.value);
    setFormData(prev => ({
      ...prev,
      cep: formatted
    }));
    
    // Buscar endereço por CEP
    if (formatted.length === 9) {
      try {
        const response = await fetch(`https://viacep.com.br/ws/${formatted.replace('-', '')}/json/`);
        const data = await response.json();
        
        if (!data.erro) {
          setFormData(prev => ({
            ...prev,
            street: data.logradouro,
            neighborhood: data.bairro,
            city: data.localidade,
            state: data.uf
          }));
        }
      } catch (error) {
        console.log('Erro ao buscar CEP:', error);
      }
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.name.trim()) newErrors.name = 'Nome é obrigatório';
    if (!formData.document.trim()) newErrors.document = 'Documento é obrigatório';
    if (!formData.email.trim()) newErrors.email = 'Email é obrigatório';
    if (!formData.phone.trim()) newErrors.phone = 'Telefone é obrigatório';
    
    // Validar email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (formData.email && !emailRegex.test(formData.email)) {
      newErrors.email = 'Email inválido';
    }
    
    if (formData.portalAccess && !formData.password && !id) {
      newErrors.password = 'Senha é obrigatória para acesso ao portal';
    }
    
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
      alert('Cliente atualizado com sucesso!');
      navigate('/admin/clientes');
    } catch (error) {
      alert('Erro ao atualizar cliente');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      alert('Cliente excluído com sucesso!');
      navigate('/admin/clientes');
    } catch (error) {
      alert('Erro ao excluir cliente');
    }
  };

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
                to="/admin/clientes"
                className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <ArrowLeftIcon className="w-5 h-5" />
              </Link>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Editar Cliente</h1>
                <p className="text-lg text-gray-600 mt-2">Atualize as informações do cliente</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="text-right">
                <div className="text-sm text-gray-500">Tipo de pessoa</div>
                <div className="flex items-center space-x-2">
                  {formData.type === 'PF' ? (
                    <UserIcon className="w-6 h-6 text-primary-600" />
                  ) : (
                    <BuildingOfficeIcon className="w-6 h-6 text-primary-600" />
                  )}
                  <span className="text-lg font-medium text-gray-900">
                    {formData.type === 'PF' ? 'Pessoa Física' : 'Pessoa Jurídica'}
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
          {/* Tipo de Pessoa */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Tipo de Pessoa</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <label className={`flex items-center p-6 border-2 rounded-xl cursor-pointer transition-all ${
                formData.type === 'PF' ? 'border-primary-500 bg-primary-50' : 'border-gray-200 hover:border-gray-300'
              }`}>
                <input
                  type="radio"
                  name="type"
                  value="PF"
                  checked={formData.type === 'PF'}
                  onChange={handleChange}
                  className="sr-only"
                />
                <UserIcon className="w-8 h-8 text-primary-600 mr-4" />
                <div>
                  <div className="text-lg font-semibold text-gray-900">Pessoa Física</div>
                  <div className="text-sm text-gray-500">Cadastro com CPF</div>
                </div>
              </label>
              
              <label className={`flex items-center p-6 border-2 rounded-xl cursor-pointer transition-all ${
                formData.type === 'PJ' ? 'border-primary-500 bg-primary-50' : 'border-gray-200 hover:border-gray-300'
              }`}>
                <input
                  type="radio"
                  name="type"
                  value="PJ"
                  checked={formData.type === 'PJ'}
                  onChange={handleChange}
                  className="sr-only"
                />
                <BuildingOfficeIcon className="w-8 h-8 text-primary-600 mr-4" />
                <div>
                  <div className="text-lg font-semibold text-gray-900">Pessoa Jurídica</div>
                  <div className="text-sm text-gray-500">Cadastro com CNPJ</div>
                </div>
              </label>
            </div>
          </div>

          {/* Dados Básicos */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Dados Básicos</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {formData.type === 'PF' ? 'Nome Completo' : 'Razão Social'} *
                </label>
                <input
                  type="text"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.name ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
                {errors.name && <p className="text-red-500 text-sm mt-1">{errors.name}</p>}
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {formData.type === 'PF' ? 'CPF' : 'CNPJ'} *
                </label>
                <input
                  type="text"
                  name="document"
                  value={formData.document}
                  onChange={handleDocumentChange}
                  maxLength={formData.type === 'PF' ? 14 : 18}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.document ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
                {errors.document && <p className="text-red-500 text-sm mt-1">{errors.document}</p>}
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Email *</label>
                <div className="relative">
                  <EnvelopeIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <input
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                      errors.email ? 'border-red-300' : 'border-gray-300'
                    }`}
                  />
                </div>
                {errors.email && <p className="text-red-500 text-sm mt-1">{errors.email}</p>}
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Telefone *</label>
                <div className="relative">
                  <PhoneIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    name="phone"
                    value={formData.phone}
                    onChange={handlePhoneChange}
                    maxLength={15}
                    className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                      errors.phone ? 'border-red-300' : 'border-gray-300'
                    }`}
                  />
                </div>
                {errors.phone && <p className="text-red-500 text-sm mt-1">{errors.phone}</p>}
              </div>
            </div>


            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Responsável *</label>
              <select
                name="responsavel_id"
                value={formData.responsavel_id || ''}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Selecione um responsável</option>
                {responsaveis.map(resp => (
                  <option key={resp.id} value={resp.id}>
                    {resp.name} {resp.oab ? `- OAB: ${resp.oab}` : ''}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Endereço */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Endereço</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">CEP</label>
                <div className="relative">
                  <MapPinIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    name="cep"
                    value={formData.cep}
                    onChange={handleCEPChange}
                    maxLength={9}
                    className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                    placeholder="00000-000"
                  />
                </div>
              </div>
              
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">Logradouro</label>
                <input
                  type="text"
                  name="street"
                  value={formData.street}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Rua, Avenida, etc."
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Número</label>
                <input
                  type="text"
                  name="number"
                  value={formData.number}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="123"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Complemento</label>
                <input
                  type="text"
                  name="complement"
                  value={formData.complement}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Apto, Sala, etc."
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Bairro</label>
                <input
                  type="text"
                  name="neighborhood"
                  value={formData.neighborhood}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Centro"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Cidade</label>
                <input
                  type="text"
                  name="city"
                  value={formData.city}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="São Paulo"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Estado</label>
                <select
                  name="state"
                  value={formData.state}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="SP">São Paulo</option>
                  <option value="RJ">Rio de Janeiro</option>
                  <option value="MG">Minas Gerais</option>
                  <option value="RS">Rio Grande do Sul</option>
                  <option value="PR">Paraná</option>
                  <option value="SC">Santa Catarina</option>
                  <option value="BA">Bahia</option>
                  <option value="GO">Goiás</option>
                  <option value="DF">Distrito Federal</option>
                </select>
              </div>
            </div>
          </div>

          {/* Configurações */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Configurações</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
                <select
                  name="status"
                  value={formData.status}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="Ativo">Ativo</option>
                  <option value="Inativo">Inativo</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Tipo de Armazenamento</label>
                <select
                  name="storageType"
                  value={formData.storageType}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="local">Local</option>
                  <option value="googledrive">Google Drive</option>
                  <option value="onedrive">OneDrive</option>
                </select>
              </div>
            </div>
            
            {/* Acesso ao Portal */}
            <div className="mt-6">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  name="portalAccess"
                  checked={formData.portalAccess}
                  onChange={handleChange}
                  className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                />
                <span className="ml-3 text-sm font-medium text-gray-700">
                  Habilitar acesso ao portal do cliente
                </span>
              </label>
            </div>
            
            {/* Senha do Portal */}
            {formData.portalAccess && (
              <div className="mt-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Senha do Portal
                  {!id && <span className="text-red-500"> *</span>}
                </label>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    name="password"
                    value={formData.password}
                    onChange={handleChange}
                    className={`w-full px-4 py-3 pr-10 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                      errors.password ? 'border-red-300' : 'border-gray-300'
                    }`}
                    placeholder={id ? "Deixe em branco para manter a senha atual" : "Senha para acesso"}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  >
                    {showPassword ? (
                      <EyeSlashIcon className="h-5 w-5 text-gray-400" />
                    ) : (
                      <EyeIcon className="h-5 w-5 text-gray-400" />
                    )}
                  </button>
                </div>
                {errors.password && <p className="text-red-500 text-sm mt-1">{errors.password}</p>}
                {id && (
                  <p className="text-sm text-gray-500 mt-1">
                    Deixe em branco para manter a senha atual
                  </p>
                )}
              </div>
            )}
            
            {/* Observações */}
            <div className="mt-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">Observações</label>
              <div className="relative">
                <DocumentTextIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <textarea
                  name="observations"
                  value={formData.observations}
                  onChange={handleChange}
                  rows={4}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Observações sobre o cliente..."
                />
              </div>
            </div>
          </div>

          {/* Botões */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex justify-end space-x-4">
              <Link
                to="/admin/clientes"
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
                  Tem certeza que deseja excluir este cliente? Esta ação não pode ser desfeita e removerá:
                </p>
                <ul className="mt-2 text-sm text-gray-600 list-disc list-inside text-left">
                  <li>Todos os dados do cliente</li>
                  <li>Relacionamentos com processos</li>
                  <li>Histórico de atendimentos</li>
                  <li>Documentos vinculados</li>
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

export default EditClient;
