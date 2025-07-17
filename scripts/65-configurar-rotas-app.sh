#!/bin/bash

# Script 65 - Configuração das Rotas no App.js
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "🔗 Configurando rotas no App.js..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar se App.js existe
if [ ! -f "src/App.js" ]; then
    echo "❌ App.js não encontrado"
    exit 1
fi

# Criar App.js com todas as rotas configuradas
cat > src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import PrivateRoute from './components/PrivateRoute';

// Layout
import AdminLayout from './layouts/AdminLayout';

// Auth Pages
import Login from './pages/auth/Login';

// Admin Pages
import Dashboard from './pages/admin/Dashboard';
import ClientList from './pages/admin/Clients/ClientList';
import NewClient from './pages/admin/Clients/NewClient';
import EditClient from './pages/admin/Clients/EditClient';

// Placeholder pages (a serem implementadas)
const ProcessList = () => <div className="p-6"><h1 className="text-2xl font-bold">Processos</h1><p>Em desenvolvimento...</p></div>;
const AttendanceList = () => <div className="p-6"><h1 className="text-2xl font-bold">Atendimentos</h1><p>Em desenvolvimento...</p></div>;
const KanbanBoard = () => <div className="p-6"><h1 className="text-2xl font-bold">Kanban</h1><p>Em desenvolvimento...</p></div>;
const DocumentList = () => <div className="p-6"><h1 className="text-2xl font-bold">Documentos</h1><p>Em desenvolvimento...</p></div>;
const Financial = () => <div className="p-6"><h1 className="text-2xl font-bold">Financeiro</h1><p>Em desenvolvimento...</p></div>;
const Reports = () => <div className="p-6"><h1 className="text-2xl font-bold">Relatórios</h1><p>Em desenvolvimento...</p></div>;
const UserList = () => <div className="p-6"><h1 className="text-2xl font-bold">Usuários</h1><p>Em desenvolvimento...</p></div>;
const Settings = () => <div className="p-6"><h1 className="text-2xl font-bold">Configurações</h1><p>Em desenvolvimento...</p></div>;

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="App">
          <Routes>
            {/* Public Routes */}
            <Route path="/login" element={<Login />} />
            
            {/* Admin Routes */}
            <Route path="/admin" element={
              <PrivateRoute>
                <AdminLayout>
                  <Dashboard />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* Client Routes */}
            <Route path="/admin/clients" element={
              <PrivateRoute>
                <AdminLayout>
                  <ClientList />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            <Route path="/admin/clients/new" element={
              <PrivateRoute>
                <AdminLayout>
                  <NewClient />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            <Route path="/admin/clients/:id/edit" element={
              <PrivateRoute>
                <AdminLayout>
                  <EditClient />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* Process Routes */}
            <Route path="/admin/processes" element={
              <PrivateRoute>
                <AdminLayout>
                  <ProcessList />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* Attendance Routes */}
            <Route path="/admin/attendances" element={
              <PrivateRoute>
                <AdminLayout>
                  <AttendanceList />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* Kanban Routes */}
            <Route path="/admin/kanban" element={
              <PrivateRoute>
                <AdminLayout>
                  <KanbanBoard />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* Document Routes */}
            <Route path="/admin/documents" element={
              <PrivateRoute>
                <AdminLayout>
                  <DocumentList />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* Financial Routes */}
            <Route path="/admin/financial" element={
              <PrivateRoute>
                <AdminLayout>
                  <Financial />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* Reports Routes */}
            <Route path="/admin/reports" element={
              <PrivateRoute>
                <AdminLayout>
                  <Reports />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* User Routes */}
            <Route path="/admin/users" element={
              <PrivateRoute>
                <AdminLayout>
                  <UserList />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* Settings Routes */}
            <Route path="/admin/settings" element={
              <PrivateRoute>
                <AdminLayout>
                  <Settings />
                </AdminLayout>
              </PrivateRoute>
            } />
            
            {/* Default Routes */}
            <Route path="/" element={<Navigate to="/admin" replace />} />
            <Route path="*" element={<Navigate to="/admin" replace />} />
          </Routes>
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
EOF

# Verificar se AuthContext existe
if [ ! -f "src/contexts/AuthContext.js" ]; then
    echo "⚠️  AuthContext não encontrado. Criando..."
    
    mkdir -p src/contexts
    
    cat > src/contexts/AuthContext.js << 'EOF'
import React, { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth deve ser usado dentro de um AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Verificar se existe token armazenado
    const token = localStorage.getItem('token');
    const userData = localStorage.getItem('user');
    
    if (token && userData) {
      setUser(JSON.parse(userData));
    }
    
    setLoading(false);
  }, []);

  const login = async (email, password) => {
    try {
      // Simulação de login - substituir por API real
      if (email === 'admin@erlene.com' && password === '123456') {
        const userData = {
          id: 1,
          name: 'Admin',
          email: 'admin@erlene.com',
          role: 'admin'
        };
        
        const token = 'fake-jwt-token';
        
        localStorage.setItem('token', token);
        localStorage.setItem('user', JSON.stringify(userData));
        
        setUser(userData);
        return { success: true };
      } else {
        return { success: false, message: 'Credenciais inválidas' };
      }
    } catch (error) {
      return { success: false, message: 'Erro no login' };
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setUser(null);
  };

  const value = {
    user,
    login,
    logout,
    loading
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
EOF
fi

# Verificar se PrivateRoute existe
if [ ! -f "src/components/PrivateRoute.jsx" ]; then
    echo "⚠️  PrivateRoute não encontrado. Criando..."
    
    mkdir -p src/components
    
    cat > src/components/PrivateRoute.jsx << 'EOF'
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const PrivateRoute = ({ children }) => {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-red-600"></div>
      </div>
    );
  }

  return user ? children : <Navigate to="/login" replace />;
};

export default PrivateRoute;
EOF
fi

echo "✅ Rotas configuradas com sucesso!"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "• /admin - Dashboard principal"
echo "• /admin/clients - Lista de clientes"
echo "• /admin/clients/new - Novo cliente"
echo "• /admin/clients/:id/edit - Editar cliente"
echo "• /admin/processes - Processos"
echo "• /admin/attendances - Atendimentos"
echo "• /admin/kanban - Kanban"
echo "• /admin/documents - Documentos"
echo "• /admin/financial - Financeiro"
echo "• /admin/reports - Relatórios"
echo "• /admin/users - Usuários"
echo "• /admin/settings - Configurações"
echo ""
echo "🔧 Execute 'npm start' para testar!"
EOF

chmod +x 65-configurar-rotas-app.sh