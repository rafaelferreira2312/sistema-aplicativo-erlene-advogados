#!/bin/bash

# Script 207b - Corrigir Loop Infinito Router
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 207b - Corrigindo loop infinito do Router..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# 1. Primeiro, limpar localStorage via script simples
echo "🧹 Limpando localStorage..."
cat > public/reset.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Reset</title></head>
<body>
<script>
localStorage.clear();
sessionStorage.clear();
alert('Dados limpos!');
window.location.href = '/';
</script>
</body>
</html>
EOF

# 2. Corrigir PublicRoute - versão simplificada
echo "🔓 Corrigindo PublicRoute..."
cat > src/components/auth/PublicRoute.js << 'EOF'
import React from 'react';
import { useAuth } from '../../hooks/auth/useAuth';

const PublicRoute = ({ children }) => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  // Não redirecionar automaticamente - deixar o usuário decidir
  return children;
};

export default PublicRoute;
EOF

# 3. Corrigir PrivateRoute - versão simplificada  
echo "🔒 Corrigindo PrivateRoute..."
cat > src/components/auth/PrivateRoute.js << 'EOF'
import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/auth/useAuth';

const PrivateRoute = ({ children, roles = [] }) => {
  const { isAuthenticated, user, isLoading } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return children;
};

export default PrivateRoute;
EOF

# 4. Simplificar AuthProvider para evitar loops
echo "🔄 Simplificando AuthProvider..."
cat > src/context/auth/AuthProvider.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { AuthContext } from './AuthContext';
import { AuthService } from '../../services/api';

export const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const checkAuth = () => {
      try {
        const authStatus = localStorage.getItem('isAuthenticated');
        const userData = localStorage.getItem('userData');
        const token = localStorage.getItem('authToken');

        if (authStatus === 'true' && userData && token) {
          setIsAuthenticated(true);
          setUser(JSON.parse(userData));
        } else {
          setIsAuthenticated(false);
          setUser(null);
        }
      } catch (error) {
        console.error('Erro auth:', error);
        setIsAuthenticated(false);
        setUser(null);
      } finally {
        setIsLoading(false);
      }
    };

    checkAuth();
  }, []);

  const login = async (credentials) => {
    setIsLoading(true);
    
    try {
      const result = await AuthService.login(credentials);
      
      if (result.success) {
        setIsAuthenticated(true);
        setUser(result.user);
        return { success: true, user: result.user };
      } else {
        return { success: false, error: result.error };
      }
    } catch (error) {
      return { success: false, error: 'Erro inesperado' };
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    try {
      await AuthService.logout();
    } catch (error) {
      console.error('Erro no logout:', error);
    } finally {
      setIsAuthenticated(false);
      setUser(null);
    }
  };

  const value = {
    isAuthenticated,
    user,
    login,
    logout,
    isLoading
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
EOF

# 5. Simplificar App.js para evitar conflitos
echo "🔧 Simplificando App.js..."
cat > src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider } from './context/auth/AuthProvider';

// Componentes básicos
import Login from './pages/auth/Login';
import AdminLayout from './components/layout/AdminLayout';
import Dashboard from './pages/admin/Dashboard';
import Clients from './pages/admin/Clients';
import Processes from './pages/admin/Processes';

// Route Guards
import PrivateRoute from './components/auth/PrivateRoute';
import PublicRoute from './components/auth/PublicRoute';

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="App">
          <Toaster position="top-right" />
          
          <Routes>
            {/* Rotas públicas */}
            <Route 
              path="/login" 
              element={
                <PublicRoute>
                  <Login />
                </PublicRoute>
              } 
            />

            {/* Área Administrativa */}
            <Route 
              path="/admin/*" 
              element={
                <PrivateRoute>
                  <AdminLayout>
                    <Routes>
                      <Route path="/" element={<Dashboard />} />
                      <Route path="/dashboard" element={<Dashboard />} />
                      <Route path="/clients" element={<Clients />} />
                      <Route path="/processes" element={<Processes />} />
                    </Routes>
                  </AdminLayout>
                </PrivateRoute>
              } 
            />

            {/* Redirecionar raiz para login */}
            <Route path="/" element={<Navigate to="/login" replace />} />
            
            {/* Catch-all */}
            <Route path="*" element={<Navigate to="/login" replace />} />
          </Routes>
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
EOF

# 6. Verificar se hook useAuth existe
echo "🔍 Verificando hook useAuth..."
if [ ! -f "src/hooks/auth/useAuth.js" ]; then
    echo "📝 Criando hook useAuth..."
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
fi

echo "✅ Loop infinito corrigido!"
echo ""
echo "🧹 PRIMEIRO: Limpe os dados antigos"
echo "   Acesse: http://localhost:3000/reset.html"
echo ""
echo "🎯 DEPOIS: Teste o fluxo"
echo "   1. http://localhost:3000 → deve ir para /login"
echo "   2. Login com: admin@erlene.com / 123456"
echo "   3. Deve ir para /admin após login"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • PublicRoute sem redirecionamento automático"
echo "   • PrivateRoute simplificado"
echo "   • AuthProvider sem verificação de token no backend"
echo "   • App.js com rotas básicas apenas"