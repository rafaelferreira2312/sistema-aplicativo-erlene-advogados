#!/bin/bash

# Script 59 - Corrigir Estrutura App e Criar Diretórios
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/59-corrigir-estrutura-app.sh

echo "🔧 Corrigindo estrutura do App e criando diretórios..."

# 1. Criar diretório ErrorBoundary se não existir
mkdir -p frontend/src/components/common/ErrorBoundary

# 2. Criar ErrorBoundary novamente garantindo que o diretório existe
cat > frontend/src/components/common/ErrorBoundary/index.js << 'EOF'
import React from 'react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-gray-900 mb-4">
              Algo deu errado
            </h1>
            <p className="text-gray-600 mb-4">
              Ocorreu um erro inesperado. Recarregue a página.
            </p>
            <button
              onClick={() => window.location.reload()}
              className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
            >
              Recarregar
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
EOF

# 3. Simplificar App.js para não depender de muitos componentes
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/auth/AuthProvider';

// Pages
import Login from './pages/auth/Login';
import Dashboard from './pages/admin/Dashboard';
import PortalDashboard from './pages/portal/Dashboard';

// Error Boundary simples inline
class SimpleErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-red-600 mb-4">Erro no Sistema</h1>
            <button
              onClick={() => window.location.reload()}
              className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
            >
              Recarregar
            </button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

// Componente de rota protegida simples
const ProtectedRoute = ({ children, requiredAuth = true }) => {
  const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';
  
  if (requiredAuth && !isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  if (!requiredAuth && isAuthenticated) {
    const userType = localStorage.getItem('userType');
    return <Navigate to={userType === 'cliente' ? '/portal' : '/admin'} replace />;
  }
  
  return children;
};

function App() {
  return (
    <SimpleErrorBoundary>
      <AuthProvider>
        <Router>
          <div className="App min-h-screen bg-gray-50">
            <Routes>
              {/* Rota raiz */}
              <Route path="/" element={<Navigate to="/login" replace />} />

              {/* Login */}
              <Route
                path="/login"
                element={
                  <ProtectedRoute requiredAuth={false}>
                    <Login />
                  </ProtectedRoute>
                }
              />

              {/* Admin Dashboard */}
              <Route
                path="/admin"
                element={
                  <ProtectedRoute>
                    <div className="min-h-screen bg-gray-100">
                      <div className="bg-red-600 text-white p-4">
                        <h1 className="text-xl font-bold">Sistema Erlene Advogados - Admin</h1>
                      </div>
                      <div className="container mx-auto p-6">
                        <Dashboard />
                      </div>
                    </div>
                  </ProtectedRoute>
                }
              />

              {/* Portal Cliente */}
              <Route
                path="/portal"
                element={
                  <ProtectedRoute>
                    <div className="min-h-screen bg-gray-100">
                      <div className="bg-red-600 text-white p-4">
                        <h1 className="text-xl font-bold">Portal do Cliente - Erlene Advogados</h1>
                      </div>
                      <div className="container mx-auto p-6">
                        <PortalDashboard />
                      </div>
                    </div>
                  </ProtectedRoute>
                }
              />

              {/* 404 */}
              <Route 
                path="*" 
                element={
                  <div className="min-h-screen flex items-center justify-center bg-gray-50">
                    <div className="text-center">
                      <h1 className="text-4xl font-bold text-gray-400 mb-4">404</h1>
                      <p className="text-gray-600 mb-4">Página não encontrada</p>
                      <a href="/login" className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">
                        Voltar ao Login
                      </a>
                    </div>
                  </div>
                } 
              />
            </Routes>
          </div>
        </Router>
      </AuthProvider>
    </SimpleErrorBoundary>
  );
}

export default App;
EOF

# 4. Verificar se Dashboard admin existe, se não criar um simples
if [ ! -f "frontend/src/pages/admin/Dashboard/index.js" ]; then
  mkdir -p frontend/src/pages/admin/Dashboard
  cat > frontend/src/pages/admin/Dashboard/index.js << 'EOF'
import React from 'react';

const Dashboard = () => {
  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-gray-900">
          Dashboard Administrativo
        </h2>
        <p className="mt-1 text-gray-600">
          Bem-vindo ao sistema de gestão jurídica.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-8 w-8 bg-red-600 rounded-full flex items-center justify-center">
                  <span className="text-white font-bold">👥</span>
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Total de Clientes
                  </dt>
                  <dd className="text-2xl font-semibold text-gray-900">
                    1,247
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-8 w-8 bg-blue-600 rounded-full flex items-center justify-center">
                  <span className="text-white font-bold">⚖️</span>
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Processos Ativos
                  </dt>
                  <dd className="text-2xl font-semibold text-gray-900">
                    891
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-8 w-8 bg-green-600 rounded-full flex items-center justify-center">
                  <span className="text-white font-bold">💰</span>
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Receita Mensal
                  </dt>
                  <dd className="text-2xl font-semibold text-gray-900">
                    R$ 125.847
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-8 w-8 bg-yellow-600 rounded-full flex items-center justify-center">
                  <span className="text-white font-bold">📅</span>
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Atendimentos Hoje
                  </dt>
                  <dd className="text-2xl font-semibold text-gray-900">
                    14
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white shadow rounded-lg p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Ações Rápidas</h3>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-red-500 hover:bg-red-50 transition-colors">
            <span className="text-2xl mb-2">👤</span>
            <span className="text-sm font-medium text-gray-900">Novo Cliente</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-red-500 hover:bg-red-50 transition-colors">
            <span className="text-2xl mb-2">⚖️</span>
            <span className="text-sm font-medium text-gray-900">Novo Processo</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-red-500 hover:bg-red-50 transition-colors">
            <span className="text-2xl mb-2">📅</span>
            <span className="text-sm font-medium text-gray-900">Agendar Atendimento</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-red-500 hover:bg-red-50 transition-colors">
            <span className="text-2xl mb-2">📊</span>
            <span className="text-sm font-medium text-gray-900">Ver Relatórios</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
EOF
fi

# 5. Verificar se PortalDashboard existe, se não criar um simples
if [ ! -f "frontend/src/pages/portal/Dashboard/index.js" ]; then
  mkdir -p frontend/src/pages/portal/Dashboard
  cat > frontend/src/pages/portal/Dashboard/index.js << 'EOF'
import React from 'react';

const PortalDashboard = () => {
  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-gray-900">
          Portal do Cliente
        </h2>
        <p className="mt-1 text-gray-600">
          Acompanhe seus processos e documentos.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <h3 className="text-lg font-medium text-gray-900">Meus Processos</h3>
            <p className="mt-1 text-gray-600">3 processos ativos</p>
            <div className="mt-4">
              <button className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">
                Ver Processos
              </button>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <h3 className="text-lg font-medium text-gray-900">Documentos</h3>
            <p className="mt-1 text-gray-600">12 documentos disponíveis</p>
            <div className="mt-4">
              <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                Ver Documentos
              </button>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <h3 className="text-lg font-medium text-gray-900">Pagamentos</h3>
            <p className="mt-1 text-gray-600">2 pagamentos pendentes</p>
            <div className="mt-4">
              <button className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">
                Ver Pagamentos
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PortalDashboard;
EOF
fi

echo "✅ Estrutura App corrigida!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • Diretório ErrorBoundary criado corretamente"
echo "   • App.js simplificado com ErrorBoundary inline"
echo "   • Roteamento básico funcional"
echo "   • Dashboard Admin e Portal criados"
echo "   • Proteção de rotas simples"
echo ""
echo "📦 ESTRUTURA FUNCIONANDO:"
echo "   • /login - Página de login"
echo "   • /admin - Dashboard administrativo"
echo "   • /portal - Portal do cliente"
echo ""
echo "▶️ Execute 'npm start' - Deve compilar sem erros!"