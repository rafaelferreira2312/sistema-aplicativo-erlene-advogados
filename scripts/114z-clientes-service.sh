#!/bin/bash

# Script 114z - Frontend Clientes Service
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 114z-clientes-service.sh && ./114z-clientes-service.sh
# EXECUTE NA PASTA: frontend/

echo "🚀 Criando Frontend Service para Clientes..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "📝 1. Criando diretórios necessários..."

# Criar diretórios se não existirem
mkdir -p src/services/api
mkdir -p src/utils
mkdir -p src/hooks

echo "📝 2. Criando serviço de clientes..."

# Criar service para comunicação com API de clientes
cat > src/services/api/clientsService.js << 'EOF'
import { apiClient } from '../apiClient';

export const clientsService = {
  // Listar clientes com filtros
  async getClients(params = {}) {
    try {
      const response = await apiClient.get('/admin/clients', { params });
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      throw error;
    }
  },

  // Obter estatísticas de clientes
  async getStats() {
    try {
      const response = await apiClient.get('/admin/clients/stats');
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar estatísticas:', error);
      throw error;
    }
  },

  // Obter cliente por ID
  async getClient(id) {
    try {
      const response = await apiClient.get(`/admin/clients/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar cliente:', error);
      throw error;
    }
  },

  // Criar cliente
  async createClient(clientData) {
    try {
      const response = await apiClient.post('/admin/clients', clientData);
      return response.data;
    } catch (error) {
      console.error('Erro ao criar cliente:', error);
      throw error;
    }
  },

  // Atualizar cliente
  async updateClient(id, clientData) {
    try {
      const response = await apiClient.put(`/admin/clients/${id}`, clientData);
      return response.data;
    } catch (error) {
      console.error('Erro ao atualizar cliente:', error);
      throw error;
    }
  },

  // Deletar cliente
  async deleteClient(id) {
    try {
      const response = await apiClient.delete(`/admin/clients/${id}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao deletar cliente:', error);
      throw error;
    }
  },

  // Buscar CEP via backend
  async buscarCep(cep) {
    try {
      // Limpar CEP antes de enviar
      const cepLimpo = cep.replace(/\D/g, '');
      const response = await apiClient.get(`/admin/clients/buscar-cep/${cepLimpo}`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar CEP:', error);
      throw error;
    }
  },

  // Obter responsáveis disponíveis
  async getResponsaveis() {
    try {
      const response = await apiClient.get('/admin/clients/responsaveis');
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar responsáveis:', error);
      throw error;
    }
  },

  // Buscar clientes (para autocomplete)
  async searchClients(query, filters = {}) {
    try {
      const params = { search: query, ...filters };
      const response = await apiClient.get('/admin/clients', { params });
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      throw error;
    }
  },

  // Exportar clientes
  async exportClients(format = 'excel', filters = {}) {
    try {
      const response = await apiClient.get('/admin/clients/export', {
        params: { format, ...filters },
        responseType: 'blob'
      });
      return response.data;
    } catch (error) {
      console.error('Erro ao exportar clientes:', error);
      throw error;
    }
  },

  // Gerenciar acesso ao portal
  async updatePortalAccess(id, accessData) {
    try {
      const response = await apiClient.put(`/admin/clients/${id}/portal-access`, accessData);
      return response.data;
    } catch (error) {
      console.error('Erro ao atualizar acesso portal:', error);
      throw error;
    }
  },

  // Validar CPF/CNPJ
  async validateDocument(document, type, excludeId = null) {
    try {
      const params = { document, type };
      if (excludeId) params.exclude_id = excludeId;
      
      const response = await apiClient.get('/admin/clients/validate-document', { params });
      return response.data;
    } catch (error) {
      console.error('Erro ao validar documento:', error);
      throw error;
    }
  }
};
EOF

echo "📝 3. Criando utilitários para formatação..."

# Criar utilitários para formatação de dados
cat > src/utils/formatters.js << 'EOF'
/**
 * Utilitários para formatação de dados de clientes
 */

// Formatar CPF
export const formatCPF = (cpf) => {
  const numbers = cpf.replace(/\D/g, '');
  return numbers.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
};

// Formatar CNPJ
export const formatCNPJ = (cnpj) => {
  const numbers = cnpj.replace(/\D/g, '');
  return numbers.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
};

// Formatar documento baseado no tipo
export const formatDocument = (document, type) => {
  const numbers = document.replace(/\D/g, '');
  
  if (type === 'PF') {
    return formatCPF(numbers);
  } else {
    return formatCNPJ(numbers);
  }
};

// Formatar telefone
export const formatPhone = (phone) => {
  const numbers = phone.replace(/\D/g, '');
  
  if (numbers.length === 11) {
    return numbers.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
  } else if (numbers.length === 10) {
    return numbers.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
  }
  
  return phone;
};

// Formatar CEP
export const formatCEP = (cep) => {
  const numbers = cep.replace(/\D/g, '');
  return numbers.replace(/(\d{5})(\d{3})/, '$1-$2');
};

// Validar CPF
export const validateCPF = (cpf) => {
  const numbers = cpf.replace(/\D/g, '');
  
  if (numbers.length !== 11) return false;
  if (/^(\d)\1{10}$/.test(numbers)) return false;
  
  let sum = 0;
  for (let i = 0; i < 9; i++) {
    sum += parseInt(numbers[i]) * (10 - i);
  }
  let remainder = (sum * 10) % 11;
  if (remainder === 10) remainder = 0;
  if (remainder !== parseInt(numbers[9])) return false;
  
  sum = 0;
  for (let i = 0; i < 10; i++) {
    sum += parseInt(numbers[i]) * (11 - i);
  }
  remainder = (sum * 10) % 11;
  if (remainder === 10) remainder = 0;
  if (remainder !== parseInt(numbers[10])) return false;
  
  return true;
};

// Validar CNPJ
export const validateCNPJ = (cnpj) => {
  const numbers = cnpj.replace(/\D/g, '');
  
  if (numbers.length !== 14) return false;
  if (/^(\d)\1{13}$/.test(numbers)) return false;
  
  let sum = 0;
  let pos = 5;
  for (let i = 0; i < 12; i++) {
    sum += parseInt(numbers[i]) * pos--;
    if (pos < 2) pos = 9;
  }
  let remainder = sum % 11;
  if (remainder < 2) remainder = 0;
  else remainder = 11 - remainder;
  if (remainder !== parseInt(numbers[12])) return false;
  
  sum = 0;
  pos = 6;
  for (let i = 0; i < 13; i++) {
    sum += parseInt(numbers[i]) * pos--;
    if (pos < 2) pos = 9;
  }
  remainder = sum % 11;
  if (remainder < 2) remainder = 0;
  else remainder = 11 - remainder;
  if (remainder !== parseInt(numbers[13])) return false;
  
  return true;
};

// Validar documento baseado no tipo
export const validateDocument = (document, type) => {
  if (type === 'PF') {
    return validateCPF(document);
  } else {
    return validateCNPJ(document);
  }
};

// Validar email
export const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

// Limpar apenas números
export const onlyNumbers = (value) => {
  return value.replace(/\D/g, '');
};

// Formatar endereço completo
export const formatAddress = (cliente) => {
  const parts = [
    cliente.endereco,
    cliente.cidade,
    cliente.estado,
    cliente.cep
  ].filter(Boolean);
  
  return parts.join(', ');
};

// Gerar iniciais para avatar
export const getInitials = (name) => {
  return name
    .split(' ')
    .map(word => word.charAt(0))
    .join('')
    .substring(0, 2)
    .toUpperCase();
};
EOF

echo "📝 4. Criando hook personalizado para clientes..."

# Criar hook personalizado para gerenciar estado de clientes
cat > src/hooks/useClients.js << 'EOF'
import { useState, useEffect, useCallback } from 'react';
import { clientsService } from '../services/api/clientsService';
import toast from 'react-hot-toast';

export const useClients = (initialParams = {}) => {
  const [clients, setClients] = useState([]);
  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [params, setParams] = useState(initialParams);

  // Carregar clientes
  const loadClients = useCallback(async (newParams = {}) => {
    try {
      setLoading(true);
      setError(null);
      
      const mergedParams = { ...params, ...newParams };
      const response = await clientsService.getClients(mergedParams);
      
      setClients(response.data || []);
      setParams(mergedParams);
    } catch (err) {
      setError(err.message);
      toast.error('Erro ao carregar clientes');
    } finally {
      setLoading(false);
    }
  }, [params]);

  // Carregar estatísticas
  const loadStats = useCallback(async () => {
    try {
      const response = await clientsService.getStats();
      setStats(response.data || {});
    } catch (err) {
      console.error('Erro ao carregar estatísticas:', err);
    }
  }, []);

  // Criar cliente
  const createClient = useCallback(async (clientData) => {
    try {
      const response = await clientsService.createClient(clientData);
      toast.success('Cliente criado com sucesso!');
      await loadClients(); // Recarregar lista
      await loadStats(); // Atualizar estatísticas
      return response;
    } catch (err) {
      toast.error('Erro ao criar cliente');
      throw err;
    }
  }, [loadClients, loadStats]);

  // Atualizar cliente
  const updateClient = useCallback(async (id, clientData) => {
    try {
      const response = await clientsService.updateClient(id, clientData);
      toast.success('Cliente atualizado com sucesso!');
      await loadClients(); // Recarregar lista
      return response;
    } catch (err) {
      toast.error('Erro ao atualizar cliente');
      throw err;
    }
  }, [loadClients]);

  // Deletar cliente
  const deleteClient = useCallback(async (id) => {
    try {
      await clientsService.deleteClient(id);
      toast.success('Cliente excluído com sucesso!');
      await loadClients(); // Recarregar lista
      await loadStats(); // Atualizar estatísticas
    } catch (err) {
      toast.error('Erro ao excluir cliente');
      throw err;
    }
  }, [loadClients, loadStats]);

  // Buscar CEP
  const buscarCep = useCallback(async (cep) => {
    try {
      const response = await clientsService.buscarCep(cep);
      return response.data;
    } catch (err) {
      toast.error('CEP não encontrado');
      throw err;
    }
  }, []);

  // Aplicar filtros
  const applyFilters = useCallback((newParams) => {
    loadClients(newParams);
  }, [loadClients]);

  // Limpar filtros
  const clearFilters = useCallback(() => {
    const clearedParams = {};
    setParams(clearedParams);
    loadClients(clearedParams);
  }, [loadClients]);

  // Carregar dados iniciais
  useEffect(() => {
    loadClients();
    loadStats();
  }, []);

  return {
    // Estados
    clients,
    stats,
    loading,
    error,
    params,
    
    // Ações
    loadClients,
    loadStats,
    createClient,
    updateClient,
    deleteClient,
    buscarCep,
    applyFilters,
    clearFilters,
    
    // Helpers
    refresh: () => {
      loadClients();
      loadStats();
    }
  };
};
EOF

echo "📝 5. Atualizando endpoints da API..."

# Verificar se existe arquivo de endpoints
if [ ! -f "src/services/api/endpoints.js" ]; then
    # Criar arquivo de endpoints se não existir
    cat > src/services/api/endpoints.js << 'EOF'
export const ENDPOINTS = {
  // Autenticação
  AUTH: {
    LOGIN: '/auth/login',
    LOGIN_CLIENT: '/auth/login-client',
    LOGOUT: '/auth/logout',
    ME: '/auth/me',
    REFRESH: '/auth/refresh'
  },

  // Dashboard
  DASHBOARD: {
    STATS: '/dashboard/stats'
  },

  // Clientes
  CLIENTS: {
    LIST: '/admin/clients',
    CREATE: '/admin/clients',
    SHOW: (id) => `/admin/clients/${id}`,
    UPDATE: (id) => `/admin/clients/${id}`,
    DELETE: (id) => `/admin/clients/${id}`,
    STATS: '/admin/clients/stats',
    SEARCH: '/admin/clients',
    EXPORT: '/admin/clients/export',
    PORTAL_ACCESS: (id) => `/admin/clients/${id}/portal-access`,
    BUSCAR_CEP: (cep) => `/admin/clients/buscar-cep/${cep}`,
    RESPONSAVEIS: '/admin/clients/responsaveis',
    VALIDATE_DOCUMENT: '/admin/clients/validate-document'
  }
};
EOF
else
    # Adicionar endpoints de clientes se o arquivo já existir
    if ! grep -q "CLIENTS:" src/services/api/endpoints.js; then
        sed -i '/};$/i\
\
  // Clientes\
  CLIENTS: {\
    LIST: "/admin/clients",\
    CREATE: "/admin/clients",\
    SHOW: (id) => `/admin/clients/${id}`,\
    UPDATE: (id) => `/admin/clients/${id}`,\
    DELETE: (id) => `/admin/clients/${id}`,\
    STATS: "/admin/clients/stats",\
    SEARCH: "/admin/clients",\
    EXPORT: "/admin/clients/export",\
    PORTAL_ACCESS: (id) => `/admin/clients/${id}/portal-access`,\
    BUSCAR_CEP: (cep) => `/admin/clients/buscar-cep/${cep}`,\
    RESPONSAVEIS: "/admin/clients/responsaveis",\
    VALIDATE_DOCUMENT: "/admin/clients/validate-document"\
  },' src/services/api/endpoints.js
    fi
fi

echo "📝 6. Criando validadores personalizados..."

# Criar validadores para formulários
cat > src/utils/validators.js << 'EOF'
import { validateCPF, validateCNPJ, validateEmail } from './formatters';

export const clientValidators = {
  // Validar campos obrigatórios
  validateRequired: (value, fieldName) => {
    if (!value || !value.toString().trim()) {
      return `${fieldName} é obrigatório`;
    }
    return null;
  },

  // Validar nome
  validateName: (name) => {
    if (!name || !name.trim()) {
      return 'Nome é obrigatório';
    }
    if (name.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    if (name.length > 255) {
      return 'Nome deve ter no máximo 255 caracteres';
    }
    return null;
  },

  // Validar documento (CPF/CNPJ)
  validateDocument: (document, type) => {
    if (!document || !document.trim()) {
      return `${type === 'PF' ? 'CPF' : 'CNPJ'} é obrigatório`;
    }

    const numbers = document.replace(/\D/g, '');
    
    if (type === 'PF') {
      if (numbers.length !== 11) {
        return 'CPF deve ter 11 dígitos';
      }
      if (!validateCPF(document)) {
        return 'CPF inválido';
      }
    } else {
      if (numbers.length !== 14) {
        return 'CNPJ deve ter 14 dígitos';
      }
      if (!validateCNPJ(document)) {
        return 'CNPJ inválido';
      }
    }
    
    return null;
  },

  // Validar email
  validateEmail: (email) => {
    if (!email || !email.trim()) {
      return 'Email é obrigatório';
    }
    if (!validateEmail(email)) {
      return 'Email inválido';
    }
    return null;
  },

  // Validar telefone
  validatePhone: (phone) => {
    if (!phone || !phone.trim()) {
      return 'Telefone é obrigatório';
    }
    
    const numbers = phone.replace(/\D/g, '');
    if (numbers.length < 10 || numbers.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    
    return null;
  },

  // Validar CEP
  validateCEP: (cep) => {
    if (!cep) return null; // CEP é opcional
    
    const numbers = cep.replace(/\D/g, '');
    if (numbers.length !== 8) {
      return 'CEP deve ter 8 dígitos';
    }
    
    return null;
  },

  // Validar senha do portal
  validatePortalPassword: (password, isRequired = true) => {
    if (isRequired && (!password || !password.trim())) {
      return 'Senha é obrigatória para acesso ao portal';
    }
    
    if (password && password.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  },

  // Validar formulário completo
  validateClientForm: (formData, isEdit = false) => {
    const errors = {};

    // Validações obrigatórias
    const nameError = clientValidators.validateName(formData.nome);
    if (nameError) errors.nome = nameError;

    const documentError = clientValidators.validateDocument(formData.cpf_cnpj, formData.tipo_pessoa);
    if (documentError) errors.cpf_cnpj = documentError;

    const emailError = clientValidators.validateEmail(formData.email);
    if (emailError) errors.email = emailError;

    const phoneError = clientValidators.validatePhone(formData.telefone);
    if (phoneError) errors.telefone = phoneError;

    // Validações opcionais
    if (formData.cep) {
      const cepError = clientValidators.validateCEP(formData.cep);
      if (cepError) errors.cep = cepError;
    }

    // Validar senha do portal se acesso habilitado
    if (formData.acesso_portal) {
      const passwordRequired = !isEdit; // Senha obrigatória apenas na criação
      const passwordError = clientValidators.validatePortalPassword(formData.senha_portal, passwordRequired);
      if (passwordError) errors.senha_portal = passwordError;
    }

    return {
      isValid: Object.keys(errors).length === 0,
      errors
    };
  }
};
EOF

echo "✅ Script 114z concluído!"
echo "📝 ClientsService criado com todos os métodos da API"
echo "📝 Utilitários de formatação e validação criados"
echo "📝 Hook useClients para gerenciar estado"
echo "📝 Endpoints configurados"
echo ""
echo "Digite 'continuar' para prosseguir com o Script 115a (Integração da Lista de Clientes)..."