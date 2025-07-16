#!/bin/bash

# Script 61 - Login no Padrão Erlene (Cores e Design System)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/61-implementar-login-padrao-erlene.sh

echo "🎨 Implementando Login no padrão Erlene..."

# 1. Recriar Login seguindo design system Erlene
cat > frontend/src/pages/auth/Login/index.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  EyeIcon, 
  EyeSlashIcon, 
  UserIcon,
  LockClosedIcon 
} from '@heroicons/react/24/outline';

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
      // Simulação de login
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      if (formData.email === 'admin@erlene.com' && formData.password === '123456') {
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'admin');
        navigate('/admin');
      } else if (formData.email === 'cliente@teste.com' && formData.password === '123456') {
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'cliente');
        navigate('/portal');
      } else {
        setError('Credenciais inválidas. Verifique email e senha.');
      }
    } catch (err) {
      setError('Erro ao fazer login. Tente novamente.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header com Logo */}
        <div className="text-center">
          <div className="mx-auto h-20 w-20 bg-gradient-erlene rounded-xl flex items-center justify-center mb-8 shadow-erlene">
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
        <div className="bg-white py-10 px-8 shadow-erlene-lg rounded-xl border border-gray-100">
          <form className="space-y-8" onSubmit={handleSubmit}>
            {/* Campo Email */}
            <div>
              <label 
                htmlFor="email" 
                className="block text-sm font-semibold text-gray-700 mb-3"
              >
                E-mail Corporativo
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
                  className="block w-full pl-10 pr-3 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 text-sm transition-all duration-200"
                  placeholder="seu.email@erlene.com"
                />
              </div>
            </div>

            {/* Campo Senha */}
            <div>
              <label 
                htmlFor="password" 
                className="block text-sm font-semibold text-gray-700 mb-3"
              >
                Senha de Acesso
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
                  className="block w-full pl-10 pr-12 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 text-sm transition-all duration-200"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeSlashIcon className="h-5 w-5 text-gray-400 hover:text-primary-600 transition-colors" />
                  ) : (
                    <EyeIcon className="h-5 w-5 text-gray-400 hover:text-primary-600 transition-colors" />
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
                className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-semibold rounded-lg text-white bg-gradient-erlene hover:shadow-erlene-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
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
              className="text-sm text-primary-600 hover:text-primary-700 font-medium transition-colors"
            >
              Esqueceu sua senha?
            </a>
            
            <div className="flex items-center justify-center space-x-2 text-sm text-gray-500">
              <span>Ainda não tem acesso?</span>
              <a 
                href="#" 
                className="text-primary-600 hover:text-primary-700 font-medium transition-colors"
              >
                Solicitar cadastro
              </a>
            </div>
          </div>
        </div>

        {/* Credenciais Demo */}
        <div className="bg-blue-50 border border-blue-200 rounded-xl p-6">
          <h3 className="text-sm font-semibold text-blue-900 mb-4 text-center">
            🧪 Credenciais para Demonstração
          </h3>
          <div className="space-y-3 text-sm text-blue-800">
            <div className="bg-white p-3 rounded-lg">
              <div className="font-medium text-blue-900">👨‍💼 Administrador</div>
              <div className="text-blue-700">admin@erlene.com</div>
              <div className="text-blue-600">Senha: 123456</div>
            </div>
            <div className="bg-white p-3 rounded-lg">
              <div className="font-medium text-blue-900">👤 Cliente</div>
              <div className="text-blue-700">cliente@teste.com</div>
              <div className="text-blue-600">Senha: 123456</div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center text-sm text-gray-500 space-y-2">
          <p>© 2024 Erlene Chaves Silva Advogados Associados</p>
          <p>Todos os direitos reservados</p>
          <div className="flex items-center justify-center space-x-2 text-xs">
            <span>Desenvolvido por</span>
            <a 
              href="#" 
              className="text-primary-600 hover:text-primary-700 font-medium"
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

# 2. Atualizar App.js para usar o componente Login correto
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import Login from './pages/auth/Login';

// Dashboard Admin (temporário - será substituído)
const AdminDashboard = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('userType');
    navigate('/login');
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="bg-gradient-erlene text-white p-4">
        <div className="flex justify-between items-center max-w-7xl mx-auto">
          <h1 className="text-xl font-bold">Sistema Erlene Advogados - Administrativo</h1>
          <button
            onClick={handleLogout}
            className="bg-red-700 hover:bg-red-800 px-4 py-2 rounded text-sm"
          >
            Sair
          </button>
        </div>
      </div>

      <div className="max-w-7xl mx-auto p-6">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900">Dashboard Administrativo</h2>
          <p className="text-gray-600">Bem-vindo ao sistema de gestão jurídica</p>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4 mb-8">
          <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 bg-blue-600 rounded-full flex items-center justify-center">
                    <span className="text-white text-sm">👥</span>
                  </div>
                </div>
                <div className="ml-5">
                  <p className="text-sm font-medium text-gray-500">Total de Clientes</p>
                  <p className="text-2xl font-semibold text-gray-900">1,247</p>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 bg-green-600 rounded-full flex items-center justify-center">
                    <span className="text-white text-sm">⚖️</span>
                  </div>
                </div>
                <div className="ml-5">
                  <p className="text-sm font-medium text-gray-500">Processos Ativos</p>
                  <p className="text-2xl font-semibold text-gray-900">891</p>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 bg-yellow-600 rounded-full flex items-center justify-center">
                    <span className="text-white text-sm">💰</span>
                  </div>
                </div>
                <div className="ml-5">
                  <p className="text-sm font-medium text-gray-500">Receita Mensal</p>
                  <p className="text-2xl font-semibold text-gray-900">R$ 125.847</p>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow-erlene rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 bg-purple-600 rounded-full flex items-center justify-center">
                    <span className="text-white text-sm">📅</span>
                  </div>
                </div>
                <div className="ml-5">
                  <p className="text-sm font-medium text-gray-500">Atendimentos Hoje</p>
                  <p className="text-2xl font-semibold text-gray-900">14</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white shadow-erlene rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Ações Rápidas</h3>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {[
              { title: 'Novo Cliente', icon: '👤' },
              { title: 'Novo Processo', icon: '⚖️' },
              { title: 'Agendar Atendimento', icon: '📅' },
              { title: 'Ver Relatórios', icon: '📊' }
            ].map((action) => (
              <button
                key={action.title}
                className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors"
              >
                <span className="text-2xl mb-2">{action.icon}</span>
                <span className="text-sm font-medium text-gray-900">{action.title}</span>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

// Portal Cliente (temporário - será substituído)
const ClientPortal = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('userType');
    navigate('/login');
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="bg-gradient-erlene text-white p-4">
        <div className="flex justify-between items-center max-w-7xl mx-auto">
          <h1 className="text-xl font-bold">Portal do Cliente - Erlene Advogados</h1>
          <button
            onClick={handleLogout}
            className="bg-red-700 hover:bg-red-800 px-4 py-2 rounded text-sm"
          >
            Sair
          </button>
        </div>
      </div>

      <div className="max-w-7xl mx-auto p-6">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900">Portal do Cliente</h2>
          <p className="text-gray-600">Acompanhe seus processos e documentos</p>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {[
            { title: 'Meus Processos', subtitle: '3 processos ativos', color: 'red', icon: '⚖️' },
            { title: 'Documentos', subtitle: '12 documentos disponíveis', color: 'blue', icon: '📄' },
            { title: 'Pagamentos', subtitle: '2 pagamentos pendentes', color: 'green', icon: '💳' }
          ].map((item) => (
            <div key={item.title} className="bg-white overflow-hidden shadow-erlene rounded-lg">
              <div className="p-6">
                <div className="flex items-center mb-4">
                  <span className="text-2xl mr-3">{item.icon}</span>
                  <h3 className="text-lg font-medium text-gray-900">{item.title}</h3>
                </div>
                <p className="text-gray-600 mb-4">{item.subtitle}</p>
                <button className={`bg-${item.color}-600 text-white px-4 py-2 rounded hover:bg-${item.color}-700`}>
                  Ver {item.title}
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

// Componente de proteção de rota
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';
  const userType = localStorage.getItem('userType');

  if (requiredAuth && !isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (!requiredAuth && isAuthenticated) {
    return <Navigate to={userType === 'cliente' ? '/portal' : '/admin'} replace />;
  }

  if (allowedTypes.length > 0 && !allowedTypes.includes(userType)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return children;
};

// Página 404
const NotFoundPage = () => (
  <div className="min-h-screen flex items-center justify-center bg-gray-50">
    <div className="text-center">
      <h1 className="text-6xl font-bold text-gray-400 mb-4">404</h1>
      <p className="text-gray-600 mb-4">Página não encontrada</p>
      <a href="/login" className="bg-gradient-erlene text-white px-4 py-2 rounded hover:shadow-erlene">
        Voltar ao Login
      </a>
    </div>
  </div>
);

// App principal
function App() {
  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/" element={<Navigate to="/login" replace />} />
          
          <Route
            path="/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <Login />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/admin"
            element={
              <ProtectedRoute allowedTypes={['admin']}>
                <AdminDashboard />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <ClientPortal />
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

echo "✅ Login implementado no padrão Erlene!"
echo ""
echo "🎨 DESIGN SYSTEM APLICADO:"
echo "   • Cores Erlene: #8B1538 (vermelho) e #F5B041 (dourado)"
echo "   • Gradiente bg-gradient-erlene"
echo "   • Sombras shadow-erlene e shadow-erlene-lg"
echo "   • Ícones Heroicons com tamanhos corretos"
echo "   • Tipografia consistente"
echo "   • Animações e transitions suaves"
echo ""
echo "✨ MELHORIAS VISUAIS:"
echo "   • Logo com gradiente Erlene"
echo "   • Campos com ícones e validação visual"
echo "   • Botão com loading state"
echo "   • Cards de credenciais demo"
echo "   • Footer institucional"
echo ""
echo "⏭️  Execute 'npm start' e teste o novo Login!"
echo "⏭️  Digite 'continuar' para próxima tela: Dashboard Admin!"