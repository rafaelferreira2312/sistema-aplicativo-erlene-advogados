// Configurações da aplicação
export const APP_CONFIG = {
  NAME: 'Sistema Erlene Advogados',
  VERSION: '1.0.0',
  API_BASE_URL: process.env.REACT_APP_API_URL || 'http://localhost:8000/api',
  APP_URL: process.env.REACT_APP_URL || 'http://localhost:3000',
  
  STORAGE_KEYS: {
    TOKEN: 'erlene_token',
    REFRESH_TOKEN: 'erlene_refresh_token',
    USER: 'erlene_user',
    THEME: 'erlene_theme',
  },
};

export const USER_TYPES = {
  ADMIN_GERAL: 'admin_geral',
  ADVOGADO: 'advogado',
  CLIENTE: 'cliente',
};
