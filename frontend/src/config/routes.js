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
