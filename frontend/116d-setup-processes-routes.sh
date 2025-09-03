#!/bin/bash

# Script 116d - Setup Rotas Processos (Parte 1)
# Sistema Erlene Advogados - Configurar rotas no App.js
# Execução: chmod +x 116d-setup-processes-routes.sh && ./116d-setup-processes-routes.sh
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 116d - Configurando rotas de processos no App.js..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 116d-setup-processes-routes.sh && ./116d-setup-processes-routes.sh"
    exit 1
fi

echo "1️⃣ Verificando estrutura anterior..."

# Verificar se processesService.js existe
if [ ! -f "src/services/processesService.js" ]; then
    echo "❌ Erro: processesService.js não encontrado. Execute primeiro os scripts 116a, 116b, 116c"
    exit 1
fi

# Verificar se Processes.js existe
if [ ! -f "src/pages/admin/Processes.js" ]; then
    echo "❌ Erro: Processes.js não encontrado. Execute primeiro os scripts 116b e 116c"
    exit 1
fi

echo "2️⃣ Fazendo backup do App.js atual..."

# Backup do App.js original
if [ -f "src/App.js" ]; then
    cp src/App.js src/App.js.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup criado: App.js.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo "3️⃣ Atualizando App.js com rotas de processos..."

cat > src/App.js << 'EOF'
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

// Componente de proteção de rota
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('erlene_token') || localStorage.getItem('token');
  const isAuthFlag = localStorage.getItem('isAuthenticated') === 'true';
  const portalAuth = localStorage.getItem('portalAuth') === 'true';
  
  const isAuthenticated = !!(token || isAuthFlag);
  const userType = localStorage.getItem('userType') || (portalAuth ? 'cliente' : 'admin');

  if (requiredAuth && !isAuthenticated) {
    if (allowedTypes.includes('cliente')) {
      return <Navigate to="/portal/login" replace />;
    }
    return <Navigate to="/login" replace />;
  }

  if (!requiredAuth && isAuthenticated) {
    if (userType === 'cliente') {
      return <Navigate to="/portal/dashboard" replace />;
    }
    return <Navigate to="/admin" replace />;
  }

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
          
          {/* Portal do Cliente */}
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
                    
                    {/* ROTAS DE PROCESSOS ATUALIZADAS */}
                    <Route path="processos" element={<Processes />} />
                    <Route path="processos/novo" element={<NewProcess />} />
                    <Route path="processos/:id/editar" element={<EditProcess />} />
                    
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

echo "4️⃣ Verificando se arquivos foram criados corretamente..."

if [ -f "src/App.js" ]; then
    echo "✅ App.js atualizado com rotas de processos"
    echo "📊 Linhas do arquivo: $(wc -l < src/App.js)"
else
    echo "❌ Erro ao atualizar App.js"
    exit 1
fi

echo ""
echo "📋 Rotas de Processos Configuradas:"
echo "   • /admin/processos - Lista de processos"
echo "   • /admin/processos/novo - Cadastro de processo"
echo "   • /admin/processos/:id/editar - Edição de processo"
echo ""
echo "✅ Script 116d concluído!"
echo "⭐ Próximo: Script para criar ProcessDetails.js"
echo ""
echo "Digite 'continuar' para criar o componente ProcessDetails.js"