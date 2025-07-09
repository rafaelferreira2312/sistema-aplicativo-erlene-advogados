#!/bin/bash

# Script 03 - Criação da Estrutura do Mobile (React Native)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/03-create-mobile-structure.sh (executado da raiz do projeto)

echo "🚀 Iniciando criação da estrutura do Mobile..."

# Criar diretório principal do mobile
mkdir -p mobile

# Estrutura principal do React Native
mkdir -p mobile/src
mkdir -p mobile/android
mkdir -p mobile/ios
mkdir -p mobile/assets
mkdir -p mobile/node_modules
mkdir -p mobile/.expo

# Estrutura src/
mkdir -p mobile/src/components
mkdir -p mobile/src/screens
mkdir -p mobile/src/navigation
mkdir -p mobile/src/services
mkdir -p mobile/src/hooks
mkdir -p mobile/src/utils
mkdir -p mobile/src/context
mkdir -p mobile/src/styles
mkdir -p mobile/src/config
mkdir -p mobile/src/constants
mkdir -p mobile/src/types
mkdir -p mobile/src/store

# Estrutura components/
mkdir -p mobile/src/components/common
mkdir -p mobile/src/components/forms
mkdir -p mobile/src/components/ui
mkdir -p mobile/src/components/layout
mkdir -p mobile/src/components/admin
mkdir -p mobile/src/components/client

# Componentes comuns
mkdir -p mobile/src/components/common/Header
mkdir -p mobile/src/components/common/TabBar
mkdir -p mobile/src/components/common/Loading
mkdir -p mobile/src/components/common/Modal
mkdir -p mobile/src/components/common/Toast
mkdir -p mobile/src/components/common/Card
mkdir -p mobile/src/components/common/Avatar
mkdir -p mobile/src/components/common/Badge

# Componentes de formulários
mkdir -p mobile/src/components/forms/LoginForm
mkdir -p mobile/src/components/forms/ClientForm
mkdir -p mobile/src/components/forms/ProcessForm
mkdir -p mobile/src/components/forms/AppointmentForm
mkdir -p mobile/src/components/forms/DocumentForm

# Componentes UI
mkdir -p mobile/src/components/ui/Button
mkdir -p mobile/src/components/ui/Input
mkdir -p mobile/src/components/ui/Select
mkdir -p mobile/src/components/ui/DatePicker
mkdir -p mobile/src/components/ui/FileUpload
mkdir -p mobile/src/components/ui/Search
mkdir -p mobile/src/components/ui/Camera
mkdir -p mobile/src/components/ui/AudioRecorder
mkdir -p mobile/src/components/ui/Signature

# Componentes de layout
mkdir -p mobile/src/components/layout/Container
mkdir -p mobile/src/components/layout/SafeArea
mkdir -p mobile/src/components/layout/KeyboardAvoid

# Componentes Admin
mkdir -p mobile/src/components/admin/Dashboard
mkdir -p mobile/src/components/admin/ProcessList
mkdir -p mobile/src/components/admin/ClientList
mkdir -p mobile/src/components/admin/AppointmentList
mkdir -p mobile/src/components/admin/DocumentViewer
mkdir -p mobile/src/components/admin/KanbanBoard
mkdir -p mobile/src/components/admin/Calendar
mkdir -p mobile/src/components/admin/Chat

# Componentes Client
mkdir -p mobile/src/components/client/Dashboard
mkdir -p mobile/src/components/client/ProcessView
mkdir -p mobile/src/components/client/DocumentView
mkdir -p mobile/src/components/client/PaymentView
mkdir -p mobile/src/components/client/MessageView

# Estrutura screens/
mkdir -p mobile/src/screens/auth
mkdir -p mobile/src/screens/admin
mkdir -p mobile/src/screens/client
mkdir -p mobile/src/screens/shared

# Telas de autenticação
mkdir -p mobile/src/screens/auth/Login
mkdir -p mobile/src/screens/auth/ForgotPassword
mkdir -p mobile/src/screens/auth/BiometricLogin

# Telas administrativas
mkdir -p mobile/src/screens/admin/Dashboard
mkdir -p mobile/src/screens/admin/ProcessList
mkdir -p mobile/src/screens/admin/ProcessDetail
mkdir -p mobile/src/screens/admin/ClientList
mkdir -p mobile/src/screens/admin/ClientDetail
mkdir -p mobile/src/screens/admin/AppointmentList
mkdir -p mobile/src/screens/admin/AppointmentDetail
mkdir -p mobile/src/screens/admin/DocumentList
mkdir -p mobile/src/screens/admin/DocumentViewer
mkdir -p mobile/src/screens/admin/KanbanBoard
mkdir -p mobile/src/screens/admin/Calendar
mkdir -p mobile/src/screens/admin/Chat
mkdir -p mobile/src/screens/admin/Profile
mkdir -p mobile/src/screens/admin/Settings
mkdir -p mobile/src/screens/admin/Notifications

# Telas do cliente
mkdir -p mobile/src/screens/client/Dashboard
mkdir -p mobile/src/screens/client/ProcessList
mkdir -p mobile/src/screens/client/ProcessDetail
mkdir -p mobile/src/screens/client/DocumentList
mkdir -p mobile/src/screens/client/DocumentViewer
mkdir -p mobile/src/screens/client/PaymentList
mkdir -p mobile/src/screens/client/PaymentDetail
mkdir -p mobile/src/screens/client/MessageList
mkdir -p mobile/src/screens/client/Chat
mkdir -p mobile/src/screens/client/Profile
mkdir -p mobile/src/screens/client/Appointments

# Telas compartilhadas
mkdir -p mobile/src/screens/shared/Camera
mkdir -p mobile/src/screens/shared/DocumentPreview
mkdir -p mobile/src/screens/shared/AudioRecorder
mkdir -p mobile/src/screens/shared/VideoCall
mkdir -p mobile/src/screens/shared/WebView

# Estrutura navigation/
mkdir -p mobile/src/navigation/stacks
mkdir -p mobile/src/navigation/tabs

# Estrutura services/
mkdir -p mobile/src/services/api
mkdir -p mobile/src/services/auth
mkdir -p mobile/src/services/storage
mkdir -p mobile/src/services/notification
mkdir -p mobile/src/services/biometric
mkdir -p mobile/src/services/camera
mkdir -p mobile/src/services/integrations

# Services API
mkdir -p mobile/src/services/api/clients
mkdir -p mobile/src/services/api/processes
mkdir -p mobile/src/services/api/appointments
mkdir -p mobile/src/services/api/documents
mkdir -p mobile/src/services/api/financial
mkdir -p mobile/src/services/api/portal

# Services de integrações
mkdir -p mobile/src/services/integrations/cnj
mkdir -p mobile/src/services/integrations/google
mkdir -p mobile/src/services/integrations/stripe
mkdir -p mobile/src/services/integrations/mercadopago

# Estrutura hooks/
mkdir -p mobile/src/hooks/api
mkdir -p mobile/src/hooks/auth
mkdir -p mobile/src/hooks/storage
mkdir -p mobile/src/hooks/navigation
mkdir -p mobile/src/hooks/device

# Estrutura utils/
mkdir -p mobile/src/utils/formatters
mkdir -p mobile/src/utils/validators
mkdir -p mobile/src/utils/helpers
mkdir -p mobile/src/utils/permissions

# Estrutura context/
mkdir -p mobile/src/context/auth
mkdir -p mobile/src/context/theme
mkdir -p mobile/src/context/notification
mkdir -p mobile/src/context/offline

# Estrutura store/
mkdir -p mobile/src/store/slices
mkdir -p mobile/src/store/middleware

# Estrutura styles/
mkdir -p mobile/src/styles/themes
mkdir -p mobile/src/styles/components

# Estrutura config/
mkdir -p mobile/src/config/api
mkdir -p mobile/src/config/integrations

# Estrutura assets/
mkdir -p mobile/assets/images
mkdir -p mobile/assets/icons
mkdir -p mobile/assets/fonts
mkdir -p mobile/assets/splash
mkdir -p mobile/assets/sounds

# Criar arquivos principais
touch mobile/package.json
touch mobile/app.json
touch mobile/App.js
touch mobile/app.config.js
touch mobile/babel.config.js
touch mobile/metro.config.js
touch mobile/.env.example
touch mobile/.env
touch mobile/.gitignore
touch mobile/README.md

# Arquivos Expo
touch mobile/eas.json
touch mobile/expo-env.d.ts

# Arquivo principal do app
touch mobile/src/App.js
touch mobile/src/index.js

# Arquivos de configuração
touch mobile/src/config/api/index.js
touch mobile/src/config/constants.js
touch mobile/src/config/env.js

# Configurações de integrações
touch mobile/src/config/integrations/cnj.js
touch mobile/src/config/integrations/google.js
touch mobile/src/config/integrations/stripe.js
touch mobile/src/config/integrations/mercadopago.js

# Navigation
touch mobile/src/navigation/AppNavigator.js
touch mobile/src/navigation/AuthNavigator.js
touch mobile/src/navigation/AdminNavigator.js
touch mobile/src/navigation/ClientNavigator.js
touch mobile/src/navigation/stacks/AdminStack.js
touch mobile/src/navigation/stacks/ClientStack.js
touch mobile/src/navigation/tabs/AdminTabs.js
touch mobile/src/navigation/tabs/ClientTabs.js

# Context providers
touch mobile/src/context/auth/AuthContext.js
touch mobile/src/context/auth/AuthProvider.js
touch mobile/src/context/theme/ThemeContext.js
touch mobile/src/context/theme/ThemeProvider.js
touch mobile/src/context/notification/NotificationContext.js
touch mobile/src/context/notification/NotificationProvider.js
touch mobile/src/context/offline/OfflineContext.js
touch mobile/src/context/offline/OfflineProvider.js

# Services principais
touch mobile/src/services/api/apiClient.js
touch mobile/src/services/api/endpoints.js
touch mobile/src/services/auth/authService.js
touch mobile/src/services/auth/tokenService.js
touch mobile/src/services/storage/secureStorage.js
touch mobile/src/services/storage/asyncStorage.js
touch mobile/src/services/notification/pushNotification.js
touch mobile/src/services/biometric/biometricAuth.js
touch mobile/src/services/camera/cameraService.js

# Services por módulo
touch mobile/src/services/api/clients/clientService.js
touch mobile/src/services/api/processes/processService.js
touch mobile/src/services/api/appointments/appointmentService.js
touch mobile/src/services/api/documents/documentService.js
touch mobile/src/services/api/financial/financialService.js
touch mobile/src/services/api/portal/portalService.js

# Hooks personalizados
touch mobile/src/hooks/auth/useAuth.js
touch mobile/src/hooks/auth/useBiometric.js
touch mobile/src/hooks/api/useApi.js
touch mobile/src/hooks/api/useClients.js
touch mobile/src/hooks/api/useProcesses.js
touch mobile/src/hooks/storage/useStorage.js
touch mobile/src/hooks/navigation/useNavigation.js
touch mobile/src/hooks/device/useDevice.js
touch mobile/src/hooks/device/usePermissions.js

# Store
touch mobile/src/store/index.js
touch mobile/src/store/slices/authSlice.js
touch mobile/src/store/slices/userSlice.js
touch mobile/src/store/slices/offlineSlice.js

# Utils
touch mobile/src/utils/formatters/dateFormatter.js
touch mobile/src/utils/formatters/currencyFormatter.js
touch mobile/src/utils/formatters/documentFormatter.js
touch mobile/src/utils/validators/formValidators.js
touch mobile/src/utils/validators/documentValidators.js
touch mobile/src/utils/helpers/apiHelpers.js
touch mobile/src/utils/helpers/navigationHelpers.js
touch mobile/src/utils/permissions/permissionHelpers.js

# Estilos
touch mobile/src/styles/colors.js
touch mobile/src/styles/typography.js
touch mobile/src/styles/spacing.js
touch mobile/src/styles/globalStyles.js
touch mobile/src/styles/themes/light.js
touch mobile/src/styles/themes/dark.js

# Componentes principais - Comuns
touch mobile/src/components/common/Header/index.js
touch mobile/src/components/common/Header/styles.js
touch mobile/src/components/common/Loading/index.js
touch mobile/src/components/common/Loading/styles.js
touch mobile/src/components/common/Modal/index.js
touch mobile/src/components/common/Modal/styles.js

# Componentes UI
touch mobile/src/components/ui/Button/index.js
touch mobile/src/components/ui/Button/styles.js
touch mobile/src/components/ui/Input/index.js
touch mobile/src/components/ui/Input/styles.js
touch mobile/src/components/ui/Camera/index.js
touch mobile/src/components/ui/Camera/styles.js

# Telas principais
touch mobile/src/screens/auth/Login/index.js
touch mobile/src/screens/auth/Login/styles.js
touch mobile/src/screens/admin/Dashboard/index.js
touch mobile/src/screens/admin/Dashboard/styles.js
touch mobile/src/screens/client/Dashboard/index.js
touch mobile/src/screens/client/Dashboard/styles.js

# Arquivos Android/iOS (estrutura básica)
mkdir -p mobile/android/app/src/main/java
mkdir -p mobile/android/app/src/main/res
mkdir -p mobile/ios/ErleneAdvogados

# Constantes
touch mobile/src/constants/colors.js
touch mobile/src/constants/fonts.js
touch mobile/src/constants/sizes.js
touch mobile/src/constants/routes.js

echo "✅ Estrutura do Mobile criada com sucesso!"
echo "📁 Total de diretórios: $(find mobile -type d | wc -l)"
echo "📄 Total de arquivos: $(find mobile -type f | wc -l)"
echo ""
echo "⏭️  Próximo: Execute o script 04-create-docker-and-docs.sh"