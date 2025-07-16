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
