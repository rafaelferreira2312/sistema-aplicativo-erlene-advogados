#!/bin/bash

# Script 55 - Correção da página de Login
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/55-corrigir-login-page.sh

echo "🔐 Corrigindo página de Login..."

# Sobrescrever o componente Login com versão mais simples e funcional
cat > frontend/src/pages/auth/Login/index.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { EyeIcon, EyeSlashIcon } from '@heroicons/react/24/outline';

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
    // Limpar erro quando usuário começar a digitar
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      // Simulação de login - substituir pela API real
      if (formData.email === 'admin@erlene.com' && formData.password === '123456') {
        // Login admin bem-sucedido
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'admin');
        navigate('/admin');
      } else if (formData.email === 'cliente@teste.com' && formData.password === '123456') {
        // Login cliente bem-sucedido
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'cliente');
        navigate('/portal');
      } else {
        setError('Credenciais inválidas. Tente admin@erlene.com ou cliente@teste.com com senha 123456');
      }
    } catch (err) {
      setError('Erro ao fazer login. Tente novamente.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header */}
        <div className="text-center">
          <div className="mx-auto h-16 w-16 bg-gradient-to-r from-red-600 to-red-700 rounded-lg flex items-center justify-center mb-6">
            <span className="text-white font-bold text-2xl">E</span>
          </div>
          <h2 className="text-3xl font-bold text-gray-900 mb-2">
            Sistema Erlene Advogados
          </h2>
          <p className="text-gray-600">
            Entre com suas credenciais para acessar o sistema
          </p>
        </div>

        {/* Form */}
        <div className="bg-white py-8 px-6 shadow-lg rounded-lg border border-gray-200">
          <form className="space-y-6" onSubmit={handleSubmit}>
            {/* Email */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                E-mail
              </label>
              <input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                required
                value={formData.email}
                onChange={handleInputChange}
                className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500"
                placeholder="seu@email.com"
              />
            </div>

            {/* Password */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Senha
              </label>
              <div className="relative">
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  required
                  value={formData.password}
                  onChange={handleInputChange}
                  className="block w-full px-3 py-2 pr-10 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  placeholder="Sua senha"
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeSlashIcon className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                  ) : (
                    <EyeIcon className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                  )}
                </button>
              </div>
            </div>

            {/* Error Message */}
            {error && (
              <div className="bg-red-50 border border-red-200 rounded-md p-3">
                <p className="text-sm text-red-600">{error}</p>
              </div>
            )}

            {/* Submit Button */}
            <div>
              <button
                type="submit"
                disabled={isLoading}
                className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200"
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
          </form>

          {/* Links */}
          <div className="mt-6 text-center space-y-2">
            <Link 
              to="/forgot-password" 
              className="text-sm text-red-600 hover:text-red-500 transition-colors"
            >
              Esqueceu sua senha?
            </Link>
            <div className="text-sm text-gray-500">
              Ou acesse o{' '}
              <Link 
                to="/portal" 
                className="text-red-600 hover:text-red-500 font-medium transition-colors"
              >
                Portal do Cliente
              </Link>
            </div>
          </div>
        </div>

        {/* Demo Credentials */}
        <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
          <h3 className="text-sm font-medium text-blue-900 mb-2">Credenciais de Teste:</h3>
          <div className="text-xs text-blue-700 space-y-1">
            <div><strong>Admin:</strong> admin@erlene.com / 123456</div>
            <div><strong>Cliente:</strong> cliente@teste.com / 123456</div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center text-sm text-gray-500">
          <p>© 2024 Erlene Advogados. Todos os direitos reservados.</p>
          <p className="mt-1">Desenvolvido por Vancouver Tec</p>
        </div>
      </div>
    </div>
  );
};

export default Login;
EOF

# Corrigir o AuthContext para ser mais simples
cat > frontend/src/context/auth/AuthContext.js << 'EOF'
import { createContext } from 'react';

export const AuthContext = createContext({
  isAuthenticated: false,
  user: null,
  login: () => {},
  logout: () => {},
  isLoading: false
});
EOF

# Corrigir o AuthProvider
cat > frontend/src/context/auth/AuthProvider.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { AuthContext } from './AuthContext';

export const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Verificar se usuário está logado ao carregar a aplicação
    const checkAuth = () => {
      const authStatus = localStorage.getItem('isAuthenticated');
      const userType = localStorage.getItem('userType');
      
      if (authStatus === 'true') {
        setIsAuthenticated(true);
        setUser({
          perfil: userType || 'admin',
          nome: userType === 'cliente' ? 'Cliente Teste' : 'Admin Teste',
          email: userType === 'cliente' ? 'cliente@teste.com' : 'admin@erlene.com'
        });
      }
      setIsLoading(false);
    };

    checkAuth();
  }, []);

  const login = (userData) => {
    setIsAuthenticated(true);
    setUser(userData);
    localStorage.setItem('isAuthenticated', 'true');
    localStorage.setItem('userType', userData.perfil);
  };

  const logout = () => {
    setIsAuthenticated(false);
    setUser(null);
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('userType');
  };

  const hasRole = (roles) => {
    if (!user) return false;
    return roles.includes(user.perfil);
  };

  const value = {
    isAuthenticated,
    user,
    login,
    logout,
    hasRole,
    isLoading
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
EOF

echo "✅ Página de Login corrigida!"
echo ""
echo "🔐 PRINCIPAIS CORREÇÕES:"
echo "   • Componente Login simplificado e funcional"
echo "   • Remoção de objetos cíclicos que causavam erro"
echo "   • AuthContext e AuthProvider corrigidos"
echo "   • Credenciais de teste adicionadas"
echo "   • Layout visual melhorado"
echo ""
echo "🧪 CREDENCIAIS DE TESTE:"
echo "   Admin: admin@erlene.com / 123456"
echo "   Cliente: cliente@teste.com / 123456"
echo ""
echo "⏭️  Execute 'npm start' novamente. Se ainda houver problemas, digite 'continuar'."