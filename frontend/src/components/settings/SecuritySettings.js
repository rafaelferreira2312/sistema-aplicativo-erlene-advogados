import React, { useState } from 'react';
import { 
  ShieldCheckIcon,
  KeyIcon,
  LockClosedIcon,
  CheckCircleIcon,
  ExclamationCircleIcon
} from '@heroicons/react/24/outline';

const SecuritySettings = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [isSaved, setIsSaved] = useState(false);

  // Mock data - 3 exemplos de configurações de segurança
  const [settings, setSettings] = useState({
    // Exemplo 1: Políticas de Senha
    passwordMinLength: '8',
    passwordRequireUppercase: true,
    passwordRequireNumbers: true,
    passwordRequireSpecialChars: true,
    passwordExpiration: '90',
    
    // Exemplo 2: Autenticação e Sessão
    twoFactorAuth: false,
    maxLoginAttempts: '5',
    lockoutDuration: '30',
    sessionTimeout: '120',
    rememberLogin: true,
    
    // Exemplo 3: Auditoria e Logs
    auditLogs: true,
    logLoginAttempts: true,
    logSystemChanges: true,
    logRetentionDays: '365',
    emailSecurityAlerts: true
  });

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setSettings(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setIsSaved(false);

    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      console.log('Configurações de segurança salvas:', settings);
      setIsSaved(true);
      setTimeout(() => setIsSaved(false), 3000);
    } catch (error) {
      console.error('Erro ao salvar:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Success Message */}
      {isSaved && (
        <div className="rounded-md bg-green-50 p-4">
          <div className="flex">
            <CheckCircleIcon className="h-5 w-5 text-green-400" />
            <div className="ml-3">
              <p className="text-sm font-medium text-green-800">
                Configurações de segurança salvas com sucesso!
              </p>
            </div>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Políticas de Senha */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="flex items-center mb-4">
              <LockClosedIcon className="h-6 w-6 text-primary-600 mr-3" />
              <h3 className="text-lg leading-6 font-medium text-gray-900">
                Políticas de Senha
              </h3>
            </div>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Tamanho Mínimo da Senha
                </label>
                <select
                  name="passwordMinLength"
                  value={settings.passwordMinLength}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="6">6 caracteres</option>
                  <option value="8">8 caracteres</option>
                  <option value="10">10 caracteres</option>
                  <option value="12">12 caracteres</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Expiração da Senha (dias)
                </label>
                <select
                  name="passwordExpiration"
                  value={settings.passwordExpiration}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="30">30 dias</option>
                  <option value="60">60 dias</option>
                  <option value="90">90 dias</option>
                  <option value="180">180 dias</option>
                  <option value="365">1 ano</option>
                  <option value="0">Nunca expira</option>
                </select>
              </div>
            </div>

            <div className="mt-6 space-y-4">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="passwordRequireUppercase"
                  checked={settings.passwordRequireUppercase}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Exigir letras maiúsculas
                </label>
              </div>

              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="passwordRequireNumbers"
                  checked={settings.passwordRequireNumbers}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Exigir números
                </label>
              </div>

              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="passwordRequireSpecialChars"
                  checked={settings.passwordRequireSpecialChars}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Exigir caracteres especiais (!@#$%^&*)
                </label>
              </div>
            </div>
          </div>
        </div>

        {/* Autenticação e Sessão */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="flex items-center mb-4">
              <KeyIcon className="h-6 w-6 text-primary-600 mr-3" />
              <h3 className="text-lg leading-6 font-medium text-gray-900">
                Autenticação e Sessão
              </h3>
            </div>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Máximo Tentativas de Login
                </label>
                <select
                  name="maxLoginAttempts"
                  value={settings.maxLoginAttempts}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="3">3 tentativas</option>
                  <option value="5">5 tentativas</option>
                  <option value="7">7 tentativas</option>
                  <option value="10">10 tentativas</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Bloqueio após Falhas (minutos)
                </label>
                <select
                  name="lockoutDuration"
                  value={settings.lockoutDuration}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="15">15 minutos</option>
                  <option value="30">30 minutos</option>
                  <option value="60">1 hora</option>
                  <option value="240">4 horas</option>
                  <option value="1440">24 horas</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Timeout de Sessão (minutos)
                </label>
                <select
                  name="sessionTimeout"
                  value={settings.sessionTimeout}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="30">30 minutos</option>
                  <option value="60">1 hora</option>
                  <option value="120">2 horas</option>
                  <option value="240">4 horas</option>
                  <option value="480">8 horas</option>
                </select>
              </div>
            </div>

            <div className="mt-6 space-y-4">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="twoFactorAuth"
                  checked={settings.twoFactorAuth}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Habilitar Autenticação de Dois Fatores (2FA)
                </label>
              </div>

              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="rememberLogin"
                  checked={settings.rememberLogin}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Permitir "Lembrar Login"
                </label>
              </div>
            </div>
          </div>
        </div>

        {/* Auditoria e Logs */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="flex items-center mb-4">
              <ShieldCheckIcon className="h-6 w-6 text-primary-600 mr-3" />
              <h3 className="text-lg leading-6 font-medium text-gray-900">
                Auditoria e Logs de Segurança
              </h3>
            </div>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Retenção de Logs (dias)
                </label>
                <select
                  name="logRetentionDays"
                  value={settings.logRetentionDays}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="30">30 dias</option>
                  <option value="90">90 dias</option>
                  <option value="180">180 dias</option>
                  <option value="365">1 ano</option>
                  <option value="730">2 anos</option>
                </select>
              </div>
            </div>

            <div className="mt-6 space-y-4">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="auditLogs"
                  checked={settings.auditLogs}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Habilitar logs de auditoria
                </label>
              </div>

              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="logLoginAttempts"
                  checked={settings.logLoginAttempts}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Registrar tentativas de login
                </label>
              </div>

              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="logSystemChanges"
                  checked={settings.logSystemChanges}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Registrar alterações do sistema
                </label>
              </div>

              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="emailSecurityAlerts"
                  checked={settings.emailSecurityAlerts}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Enviar alertas de segurança por email
                </label>
              </div>
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="flex justify-end space-x-3">
          <button
            type="button"
            className="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            Restaurar Padrões
          </button>
          <button
            type="submit"
            disabled={isLoading}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 disabled:opacity-50"
          >
            {isLoading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Salvando...
              </>
            ) : (
              'Salvar Configurações'
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default SecuritySettings;
