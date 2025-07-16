#!/bin/bash

# Script 34 - Services e API Client
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/34-create-services-api.sh

echo "🔌 Criando services e API client..."

# src/services/api/apiClient.js
cat > frontend/src/services/api/apiClient.js << 'EOF'
import axios from 'axios';
import { toast } from 'react-hot-toast';
import { APP_CONFIG } from '../../config/constants';
import { tokenService } from '../auth/tokenService';

// Criar instância do axios
export const apiClient = axios.create({
  baseURL: APP_CONFIG.API_BASE_URL,
  timeout: APP_CONFIG.REQUEST_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Request interceptor - adicionar token automaticamente
apiClient.interceptors.request.use(
  (config) => {
    const token = tokenService.getToken();
    
    if (token && !tokenService.isTokenExpired(token)) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - tratar erros e refresh token
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    const originalRequest = error.config;

    // Token expirado - tentar refresh
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = tokenService.getRefreshToken();
        
        if (refreshToken) {
          const response = await axios.post(`${APP_CONFIG.API_BASE_URL}/auth/refresh`, {
            refresh_token: refreshToken
          });

          const { token: newToken } = response.data;
          
          tokenService.setToken(newToken);
          originalRequest.headers.Authorization = `Bearer ${newToken}`;
          
          return apiClient(originalRequest);
        }
      } catch (refreshError) {
        // Refresh falhou - fazer logout
        tokenService.clearAll();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    // Tratar outros erros
    handleApiError(error);
    
    return Promise.reject(error);
  }
);

// Função para tratar erros da API
const handleApiError = (error) => {
  const { response } = error;
  
  if (!response) {
    toast.error('Erro de conexão. Verifique sua internet.');
    return;
  }

  const { status, data } = response;
  
  switch (status) {
    case 400:
      toast.error(data?.message || 'Dados inválidos');
      break;
    case 401:
      toast.error('Acesso não autorizado');
      break;
    case 403:
      toast.error('Você não tem permissão para esta ação');
      break;
    case 404:
      toast.error('Recurso não encontrado');
      break;
    case 422:
      // Erros de validação
      if (data?.errors) {
        Object.values(data.errors).flat().forEach(error => {
          toast.error(error);
        });
      } else {
        toast.error(data?.message || 'Erro de validação');
      }
      break;
    case 429:
      toast.error('Muitas tentativas. Tente novamente em alguns minutos.');
      break;
    case 500:
      toast.error('Erro interno do servidor');
      break;
    default:
      toast.error(data?.message || 'Erro inesperado');
  }
};

export default apiClient;
EOF

# src/services/api/endpoints.js
cat > frontend/src/services/api/endpoints.js << 'EOF'
// Endpoints da API organizados por módulo
export const ENDPOINTS = {
  // Autenticação
  AUTH: {
    LOGIN: '/auth/login',
    PORTAL_LOGIN: '/auth/portal/login',
    LOGOUT: '/auth/logout',
    REFRESH: '/auth/refresh',
    VALIDATE: '/auth/validate',
    PROFILE: '/auth/profile',
    FORGOT_PASSWORD: '/auth/forgot-password',
    RESET_PASSWORD: '/auth/reset-password',
    CHANGE_PASSWORD: '/auth/change-password',
  },

  // Dashboard
  DASHBOARD: {
    STATS: '/dashboard/stats',
    RECENT_ACTIVITIES: '/dashboard/recent-activities',
    CHARTS: '/dashboard/charts',
  },

  // Clientes
  CLIENTS: {
    LIST: '/clients',
    CREATE: '/clients',
    SHOW: (id) => `/clients/${id}`,
    UPDATE: (id) => `/clients/${id}`,
    DELETE: (id) => `/clients/${id}`,
    SEARCH: '/clients/search',
    EXPORT: '/clients/export',
    PORTAL_ACCESS: (id) => `/clients/${id}/portal-access`,
  },

  // Processos
  PROCESSES: {
    LIST: '/processes',
    CREATE: '/processes',
    SHOW: (id) => `/processes/${id}`,
    UPDATE: (id) => `/processes/${id}`,
    DELETE: (id) => `/processes/${id}`,
    SEARCH: '/processes/search',
    MOVEMENTS: (id) => `/processes/${id}/movements`,
    SYNC_COURT: (id) => `/processes/${id}/sync-court`,
    EXPORT: '/processes/export',
  },

  // Atendimentos
  APPOINTMENTS: {
    LIST: '/appointments',
    CREATE: '/appointments',
    SHOW: (id) => `/appointments/${id}`,
    UPDATE: (id) => `/appointments/${id}`,
    DELETE: (id) => `/appointments/${id}`,
    CALENDAR: '/appointments/calendar',
    AVAILABLE_TIMES: '/appointments/available-times',
  },

  // Financeiro
  FINANCIAL: {
    DASHBOARD: '/financial/dashboard',
    TRANSACTIONS: '/financial/transactions',
    CREATE_TRANSACTION: '/financial/transactions',
    UPDATE_TRANSACTION: (id) => `/financial/transactions/${id}`,
    DELETE_TRANSACTION: (id) => `/financial/transactions/${id}`,
    REPORTS: '/financial/reports',
    EXPORT: '/financial/export',
  },

  // Documentos (GED)
  DOCUMENTS: {
    LIST: '/documents',
    UPLOAD: '/documents/upload',
    DOWNLOAD: (id) => `/documents/${id}/download`,
    DELETE: (id) => `/documents/${id}`,
    CLIENT_FOLDER: (clientId) => `/documents/client/${clientId}`,
    SEARCH: '/documents/search',
    SHARE: (id) => `/documents/${id}/share`,
  },

  // Kanban
  KANBAN: {
    BOARDS: '/kanban/boards',
    COLUMNS: '/kanban/columns',
    CARDS: '/kanban/cards',
    MOVE_CARD: '/kanban/cards/move',
    CREATE_CARD: '/kanban/cards',
    UPDATE_CARD: (id) => `/kanban/cards/${id}`,
    DELETE_CARD: (id) => `/kanban/cards/${id}`,
  },

  // Usuários
  USERS: {
    LIST: '/users',
    CREATE: '/users',
    SHOW: (id) => `/users/${id}`,
    UPDATE: (id) => `/users/${id}`,
    DELETE: (id) => `/users/${id}`,
    PERMISSIONS: '/users/permissions',
    ROLES: '/users/roles',
  },

  // Relatórios
  REPORTS: {
    CLIENTS: '/reports/clients',
    PROCESSES: '/reports/processes',
    FINANCIAL: '/reports/financial',
    PRODUCTIVITY: '/reports/productivity',
    CUSTOM: '/reports/custom',
    EXPORT: '/reports/export',
  },

  // Configurações
  SETTINGS: {
    GENERAL: '/settings/general',
    INTEGRATIONS: '/settings/integrations',
    NOTIFICATIONS: '/settings/notifications',
    PAYMENTS: '/settings/payments',
    BACKUPS: '/settings/backups',
  },

  // Portal do Cliente
  PORTAL: {
    DASHBOARD: '/portal/dashboard',
    PROCESSES: '/portal/processes',
    PROCESS_DETAIL: (id) => `/portal/processes/${id}`,
    DOCUMENTS: '/portal/documents',
    PAYMENTS: '/portal/payments',
    MESSAGES: '/portal/messages',
    SEND_MESSAGE: '/portal/messages',
    PROFILE: '/portal/profile',
  },

  // Integrações
  INTEGRATIONS: {
    TRIBUNALS: '/integrations/tribunals',
    GOOGLE_DRIVE: '/integrations/google-drive',
    ONEDRIVE: '/integrations/onedrive',
    STRIPE: '/integrations/stripe',
    MERCADO_PAGO: '/integrations/mercado-pago',
  },

  // Pagamentos
  PAYMENTS: {
    STRIPE: {
      CREATE_INTENT: '/payments/stripe/create-intent',
      CONFIRM: '/payments/stripe/confirm',
      WEBHOOKS: '/payments/stripe/webhooks',
    },
    MERCADO_PAGO: {
      CREATE_PREFERENCE: '/payments/mercado-pago/create-preference',
      PROCESS_PAYMENT: '/payments/mercado-pago/process-payment',
      WEBHOOKS: '/payments/mercado-pago/webhooks',
    },
  },
};
EOF

# src/services/api/clients/clientService.js
cat > frontend/src/services/api/clients/clientService.js << 'EOF'
import { apiClient } from '../apiClient';
import { ENDPOINTS } from '../endpoints';

export const clientService = {
  // Listar clientes
  async getClients(params = {}) {
    const response = await apiClient.get(ENDPOINTS.CLIENTS.LIST, { params });
    return response.data;
  },

  // Obter cliente por ID
  async getClient(id) {
    const response = await apiClient.get(ENDPOINTS.CLIENTS.SHOW(id));
    return response.data;
  },

  // Criar cliente
  async createClient(clientData) {
    const response = await apiClient.post(ENDPOINTS.CLIENTS.CREATE, clientData);
    return response.data;
  },

  // Atualizar cliente
  async updateClient(id, clientData) {
    const response = await apiClient.put(ENDPOINTS.CLIENTS.UPDATE(id), clientData);
    return response.data;
  },

  // Deletar cliente
  async deleteClient(id) {
    const response = await apiClient.delete(ENDPOINTS.CLIENTS.DELETE(id));
    return response.data;
  },

  // Buscar clientes
  async searchClients(query, filters = {}) {
    const response = await apiClient.get(ENDPOINTS.CLIENTS.SEARCH, {
      params: { q: query, ...filters }
    });
    return response.data;
  },

  // Exportar clientes
  async exportClients(format = 'excel', filters = {}) {
    const response = await apiClient.get(ENDPOINTS.CLIENTS.EXPORT, {
      params: { format, ...filters },
      responseType: 'blob'
    });
    return response.data;
  },

  // Gerenciar acesso ao portal
  async updatePortalAccess(id, accessData) {
    const response = await apiClient.put(ENDPOINTS.CLIENTS.PORTAL_ACCESS(id), accessData);
    return response.data;
  },
};
EOF

# src/services/api/processes/processService.js
cat > frontend/src/services/api/processes/processService.js << 'EOF'
import { apiClient } from '../apiClient';
import { ENDPOINTS } from '../endpoints';

export const processService = {
  // Listar processos
  async getProcesses(params = {}) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.LIST, { params });
    return response.data;
  },

  // Obter processo por ID
  async getProcess(id) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.SHOW(id));
    return response.data;
  },

  // Criar processo
  async createProcess(processData) {
    const response = await apiClient.post(ENDPOINTS.PROCESSES.CREATE, processData);
    return response.data;
  },

  // Atualizar processo
  async updateProcess(id, processData) {
    const response = await apiClient.put(ENDPOINTS.PROCESSES.UPDATE(id), processData);
    return response.data;
  },

  // Deletar processo
  async deleteProcess(id) {
    const response = await apiClient.delete(ENDPOINTS.PROCESSES.DELETE(id));
    return response.data;
  },

  // Obter movimentações do processo
  async getProcessMovements(id) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.MOVEMENTS(id));
    return response.data;
  },

  // Sincronizar com tribunal
  async syncWithCourt(id) {
    const response = await apiClient.post(ENDPOINTS.PROCESSES.SYNC_COURT(id));
    return response.data;
  },

  // Buscar processos
  async searchProcesses(query, filters = {}) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.SEARCH, {
      params: { q: query, ...filters }
    });
    return response.data;
  },

  // Exportar processos
  async exportProcesses(format = 'excel', filters = {}) {
    const response = await apiClient.get(ENDPOINTS.PROCESSES.EXPORT, {
      params: { format, ...filters },
      responseType: 'blob'
    });
    return response.data;
  },
};
EOF

# src/services/api/appointments/appointmentService.js
cat > frontend/src/services/api/appointments/appointmentService.js << 'EOF'
import { apiClient } from '../apiClient';
import { ENDPOINTS } from '../endpoints';

export const appointmentService = {
  // Listar atendimentos
  async getAppointments(params = {}) {
    const response = await apiClient.get(ENDPOINTS.APPOINTMENTS.LIST, { params });
    return response.data;
  },

  // Obter atendimento por ID
  async getAppointment(id) {
    const response = await apiClient.get(ENDPOINTS.APPOINTMENTS.SHOW(id));
    return response.data;
  },

  // Criar atendimento
  async createAppointment(appointmentData) {
    const response = await apiClient.post(ENDPOINTS.APPOINTMENTS.CREATE, appointmentData);
    return response.data;
  },

  // Atualizar atendimento
  async updateAppointment(id, appointmentData) {
    const response = await apiClient.put(ENDPOINTS.APPOINTMENTS.UPDATE(id), appointmentData);
    return response.data;
  },

  // Deletar atendimento
  async deleteAppointment(id) {
    const response = await apiClient.delete(ENDPOINTS.APPOINTMENTS.DELETE(id));
    return response.data;
  },

  // Obter calendário de atendimentos
  async getCalendar(startDate, endDate) {
    const response = await apiClient.get(ENDPOINTS.APPOINTMENTS.CALENDAR, {
      params: { start_date: startDate, end_date: endDate }
    });
    return response.data;
  },

  // Obter horários disponíveis
  async getAvailableTimes(date, lawyerId) {
    const response = await apiClient.get(ENDPOINTS.APPOINTMENTS.AVAILABLE_TIMES, {
      params: { date, lawyer_id: lawyerId }
    });
    return response.data;
  },
};
EOF

# src/services/api/financial/financialService.js
cat > frontend/src/services/api/financial/financialService.js << 'EOF'
import { apiClient } from '../apiClient';
import { ENDPOINTS } from '../endpoints';

export const financialService = {
  // Dashboard financeiro
  async getDashboard(period = 'month') {
    const response = await apiClient.get(ENDPOINTS.FINANCIAL.DASHBOARD, {
      params: { period }
    });
    return response.data;
  },

  // Listar transações
  async getTransactions(params = {}) {
    const response = await apiClient.get(ENDPOINTS.FINANCIAL.TRANSACTIONS, { params });
    return response.data;
  },

  // Criar transação
  async createTransaction(transactionData) {
    const response = await apiClient.post(ENDPOINTS.FINANCIAL.CREATE_TRANSACTION, transactionData);
    return response.data;
  },

  // Atualizar transação
  async updateTransaction(id, transactionData) {
    const response = await apiClient.put(ENDPOINTS.FINANCIAL.UPDATE_TRANSACTION(id), transactionData);
    return response.data;
  },

  // Deletar transação
  async deleteTransaction(id) {
    const response = await apiClient.delete(ENDPOINTS.FINANCIAL.DELETE_TRANSACTION(id));
    return response.data;
  },

  // Relatórios financeiros
  async getReports(type, params = {}) {
    const response = await apiClient.get(ENDPOINTS.FINANCIAL.REPORTS, {
      params: { type, ...params }
    });
    return response.data;
  },

  // Exportar dados financeiros
  async exportData(format = 'excel', filters = {}) {
    const response = await apiClient.get(ENDPOINTS.FINANCIAL.EXPORT, {
      params: { format, ...filters },
      responseType: 'blob'
    });
    return response.data;
  },
};
EOF

echo "✅ Services e API client criados com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • apiClient.js - Cliente Axios configurado"
echo "   • endpoints.js - URLs organizadas por módulo"
echo "   • clientService.js - CRUD de clientes"
echo "   • processService.js - CRUD de processos"
echo "   • appointmentService.js - CRUD de atendimentos"
echo "   • financialService.js - Módulo financeiro"
echo ""
echo "🔌 RECURSOS INCLUÍDOS:"
echo "   • Interceptors para token automático"
echo "   • Refresh token automático"
echo "   • Tratamento de erros centralizado"
echo "   • Toast notifications automáticos"
echo "   • Timeout e retry configuráveis"
echo "   • Endpoints organizados e tipados"
echo "   • Services com métodos CRUD completos"
echo ""
echo "⏭️  Próximo: Layouts e Componentes de Interface!"