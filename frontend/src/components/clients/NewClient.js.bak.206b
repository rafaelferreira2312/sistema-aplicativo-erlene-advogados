import React, { useState, useEffect } from 'react';
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
import { clientsService } from '../../services/api/clientsService';
import { formatDocument, formatPhone, formatCEP } from '../../utils/formatters';
import { clientValidators } from '../../utils/validators';
import toast from 'react-hot-toast';

const NewClient = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [loadingCep, setLoadingCep] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [responsaveis, setResponsaveis] = useState([]);
  
  const [formData, setFormData] = useState({
    tipo_pessoa: 'PF',
    nome: '',
    cpf_cnpj: '',
    email: '',
    telefone: '',
    cep: '',
    endereco: '',
    cidade: '',
    estado: 'SP',
    observacoes: '',
    status: 'ativo',
    acesso_portal: false,
    senha_portal: '',
    tipo_armazenamento: 'local',
    responsavel_id: ''
  });

  const [errors, setErrors] = useState({});

  // Carregar responsáveis
  useEffect(() => {
    const loadResponsaveis = async () => {
      try {
        const response = await clientsService.getResponsaveis();
        setResponsaveis(response.data || []);
        
        // Selecionar primeiro responsável por padrão
        if (response.data && response.data.length > 0) {
          setFormData(prev => ({
            ...prev,
            responsavel_id: response.data[0].id
          }));
        }
      } catch (error) {
        console.error('Erro ao carregar responsáveis:', error);
        toast.error('Erro ao carregar responsáveis');
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

  const handleDocumentChange = (e) => {
    const formatted = formatDocument(e.target.value, formData.tipo_pessoa);
    setFormData(prev => ({
      ...prev,
      cpf_cnpj: formatted
    }));
    
    // Limpar erro
    if (errors.cpf_cnpj) {
      setErrors(prev => ({ ...prev, cpf_cnpj: '' }));
    }
  };

  const handlePhoneChange = (e) => {
    const formatted = formatPhone(e.target.value);
    setFormData(prev => ({
      ...prev,
      telefone: formatted
    }));
    
    if (errors.telefone) {
      setErrors(prev => ({ ...prev, telefone: '' }));
    }
  };

  const handleCEPChange = async (e) => {
    const formatted = formatCEP(e.target.value);
    setFormData(prev => ({
      ...prev,
      cep: formatted
    }));
    
    // Buscar endereço por CEP via backend
    if (formatted.length === 9) {
      setLoadingCep(true);
      try {
        const response = await clientsService.buscarCep(formatted);
        const endereco = response.data;
        
        setFormData(prev => ({
          ...prev,
          endereco: endereco.logradouro,
          cidade: endereco.localidade,
          estado: endereco.uf
        }));
        
        toast.success('Endereço encontrado!');
      } catch (error) {
        toast.error('CEP não encontrado');
      } finally {
        setLoadingCep(false);
      }
    }
  };

  const validateForm = () => {
    const validation = clientValidators.validateClientForm(formData, false);
    setErrors(validation.errors);
    return validation.isValid;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      toast.error('Por favor, corrija os erros no formulário');
      return;
    }
    
    setLoading(true);
    
    try {
      const response = await clientsService.createClient(formData);
      
      // Mostrar senha temporária se gerada
      if (response.data.senha_temporaria) {
        toast.success(`Cliente criado! Senha temporária: ${response.data.senha_temporaria}`, {
          duration: 10000,
        });
      }
      
      navigate('/admin/clientes');
    } catch (error) {
      if (error.response && error.response.data && error.response.data.errors) {
        setErrors(error.response.data.errors);
        toast.error('Dados inválidos. Verifique os campos destacados.');
      } else {
        toast.error('Erro ao cadastrar cliente');
      }
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
              formData.tipo_pessoa === 'PF' ? 'border-primary-500 bg-primary-50' : 'border-gray-200 hover:border-gray-300'
            }`}>
              <input
                type="radio"
                name="tipo_pessoa"
                value="PF"
                checked={formData.tipo_pessoa === 'PF'}
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
              formData.tipo_pessoa === 'PJ' ? 'border-primary-500 bg-primary-50' : 'border-gray-200 hover:border-gray-300'
            }`}>
              <input
                type="radio"
                name="tipo_pessoa"
                value="PJ"
                checked={formData.tipo_pessoa === 'PJ'}
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
                {formData.tipo_pessoa === 'PF' ? 'Nome Completo' : 'Razão Social'} *
              </label>
              <input
                type="text"
                name="nome"
                value={formData.nome}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.nome ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder={formData.tipo_pessoa === 'PF' ? 'João Silva Santos' : 'Empresa ABC Ltda'}
              />
              {errors.nome && <p className="text-red-500 text-sm mt-1">{errors.nome}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                {formData.tipo_pessoa === 'PF' ? 'CPF' : 'CNPJ'} *
              </label>
              <input
                type="text"
                name="cpf_cnpj"
                value={formData.cpf_cnpj}
                onChange={handleDocumentChange}
                maxLength={formData.tipo_pessoa === 'PF' ? 14 : 18}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.cpf_cnpj ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder={formData.tipo_pessoa === 'PF' ? '000.000.000-00' : '00.000.000/0000-00'}
              />
              {errors.cpf_cnpj && <p className="text-red-500 text-sm mt-1">{errors.cpf_cnpj}</p>}
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
                  name="telefone"
                  value={formData.telefone}
                  onChange={handlePhoneChange}
                  maxLength={15}
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.telefone ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="(11) 99999-9999"
                />
              </div>
              {errors.telefone && <p className="text-red-500 text-sm mt-1">{errors.telefone}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Responsável *</label>
              <select
                name="responsavel_id"
                value={formData.responsavel_id}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.responsavel_id ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione um responsável</option>
                {responsaveis.map(resp => (
                  <option key={resp.id} value={resp.id}>
                    {resp.name} {resp.oab ? `- OAB: ${resp.oab}` : ''}
                  </option>
                ))}
              </select>
              {errors.responsavel_id && <p className="text-red-500 text-sm mt-1">{errors.responsavel_id}</p>}
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
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    loadingCep ? 'bg-gray-50' : ''
                  } ${errors.cep ? 'border-red-300' : 'border-gray-300'}`}
                  placeholder="00000-000"
                  disabled={loadingCep}
                />
                {loadingCep && (
                  <div className="absolute right-3 top-3">
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-primary-600"></div>
                  </div>
                )}
              </div>
              {errors.cep && <p className="text-red-500 text-sm mt-1">{errors.cep}</p>}
            </div>
            
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">Endereço</label>
              <input
                type="text"
                name="endereco"
                value={formData.endereco}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Rua, Avenida, etc."
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Cidade</label>
              <input
                type="text"
                name="cidade"
                value={formData.cidade}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="São Paulo"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Estado</label>
              <select
                name="estado"
                value={formData.estado}
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
                <option value="ativo">Ativo</option>
                <option value="inativo">Inativo</option>
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Tipo de Armazenamento</label>
              <select
                name="tipo_armazenamento"
                value={formData.tipo_armazenamento}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="local">Local</option>
                <option value="google_drive">Google Drive</option>
                <option value="onedrive">OneDrive</option>
              </select>
            </div>
          </div>
          
          {/* Acesso ao Portal */}
          <div className="mt-6">
            <label className="flex items-center">
              <input
                type="checkbox"
                name="acesso_portal"
                checked={formData.acesso_portal}
                onChange={handleChange}
                className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
              />
              <span className="ml-3 text-sm font-medium text-gray-700">
                Habilitar acesso ao portal do cliente
              </span>
            </label>
          </div>
          
          {/* Senha do Portal */}
          {formData.acesso_portal && (
            <div className="mt-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">Senha do Portal *</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  name="senha_portal"
                  value={formData.senha_portal}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 pr-10 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.senha_portal ? 'border-red-300' : 'border-gray-300'
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
              {errors.senha_portal && <p className="text-red-500 text-sm mt-1">{errors.senha_portal}</p>}
            </div>
          )}
          
          {/* Observações */}
          <div className="mt-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">Observações</label>
            <div className="relative">
              <DocumentTextIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
              <textarea
                name="observacoes"
                value={formData.observacoes}
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
