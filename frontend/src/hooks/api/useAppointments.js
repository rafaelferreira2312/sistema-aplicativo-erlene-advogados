import { useQuery, useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { appointmentService } from '../../services/api/appointments/appointmentService';

// Hook para listar atendimentos
export const useAppointments = (params = {}) => {
  return useQuery(
    ['appointments', params],
    () => appointmentService.getAppointments(params),
    {
      keepPreviousData: true,
      staleTime: 2 * 60 * 1000, // 2 minutos (dados mais dinâmicos)
    }
  );
};

// Hook para obter um atendimento específico
export const useAppointment = (id) => {
  return useQuery(
    ['appointment', id],
    () => appointmentService.getAppointment(id),
    {
      enabled: !!id,
      staleTime: 5 * 60 * 1000,
    }
  );
};

// Hook para calendário de atendimentos
export const useAppointmentCalendar = (startDate, endDate) => {
  return useQuery(
    ['appointment-calendar', startDate, endDate],
    () => appointmentService.getCalendar(startDate, endDate),
    {
      enabled: !!(startDate && endDate),
      staleTime: 1 * 60 * 1000, // 1 minuto
    }
  );
};

// Hook para horários disponíveis
export const useAvailableTimes = (date, lawyerId) => {
  return useQuery(
    ['available-times', date, lawyerId],
    () => appointmentService.getAvailableTimes(date, lawyerId),
    {
      enabled: !!(date && lawyerId),
      staleTime: 30 * 1000, // 30 segundos
    }
  );
};

// Hook para criar atendimento
export const useCreateAppointment = () => {
  const queryClient = useQueryClient();

  return useMutation(appointmentService.createAppointment, {
    onSuccess: (data) => {
      queryClient.invalidateQueries(['appointments']);
      queryClient.invalidateQueries(['appointment-calendar']);
      queryClient.invalidateQueries(['available-times']);
      toast.success('Atendimento agendado com sucesso!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.message || 'Erro ao agendar atendimento');
    },
  });
};

// Hook para atualizar atendimento
export const useUpdateAppointment = () => {
  const queryClient = useQueryClient();

  return useMutation(
    ({ id, data }) => appointmentService.updateAppointment(id, data),
    {
      onSuccess: (data, variables) => {
        queryClient.invalidateQueries(['appointments']);
        queryClient.invalidateQueries(['appointment', variables.id]);
        queryClient.invalidateQueries(['appointment-calendar']);
        toast.success('Atendimento atualizado com sucesso!');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Erro ao atualizar atendimento');
      },
    }
  );
};

// Hook para deletar atendimento
export const useDeleteAppointment = () => {
  const queryClient = useQueryClient();

  return useMutation(appointmentService.deleteAppointment, {
    onSuccess: () => {
      queryClient.invalidateQueries(['appointments']);
      queryClient.invalidateQueries(['appointment-calendar']);
      toast.success('Atendimento cancelado com sucesso!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.message || 'Erro ao cancelar atendimento');
    },
  });
};
