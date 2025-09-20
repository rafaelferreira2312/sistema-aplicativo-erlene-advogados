#!/bin/bash

# Script 209 - Corrigir Login Definitivamente 
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔐 Script 209 - Corrigindo Login definitivamente..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# 1. Limpar dados antigos do localStorage
echo "🧹 Criando script para limpar localStorage..."
cat > public/clear-storage.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Clear Storage</title></head>
<body>
<h2>Limpando dados antigos...</h2>
<script>
localStorage.clear();
sessionStorage.clear();
console.log('Storage limpo');
alert('Dados antigos removidos! Clique OK para ir ao login.');
window.location.href = '/login';
</script>
</body>
</html>
EOF

# 2. Verificar qual arquivo de Login existe e está sendo usado
echo "🔍 Verificando estrutura de Login..."
if [ -f "src/pages/auth/Login/index.js" ]; then
    LOGIN_FILE="src/pages/auth/Login/index.js"
    echo "📁 Login encontrado em: $LOGIN_FILE"
elif [ -f "src/pages/auth/Login.js" ]; then
    LOGIN_FILE="src/pages/auth/Login.js"
    echo "📁 Login encontrado em: $LOGIN_FILE"
else
    echo "❌ Arquivo Login não encontrado!"
    exit 1
fi

# 3. Fazer backup do Login atual
cp "$LOGIN_FILE" "${LOGIN_FILE}.bak.209"

# 4. Verificar se o arquivo ainda tem referências ao Laravel
echo "🔍 Verificando referências antigas no Login..."
if grep -q "loginAdmin" "$LOGIN_FILE"; then
    echo "⚠️ Encontrada referência 'loginAdmin' - precisa corrigir"
else
    echo "✅ Não há referências 'loginAdmin'"
fi

# 5. Recriar Login usando exatamente o layout original mas com Node.js
echo "🔧 Recriando Login com integração Node.js..."
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

  // Redirecionar se já autenticado
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
        alert('Login realizado com sucesso!');
        navigate('/admin');
      } else {
        alert(result.error || 'Credenciais inválidas');
      }
    } catch (error) {
      console.error('Erro no login:', error);
      alert('Erro ao fazer login. Verifique se o backend está rodando.');
    } finally {
      setIsLoading(false);
    }
  };

  // Botões de teste para preencher credenciais
  const fillTestCredentials = (type) => {
    const credentials = {
      admin: { email: 'admin@erlene.com', password: '123456' },
      lawyer: { email: 'advogado@erlene.com', password: '123456' },
      client: { email: 'cliente@teste.com', password: '123456' }
    };
    
    setFormData(credentials[type]);
    alert(`Credenciais de ${type} preenchidas`);
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
          
          {/* Botões de teste */}
          <div className="mb-6 bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <h3 className="text-sm font-medium text-yellow-800 mb-3">🧪 Credenciais de Teste:</h3>
            <div className="grid grid-cols-3 gap-2">
              <button
                type="button"
                onClick={() => fillTestCredentials('admin')}
                className="text-xs bg-blue-100 text-blue-800 px-3 py-2 rounded hover:bg-blue-200"
              >
                Admin
              </button>
              <button
                type="button"
                onClick={() => fillTestCredentials('lawyer')}
                className="text-xs bg-green-100 text-green-800 px-3 py-2 rounded hover:bg-green-200"
              >
                Advogado
              </button>
              <button
                type="button"
                onClick={() => fillTestCredentials('client')}
                className="text-xs bg-purple-100 text-purple-800 px-3 py-2 rounded hover:bg-purple-200"
              >
                Cliente
              </button>
            </div>
          </div>

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
          <p className="mt-1">Desenvolvido por Vancouver Tec | Backend: Node.js</p>
        </div>
      </div>
    </div>
  );
};

export default Login;
EOF

# 6. Atualizar .env do frontend para porta 3008
echo "🔧 Atualizando .env para porta 3008..."
cat > .env << 'EOF'
REACT_APP_API_URL=http://localhost:3008/api
REACT_APP_ENV=development
REACT_APP_DEBUG=true
REACT_APP_NAME=Sistema Erlene Advogados
REACT_APP_VERSION=1.0.0
EOF

echo "✅ Login corrigido definitivamente!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • Login recreado sem referências ao Laravel"
echo "   • Usando useAuth() do sistema Node.js"
echo "   • .env configurado para porta 3008"
echo "   • Script para limpar localStorage criado"
echo ""
echo "🧹 PRIMEIRO PASSO - LIMPAR DADOS ANTIGOS:"
echo "   Acesse: http://localhost:3000/clear-storage.html"
echo ""
echo "🧪 CREDENCIAIS DE TESTE:"
echo "   Admin: admin@erlene.com / 123456"
echo "   Advogado: advogado@erlene.com / 123456"
echo "   Cliente: cliente@teste.com / 123456"
echo ""
echo "📋 TESTE FINAL:"
echo "   1. Limpe storage primeiro"
echo "   2. Acesse /login"
echo "   3. Use botões de teste"
echo "   4. Faça login"