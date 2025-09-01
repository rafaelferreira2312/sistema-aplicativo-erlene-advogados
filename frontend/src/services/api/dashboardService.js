import apiClient from './apiClient';

export const dashboardService = {
  // Obter estatísticas do dashboard
  async getStats() {
    try {
      const response = await apiClient.get('/admin/dashboard');
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar estatísticas do dashboard:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar estatísticas',
        data: {
          totalClients: 0,
          activeProcesses: 0,
          pendingAppointments: 0,
          monthlyRevenue: 0
        }
      };
    }
  },

  // Obter notificações recentes
  async getNotifications() {
    try {
      const response = await apiClient.get('/admin/dashboard/notifications');
      return {
        success: true,
        data: response.data.data || response.data || []
      };
    } catch (error) {
      console.error('Erro ao buscar notificações:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar notificações',
        data: []
      };
    }
  },

  // Obter atividades recentes
  async getRecentActivities() {
    try {
      const response = await apiClient.get('/admin/dashboard/activities');
      return {
        success: true,
        data: response.data.data || response.data || []
      };
    } catch (error) {
      console.error('Erro ao buscar atividades:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar atividades',
        data: []
      };
    }
  },

  // Obter gráficos do dashboard
  async getCharts(period = 'month') {
    try {
      const response = await apiClient.get('/admin/dashboard/charts', {
        params: { period }
      });
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar gráficos:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar gráficos',
        data: {}
      };
    }
  }
};

export default dashboardService;
