#!/bin/bash

# Script 207 - Corrigir Fluxo de Autenticação
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔐 Script 207 - Corrigindo fluxo de autenticação..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# 1. Limpar localStorage para forçar logout
echo "🧹 Limpando dados de autenticação antigos..."
cat > clear-auth.js << 'EOF'
// Script para limpar dados de autenticação
if (typeof localStorage !== 'undefined') {
  localStorage.removeItem('isAuthenticated');
  localStorage.removeItem('userType');
  localStorage.removeItem('authToken');
  localStorage.removeItem('userData');
  console.log('✅ Dados de autenticação removidos');
}
EOF

# 2. Corrigir App.js para redirecionar para login
echo "🔧 Corrigindo App.js para forçar login..."
cat > src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider } from './context/auth/AuthProvider';

// Componentes de autenticação
import Login from './pages/auth/Login';

// Componentes do portal cliente
import PortalLogin from './pages/portal/PortalLogin';
import PortalDashboard from './pages/portal/PortalDashboard';
import PortalProcessos from './pages/portal/PortalProcessos';
import PortalDocumentos from './pages/portal/PortalDocumentos';
import PortalPagamentos from './pages/portal/PortalPagamentos';
import PortalMensagens from './pages/portal/PortalMensagens';
import PortalPerfil from './pages/portal/PortalPerfil';

// Layout admin e componentes
import AdminLayout from './components/layout/AdminLayout';
import Dashboard from './pages/admin/Dashboard';
import Clients from './pages/admin/Clients';
import NewClient from './components/clients/NewClient';
import EditClient from './components/clients/EditClient';
import Processes from './pages/admin/Processes';
import NewProcess from './components/processes/NewProcess';
import EditProcess from './components/processes/EditProcess';
import Audiencias from './pages/admin/Audiencias';
import NewAudiencia from './components/audiencias/NewAudiencia';
import EditAudiencia from './components/audiencias/EditAudiencia';
import Prazos from './pages/admin/Prazos';
import NewPrazo from './components/prazos/NewPrazo';
import EditPrazo from './components/prazos/EditPrazo';
import Atendimentos from './pages/admin/Atendimentos';
import NewAtendimento from './components/atendimentos/NewAtendimento';
import Financeiro from './pages/admin/Financeiro';
import Documentos from './pages/admin/Documentos';
import Kanban from './pages/admin/Kanban';
import Relatorios from './pages/admin/Relatorios';
import Usuarios from './pages/admin/Usuarios';
import Configuracoes from './pages/admin/Configuracoes';

// Route Guard
import PrivateRoute from './components/auth/PrivateRoute';
import PublicRoute from './components/auth/PublicRoute';

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="App">
          <Toaster
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#363636',
                color: '#fff',
              },
              success: {
                duration: 3000,
                theme: {
                  primary: '#4aed88',
                },
              },
            }}
          />
          
          <Routes>
            {/* Rota raiz - redireciona para login */}
            <Route path="/" element={<Navigate to="/login" replace />} />
            
            {/* Rotas públicas */}
            <Route 
              path="/login" 
              element={
                <PublicRoute>
                  <Login />
                </PublicRoute>
              } 
            />
            <Route 
              path="/portal/login" 
              element={
                <PublicRoute>
                  <PortalLogin />
                </PublicRoute>
              } 
            />

            {/* Portal do Cliente */}
            <Route path="/portal" element={<PrivateRoute roles={['client']}><PortalDashboard /></PrivateRoute>} />
            <Route path="/portal/dashboard" element={<PrivateRoute roles={['client']}><PortalDashboard /></PrivateRoute>} />
            <Route path="/portal/processos" element={<PrivateRoute roles={['client']}><PortalProcessos /></PrivateRoute>} />
            <Route path="/portal/documentos" element={<PrivateRoute roles={['client']}><PortalDocumentos /></PrivateRoute>} />
            <Route path="/portal/pagamentos" element={<PrivateRoute roles={['client']}><PortalPagamentos /></PrivateRoute>} />
            <Route path="/portal/mensagens" element={<PrivateRoute roles={['client']}><PortalMensagens /></PrivateRoute>} />
            <Route path="/portal/perfil" element={<PrivateRoute roles={['client']}><PortalPerfil /></PrivateRoute>} />

            {/* Área Administrativa */}
            <Route 
              path="/admin/*" 
              element={
                <PrivateRoute roles={['admin', 'lawyer']}>
                  <AdminLayout>
                    <Routes>
                      <Route path="/" element={<Dashboard />} />
                      <Route path="/dashboard" element={<Dashboard />} />
                      <Route path="/clients" element={<Clients />} />
                      <Route path="/clients/new" element={<NewClient />} />
                      <Route path="/clients/:id/edit" element={<EditClient />} />
                      <Route path="/processes" element={<Processes />} />
                      <Route path="/processes/new" element={<NewProcess />} />
                      <Route path="/processes/:id/edit" element={<EditProcess />} />
                      <Route path="/audiencias" element={<Audiencias />} />
                      <Route path="/audiencias/new" element={<NewAudiencia />} />
                      <Route path="/audiencias/:id/edit" element={<EditAudiencia />} />
                      <Route path="/prazos" element={<Prazos />} />
                      <Route path="/prazos/new" element={<NewPrazo />} />
                      <Route path="/prazos/:id/edit" element={<EditPrazo />} />
                      <Route path="/atendimentos" element={<Atendimentos />} />
                      <Route path="/atendimentos/new" element={<NewAtendimento />} />
                      <Route path="/financeiro" element={<Financeiro />} />
                      <Route path="/documentos" element={<Documentos />} />
                      <Route path="/kanban" element={<Kanban />} />
                      <Route path="/relatorios" element={<Relatorios />} />
                      <Route path="/usuarios" element={<Usuarios />} />
                      <Route path="/configuracoes" element={<Configuracoes />} />
                    </Routes>
                  </AdminLayout>
                </PrivateRoute>
              } 
            />

            {/* Catch-all: redireciona para login */}
            <Route path="*" element={<Navigate to="/login" replace />} />
          </Routes>
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
EOF

# 3. Corrigir PrivateRoute para verificar autenticação real
echo "🔒 Corrigindo PrivateRoute..."
mkdir -p src/components/auth
cat > src/components/auth/PrivateRoute.js << 'EOF'
import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/auth/useAuth';

const PrivateRoute = ({ children, roles = [] }) => {
  const { isAuthenticated, user, isLoading } = useAuth();
  const location = useLocation();

  // Mostrar loading enquanto verifica autenticação
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  // Se não autenticado, redirecionar para login
  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Se tem roles específicas, verificar se usuário tem permissão
  if (roles.length > 0 && user) {
    const hasPermission = roles.includes(user.role);
    if (!hasPermission) {
      // Redirecionar baseado no role do usuário
      if (user.role === 'client') {
        return <Navigate to="/portal" replace />;
      } else {
        return <Navigate to="/admin" replace />;
      }
    }
  }

  return children;
};

export default PrivateRoute;
EOF

# 4. Corrigir PublicRoute para redirecionar se já autenticado
echo "🔓 Corrigindo PublicRoute..."
cat > src/components/auth/PublicRoute.js << 'EOF'
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../hooks/auth/useAuth';

const PublicRoute = ({ children }) => {
  const { isAuthenticated, user, isLoading } = useAuth();

  // Mostrar loading enquanto verifica autenticação
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  // Se autenticado, redirecionar para área apropriada
  if (isAuthenticated && user) {
    if (user.role === 'client') {
      return <Navigate to="/portal" replace />;
    } else {
      return <Navigate to="/admin" replace />;
    }
  }

  // Se não autenticado, mostrar página pública
  return children;
};

export default PublicRoute;
EOF

# 5. Corrigir .env para usar porta 3008
echo "🔧 Corrigindo configuração da API..."
cat > .env << 'EOF'
# API Configuration - Backend Node.js
REACT_APP_API_URL=http://localhost:3008/api

# Development
REACT_APP_ENV=development
REACT_APP_DEBUG=true

# App Info
REACT_APP_NAME=Sistema Erlene Advogados
REACT_APP_VERSION=1.0.0
REACT_APP_BACKEND=nodejs
EOF

# 6. Corrigir AuthProvider para limpar estado inicial
echo "🔄 Corrigindo AuthProvider..."
cat > src/context/auth/AuthProvider.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { AuthContext } from './AuthContext';
import { AuthService } from '../../services/api';

export const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  // Verificar autenticação ao carregar app
  useEffect(() => {
    const checkAuth = async () => {
      try {
        console.log('🔍 Verificando autenticação...');
        
        const authStatus = localStorage.getItem('isAuthenticated');
        const userData = localStorage.getItem('userData');
        const token = localStorage.getItem('authToken');

        // Se não tem dados locais, não está autenticado
        if (authStatus !== 'true' || !userData || !token) {
          console.log('❌ Não há dados de autenticação locais');
          setIsAuthenticated(false);
          setUser(null);
          setIsLoading(false);
          return;
        }

        // Verificar se token ainda é válido no backend Node.js
        console.log('🔐 Verificando token no backend...');
        const isValid = await AuthService.verifyToken();
        
        if (isValid) {
          console.log('✅ Token válido');
          setIsAuthenticated(true);
          setUser(JSON.parse(userData));
        } else {
          console.log('❌ Token inválido - fazendo logout');
          // Token inválido, limpar dados
          localStorage.removeItem('isAuthenticated');
          localStorage.removeItem('userData');
          localStorage.removeItem('authToken');
          setIsAuthenticated(false);
          setUser(null);
        }
      } catch (error) {
        console.error('❌ Erro ao verificar autenticação:', error);
        // Em caso de erro, limpar dados
        localStorage.removeItem('isAuthenticated');
        localStorage.removeItem('userData');
        localStorage.removeItem('authToken');
        setIsAuthenticated(false);
        setUser(null);
      } finally {
        setIsLoading(false);
      }
    };

    checkAuth();
  }, []);

  // Função de login
  const login = async (credentials) => {
    setIsLoading(true);
    
    try {
      console.log('🔐 Tentando fazer login...');
      const result = await AuthService.login(credentials);
      
      if (result.success) {
        console.log('✅ Login successful');
        setIsAuthenticated(true);
        setUser(result.user);
        
        return {
          success: true,
          user: result.user
        };
      } else {
        console.log('❌ Login failed:', result.error);
        return {
          success: false,
          error: result.error
        };
      }
    } catch (error) {
      console.error('❌ Login error:', error);
      return {
        success: false,
        error: 'Erro inesperado'
      };
    } finally {
      setIsLoading(false);
    }
  };

  // Função de logout
  const logout = async () => {
    setIsLoading(true);
    
    try {
      console.log('🚪 Fazendo logout...');
      await AuthService.logout();
    } catch (error) {
      console.error('Erro no logout:', error);
    } finally {
      setIsAuthenticated(false);
      setUser(null);
      setIsLoading(false);
      console.log('✅ Logout concluído');
    }
  };

  // Verificar se usuário tem determinada role
  const hasRole = (roles) => {
    if (!user) return false;
    if (typeof roles === 'string') roles = [roles];
    return roles.includes(user.role);
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

# 7. Adicionar script para limpar localStorage
echo "📜 Criando script para limpar dados antigos..."
cat > public/clear-auth.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Limpar Autenticação</title>
</head>
<body>
    <h1>Limpando dados de autenticação...</h1>
    <script>
        localStorage.removeItem('isAuthenticated');
        localStorage.removeItem('userType');
        localStorage.removeItem('authToken');
        localStorage.removeItem('userData');
        alert('Dados limpos! Volte para /login');
        window.location.href = '/login';
    </script>
</body>
</html>
EOF

rm clear-auth.js

echo "✅ Fluxo de autenticação corrigido!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • App.js: Rota raiz redireciona para /login"
echo "   • PrivateRoute: Verifica autenticação real"
echo "   • PublicRoute: Redireciona se já autenticado"
echo "   • .env: API apontando para porta 3008"
echo "   • AuthProvider: Estado limpo inicial"
echo ""
echo "🧹 PARA LIMPAR DADOS ANTIGOS:"
echo "   Acesse: http://localhost:3000/clear-auth.html"
echo ""
echo "📋 TESTE:"
echo "   1. Acesse http://localhost:3000 (deve ir para /login)"
echo "   2. Use credenciais: admin@erlene.com / 123456"
echo "   3. Deve ir para /admin após login"