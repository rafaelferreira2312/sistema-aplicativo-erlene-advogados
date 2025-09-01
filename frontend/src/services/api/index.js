// Exports centralizados dos services da API
export { default as apiClient } from './apiClient';
export { clientsService } from './clientsService';
export { dashboardService } from './dashboardService';
export { authService } from '../auth/authService';

// Re-export para compatibilidade
export { default as authService } from '../auth/authService';
export { default as clientsService } from './clientsService';
export { default as dashboardService } from './dashboardService';

// Export do apiService principal
export { default as apiService } from '../api';
