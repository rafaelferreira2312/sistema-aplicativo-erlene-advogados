#!/bin/bash

# Script 01 - Criação da Estrutura do Backend (PHP/Laravel)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/01-create-backend-structure.sh

echo "🚀 Iniciando criação da estrutura do Backend..."

# Criar diretório principal do backend
mkdir -p backend

# Estrutura principal do Laravel
mkdir -p backend/app
mkdir -p backend/bootstrap
mkdir -p backend/config
mkdir -p backend/database
mkdir -p backend/public
mkdir -p backend/resources
mkdir -p backend/routes
mkdir -p backend/storage
mkdir -p backend/tests
mkdir -p backend/vendor

# Estrutura app/
mkdir -p backend/app/Console
mkdir -p backend/app/Console/Commands
mkdir -p backend/app/Exceptions
mkdir -p backend/app/Http
mkdir -p backend/app/Models
mkdir -p backend/app/Providers
mkdir -p backend/app/Services
mkdir -p backend/app/Traits
mkdir -p backend/app/Helpers

# Estrutura app/Http/
mkdir -p backend/app/Http/Controllers
mkdir -p backend/app/Http/Controllers/Api
mkdir -p backend/app/Http/Controllers/Api/Admin
mkdir -p backend/app/Http/Controllers/Api/Client
mkdir -p backend/app/Http/Controllers/Api/Portal
mkdir -p backend/app/Http/Controllers/Auth
mkdir -p backend/app/Http/Middleware
mkdir -p backend/app/Http/Requests
mkdir -p backend/app/Http/Resources

# Estrutura Controllers específicos
mkdir -p backend/app/Http/Controllers/Api/Admin/Clients
mkdir -p backend/app/Http/Controllers/Api/Admin/Processes
mkdir -p backend/app/Http/Controllers/Api/Admin/Appointments
mkdir -p backend/app/Http/Controllers/Api/Admin/Financial
mkdir -p backend/app/Http/Controllers/Api/Admin/Documents
mkdir -p backend/app/Http/Controllers/Api/Admin/Users
mkdir -p backend/app/Http/Controllers/Api/Admin/Reports
mkdir -p backend/app/Http/Controllers/Api/Admin/Integrations

# Estrutura Services
mkdir -p backend/app/Services/Integration
mkdir -p backend/app/Services/Payment
mkdir -p backend/app/Services/Document
mkdir -p backend/app/Services/Email
mkdir -p backend/app/Services/Tribunal
mkdir -p backend/app/Services/Storage

# Estrutura Services/Integration (APIs externas)
mkdir -p backend/app/Services/Integration/CNJ
mkdir -p backend/app/Services/Integration/Escavador
mkdir -p backend/app/Services/Integration/Jurisbrasil
mkdir -p backend/app/Services/Integration/GoogleDrive
mkdir -p backend/app/Services/Integration/OneDrive
mkdir -p backend/app/Services/Integration/GoogleCalendar
mkdir -p backend/app/Services/Integration/Gmail
mkdir -p backend/app/Services/Integration/Stripe
mkdir -p backend/app/Services/Integration/MercadoPago
mkdir -p backend/app/Services/Integration/ChatGPT

# Estrutura Models
mkdir -p backend/app/Models/Admin
mkdir -p backend/app/Models/Client
mkdir -p backend/app/Models/Financial
mkdir -p backend/app/Models/Integration

# Estrutura config/
mkdir -p backend/config/integrations

# Estrutura database/
mkdir -p backend/database/factories
mkdir -p backend/database/migrations
mkdir -p backend/database/seeders

# Estrutura resources/
mkdir -p backend/resources/views
mkdir -p backend/resources/views/emails
mkdir -p backend/resources/views/reports
mkdir -p backend/resources/lang
mkdir -p backend/resources/lang/pt_BR

# Estrutura storage/
mkdir -p backend/storage/app
mkdir -p backend/storage/app/public
mkdir -p backend/storage/app/clients
mkdir -p backend/storage/app/documents
mkdir -p backend/storage/app/backups
mkdir -p backend/storage/app/temp
mkdir -p backend/storage/framework
mkdir -p backend/storage/framework/cache
mkdir -p backend/storage/framework/sessions
mkdir -p backend/storage/framework/views
mkdir -p backend/storage/logs

# Estrutura tests/
mkdir -p backend/tests/Feature
mkdir -p backend/tests/Feature/Api
mkdir -p backend/tests/Feature/Integration
mkdir -p backend/tests/Unit
mkdir -p backend/tests/Unit/Services

# Estrutura routes/
# (arquivos serão criados posteriormente)

# Estrutura public/
mkdir -p backend/public/css
mkdir -p backend/public/js
mkdir -p backend/public/images
mkdir -p backend/public/uploads

# Criar arquivos principais vazios
touch backend/composer.json
touch backend/package.json
touch backend/artisan
touch backend/.env.example
touch backend/.env
touch backend/webpack.mix.js
touch backend/phpunit.xml

# Arquivos de configuração
touch backend/config/app.php
touch backend/config/auth.php
touch backend/config/database.php
touch backend/config/filesystems.php
touch backend/config/mail.php
touch backend/config/services.php
touch backend/config/cors.php
touch backend/config/jwt.php

# Arquivos de configuração das integrações
touch backend/config/integrations/cnj.php
touch backend/config/integrations/escavador.php
touch backend/config/integrations/jurisbrasil.php
touch backend/config/integrations/google_drive.php
touch backend/config/integrations/onedrive.php
touch backend/config/integrations/google_calendar.php
touch backend/config/integrations/gmail.php
touch backend/config/integrations/stripe.php
touch backend/config/integrations/mercadopago.php
touch backend/config/integrations/chatgpt.php

# Models principais
touch backend/app/Models/User.php
touch backend/app/Models/Client.php
touch backend/app/Models/Process.php
touch backend/app/Models/Appointment.php
touch backend/app/Models/Unit.php
touch backend/app/Models/Document.php
touch backend/app/Models/Financial.php
touch backend/app/Models/Integration.php
touch backend/app/Models/Tribunal.php
touch backend/app/Models/Movement.php
touch backend/app/Models/Task.php
touch backend/app/Models/KanbanColumn.php
touch backend/app/Models/KanbanCard.php
touch backend/app/Models/Permission.php
touch backend/app/Models/Message.php
touch backend/app/Models/Calendar.php

# Models específicos por módulo
touch backend/app/Models/Admin/AdminUser.php
touch backend/app/Models/Client/ClientAccess.php
touch backend/app/Models/Financial/Payment.php
touch backend/app/Models/Financial/StripePayment.php
touch backend/app/Models/Financial/MercadoPagoPayment.php
touch backend/app/Models/Integration/TribunalIntegration.php
touch backend/app/Models/Integration/DriveSync.php

# Controllers principais - Admin
touch backend/app/Http/Controllers/Api/Admin/DashboardController.php
touch backend/app/Http/Controllers/Api/Admin/UnitsController.php
touch backend/app/Http/Controllers/Api/Admin/UsersController.php
touch backend/app/Http/Controllers/Api/Admin/ConfigController.php

# Controllers - Clientes
touch backend/app/Http/Controllers/Api/Admin/Clients/ClientController.php
touch backend/app/Http/Controllers/Api/Admin/Clients/ClientDocumentController.php
touch backend/app/Http/Controllers/Api/Admin/Clients/ClientAccessController.php

# Controllers - Processos
touch backend/app/Http/Controllers/Api/Admin/Processes/ProcessController.php
touch backend/app/Http/Controllers/Api/Admin/Processes/MovementController.php
touch backend/app/Http/Controllers/Api/Admin/Processes/KanbanController.php

# Controllers - Atendimentos
touch backend/app/Http/Controllers/Api/Admin/Appointments/AppointmentController.php
touch backend/app/Http/Controllers/Api/Admin/Appointments/CalendarController.php

# Controllers - Financeiro
touch backend/app/Http/Controllers/Api/Admin/Financial/FinancialController.php
touch backend/app/Http/Controllers/Api/Admin/Financial/PaymentController.php
touch backend/app/Http/Controllers/Api/Admin/Financial/StripeController.php
touch backend/app/Http/Controllers/Api/Admin/Financial/MercadoPagoController.php

# Controllers - Documentos
touch backend/app/Http/Controllers/Api/Admin/Documents/DocumentController.php
touch backend/app/Http/Controllers/Api/Admin/Documents/GEDController.php
touch backend/app/Http/Controllers/Api/Admin/Documents/StorageController.php

# Controllers - Usuários
touch backend/app/Http/Controllers/Api/Admin/Users/UserController.php
touch backend/app/Http/Controllers/Api/Admin/Users/PermissionController.php

# Controllers - Relatórios
touch backend/app/Http/Controllers/Api/Admin/Reports/ClientReportController.php
touch backend/app/Http/Controllers/Api/Admin/Reports/ProcessReportController.php
touch backend/app/Http/Controllers/Api/Admin/Reports/FinancialReportController.php

# Controllers - Integrações
touch backend/app/Http/Controllers/Api/Admin/Integrations/TribunalController.php
touch backend/app/Http/Controllers/Api/Admin/Integrations/DriveController.php
touch backend/app/Http/Controllers/Api/Admin/Integrations/EmailController.php
touch backend/app/Http/Controllers/Api/Admin/Integrations/PaymentGatewayController.php

# Controllers - Portal do Cliente
touch backend/app/Http/Controllers/Api/Portal/ClientDashboardController.php
touch backend/app/Http/Controllers/Api/Portal/ClientProcessController.php
touch backend/app/Http/Controllers/Api/Portal/ClientDocumentController.php
touch backend/app/Http/Controllers/Api/Portal/ClientPaymentController.php
touch backend/app/Http/Controllers/Api/Portal/ClientMessageController.php

echo "✅ Estrutura do Backend criada com sucesso!"
echo "📁 Total de diretórios: $(find backend -type d | wc -l)"
echo "📄 Total de arquivos: $(find backend -type f | wc -l)"
echo ""
echo "⏭️  Próximo: Execute o script 02-create-frontend-structure.sh"