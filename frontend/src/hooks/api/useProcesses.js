import { useQuery, useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { processService } from '../../services/api/processes/processService';

// Hook para listar processos
export const useProcesses = (params = {}) => {
  return useQuery(
    ['processes', params],
    () => processService.getProcesses(params),
    {
      keepPreviousData: true,
      staleTime: 5 * 60 * 1000,
    }
  );
};

// Hook para obter um processo específico
export const useProcess = (id) => {
  return useQuery(
    ['process', id],
    () => processService.getProcess(id),
    {
      enabled: !!id,
      staleTime: 10 * 60 * 1000,
    }
  );
};

// Hook para movimentações do processo
export const useProcessMovements = (id) => {
  return useQuery(
    ['process-movements', id],
    () => processService.getProcessMovements(id),
    {
      enabled: !!id,
      refetchInterval: 5 * 60 * 1000, // Atualizar a cada 5 minutos
    }
  );
};

// Hook para criar processo
export const useCreateProcess = () => {
  const queryClient = useQueryClient();

  return useMutation(processService.createProcess, {
    onSuccess: (data) => {
      queryClient.invalidateQueries(['processes']);
      toast.success('Processo criado com sucesso!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.message || 'Erro ao criar processo');
    },
  });
};

// Hook para atualizar processo
export const useUpdateProcess = () => {
  const queryClient = useQueryClient();

  return useMutation(
    ({ id, data }) => processService.updateProcess(id, data),
    {
      onSuccess: (data, variables) => {
        queryClient.invalidateQueries(['processes']);
        queryClient.invalidateQueries(['process', variables.id]);
        queryClient.invalidateQueries(['process-movements', variables.id]);
        toast.success('Processo atualizado com sucesso!');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Erro ao atualizar processo');
      },
    }
  );
};

// Hook para sincronizar com tribunal
export const useSyncWithCourt = () => {
  const queryClient = useQueryClient();

  return useMutation(processService.syncWithCourt, {
    onSuccess: (data, processId) => {
      queryClient.invalidateQueries(['process', processId]);
      queryClient.invalidateQueries(['process-movements', processId]);
      toast.success('Processo sincronizado com sucesso!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.message || 'Erro ao sincronizar processo');
    },
  });
};

// Hook para buscar processos
export const useSearchProcesses = () => {
  return useMutation(
    ({ query, filters }) => processService.searchProcesses(query, filters),
    {
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Erro na busca');
      },
    }
  );
};
