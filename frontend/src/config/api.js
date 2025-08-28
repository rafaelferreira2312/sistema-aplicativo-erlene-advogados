// Configurações da API - Backend Laravel
export const API_CONFIG = {
  BASE_URL: process.env.REACT_APP_API_URL || 'http://localhost:8000/api',
  TIMEOUT: 30000,
  HEADERS: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  }
};

// Endpoints da API
export const API_ENDPOINTS = {
  // Autenticação
  AUTH: {
    LOGIN: '/auth/login',
    LOGOUT: '/auth/logout',
    REFRESH: '/auth/refresh',
    ME: '/auth/me',
    PORTAL_LOGIN: '/auth/portal/login'
  },

  // Clientes
  CLIENTS: {
    LIST: '/clients',
    CREATE: '/clients',
    SHOW: '/clients/{id}',
    UPDATE: '/clients/{id}',
    DELETE: '/clients/{id}'
  },

  // Processos
  PROCESSES: {
    LIST: '/processes',
    CREATE: '/processes',
    SHOW: '/processes/{id}',
    UPDATE: '/processes/{id}',
    DELETE: '/processes/{id}',
    MOVEMENTS: '/processes/{id}/movements'
  },

  // Audiências
  AUDIENCES: {
    LIST: '/audiences',
    CREATE: '/audiences',
    SHOW: '/audiences/{id}',
    UPDATE: '/audiences/{id}',
    DELETE: '/audiences/{id}'
  },

  // Prazos
  DEADLINES: {
    LIST: '/deadlines',
    CREATE: '/deadlines',
    SHOW: '/deadlines/{id}',
    UPDATE: '/deadlines/{id}',
    DELETE: '/deadlines/{id}'
  },

  // Atendimentos
  APPOINTMENTS: {
    LIST: '/appointments',
    CREATE: '/appointments',
    SHOW: '/appointments/{id}',
    UPDATE: '/appointments/{id}',
    DELETE: '/appointments/{id}'
  },

  // Financeiro
  FINANCIAL: {
    LIST: '/financial',
    CREATE: '/financial',
    SHOW: '/financial/{id}',
    UPDATE: '/financial/{id}',
    DELETE: '/financial/{id}',
    DASHBOARD: '/financial/dashboard'
  },

  // Documentos
  DOCUMENTS: {
    LIST: '/documents',
    UPLOAD: '/documents',
    SHOW: '/documents/{id}',
    DOWNLOAD: '/documents/{id}/download',
    DELETE: '/documents/{id}'
  },

  // Portal do Cliente
  PORTAL: {
    DASHBOARD: '/portal/dashboard',
    PROCESSES: '/portal/processes',
    DOCUMENTS: '/portal/documents',
    PAYMENTS: '/portal/payments',
    MESSAGES: '/portal/messages'
  }
};

// Status codes
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  UNPROCESSABLE_ENTITY: 422,
  INTERNAL_SERVER_ERROR: 500
};
