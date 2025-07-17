#!/bin/bash

# Script 76 - Corrigir Erros de Compilação
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "🔧 Corrigindo erros de compilação..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 Verificando estrutura de pastas..."

# Criar estrutura de pastas necessárias
mkdir -p frontend/src/components/clients
mkdir -p frontend/src/components/reports

echo "✅ Estrutura de pastas criada"

echo "📝 Corrigindo App.js..."

# Criar App.js correto sem o ClientReports por enquanto
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/auth/Login';
import AdminLayout from './components/layout/AdminLayout';
import Dashboard from './pages/admin/Dashboard';
import Clients from './pages/admin/Clients';
import NewClient from './components/clients/NewClient';

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

echo "✅ App.js corrigido"

echo "🔧 Corrigindo Clients.js (dependency array)..."

# Corrigir o hook useEffect no Clients.js
if [ -f "frontend/src/pages/admin/Clients.js" ]; then
    # Fazer backup
    cp frontend/src/pages/admin/Clients.js frontend/src/pages/admin/Clients.js.backup.fix
    
    # Corrigir o useEffect
    sed -i 's|}, \[\]);|}, [mockClients]);|' frontend/src/pages/admin/Clients.js
    
    echo "✅ Clients.js corrigido"
else
    echo "⚠️ Clients.js não encontrado"
fi

echo "📝 Verificando se NewClient existe..."

# Verificar se NewClient existe
if [ ! -f "frontend/src/components/clients/NewClient.js" ]; then
    echo "⚠️ NewClient não encontrado. Criando..."
    
    # Criar NewClient básico
    cat > frontend/src/components/clients/NewClient.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  UserIcon,
  BuildingOfficeIcon
} from '@heroicons/react/24/outline';

const NewClient = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  
  const [formData, setFormData] = useState({
    type: 'PF',
    name: '',
    document: '',
    email: '',
    phone: ''
  });

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      alert('Cliente cadastrado com sucesso!');
      navigate('/admin/clientes');
    } catch (error) {
      alert('Erro ao cadastrar cliente');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/clientes"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Novo Cliente</h1>
              <p className="text-lg text-gray-600 mt-2">Cadastre um novo cliente no sistema</p>
            </div>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Tipo de Pessoa */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Tipo de Pessoa</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <label className={`flex items-center p-6 border-2 rounded-xl cursor-pointer transition-all ${
              formData.type === 'PF' ? 'border-primary-500 bg-primary-50' : 'border-gray-200 hover:border-gray-300'
            }`}>
              <input
                type="radio"
                name="type"
                value="PF"
                checked={formData.type === 'PF'}
                onChange={handleChange}
                className="sr-only"
              />
              <UserIcon className="w-8 h-8 text-primary-600 mr-4" />
              <div>
                <div className="text-lg font-semibold text-gray-900">Pessoa Física</div>
                <div className="text-sm text-gray-500">Cadastro com CPF</div>
              </div>
            </label>
            
            <label className={`flex items-center p-6 border-2 rounded-xl cursor-pointer transition-all ${
              formData.type === 'PJ' ? 'border-primary-500 bg-primary-50' : 'border-gray-200 hover:border-gray-300'
            }`}>
              <input
                type="radio"
                name="type"
                value="PJ"
                checked={formData.type === 'PJ'}
                onChange={handleChange}
                className="sr-only"
              />
              <BuildingOfficeIcon className="w-8 h-8 text-primary-600 mr-4" />
              <div>
                <div className="text-lg font-semibold text-gray-900">Pessoa Jurídica</div>
                <div className="text-sm text-gray-500">Cadastro com CNPJ</div>
              </div>
            </label>
          </div>
        </div>

        {/* Dados Básicos */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Dados Básicos</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                {formData.type === 'PF' ? 'Nome Completo' : 'Razão Social'} *
              </label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder={formData.type === 'PF' ? 'João Silva Santos' : 'Empresa ABC Ltda'}
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                {formData.type === 'PF' ? 'CPF' : 'CNPJ'} *
              </label>
              <input
                type="text"
                name="document"
                value={formData.document}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder={formData.type === 'PF' ? '000.000.000-00' : '00.000.000/0000-00'}
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Email *</label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="email@exemplo.com"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Telefone *</label>
              <input
                type="text"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="(11) 99999-9999"
              />
            </div>
          </div>
        </div>

        {/* Botões */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/clientes"
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              Cancelar
            </Link>
            <button
              type="submit"
              disabled={loading}
              className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? 'Salvando...' : 'Salvar Cliente'}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewClient;
EOF
    
    echo "✅ NewClient criado"
fi

echo ""
echo "✅ ERROS CORRIGIDOS!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • App.js sem ClientReports (removido temporariamente)"
echo "   • useEffect dependency array corrigido em Clients.js"
echo "   • NewClient criado/verificado"
echo "   • Estrutura de pastas corrigida"
echo ""
echo "🔗 TESTE AS ROTAS:"
echo "   • http://localhost:3000/admin/clientes"
echo "   • http://localhost:3000/admin/clientes/novo"
echo ""
echo "💡 PRÓXIMO PASSO:"
echo "   Testar se a compilação está funcionando"
echo "   Execute 'npm start' no frontend"