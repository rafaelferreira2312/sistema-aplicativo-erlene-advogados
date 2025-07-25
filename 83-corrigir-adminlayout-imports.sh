#!/bin/bash

# Script 83 - Corrigir Imports do AdminLayout
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "🔧 Corrigindo imports do AdminLayout (ClockIcon)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar estrutura frontend
if [ ! -d "frontend/src/components/layout/AdminLayout" ]; then
    echo "❌ Erro: AdminLayout não encontrado"
    exit 1
fi

echo "📝 Fazendo backup do AdminLayout atual..."

# Fazer backup
cp frontend/src/components/layout/AdminLayout/index.js frontend/src/components/layout/AdminLayout/index.js.backup.$(date +%Y%m%d_%H%M%S)

echo "🔧 Corrigindo AdminLayout com imports corretos..."

# Criar AdminLayout corrigido seguindo EXATO padrão do projeto
cat > frontend/src/components/layout/AdminLayout/index.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  Bars3Icon,
  XMarkIcon,
  HomeIcon,
  UsersIcon,
  ScaleIcon,
  CalendarIcon,
  ClockIcon,
  CurrencyDollarIcon,
  DocumentIcon,
  ClipboardDocumentListIcon,
  ChartBarIcon,
  UserGroupIcon,
  Cog6ToothIcon,
  ArrowRightOnRectangleIcon,
  BellIcon,
  MagnifyingGlassIcon
} from '@heroicons/react/24/outline';

const AdminLayout = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('userType');
    navigate('/login');
  };

  const navigation = [
    { name: 'Dashboard', href: '/admin', icon: HomeIcon, current: location.pathname === '/admin' || location.pathname === '/admin/dashboard' },
    { name: 'Clientes', href: '/admin/clientes', icon: UsersIcon, current: location.pathname.startsWith('/admin/clientes') },
    { name: 'Processos', href: '/admin/processos', icon: ScaleIcon, current: location.pathname.startsWith('/admin/processos') },
    { name: 'Audiências', href: '/admin/audiencias', icon: CalendarIcon, current: location.pathname === '/admin/audiencias' },
    { name: 'Prazos', href: '/admin/prazos', icon: ClockIcon, current: location.pathname === '/admin/prazos' },
    { name: 'Atendimentos', href: '/admin/appointments', icon: CalendarIcon, current: location.pathname === '/admin/appointments' },
    { name: 'Financeiro', href: '/admin/financial', icon: CurrencyDollarIcon, current: location.pathname === '/admin/financial' },
    { name: 'Documentos', href: '/admin/documents', icon: DocumentIcon, current: location.pathname === '/admin/documents' },
    { name: 'Kanban', href: '/admin/kanban', icon: ClipboardDocumentListIcon, current: location.pathname === '/admin/kanban' },
    { name: 'Relatórios', href: '/admin/reports', icon: ChartBarIcon, current: location.pathname === '/admin/reports' },
    { name: 'Usuários', href: '/admin/users', icon: UserGroupIcon, current: location.pathname === '/admin/users' },
    { name: 'Configurações', href: '/admin/settings', icon: Cog6ToothIcon, current: location.pathname === '/admin/settings' },
  ];

  return (
    <div className="h-full flex">
      {/* Sidebar Mobile */}
      {sidebarOpen && (
        <div className="fixed inset-0 flex z-40 md:hidden">
          <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setSidebarOpen(false)} />
          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
            <div className="absolute top-0 right-0 -mr-12 pt-2">
              <button
                className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                onClick={() => setSidebarOpen(false)}
              >
                <XMarkIcon className="h-6 w-6 text-white" />
              </button>
            </div>
            <div className="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
              <div className="flex-shrink-0 flex items-center px-4">
                <div className="h-10 w-10 bg-gradient-erlene rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-lg">E</span>
                </div>
                <span className="ml-3 text-lg font-semibold text-gray-900">Erlene Advogados</span>
              </div>
              <nav className="mt-5 px-2 space-y-1">
                {navigation.map((item) => (
                  <a
                    key={item.name}
                    href={item.href}
                    className={`${
                      item.current
                        ? 'bg-primary-100 text-primary-900'
                        : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                    } group flex items-center px-2 py-2 text-base font-medium rounded-md`}
                  >
                    <item.icon
                      className={`${
                        item.current ? 'text-primary-500' : 'text-gray-400 group-hover:text-gray-500'
                      } mr-4 flex-shrink-0 h-6 w-6`}
                    />
                    {item.name}
                  </a>
                ))}
              </nav>
            </div>
          </div>
        </div>
      )}

      {/* Sidebar Desktop */}
      <div className="hidden md:flex md:flex-shrink-0">
        <div className="flex flex-col w-64">
          <div className="flex flex-col h-0 flex-1 border-r border-gray-200 bg-white">
            <div className="flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
              <div className="flex items-center flex-shrink-0 px-4">
                <div className="h-10 w-10 bg-gradient-erlene rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-lg">E</span>
                </div>
                <span className="ml-3 text-lg font-semibold text-gray-900">Erlene Advogados</span>
              </div>
              <nav className="mt-8 flex-1 px-2 bg-white space-y-1">
                {navigation.map((item) => (
                  <a
                    key={item.name}
                    href={item.href}
                    className={`${
                      item.current
                        ? 'bg-primary-100 text-primary-900 border-r-2 border-primary-500'
                        : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                    } group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-colors duration-150`}
                  >
                    <item.icon
                      className={`${
                        item.current ? 'text-primary-500' : 'text-gray-400 group-hover:text-gray-500'
                      } mr-3 flex-shrink-0 h-5 w-5`}
                    />
                    {item.name}
                  </a>
                ))}
              </nav>
            </div>
            <div className="flex-shrink-0 flex border-t border-gray-200 p-4">
              <button
                onClick={handleLogout}
                className="flex-shrink-0 w-full group block"
              >
                <div className="flex items-center">
                  <ArrowRightOnRectangleIcon className="inline-block h-5 w-5 text-gray-400 group-hover:text-gray-500 mr-3" />
                  <div className="text-sm font-medium text-gray-700 group-hover:text-gray-900">Sair do Sistema</div>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex flex-col w-0 flex-1 overflow-hidden">
        {/* Header */}
        <div className="relative z-10 flex-shrink-0 flex h-16 bg-white shadow border-b border-gray-200">
          <button
            className="px-4 border-r border-gray-200 text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500 md:hidden"
            onClick={() => setSidebarOpen(true)}
          >
            <Bars3Icon className="h-6 w-6" />
          </button>
          <div className="flex-1 px-4 flex justify-between">
            <div className="flex-1 flex">
              <div className="w-full flex md:ml-0">
                <div className="relative w-full text-gray-400 focus-within:text-gray-600">
                  <div className="absolute inset-y-0 left-0 flex items-center pointer-events-none">
                    <MagnifyingGlassIcon className="h-5 w-5" />
                  </div>
                  <input
                    className="block w-full h-full pl-8 pr-3 py-2 border-transparent text-gray-900 placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-0 focus:border-transparent"
                    placeholder="Buscar clientes, processos..."
                  />
                </div>
              </div>
            </div>
            <div className="ml-4 flex items-center md:ml-6">
              <button className="bg-white p-1 rounded-full text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500">
                <BellIcon className="h-6 w-6" />
              </button>
              <div className="ml-3 relative">
                <div className="flex items-center">
                  <div className="h-8 w-8 bg-gradient-erlene rounded-full flex items-center justify-center">
                    <span className="text-white font-medium text-sm">A</span>
                  </div>
                  <span className="ml-3 text-sm font-medium text-gray-700">Admin</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Page Content */}
        <main className="flex-1 relative overflow-y-auto focus:outline-none bg-gray-50">
          <div className="py-6">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
              {children}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;
EOF

echo "✅ AdminLayout corrigido!"

echo "📝 Verificando se todas as páginas existem..."

# Verificar se todas as páginas mencionadas existem
pages_to_check=(
    "frontend/src/pages/admin/Audiencias.js"
    "frontend/src/pages/admin/Prazos.js"
)

for page in "${pages_to_check[@]}"; do
    if [ -f "$page" ]; then
        echo "✅ $page existe"
    else
        echo "⚠️ $page não encontrado"
    fi
done

echo ""
echo "✅ CORREÇÕES APLICADAS!"
echo ""
echo "🔧 PROBLEMAS CORRIGIDOS:"
echo "   • ClockIcon importado corretamente"
echo "   • Imports organizados seguindo padrão do projeto"
echo "   • Navigation com current state corrigido"
echo "   • Links para Audiências e Prazos funcionando"
echo ""
echo "📁 ARQUIVO CORRIGIDO:"
echo "   • frontend/src/components/layout/AdminLayout/index.js"
echo ""
echo "💾 BACKUP CRIADO:"
echo "   • AdminLayout backup salvo com timestamp"
echo ""
echo "🧪 TESTE AS ROTAS:"
echo "   1. http://localhost:3000/admin"
echo "   2. http://localhost:3000/admin/audiencias"
echo "   3. http://localhost:3000/admin/prazos"
echo "   4. Clique nos links do menu lateral"
echo ""
echo "🎯 ERRO ClockIcon CORRIGIDO!"
echo ""
echo "⏭️ PRÓXIMO PASSO:"
echo "   Testar se a aplicação está funcionando sem erros"
echo "   Execute 'npm start' e verifique o console"