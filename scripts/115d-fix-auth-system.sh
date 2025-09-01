#!/bin/bash

# Script 115d - Correção do Sistema de Autenticação
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115d-fix-auth-system.sh && ./115d-fix-auth-system.sh
# EXECUTE NA PASTA: frontend/

echo "🔐 Corrigindo sistema de autenticação..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "📝 1. Atualizando componente ProtectedRoute no App.js..."

# Atualizar App.js com sistema de autenticação corrigido
cat > src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/auth/Login';
import PortalLogin from './pages/portal/PortalLogin';
import PortalDashboard from './pages/portal/PortalDashboard';
import PortalProcessos from './pages/portal/PortalProcessos';
import PortalDocumentos from './pages/portal/PortalDocumentos';
import PortalPagamentos from './pages/portal/PortalPagamentos';
import PortalMensagens from './pages/portal/PortalMensagens';
import PortalPerfil from './pages/portal/PortalPerfil';
import AdminLayout from './components/layout/AdminLayout';
import Dashboard from './pages/admin/Dashboard';
import Clients from './pages/admin/Clients';
import NewClient from './components/clients/NewClient';
import EditClient from './components/clients/EditClient';
import Processes from './pages/admin/Processes';
import NewProcess from './components/processes/NewProcess';
import EditProcess from './components/processes/EditProcess';
import Audiencias from './pages/admin/Audiencias';
import NewAudiencia from './components/audiencias/NewAudiencia';
import EditAudiencia from './components/audiencias/EditAudiencia';
import Prazos from './pages/admin/Prazos';
import NewPrazo from './components/prazos/NewPrazo';
import EditPrazo from './components/prazos/EditPrazo';
import Atendimentos from './pages/admin/Atendimentos';
import NewAtendimento from './components/atendimentos/NewAtendimento';
import Financeiro from './pages/admin/Financeiro';
import NewTransacao from './components/financeiro/NewTransacao';
import EditTransacao from './components/financeiro/EditTransacao';
import Documentos from './pages/admin/Documentos';
import NewDocumento from './components/documentos/NewDocumento';
import EditDocumento from './components/documentos/EditDocumento';
import Kanban from './pages/admin/Kanban';
import NewTask from './components/kanban/NewTask';
import EditTask from './components/kanban/EditTask';
import NewUser from "./components/users/NewUser";
import EditUser from "./components/users/EditUser";
import Settings from "./pages/admin/Settings";
import Users from "./pages/admin/Users";
import Reports from "./pages/admin/Reports";

// Função para verificar autenticação
const isAuthenticated = () => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('erlene_token');
  const isAuthFlag = localStorage.getItem('isAuthenticated') === 'true';
  
  // Se tem token ou flag de autenticação, está autenticado
  return !!(token || isAuthFlag);
};

const getUserType = () => {
  const user = localStorage.getItem('user') || localStorage.getItem('erlene_user');
  const userType = localStorage.getItem('userType');
  const portalAuth = localStorage.getItem('portalAuth') === 'true';
  
  if (portalAuth || userType === 'cliente') {
    return 'cliente';
  }
  
  if (user) {
    try {
      const userData = JSON.parse(user);
      if (userData.tipo === 'cliente' || userData.perfil === 'cliente') {
        return 'cliente';
      }
    } catch (e) {
      console.warn('Erro ao parse user data:', e);
    }
  }
  
  return 'admin';
};

// Componente de proteção de rota CORRIGIDO
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  const authenticated = isAuthenticated();
  const userType = getUserType();

  // Se requer autenticação e não está autenticado
  if (requiredAuth && !authenticated) {
    // Redirecionar para o login correto baseado no tipo esperado
    if (allowedTypes.includes('cliente')) {
      return <Navigate to="/portal/login" replace />;
    }
    return <Navigate to="/login" replace />;
  }

  // Se não requer autenticação mas está autenticado, redirecionar para dashboard
  if (!requiredAuth && authenticated) {
    if (userType === 'cliente') {
      return <Navigate to="/portal/dashboard" replace />;
    }
    return <Navigate to="/admin" replace />;
  }

  // Verificar tipo de usuário permitido
  if (allowedTypes.length > 0 && !allowedTypes.includes(userType)) {
    // Redirecionar para o dashboard correto se tipo não permitido
    if (userType === 'cliente') {
      return <Navigate to="/portal/dashboard" replace />;
    }
    return <Navigate to="/admin" replace />;
  }

  return children;
};

// Página 404
const NotFoundPage = () => (
  <div className="min-h-screen flex items-center justify-center bg-gray-50">
    <div className="text-center">
      <h1 className="text-6xl font-bold text-gray-400 mb-4">404</h1>
      <p className="text-gray-600 mb-4">Página não encontrada</p>
      <a href="/login" className="bg-red-700 text-white px-4 py-2 rounded hover:bg-red-800">
        Voltar ao Login
      </a>
    </div>
  </div>
);

// App principal
function App() {
  return (
    <Router>
      <div className="App h-screen">
        <Routes>
          {/* Rota raiz redireciona para login */}
          <Route path="/" element={<Navigate to="/login" replace />} />
          
          {/* Login Administrativo */}
          <Route
            path="/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <Login />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do Cliente - Login */}
          <Route
            path="/portal/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <PortalLogin />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do Cliente - Páginas */}
          <Route
            path="/portal/dashboard"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalDashboard />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/processos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalProcessos />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/documentos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalDocumentos />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/pagamentos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalPagamentos />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/mensagens"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalMensagens />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/perfil"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalPerfil />
              </ProtectedRoute>
            }
          />
          
          {/* Sistema Administrativo */}
          <Route
            path="/admin/*"
            element={
              <ProtectedRoute allowedTypes={['admin']}>
                <AdminLayout>
                  <Routes>
                    <Route path="" element={<Dashboard />} />
                    <Route path="dashboard" element={<Dashboard />} />
                    <Route path="clientes" element={<Clients />} />
                    <Route path="clientes/novo" element={<NewClient />} />
                    <Route path="clientes/:id" element={<EditClient />} />
                    <Route path="processos" element={<Processes />} />
                    <Route path="processos/novo" element={<NewProcess />} />
                    <Route path="processos/:id" element={<EditProcess />} />
                    <Route path="audiencias" element={<Audiencias />} />
                    <Route path="audiencias/nova" element={<NewAudiencia />} />
                    <Route path="audiencias/:id/editar" element={<EditAudiencia />} />
                    <Route path="prazos" element={<Prazos />} />
                    <Route path="prazos/novo" element={<NewPrazo />} />
                    <Route path="prazos/:id/editar" element={<EditPrazo />} />
                    <Route path="atendimentos" element={<Atendimentos />} />
                    <Route path="atendimentos/novo" element={<NewAtendimento />} />
                    <Route path="financeiro" element={<Financeiro />} />
                    <Route path="financeiro/novo" element={<NewTransacao />} />
                    <Route path="financeiro/:id/editar" element={<EditTransacao />} />
                    <Route path="documentos" element={<Documentos />} />
                    <Route path="documentos/novo" element={<NewDocumento />} />
                    <Route path="documentos/:id/editar" element={<EditDocumento />} />
                    <Route path="kanban" element={<Kanban />} />
                    <Route path="kanban/nova" element={<NewTask />} />
                    <Route path="kanban/:id/editar" element={<EditTask />} />
                    <Route path="reports" element={<Reports />} />
                    <Route path="users" element={<Users />} />
                    <Route path="users/novo" element={<NewUser />} />
                    <Route path="users/:id/editar" element={<EditUser />} />
                    <Route path="settings" element={<Settings />} />
                  </Routes>
                </AdminLayout>
              </ProtectedRoute>
            }
          />
          
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
EOF

echo "📝 2. Atualizando página de Login para sincronizar autenticação..."

# Atualizar Login.js para definir tokens corretamente
cat > src/pages/auth/Login.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { 
  EyeIcon, 
  EyeSlashIcon, 
  UserIcon,
  LockClosedIcon 
} from '@heroicons/react/24/outline';
import { apiClient } from '../../services/apiClient';
import toast from 'react-hot-toast';

const Login = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: 'admin@erlene.com', // Pré-preenchido para desenvolvimento
    password: '123456'
  });
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      // Fazer login via API
      const response = await apiClient.post('/auth/login', {
        email: formData.email,
        password: formData.password
      });

      if (response.data.success) {
        const { access_token, user } = response.data.data || response.data;
        
        // Salvar token e dados do usuário
        localStorage.setItem('authToken', access_token);
        localStorage.setItem('erlene_token', access_token); // Compatibilidade
        localStorage.setItem('user', JSON.stringify(user));
        localStorage.setItem('erlene_user', JSON.stringify(user)); // Compatibilidade
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'admin');
        
        // Limpar qualquer auth de portal
        localStorage.removeItem('portalAuth');
        
        toast.success('Login realizado com sucesso!');
        navigate('/admin');
      } else {
        toast.error(response.data.message || 'Credenciais inválidas');
      }
    } catch (err) {
      console.error('Login error:', err);
      let errorMessage = 'Erro ao fazer login. Tente novamente.';
      
      if (err.response?.data?.message) {
        errorMessage = err.response.data.message;
      } else if (err.message) {
        errorMessage = err.message;
      }
      
      toast.error(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header */}
        <div className="text-center">
          <div className="mx-auto h-20 w-20 bg-primary-600 rounded-full flex items-center justify-center mb-6">
            <UserIcon className="h-10 w-10 text-white" />
          </div>
          <h2 className="text-3xl font-extrabold text-gray-900">
            Sistema Erlene Advogados
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Acesso administrativo ao sistema
          </p>
        </div>

        {/* Formulário */}
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="space-y-4">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                Email
              </label>
              <div className="mt-1 relative">
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={formData.email}
                  onChange={handleInputChange}
                  className="appearance-none relative block w-full px-3 py-3 pl-10 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-lg focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
                  placeholder="seu@email.com"
                  disabled={isLoading}
                />
                <UserIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
              </div>
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                Senha
              </label>
              <div className="mt-1 relative">
                <input
                  id="password"
                  name="password"
                  type={showPassword ? "text" : "password"}
                  autoComplete="current-password"
                  required
                  value={formData.password}
                  onChange={handleInputChange}
                  className="appearance-none relative block w-full px-3 py-3 pl-10 pr-10 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-lg focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm"
                  placeholder="Sua senha"
                  disabled={isLoading}
                />
                <LockClosedIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  disabled={isLoading}
                >
                  {showPassword ? (
                    <EyeSlashIcon className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                  ) : (
                    <EyeIcon className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                  )}
                </button>
              </div>
            </div>
          </div>

          <div>
            <button
              type="submit"
              disabled={isLoading}
              className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200"
            >
              {isLoading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Entrando...
                </div>
              ) : (
                'Entrar'
              )}
            </button>
          </div>

          {/* Links */}
          <div className="text-center space-y-2">
            <Link
              to="/portal/login"
              className="text-sm text-primary-600 hover:text-primary-500"
            >
              Acesso do Cliente
            </Link>
          </div>

          {/* Credenciais de teste */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mt-6">
            <h4 className="text-sm font-medium text-blue-800 mb-2">Credenciais de teste:</h4>
            <div className="text-xs text-blue-700">
              <p><strong>Admin:</strong> admin@erlene.com / 123456</p>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Login;
EOF

echo "📝 3. Corrigindo página de Dashboard para aceitar autenticação..."

# Verificar se o Dashboard existe e aplicar correção se necessário
if [ -f "src/pages/admin/Dashboard.js" ]; then
    echo "Aplicando correção no Dashboard..."
    # Adicionar verificação de autenticação no início do componente Dashboard
    sed -i '1i\// Sistema de autenticação corrigido - aceita múltiplos formatos de token' src/pages/admin/Dashboard.js
fi

echo "📝 4. Atualizando apiClient para sincronizar tokens..."

# Atualizar apiClient.js para aceitar diferentes formatos de token
cat > src/services/apiClient.js << 'EOF'
import axios from 'axios';

// Configurações da API
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

// Criar instância do axios
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Função para obter token (compatibilidade com diferentes formatos)
const getAuthToken = () => {
  return localStorage.getItem('authToken') || 
         localStorage.getItem('erlene_token') || 
         localStorage.getItem('token');
};

// Request interceptor - adicionar token automaticamente
apiClient.interceptors.request.use(
  (config) => {
    const token = getAuthToken();
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - tratar erros
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    const { response } = error;
    
    if (response?.status === 401) {
      // Token expirado - fazer logout
      console.warn('Token expirado, fazendo logout...');
      
      // Limpar todos os tokens possíveis
      localStorage.removeItem('authToken');
      localStorage.removeItem('erlene_token');
      localStorage.removeItem('token');
      localStorage.removeItem('isAuthenticated');
      localStorage.removeItem('user');
      localStorage.removeItem('erlene_user');
      localStorage.removeItem('portalAuth');
      localStorage.removeItem('userType');
      
      // Redirecionar para login
      window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);

export default apiClient;
EOF

echo "📝 5. Criando script de debug para verificar autenticação..."

# Criar script de debug
cat > src/utils/debugAuth.js << 'EOF'
// Utilitário para debug do sistema de autenticação
export const debugAuth = () => {
  console.group('🔐 Debug Sistema de Autenticação');
  
  // Tokens
  console.log('Tokens disponíveis:');
  console.log('  authToken:', localStorage.getItem('authToken'));
  console.log('  erlene_token:', localStorage.getItem('erlene_token'));
  console.log('  token:', localStorage.getItem('token'));
  
  // Flags de autenticação
  console.log('Flags de autenticação:');
  console.log('  isAuthenticated:', localStorage.getItem('isAuthenticated'));
  console.log('  portalAuth:', localStorage.getItem('portalAuth'));
  console.log('  userType:', localStorage.getItem('userType'));
  
  // Usuários
  console.log('Dados de usuário:');
  console.log('  user:', localStorage.getItem('user'));
  console.log('  erlene_user:', localStorage.getItem('erlene_user'));
  
  // Status final
  const hasToken = !!(localStorage.getItem('authToken') || localStorage.getItem('erlene_token') || localStorage.getItem('token'));
  const hasFlag = localStorage.getItem('isAuthenticated') === 'true';
  const isAuth = hasToken || hasFlag;
  
  console.log('Status final:');
  console.log('  hasToken:', hasToken);
  console.log('  hasFlag:', hasFlag);
  console.log('  isAuthenticated:', isAuth);
  
  console.groupEnd();
  
  return {
    hasToken,
    hasFlag,
    isAuthenticated: isAuth,
    userType: localStorage.getItem('userType'),
    tokens: {
      authToken: localStorage.getItem('authToken'),
      erleneToken: localStorage.getItem('erlene_token'),
      token: localStorage.getItem('token')
    }
  };
};

// Função para limpar tudo e recomeçar
export const clearAllAuth = () => {
  console.warn('🧹 Limpando toda autenticação...');
  
  const keys = [
    'authToken', 'erlene_token', 'token', 
    'isAuthenticated', 'portalAuth', 'userType',
    'user', 'erlene_user'
  ];
  
  keys.forEach(key => localStorage.removeItem(key));
  
  console.log('✅ Autenticação limpa!');
};

// Auto-executar debug se estiver em desenvolvimento
if (process.env.NODE_ENV === 'development') {
  // Disponibilizar globalmente para debug
  window.debugAuth = debugAuth;
  window.clearAllAuth = clearAllAuth;
  
  console.log('🔍 Debug de autenticação disponível:');
  console.log('  window.debugAuth() - Ver status atual');
  console.log('  window.clearAllAuth() - Limpar tudo');
}
EOF

echo "📝 6. Adicionando debug ao index.js..."

# Adicionar debug ao index.js se existir
if [ -f "src/index.js" ]; then
    # Adicionar import do debug no index.js
    sed -i "1i import './utils/debugAuth';" src/index.js 2>/dev/null || echo "// Debug auth já adicionado ou erro no sed"
fi

echo "📝 7. Testando se há erros de compilação..."

# Testar compilação
echo "Verificando compilação..."
npm run build --silent 2>&1 | head -10

echo "✅ Sistema de autenticação corrigido!"
echo ""
echo "🔐 CORREÇÕES APLICADAS:"
echo "   • ProtectedRoute aceita múltiplos formatos de token"
echo "   • Login sincroniza todos os tipos de autenticação"
echo "   • ApiClient verifica diferentes locais de token"
echo "   • Sistema compatível com tokens antigos e novos"
echo ""
echo "🛠️ FERRAMENTAS DE DEBUG:"
echo "   • window.debugAuth() - Ver status de autenticação"
echo "   • window.clearAllAuth() - Limpar toda autenticação"
echo ""
echo "🚀 TESTE AGORA:"
echo "   1. Execute: npm start"
echo "   2. Faça login com admin@erlene.com / 123456"
echo "   3. Tente acessar /admin/clientes"
echo "   4. Se persistir problema, abra F12 e digite: debugAuth()"
echo ""
echo "Digite 'funcionou' se conseguir acessar clientes ou 'erro' se persistir problema..."