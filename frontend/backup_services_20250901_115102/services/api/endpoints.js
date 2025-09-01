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
