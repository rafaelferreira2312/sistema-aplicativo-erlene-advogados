import { useState, useEffect, useCallback } from 'react';
import { clientsService } from '../services/api/clientsService';
import toast from 'react-hot-toast';

export const useClients = (initialParams = {}) => {
  const [clients, setClients] = useState([]);
  const [stats, setStats] = useState({ total: 0, ativos: 0, pf: 0, pj: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Carregar clientes - função estável
  const loadClients = useCallback(async (params = {}) => {
    try {
      setLoading(true);
      setError(null);
      
      console.log('Carregando clientes com parâmetros:', params);
      const response = await clientsService.getClients(params);
      
      console.log('Resposta da API:', response);
      
      // Extrair dados da resposta
      let clientsData = [];
      if (response?.data) {
        if (Array.isArray(response.data)) {
          clientsData = response.data;
        } else if (response.data.data && Array.isArray(response.data.data)) {
          clientsData = response.data.data;
        }
      }
      
      console.log('Clientes extraídos:', clientsData);
      setClients(clientsData);
    } catch (err) {
      console.error('Erro ao carregar clientes:', err);
      setError(err.message);
      setClients([]);
      toast.error('Erro ao carregar clientes');
    } finally {
      setLoading(false);
    }
  }, []);

  // Carregar estatísticas
  const loadStats = useCallback(async () => {
    try {
      const response = await clientsService.getStats();
      if (response?.data) {
        setStats(response.data);
      }
    } catch (err) {
      console.error('Erro ao carregar estatísticas:', err);
    }
  }, []);

  // Carregar dados apenas uma vez
  useEffect(() => {
    loadClients();
    loadStats();
  }, []); // Array vazio para carregar apenas uma vez

  // Aplicar filtros
  const applyFilters = useCallback((params) => {
    loadClients(params);
  }, [loadClients]);

  // Criar cliente
  const createClient = useCallback(async (clientData) => {
    try {
      const response = await clientsService.createClient(clientData);
      toast.success('Cliente criado com sucesso!');
      await loadClients();
      await loadStats();
      return response;
    } catch (err) {
      toast.error('Erro ao criar cliente');
      throw err;
    }
  }, [loadClients, loadStats]);

  // Atualizar cliente
  const updateClient = useCallback(async (id, clientData) => {
    try {
      const response = await clientsService.updateClient(id, clientData);
      toast.success('Cliente atualizado com sucesso!');
      await loadClients();
      return response;
    } catch (err) {
      toast.error('Erro ao atualizar cliente');
      throw err;
    }
  }, [loadClients]);

  // Deletar cliente
  const deleteClient = useCallback(async (id) => {
    try {
      await clientsService.deleteClient(id);
      toast.success('Cliente excluído com sucesso!');
      await loadClients();
      await loadStats();
    } catch (err) {
      toast.error('Erro ao excluir cliente');
      throw err;
    }
  }, [loadClients, loadStats]);

  return {
    clients: Array.isArray(clients) ? clients : [],
    stats,
    loading,
    error,
    loadClients,
    createClient,
    updateClient,
    deleteClient,
    applyFilters,
    refresh: () => {
      loadClients();
      loadStats();
    }
  };
};
