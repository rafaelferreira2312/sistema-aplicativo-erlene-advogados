# Análise dos Controllers Laravel
## Gerado em: 2025-09-19 11:27:07

## Estrutura de Controllers
- Api/Admin/Appointments/AppointmentController.php
- Api/Admin/Appointments/CalendarController.php
- Api/Admin/AudienciaController.php
- Api/Admin/Clients/ClientAccessController.php
- Api/Admin/Clients/ClientController.php
- Api/Admin/Clients/ClientDocumentController.php
- Api/Admin/ConfigController.php
- Api/Admin/DashboardController.php
- Api/Admin/Documents/DocumentController.php
- Api/Admin/Documents/GEDController.php
- Api/Admin/Documents/StorageController.php
- Api/Admin/Financial/FinancialController.php
- Api/Admin/Financial/MercadoPagoController.php
- Api/Admin/Financial/PaymentController.php
- Api/Admin/Financial/StripeController.php
- Api/Admin/IntegrationController.php
- Api/Admin/Integrations/CNJ/CNJController.php
- Api/Admin/Integrations/CNJ/CNJProcessController.php
- Api/Admin/Integrations/DriveController.php
- Api/Admin/Integrations/EmailController.php
- Api/Admin/Integrations/PaymentGatewayController.php
- Api/Admin/Integrations/TribunalController.php
- Api/Admin/KanbanController.php
- Api/Admin/Processes/KanbanController.php
- Api/Admin/Processes/MovementController.php
- Api/Admin/Processes/ProcessController.php
- Api/Admin/Reports/ClientReportController.php
- Api/Admin/Reports/FinancialReportController.php
- Api/Admin/Reports/ProcessReportController.php
- Api/Admin/UnitsController.php
- Api/Admin/Users/PermissionController.php
- Api/Admin/Users/UserController.php
- Api/Admin/UsersController.php
- Api/AuthController.php
- Api/Portal/ClientDashboardController.php
- Api/Portal/ClientDocumentController.php
- Api/Portal/ClientMessageController.php
- Api/Portal/ClientPaymentController.php
- Api/Portal/ClientProcessController.php
- Auth/AuthController.php
- Controller.php

## Detalhes dos Controllers Principais
### ClientPaymentController
**Arquivo:** `app/Http/Controllers/Api/Portal/ClientPaymentController.php`
**Métodos:**
-     dashboard
-     history
-     index
-     payWithMercadoPago
-     payWithStripe
-     receipt
-     show
**Dependências principais:**
```php
use App\Http\Controllers\Controller;
use App\Models\Financeiro;
use App\Models\PagamentoStripe;
use App\Models\PagamentoMercadoPago;
use Illuminate\Http\Request;
```

### ClientDocumentController
**Arquivo:** `app/Http/Controllers/Api/Portal/ClientDocumentController.php`
**Métodos:**
-     download
-     index
-     show
-     statistics
-     upload
**Dependências principais:**
```php
use App\Http\Controllers\Controller;
use App\Models\DocumentoGed;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
```

### ClientDashboardController
**Arquivo:** `app/Http/Controllers/Api/Portal/ClientDashboardController.php`
**Métodos:**
-     changePassword
-     index
-     notifications
-     profile
-     updateProfile
**Dependências principais:**
```php
use App\Http\Controllers\Controller;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\Atendimento;
use App\Models\Financeiro;
```

### ClientProcessController
**Arquivo:** `app/Http/Controllers/Api/Portal/ClientProcessController.php`
**Métodos:**
-     index
-     movements
-     show
-     timeline
**Dependências principais:**
```php
use App\Http\Controllers\Controller;
use App\Models\Processo;
use Illuminate\Http\Request;
```

### ClientMessageController
**Arquivo:** `app/Http/Controllers/Api/Portal/ClientMessageController.php`
**Métodos:**
-     conversations
-     index
-     markAllAsRead
-     markAsRead
-     show
-     statistics
-     store
**Dependências principais:**
```php
use App\Http\Controllers\Controller;
use App\Models\Mensagem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
```

### StripeController
**Arquivo:** `app/Http/Controllers/Api/Admin/Financial/StripeController.php`
**Métodos:**
-     createPaymentIntent
-     index
-     refund
-     webhook
**Dependências principais:**
```php
use App\Http\Controllers\Controller;
use App\Models\Financeiro;
use App\Models\PagamentoStripe;
use App\Models\Cliente;
use Illuminate\Http\Request;
```

### MercadoPagoController
**Arquivo:** `app/Http/Controllers/Api/Admin/Financial/MercadoPagoController.php`
**Métodos:**
-     cancel
-     createPreference
-     index
-     webhook
**Dependências principais:**
```php
use App\Http\Controllers\Controller;
use App\Models\Financeiro;
use App\Models\PagamentoMercadoPago;
use App\Models\Cliente;
use Illuminate\Http\Request;
```

### FinancialController
**Arquivo:** `app/Http/Controllers/Api/Admin/Financial/FinancialController.php`
**Métodos:**
-     dashboard
-     destroy
-     index
-     marcarPago
-     show
-     store
-     update
**Dependências principais:**
```php
use App\Http\Controllers\Controller;
use App\Models\Financeiro;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\Atendimento;
```

### PaymentController
**Arquivo:** `app/Http/Controllers/Api/Admin/Financial/PaymentController.php`

### CNJProcessController
**Arquivo:** `app/Http/Controllers/Api/Admin/Integrations/CNJ/CNJProcessController.php`
**Métodos:**
-     destroy
-     index
-     show
-     store
-     syncWithCNJ
-     update
**Dependências principais:**
```php
use App\Http\Controllers\Controller;
use App\Models\Processo;
use App\Models\Cliente;
use App\Models\User;
use App\Services\Integration\CNJService;
```

## Resumo por Categoria
- **Total**: 41 controllers
- **API Controllers**: 39
- **Auth Controllers**: 2

