import React, { useState, useEffect } from 'react';
import { 
  Cog6ToothIcon,
  BuildingOfficeIcon,
  ShieldCheckIcon,
  ArrowLeftIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline';
import GeneralSettings from '../../components/settings/GeneralSettings';
import SecuritySettings from '../../components/settings/SecuritySettings';

const Settings = () => {
  const [isLoading, setIsLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState('overview');

  const settingsCategories = [
    {
      id: 'general',
      name: 'Configurações Gerais',
      description: 'Informações básicas do escritório e sistema',
      icon: BuildingOfficeIcon,
      color: 'bg-blue-500',
      component: GeneralSettings
    },
    {
      id: 'security',
      name: 'Segurança',
      description: 'Configurações de segurança e autenticação',
      icon: ShieldCheckIcon,
      color: 'bg-red-500',
      component: SecuritySettings
    }
  ];

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsLoading(false);
    }, 1000);
    return () => clearTimeout(timer);
  }, []);

  const handleCategorySelect = (categoryId) => {
    setSelectedCategory(categoryId);
  };

  const renderCategoryComponent = () => {
    const category = settingsCategories.find(c => c.id === selectedCategory);
    if (category && category.component) {
      const Component = category.component;
      return <Component />;
    }
    return null;
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  // Renderizar categoria específica
  if (selectedCategory !== 'overview') {
    const category = settingsCategories.find(c => c.id === selectedCategory);
    
    return (
      <div className="space-y-6">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => setSelectedCategory('overview')}
            className="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
          >
            <ArrowLeftIcon className="h-4 w-4 mr-2" />
            Voltar
          </button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{category?.name}</h1>
            <p className="text-sm text-gray-600">{category?.description}</p>
          </div>
        </div>
        {renderCategoryComponent()}
      </div>
    );
  }

  // Dashboard principal
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Configurações do Sistema</h1>
        <p className="mt-2 text-sm text-gray-700">
          Gerencie configurações, segurança e integrações do sistema
        </p>
      </div>

      {/* System Status Banner */}
      <div className="bg-gradient-to-r from-green-50 to-blue-50 border border-green-200 rounded-lg p-4">
        <div className="flex items-center">
          <CheckCircleIcon className="h-6 w-6 text-green-600 mr-3" />
          <div className="flex-1">
            <h3 className="text-sm font-medium text-green-800">Sistema Operacional</h3>
            <p className="text-sm text-green-700 mt-1">
              Todos os serviços estão funcionando normalmente. Versão 1.0.0
            </p>
          </div>
        </div>
      </div>

      {/* Settings Categories */}
      <div className="bg-white shadow-erlene rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
            Categorias de Configuração
          </h3>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            {settingsCategories.map((category) => (
              <div
                key={category.id}
                className="relative group bg-white p-6 border border-gray-200 rounded-lg hover:shadow-erlene-lg transition-all duration-200 cursor-pointer hover:border-primary-300"
                onClick={() => handleCategorySelect(category.id)}
              >
                <div>
                  <span className={`rounded-lg inline-flex p-3 ${category.color} text-white ring-4 ring-white`}>
                    <category.icon className="h-6 w-6" />
                  </span>
                </div>
                <div className="mt-4">
                  <h3 className="text-lg font-medium text-gray-900 group-hover:text-primary-600">
                    {category.name}
                  </h3>
                  <p className="mt-2 text-sm text-gray-500">
                    {category.description}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Settings;
