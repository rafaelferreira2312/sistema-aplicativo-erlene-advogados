import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  UserIcon,
  BuildingOfficeIcon,
  EnvelopeIcon,
  PhoneIcon,
  MapPinIcon,
  EyeIcon,
  EyeSlashIcon,
  DocumentTextIcon
} from '@heroicons/react/24/outline';

const NewClient = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  
  const [formData, setFormData] = useState({
    // Dados básicos
    type: 'PF',
    name: '',
    document: '',
    email: '',
    phone: '',
    
    // Endereço
    cep: '',
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: 'SP',
    
    // Configurações
    status: 'Ativo',
    portalAccess: false,
    password: '',
    storageType: 'local',
    observations: ''
  });

  const [errors, setErrors] = useState({});

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
      // CPF: 000.000.000-00
      return numbers.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    } else {
      // CNPJ: 00.000.000/0000-00
      return numbers.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
    }
  };

  const formatPhone = (value) => {
    const numbers = value.replace(/\D/g, '');
    // (00) 00000-0000
    return numbers.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
  };

  const formatCEP = (value) => {
    const numbers = value.replace(/\D/g, '');
    // 00000-000
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
    
    if (formData.portalAccess && !formData.password) {
      newErrors.password = 'Senha é obrigatória para acesso ao portal';
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
      alert('Cliente cadastrado com sucesso!');
      navigate('/admin/clientes');
    } catch (error) {
      alert('Erro ao cadastrar cliente');
    } finally {
      setLoading(false);
    }
  };

  return (
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
              <h1 className="text-3xl font-bold text-gray-900">Novo Cliente</h1>
              <p className="text-lg text-gray-600 mt-2">Cadastre um novo cliente no sistema</p>
            </div>
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
                placeholder={formData.type === 'PF' ? 'João Silva Santos' : 'Empresa ABC Ltda'}
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
                placeholder={formData.type === 'PF' ? '000.000.000-00' : '00.000.000/0000-00'}
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
                  placeholder="email@exemplo.com"
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
                  placeholder="(11) 99999-9999"
                />
              </div>
              {errors.phone && <p className="text-red-500 text-sm mt-1">{errors.phone}</p>}
            </div>
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
              <label className="block text-sm font-medium text-gray-700 mb-2">Senha do Portal *</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 pr-10 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.password ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="Senha para acesso"
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
              disabled={loading}
              className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Salvando...
                </div>
              ) : (
                'Salvar Cliente'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewClient;
