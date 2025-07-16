#!/bin/bash

# Script 37 - Hooks Customizados
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/37-create-custom-hooks.sh

echo "🪝 Criando hooks customizados..."

# src/hooks/api/useClients.js
cat > frontend/src/hooks/api/useClients.js << 'EOF'
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
EOF

# src/hooks/api/useProcesses.js
cat > frontend/src/hooks/api/useProcesses.js << 'EOF'
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
EOF

# src/hooks/api/useAppointments.js
cat > frontend/src/hooks/api/useAppointments.js << 'EOF'
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
EOF

# src/hooks/common/useLocalStorage.js
cat > frontend/src/hooks/common/useLocalStorage.js << 'EOF'
import { useState, useEffect } from 'react';

export const useLocalStorage = (key, initialValue) => {
  // State para armazenar nosso valor
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Erro ao ler localStorage para key "${key}":`, error);
      return initialValue;
    }
  });

  // Função para definir o valor
  const setValue = (value) => {
    try {
      // Permitir value ser uma função para ter a mesma API que useState
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      
      setStoredValue(valueToStore);
      
      if (valueToStore === undefined) {
        window.localStorage.removeItem(key);
      } else {
        window.localStorage.setItem(key, JSON.stringify(valueToStore));
      }
    } catch (error) {
      console.error(`Erro ao salvar localStorage para key "${key}":`, error);
    }
  };

  // Sincronizar com mudanças do localStorage em outras abas
  useEffect(() => {
    const handleStorageChange = (e) => {
      if (e.key === key && e.newValue !== null) {
        try {
          setStoredValue(JSON.parse(e.newValue));
        } catch (error) {
          console.error(`Erro ao sincronizar localStorage para key "${key}":`, error);
        }
      }
    };

    window.addEventListener('storage', handleStorageChange);
    return () => window.removeEventListener('storage', handleStorageChange);
  }, [key]);

  return [storedValue, setValue];
};
EOF

# src/hooks/common/useDebounce.js
cat > frontend/src/hooks/common/useDebounce.js << 'EOF'
import { useState, useEffect } from 'react';

export const useDebounce = (value, delay) => {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
};

// Hook para função debounced
export const useDebouncedCallback = (callback, delay) => {
  const [debounceTimer, setDebounceTimer] = useState(null);

  const debouncedCallback = (...args) => {
    if (debounceTimer) {
      clearTimeout(debounceTimer);
    }

    const newTimer = setTimeout(() => {
      callback(...args);
    }, delay);

    setDebounceTimer(newTimer);
  };

  useEffect(() => {
    return () => {
      if (debounceTimer) {
        clearTimeout(debounceTimer);
      }
    };
  }, [debounceTimer]);

  return debouncedCallback;
};
EOF

# src/hooks/common/usePagination.js
cat > frontend/src/hooks/common/usePagination.js << 'EOF'
import { useState, useMemo } from 'react';

export const usePagination = ({
  data = [],
  itemsPerPage = 10,
  initialPage = 1,
}) => {
  const [currentPage, setCurrentPage] = useState(initialPage);

  // Calcular dados paginados
  const paginatedData = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return data.slice(startIndex, endIndex);
  }, [data, currentPage, itemsPerPage]);

  // Calcular informações de paginação
  const paginationInfo = useMemo(() => {
    const totalItems = data.length;
    const totalPages = Math.ceil(totalItems / itemsPerPage);
    const startItem = (currentPage - 1) * itemsPerPage + 1;
    const endItem = Math.min(currentPage * itemsPerPage, totalItems);

    return {
      totalItems,
      totalPages,
      currentPage,
      itemsPerPage,
      startItem: totalItems > 0 ? startItem : 0,
      endItem,
      hasNextPage: currentPage < totalPages,
      hasPreviousPage: currentPage > 1,
    };
  }, [data.length, currentPage, itemsPerPage]);

  // Funções de navegação
  const goToPage = (page) => {
    const newPage = Math.max(1, Math.min(page, paginationInfo.totalPages));
    setCurrentPage(newPage);
  };

  const nextPage = () => {
    if (paginationInfo.hasNextPage) {
      setCurrentPage(currentPage + 1);
    }
  };

  const previousPage = () => {
    if (paginationInfo.hasPreviousPage) {
      setCurrentPage(currentPage - 1);
    }
  };

  const goToFirstPage = () => {
    setCurrentPage(1);
  };

  const goToLastPage = () => {
    setCurrentPage(paginationInfo.totalPages);
  };

  return {
    paginatedData,
    paginationInfo,
    goToPage,
    nextPage,
    previousPage,
    goToFirstPage,
    goToLastPage,
    setCurrentPage,
  };
};
EOF

# src/hooks/common/useForm.js
cat > frontend/src/hooks/common/useForm.js << 'EOF'
import { useState, useCallback } from 'react';

export const useForm = (initialValues = {}, validationSchema = {}) => {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Atualizar um campo
  const setValue = useCallback((name, value) => {
    setValues(prev => ({
      ...prev,
      [name]: value
    }));

    // Limpar erro quando o campo é modificado
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: undefined
      }));
    }
  }, [errors]);

  // Atualizar múltiplos campos
  const setValues = useCallback((newValues) => {
    setValues(prev => ({
      ...prev,
      ...newValues
    }));
  }, []);

  // Marcar campo como tocado
  const setFieldTouched = useCallback((name, touched = true) => {
    setTouched(prev => ({
      ...prev,
      [name]: touched
    }));
  }, []);

  // Validar um campo específico
  const validateField = useCallback((name, value) => {
    const fieldValidation = validationSchema[name];
    if (!fieldValidation) return '';

    if (typeof fieldValidation === 'function') {
      return fieldValidation(value, values);
    }

    return '';
  }, [validationSchema, values]);

  // Validar todo o formulário
  const validateForm = useCallback(() => {
    const newErrors = {};
    let isValid = true;

    Object.keys(validationSchema).forEach(name => {
      const error = validateField(name, values[name]);
      if (error) {
        newErrors[name] = error;
        isValid = false;
      }
    });

    setErrors(newErrors);
    return isValid;
  }, [validationSchema, values, validateField]);

  // Handler para mudança de campo
  const handleChange = useCallback((event) => {
    const { name, value, type, checked } = event.target;
    const fieldValue = type === 'checkbox' ? checked : value;
    
    setValue(name, fieldValue);
  }, [setValue]);

  // Handler para blur
  const handleBlur = useCallback((event) => {
    const { name } = event.target;
    setFieldTouched(name, true);
    
    const error = validateField(name, values[name]);
    if (error) {
      setErrors(prev => ({
        ...prev,
        [name]: error
      }));
    }
  }, [setFieldTouched, validateField, values]);

  // Handler para submit
  const handleSubmit = useCallback((onSubmit) => {
    return async (event) => {
      if (event) {
        event.preventDefault();
      }

      // Marcar todos os campos como tocados
      const allTouched = Object.keys(values).reduce((acc, key) => {
        acc[key] = true;
        return acc;
      }, {});
      setTouched(allTouched);

      // Validar formulário
      const isValid = validateForm();
      
      if (isValid) {
        setIsSubmitting(true);
        try {
          await onSubmit(values);
        } catch (error) {
          console.error('Erro no submit:', error);
        } finally {
          setIsSubmitting(false);
        }
      }
    };
  }, [values, validateForm]);

  // Reset do formulário
  const reset = useCallback((newValues = initialValues) => {
    setValues(newValues);
    setErrors({});
    setTouched({});
    setIsSubmitting(false);
  }, [initialValues]);

  // Verificar se o formulário é válido
  const isValid = Object.keys(errors).length === 0;

  return {
    values,
    errors,
    touched,
    isSubmitting,
    isValid,
    setValue,
    setValues,
    setFieldTouched,
    handleChange,
    handleBlur,
    handleSubmit,
    validateField,
    validateForm,
    reset,
  };
};
EOF

echo "✅ Hooks customizados criados com sucesso!"
echo ""
echo "📊 HOOKS CRIADOS:"
echo "   • useClients - CRUD completo de clientes"
echo "   • useProcesses - CRUD completo de processos"
echo "   • useAppointments - CRUD completo de atendimentos"
echo "   • useLocalStorage - Persistência local sincronizada"
echo "   • useDebounce - Debounce para busca e performance"
echo "   • usePagination - Paginação completa com navegação"
echo "   • useForm - Formulários com validação"
echo ""
echo "🪝 RECURSOS INCLUÍDOS:"
echo "   • React Query integrado com cache inteligente"
echo "   • Toast notifications automáticos"
echo "   • Error handling centralizado"
echo "   • Invalidação de cache otimizada"
echo "   • Hooks reutilizáveis e performáticos"
echo "   • Validação de formulários flexível"
echo "   • Paginação com todas as funções necessárias"
echo ""
echo "⏭️  Próximo: Context providers (Theme, Notification)!"