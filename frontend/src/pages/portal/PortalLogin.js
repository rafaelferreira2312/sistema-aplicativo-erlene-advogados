import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  EyeIcon, 
  EyeSlashIcon, 
  UserIcon,
  LockClosedIcon 
} from '@heroicons/react/24/outline';
import { authService } from '../../services/auth/authService';
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
