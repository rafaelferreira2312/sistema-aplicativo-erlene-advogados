import { useQuery, useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import { clientService } from '../../services/api/clients/clientService';

// Hook para listar clientes
export const useClients = (params = {}) => {
  return useQuery(
    ['clients', params],
    () => clientService.getClients(params),
    {
      keepPreviousData: true,
      staleTime: 5 * 60 * 1000, // 5 minutos
    }
  );
};

// Hook para obter um cliente específico
export const useClient = (id) => {
  return useQuery(
    ['client', id],
    () => clientService.getClient(id),
    {
      enabled: !!id,
      staleTime: 10 * 60 * 1000, // 10 minutos
    }
  );
};

// Hook para criar cliente
export const useCreateClient = () => {
  const queryClient = useQueryClient();

  return useMutation(clientService.createClient, {
    onSuccess: (data) => {
      queryClient.invalidateQueries(['clients']);
      toast.success('Cliente criado com sucesso!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.message || 'Erro ao criar cliente');
    },
  });
};

// Hook para atualizar cliente
export const useUpdateClient = () => {
  const queryClient = useQueryClient();

  return useMutation(
    ({ id, data }) => clientService.updateClient(id, data),
    {
      onSuccess: (data, variables) => {
        queryClient.invalidateQueries(['clients']);
        queryClient.invalidateQueries(['client', variables.id]);
        toast.success('Cliente atualizado com sucesso!');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Erro ao atualizar cliente');
      },
    }
  );
};

// Hook para deletar cliente
export const useDeleteClient = () => {
  const queryClient = useQueryClient();

  return useMutation(clientService.deleteClient, {
    onSuccess: () => {
      queryClient.invalidateQueries(['clients']);
      toast.success('Cliente removido com sucesso!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.message || 'Erro ao remover cliente');
    },
  });
};

// Hook para buscar clientes
export const useSearchClients = () => {
  return useMutation(
    ({ query, filters }) => clientService.searchClients(query, filters),
    {
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Erro na busca');
      },
    }
  );
};

// Hook para exportar clientes
export const useExportClients = () => {
  return useMutation(
    ({ format, filters }) => clientService.exportClients(format, filters),
    {
      onSuccess: (blob, variables) => {
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `clientes.${variables.format === 'excel' ? 'xlsx' : 'pdf'}`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        window.URL.revokeObjectURL(url);
        toast.success('Arquivo exportado com sucesso!');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Erro ao exportar');
      },
    }
  );
};
