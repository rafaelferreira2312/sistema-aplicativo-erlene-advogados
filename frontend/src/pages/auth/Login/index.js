import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  EyeIcon, 
  EyeSlashIcon, 
  UserIcon,
  LockClosedIcon 
} from '@heroicons/react/24/outline';
import { authService } from '../../../services/auth/authService';
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
