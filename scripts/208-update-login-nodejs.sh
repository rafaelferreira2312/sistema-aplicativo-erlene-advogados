#!/bin/bash

# Script 208 - Atualizar Login Component para Node.js
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔐 Script 208 - Atualizando Login para usar backend Node.js..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# Fazer backup do Login atual
echo "📦 Fazendo backup do Login atual..."
if [ -f "src/pages/auth/Login.js" ]; then
    cp src/pages/auth/Login.js src/pages/auth/Login.js.bak.208
    LOGIN_FILE="src/pages/auth/Login.js"
elif [ -f "src/pages/auth/Login/index.js" ]; then
    cp src/pages/auth/Login/index.js src/pages/auth/Login/index.js.bak.208
    LOGIN_FILE="src/pages/auth/Login/index.js"
else
    echo "📁 Criando estrutura de Login..."
    mkdir -p src/pages/auth
    LOGIN_FILE="src/pages/auth/Login.js"
fi

# Atualizar Login para usar Node.js (MANTENDO LAYOUT ORIGINAL)
echo "🔧 Atualizando Login para Node.js..."
cat > "$LOGIN_FILE" << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { 
  EyeIcon, 
  EyeSlashIcon, 
  UserIcon, 
  LockClosedIcon 
} from '@heroicons/react/24/outline';

import { useAuth } from '../../hooks/auth/useAuth';
import { checkApiHealth } from '../../services/api';

const Login = () => {
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [apiStatus, setApiStatus] = useState(null);
  
  const { login, isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  
  const from = location.state?.from?.pathname || '/admin';

  // Verificar status da API ao carregar
  useEffect(() => {
    const checkAPI = async () => {
      try {
        const status = await checkApiHealth();
        setApiStatus(status);
        if (!status.success) {
          toast.error('Backend Node.js não está respondendo na porta 3008');
        } else {
          toast.success('Backend Node.js conectado!');
        }
      } catch (error) {
        setApiStatus({ success: false });
        toast.error('Erro ao conectar com backend');
      }
    };
    
    checkAPI();
  }, []);

  // Redirecionar se já autenticado
  useEffect(() => {
    if (isAuthenticated) {
      navigate(from, { replace: true });
    }
  }, [isAuthenticated, navigate, from]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.email || !formData.password) {
      toast.error('Por favor, preencha todos os campos');
      return;
    }

    if (!apiStatus?.success) {
      toast.error('Backend Node.js indisponível. Execute: cd backend && npm run dev');
      return;
    }

    setIsLoading(true);

    try {
      console.log('🔐 Tentando login com:', { email: formData.email });
      
      const result = await login(formData);

      if (result.success) {
        toast.success(`Login realizado! Bem-vindo ${result.user.name}`);
        
        // Redirecionar baseado no role
        if (result.user.role === 'client') {
          navigate('/portal', { replace: true });
        } else {
          navigate('/admin', { replace: true });
        }
      } else {
        toast.error(result.error || 'Credenciais inválidas');
        console.error('❌ Login failed:', result.error);
      }
    } catch (error) {
      console.error('❌ Login error:', error);
      toast.error('Erro inesperado. Verifique se o backend Node.js está rodando.');
    } finally {
      setIsLoading(false);
    }
  };

  // Função para preencher credenciais de teste
  const fillTestCredentials = (type) => {
    const credentials = {
      admin: { email: 'admin@erlene.com', password: '123456' },
      lawyer: { email: 'advogado@erlene.com', password: '123456' },
      client: { email: 'cliente@teste.com', password: '123456' }
    };
    
    setFormData(credentials[type]);
    toast.info(`Credenciais de ${type} preenchidas`);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-primary-100 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        {/* Logo */}
        <div className="flex justify-center">
          <div className="bg-primary-600 rounded-full p-4">
            <span className="text-white text-2xl font-bold">E</span>
          </div>
        </div>
        
        {/* Título */}
        <h2 className="mt-6 text-center text-3xl font-bold tracking-tight text-gray-900">
          Sistema Erlene Advogados
        </h2>
        <p className="mt-2 text-center text-lg text-gray-600">
          Gestão Jurídica Inteligente
        </p>
        <p className="mt-1 text-center text-sm text-gray-500">
          Entre com suas credenciais para acessar o sistema
        </p>

        {/* Status da API */}
        <div className="mt-4 text-center">
          {apiStatus?.success ? (
            <div className="inline-flex items-center text-green-600 text-sm">
              <div className="w-2 h-2 bg-green-500 rounded-full mr-2"></div>
              Backend Node.js conectado (porta 3008)
            </div>
          ) : (
            <div className="inline-flex items-center text-red-600 text-sm">
              <div className="w-2 h-2 bg-red-500 rounded-full mr-2"></div>
              Backend indisponível - Execute: cd backend && npm run dev
            </div>
          )}
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow-xl sm:rounded-lg sm:px-10">
          
          {/* Botões de teste */}
          <div className="mb-6 bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <h3 className="text-sm font-medium text-yellow-800 mb-3">🧪 Credenciais de Teste:</h3>
            <div className="grid grid-cols-3 gap-2">
              <button
                type="button"
                onClick={() => fillTestCredentials('admin')}
                className="text-xs bg-blue-100 text-blue-800 px-3 py-2 rounded hover:bg-blue-200 transition-colors"
              >
                Admin
              </button>
              <button
                type="button"
                onClick={() => fillTestCredentials('lawyer')}
                className="text-xs bg-green-100 text-green-800 px-3 py-2 rounded hover:bg-green-200 transition-colors"
              >
                Advogado
              </button>
              <button
                type="button"
                onClick={() => fillTestCredentials('client')}
                className="text-xs bg-purple-100 text-purple-800 px-3 py-2 rounded hover:bg-purple-200 transition-colors"
              >
                Cliente
              </button>
            </div>
          </div>

          {/* Formulário */}
          <form className="space-y-6" onSubmit={handleSubmit}>
            {/* Campo Email */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                E-mail
              </label>
              <div className="mt-1 relative">
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
                  className="appearance-none block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
                  placeholder="seu@email.com"
                />
              </div>
            </div>

            {/* Campo Senha */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                Senha
              </label>
              <div className="mt-1 relative">
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
                  className="appearance-none block w-full pl-10 pr-10 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
                  placeholder="••••••••"
                />
                <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="text-gray-400 hover:text-gray-600 focus:outline-none"
                  >
                    {showPassword ? (
                      <EyeSlashIcon className="h-5 w-5" />
                    ) : (
                      <EyeIcon className="h-5 w-5" />
                    )}
                  </button>
                </div>
              </div>
            </div>

            {/* Botão Submit */}
            <div>
              <button
                type="submit"
                disabled={isLoading || !apiStatus?.success}
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {isLoading ? (
                  <div className="flex items-center">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Entrando...
                  </div>
                ) : (
                  <>
                    <LockClosedIcon className="h-4 w-4 mr-2" />
                    Acessar Sistema
                  </>
                )}
              </button>
            </div>
          </form>

          {/* Links */}
          <div className="mt-6 text-center space-y-2">
            <div>
              <a href="#" className="text-sm text-primary-600 hover:text-primary-500">
                Esqueceu sua senha?
              </a>
            </div>
            <div className="text-sm text-gray-600">
              Portal do cliente? 
              <a href="#" className="text-primary-600 hover:text-primary-500 ml-1">
                Acesse aqui
              </a>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-8 text-center text-xs text-gray-500">
          <p>© 2024 Erlene Chaves Silva - Todos os direitos reservados.</p>
          <p className="mt-1">Desenvolvido por Vancouver Tec | Backend: Node.js</p>
        </div>
      </div>
    </div>
  );
};

export default Login;
EOF

echo "✅ Login atualizado para Node.js!"
echo ""
echo "🔧 ATUALIZAÇÕES APLICADAS:"
echo "   • Removido loginAdmin (era da API Laravel)"
echo "   • Usando useAuth() do novo sistema"
echo "   • Health check do backend Node.js"
echo "   • Layout visual MANTIDO idêntico"
echo "   • Botões de teste com credenciais Node.js"
echo ""
echo "🧪 CREDENCIAIS DE TESTE:"
echo "   Admin: admin@erlene.com / 123456"
echo "   Advogado: advogado@erlene.com / 123456"
echo "   Cliente: cliente@teste.com / 123456"
echo ""
echo "📋 TESTE AGORA:"
echo "   1. Clique nos botões de teste para preencher credenciais"
echo "   2. Clique em 'Acessar Sistema'"
echo "   3. Deve redirecionar para /admin após login"
echo ""
echo "⚠️ CERTIFIQUE-SE QUE:"
echo "   Backend Node.js está rodando: cd backend && npm run dev"