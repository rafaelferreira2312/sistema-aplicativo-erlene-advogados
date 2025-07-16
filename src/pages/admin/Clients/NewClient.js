import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  ArrowLeftIcon,
  UserIcon,
  BuildingOfficeIcon,
  EnvelopeIcon,
  PhoneIcon,
  EyeIcon,
  EyeSlashIcon,
  MapPinIcon
} from '@heroicons/react/24/outline';

const NewClient = () => {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [formData, setFormData] = useState({
    nome: '',
    email: '',
    telefone: '',
    cpf_cnpj: '',
    tipo_pessoa: 'PF',
    cep: '',
    endereco: '',
    numero: '',
    complemento: '',
    bairro: '',
    cidade: '',
    estado: '',
    status: 'ativo',
    observacoes: '',
    acesso_portal: false,
    senha_portal: '',
    tipo_armazenamento: 'local'
  });

  const [errors, setErrors] = useState({});

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const formatCpfCnpj = (value) => {
    const numbers = value.replace(/\D/g, '');
    
    if (formData.tipo_pessoa === 'PF') {
      return numbers.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    } else {
      return numbers.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
    }
  };

  const formatPhone = (value) => {
    const numbers = value.replace(/\D/g, '');
    if (numbers.length <= 10) {
      return numbers.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
    } else {
      return numbers.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
    }
  };

  const formatCep = (value) => {
    const numbers = value.replace(/\D/g, '');
    return numbers.replace(/(\d{5})(\d{3})/, '$1-$2');
  };

  const handleCpfCnpjChange = (e) => {
    const formatted = formatCpfCnpj(e.target.value);
    setFormData(prev => ({ ...prev, cpf_cnpj: formatted }));
  };

  const handlePhoneChange = (e) => {
    const formatted = formatPhone(e.target.value);
    setFormData(prev => ({ ...prev, telefone: formatted }));
  };

  const handleCepChange = (e) => {
    const formatted = formatCep(e.target.value);
    setFormData(prev => ({ ...prev, cep: formatted }));
  };

  const validateForm = () => {
    const newErrors = {};
    if (!formData.nome.trim()) newErrors.nome = 'Nome é obrigatório';
    if (!formData.email.trim()) newErrors.email = 'E-mail é obrigatório';
    if (!formData.telefone.trim()) newErrors.telefone = 'Telefone é obrigatório';
    if (!formData.cpf_cnpj.trim()) newErrors.cpf_cnpj = 'CPF/CNPJ é obrigatório';
    
    if (formData.acesso_portal && !formData.senha_portal.trim()) {
      newErrors.senha_portal = 'Senha é obrigatória quando acesso ao portal está habilitado';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setIsLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      console.log('Cliente cadastrado:', formData);
      navigate('/admin/clients', { 
        state: { message: 'Cliente cadastrado com sucesso!' }
      });
    } catch (error) {
      console.error('Erro ao cadastrar cliente:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center space-x-4">
        <button
          onClick={() => navigate('/admin/clients')}
          className="p-2 text-gray-400 hover:text-gray-600 transition-colors"
        >
          <ArrowLeftIcon className="h-6 w-6" />
        </button>
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Novo Cliente</h1>
          <p className="mt-1 text-lg text-gray-600">Cadastre um novo cliente no sistema</p>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Tipo de Pessoa */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Tipo de Cliente</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <label className={`relative flex cursor-pointer rounded-lg border p-4 focus:outline-none ${
              formData.tipo_pessoa === 'PF' 
                ? 'border-primary-500 bg-primary-50' 
                : 'border-gray-300'
            }`}>
              <input
                type="radio"
                name="tipo_pessoa"
                value="PF"
                checked={formData.tipo_pessoa === 'PF'}
                onChange={handleInputChange}
                className="sr-only"
              />
              <div className="flex items-center space-x-3">
                <UserIcon className="h-6 w-6 text-blue-500" />
                <div>
                  <div className="text-sm font-medium text-gray-900">Pessoa Física</div>
                  <div className="text-sm text-gray-500">Cliente individual</div>
                </div>
              </div>
            </label>

            <label className={`relative flex cursor-pointer rounded-lg border p-4 focus:outline-none ${
              formData.tipo_pessoa === 'PJ' 
                ? 'border-primary-500 bg-primary-50' 
                : 'border-gray-300'
            }`}>
              <input
                type="radio"
                name="tipo_pessoa"
                value="PJ"
                checked={formData.tipo_pessoa === 'PJ'}
                onChange={handleInputChange}
                className="sr-only"
              />
              <div className="flex items-center space-x-3">
                <BuildingOfficeIcon className="h-6 w-6 text-green-500" />
                <div>
                  <div className="text-sm font-medium text-gray-900">Pessoa Jurídica</div>
                  <div className="text-sm text-gray-500">Empresa ou organização</div>
                </div>
              </div>
            </label>
          </div>
        </div>

        {/* Dados Básicos */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-6">Dados Básicos</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                {formData.tipo_pessoa === 'PF' ? 'Nome Completo' : 'Razão Social'} *
              </label>
              <input
                type="text"
                name="nome"
                value={formData.nome}
                onChange={handleInputChange}
                className={`block w-full rounded-lg border shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 p-3 ${
                  errors.nome ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder={formData.tipo_pessoa === 'PF' ? 'Ex: João Silva Santos' : 'Ex: Empresa ABC Ltda'}
              />
              {errors.nome && <p className="mt-1 text-sm text-red-600">{errors.nome}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                {formData.tipo_pessoa === 'PF' ? 'CPF' : 'CNPJ'} *
              </label>
              <input
                type="text"
                name="cpf_cnpj"
                value={formData.cpf_cnpj}
                onChange={handleCpfCnpjChange}
                maxLength={formData.tipo_pessoa === 'PF' ? 14 : 18}
                className={`block w-full rounded-lg border shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 p-3 ${
                  errors.cpf_cnpj ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder={formData.tipo_pessoa === 'PF' ? '000.000.000-00' : '00.000.000/0000-00'}
              />
              {errors.cpf_cnpj && <p className="mt-1 text-sm text-red-600">{errors.cpf_cnpj}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">E-mail *</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <EnvelopeIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleInputChange}
                  className={`block w-full pl-10 pr-3 py-3 rounded-lg border shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 ${
                    errors.email ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="cliente@email.com"
                />
              </div>
              {errors.email && <p className="mt-1 text-sm text-red-600">{errors.email}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Telefone *</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <PhoneIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type="text"
                  name="telefone"
                  value={formData.telefone}
                  onChange={handlePhoneChange}
                  maxLength={15}
                  className={`block w-full pl-10 pr-3 py-3 rounded-lg border shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 ${
                    errors.telefone ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="(11) 99999-9999"
                />
              </div>
              {errors.telefone && <p className="mt-1 text-sm text-red-600">{errors.telefone}</p>}
            </div>
          </div>
        </div>

        {/* Endereço */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-6">Endereço</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">CEP</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <MapPinIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type="text"
                  name="cep"
                  value={formData.cep}
                  onChange={handleCepChange}
                  maxLength={9}
                  className="block w-full pl-10 pr-3 py-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  placeholder="00000-000"
                />
              </div>
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">Endereço</label>
              <input
                type="text"
                name="endereco"
                value={formData.endereco}
                onChange={handleInputChange}
                className="block w-full p-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Rua, Avenida, etc."
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Número</label>
              <input
                type="text"
                name="numero"
                value={formData.numero}
                onChange={handleInputChange}
                className="block w-full p-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="123"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Complemento</label>
              <input
                type="text"
                name="complemento"
                value={formData.complemento}
                onChange={handleInputChange}
                className="block w-full p-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Apto, Sala, etc."
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Bairro</label>
              <input
                type="text"
                name="bairro"
                value={formData.bairro}
                onChange={handleInputChange}
                className="block w-full p-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Bairro"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Cidade</label>
              <input
                type="text"
                name="cidade"
                value={formData.cidade}
                onChange={handleInputChange}
                className="block w-full p-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="São Paulo"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Estado</label>
              <select
                name="estado"
                value={formData.estado}
                onChange={handleInputChange}
                className="block w-full p-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Selecione</option>
                <option value="SP">São Paulo</option>
                <option value="RJ">Rio de Janeiro</option>
                <option value="MG">Minas Gerais</option>
                <option value="RS">Rio Grande do Sul</option>
                <option value="PR">Paraná</option>
                <option value="SC">Santa Catarina</option>
                <option value="BA">Bahia</option>
                <option value="DF">Distrito Federal</option>
              </select>
            </div>
          </div>
        </div>

        {/* Configurações */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-6">Configurações</h2>
          <div className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
                <select
                  name="status"
                  value={formData.status}
                  onChange={handleInputChange}
                  className="block w-full p-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="ativo">Ativo</option>
                  <option value="inativo">Inativo</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Tipo de Armazenamento</label>
                <select
                  name="tipo_armazenamento"
                  value={formData.tipo_armazenamento}
                  onChange={handleInputChange}
                  className="block w-full p-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="local">Local (Servidor)</option>
                  <option value="google_drive">Google Drive</option>
                  <option value="onedrive">OneDrive</option>
                  <option value="hibrido">Híbrido</option>
                </select>
              </div>
            </div>

            {/* Acesso ao Portal */}
            <div className="border border-gray-200 rounded-lg p-4">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h3 className="text-sm font-medium text-gray-900">Acesso ao Portal do Cliente</h3>
                  <p className="text-sm text-gray-500">Permitir que o cliente acesse o portal online</p>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    name="acesso_portal"
                    checked={formData.acesso_portal}
                    onChange={handleInputChange}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                </label>
              </div>
              
              {formData.acesso_portal && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Senha do Portal *</label>
                  <div className="relative">
                    <input
                      type={showPassword ? 'text' : 'password'}
                      name="senha_portal"
                      value={formData.senha_portal}
                      onChange={handleInputChange}
                      className={`block w-full pr-10 p-3 rounded-lg border shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 ${
                        errors.senha_portal ? 'border-red-300' : 'border-gray-300'
                      }`}
                      placeholder="Digite a senha para acesso ao portal"
                    />
                    <button
                      type="button"
                      className="absolute inset-y-0 right-0 pr-3 flex items-center"
                      onClick={() => setShowPassword(!showPassword)}
                    >
                      {showPassword ? (
                        <EyeSlashIcon className="h-5 w-5 text-gray-400" />
                      ) : (
                        <EyeIcon className="h-5 w-5 text-gray-400" />
                      )}
                    </button>
                  </div>
                  {errors.senha_portal && <p className="mt-1 text-sm text-red-600">{errors.senha_portal}</p>}
                </div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Observações</label>
              <textarea
                name="observacoes"
                value={formData.observacoes}
                onChange={handleInputChange}
                rows={3}
                className="block w-full p-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Observações gerais sobre o cliente..."
              />
            </div>
          </div>
        </div>

        {/* Botões de Ação */}
        <div className="flex items-center justify-end space-x-4 pt-6 border-t border-gray-200">
          <button
            type="button"
            onClick={() => navigate('/admin/clients')}
            className="px-6 py-3 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-colors"
          >
            Cancelar
          </button>
          <button
            type="submit"
            disabled={isLoading}
            className="px-6 py-3 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-gradient-erlene hover:shadow-erlene-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
          >
            {isLoading ? (
              <div className="flex items-center">
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Salvando...
              </div>
            ) : (
              'Cadastrar Cliente'
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default NewClient;
