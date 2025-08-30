import apiService from '../api';

class DashboardService {
  constructor() {
    this.api = apiService;
  }

  async getDashboardData() {
    try {
      console.log('Buscando dados do dashboard...');
      
      const response = await this.api.getDashboardStats();
      
      if (response.success) {
        console.log('Dados do dashboard carregados:', response.data);
        return {
          success: true,
          data: this.formatDashboardData(response.data)
        };
      }
      
      return {
        success: false,
        message: response.message || 'Erro ao carregar dados do dashboard'
      };
      
    } catch (error) {
      console.error('Erro no DashboardService:', error);
      return {
        success: false,
        message: error.message || 'Erro de conexão com o servidor'
      };
    }
  }

  async getNotifications() {
    try {
      const response = await this.api.getDashboardNotifications();
      
      if (response.success) {
        return {
          success: true,
          data: response.data || []
        };
      }
      
      return {
        success: false,
        message: response.message || 'Erro ao carregar notificações',
        data: []
      };
      
    } catch (error) {
      console.error('Erro ao buscar notificações:', error);
      return {
        success: false,
        message: error.message || 'Erro de conexão',
        data: []
      };
    }
  }

  formatDashboardData(data) {
    try {
      return {
        // Usar dados exatos da API (incluindo porcentagens calculadas no backend)
        stats: {
          clientes: {
            total: data.stats?.clientes?.total || 0,
            ativos: data.stats?.clientes?.ativos || 0,
            novos_mes: data.stats?.clientes?.novos_mes || 0,
            porcentagem: data.stats?.clientes?.porcentagem || '0%',
            tipo_mudanca: data.stats?.clientes?.tipo_mudanca || 'stable'
          },
          processos: {
            total: data.stats?.processos?.total || 0,
            ativos: data.stats?.processos?.ativos || 0,
            urgentes: data.stats?.processos?.urgentes || 0,
            prazos_vencendo: data.stats?.processos?.prazos_vencendo || 0,
            porcentagem: data.stats?.processos?.porcentagem || '0%',
            tipo_mudanca: data.stats?.processos?.tipo_mudanca || 'stable'
          },
          atendimentos: {
            hoje: data.stats?.atendimentos?.hoje || 0,
            semana: data.stats?.atendimentos?.semana || 0,
            agendados: data.stats?.atendimentos?.agendados || 0,
            porcentagem: data.stats?.atendimentos?.porcentagem || '0%',
            tipo_mudanca: data.stats?.atendimentos?.tipo_mudanca || 'stable'
          },
          financeiro: {
            receita_mes_formatada: data.stats?.financeiro?.receita_mes_formatada || 'R$ 0,00',
            receita_mes_valor: data.stats?.financeiro?.receita_mes || 0,
            pendente: data.stats?.financeiro?.pendente || 0,
            vencidos: data.stats?.financeiro?.vencidos || 0,
            porcentagem: data.stats?.financeiro?.porcentagem || '0%',
            tipo_mudanca: data.stats?.financeiro?.tipo_mudanca || 'stable'
          },
          tarefas: {
            pendentes: data.stats?.tarefas?.pendentes || 0,
            vencidas: data.stats?.tarefas?.vencidas || 0
          }
        },
        
        graficos: {
          atendimentos: data.graficos?.atendimentos || [],
          receitas: data.graficos?.receitas || []
        },
        
        listas: {
          proximos_atendimentos: data.listas?.proximos_atendimentos || [],
          processos_urgentes: data.listas?.processos_urgentes || [],
          tarefas_pendentes: data.listas?.tarefas_pendentes || []
        },

        acoes_rapidas: data.acoes_rapidas || {},
        ultima_atualizacao: data.ultima_atualizacao
      };
    } catch (error) {
      console.error('Erro ao formatar dados do dashboard:', error);
      return this.getEmptyDashboardData();
    }
  }

  getEmptyDashboardData() {
    return {
      stats: {
        clientes: { total: 0, ativos: 0, novos_mes: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
        processos: { total: 0, ativos: 0, urgentes: 0, prazos_vencendo: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
        atendimentos: { hoje: 0, semana: 0, agendados: 0, porcentagem: '0%', tipo_mudanca: 'stable' },
        financeiro: { 
          receita_mes_formatada: 'R$ 0,00', 
          receita_mes_valor: 0,
          pendente: 0, 
          vencidos: 0,
          porcentagem: '0%',
          tipo_mudanca: 'stable'
        },
        tarefas: { pendentes: 0, vencidas: 0 }
      },
      graficos: { atendimentos: [], receitas: [] },
      listas: { proximos_atendimentos: [], processos_urgentes: [], tarefas_pendentes: [] }
    };
  }

  isDataFresh(timestamp, maxAge = 5 * 60 * 1000) {
    if (!timestamp) return false;
    return (Date.now() - timestamp) < maxAge;
  }

  getCachedData() {
    try {
      const cached = localStorage.getItem('dashboard_cache');
      if (!cached) return null;
      
      const data = JSON.parse(cached);
      if (this.isDataFresh(data.timestamp)) {
        return data.data;
      }
      
      localStorage.removeItem('dashboard_cache');
      return null;
    } catch (error) {
      return null;
    }
  }

  setCachedData(data) {
    try {
      const cacheData = { data: data, timestamp: Date.now() };
      localStorage.setItem('dashboard_cache', JSON.stringify(cacheData));
    } catch (error) {
      console.error('Erro ao salvar cache:', error);
    }
  }

  async getDashboardDataWithCache(useCache = true) {
    if (useCache) {
      const cachedData = this.getCachedData();
      if (cachedData) {
        console.log('Usando dados do cache');
        return { success: true, data: cachedData, fromCache: true };
      }
    }

    const result = await this.getDashboardData();
    
    if (result.success) {
      this.setCachedData(result.data);
    }
    
    return { ...result, fromCache: false };
  }
}

const dashboardService = new DashboardService();
export default dashboardService;
export { dashboardService };
