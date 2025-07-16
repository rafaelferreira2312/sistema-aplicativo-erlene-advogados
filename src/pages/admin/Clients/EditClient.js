import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
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

const EditClient = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [isLoading, setIsLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(true);
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

  useEffect(() => {
    const loadClientData = async () => {
      setLoadingData(true);
      try {
        // Simular carregamento dos dados do cliente
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Mock data baseado no ID
        const mockClients = {
          '1': {
            nome: 'Maria Silva Santos',
            email: 'maria.silva@email.com',
            telefone: '(11) 99999-9999',
            cpf_cnpj: '123.456.789-00',
            tipo_pessoa: 'PF',
            cep: '01234-567',
            endereco: 'Rua das Flores',
            numero: '123',
            complemento: 'Apto 45',
            bairro: 'Centro',
            cidade: 'São Paulo',
            estado: 'SP',
            status: 'ativo',
            observacoes: 'Cliente preferencial',
            acesso_portal: true,
            senha_portal: '',
            tipo_armazenamento: 'local'
          },
          '2': {
            nome: 'Empresa ABC Ltda',
            email: 'contato@empresaabc.com.br',
            telefone: '(11) 3333-4444',
            cpf_cnpj: '12.345.678/0001-90',
            tipo_pessoa: 'PJ',
            cep: '01310-100',
            endereco: 'Av. Paulista',
            numero: '1000',
            complemento: 'Sala 1001',
            bairro: 'Bela Vista',
            cidade: 'São Paulo',
            estado: 'SP',
            status: 'ativo',
            observacoes: 'Empresa parceira',
            acesso_portal: false,
            senha_portal: '',
            tipo_armazenamento: 'google_drive'
          }
        };
        
        const clientData = mockClients[id];
        if (clientData) {
          setFormData(clientData);
        } else {
          navigate('/admin/clients');
        }
      } catch (error) {
        console.error('Erro ao carregar cliente:', error);
        navigate('/admin/clients');
      } finally {
        setLoadingData(false);
      }
    };

    loadClientData();
  }, [id, navigate]);

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

  const validateForm = () => {
    const newErrors = {};
    if (!formData.nome.trim()) newErrors.nome = 'Nome é obrigatório';
    if (!formData.email.trim()) newErrors.email = 'E-mail é obrigatório';
    if (!formData.telefone.trim()) newErrors.telefone = 'Telefone é obrigatório';
    
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
      console.log('Cliente atualizado:', formData);
      navigate('/admin/clients', { 
        state: { message: 'Cliente atualizado com sucesso!' }
      });
    } catch (error) {
      console.error('Erro ao atualizar cliente:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (loadingData) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando dados do cliente...</p>
        </div>
      </div>
    );
  }

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
          <h1 className="text-3xl font-bold text-gray-900">Editar Cliente</h1>
          <p className="mt-1 text-lg text-gray-600">Edite os dados do cliente: {formData.nome}</p>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Tipo de Pessoa (somente visualização) */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Tipo de Cliente</h2>
          <div className="flex items-center space-x-3 p-4 border rounded-lg bg-gray-50">
            {formData.tipo_pessoa === 'PF' ? (
              <UserIcon className="h-6 w-6 text-blue-500" />
            ) : (
              <BuildingOfficeIcon className="h-6 w-6 text-green-500" />
            )}
            <div>
              <div className="text-sm font-medium text-gray-900">
                {formData.tipo_pessoa === 'PF' ? 'Pessoa Física' : 'Pessoa Jurídica'}
              </div>
              <div className="text-sm text-gray-500">
                {formData.tipo_pessoa === 'PF' ? 'Cliente individual' : 'Empresa ou organização'}
              </div>
            </div>
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
                className="block w-full rounded-lg border border-gray-300 shadow-sm p-3 bg-gray-50 text-gray-500"
                readOnly
              />
              <p className="mt-1 text-xs text-gray-500">CPF/CNPJ não pode ser alterado</p>
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
                  onChange={handleInputChange}
                  className={`block w-full pl-10 pr-3 py-3 rounded-lg border shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 ${
                    errors.telefone ? 'border-red-300' : 'border-gray-300'
                  }`}
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
                  onChange={handleInputChange}
                  className="block w-full pl-10 pr-3 py-3 rounded-lg border-gray-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
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
                  <label className="block text-sm font-medium text-gray-700 mb-2">Nova Senha do Portal</label>
                  <div className="relative">
                    <input
                      type={showPassword ? 'text' : 'password'}
                      name="senha_portal"
                      value={formData.senha_portal}
                      onChange={handleInputChange}
                      className={`block w-full pr-10 p-3 rounded-lg border shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 ${
                        errors.senha_portal ? 'border-red-300' : 'border-gray-300'
                      }`}
                      placeholder="Deixe vazio para manter a senha atual"
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
                Atualizando...
              </div>
            ) : (
              'Atualizar Cliente'
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default EditClient;
