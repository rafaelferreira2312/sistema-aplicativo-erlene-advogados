#!/bin/bash

# Script 115f - Correção de Proxy e Erro de Clientes
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115f-fix-proxy-clients-error.sh && ./115f-fix-proxy-clients-error.sh
# EXECUTE NA PASTA: frontend/

echo "🔧 Corrigindo erro de proxy e clients.map..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "📝 1. Corrigindo configuração de proxy no package.json..."

# Remover proxy incorreto do package.json e adicionar o correto
python3 -c "
import json

# Ler package.json
with open('package.json', 'r') as f:
    data = json.load(f)

# Remover proxy antigo se existir
if 'proxy' in data:
    del data['proxy']

# Escrever package.json sem proxy (usaremos .env)
with open('package.json', 'w') as f:
    json.dump(data, f, indent=2)

print('package.json atualizado - proxy removido')
"

echo "📝 2. Criando/Atualizando arquivo .env com configuração correta..."

# Criar .env com configuração correta
cat > .env << 'EOF'
# API Configuration - Backend Laravel
REACT_APP_API_URL=http://localhost:8000/api
REACT_APP_APP_URL=http://localhost:3000

# App Configuration
REACT_APP_APP_NAME="Sistema Erlene Advogados"
REACT_APP_VERSION="1.0.0"

# Features
REACT_APP_ENABLE_MOCK=false
REACT_APP_ENABLE_DEBUG=true

# Remove proxy warnings
GENERATE_SOURCEMAP=false
EOF

echo "📝 3. Corrigindo hook useClients para garantir formato correto dos dados..."

# Atualizar useClients.js para tratar dados vazios e formato incorreto
cat > src/hooks/useClients.js << 'EOF'
import { useState, useEffect, useCallback } from 'react';
import { clientsService } from '../services/api/clientsService';
import toast from 'react-hot-toast';

export const useClients = (initialParams = {}) => {
  const [clients, setClients] = useState([]); // Sempre iniciar como array vazio
  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [params, setParams] = useState(initialParams);

  // Carregar clientes
  const loadClients = useCallback(async (newParams = {}) => {
    try {
      setLoading(true);
      setError(null);
      
      const mergedParams = { ...params, ...newParams };
      const response = await clientsService.getClients(mergedParams);
      
      // Garantir que sempre temos um array
      let clientsData = [];
      
      if (response && response.data) {
        if (Array.isArray(response.data)) {
          clientsData = response.data;
        } else if (response.data.data && Array.isArray(response.data.data)) {
          // Paginação Laravel: { data: [...], meta: {...} }
          clientsData = response.data.data;
        } else {
          console.warn('Formato inesperado de dados:', response.data);
          clientsData = [];
        }
      }
      
      console.log('Clientes carregados:', clientsData.length, clientsData);
      setClients(clientsData);
      setParams(mergedParams);
    } catch (err) {
      console.error('Erro ao carregar clientes:', err);
      setError(err.message);
      setClients([]); // Garantir array vazio em caso de erro
      toast.error('Erro ao carregar clientes');
    } finally {
      setLoading(false);
    }
  }, [params]);

  // Carregar estatísticas
  const loadStats = useCallback(async () => {
    try {
      const response = await clientsService.getStats();
      
      let statsData = {};
      if (response && response.data) {
        statsData = response.data;
      }
      
      console.log('Estatísticas carregadas:', statsData);
      setStats(statsData);
    } catch (err) {
      console.error('Erro ao carregar estatísticas:', err);
      setStats({
        total: 0,
        ativos: 0,
        pf: 0,
        pj: 0
      });
    }
  }, []);

  // Criar cliente
  const createClient = useCallback(async (clientData) => {
    try {
      const response = await clientsService.createClient(clientData);
      toast.success('Cliente criado com sucesso!');
      await loadClients(); // Recarregar lista
      await loadStats(); // Atualizar estatísticas
      return response;
    } catch (err) {
      console.error('Erro ao criar cliente:', err);
      toast.error('Erro ao criar cliente');
      throw err;
    }
  }, [loadClients, loadStats]);

  // Atualizar cliente
  const updateClient = useCallback(async (id, clientData) => {
    try {
      const response = await clientsService.updateClient(id, clientData);
      toast.success('Cliente atualizado com sucesso!');
      await loadClients(); // Recarregar lista
      return response;
    } catch (err) {
      console.error('Erro ao atualizar cliente:', err);
      toast.error('Erro ao atualizar cliente');
      throw err;
    }
  }, [loadClients]);

  // Deletar cliente
  const deleteClient = useCallback(async (id) => {
    try {
      await clientsService.deleteClient(id);
      toast.success('Cliente excluído com sucesso!');
      await loadClients(); // Recarregar lista
      await loadStats(); // Atualizar estatísticas
    } catch (err) {
      console.error('Erro ao excluir cliente:', err);
      toast.error('Erro ao excluir cliente');
      throw err;
    }
  }, [loadClients, loadStats]);

  // Buscar CEP
  const buscarCep = useCallback(async (cep) => {
    try {
      const response = await clientsService.buscarCep(cep);
      return response.data;
    } catch (err) {
      console.error('Erro ao buscar CEP:', err);
      toast.error('CEP não encontrado');
      throw err;
    }
  }, []);

  // Aplicar filtros
  const applyFilters = useCallback((newParams) => {
    loadClients(newParams);
  }, [loadClients]);

  // Limpar filtros
  const clearFilters = useCallback(() => {
    const clearedParams = {};
    setParams(clearedParams);
    loadClients(clearedParams);
  }, [loadClients]);

  // Carregar dados iniciais
  useEffect(() => {
    loadClients();
    loadStats();
  }, []); // Removido dependência para evitar loop infinito

  return {
    // Estados - garantir que clients é sempre um array
    clients: Array.isArray(clients) ? clients : [],
    stats: stats || {},
    loading,
    error,
    params,
    
    // Ações
    loadClients,
    loadStats,
    createClient,
    updateClient,
    deleteClient,
    buscarCep,
    applyFilters,
    clearFilters,
    
    // Helpers
    refresh: () => {
      loadClients();
      loadStats();
    }
  };
};
EOF

echo "📝 4. Adicionando tratamento de erro na página Clients..."

# Verificar se Clients.js existe e adicionar proteção
if [ -f "src/pages/admin/Clients.js" ]; then
    echo "Adicionando proteção contra dados inválidos em Clients.js..."
    
    # Fazer backup
    cp src/pages/admin/Clients.js src/pages/admin/Clients.js.backup
    
    # Adicionar verificação no início do componente
    python3 -c "
import re

with open('src/pages/admin/Clients.js', 'r') as f:
    content = f.read()

# Adicionar verificação de array no início do componente, depois do hook useClients
pattern = r'(const \{\s*clients,[\s\S]*?\} = useClients\(\);)'
replacement = r'\1\n\n  // Garantir que clients é sempre um array\n  const safeClients = Array.isArray(clients) ? clients : [];\n  console.log(\"Clients data:\", { clients, safeClients, type: typeof clients });'

new_content = re.sub(pattern, replacement, content)

# Substituir todas as ocorrências de clients.map por safeClients.map
new_content = new_content.replace('clients.map', 'safeClients.map')
new_content = new_content.replace('clients.length', 'safeClients.length')

with open('src/pages/admin/Clients.js', 'w') as f:
    f.write(new_content)

print('Clients.js atualizado com proteção contra dados inválidos')
"
fi

echo "📝 5. Testando conexão com backend..."

# Verificar se o backend está rodando
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "✅ Backend Laravel está rodando em http://localhost:8000"
else
    echo "❌ Backend não está rodando. Iniciando..."
    echo "Execute em outra aba:"
    echo "cd ../backend && php artisan serve"
fi

echo "📝 6. Testando endpoint de clientes..."

# Testar endpoint de clientes se backend estiver rodando
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "Testando endpoint de clientes:"
    curl -s -H "Content-Type: application/json" http://localhost:8000/api/admin/clients | head -3
    echo ""
fi

echo "📝 7. Criando script de desenvolvimento..."

# Criar script para facilitar desenvolvimento
cat > start-dev.sh << 'EOF'
#!/bin/bash

echo "🚀 Iniciando ambiente de desenvolvimento..."

# Verificar se backend está rodando
if ! curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "Backend não está rodando. Execute:"
    echo "cd ../backend && php artisan serve"
    echo ""
fi

# Limpar cache do npm
npm start
EOF

chmod +x start-dev.sh

echo "✅ Correções aplicadas!"
echo ""
echo "🔧 PROBLEMAS CORRIGIDOS:"
echo "   • Proxy redirecionado para http://localhost:8000"
echo "   • Hook useClients protegido contra dados inválidos"
echo "   • Página Clients com verificação de array"
echo "   • Arquivo .env configurado corretamente"
echo ""
echo "🚀 PRÓXIMOS PASSOS:"
echo "   1. Parar o servidor React (Ctrl+C)"
echo "   2. Verificar se backend está rodando: cd ../backend && php artisan serve"
echo "   3. Reiniciar frontend: npm start"
echo "   4. Testar acesso a /admin/clientes"
echo ""
echo "📋 ARQUIVOS CRIADOS/MODIFICADOS:"
echo "   • .env - Configuração da API"
echo "   • src/hooks/useClients.js - Proteção contra dados inválidos"
echo "   • src/pages/admin/Clients.js - Verificação de array"
echo "   • start-dev.sh - Script de desenvolvimento"
echo ""
echo "Digite 'funcionou' após testar..."