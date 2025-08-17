import React, { useState } from 'react';
import { 
  BuildingOfficeIcon,
  MapPinIcon,
  PhoneIcon,
  CheckCircleIcon,
  ExclamationCircleIcon
} from '@heroicons/react/24/outline';

const GeneralSettings = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [isSaved, setIsSaved] = useState(false);
  const [errors, setErrors] = useState({});

  // Mock data - 3 exemplos de configurações
  const [settings, setSettings] = useState({
    // Exemplo 1: Informações do Escritório Principal
    officeName: 'Erlene Advogados',
    cnpj: '12.345.678/0001-90',
    oab: 'OAB/SP 123.456',
    responsibleLawyer: 'Dra. Erlene Chaves Silva',
    
    // Exemplo 2: Endereço e Contato
    address: 'Rua das Flores, 123',
    city: 'São Paulo',
    state: 'SP',
    zipCode: '01234-567',
    phone: '(11) 3333-4444',
    email: 'contato@erleneadvogados.com.br',
    
    // Exemplo 3: Configurações de Sistema
    timezone: 'America/Sao_Paulo',
    dateFormat: 'DD/MM/YYYY',
    currency: 'BRL',
    sessionTimeout: '120',
    autoBackup: true,
    maintenanceMode: false
  });

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setSettings(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));

    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    if (!settings.officeName) newErrors.officeName = 'Nome do escritório é obrigatório';
    if (!settings.cnpj) newErrors.cnpj = 'CNPJ é obrigatório';
    if (!settings.email) newErrors.email = 'Email é obrigatório';
    
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (settings.email && !emailRegex.test(settings.email)) {
      newErrors.email = 'Email inválido';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;

    setIsLoading(true);
    setIsSaved(false);

    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      console.log('Configurações salvas:', settings);
      setIsSaved(true);
      setTimeout(() => setIsSaved(false), 3000);
    } catch (error) {
      setErrors({ submit: 'Erro ao salvar configurações' });
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
                Configurações salvas com sucesso!
              </p>
            </div>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Informações do Escritório */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="flex items-center mb-4">
              <BuildingOfficeIcon className="h-6 w-6 text-primary-600 mr-3" />
              <h3 className="text-lg leading-6 font-medium text-gray-900">
                Informações do Escritório
              </h3>
            </div>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Nome do Escritório *
                </label>
                <input
                  type="text"
                  name="officeName"
                  value={settings.officeName}
                  onChange={handleInputChange}
                  className={`mt-1 block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 ${
                    errors.officeName ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
                {errors.officeName && (
                  <p className="mt-1 text-sm text-red-600">{errors.officeName}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  CNPJ *
                </label>
                <input
                  type="text"
                  name="cnpj"
                  value={settings.cnpj}
                  onChange={handleInputChange}
                  className={`mt-1 block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 ${
                    errors.cnpj ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
                {errors.cnpj && (
                  <p className="mt-1 text-sm text-red-600">{errors.cnpj}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  OAB Responsável
                </label>
                <input
                  type="text"
                  name="oab"
                  value={settings.oab}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Advogado Responsável
                </label>
                <input
                  type="text"
                  name="responsibleLawyer"
                  value={settings.responsibleLawyer}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Endereço e Contato */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="flex items-center mb-4">
              <MapPinIcon className="h-6 w-6 text-primary-600 mr-3" />
              <h3 className="text-lg leading-6 font-medium text-gray-900">
                Endereço e Contato
              </h3>
            </div>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div className="sm:col-span-2">
                <label className="block text-sm font-medium text-gray-700">
                  Endereço Completo
                </label>
                <input
                  type="text"
                  name="address"
                  value={settings.address}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Cidade
                </label>
                <input
                  type="text"
                  name="city"
                  value={settings.city}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Estado
                </label>
                <select
                  name="state"
                  value={settings.state}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="SP">São Paulo</option>
                  <option value="RJ">Rio de Janeiro</option>
                  <option value="MG">Minas Gerais</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  CEP
                </label>
                <input
                  type="text"
                  name="zipCode"
                  value={settings.zipCode}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Telefone *
                </label>
                <input
                  type="tel"
                  name="phone"
                  value={settings.phone}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Email *
                </label>
                <input
                  type="email"
                  name="email"
                  value={settings.email}
                  onChange={handleInputChange}
                  className={`mt-1 block w-full rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500 ${
                    errors.email ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
                {errors.email && (
                  <p className="mt-1 text-sm text-red-600">{errors.email}</p>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Configurações de Sistema */}
        <div className="bg-white shadow-erlene rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="flex items-center mb-4">
              <PhoneIcon className="h-6 w-6 text-primary-600 mr-3" />
              <h3 className="text-lg leading-6 font-medium text-gray-900">
                Configurações de Sistema
              </h3>
            </div>
            
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Fuso Horário
                </label>
                <select
                  name="timezone"
                  value={settings.timezone}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="America/Sao_Paulo">São Paulo (GMT-3)</option>
                  <option value="America/Rio_Branco">Acre (GMT-5)</option>
                  <option value="America/Manaus">Manaus (GMT-4)</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Formato de Data
                </label>
                <select
                  name="dateFormat"
                  value={settings.dateFormat}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="DD/MM/YYYY">DD/MM/YYYY</option>
                  <option value="MM/DD/YYYY">MM/DD/YYYY</option>
                  <option value="YYYY-MM-DD">YYYY-MM-DD</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Moeda
                </label>
                <select
                  name="currency"
                  value={settings.currency}
                  onChange={handleInputChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="BRL">Real (R$)</option>
                  <option value="USD">Dólar ($)</option>
                  <option value="EUR">Euro (€)</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Timeout de Sessão (minutos)
                </label>
                <input
                  type="number"
                  name="sessionTimeout"
                  value={settings.sessionTimeout}
                  onChange={handleInputChange}
                  min="30"
                  max="480"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>

            <div className="mt-6 space-y-4">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="autoBackup"
                  checked={settings.autoBackup}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Backup Automático Diário
                </label>
              </div>

              <div className="flex items-center">
                <input
                  type="checkbox"
                  name="maintenanceMode"
                  checked={settings.maintenanceMode}
                  onChange={handleInputChange}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label className="ml-3 block text-sm text-gray-900">
                  Modo de Manutenção
                </label>
              </div>
            </div>
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

export default GeneralSettings;
