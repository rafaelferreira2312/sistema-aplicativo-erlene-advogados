#!/bin/bash

# Script 206 - Criar API Service para Node.js
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔗 Script 206 - Criando API Service para Backend Node.js..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# Fazer backup dos arquivos que serão alterados
echo "📦 Criando backup..."
mkdir -p backups/script-206
if [ -f "src/services/api.js" ]; then
    cp src/services/api.js backups/script-206/api.js.bak
fi

echo "✅ Backup criado"

# 1. Criar service de API atualizado para Node.js
echo "🔧 Criando serviço de API para Node.js..."
mkdir -p src/services
cat > src/services/api.js << 'EOF'
import axios from 'axios';

// Configuração base da API
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3008/api';

// Instância do axios configurada
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// Interceptor de request para adicionar token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    console.error('Erro no request:', error);
    return Promise.reject(error);
  }
);

// Interceptor de response para tratar erros
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    console.error('Erro na response:', error);
    
    // Se token expirado, logout automático
    if (error.response?.status === 401) {
      localStorage.removeItem('authToken');
      localStorage.removeItem('userData');
      localStorage.removeItem('isAuthenticated');
      window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);

// Classe de serviços de autenticação
export class AuthService {
  // Login
  static async login(credentials) {
    try {
      const response = await api.post('/auth/login', {
        email: credentials.email,
        password: credentials.password
      });

      if (response.data.success) {
        const { access_token, user } = response.data.data;
        
        // Salvar dados no localStorage
        localStorage.setItem('authToken', access_token);
        localStorage.setItem('userData', JSON.stringify(user));
        localStorage.setItem('isAuthenticated', 'true');
        
        return {
          success: true,
          user: user,
          token: access_token
        };
      } else {
        return {
          success: false,
          error: response.data.message || 'Erro no login'
        };
      }
    } catch (error) {
      console.error('Erro no login:', error);
      
      return {
        success: false,
        error: error.response?.data?.message || 'Erro de conexão com servidor'
      };
    }
  }

  // Logout
  static async logout() {
    try {
      await api.post('/auth/logout');
    } catch (error) {
      console.error('Erro no logout:', error);
    } finally {
      // Limpar dados locais independente do resultado
      localStorage.removeItem('authToken');
      localStorage.removeItem('userData');
      localStorage.removeItem('isAuthenticated');
    }
  }

  // Obter dados do usuário atual
  static async getCurrentUser() {
    try {
      const response = await api.get('/auth/me');
      
      if (response.data.success) {
        return {
          success: true,
          user: response.data.data.user
        };
      } else {
        return {
          success: false,
          error: response.data.message
        };
      }
    } catch (error) {
      console.error('Erro ao buscar usuário:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar dados do usuário'
      };
    }
  }

  // Verificar se token é válido
  static async verifyToken() {
    try {
      const response = await api.get('/auth/me');
      return response.data.success;
    } catch (error) {
      return false;
    }
  }

  // Alterar senha
  static async changePassword(passwords) {
    try {
      const response = await api.post('/auth/change-password', passwords);
      
      return {
        success: response.data.success,
        message: response.data.message
      };
    } catch (error) {
      console.error('Erro ao alterar senha:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao alterar senha'
      };
    }
  }
}

// Health check da API
export const checkApiHealth = async () => {
  try {
    const response = await api.get('/health');
    return response.data;
  } catch (error) {
    console.error('API não está respondendo:', error);
    return { success: false, error: 'API indisponível' };
  }
};

export default api;
EOF

# 2. Criar arquivo de configuração de ambiente
echo "🔧 Criando arquivo .env para frontend..."
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
# API Configuration
REACT_APP_API_URL=http://localhost:3008/api

# Development
REACT_APP_ENV=development
REACT_APP_DEBUG=true

# App Info
REACT_APP_NAME=Sistema Erlene Advogados
REACT_APP_VERSION=1.0.0
EOF
    echo "✅ Arquivo .env criado"
else
    echo "⚠️ Arquivo .env já existe - verificando configurações..."
    
    if ! grep -q "REACT_APP_API_URL" .env; then
        echo "REACT_APP_API_URL=http://localhost:3008/api" >> .env
        echo "✅ REACT_APP_API_URL adicionado ao .env"
    fi
fi

# 3. Testar conexão com API
echo "🧪 Testando conexão com backend..."
cat > test-api-connection.js << 'EOF'
const axios = require('axios');

async function testConnection() {
  try {
    console.log('🔍 Testando conexão com backend Node.js...');
    
    const response = await axios.get('http://localhost:3008/health', {
      timeout: 5000
    });
    
    if (response.data.success) {
      console.log('✅ Backend Node.js está rodando!');
      console.log('📊 Status:', response.data);
    } else {
      console.log('⚠️ Backend respondeu mas com erro');
    }
  } catch (error) {
    console.log('❌ Backend Node.js não está rodando!');
    console.log('💡 Execute: cd ../backend && npm run dev');
    console.log('🔗 URL esperada: http://localhost:3008');
  }
}

testConnection();
EOF

node test-api-connection.js
rm test-api-connection.js

echo "✅ API Service criado com sucesso!"
echo ""
echo "📁 Arquivos criados:"
echo "   - src/services/api.js (serviço de API para Node.js)"
echo "   - .env (configurações de ambiente)"
echo ""
echo "🔧 Configurações:"
echo "   - API URL: http://localhost:3008/api"
echo "   - Timeout: 10 segundos"
echo "   - Headers automáticos com JWT"
echo ""
echo "📋 Próximo script: 207-update-login-component.sh"
echo ""
echo "⚠️ IMPORTANTE: Certifique-se que o backend está rodando antes do próximo script!"