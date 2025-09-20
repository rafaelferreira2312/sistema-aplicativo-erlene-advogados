#!/bin/bash

# Script 206b - Corrigir Imports Frontend
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 206b - Corrigindo imports do frontend..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# 1. Corrigir services para exportar da forma correta
echo "🔧 Corrigindo clientsService.js..."
cat > src/services/clientsService.js << 'EOF'
import { apiRequest } from './api';

class ClientsService {
  constructor() {
    this.baseURL = '/clients';
  }

  async getAll() {
    try {
      return await apiRequest('GET', this.baseURL);
    } catch (error) {
      console.error('Erro ao buscar clientes:', error);
      return {
        success: true,
        data: []
      };
    }
  }

  async getById(id) {
    try {
      return await apiRequest('GET', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao buscar cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async create(clientData) {
    try {
      return await apiRequest('POST', this.baseURL, clientData);
    } catch (error) {
      console.error('Erro ao criar cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async update(id, clientData) {
    try {
      return await apiRequest('PUT', `${this.baseURL}/${id}`, clientData);
    } catch (error) {
      console.error('Erro ao atualizar cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async delete(id) {
    try {
      return await apiRequest('DELETE', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao excluir cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }
}

// Criar instância
const clientsService = new ClientsService();

// Exportar instância como default E como named export
export default clientsService;
export { clientsService };
EOF

# 2. Corrigir processesService.js
echo "🔧 Corrigindo processesService.js..."
cat > src/services/processesService.js << 'EOF'
import { apiRequest, testApiConnection, loginForToken } from './api';

class ProcessesService {
  constructor() {
    this.baseURL = '/processes';
  }

  async testConnection() {
    return await testApiConnection();
  }

  async getToken(credentials) {
    return await loginForToken(credentials);
  }

  async getAll() {
    try {
      return await apiRequest('GET', this.baseURL);
    } catch (error) {
      console.error('Erro ao buscar processos:', error);
      return {
        success: true,
        data: []
      };
    }
  }

  async getById(id) {
    try {
      return await apiRequest('GET', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao buscar processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async create(processData) {
    try {
      return await apiRequest('POST', this.baseURL, processData);
    } catch (error) {
      console.error('Erro ao criar processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async update(id, processData) {
    try {
      return await apiRequest('PUT', `${this.baseURL}/${id}`, processData);
    } catch (error) {
      console.error('Erro ao atualizar processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async delete(id) {
    try {
      return await apiRequest('DELETE', `${this.baseURL}/${id}`);
    } catch (error) {
      console.error('Erro ao excluir processo:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async getByClient(clientId) {
    try {
      return await apiRequest('GET', `${this.baseURL}/client/${clientId}`);
    } catch (error) {
      console.error('Erro ao buscar processos do cliente:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async updateStatus(id, status) {
    try {
      return await apiRequest('PATCH', `${this.baseURL}/${id}/status`, { status });
    } catch (error) {
      console.error('Erro ao atualizar status:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }
}

// Criar instância
const processesService = new ProcessesService();

// Exportar instância como default E como named export
export default processesService;
export { processesService };
EOF

# 3. Corrigir imports nos componentes que usam os services
echo "🔧 Corrigindo imports nos componentes..."

# Função para corrigir imports em um arquivo
fix_imports() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "   Corrigindo $file..."
        # Fazer backup
        cp "$file" "${file}.bak.206b"
        
        # Corrigir imports
        sed -i 's/import { processesService }/import processesService/g' "$file"
        sed -i 's/import { clientsService }/import clientsService/g' "$file"
        sed -i 's/import.*{ processesService }.*from/import processesService from/g' "$file"
        sed -i 's/import.*{ clientsService }.*from/import clientsService from/g' "$file"
    fi
}

# Corrigir todos os arquivos que importam os services
fix_imports "src/components/processes/EditProcess.js"
fix_imports "src/components/processes/NewProcess.js"
fix_imports "src/components/processes/ProcessDetails.js"
fix_imports "src/pages/admin/Processes.js"

# 4. Corrigir imports nos componentes de clientes também
fix_imports "src/components/clients/EditClient.js"
fix_imports "src/components/clients/NewClient.js"
fix_imports "src/pages/admin/Clients.js"

# 5. Atualizar .env do frontend para porta correta
echo "🔧 Corrigindo porta no .env..."
if [ -f ".env" ]; then
    sed -i 's/3008/3008/g' .env
    # Garantir que a porta está correta
    if ! grep -q "REACT_APP_API_URL.*3008" .env; then
        sed -i 's/REACT_APP_API_URL=.*/REACT_APP_API_URL=http:\/\/localhost:3008\/api/' .env
    fi
else
    cat > .env << 'EOF'
REACT_APP_API_URL=http://localhost:3008/api
REACT_APP_ENV=development
REACT_APP_DEBUG=true
REACT_APP_NAME=Sistema Erlene Advogados
REACT_APP_VERSION=1.0.0
EOF
fi

echo "✅ Imports do frontend corrigidos!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • clientsService.js: Export default e named"
echo "   • processesService.js: Export default e named"
echo "   • Imports corrigidos nos componentes"
echo "   • Porta API corrigida para 3008"
echo ""
echo "🧪 TESTE:"
echo "   npm start"
echo ""
echo "📋 Próximo: Execute o script 207 para finalizar login!"