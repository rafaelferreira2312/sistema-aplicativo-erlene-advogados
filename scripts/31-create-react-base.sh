#!/bin/bash

# Script 31 - Estrutura Base React (App.js, routing, layout)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/31-create-react-base.sh

echo "⚛️ Criando estrutura base do React..."

# src/index.js - Entry point
cat > frontend/src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from 'react-query';
import { ReactQueryDevtools } from 'react-query/devtools';
import { Toaster } from 'react-hot-toast';

import App from './App';
import { AuthProvider } from './context/auth/AuthProvider';
import { ThemeProvider } from './context/theme/ThemeProvider';
import { NotificationProvider } from './context/notification/NotificationProvider';

import './styles/globals.css';
import './index.css';

// Configuração do React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 2,
      refetchOnWindowFocus: false,
      staleTime: 5 * 60 * 1000, // 5 minutos
      cacheTime: 10 * 60 * 1000, // 10 minutos
    },
    mutations: {
      retry: 1,
    },
  },
});

const root = ReactDOM.createRoot(document.getElementById('root'));

root.render(
  <React.StrictMode>
    <BrowserRouter>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider>
          <AuthProvider>
            <NotificationProvider>
              <App />
              <Toaster
                position="top-right"
                toastOptions={{
                  duration: 4000,
                  style: {
                    background: '#fff',
                    color: '#212529',
                    border: '1px solid #dee2e6',
                    borderRadius: '8px',
                    boxShadow: '0 4px 20px rgba(139, 21, 56, 0.1)',
                  },
                  success: {
                    iconTheme: {
                      primary: '#28a745',
                      secondary: '#fff',
                    },
                  },
                  error: {
                    iconTheme: {
                      primary: '#dc3545',
                      secondary: '#fff',
                    },
                  },
                }}
              />
            </NotificationProvider>
          </AuthProvider>
        </ThemeProvider>
        <ReactQueryDevtools initialIsOpen={false} />
      </QueryClientProvider>
    </BrowserRouter>
  </React.StrictMode>
);
EOF

# src/App.js - Componente principal
cat > frontend/src/App.js << 'EOF'
import React, { Suspense } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './hooks/auth/useAuth';

// Layouts
import AuthLayout from './components/layout/AuthLayout';
import AdminLayout from './components/layout/AdminLayout';
import PortalLayout from './components/layout/PortalLayout';

// Components
import Loading from './components/common/Loading';
import PrivateRoute from './components/auth/PrivateRoute';
import PublicRoute from './components/auth/PublicRoute';

// Lazy loading das páginas
const Login = React.lazy(() => import('./pages/auth/Login'));
const AdminDashboard = React.lazy(() => import('./pages/admin/Dashboard'));
const Clients = React.lazy(() => import('./pages/admin/Clients'));
const Processes = React.lazy(() => import('./pages/admin/Processes'));
const Appointments = React.lazy(() => import('./pages/admin/Appointments'));
const Financial = React.lazy(() => import('./pages/admin/Financial'));
const Documents = React.lazy(() => import('./pages/admin/Documents'));
const Kanban = React.lazy(() => import('./pages/admin/Kanban'));
const Reports = React.lazy(() => import('./pages/admin/Reports'));
const Users = React.lazy(() => import('./pages/admin/Users'));
const Settings = React.lazy(() => import('./pages/admin/Settings'));

// Portal do Cliente
const PortalLogin = React.lazy(() => import('./pages/portal/Login'));
const PortalDashboard = React.lazy(() => import('./pages/portal/Dashboard'));
const PortalProcesses = React.lazy(() => import('./pages/portal/Processes'));
const PortalDocuments = React.lazy(() => import('./pages/portal/Documents'));
const PortalPayments = React.lazy(() => import('./pages/portal/Payments'));
const PortalMessages = React.lazy(() => import('./pages/portal/Messages'));

// Error Pages
const NotFound = React.lazy(() => import('./pages/errors/NotFound'));
const Unauthorized = React.lazy(() => import('./pages/errors/Unauthorized'));

function App() {
  const { isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-erlene flex items-center justify-center">
        <Loading size="large" color="white" />
      </div>
    );
  }

  return (
    <div className="App">
      <Suspense fallback={<Loading size="large" />}>
        <Routes>
          {/* Rotas Públicas */}
          <Route path="/login" element={
            <PublicRoute>
              <AuthLayout>
                <Login />
              </AuthLayout>
            </PublicRoute>
          } />

          {/* Portal do Cliente */}
          <Route path="/portal/login" element={
            <PublicRoute>
              <AuthLayout>
                <PortalLogin />
              </AuthLayout>
            </PublicRoute>
          } />

          <Route path="/portal/*" element={
            <PrivateRoute allowedRoles={['cliente']}>
              <PortalLayout>
                <Routes>
                  <Route index element={<PortalDashboard />} />
                  <Route path="processos" element={<PortalProcesses />} />
                  <Route path="documentos" element={<PortalDocuments />} />
                  <Route path="pagamentos" element={<PortalPayments />} />
                  <Route path="mensagens" element={<PortalMessages />} />
                  <Route path="*" element={<NotFound />} />
                </Routes>
              </PortalLayout>
            </PrivateRoute>
          } />

          {/* Sistema Administrativo */}
          <Route path="/admin/*" element={
            <PrivateRoute allowedRoles={['admin_geral', 'admin_unidade', 'advogado', 'secretario', 'financeiro']}>
              <AdminLayout>
                <Routes>
                  <Route index element={<AdminDashboard />} />
                  <Route path="clientes" element={<Clients />} />
                  <Route path="processos" element={<Processes />} />
                  <Route path="atendimentos" element={<Appointments />} />
                  <Route path="financeiro" element={<Financial />} />
                  <Route path="documentos" element={<Documents />} />
                  <Route path="kanban" element={<Kanban />} />
                  <Route path="relatorios" element={<Reports />} />
                  <Route path="usuarios" element={<Users />} />
                  <Route path="configuracoes" element={<Settings />} />
                  <Route path="*" element={<NotFound />} />
                </Routes>
              </AdminLayout>
            </PrivateRoute>
          } />

          {/* Rotas de Erro */}
          <Route path="/unauthorized" element={<Unauthorized />} />
          <Route path="/404" element={<NotFound />} />

          {/* Redirecionamentos */}
          <Route path="/" element={<Navigate to="/admin" replace />} />
          <Route path="*" element={<Navigate to="/404" replace />} />
        </Routes>
      </Suspense>
    </div>
  );
}

export default App;
EOF

# src/index.css - Estilos base
cat > frontend/src/index.css << 'EOF'
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';
@import './styles/variables.css';
@import './styles/components.css';

/* Reset e base styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  font-family: 'Inter', ui-sans-serif, system-ui, -apple-system, sans-serif;
  line-height: 1.6;
  color: theme('colors.gray.700');
  scroll-behavior: smooth;
}

body {
  background-color: theme('colors.gray.50');
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  overflow-x: hidden;
}

#root {
  min-height: 100vh;
}

/* Scrollbar customizada */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: theme('colors.gray.100');
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: theme('colors.primary.800');
  border-radius: 4px;
  transition: background-color 0.2s ease;
}

::-webkit-scrollbar-thumb:hover {
  background: theme('colors.primary.900');
}

/* Firefox scrollbar */
* {
  scrollbar-width: thin;
  scrollbar-color: theme('colors.primary.800') theme('colors.gray.100');
}

/* Focus outline personalizado */
*:focus {
  outline: 2px solid theme('colors.primary.500');
  outline-offset: 2px;
}

/* Transições suaves para elementos interativos */
button, 
input, 
select, 
textarea, 
a {
  transition: all 0.2s ease-in-out;
}

/* Utility classes para loading states */
.animate-pulse-slow {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

.animate-fade-in {
  animation: fadeIn 0.5s ease-in-out;
}

.animate-slide-up {
  animation: slideUp 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

/* Print styles */
@media print {
  body {
    background: white !important;
    color: black !important;
  }
  
  .no-print {
    display: none !important;
  }
  
  .print-break {
    page-break-before: always;
  }
}

/* High contrast mode support */
@media (prefers-contrast: high) {
  .shadow-erlene {
    box-shadow: 0 0 0 2px theme('colors.primary.800');
  }
}

/* Reduced motion support */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}

/* Loading spinner global */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(2px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

/* Error boundary styles */
.error-boundary {
  padding: 2rem;
  text-align: center;
  background: white;
  border-radius: 8px;
  box-shadow: theme('boxShadow.erlene');
  margin: 2rem;
}

.error-boundary h2 {
  color: theme('colors.danger.600');
  margin-bottom: 1rem;
}

/* Tooltip personalizado */
.tooltip {
  position: relative;
  display: inline-block;
}

.tooltip::before {
  content: attr(data-tooltip);
  position: absolute;
  bottom: 125%;
  left: 50%;
  transform: translateX(-50%);
  background: theme('colors.gray.900');
  color: white;
  padding: 0.5rem 0.75rem;
  border-radius: 4px;
  font-size: 0.875rem;
  white-space: nowrap;
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.2s, visibility 0.2s;
  z-index: 1000;
}

.tooltip:hover::before {
  opacity: 1;
  visibility: visible;
}

/* Form validation styles */
.form-error {
  color: theme('colors.danger.600');
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.form-success {
  color: theme('colors.success.600');
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

/* Table responsive */
.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.table-responsive table {
  min-width: 100%;
}

/* Card hover effects */
.card-hover {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card-hover:hover {
  transform: translateY(-2px);
  box-shadow: theme('boxShadow.erlene-lg');
}

/* Mobile optimizations */
@media (max-width: 768px) {
  .mobile-hide {
    display: none !important;
  }
  
  .mobile-full {
    width: 100% !important;
  }
  
  .mobile-stack {
    flex-direction: column !important;
  }
}
EOF

# src/config/routes.js - Configuração de rotas
cat > frontend/src/config/routes.js << 'EOF'
// Configuração centralizada de rotas
export const ROUTES = {
  // Autenticação
  LOGIN: '/login',
  LOGOUT: '/logout',
  
  // Portal do Cliente
  PORTAL: {
    LOGIN: '/portal/login',
    DASHBOARD: '/portal',
    PROCESSES: '/portal/processos',
    DOCUMENTS: '/portal/documentos',
    PAYMENTS: '/portal/pagamentos',
    MESSAGES: '/portal/mensagens',
    PROFILE: '/portal/perfil',
  },
  
  // Sistema Administrativo
  ADMIN: {
    DASHBOARD: '/admin',
    CLIENTS: '/admin/clientes',
    CLIENT_DETAIL: '/admin/clientes/:id',
    CLIENT_NEW: '/admin/clientes/novo',
    
    PROCESSES: '/admin/processos',
    PROCESS_DETAIL: '/admin/processos/:id',
    PROCESS_NEW: '/admin/processos/novo',
    
    APPOINTMENTS: '/admin/atendimentos',
    APPOINTMENT_DETAIL: '/admin/atendimentos/:id',
    APPOINTMENT_NEW: '/admin/atendimentos/novo',
    
    FINANCIAL: '/admin/financeiro',
    FINANCIAL_RECEIPTS: '/admin/financeiro/receitas',
    FINANCIAL_EXPENSES: '/admin/financeiro/despesas',
    FINANCIAL_REPORTS: '/admin/financeiro/relatorios',
    
    DOCUMENTS: '/admin/documentos',
    DOCUMENT_CLIENT: '/admin/documentos/cliente/:clientId',
    
    KANBAN: '/admin/kanban',
    KANBAN_PROCESSES: '/admin/kanban/processos',
    KANBAN_TASKS: '/admin/kanban/tarefas',
    
    REPORTS: '/admin/relatorios',
    REPORTS_CLIENTS: '/admin/relatorios/clientes',
    REPORTS_PROCESSES: '/admin/relatorios/processos',
    REPORTS_FINANCIAL: '/admin/relatorios/financeiro',
    REPORTS_PRODUCTIVITY: '/admin/relatorios/produtividade',
    
    USERS: '/admin/usuarios',
    USER_DETAIL: '/admin/usuarios/:id',
    USER_NEW: '/admin/usuarios/novo',
    
    SETTINGS: '/admin/configuracoes',
    SETTINGS_GENERAL: '/admin/configuracoes/geral',
    SETTINGS_INTEGRATIONS: '/admin/configuracoes/integracoes',
    SETTINGS_PAYMENTS: '/admin/configuracoes/pagamentos',
    SETTINGS_NOTIFICATIONS: '/admin/configuracoes/notificacoes',
  },
  
  // Páginas de Erro
  ERROR: {
    NOT_FOUND: '/404',
    UNAUTHORIZED: '/unauthorized',
    SERVER_ERROR: '/500',
  },
};

// Breadcrumb mapping
export const BREADCRUMBS = {
  [ROUTES.ADMIN.DASHBOARD]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD }
  ],
  [ROUTES.ADMIN.CLIENTS]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD },
    { label: 'Clientes', path: ROUTES.ADMIN.CLIENTS }
  ],
  [ROUTES.ADMIN.PROCESSES]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD },
    { label: 'Processos', path: ROUTES.ADMIN.PROCESSES }
  ],
  [ROUTES.ADMIN.APPOINTMENTS]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD },
    { label: 'Atendimentos', path: ROUTES.ADMIN.APPOINTMENTS }
  ],
  [ROUTES.ADMIN.FINANCIAL]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD },
    { label: 'Financeiro', path: ROUTES.ADMIN.FINANCIAL }
  ],
  [ROUTES.ADMIN.DOCUMENTS]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD },
    { label: 'Documentos', path: ROUTES.ADMIN.DOCUMENTS }
  ],
  [ROUTES.ADMIN.KANBAN]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD },
    { label: 'Kanban', path: ROUTES.ADMIN.KANBAN }
  ],
  [ROUTES.ADMIN.REPORTS]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD },
    { label: 'Relatórios', path: ROUTES.ADMIN.REPORTS }
  ],
  [ROUTES.ADMIN.USERS]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD },
    { label: 'Usuários', path: ROUTES.ADMIN.USERS }
  ],
  [ROUTES.ADMIN.SETTINGS]: [
    { label: 'Dashboard', path: ROUTES.ADMIN.DASHBOARD },
    { label: 'Configurações', path: ROUTES.ADMIN.SETTINGS }
  ],
};

// Menu navigation items
export const ADMIN_MENU_ITEMS = [
  {
    label: 'Dashboard',
    path: ROUTES.ADMIN.DASHBOARD,
    icon: 'HomeIcon',
    permission: 'dashboard.view',
  },
  {
    label: 'Clientes',
    path: ROUTES.ADMIN.CLIENTS,
    icon: 'UsersIcon',
    permission: 'clients.view',
    submenu: [
      { label: 'Lista de Clientes', path: ROUTES.ADMIN.CLIENTS },
      { label: 'Novo Cliente', path: ROUTES.ADMIN.CLIENT_NEW },
    ],
  },
  {
    label: 'Processos',
    path: ROUTES.ADMIN.PROCESSES,
    icon: 'ScaleIcon',
    permission: 'processes.view',
    submenu: [
      { label: 'Lista de Processos', path: ROUTES.ADMIN.PROCESSES },
      { label: 'Novo Processo', path: ROUTES.ADMIN.PROCESS_NEW },
    ],
  },
  {
    label: 'Atendimentos',
    path: ROUTES.ADMIN.APPOINTMENTS,
    icon: 'CalendarIcon',
    permission: 'appointments.view',
  },
  {
    label: 'Financeiro',
    path: ROUTES.ADMIN.FINANCIAL,
    icon: 'CurrencyDollarIcon',
    permission: 'financial.view',
    submenu: [
      { label: 'Receitas', path: ROUTES.ADMIN.FINANCIAL_RECEIPTS },
      { label: 'Despesas', path: ROUTES.ADMIN.FINANCIAL_EXPENSES },
      { label: 'Relatórios', path: ROUTES.ADMIN.FINANCIAL_REPORTS },
    ],
  },
  {
    label: 'Documentos',
    path: ROUTES.ADMIN.DOCUMENTS,
    icon: 'DocumentIcon',
    permission: 'documents.view',
  },
  {
    label: 'Kanban',
    path: ROUTES.ADMIN.KANBAN,
    icon: 'ViewColumnsIcon',
    permission: 'kanban.view',
  },
  {
    label: 'Relatórios',
    path: ROUTES.ADMIN.REPORTS,
    icon: 'ChartBarIcon',
    permission: 'reports.view',
    submenu: [
      { label: 'Clientes', path: ROUTES.ADMIN.REPORTS_CLIENTS },
      { label: 'Processos', path: ROUTES.ADMIN.REPORTS_PROCESSES },
      { label: 'Financeiro', path: ROUTES.ADMIN.REPORTS_FINANCIAL },
      { label: 'Produtividade', path: ROUTES.ADMIN.REPORTS_PRODUCTIVITY },
    ],
  },
  {
    label: 'Usuários',
    path: ROUTES.ADMIN.USERS,
    icon: 'UserGroupIcon',
    permission: 'users.view',
  },
  {
    label: 'Configurações',
    path: ROUTES.ADMIN.SETTINGS,
    icon: 'CogIcon',
    permission: 'settings.view',
  },
];

export const PORTAL_MENU_ITEMS = [
  {
    label: 'Dashboard',
    path: ROUTES.PORTAL.DASHBOARD,
    icon: 'HomeIcon',
  },
  {
    label: 'Meus Processos',
    path: ROUTES.PORTAL.PROCESSES,
    icon: 'ScaleIcon',
  },
  {
    label: 'Documentos',
    path: ROUTES.PORTAL.DOCUMENTS,
    icon: 'DocumentIcon',
  },
  {
    label: 'Pagamentos',
    path: ROUTES.PORTAL.PAYMENTS,
    icon: 'CreditCardIcon',
  },
  {
    label: 'Mensagens',
    path: ROUTES.PORTAL.MESSAGES,
    icon: 'ChatBubbleLeftIcon',
  },
];

// Função helper para construir URLs dinâmicas
export const buildRoute = (route, params = {}) => {
  let builtRoute = route;
  
  Object.entries(params).forEach(([key, value]) => {
    builtRoute = builtRoute.replace(`:${key}`, value);
  });
  
  return builtRoute;
};

// Função helper para verificar se a rota atual está ativa
export const isRouteActive = (currentPath, targetPath) => {
  if (targetPath === ROUTES.ADMIN.DASHBOARD) {
    return currentPath === targetPath;
  }
  
  return currentPath.startsWith(targetPath);
};
EOF

# src/config/constants.js - Constantes da aplicação
cat > frontend/src/config/constants.js << 'EOF'
// Configurações da aplicação
export const APP_CONFIG = {
  NAME: 'Sistema Erlene Advogados',
  VERSION: '1.0.0',
  DESCRIPTION: 'Sistema de Gestão Jurídica',
  AUTHOR: 'Vancouver Tec',
  
  // URLs
  API_BASE_URL: process.env.REACT_APP_API_URL || 'https://localhost:8443/api',
  APP_URL: process.env.REACT_APP_URL || 'https://localhost:3000',
  
  // Limites
  MAX_FILE_SIZE: 50 * 1024 * 1024, // 50MB
  MAX_FILES_PER_UPLOAD: 10,
  ITEMS_PER_PAGE: 20,
  
  // Timeouts
  REQUEST_TIMEOUT: 30000, // 30 segundos
  TOKEN_REFRESH_TIMEOUT: 5 * 60 * 1000, // 5 minutos
  
  // Storage keys
  STORAGE_KEYS: {
    TOKEN: 'erlene_token',
    REFRESH_TOKEN: 'erlene_refresh_token',
    USER: 'erlene_user',
    THEME: 'erlene_theme',
    SIDEBAR_COLLAPSED: 'erlene_sidebar_collapsed',
  },
};

// Tipos de usuário
export const USER_TYPES = {
  ADMIN_GERAL: 'admin_geral',
  ADMIN_UNIDADE: 'admin_unidade',
  ADVOGADO: 'advogado',
  SECRETARIO: 'secretario',
  FINANCEIRO: 'financeiro',
  CONSULTA: 'consulta',
  CLIENTE: 'cliente',
};

// Labels dos tipos de usuário
export const USER_TYPE_LABELS = {
  [USER_TYPES.ADMIN_GERAL]: 'Administrador Geral',
  [USER_TYPES.ADMIN_UNIDADE]: 'Administrador da Unidade',
  [USER_TYPES.ADVOGADO]: 'Advogado',
  [USER_TYPES.SECRETARIO]: 'Secretário(a)',
  [USER_TYPES.FINANCEIRO]: 'Financeiro',
  [USER_TYPES.CONSULTA]: 'Consulta',
  [USER_TYPES.CLIENTE]: 'Cliente',
};

// Status de processos
export const PROCESS_STATUS = {
  DISTRIBUIDO: 'distribuido',
  EM_ANDAMENTO: 'em_andamento',
  AUDIENCIA_MARCADA: 'audiencia_marcada',
  SENTENCA: 'sentenca',
  RECURSO: 'recurso',
  TRANSITADO_JULGADO: 'transitado_julgado',
  ARQUIVADO: 'arquivado',
  SUSPENSO: 'suspenso',
};

// Labels dos status de processos
export const PROCESS_STATUS_LABELS = {
  [PROCESS_STATUS.DISTRIBUIDO]: 'Distribuído',
  [PROCESS_STATUS.EM_ANDAMENTO]: 'Em Andamento',
  [PROCESS_STATUS.AUDIENCIA_MARCADA]: 'Audiência Marcada',
  [PROCESS_STATUS.SENTENCA]: 'Sentença',
  [PROCESS_STATUS.RECURSO]: 'Recurso',
  [PROCESS_STATUS.TRANSITADO_JULGADO]: 'Transitado em Julgado',
  [PROCESS_STATUS.ARQUIVADO]: 'Arquivado',
  [PROCESS_STATUS.SUSPENSO]: 'Suspenso',
};

// Cores dos status de processos
export const PROCESS_STATUS_COLORS = {
  [PROCESS_STATUS.DISTRIBUIDO]: 'bg-blue-100 text-blue-800',
  [PROCESS_STATUS.EM_ANDAMENTO]: 'bg-yellow-100 text-yellow-800',
  [PROCESS_STATUS.AUDIENCIA_MARCADA]: 'bg-purple-100 text-purple-800',
  [PROCESS_STATUS.SENTENCA]: 'bg-orange-100 text-orange-800',
  [PROCESS_STATUS.RECURSO]: 'bg-indigo-100 text-indigo-800',
  [PROCESS_STATUS.TRANSITADO_JULGADO]: 'bg-green-100 text-green-800',
  [PROCESS_STATUS.ARQUIVADO]: 'bg-gray-100 text-gray-800',
  [PROCESS_STATUS.SUSPENSO]: 'bg-red-100 text-red-800',
};

// Tipos de atendimento
export const APPOINTMENT_TYPES = {
  PRESENCIAL: 'presencial',
  ONLINE: 'online',
  TELEFONE: 'telefone',
};

// Labels dos tipos de atendimento
export const APPOINTMENT_TYPE_LABELS = {
  [APPOINTMENT_TYPES.PRESENCIAL]: 'Presencial',
  [APPOINTMENT_TYPES.ONLINE]: 'Online',
  [APPOINTMENT_TYPES.TELEFONE]: 'Telefone',
};

// Status de atendimentos
export const APPOINTMENT_STATUS = {
  AGENDADO: 'agendado',
  EM_ANDAMENTO: 'em_andamento',
  CONCLUIDO: 'concluido',
  CANCELADO: 'cancelado',
  REMARCADO: 'remarcado',
};

// Labels dos status de atendimentos
export const APPOINTMENT_STATUS_LABELS = {
  [APPOINTMENT_STATUS.AGENDADO]: 'Agendado',
  [APPOINTMENT_STATUS.EM_ANDAMENTO]: 'Em Andamento',
  [APPOINTMENT_STATUS.CONCLUIDO]: 'Concluído',
  [APPOINTMENT_STATUS.CANCELADO]: 'Cancelado',
  [APPOINTMENT_STATUS.REMARCADO]: 'Remarcado',
};

// Tipos de documento aceitos
export const DOCUMENT_TYPES = {
  PDF: '.pdf',
  DOC: '.doc,.docx',
  XLS: '.xls,.xlsx',
  IMAGE: '.jpg,.jpeg,.png,.gif,.webp',
  AUDIO: '.mp3,.wav,.m4a,.ogg',
  VIDEO: '.mp4,.avi,.mov,.wmv,.webm',
};

// Mensagens de validação
export const VALIDATION_MESSAGES = {
  REQUIRED: 'Este campo é obrigatório',
  INVALID_EMAIL: 'E-mail inválido',
  INVALID_CPF: 'CPF inválido',
  INVALID_CNPJ: 'CNPJ inválido',
  INVALID_PHONE: 'Telefone inválido',
  MIN_LENGTH: (min) => `Mínimo de ${min} caracteres`,
  MAX_LENGTH: (max) => `Máximo de ${max} caracteres`,
  PASSWORD_WEAK: 'Senha deve ter pelo menos 8 caracteres, com maiúsculas, minúsculas e números',
  PASSWORDS_DONT_MATCH: 'Senhas não conferem',
  INVALID_DATE: 'Data inválida',
  FUTURE_DATE_NOT_ALLOWED: 'Data futura não permitida',
  PAST_DATE_NOT_ALLOWED: 'Data passada não permitida',
  FILE_TOO_LARGE: 'Arquivo muito grande',
  INVALID_FILE_TYPE: 'Tipo de arquivo não permitido',
};
EOF