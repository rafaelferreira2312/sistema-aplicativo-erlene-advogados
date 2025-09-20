#!/bin/bash

# Script 207a - Corrigir Imports de Componentes Faltando
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 207a - Corrigindo imports de componentes faltando..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# Fazer backup do App.js atual
cp src/App.js src/App.js.bak.207a

# Corrigir App.js removendo imports que não existem
echo "🔧 Corrigindo App.js - removendo componentes inexistentes..."
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

// Layout admin e componentes principais (que existem)
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

// Route Guards
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

# Verificar quais componentes existem realmente
echo "🔍 Verificando componentes que existem..."
echo "📁 Componentes encontrados em src/pages/admin/:"
ls -la src/pages/admin/ 2>/dev/null || echo "   Pasta admin não encontrada"

echo ""
echo "📁 Componentes encontrados em src/components/:"
find src/components/ -name "*.js" 2>/dev/null | head -10 || echo "   Pasta components não encontrada"

echo ""
echo "✅ App.js corrigido - removidos imports inexistentes:"
echo "   ❌ Relatorios (não existe)"
echo "   ❌ Usuarios (não existe)" 
echo "   ❌ Configuracoes (não existe)"
echo ""
echo "📋 TESTE AGORA:"
echo "   npm start"
echo ""
echo "🔗 ACESSE:"
echo "   http://localhost:3000 (deve redirecionar para /login)"
echo "   http://localhost:3000/clear-auth.html (para limpar dados antigos)"