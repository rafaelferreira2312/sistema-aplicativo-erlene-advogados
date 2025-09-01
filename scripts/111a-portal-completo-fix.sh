#!/bin/bash

# Script 111a - Correção Portal Completo
# Autor: Sistema Erlene Advogados  
# Data: $(date +%Y-%m-%d)

echo "🔧 Script 111a - Corrigindo redirecionamento portal..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar estrutura frontend
if [ ! -d "frontend/src" ]; then
    echo "❌ Erro: Estrutura frontend não encontrada"
    exit 1
fi

echo "📝 Fazendo backup do App.js atual..."
cp frontend/src/App.js frontend/src/App.js.bak.111a

echo "🔧 Corrigindo App.js - removendo redirecionamentos problemáticos..."

# Criar App.js corrigido sem Navigate problemático
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Login from './pages/auth/Login';
import PortalLogin from './pages/portal/PortalLogin';
import PortalDashboard from './pages/portal/PortalDashboard';
import PortalProcessos from './pages/portal/PortalProcessos';
import PortalDocumentos from './pages/portal/PortalDocumentos';
import PortalPagamentos from './pages/portal/PortalPagamentos';
import PortalMensagens from './pages/portal/PortalMensagens';
import PortalPerfil from './pages/portal/PortalPerfil';
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

// Página inicial que redireciona sem Navigate
const HomePage = () => {
  React.useEffect(() => {
    const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';
    const portalAuth = localStorage.getItem('portalAuth') === 'true';
    const userType = localStorage.getItem('userType');

    if (isAuthenticated && userType === 'admin') {
      window.location.href = '/admin';
    } else if (portalAuth && userType === 'cliente') {
      window.location.href = '/portal/dashboard';
    } else {
      window.location.href = '/login';
    }
  }, []);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-red-600 mx-auto"></div>
        <p className="mt-4 text-gray-600">Redirecionando...</p>
      </div>
    </div>
  );
};

// Componente de proteção de rota sem Navigate
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  const [loading, setLoading] = React.useState(true);
  const [authorized, setAuthorized] = React.useState(false);

  React.useEffect(() => {
    const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';
    const portalAuth = localStorage.getItem('portalAuth') === 'true';
    const userType = localStorage.getItem('userType');

    // Se requer autenticação
    if (requiredAuth) {
      // Para sistema administrativo
      if (allowedTypes.includes('admin') && !isAuthenticated) {
        window.location.href = '/login';
        return;
      }
      
      // Para portal do cliente
      if (allowedTypes.includes('cliente') && !portalAuth) {
        window.location.href = '/portal/login';
        return;
      }
    }

    // Se não requer autenticação e está logado, redirecionar
    if (!requiredAuth && (isAuthenticated || portalAuth)) {
      if (userType === 'cliente') {
        window.location.href = '/portal/dashboard';
        return;
      } else {
        window.location.href = '/admin';
        return;
      }
    }

    // Verificar tipo de usuário permitido
    if (allowedTypes.length > 0 && !allowedTypes.includes(userType)) {
      window.location.href = '/unauthorized';
      return;
    }

    setAuthorized(true);
    setLoading(false);
  }, [requiredAuth, allowedTypes]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-red-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Verificando acesso...</p>
        </div>
      </div>
    );
  }

  return authorized ? children : null;
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

// App principal
function App() {
  return (
    <Router>
      <div className="App h-screen">
        <Routes>
          <Route path="/" element={<HomePage />} />
          
          <Route
            path="/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <Login />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <PortalLogin />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/dashboard"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalDashboard />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/processos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalProcessos />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/documentos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalDocumentos />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/pagamentos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalPagamentos />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/mensagens"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalMensagens />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal/perfil"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalPerfil />
              </ProtectedRoute>
            }
          />
          
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

echo "✅ App.js corrigido!"

echo "🔧 Corrigindo PortalLayout - ajustando navegação..."

# Corrigir PortalLayout.js para evitar conflitos
cat > frontend/src/components/portal/layout/index.js << 'EOF'
import React, { useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { 
  HomeIcon,
  ScaleIcon,
  DocumentIcon,
  CreditCardIcon,
  ChatBubbleLeftIcon,
  Bars3Icon,
  XMarkIcon,
  ArrowRightOnRectangleIcon,
  UserIcon
} from '@heroicons/react/24/outline';
import { useAuth } from '../../../hooks/auth/useAuth';

const navigation = [
  { name: 'Dashboard', href: '/portal/dashboard', icon: HomeIcon },
  { name: 'Meus Processos', href: '/portal/processos', icon: ScaleIcon },
  { name: 'Documentos', href: '/portal/documentos', icon: DocumentIcon },
  { name: 'Pagamentos', href: '/portal/pagamentos', icon: CreditCardIcon },
  { name: 'Mensagens', href: '/portal/mensagens', icon: ChatBubbleLeftIcon },
  { name: 'Meu Perfil', href: '/portal/perfil', icon: UserIcon },
];

const PortalLayout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();
  const { user, logout } = useAuth();

  const handleLogout = async () => {
    localStorage.removeItem('portalAuth');
    localStorage.removeItem('userType');
    localStorage.removeItem('user');
    window.location.href = '/portal/login';
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div 
          className="fixed inset-0 z-40 bg-black bg-opacity-25 lg:hidden" 
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div
        className={`
          fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0
          ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
        `}
      >
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-center justify-between h-16 px-4 bg-gradient-to-r from-red-600 to-red-700">
            <div className="flex items-center">
              <div className="flex-shrink-0 w-8 h-8 bg-white rounded-lg flex items-center justify-center">
                <span className="text-red-600 font-bold text-lg">E</span>
              </div>
              <div className="ml-3 text-white">
                <p className="text-sm font-semibold">Portal do Cliente</p>
                <p className="text-xs opacity-75">Erlene Advogados</p>
              </div>
            </div>

            <button
              type="button"
              className="lg:hidden text-white hover:text-gray-200"
              onClick={() => setSidebarOpen(false)}
            >
              <XMarkIcon className="h-6 w-6" />
            </button>
          </div>

          {/* User info */}
          <div className="px-4 py-4 border-b border-gray-200">
            <div className="flex items-center">
              <div className="flex-shrink-0 w-10 h-10 bg-gray-300 rounded-full flex items-center justify-center">
                <span className="text-gray-600 font-medium text-sm">
                  {user?.nome?.charAt(0) || 'C'}
                </span>
              </div>
              <div className="ml-3">
                <p className="text-sm font-medium text-gray-900">
                  {user?.nome || 'Cliente'}
                </p>
                <p className="text-xs text-gray-500">
                  {user?.email || 'cliente@email.com'}
                </p>
              </div>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
            {navigation.map((item) => {
              const isActive = location.pathname === item.href;
              
              return (
                <NavLink
                  key={item.name}
                  to={item.href}
                  className={`
                    group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors
                    ${isActive
                      ? 'bg-red-50 text-red-700 border-r-2 border-red-700'
                      : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                    }
                  `}
                  onClick={() => {
                    if (window.innerWidth < 1024) {
                      setSidebarOpen(false);
                    }
                  }}
                >
                  <item.icon
                    className={`
                      mr-3 h-5 w-5 flex-shrink-0
                      ${isActive ? 'text-red-500' : 'text-gray-400 group-hover:text-gray-500'}
                    `}
                  />
                  {item.name}
                </NavLink>
              );
            })}
          </nav>

          {/* Logout */}
          <div className="px-4 py-4 border-t border-gray-200">
            <button
              onClick={handleLogout}
              className="w-full flex items-center px-3 py-2 text-sm font-medium text-gray-600 rounded-lg hover:bg-gray-50 hover:text-gray-900 transition-colors"
            >
              <ArrowRightOnRectangleIcon className="mr-3 h-5 w-5 text-gray-400" />
              Sair
            </button>
          </div>
        </div>
      </div>

      {/* Main content */}
      <div className="flex-1 flex flex-col overflow-hidden lg:ml-0">
        {/* Header */}
        <header className="bg-white shadow-sm border-b border-gray-200">
          <div className="flex items-center justify-between h-16 px-4 sm:px-6 lg:px-8">
            <button
              type="button"
              className="lg:hidden -ml-0.5 -mt-0.5 h-12 w-12 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-gray-900"
              onClick={() => setSidebarOpen(!sidebarOpen)}
            >
              <Bars3Icon className="h-6 w-6" />
            </button>

            <h1 className="ml-4 lg:ml-0 text-xl font-semibold text-gray-900">
              Portal do Cliente
            </h1>

            <div className="text-sm text-gray-500">
              Bem-vindo, {user?.nome?.split(' ')[0] || 'Cliente'}
            </div>
          </div>
        </header>

        {/* Page content */}
        <main className="flex-1 overflow-y-auto bg-gray-50">
          <div className="py-6">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              {children}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
};

export default PortalLayout;
EOF

echo "✅ PortalLayout corrigido!"

echo "🔧 Criando hook useAuth simplificado..."

# Criar useAuth simplificado para evitar conflitos
mkdir -p frontend/src/hooks/auth
cat > frontend/src/hooks/auth/useAuth.js << 'EOF'
import { useState, useEffect } from 'react';

export const useAuth = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Carregar dados do usuário do localStorage
    const userData = localStorage.getItem('user');
    if (userData) {
      try {
        setUser(JSON.parse(userData));
      } catch (error) {
        console.error('Erro ao carregar dados do usuário:', error);
      }
    }
    setLoading(false);
  }, []);

  const logout = async () => {
    localStorage.removeItem('portalAuth');
    localStorage.removeItem('userType');
    localStorage.removeItem('user');
    localStorage.removeItem('isAuthenticated');
    setUser(null);
    window.location.href = '/login';
  };

  return {
    user,
    loading,
    logout,
    isAuthenticated: !!user
  };
};
EOF

echo "✅ Hook useAuth criado!"

echo ""
echo "🎉 CORREÇÃO APLICADA COM SUCESSO!"
echo ""
echo "🔧 MUDANÇAS PRINCIPAIS:"
echo "   • Removido Navigate problemático"
echo "   • Substituído por window.location.href"
echo "   • ProtectedRoute sem Navigate"
echo "   • Redirecionamento via useEffect"
echo "   • Hook useAuth simplificado"
echo ""
echo "🎯 TESTE AS ROTAS:"
echo "   • http://localhost:3000 → redireciona"
echo "   • http://localhost:3000/login → login admin"
echo "   • http://localhost:3000/portal/login → login cliente"
echo "   • http://localhost:3000/portal/dashboard → dashboard cliente"
echo ""
echo "🔑 CREDENCIAIS PORTAL:"
echo "   CPF/CNPJ: 123.456.789-00"
echo "   Senha: 123456"
echo ""
echo "💾 BACKUP SALVO EM:"
echo "   • frontend/src/App.js.bak.111a"
echo ""
echo "✨ AGORA TESTE: npm start"
echo "   Deve funcionar sem erros de Router!"