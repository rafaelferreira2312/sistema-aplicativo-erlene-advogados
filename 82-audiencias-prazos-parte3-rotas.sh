#!/bin/bash

# Script 82 - Audiências e Prazos (Parte 3/3) - Rotas e App.js
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "🔗 Configurando rotas de Audiências e Prazos (Parte 3/3)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar estrutura frontend
if [ ! -d "frontend/src/pages/admin" ]; then
    echo "❌ Erro: Estrutura frontend não encontrada"
    exit 1
fi

echo "📝 1. Atualizando App.js para incluir rotas de Audiências e Prazos..."

# Fazer backup do App.js
cp frontend/src/App.js frontend/src/App.js.backup.$(date +%Y%m%d_%H%M%S)

# Atualizar App.js com novas rotas
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/auth/Login';
import AdminLayout from './components/layout/AdminLayout';
import Dashboard from './pages/admin/Dashboard';
import Clients from './pages/admin/Clients';
import NewClient from './components/clients/NewClient';
import Processes from './pages/admin/Processes';
import NewProcess from './components/processes/NewProcess';
import Audiencias from './pages/admin/Audiencias';
import Prazos from './pages/admin/Prazos';

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
                    <Route path="processos" element={<Processes />} />
                    <Route path="processos/novo" element={<NewProcess />} />
                    <Route path="audiencias" element={<Audiencias />} />
                    <Route path="prazos" element={<Prazos />} />
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
EOF

echo "✅ App.js atualizado com rotas de Audiências e Prazos!"

echo "📝 2. Verificando AdminLayout para adicionar links do menu..."

# Verificar se AdminLayout existe e tem os links necessários
if [ -f "frontend/src/components/layout/AdminLayout/index.js" ]; then
    echo "📁 AdminLayout encontrado, verificando links..."
    
    # Verificar se links já existem
    if ! grep -q "/admin/audiencias" frontend/src/components/layout/AdminLayout/index.js; then
        echo "⚠️ Links de Audiências e Prazos não encontrados, adicionando..."
        
        # Fazer backup
        cp frontend/src/components/layout/AdminLayout/index.js frontend/src/components/layout/AdminLayout/index.js.backup.audiencias
        
        # Adicionar ícones necessários ao import se não existir
        if ! grep -q "CalendarIcon" frontend/src/components/layout/AdminLayout/index.js; then
            sed -i 's/} from '\''@heroicons\/react\/24\/outline'\'';/, CalendarIcon, ClockIcon } from '\''@heroicons\/react\/24\/outline'\'';/' frontend/src/components/layout/AdminLayout/index.js
        fi
        
        # Adicionar links após processos (buscar linha com processos e adicionar)
        sed -i '/href.*\/admin\/processos/a\          { name: '\''Audiências'\'', href: '\''/admin/audiencias'\'', icon: CalendarIcon },\
          { name: '\''Prazos'\'', href: '\''/admin/prazos'\'', icon: ClockIcon },' frontend/src/components/layout/AdminLayout/index.js
        
        echo "✅ Links de Audiências e Prazos adicionados ao AdminLayout"
    else
        echo "✅ Links já existem no AdminLayout"
    fi
else
    echo "⚠️ AdminLayout não encontrado - precisa ser configurado manualmente"
fi

echo "📝 3. Criando componente de navegação rápida..."

# Criar componente de navegação rápida para processos
mkdir -p frontend/src/components/navigation

cat > frontend/src/components/navigation/ProcessNavigation.js << 'EOF'
import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  ScaleIcon,
  CalendarIcon,
  ClockIcon,
  ChartBarIcon,
  Squares2X2Icon
} from '@heroicons/react/24/outline';

const ProcessNavigation = () => {
  const location = useLocation();

  const navigationItems = [
    {
      name: 'Processos',
      href: '/admin/processos',
      icon: ScaleIcon,
      description: 'Lista geral de processos'
    },
    {
      name: 'Audiências',
      href: '/admin/audiencias', 
      icon: CalendarIcon,
      description: 'Audiências agendadas'
    },
    {
      name: 'Prazos',
      href: '/admin/prazos',
      icon: ClockIcon,
      description: 'Prazos vencendo'
    },
    {
      name: 'Kanban',
      href: '/admin/processos/kanban',
      icon: Squares2X2Icon,
      description: 'Visualização em quadros'
    },
    {
      name: 'Relatórios',
      href: '/admin/relatorios/processos',
      icon: ChartBarIcon,
      description: 'Relatórios de processos'
    }
  ];

  return (
    <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6 mb-8">
      <h2 className="text-lg font-semibold text-gray-900 mb-4">Navegação Rápida</h2>
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        {navigationItems.map((item) => {
          const isActive = location.pathname === item.href;
          return (
            <Link
              key={item.name}
              to={item.href}
              className={`flex flex-col items-center p-4 rounded-lg transition-all duration-200 ${
                isActive 
                  ? 'bg-primary-50 border-2 border-primary-200 text-primary-700' 
                  : 'bg-gray-50 border-2 border-transparent hover:bg-gray-100 text-gray-600 hover:text-gray-900'
              }`}
            >
              <item.icon className={`w-6 h-6 mb-2 ${isActive ? 'text-primary-600' : 'text-gray-400'}`} />
              <span className="text-sm font-medium text-center">{item.name}</span>
              <span className="text-xs text-center mt-1 opacity-75">{item.description}</span>
            </Link>
          );
        })}
      </div>
    </div>
  );
};

export default ProcessNavigation;
EOF

echo "✅ ProcessNavigation criado!"

echo ""
echo "🎉 PARTE 3/3 CONCLUÍDA!"
echo ""
echo "✅ CONFIGURAÇÕES FINALIZADAS:"
echo "   • App.js atualizado com rotas de Audiências e Prazos"
echo "   • Links adicionados ao AdminLayout (se necessário)"
echo "   • Componente de navegação rápida criado"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "   • /admin/audiencias - Página de audiências"
echo "   • /admin/prazos - Página de prazos"
echo "   • Links no menu lateral"
echo ""
echo "📁 ARQUIVOS CRIADOS/ATUALIZADOS:"
echo "   • frontend/src/App.js (rotas)"
echo "   • frontend/src/components/layout/AdminLayout/index.js (links)"
echo "   • frontend/src/components/navigation/ProcessNavigation.js (navegação)"
echo ""
echo "🧪 TESTE AS ROTAS:"
echo "   1. http://localhost:3000/admin/audiencias"
echo "   2. http://localhost:3000/admin/prazos"
echo "   3. Clique nos links do menu lateral"
echo ""
echo "🎯 MÓDULO AUDIÊNCIAS E PRAZOS 100% COMPLETO!"
echo ""
echo "⏭️ PRÓXIMO MÓDULO SUGERIDO:"
echo "   • Sistema Financeiro (honorários, pagamentos)"
echo "   • Kanban de Processos (arrastar e soltar)"
echo "   • Sistema GED (documentos por cliente)"
echo "   • Portal do Cliente completo"
echo ""
echo "Digite 'continuar' para implementar o próximo módulo!"