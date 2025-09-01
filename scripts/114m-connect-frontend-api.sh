#!/bin/bash

# Script 114m - Conectar frontend com API real (remover mocks)
# EXECUTE DENTRO DA PASTA: frontend/

echo "Script 114m - Conectando frontend com API real..."

if [ ! -f "package.json" ]; then
    echo "Erro: Execute dentro da pasta frontend/"
    exit 1
fi

echo "1. Verificando se backend está rodando..."

# Testar conexão com backend
if curl -s http://localhost:8000/api/dashboard/stats > /dev/null 2>&1; then
    echo "Backend Laravel está rodando!"
else
    echo "AVISO: Backend não está respondendo em localhost:8000"
    echo "Certifique-se de:"
    echo "1. Executar 'php artisan serve' no backend"
    echo "2. Backend estar em localhost:8000"
    echo ""
    read -p "Pressione Enter para continuar mesmo assim..."
fi

echo "2. Atualizando arquivo API service existente..."

# Atualizar o api.js existente para usar API real
cat > src/services/api.js << 'EOF'
// API Service - Sistema Erlene Advogados
// Serviço para comunicação com o backend Laravel

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

class ApiService {
  constructor() {
    this.baseURL = API_BASE_URL;
    this.token = localStorage.getItem('erlene_token');
  }

  // Headers padrão para requisições
  getHeaders(includeAuth = true) {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    return headers;
  }

  // Método genérico para fazer requisições
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      ...options,
      headers: {
        ...this.getHeaders(options.auth !== false),
        ...(options.headers || {})
      }
    };

    try {
      const response = await fetch(url, config);
      
      // Se resposta não é JSON, retornar texto
      const contentType = response.headers.get('content-type');
      let data;
      
      if (contentType && contentType.includes('application/json')) {
        data = await response.json();
      } else {
        data = { message: await response.text() };
      }

      if (!response.ok) {
        throw new Error(data.message || `HTTP error! status: ${response.status}`);
      }

      return data;
    } catch (error) {
      console.error('API Request Error:', error);
      throw error;
    }
  }

  // Métodos de autenticação
  async loginAdmin(email, password) {
    try {
      const response = await this.request('/auth/login', {
        method: 'POST',
        auth: false,
        body: JSON.stringify({ email, password })
      });

      if (response.success && response.access_token) {
        this.setToken(response.access_token);
        this.setUser(response.user);
        return { success: true, user: response.user };
      }

      return response;
    } catch (error) {
      console.error('Login Admin Error:', error);
      return { 
        success: false, 
        message: error.message || 'Erro ao fazer login. Verifique suas credenciais.' 
      };
    }
  }

  async loginPortal(email, password) {
    try {
      const response = await this.request('/auth/portal/login', {
        method: 'POST',
        auth: false,
        body: JSON.stringify({ 
          email: email,
          password: password 
        })
      });

      if (response.success && response.access_token) {
        this.setToken(response.access_token);
        this.setUser(response.user);
        return { success: true, user: response.user };
      }

      return response;
    } catch (error) {
      console.error('Login Portal Error:', error);
      return { 
        success: false, 
        message: error.message || 'Erro ao fazer login no portal. Verifique suas credenciais.' 
      };
    }
  }

  async logout() {
    try {
      await this.request('/auth/logout', {
        method: 'POST'
      });
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      this.clearAuth();
    }
  }

  async getMe() {
    try {
      const response = await this.request('/auth/me');
      return response;
    } catch (error) {
      console.error('Get Me Error:', error);
      throw error;
    }
  }

  // Métodos de dashboard
  async getDashboardStats() {
    try {
      const response = await this.request('/dashboard/stats');
      return response;
    } catch (error) {
      console.error('Dashboard Stats Error:', error);
      throw error;
    }
  }

  // Métodos de teste
  async testConnection() {
    try {
      const response = await this.request('/dashboard/stats', { auth: false });
      return { success: true, data: response };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Gerenciamento de token e usuário
  setToken(token) {
    this.token = token;
    localStorage.setItem('erlene_token', token);
  }

  setUser(user) {
    localStorage.setItem('erlene_user', JSON.stringify(user));
  }

  getUser() {
    const user = localStorage.getItem('erlene_user');
    return user ? JSON.parse(user) : null;
  }

  getToken() {
    return this.token || localStorage.getItem('erlene_token');
  }

  clearAuth() {
    this.token = null;
    localStorage.removeItem('erlene_token');
    localStorage.removeItem('erlene_user');
    // Manter compatibilidade com sistema antigo
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('portalAuth');
    localStorage.removeItem('userType');
    localStorage.removeItem('user');
  }

  isAuthenticated() {
    return !!this.getToken();
  }
}

// Exportar instância singleton
const apiService = new ApiService();
export default apiService;

// Exportar para uso direto
export { apiService };
EOF

echo "3. Atualizando componente Login para usar API real..."

cat > src/pages/auth/Login/index.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  EyeIcon, 
  EyeSlashIcon, 
  UserIcon,
  LockClosedIcon 
} from '@heroicons/react/24/outline';
import apiService from '../../../services/api';

const Login = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      // Tentar login administrativo primeiro
      const response = await apiService.loginAdmin(formData.email, formData.password);
      
      if (response.success) {
        // Determinar tipo de usuário baseado no perfil
        const user = response.user;
        const perfil = user.perfil || user.profile;
        
        if (perfil === 'consulta') {
          // É um cliente usando o login admin - redirecionar para portal
          localStorage.setItem('portalAuth', 'true');
          localStorage.setItem('userType', 'cliente');
          localStorage.removeItem('isAuthenticated');
          navigate('/portal/dashboard');
        } else {
          // É admin/advogado - redirecionar para admin
          localStorage.setItem('isAuthenticated', 'true');
          localStorage.setItem('userType', 'admin');
          localStorage.removeItem('portalAuth');
          navigate('/admin');
        }
      } else {
        setError(response.message || 'Credenciais inválidas');
      }
    } catch (err) {
      console.error('Login error:', err);
      setError(err.message || 'Erro ao fazer login. Tente novamente.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header com Logo */}
        <div className="text-center">
          <div className="mx-auto h-20 w-20 bg-gradient-to-r from-red-600 to-red-700 rounded-xl flex items-center justify-center mb-8 shadow-lg">
            <span className="text-white font-bold text-3xl">E</span>
          </div>
          <h2 className="text-4xl font-bold text-gray-900 mb-3">
            Sistema Erlene Advogados
          </h2>
          <p className="text-lg text-gray-600 mb-2">
            Gestão Jurídica Inteligente
          </p>
          <p className="text-sm text-gray-500">
            Entre com suas credenciais para acessar o sistema
          </p>
        </div>

        {/* Card do Formulário */}
        <div className="bg-white py-10 px-8 shadow-lg rounded-xl border border-gray-100">
          <form className="space-y-8" onSubmit={handleSubmit}>
            {/* Campo Email */}
            <div>
              <label 
                htmlFor="email" 
                className="block text-sm font-semibold text-gray-700 mb-3"
              >
                E-mail
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <UserIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={formData.email}
                  onChange={handleInputChange}
                  className="block w-full pl-10 pr-3 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm transition-all duration-200"
                  placeholder="seu@email.com"
                />
              </div>
            </div>

            {/* Campo Senha */}
            <div>
              <label 
                htmlFor="password" 
                className="block text-sm font-semibold text-gray-700 mb-3"
              >
                Senha
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <LockClosedIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  required
                  value={formData.password}
                  onChange={handleInputChange}
                  className="block w-full pl-10 pr-12 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm transition-all duration-200"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeSlashIcon className="h-5 w-5 text-gray-400 hover:text-red-600 transition-colors" />
                  ) : (
                    <EyeIcon className="h-5 w-5 text-gray-400 hover:text-red-600 transition-colors" />
                  )}
                </button>
              </div>
            </div>

            {/* Mensagem de Erro */}
            {error && (
              <div className="bg-red-50 border-l-4 border-red-400 p-4 rounded-lg">
                <div className="flex">
                  <div className="ml-3">
                    <p className="text-sm text-red-700 font-medium">{error}</p>
                  </div>
                </div>
              </div>
            )}

            {/* Botão de Login */}
            <div>
              <button
                type="submit"
                disabled={isLoading}
                className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-semibold rounded-lg text-white bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
              >
                {isLoading ? (
                  <div className="flex items-center">
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-3"></div>
                    Autenticando...
                  </div>
                ) : (
                  <span className="flex items-center">
                    <LockClosedIcon className="h-5 w-5 mr-2" />
                    Acessar Sistema
                  </span>
                )}
              </button>
            </div>
          </form>

          {/* Links Auxiliares */}
          <div className="mt-8 text-center space-y-4">
            <a 
              href="#" 
              className="text-sm text-red-600 hover:text-red-700 font-medium transition-colors"
            >
              Esqueceu sua senha?
            </a>
            
            <div className="flex items-center justify-center space-x-2 text-sm text-gray-500">
              <span>Portal do cliente?</span>
              <a 
                href="/portal/login" 
                className="text-red-600 hover:text-red-700 font-medium transition-colors"
              >
                Acesse aqui
              </a>
            </div>
          </div>
        </div>

        {/* Credenciais Demo */}
        <div className="bg-blue-50 border border-blue-200 rounded-xl p-6">
          <h3 className="text-sm font-semibold text-blue-900 mb-4 text-center">
            Credenciais para Demonstração
          </h3>
          <div className="space-y-3 text-sm text-blue-800">
            <div className="bg-white p-3 rounded-lg">
              <div className="font-medium text-blue-900">Admin Geral</div>
              <div className="text-blue-700">admin@erlene.com</div>
              <div className="text-blue-600">Senha: 123456</div>
            </div>
            <div className="bg-white p-3 rounded-lg">
              <div className="font-medium text-blue-900">Cliente Portal</div>
              <div className="text-blue-700">cliente@teste.com</div>
              <div className="text-blue-600">Senha: 123456</div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center text-sm text-gray-500 space-y-2">
          <p>© 2024 Erlene Chaves Silva Advogados Associados</p>
          <div className="flex items-center justify-center space-x-2 text-xs">
            <span>Desenvolvido por</span>
            <a 
              href="#" 
              className="text-red-600 hover:text-red-700 font-medium"
            >
              Vancouver Tec
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
EOF

echo "4. Criando PortalLogin atualizado para API..."

cat > src/pages/portal/PortalLogin.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  EyeIcon, 
  EyeSlashIcon, 
  UserIcon,
  LockClosedIcon 
} from '@heroicons/react/24/outline';
import apiService from '../../services/api';

const PortalLogin = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      // Tentar login no portal
      const response = await apiService.loginPortal(formData.email, formData.password);
      
      if (response.success) {
        localStorage.setItem('portalAuth', 'true');
        localStorage.setItem('userType', 'cliente');
        localStorage.removeItem('isAuthenticated');
        navigate('/portal/dashboard');
      } else {
        setError(response.message || 'Credenciais inválidas');
      }
    } catch (err) {
      console.error('Portal login error:', err);
      setError(err.message || 'Erro ao fazer login. Tente novamente.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-blue-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header */}
        <div className="text-center">
          <div className="mx-auto h-20 w-20 bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl flex items-center justify-center mb-8 shadow-lg">
            <span className="text-white font-bold text-3xl">E</span>
          </div>
          <h2 className="text-4xl font-bold text-gray-900 mb-3">
            Portal do Cliente
          </h2>
          <p className="text-lg text-gray-600 mb-2">
            Erlene Advogados
          </p>
          <p className="text-sm text-gray-500">
            Acesse seus processos e documentos
          </p>
        </div>

        {/* Form */}
        <div className="bg-white py-10 px-8 shadow-lg rounded-xl border border-gray-100">
          <form className="space-y-8" onSubmit={handleSubmit}>
            {/* Email */}
            <div>
              <label htmlFor="email" className="block text-sm font-semibold text-gray-700 mb-3">
                E-mail
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <UserIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="email"
                  name="email"
                  type="email"
                  required
                  value={formData.email}
                  onChange={handleInputChange}
                  className="block w-full pl-10 pr-3 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
                  placeholder="seu@email.com"
                />
              </div>
            </div>

            {/* Senha */}
            <div>
              <label htmlFor="password" className="block text-sm font-semibold text-gray-700 mb-3">
                Senha
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <LockClosedIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  required
                  value={formData.password}
                  onChange={handleInputChange}
                  className="block w-full pl-10 pr-12 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeSlashIcon className="h-5 w-5 text-gray-400 hover:text-blue-600 transition-colors" />
                  ) : (
                    <EyeIcon className="h-5 w-5 text-gray-400 hover:text-blue-600 transition-colors" />
                  )}
                </button>
              </div>
            </div>

            {/* Erro */}
            {error && (
              <div className="bg-red-50 border-l-4 border-red-400 p-4 rounded-lg">
                <p className="text-sm text-red-700 font-medium">{error}</p>
              </div>
            )}

            {/* Submit */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full flex justify-center py-3 px-4 border border-transparent text-sm font-semibold rounded-lg text-white bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
            >
              {isLoading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-3"></div>
                  Entrando...
                </div>
              ) : (
                'Entrar no Portal'
              )}
            </button>
          </form>

          {/* Links */}
          <div className="mt-8 text-center space-y-4">
            <div className="flex items-center justify-center space-x-2 text-sm text-gray-500">
              <span>Não é cliente?</span>
              <a href="/login" className="text-blue-600 hover:text-blue-700 font-medium">
                Acesso administrativo
              </a>
            </div>
          </div>
        </div>

        {/* Credenciais */}
        <div className="bg-green-50 border border-green-200 rounded-xl p-6">
          <h3 className="text-sm font-semibold text-green-900 mb-4 text-center">
            Teste com Cliente Demo
          </h3>
          <div className="bg-white p-3 rounded-lg text-sm text-green-800">
            <div className="font-medium text-green-900">Cliente Teste</div>
            <div className="text-green-700">cliente@teste.com</div>
            <div className="text-green-600">Senha: 123456</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PortalLogin;
EOF

echo "5. Testando conexão com API..."

# Teste básico de conexão
echo "Testando endpoints principais:"
echo ""

# Testar login
echo "Testando login admin:"
curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}' | head -3

echo ""
echo "Testando rota protegida (deve dar erro sem token):"
curl -s http://localhost:8000/api/dashboard/stats | head -2

echo ""
echo "6. Verificando variáveis de ambiente..."

# Verificar .env
if [ ! -f ".env" ]; then
    echo "Criando arquivo .env..."
    cat > .env << 'EOF'
# API Configuration
REACT_APP_API_URL=http://localhost:8000/api
REACT_APP_APP_URL=http://localhost:3000

# App Configuration
REACT_APP_APP_NAME="Sistema Erlene Advogados"
REACT_APP_VERSION="1.0.0"

# Features
REACT_APP_ENABLE_MOCK=false
REACT_APP_ENABLE_DEBUG=true
EOF
    echo ".env criado!"
else
    echo ".env já existe"
fi

echo ""
echo "SCRIPT 114M CONCLUÍDO!"
echo ""
echo "FRONTEND CONECTADO COM API REAL:"
echo "- API Service atualizado para usar backend Laravel"
echo "- Login.js conectado com /api/auth/login"
echo "- PortalLogin.js conectado com /api/auth/portal/login"
echo "- Roteamento automático baseado no perfil do usuário"
echo "- Mocks removidos, usando dados reais"
echo ""
echo "CREDENCIAIS PARA TESTE:"
echo "Admin: admin@erlene.com / 123456 → /admin"
echo "Cliente: cliente@teste.com / 123456 → /portal/dashboard"
echo ""
echo "PRÓXIMO:"
echo "1. Pare o frontend se estiver rodando (Ctrl+C)"
echo "2. Execute: npm start"
echo "3. Certifique-se que backend está em localhost:8000"
echo "4. Teste o login real!"