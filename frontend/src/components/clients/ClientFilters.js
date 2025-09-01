import React, { useState } from 'react';
import { MagnifyingGlassIcon, FunnelIcon, XMarkIcon } from '@heroicons/react/24/outline';

const ClientFilters = ({ 
  onApplyFilters, 
  onClearFilters, 
  loading = false,
  initialFilters = {} 
}) => {
  const [filters, setFilters] = useState({
    search: '',
    tipo_pessoa: 'all',
    status: 'all',
    acesso_portal: 'all',
    tipo_armazenamento: 'all',
    ...initialFilters
  });

  const [showAdvanced, setShowAdvanced] = useState(false);

  const handleFilterChange = (field, value) => {
    const newFilters = { ...filters, [field]: value };
    setFilters(newFilters);
    
    // Aplicar filtros automaticamente
    const apiFilters = {};
    Object.keys(newFilters).forEach(key => {
      if (newFilters[key] && newFilters[key] !== 'all') {
        apiFilters[key] = newFilters[key];
      }
    });
    
    onApplyFilters(apiFilters);
  };

  const clearAllFilters = () => {
    const clearedFilters = {
      search: '',
      tipo_pessoa: 'all',
      status: 'all',
      acesso_portal: 'all',
      tipo_armazenamento: 'all'
    };
    
    setFilters(clearedFilters);
    onClearFilters();
  };

  const hasActiveFilters = Object.values(filters).some(value => value && value !== 'all');

  return (
    <div className="space-y-4">
      {/* Filtros principais */}
      <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4">
        {/* Busca */}
        <div className="relative flex-1">
          <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
          <input
            type="text"
            placeholder="Buscar por nome, documento ou email..."
            value={filters.search}
            onChange={(e) => handleFilterChange('search', e.target.value)}
            className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            disabled={loading}
          />
        </div>

        {/* Tipo de pessoa */}
        <select
          value={filters.tipo_pessoa}
          onChange={(e) => handleFilterChange('tipo_pessoa', e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          disabled={loading}
        >
          <option value="all">Todos os tipos</option>
          <option value="PF">Pessoa Física</option>
          <option value="PJ">Pessoa Jurídica</option>
        </select>

        {/* Status */}
        <select
          value={filters.status}
          onChange={(e) => handleFilterChange('status', e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          disabled={loading}
        >
          <option value="all">Todos os status</option>
          <option value="ativo">Ativo</option>
          <option value="inativo">Inativo</option>
        </select>

        {/* Botão filtros avançados */}
        <button
          onClick={() => setShowAdvanced(!showAdvanced)}
          className="px-4 py-2 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 flex items-center"
          disabled={loading}
        >
          <FunnelIcon className="w-4 h-4 mr-2" />
          Avançado
        </button>

        {/* Limpar filtros */}
        {hasActiveFilters && (
          <button
            onClick={clearAllFilters}
            className="px-4 py-2 bg-red-100 text-red-600 rounded-lg hover:bg-red-200 flex items-center"
            disabled={loading}
          >
            <XMarkIcon className="w-4 h-4 mr-2" />
            Limpar
          </button>
        )}
      </div>

      {/* Filtros avançados */}
      {showAdvanced && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 p-4 bg-gray-50 rounded-lg">
          {/* Acesso ao portal */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Acesso ao Portal
            </label>
            <select
              value={filters.acesso_portal}
              onChange={(e) => handleFilterChange('acesso_portal', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              disabled={loading}
            >
              <option value="all">Todos</option>
              <option value="true">Habilitado</option>
              <option value="false">Desabilitado</option>
            </select>
          </div>

          {/* Tipo de armazenamento */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Armazenamento
            </label>
            <select
              value={filters.tipo_armazenamento}
              onChange={(e) => handleFilterChange('tipo_armazenamento', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              disabled={loading}
            >
              <option value="all">Todos</option>
              <option value="local">Local</option>
              <option value="google_drive">Google Drive</option>
              <option value="onedrive">OneDrive</option>
            </select>
          </div>
        </div>
      )}
    </div>
  );
};

export default ClientFilters;
