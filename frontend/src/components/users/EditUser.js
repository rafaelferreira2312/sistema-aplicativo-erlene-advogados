import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { 
  UserIcon,
  EyeIcon,
  EyeSlashIcon,
  ExclamationCircleIcon,
  CheckCircleIcon,
  ArrowLeftIcon,
  KeyIcon,
  TrashIcon
} from '@heroicons/react/24/outline';

const EditUser = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [showPasswordSection, setShowPasswordSection] = useState(false);
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
    status: 'Ativo',
    permissions: [],
    newPassword: '',
    confirmPassword: ''
  });

  // Mock data - simular carregamento do usuário
  const mockUser = {
    id: 2,
    name: 'Dr. João Silva Santos',
    email: 'joao@erleneadvogados.com.br',
    phone: '(11) 98888-8888',
    role: 'Advogado Sênior',
    unit: 'Matriz',
    status: 'Ativo',
    lastLogin: '2024-03-15T08:45:00',
    createdAt: '2023-02-20'
  };

  const roles = [
    { value: 'Administrador', label: 'Administrador', description: 'Acesso total ao sistema' },
    { value: 'Advogado Sênior', label: 'Advogado Sênior', description: 'Acesso completo a processos e relatórios' },
    { value: 'Advogado', label: 'Advogado', description: 'Acesso a processos e clientes' },
    { value: 'Assistente Jurídico', label: 'Assistente Jurídico', description: 'Acesso limitado a processos' },
    { value: 'Secretária', label: 'Secretária', description: 'Acesso a agenda e clientes' },
    { value: 'Estagiário', label: 'Estagiário', description: 'Acesso apenas leitura' }
  ];

  const units = [
    { value: 'Matriz', label: 'Matriz - São Paulo' },
    { value: 'Filial SP', label: 'Filial - Santos/SP' },
    { value: 'Filial RJ', label: 'Filial - Rio de Janeiro/RJ' },
    { value: 'Filial MG', label: 'Filial - Belo Horizonte/MG' }
  ];

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

  useEffect(() => {
    // Simular carregamento dos dados do usuário
    const loadUser = async () => {
      setIsLoading(true);
      
      try {
        // Simular chamada à API
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        setFormData({
          name: mockUser.name,
          email: mockUser.email,
          phone: mockUser.phone,
          role: mockUser.role,
          unit: mockUser.unit,
          status: mockUser.status,
          permissions: permissionsByRole[mockUser.role] || [],
          newPassword: '',
          confirmPassword: ''
        });
      } catch (error) {
        setErrors({ load: 'Erro ao carregar dados do usuário' });
      } finally {
        setIsLoading(false);
      }
    };

    loadUser();
  }, [id]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
      ...(name === 'role' && { permissions: permissionsByRole[value] || [] })
    }));
    
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.name.trim()) {
      newErrors.name = 'Nome é obrigatório';
    } else if (formData.name.length < 3) {
      newErrors.name = 'Nome deve ter pelo menos 3 caracteres';
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!formData.email.trim()) {
      newErrors.email = 'Email é obrigatório';
    } else if (!emailRegex.test(formData.email)) {
      newErrors.email = 'Email deve ter um formato válido';
    }

    if (!formData.phone.trim()) {
      newErrors.phone = 'Telefone é obrigatório';
    }

    if (!formData.role) {
      newErrors.role = 'Perfil é obrigatório';
    }

    if (!formData.unit) {
      newErrors.unit = 'Unidade é obrigatória';
    }

    // Validar senha apenas se estiver sendo alterada
    if (showPasswordSection) {
      if (formData.newPassword && formData.newPassword.length < 6) {
        newErrors.newPassword = 'Nova senha deve ter pelo menos 6 caracteres';
      }

      if (formData.newPassword && formData.newPassword !== formData.confirmPassword) {
        newErrors.confirmPassword = 'Senhas não coincidem';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setIsSaving(true);
    setErrors({});

    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      console.log('Dados atualizados:', formData);
      setSuccess('Usuário atualizado com sucesso!');
      
      setTimeout(() => {
        navigate('/admin/users');
      }, 2000);

    } catch (error) {
      setErrors({ submit: 'Erro ao atualizar usuário. Tente novamente.' });
    } finally {
      setIsSaving(false);
    }
  };

  const handleResetPassword = async () => {
    if (window.confirm('Tem certeza que deseja resetar a senha deste usuário?')) {
      try {
        // Simular reset de senha
        await new Promise(resolve => setTimeout(resolve, 1000));
        setSuccess('Email de reset de senha enviado!');
      } catch (error) {
        setErrors({ reset: 'Erro ao resetar senha' });
      }
    }
  };

  const handleDeleteUser = async () => {
    if (window.confirm('Tem certeza que deseja excluir este usuário? Esta ação não pode ser desfeita.')) {
      try {
        await new Promise(resolve => setTimeout(resolve, 1000));
        navigate('/admin/users');
      } catch (error) {
        setErrors({ delete: 'Erro ao excluir usuário' });
      }
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

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

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
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="flex-shrink-0">
              <UserIcon className="h-8 w-8 text-primary-600" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Editar Usuário</h1>
              <p className="text-sm text-gray-600">
                {formData.name} • {formData.email}
              </p>
            </div>
          </div>
          <div className="flex space-x-3">
            <button
              onClick={handleResetPassword}
              className="inline-flex items-center px-3 py-2 border border-yellow-300 text-sm font-medium rounded-md text-yellow-700 bg-yellow-50 hover:bg-yellow-100"
            >
              <KeyIcon className="h-4 w-4 mr-2" />
              Resetar Senha
            </button>
            <button
              onClick={handleDeleteUser}
              className="inline-flex items-center px-3 py-2 border border-red-300 text-sm font-medium rounded-md text-red-700 bg-red-50 hover:bg-red-100"
            >
              <TrashIcon className="h-4 w-4 mr-2" />
              Excluir
            </button>
          </div>
        </div>
      </div>

      {/* Success/Error Messages */}
      {success && (
        <div className="mb-6 rounded-md bg-green-50 p-4">
          <div className="flex">
            <CheckCircleIcon className="h-5 w-5 text-green-400" />
            <div className="ml-3">
              <p className="text-sm font-medium text-green-800">{success}</p>
            </div>
          </div>
        </div>
      )}

      {errors.load && (
        <div className="mb-6 rounded-md bg-red-50 p-4">
          <div className="flex">
            <ExclamationCircleIcon className="h-5 w-5 text-red-400" />
            <div className="ml-3">
              <p className="text-sm font-medium text-red-800">{errors.load}</p>
            </div>
          </div>
        </div>
      )}

      {/* User Info */}
      <div className="bg-white shadow-erlene rounded-lg mb-6">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Informações do Usuário
          </h3>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            <div>
              <dt className="text-sm font-medium text-gray-500">Criado em</dt>
              <dd className="mt-1 text-sm text-gray-900">
                {new Date(mockUser.createdAt).toLocaleDateString('pt-BR')}
              </dd>
            </div>
            <div>
              <dt className="text-sm font-medium text-gray-500">Último Login</dt>
              <dd className="mt-1 text-sm text-gray-900">
                {new Date(mockUser.lastLogin).toLocaleString('pt-BR')}
              </dd>
            </div>
            <div>
              <dt className="text-sm font-medium text-gray-500">ID do Usuário</dt>
              <dd className="mt-1 text-sm text-gray-900">#{mockUser.id}</dd>
            </div>
          </div>
        </div>
      </div>

      {/* Edit Form */}
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Basic Info */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
              Informações Básicas
            </h3>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
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
                />
                {errors.name && (
                  <p className="mt-1 text-sm text-red-600">{errors.name}</p>
                )}
              </div>

              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                  Email *
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
                />
                {errors.email && (
                  <p className="mt-1 text-sm text-red-600">{errors.email}</p>
                )}
              </div>

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
                />
                {errors.phone && (
                  <p className="mt-1 text-sm text-red-600">{errors.phone}</p>
                )}
              </div>

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

        {/* Professional Info */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
              Informações Profissionais
            </h3>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
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
                  <p className="mt-1 text-sm text-red-600">{errors.role}</p>
                )}
              </div>

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
                  <p className="mt-1 text-sm text-red-600">{errors.unit}</p>
                )}
              </div>
            </div>

            {/* Permissions */}
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

        {/* Password Section */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg leading-6 font-medium text-gray-900">
                Alterar Senha
              </h3>
              <button
                type="button"
                onClick={() => setShowPasswordSection(!showPasswordSection)}
                className="text-sm text-primary-600 hover:text-primary-500"
              >
                {showPasswordSection ? 'Cancelar' : 'Alterar Senha'}
              </button>
            </div>

            {showPasswordSection && (
              <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <div>
                  <label htmlFor="newPassword" className="block text-sm font-medium text-gray-700">
                    Nova Senha
                  </label>
                  <div className="mt-1 relative">
                    <input
                      type={showPassword ? 'text' : 'password'}
                      name="newPassword"
                      id="newPassword"
                      value={formData.newPassword}
                      onChange={handleInputChange}
                      className={`block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 pr-10 ${
                        errors.newPassword ? 'border-red-300' : 'border-gray-300'
                      }`}
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
                  {errors.newPassword && (
                    <p className="mt-1 text-sm text-red-600">{errors.newPassword}</p>
                  )}
                </div>

                <div>
                  <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700">
                    Confirmar Nova Senha
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
                    <p className="mt-1 text-sm text-red-600">{errors.confirmPassword}</p>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Error Message */}
        {errors.submit && (
          <div className="rounded-md bg-red-50 p-4">
            <div className="flex">
              <ExclamationCircleIcon className="h-5 w-5 text-red-400" />
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
            className="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            Cancelar
          </Link>
          <button
            type="submit"
            disabled={isSaving}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 disabled:opacity-50"
          >
            {isSaving ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Salvando...
              </>
            ) : (
              'Salvar Alterações'
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default EditUser;
