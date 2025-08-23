#!/bin/bash

# Script 111b - Correção Emergencial Loop Infinito
# Autor: Sistema Erlene Advogados  
# Data: $(date +%Y-%m-%d)

echo "🚨 Script 111b - Corrigindo loop infinito EMERGENCIAL..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Fazendo backup e restaurando App.js funcional..."

# Fazer backup do atual
cp frontend/src/App.js frontend/src/App.js.loop.bak

echo "🔧 Criando App.js SIMPLES sem loops..."

# Criar App.js sem loops - VERSÃO EMERGENCIAL SIMPLES
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/auth/Login';
import PortalLogin from './pages/portal/PortalLogin';
import PortalDashboard from './pages/portal/PortalDashboard';
import PortalProcessos from './pages/portal/PortalProcessos';
import PortalDocumentos from './pages/portal/PortalDocumentos';
import PortalPagamentos from './pages/portal/PortalPagamentos';
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
import NewTransacao from './components/financeiro/NewTransacao';
import EditTransacao from './components/financeiro/EditTransacao';
import Documentos from './pages/admin/Documentos';
import NewDocumento from './components/documentos/NewDocumento';
import EditDocumento from './components/documentos/EditDocumento';
import Kanban from './pages/admin/Kanban';
import NewTask from './components/kanban/NewTask';
import EditTask from './components/kanban/EditTask';
import NewUser from "./components/users/NewUser";
import EditUser from "./components/users/EditUser";
import Settings from "./pages/admin/Settings";
import Users from "./pages/admin/Users";
import Reports from "./pages/admin/Reports";

// Componente de proteção simples SEM LOOPS
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';
  const portalAuth = localStorage.getItem('portalAuth') === 'true';
  const userType = localStorage.getItem('userType');

  // Para sistema administrativo
  if (allowedTypes.includes('admin') && !isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  // Para portal do cliente
  if (allowedTypes.includes('cliente') && !portalAuth) {
    return <Navigate to="/portal/login" replace />;
  }

  // Se não requer auth e está logado, redirecionar
  if (!requiredAuth && (isAuthenticated || portalAuth)) {
    if (userType === 'cliente') {
      return <Navigate to="/portal/dashboard" replace />;
    } else {
      return <Navigate to="/admin" replace />;
    }
  }

  // Verificar tipo permitido
  if (allowedTypes.length > 0 && !allowedTypes.includes(userType)) {
    return <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-2xl font-bold text-red-600 mb-4">Acesso Negado</h1>
        <p className="text-gray-600 mb-4">Você não tem permissão para acessar esta página.</p>
        <a href="/login" className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">
          Fazer Login
        </a>
      </div>
    </div>;
  }

  return children;
};

// Página 404
const NotFoundPage = () => (
  <div className="min-h-screen flex items-center justify-center bg-gray-50">
    <div className="text-center">
      <h1 className="text-6xl font-bold text-gray-400 mb-4">404</h1>
      <p className="text-gray-600 mb-4">Página não encontrada</p>
      <a href="/login" className="bg-red-700 text-white px-4 py-2 rounded hover:bg-red-800">
        Voltar ao Login
      </a>
    </div>
  </div>
);

// App principal SEM LOOPS
function App() {
  return (
    <Router>
      <div className="App h-screen">
        <Routes>
          {/* Página inicial simples */}
          <Route path="/" element={<Navigate to="/login" replace />} />
          
          {/* Login administrativo */}
          <Route
            path="/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <Login />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do cliente - Login */}
          <Route
            path="/portal/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <PortalLogin />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do cliente - Dashboard */}
          <Route
            path="/portal/dashboard"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalDashboard />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do cliente - Processos */}
          <Route
            path="/portal/processos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalProcessos />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do cliente - Documentos */}
          <Route
            path="/portal/documentos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalDocumentos />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do cliente - Pagamentos */}
          <Route
            path="/portal/pagamentos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalPagamentos />
              </ProtectedRoute>
            }
          />
          
          {/* Sistema administrativo */}
          <Route
            path="/admin/*"
            element={
              <ProtectedRoute allowedTypes={['admin']}>
                <AdminLayout>
                  <Routes>
                    <Route path="" element={<Dashboard />} />
                    <Route path="dashboard" element={<Dashboard />} />
                    <Route path="clientes" element={<Clients />} />
                    <Route path="clientes/novo" element={<NewClient />} />
                    <Route path="clientes/:id" element={<EditClient />} />
                    <Route path="processos" element={<Processes />} />
                    <Route path="processos/novo" element={<NewProcess />} />
                    <Route path="processos/:id" element={<EditProcess />} />
                    <Route path="audiencias" element={<Audiencias />} />
                    <Route path="audiencias/nova" element={<NewAudiencia />} />
                    <Route path="audiencias/:id/editar" element={<EditAudiencia />} />
                    <Route path="prazos" element={<Prazos />} />
                    <Route path="prazos/novo" element={<NewPrazo />} />
                    <Route path="prazos/:id/editar" element={<EditPrazo />} />
                    <Route path="atendimentos" element={<Atendimentos />} />
                    <Route path="atendimentos/novo" element={<NewAtendimento />} />
                    <Route path="financeiro" element={<Financeiro />} />
                    <Route path="financeiro/novo" element={<NewTransacao />} />
                    <Route path="financeiro/:id/editar" element={<EditTransacao />} />
                    <Route path="documentos" element={<Documentos />} />
                    <Route path="documentos/novo" element={<NewDocumento />} />
                    <Route path="documentos/:id/editar" element={<EditDocumento />} />
                    <Route path="kanban" element={<Kanban />} />
                    <Route path="kanban/nova" element={<NewTask />} />
                    <Route path="kanban/:id/editar" element={<EditTask />} />
                    <Route path="reports" element={<Reports />} />
                    <Route path="users" element={<Users />} />
                    <Route path="users/novo" element={<NewUser />} />
                    <Route path="users/:id/editar" element={<EditUser />} />
                    <Route path="settings" element={<Settings />} />
                  </Routes>
                </AdminLayout>
              </ProtectedRoute>
            }
          />
          
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
EOF

echo "✅ App.js restaurado sem loops!"

echo "🔧 Corrigindo useAuth hook..."

# Criar useAuth sem loops também
cat > frontend/src/hooks/auth/useAuth.js << 'EOF'
import { useState, useEffect } from 'react';

export const useAuth = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Carregar dados do usuário APENAS UMA VEZ
    const userData = localStorage.getItem('user');
    if (userData) {
      try {
        setUser(JSON.parse(userData));
      } catch (error) {
        console.error('Erro ao carregar dados do usuário:', error);
        localStorage.removeItem('user');
      }
    }
    setLoading(false);
  }, []); // Array vazio - executa APENAS uma vez

  const logout = async () => {
    // Limpar tudo
    localStorage.removeItem('portalAuth');
    localStorage.removeItem('userType');
    localStorage.removeItem('user');
    localStorage.removeItem('isAuthenticated');
    setUser(null);
    
    // Redirecionar APENAS se não estiver já na página de login
    if (!window.location.pathname.includes('/login')) {
      window.location.href = '/login';
    }
  };

  return {
    user,
    loading,
    logout,
    isAuthenticated: !!user
  };
};
EOF

echo "✅ useAuth corrigido!"

echo "🔧 Verificando PortalLayout..."

# Verificar se PortalLayout existe e corrigir
if [ -f "frontend/src/components/portal/layout/index.js" ]; then
    echo "📝 PortalLayout encontrado - corrigindo..."
    
    # Corrigir PortalLayout para usar as rotas corretas
    sed -i "s|href='/portal'|href='/portal/dashboard'|g" frontend/src/components/portal/layout/index.js
    
    echo "✅ PortalLayout corrigido!"
else
    echo "⚠️ PortalLayout não encontrado - ok"
fi

echo "🧹 Limpando cache do React..."

# Tentar parar qualquer processo npm/yarn
pkill -f "react-scripts" 2>/dev/null || true
pkill -f "npm start" 2>/dev/null || true

# Remover cache
rm -rf frontend/node_modules/.cache 2>/dev/null || true
rm -rf frontend/.eslintcache 2>/dev/null || true

echo ""
echo "🎉 CORREÇÃO EMERGENCIAL APLICADA!"
echo ""
echo "🔧 PROBLEMAS CORRIGIDOS:"
echo "   • Removidos loops infinitos de useEffect"
echo "   • Voltou para Navigate do React Router"
echo "   • useAuth sem loops"
echo "   • Cache limpo"
echo ""
echo "🎯 TESTE AGORA:"
echo "   1. Pare o servidor (Ctrl+C)"
echo "   2. Execute: npm start"
echo "   3. Acesse: http://localhost:3000"
echo ""
echo "🔑 CREDENCIAIS FUNCIONAIS:"
echo "   ADMIN: admin@erlene.com / 123456"
echo "   CLIENTE: cliente@teste.com / 123456"
echo ""
echo "💾 BACKUPS SALVOS:"
echo "   • frontend/src/App.js.loop.bak (versão com loop)"
echo ""
echo "✨ O sistema deve voltar ao normal agora!"
echo ""
echo "📍 URLS FUNCIONAIS:"
echo "   • http://localhost:3000/login (admin)"
echo "   • http://localhost:3000/portal/login (cliente)"
echo "   • http://localhost:3000/admin (dashboard admin)"
echo "   • http://localhost:3000/portal/dashboard (dashboard cliente)"