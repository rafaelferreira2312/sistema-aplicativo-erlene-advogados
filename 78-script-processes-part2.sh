#!/bin/bash

# Script 78 - Tela de Processos (Parte 2/3)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "⚖️ Criando tela de processos (Parte 2/3)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Completando Processes.js com lista e filtros..."

# Completar o arquivo Processes.js adicionando a lista de processos
cat >> frontend/src/pages/admin/Processes.js << 'EOF'

      {/* Lista de Processos */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Lista de Processos</h2>
          <Link
            to="/admin/processos/novo"
            className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <PlusIcon className="w-5 h-5 mr-2" />
            Novo Processo
          </Link>
        </div>
        
        <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-6">
          {/* Busca */}
          <div className="relative flex-1">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar processo, cliente ou tipo..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          
          {/* Filtros */}
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os status</option>
            <option value="Em andamento">Em andamento</option>
            <option value="Urgente">Urgente</option>
            <option value="Suspenso">Suspenso</option>
            <option value="Concluído">Concluído</option>
          </select>
          
          <select
            value={filterCourt}
            onChange={(e) => setFilterCourt(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os tribunais</option>
            <option value="TJSP">TJSP</option>
            <option value="TJRJ">TJRJ</option>
            <option value="STJ">STJ</option>
            <option value="TST">TST</option>
          </select>

          <select
            value={filterClient}
            onChange={(e) => setFilterClient(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os clientes</option>
            <option value="1">João Silva Santos</option>
            <option value="2">Empresa ABC Ltda</option>
            <option value="3">Maria Oliveira Costa</option>
            <option value="4">Tech Solutions S.A.</option>
          </select>
        </div>

        {/* Tabela de Processos */}
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Processo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cliente
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tribunal/Tipo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Valor/Prazo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Advogado
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredProcesses.map((process) => (
                <tr key={process.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                        <ScaleIcon className="w-5 h-5 text-primary-600" />
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {process.number}
                        </div>
                        <div className={`text-xs font-medium ${getPriorityColor(process.priority)}`}>
                          Prioridade: {process.priority}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{process.client}</div>
                    <div className="text-sm text-gray-500">ID: {process.clientId}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{process.court}</div>
                    <div className="text-sm text-gray-500">{process.actionType}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(process.status)}`}>
                      {getStatusIcon(process.status)}
                      <span className="ml-1">{process.status}</span>
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {process.value > 0 ? `R$ ${process.value.toLocaleString('pt-BR')}` : 'Sem valor'}
                    </div>
                    <div className="text-sm text-gray-500">
                      {process.nextDeadline ? (
                        <span className="flex items-center">
                          <ClockIcon className="w-3 h-3 mr-1" />
                          {new Date(process.nextDeadline).toLocaleDateString('pt-BR')}
                        </span>
                      ) : (
                        'Sem prazo'
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{process.lawyer}</div>
                    <div className="text-sm text-gray-500">
                      Dist: {new Date(process.distributionDate).toLocaleDateString('pt-BR')}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex justify-end space-x-2">
                      <button 
                        className="text-blue-600 hover:text-blue-900"
                        title="Visualizar"
                      >
                        <EyeIcon className="w-5 h-5" />
                      </button>
                      <Link
                        to={`/admin/processos/${process.id}/editar`}
                        className="text-primary-600 hover:text-primary-900"
                        title="Editar"
                      >
                        <PencilIcon className="w-5 h-5" />
                      </Link>
                      <button
                        onClick={() => handleDelete(process.id)}
                        className="text-red-600 hover:text-red-900"
                        title="Excluir"
                      >
                        <TrashIcon className="w-5 h-5" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {/* Estado vazio */}
        {filteredProcesses.length === 0 && (
          <div className="text-center py-12">
            <ScaleIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum processo encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || filterStatus !== 'all' || filterCourt !== 'all' || filterClient !== 'all'
                ? 'Tente ajustar os filtros de busca.'
                : 'Comece cadastrando um novo processo.'}
            </p>
            <div className="mt-6">
              <Link
                to="/admin/processos/novo"
                className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <PlusIcon className="w-5 h-5 mr-2" />
                Novo Processo
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Processes;
EOF

echo "✅ Processes.js completado (Parte 2)!"

echo "📝 Atualizando App.js para incluir rota de processos..."

# Fazer backup do App.js atual
cp frontend/src/App.js frontend/src/App.js.backup.processes

# Atualizar App.js para incluir Processes
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/auth/Login';
import AdminLayout from './components/layout/AdminLayout';
import Dashboard from './pages/admin/Dashboard';
import Clients from './pages/admin/Clients';
import NewClient from './components/clients/NewClient';
import Processes from './pages/admin/Processes';

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

echo "✅ App.js atualizado com rota de processos!"

echo "🔧 Verificando se AdminLayout tem link para processos..."

# Verificar se o AdminLayout tem o link de processos
if [ -f "frontend/src/components/layout/AdminLayout/index.js" ]; then
    if grep -q "processos" frontend/src/components/layout/AdminLayout/index.js; then
        echo "✅ Link de processos já existe no AdminLayout"
    else
        echo "⚠️ Adicionando link de processos ao AdminLayout..."
        
        # Fazer backup
        cp frontend/src/components/layout/AdminLayout/index.js frontend/src/components/layout/AdminLayout/index.js.backup.processes
        
        # Adicionar link de processos no sidebar (inserir após clientes)
        sed -i '/clientes/a\          { name: '\''Processos'\'', href: '\''/admin/processos'\'', icon: ScaleIcon },' frontend/src/components/layout/AdminLayout/index.js
        
        # Adicionar import do ScaleIcon se não existir
        if ! grep -q "ScaleIcon" frontend/src/components/layout/AdminLayout/index.js; then
            sed -i 's/} from '\''@heroicons\/react\/24\/outline'\'';/, ScaleIcon } from '\''@heroicons\/react\/24\/outline'\'';/' frontend/src/components/layout/AdminLayout/index.js
        fi
        
        echo "✅ Link de processos adicionado ao AdminLayout"
    fi
else
    echo "⚠️ AdminLayout não encontrado - verifique manualmente"
fi

echo ""
echo "✅ PARTE 2/3 CONCLUÍDA!"
echo ""
echo "📊 IMPLEMENTADO:"
echo "   • Lista completa de processos em tabela"
echo "   • Filtros por status, tribunal, cliente"
echo "   • Busca por número, cliente ou tipo"
echo "   • Ações CRUD (visualizar, editar, excluir)"
echo "   • Exibição de valor da causa e prazos"
echo "   • Prioridades coloridas"
echo "   • Status com ícones específicos"
echo "   • Relacionamento com clientes"
echo "   • Estado vazio com call-to-action"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "   • /admin/processos - Lista de processos"
echo "   • Link no sidebar AdminLayout"
echo ""
echo "⏭️ PRÓXIMA PARTE (3/3):"
echo "   • Formulário de cadastro de processo"
echo "   • Seleção de cliente com busca"
echo "   • Validação de número CNJ"
echo "   • Configurações avançadas"
echo ""
echo "Digite 'continuar' para Parte 3/3!"