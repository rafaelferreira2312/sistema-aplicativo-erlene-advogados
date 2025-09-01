import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
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

// Componente de proteção de rota CORRIGIDO
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  // Verificar múltiplas formas de autenticação para compatibilidade
  const token = localStorage.getItem('authToken') || localStorage.getItem('erlene_token') || localStorage.getItem('token');
  const isAuthFlag = localStorage.getItem('isAuthenticated') === 'true';
  const portalAuth = localStorage.getItem('portalAuth') === 'true';
  
  const isAuthenticated = !!(token || isAuthFlag);
  
  // Determinar tipo de usuário
  const userType = localStorage.getItem('userType') || (portalAuth ? 'cliente' : 'admin');

  // Se requer autenticação e não está autenticado
  if (requiredAuth && !isAuthenticated) {
    // Redirecionar para o login correto baseado no tipo esperado
    if (allowedTypes.includes('cliente')) {
      return <Navigate to="/portal/login" replace />;
    }
    return <Navigate to="/login" replace />;
  }

  // Se não requer autenticação mas está autenticado, redirecionar para dashboard
  if (!requiredAuth && isAuthenticated) {
    if (userType === 'cliente') {
      return <Navigate to="/portal/dashboard" replace />;
    }
    return <Navigate to="/admin" replace />;
  }

  // Verificar tipo de usuário permitido
  if (allowedTypes.length > 0 && !allowedTypes.includes(userType)) {
    if (userType === 'cliente') {
      return <Navigate to="/portal/dashboard" replace />;
    }
    return <Navigate to="/admin" replace />;
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

// App principal
function App() {
  return (
    <Router>
      <div className="App h-screen">
        <Routes>
          {/* Rota raiz redireciona para login */}
          <Route path="/" element={<Navigate to="/login" replace />} />
          
          {/* Login Administrativo */}
          <Route
            path="/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <Login />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do Cliente - Login */}
          <Route
            path="/portal/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <PortalLogin />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do Cliente - Dashboard */}
          <Route
            path="/portal/dashboard"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalDashboard />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do Cliente - Processos */}
          <Route
            path="/portal/processos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalProcessos />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do Cliente - Documentos */}
          <Route
            path="/portal/documentos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalDocumentos />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do Cliente - Pagamentos */}
          <Route
            path="/portal/pagamentos"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalPagamentos />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do Cliente - Mensagens */}
          <Route
            path="/portal/mensagens"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalMensagens />
              </ProtectedRoute>
            }
          />
          
          {/* Portal do Cliente - Perfil */}
          <Route
            path="/portal/perfil"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <PortalPerfil />
              </ProtectedRoute>
            }
          />
          
          {/* Sistema Administrativo */}
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
