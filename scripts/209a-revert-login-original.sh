#!/bin/bash

# Script 209a - Reverter Login ao Layout Original
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 209a - Revertendo Login ao layout original..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# Encontrar arquivo de Login
if [ -f "src/pages/auth/Login/index.js" ]; then
    LOGIN_FILE="src/pages/auth/Login/index.js"
elif [ -f "src/pages/auth/Login.js" ]; then
    LOGIN_FILE="src/pages/auth/Login.js"
else
    echo "❌ Arquivo Login não encontrado!"
    exit 1
fi

# Fazer backup do Login atual
cp "$LOGIN_FILE" "${LOGIN_FILE}.bak.209a"

# Reverter ao Login original SEM alterações visuais, apenas lógica Node.js
echo "🔧 Revertendo ao layout original com lógica Node.js..."
cat > "$LOGIN_FILE" << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../../../hooks/auth/useAuth';

const Login = () => {
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  
  const { login, isAuthenticated } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (isAuthenticated) {
      navigate('/admin');
    }
  }, [isAuthenticated, navigate]);

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
      alert('Por favor, preencha todos os campos');
      return;
    }

    setIsLoading(true);

    try {
      const result = await login(formData);

      if (result.success) {
        navigate('/admin');
      } else {
        alert(result.error || 'Credenciais inválidas');
      }
    } catch (error) {
      console.error('Erro no login:', error);
      alert('Erro ao fazer login');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-primary-100 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="flex justify-center">
          <div className="bg-primary-600 rounded-full p-4">
            <span className="text-white text-2xl font-bold">E</span>
          </div>
        </div>
        
        <h2 className="mt-6 text-center text-3xl font-bold tracking-tight text-gray-900">
          Sistema Erlene Advogados
        </h2>
        <p className="mt-2 text-center text-lg text-gray-600">
          Gestão Jurídica Inteligente
        </p>
        <p className="mt-1 text-center text-sm text-gray-500">
          Entre com suas credenciais para acessar o sistema
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow-xl sm:rounded-lg sm:px-10">
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                E-mail
              </label>
              <div className="mt-1">
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={formData.email}
                  onChange={handleInputChange}
                  className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
                  placeholder="seu@email.com"
                />
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
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  required
                  value={formData.password}
                  onChange={handleInputChange}
                  className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
                  placeholder="••••••••"
                />
                <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    {showPassword ? '🙈' : '👁️'}
                  </button>
                </div>
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={isLoading}
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50"
              >
                {isLoading ? 'Entrando...' : 'Acessar Sistema'}
              </button>
            </div>
          </form>

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

        <div className="mt-8 text-center text-xs text-gray-500">
          <p>© 2024 Erlene Chaves Silva - Todos os direitos reservados.</p>
          <p className="mt-1">Desenvolvido por Vancouver Tec</p>
        </div>
      </div>
    </div>
  );
};

export default Login;
EOF

echo "✅ Login revertido ao layout original!"
echo ""
echo "🔧 CORREÇÃO APLICADA:"
echo "   • Layout visual mantido 100% original"
echo "   • Apenas lógica interna alterada para Node.js"
echo "   • Removidos botões de teste que alteravam o design"
echo ""
echo "📋 TESTE:"
echo "   Credenciais: admin@erlene.com / 123456"