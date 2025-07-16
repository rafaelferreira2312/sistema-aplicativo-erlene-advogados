#!/bin/bash

echo "🔧 Criando hook useAuth que está faltando..."

# Criar diretório
mkdir -p frontend/src/hooks/auth

# Criar useAuth.js
cat > frontend/src/hooks/auth/useAuth.js << 'EOF'
import { useContext } from 'react';
import { AuthContext } from '../../context/auth/AuthContext';

export const useAuth = () => {
  const context = useContext(AuthContext);
  
  if (!context) {
    throw new Error('useAuth deve ser usado dentro de um AuthProvider');
  }
  
  return context;
};
EOF

echo "✅ useAuth hook criado!"