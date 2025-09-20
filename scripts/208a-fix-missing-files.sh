#!/bin/bash

# Script 208a - Corrigir Arquivos Faltando
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 208a - Corrigindo arquivos faltando..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# 1. Criar hook useAuth se não existir
echo "🔧 Criando hook useAuth..."
mkdir -p src/hooks/auth
cat > src/hooks/auth/useAuth.js << 'EOF'
import { useContext } from 'react';
import { AuthContext } from '../../context/auth/AuthContext';

export const useAuth = () => {
  const context = useContext(AuthContext);
  
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  
  return context;
};
EOF

# 2. Verificar se AuthContext existe
echo "🔧 Verificando AuthContext..."
if [ ! -f "src/context/auth/AuthContext.js" ]; then
    echo "📝 Criando AuthContext..."
    mkdir -p src/context/auth
    cat > src/context/auth/AuthContext.js << 'EOF'
import { createContext } from 'react';

export const AuthContext = createContext({
  isAuthenticated: false,
  user: null,
  login: () => {},
  logout: () => {},
  isLoading: false
});
EOF
fi

# 3. Corrigir .env para porta 3008 (mas backend está em 3001)
echo "🔧 Atualizando .env para porta correta..."
cat > .env << 'EOF'
# API Configuration - Backend Node.js na porta 3001
REACT_APP_API_URL=http://localhost:3001/api

# Development
REACT_APP_ENV=development
REACT_APP_DEBUG=true

# App Info
REACT_APP_NAME=Sistema Erlene Advogados
REACT_APP_VERSION=1.0.0
REACT_APP_BACKEND=nodejs
EOF

# 4. Verificar estrutura de Login
echo "🔍 Verificando estrutura de Login..."
if [ -f "src/pages/auth/Login/index.js" ]; then
    echo "📁 Login está em src/pages/auth/Login/index.js"
    # Corrigir imports para caminho correto
    sed -i 's|../../hooks/auth/useAuth|../../../hooks/auth/useAuth|g' src/pages/auth/Login/index.js
    sed -i 's|../../services/api|../../../services/api|g' src/pages/auth/Login/index.js
    echo "✅ Imports corrigidos no Login/index.js"
elif [ -f "src/pages/auth/Login.js" ]; then
    echo "📁 Login está em src/pages/auth/Login.js"
    echo "✅ Imports já estão corretos"
else
    echo "❌ Arquivo Login não encontrado!"
fi

# 5. Testar se arquivos existem agora
echo "🧪 Verificando arquivos criados..."

if [ -f "src/hooks/auth/useAuth.js" ]; then
    echo "✅ useAuth.js criado"
else
    echo "❌ useAuth.js não foi criado"
fi

if [ -f "src/services/api.js" ]; then
    echo "✅ api.js existe"
else
    echo "❌ api.js não existe"
fi

if [ -f "src/context/auth/AuthContext.js" ]; then
    echo "✅ AuthContext.js existe"
else
    echo "❌ AuthContext.js não existe"
fi

echo ""
echo "✅ Arquivos faltando corrigidos!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • Hook useAuth criado"
echo "   • AuthContext verificado"
echo "   • .env atualizado para porta 3001"
echo "   • Imports do Login corrigidos"
echo ""
echo "⚠️ NOTA IMPORTANTE:"
echo "   Backend está rodando na porta 3001 (não 3008)"
echo "   .env foi ajustado para: http://localhost:3001/api"
echo ""
echo "📋 TESTE AGORA:"
echo "   npm start (deve compilar sem erros)"