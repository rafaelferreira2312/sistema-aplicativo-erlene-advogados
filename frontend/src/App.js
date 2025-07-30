import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/auth/Login';
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

// Portal Cliente (temporário)
const ClientPortal = () => {
  const handleLogout = () => {
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('userType');
    window.location.href = '/login';
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="bg-gradient-erlene text-white p-4">
        <div className="flex justify-between items-center max-w-7xl mx-auto">
          <h1 className="text-xl font-bold">Portal do Cliente - Erlene Advogados</h1>
          <button
            onClick={handleLogout}
            className="bg-red-700 hover:bg-red-800 px-4 py-2 rounded text-sm"
          >
            Sair
          </button>
        </div>
      </div>

      <div className="max-w-7xl mx-auto p-6">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900">Portal do Cliente</h2>
          <p className="text-gray-600">Acompanhe seus processos e documentos</p>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {[
            { title: 'Meus Processos', subtitle: '3 processos ativos', color: 'red', icon: '⚖️' },
            { title: 'Documentos', subtitle: '12 documentos disponíveis', color: 'blue', icon: '📄' },
            { title: 'Pagamentos', subtitle: '2 pagamentos pendentes', color: 'green', icon: '💳' }
          ].map((item) => (
            <div key={item.title} className="bg-white overflow-hidden shadow-erlene rounded-lg">
              <div className="p-6">
                <div className="flex items-center mb-4">
                  <span className="text-2xl mr-3">{item.icon}</span>
                  <h3 className="text-lg font-medium text-gray-900">{item.title}</h3>
                </div>
                <p className="text-gray-600 mb-4">{item.subtitle}</p>
                <button className={`bg-${item.color}-600 text-white px-4 py-2 rounded hover:bg-${item.color}-700`}>
                  Ver {item.title}
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

// Componente de proteção de rota
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';
  const userType = localStorage.getItem('userType');

  if (requiredAuth && !isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (!requiredAuth && isAuthenticated) {
    return <Navigate to={userType === 'cliente' ? '/portal' : '/admin'} replace />;
  }

  if (allowedTypes.length > 0 && !allowedTypes.includes(userType)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return children;
};

// Página 404
const NotFoundPage = () => (
  <div className="min-h-screen flex items-center justify-center bg-gray-50">
    <div className="text-center">
      <h1 className="text-6xl font-bold text-gray-400 mb-4">404</h1>
      <p className="text-gray-600 mb-4">Página não encontrada</p>
      <a href="/login" className="bg-gradient-erlene text-white px-4 py-2 rounded hover:shadow-erlene">
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
          <Route path="/" element={<Navigate to="/login" replace />} />
          
          <Route
            path="/login"
            element={
              <ProtectedRoute requiredAuth={false}>
                <Login />
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
                  </Routes>
                </AdminLayout>
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/portal"
            element={
              <ProtectedRoute allowedTypes={['cliente']}>
                <ClientPortal />
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
