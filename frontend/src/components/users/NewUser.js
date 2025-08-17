import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { 
  UserPlusIcon,
  EyeIcon,
  EyeSlashIcon,
  ExclamationCircleIcon,
  CheckCircleIcon,
  ArrowLeftIcon
} from '@heroicons/react/24/outline';

const NewUser = () => {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [errors, setErrors] = useState({});
  const [success, setSuccess] = useState('');

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    role: '',
    unit: '',
    password: '',
    confirmPassword: '',
    status: 'Ativo',
    permissions: []
  });

  // Opções de perfis
  const roles = [
    { value: '', label: 'Selecione o perfil...' },
    { value: 'Administrador', label: 'Administrador', description: 'Acesso total ao sistema' },
    { value: 'Advogado Sênior', label: 'Advogado Sênior', description: 'Acesso completo a processos e relatórios' },
    { value: 'Advogado', label: 'Advogado', description: 'Acesso a processos e clientes' },
    { value: 'Assistente Jurídico', label: 'Assistente Jurídico', description: 'Acesso limitado a processos' },
    { value: 'Secretária', label: 'Secretária', description: 'Acesso a agenda e clientes' },
    { value: 'Estagiário', label: 'Estagiário', description: 'Acesso apenas leitura' }
  ];

  // Opções de unidades
  const units = [
    { value: '', label: 'Selecione a unidade...' },
    { value: 'Matriz', label: 'Matriz - São Paulo' },
    { value: 'Filial SP', label: 'Filial - Santos/SP' },
    { value: 'Filial RJ', label: 'Filial - Rio de Janeiro/RJ' },
    { value: 'Filial MG', label: 'Filial - Belo Horizonte/MG' }
  ];

  // Permissões por perfil
  const permissionsByRole = {
    'Administrador': [
      'full_access', 'users_manage', 'settings_manage', 'reports_full', 
      'financial_full', 'processes_full', 'clients_full', 'documents_full'
    ],
    'Advogado Sênior': [
      'processes_full', 'clients_full', 'reports_view', 'financial_view', 
      'documents_full', 'schedule_manage'
    ],
    'Advogado': [
      'processes_manage', 'clients_manage', 'documents_manage', 'schedule_manage'
    ],
    'Assistente Jurídico': [
      'processes_view', 'clients_manage', 'documents_manage', 'schedule_view'
    ],
    'Secretária': [
      'clients_manage', 'schedule_manage', 'documents_view'
    ],
    'Estagiário': [
      'processes_view', 'clients_view', 'documents_view'
    ]
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
      // Atualizar permissões automaticamente quando o perfil muda
      ...(name === 'role' && { permissions: permissionsByRole[value] || [] })
    }));
    
    // Limpar erro do campo quando o usuário começar a digitar
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    // Validar nome
    if (!formData.name.trim()) {
      newErrors.name = 'Nome é obrigatório';
    } else if (formData.name.length < 3) {
      newErrors.name = 'Nome deve ter pelo menos 3 caracteres';
    }

    // Validar email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!formData.email.trim()) {
      newErrors.email = 'Email é obrigatório';
    } else if (!emailRegex.test(formData.email)) {
      newErrors.email = 'Email deve ter um formato válido';
    }

    // Validar telefone
    if (!formData.phone.trim()) {
      newErrors.phone = 'Telefone é obrigatório';
    } else if (formData.phone.length < 10) {
      newErrors.phone = 'Telefone deve ter pelo menos 10 dígitos';
    }

    // Validar perfil
    if (!formData.role) {
      newErrors.role = 'Perfil é obrigatório';
    }

    // Validar unidade
    if (!formData.unit) {
      newErrors.unit = 'Unidade é obrigatória';
    }

    // Validar senha
    if (!formData.password) {
      newErrors.password = 'Senha é obrigatória';
    } else if (formData.password.length < 6) {
      newErrors.password = 'Senha deve ter pelo menos 6 caracteres';
    }

    // Validar confirmação de senha
    if (!formData.confirmPassword) {
      newErrors.confirmPassword = 'Confirmação de senha é obrigatória';
    } else if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Senhas não coincidem';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setIsLoading(true);
    setErrors({});

    try {
      // Simular chamada à API
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      console.log('Dados do usuário:', {
        ...formData,
        permissions: permissionsByRole[formData.role] || []
      });

      setSuccess('Usuário criado com sucesso!');
      
      // Redirecionar após 2 segundos
      setTimeout(() => {
        navigate('/admin/users');
      }, 2000);

    } catch (error) {
      setErrors({ submit: 'Erro ao criar usuário. Tente novamente.' });
    } finally {
      setIsLoading(false);
    }
  };

  const getPermissionDescription = (permission) => {
    const descriptions = {
      'full_access': 'Acesso total ao sistema',
      'users_manage': 'Gerenciar usuários',
      'settings_manage': 'Gerenciar configurações',
      'reports_full': 'Acesso completo a relatórios',
      'financial_full': 'Acesso completo ao financeiro',
      'processes_full': 'Acesso completo a processos',
      'clients_full': 'Acesso completo a clientes',
      'documents_full': 'Acesso completo a documentos',
      'processes_manage': 'Gerenciar processos',
      'clients_manage': 'Gerenciar clientes',
      'documents_manage': 'Gerenciar documentos',
      'schedule_manage': 'Gerenciar agenda',
      'processes_view': 'Visualizar processos',
      'clients_view': 'Visualizar clientes',
      'documents_view': 'Visualizar documentos',
      'schedule_view': 'Visualizar agenda',
      'reports_view': 'Visualizar relatórios',
      'financial_view': 'Visualizar financeiro'
    };
    return descriptions[permission] || permission;
  };

  return (
    <div className="max-w-4xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center space-x-4 mb-4">
          <Link
            to="/admin/users"
            className="inline-flex items-center text-sm text-gray-500 hover:text-gray-700"
          >
            <ArrowLeftIcon className="h-4 w-4 mr-1" />
            Voltar para Usuários
          </Link>
        </div>
        <div className="flex items-center space-x-3">
          <div className="flex-shrink-0">
            <UserPlusIcon className="h-8 w-8 text-primary-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Novo Usuário</h1>
            <p className="text-sm text-gray-600">
              Preencha as informações para criar um novo usuário
            </p>
          </div>
        </div>
      </div>

      {/* Success Message */}
      {success && (
        <div className="mb-6 rounded-md bg-green-50 p-4">
          <div className="flex">
            <div className="flex-shrink-0">
              <CheckCircleIcon className="h-5 w-5 text-green-400" />
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-green-800">{success}</p>
            </div>
          </div>
        </div>
      )}

      {/* Form */}
      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
              Informações Pessoais
            </h3>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              {/* Nome Completo */}
              <div>
                <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                  Nome Completo *
                </label>
                <input
                  type="text"
                  name="name"
                  id="name"
                  value={formData.name}
                  onChange={handleInputChange}
                  className={`mt-1 block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 ${
                    errors.name ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="Ex: Dr. João Silva Santos"
                />
                {errors.name && (
                  <p className="mt-1 text-sm text-red-600 flex items-center">
                    <ExclamationCircleIcon className="h-4 w-4 mr-1" />
                    {errors.name}
                  </p>
                )}
              </div>

              {/* Email */}
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                  Email Profissional *
                </label>
                <input
                  type="email"
                  name="email"
                  id="email"
                  value={formData.email}
                  onChange={handleInputChange}
                  className={`mt-1 block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 ${
                    errors.email ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="joao@erleneadvogados.com.br"
                />
                {errors.email && (
                  <p className="mt-1 text-sm text-red-600 flex items-center">
                    <ExclamationCircleIcon className="h-4 w-4 mr-1" />
                    {errors.email}
                  </p>
                )}
              </div>

              {/* Telefone */}
              <div>
                <label htmlFor="phone" className="block text-sm font-medium text-gray-700">
                  Telefone *
                </label>
                <input
                  type="tel"
                  name="phone"
                  id="phone"
                  value={formData.phone}
                  onChange={handleInputChange}
                  className={`mt-1 block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 ${
                    errors.phone ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="(11) 99999-9999"
                />
                {errors.phone && (
                  <p className="mt-1 text-sm text-red-600 flex items-center">
                    <ExclamationCircleIcon className="h-4 w-4 mr-1" />
                    {errors.phone}
                  </p>
                )}
              </div>

              {/* Status */}
              <div>
                <label htmlFor="status" className="block text-sm font-medium text-gray-700">
                  Status *
                </label>
                <select
                  name="status"
                  id="status"
                  value={formData.status}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="Ativo">Ativo</option>
                  <option value="Inativo">Inativo</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        {/* Informações Profissionais */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
              Informações Profissionais
            </h3>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              {/* Perfil */}
              <div>
                <label htmlFor="role" className="block text-sm font-medium text-gray-700">
                  Perfil *
                </label>
                <select
                  name="role"
                  id="role"
                  value={formData.role}
                  onChange={handleInputChange}
                  className={`mt-1 block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 ${
                    errors.role ? 'border-red-300' : 'border-gray-300'
                  }`}
                >
                  {roles.map((role) => (
                    <option key={role.value} value={role.value}>
                      {role.label}
                    </option>
                  ))}
                </select>
                {errors.role && (
                  <p className="mt-1 text-sm text-red-600 flex items-center">
                    <ExclamationCircleIcon className="h-4 w-4 mr-1" />
                    {errors.role}
                  </p>
                )}
                {formData.role && (
                  <p className="mt-1 text-sm text-gray-500">
                    {roles.find(r => r.value === formData.role)?.description}
                  </p>
                )}
              </div>

              {/* Unidade */}
              <div>
                <label htmlFor="unit" className="block text-sm font-medium text-gray-700">
                  Unidade *
                </label>
                <select
                  name="unit"
                  id="unit"
                  value={formData.unit}
                  onChange={handleInputChange}
                  className={`mt-1 block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 ${
                    errors.unit ? 'border-red-300' : 'border-gray-300'
                  }`}
                >
                  {units.map((unit) => (
                    <option key={unit.value} value={unit.value}>
                      {unit.label}
                    </option>
                  ))}
                </select>
                {errors.unit && (
                  <p className="mt-1 text-sm text-red-600 flex items-center">
                    <ExclamationCircleIcon className="h-4 w-4 mr-1" />
                    {errors.unit}
                  </p>
                )}
              </div>
            </div>

            {/* Permissões */}
            {formData.role && (
              <div className="mt-6">
                <label className="block text-sm font-medium text-gray-700 mb-3">
                  Permissões do Perfil
                </label>
                <div className="bg-gray-50 rounded-lg p-4">
                  <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
                    {(permissionsByRole[formData.role] || []).map((permission) => (
                      <div key={permission} className="flex items-center text-sm text-gray-600">
                        <CheckCircleIcon className="h-4 w-4 text-green-500 mr-2 flex-shrink-0" />
                        {getPermissionDescription(permission)}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Senha */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
              Definir Senha de Acesso
            </h3>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              {/* Senha */}
              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                  Senha *
                </label>
                <div className="mt-1 relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    name="password"
                    id="password"
                    value={formData.password}
                    onChange={handleInputChange}
                    className={`block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 pr-10 ${
                      errors.password ? 'border-red-300' : 'border-gray-300'
                    }`}
                    placeholder="Mínimo 6 caracteres"
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
                {errors.password && (
                  <p className="mt-1 text-sm text-red-600 flex items-center">
                    <ExclamationCircleIcon className="h-4 w-4 mr-1" />
                    {errors.password}
                  </p>
                )}
              </div>

              {/* Confirmar Senha */}
              <div>
                <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700">
                  Confirmar Senha *
                </label>
                <div className="mt-1 relative">
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    name="confirmPassword"
                    id="confirmPassword"
                    value={formData.confirmPassword}
                    onChange={handleInputChange}
                    className={`block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 pr-10 ${
                      errors.confirmPassword ? 'border-red-300' : 'border-gray-300'
                    }`}
                    placeholder="Digite a senha novamente"
                  />
                  <button
                    type="button"
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  >
                    {showConfirmPassword ? (
                      <EyeSlashIcon className="h-5 w-5 text-gray-400" />
                    ) : (
                      <EyeIcon className="h-5 w-5 text-gray-400" />
                    )}
                  </button>
                </div>
                {errors.confirmPassword && (
                  <p className="mt-1 text-sm text-red-600 flex items-center">
                    <ExclamationCircleIcon className="h-4 w-4 mr-1" />
                    {errors.confirmPassword}
                  </p>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Error Message */}
        {errors.submit && (
          <div className="rounded-md bg-red-50 p-4">
            <div className="flex">
              <div className="flex-shrink-0">
                <ExclamationCircleIcon className="h-5 w-5 text-red-400" />
              </div>
              <div className="ml-3">
                <p className="text-sm font-medium text-red-800">{errors.submit}</p>
              </div>
            </div>
          </div>
        )}

        {/* Actions */}
        <div className="flex justify-end space-x-3">
          <Link
            to="/admin/users"
            className="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
          >
            Cancelar
          </Link>
          <button
            type="submit"
            disabled={isLoading}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Criando...
              </>
            ) : (
              <>
                <UserPlusIcon className="-ml-1 mr-2 h-4 w-4" />
                Criar Usuário
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default NewUser;
