#!/bin/bash

# Script 02 - Criação da Estrutura do Frontend (React)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/02-create-frontend-structure.sh

echo "🚀 Iniciando criação da estrutura do Frontend..."

# Criar diretório principal do frontend
mkdir -p frontend

# Estrutura principal do React
mkdir -p frontend/public
mkdir -p frontend/src
mkdir -p frontend/build
mkdir -p frontend/node_modules

# Estrutura public/
mkdir -p frontend/public/images
mkdir -p frontend/public/icons
mkdir -p frontend/public/assets

# Estrutura src/
mkdir -p frontend/src/components
mkdir -p frontend/src/pages
mkdir -p frontend/src/services
mkdir -p frontend/src/hooks
mkdir -p frontend/src/utils
mkdir -p frontend/src/context
mkdir -p frontend/src/styles
mkdir -p frontend/src/assets
mkdir -p frontend/src/config
mkdir -p frontend/src/types
mkdir -p frontend/src/constants

# Estrutura components/
mkdir -p frontend/src/components/common
mkdir -p frontend/src/components/layout
mkdir -p frontend/src/components/forms
mkdir -p frontend/src/components/ui
mkdir -p frontend/src/components/charts
mkdir -p frontend/src/components/admin
mkdir -p frontend/src/components/portal

# Componentes comuns
mkdir -p frontend/src/components/common/Header
mkdir -p frontend/src/components/common/Sidebar
mkdir -p frontend/src/components/common/Footer
mkdir -p frontend/src/components/common/Loading
mkdir -p frontend/src/components/common/Modal
mkdir -p frontend/src/components/common/Toast
mkdir -p frontend/src/components/common/Breadcrumb
mkdir -p frontend/src/components/common/Pagination

# Componentes de layout
mkdir -p frontend/src/components/layout/AdminLayout
mkdir -p frontend/src/components/layout/PortalLayout
mkdir -p frontend/src/components/layout/AuthLayout

# Componentes de formulários
mkdir -p frontend/src/components/forms/ClientForm
mkdir -p frontend/src/components/forms/ProcessForm
mkdir -p frontend/src/components/forms/AppointmentForm
mkdir -p frontend/src/components/forms/UserForm
mkdir -p frontend/src/components/forms/PaymentForm
mkdir -p frontend/src/components/forms/DocumentForm

# Componentes UI
mkdir -p frontend/src/components/ui/Button
mkdir -p frontend/src/components/ui/Input
mkdir -p frontend/src/components/ui/Select
mkdir -p frontend/src/components/ui/Table
mkdir -p frontend/src/components/ui/Card
mkdir -p frontend/src/components/ui/Badge
mkdir -p frontend/src/components/ui/Avatar
mkdir -p frontend/src/components/ui/DatePicker
mkdir -p frontend/src/components/ui/FileUpload
mkdir -p frontend/src/components/ui/Search

# Componentes de gráficos
mkdir -p frontend/src/components/charts/Dashboard
mkdir -p frontend/src/components/charts/Financial
mkdir -p frontend/src/components/charts/Reports

# Componentes Admin
mkdir -p frontend/src/components/admin/Dashboard
mkdir -p frontend/src/components/admin/Clients
mkdir -p frontend/src/components/admin/Processes
mkdir -p frontend/src/components/admin/Appointments
mkdir -p frontend/src/components/admin/Financial
mkdir -p frontend/src/components/admin/Documents
mkdir -p frontend/src/components/admin/Users
mkdir -p frontend/src/components/admin/Reports
mkdir -p frontend/src/components/admin/Settings
mkdir -p frontend/src/components/admin/Kanban

# Componentes Portal
mkdir -p frontend/src/components/portal/Dashboard
mkdir -p frontend/src/components/portal/Processes
mkdir -p frontend/src/components/portal/Documents
mkdir -p frontend/src/components/portal/Payments
mkdir -p frontend/src/components/portal/Messages
mkdir -p frontend/src/components/portal/Profile

# Estrutura pages/
mkdir -p frontend/src/pages/auth
mkdir -p frontend/src/pages/admin
mkdir -p frontend/src/pages/portal
mkdir -p frontend/src/pages/error

# Páginas de autenticação
mkdir -p frontend/src/pages/auth/Login
mkdir -p frontend/src/pages/auth/ForgotPassword
mkdir -p frontend/src/pages/auth/ResetPassword

# Páginas administrativas
mkdir -p frontend/src/pages/admin/Dashboard
mkdir -p frontend/src/pages/admin/Clients
mkdir -p frontend/src/pages/admin/Processes
mkdir -p frontend/src/pages/admin/Appointments
mkdir -p frontend/src/pages/admin/Financial
mkdir -p frontend/src/pages/admin/Documents
mkdir -p frontend/src/pages/admin/Users
mkdir -p frontend/src/pages/admin/Reports
mkdir -p frontend/src/pages/admin/Settings
mkdir -p frontend/src/pages/admin/Integrations
mkdir -p frontend/src/pages/admin/Kanban
mkdir -p frontend/src/pages/admin/Calendar

# Sub-páginas de clientes
mkdir -p frontend/src/pages/admin/Clients/List
mkdir -p frontend/src/pages/admin/Clients/Create
mkdir -p frontend/src/pages/admin/Clients/Edit
mkdir -p frontend/src/pages/admin/Clients/View
mkdir -p frontend/src/pages/admin/Clients/Documents

# Sub-páginas de processos
mkdir -p frontend/src/pages/admin/Processes/List
mkdir -p frontend/src/pages/admin/Processes/Create
mkdir -p frontend/src/pages/admin/Processes/Edit
mkdir -p frontend/src/pages/admin/Processes/View
mkdir -p frontend/src/pages/admin/Processes/Movements

# Sub-páginas de atendimentos
mkdir -p frontend/src/pages/admin/Appointments/List
mkdir -p frontend/src/pages/admin/Appointments/Create
mkdir -p frontend/src/pages/admin/Appointments/Edit
mkdir -p frontend/src/pages/admin/Appointments/View

# Sub-páginas financeiras
mkdir -p frontend/src/pages/admin/Financial/Dashboard
mkdir -p frontend/src/pages/admin/Financial/Payments
mkdir -p frontend/src/pages/admin/Financial/Invoices
mkdir -p frontend/src/pages/admin/Financial/Reports

# Sub-páginas de configurações
mkdir -p frontend/src/pages/admin/Settings/General
mkdir -p frontend/src/pages/admin/Settings/Users
mkdir -p frontend/src/pages/admin/Settings/Permissions
mkdir -p frontend/src/pages/admin/Settings/Integrations
mkdir -p frontend/src/pages/admin/Settings/APIs

# Páginas do portal do cliente
mkdir -p frontend/src/pages/portal/Dashboard
mkdir -p frontend/src/pages/portal/Processes
mkdir -p frontend/src/pages/portal/Documents
mkdir -p frontend/src/pages/portal/Payments
mkdir -p frontend/src/pages/portal/Messages
mkdir -p frontend/src/pages/portal/Profile
mkdir -p frontend/src/pages/portal/Login

# Páginas de erro
mkdir -p frontend/src/pages/error/404
mkdir -p frontend/src/pages/error/500
mkdir -p frontend/src/pages/error/403

# Estrutura services/
mkdir -p frontend/src/services/api
mkdir -p frontend/src/services/auth
mkdir -p frontend/src/services/integrations

# Services API
mkdir -p frontend/src/services/api/clients
mkdir -p frontend/src/services/api/processes
mkdir -p frontend/src/services/api/appointments
mkdir -p frontend/src/services/api/financial
mkdir -p frontend/src/services/api/documents
mkdir -p frontend/src/services/api/users
mkdir -p frontend/src/services/api/reports
mkdir -p frontend/src/services/api/portal

# Services de integrações
mkdir -p frontend/src/services/integrations/cnj
mkdir -p frontend/src/services/integrations/escavador
mkdir -p frontend/src/services/integrations/jurisbrasil
mkdir -p frontend/src/services/integrations/google
mkdir -p frontend/src/services/integrations/microsoft
mkdir -p frontend/src/services/integrations/stripe
mkdir -p frontend/src/services/integrations/mercadopago
mkdir -p frontend/src/services/integrations/chatgpt

# Estrutura hooks/
mkdir -p frontend/src/hooks/api
mkdir -p frontend/src/hooks/auth
mkdir -p frontend/src/hooks/common

# Estrutura utils/
mkdir -p frontend/src/utils/formatters
mkdir -p frontend/src/utils/validators
mkdir -p frontend/src/utils/helpers

# Estrutura context/
mkdir -p frontend/src/context/auth
mkdir -p frontend/src/context/theme
mkdir -p frontend/src/context/notification

# Estrutura styles/
mkdir -p frontend/src/styles/components
mkdir -p frontend/src/styles/pages
mkdir -p frontend/src/styles/themes

# Estrutura assets/
mkdir -p frontend/src/assets/images
mkdir -p frontend/src/assets/icons
mkdir -p frontend/src/assets/fonts
mkdir -p frontend/src/assets/videos

# Estrutura config/
mkdir -p frontend/src/config/api
mkdir -p frontend/src/config/integrations

# Criar arquivos principais
touch frontend/package.json
touch frontend/package-lock.json
touch frontend/.env.example
touch frontend/.env.local
touch frontend/.gitignore
touch frontend/README.md
touch frontend/tailwind.config.js
touch frontend/craco.config.js

# Arquivos public/
touch frontend/public/index.html
touch frontend/public/manifest.json
touch frontend/public/robots.txt
touch frontend/public/favicon.ico

# Arquivo principal do React
touch frontend/src/index.js
touch frontend/src/App.js
touch frontend/src/App.css
touch frontend/src/index.css

# Arquivos de configuração
touch frontend/src/config/api/index.js
touch frontend/src/config/constants.js
touch frontend/src/config/routes.js

# Configurações de integrações (para as APIs)
touch frontend/src/config/integrations/cnj.js
touch frontend/src/config/integrations/escavador.js
touch frontend/src/config/integrations/jurisbrasil.js
touch frontend/src/config/integrations/google.js
touch frontend/src/config/integrations/microsoft.js
touch frontend/src/config/integrations/stripe.js
touch frontend/src/config/integrations/mercadopago.js
touch frontend/src/config/integrations/chatgpt.js

# Context providers
touch frontend/src/context/auth/AuthContext.js
touch frontend/src/context/auth/AuthProvider.js
touch frontend/src/context/theme/ThemeContext.js
touch frontend/src/context/theme/ThemeProvider.js
touch frontend/src/context/notification/NotificationContext.js
touch frontend/src/context/notification/NotificationProvider.js

# Services principais
touch frontend/src/services/api/apiClient.js
touch frontend/src/services/api/endpoints.js
touch frontend/src/services/auth/authService.js
touch frontend/src/services/auth/tokenService.js

# Services por módulo
touch frontend/src/services/api/clients/clientService.js
touch frontend/src/services/api/processes/processService.js
touch frontend/src/services/api/appointments/appointmentService.js
touch frontend/src/services/api/financial/financialService.js
touch frontend/src/services/api/documents/documentService.js
touch frontend/src/services/api/users/userService.js
touch frontend/src/services/api/reports/reportService.js
touch frontend/src/services/api/portal/portalService.js

# Hooks personalizados
touch frontend/src/hooks/auth/useAuth.js
touch frontend/src/hooks/auth/usePermissions.js
touch frontend/src/hooks/api/useApi.js
touch frontend/src/hooks/api/useClients.js
touch frontend/src/hooks/api/useProcesses.js
touch frontend/src/hooks/common/useLocalStorage.js
touch frontend/src/hooks/common/useDebounce.js
touch frontend/src/hooks/common/useModal.js

# Utils
touch frontend/src/utils/formatters/dateFormatter.js
touch frontend/src/utils/formatters/currencyFormatter.js
touch frontend/src/utils/formatters/documentFormatter.js
touch frontend/src/utils/validators/formValidators.js
touch frontend/src/utils/validators/documentValidators.js
touch frontend/src/utils/helpers/apiHelpers.js
touch frontend/src/utils/helpers/routeHelpers.js

# Estilos principais
touch frontend/src/styles/globals.css
touch frontend/src/styles/variables.css
touch frontend/src/styles/components.css
touch frontend/src/styles/themes/light.css
touch frontend/src/styles/themes/dark.css

# Componentes principais - Layout
touch frontend/src/components/layout/AdminLayout/index.js
touch frontend/src/components/layout/AdminLayout/AdminLayout.css
touch frontend/src/components/layout/PortalLayout/index.js
touch frontend/src/components/layout/PortalLayout/PortalLayout.css
touch frontend/src/components/layout/AuthLayout/index.js
touch frontend/src/components/layout/AuthLayout/AuthLayout.css

# Componentes comuns
touch frontend/src/components/common/Header/index.js
touch frontend/src/components/common/Header/Header.css
touch frontend/src/components/common/Sidebar/index.js
touch frontend/src/components/common/Sidebar/Sidebar.css
touch frontend/src/components/common/Loading/index.js
touch frontend/src/components/common/Loading/Loading.css
touch frontend/src/components/common/Modal/index.js
touch frontend/src/components/common/Modal/Modal.css

# Páginas principais
touch frontend/src/pages/auth/Login/index.js
touch frontend/src/pages/auth/Login/Login.css
touch frontend/src/pages/admin/Dashboard/index.js
touch frontend/src/pages/admin/Dashboard/Dashboard.css
touch frontend/src/pages/portal/Dashboard/index.js
touch frontend/src/pages/portal/Dashboard/Dashboard.css

echo "✅ Estrutura do Frontend criada com sucesso!"
echo "📁 Total de diretórios: $(find frontend -type d | wc -l)"
echo "📄 Total de arquivos: $(find frontend -type f | wc -l)"
echo ""
echo "⏭️  Próximo: Execute o script 03-create-mobile-structure.sh"