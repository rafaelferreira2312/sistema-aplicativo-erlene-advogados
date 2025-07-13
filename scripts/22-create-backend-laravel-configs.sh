#!/bin/bash

# Script 22 - Criação das Configurações Laravel (CRÍTICO PARA RODAR)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/22-create-backend-laravel-configs.sh (executado da raiz do projeto)

echo "🚀 Criando Configurações Laravel (CRÍTICO PARA RODAR)..."

# Composer.json - Dependências PHP
cat > backend/composer.json << 'EOF'
{
    "name": "erlene-advogados/sistema-juridico",
    "type": "project",
    "description": "Sistema de Gestão Jurídica - Erlene Advogados",
    "keywords": ["framework", "laravel", "juridico", "advocacia"],
    "license": "MIT",
    "require": {
        "php": "^8.2",
        "guzzlehttp/guzzle": "^7.2",
        "laravel/framework": "^10.10",
        "laravel/sanctum": "^3.2",
        "laravel/tinker": "^2.8",
        "tymon/jwt-auth": "^2.0",
        "spatie/laravel-cors": "^3.0",
        "intervention/image": "^3.0",
        "maatwebsite/excel": "^3.1",
        "barryvdh/laravel-dompdf": "^2.0",
        "pusher/pusher-php-server": "^7.2",
        "stripe/stripe-php": "^13.0",
        "mercadopago/dx-php": "^3.0",
        "google/apiclient": "^2.15",
        "microsoft/microsoft-graph": "^2.0",
        "league/flysystem-aws-s3-v3": "^3.0",
        "league/flysystem-ftp": "^3.0"
    },
    "require-dev": {
        "fakerphp/faker": "^1.9.1",
        "laravel/pint": "^1.0",
        "laravel/sail": "^1.18",
        "mockery/mockery": "^1.4.4",
        "nunomaduro/collision": "^7.0",
        "phpunit/phpunit": "^10.1",
        "spatie/laravel-ignition": "^2.0"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
EOF

# Routes API - Todas as rotas da API
cat > backend/routes/api.php << 'EOF'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Api\Admin\DashboardController;
use App\Http\Controllers\Api\Admin\Clients\ClientController;
use App\Http\Controllers\Api\Admin\Processes\ProcessController;
use App\Http\Controllers\Api\Admin\Appointments\AppointmentController;
use App\Http\Controllers\Api\Admin\Financial\FinancialController;
use App\Http\Controllers\Api\Admin\Financial\StripeController;
use App\Http\Controllers\Api\Admin\Financial\MercadoPagoController;
use App\Http\Controllers\Api\Admin\Documents\DocumentController;
use App\Http\Controllers\Api\Admin\Users\UserController;
use App\Http\Controllers\Api\Admin\KanbanController;
use App\Http\Controllers\Api\Admin\ConfigController;
use App\Http\Controllers\Api\Portal\ClientDashboardController;
use App\Http\Controllers\Api\Portal\ClientProcessController;
use App\Http\Controllers\Api\Portal\ClientDocumentController;
use App\Http\Controllers\Api\Portal\ClientPaymentController;
use App\Http\Controllers\Api\Portal\ClientMessageController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Rotas de Autenticação (Públicas)
Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login']);
    Route::post('login-client', [AuthController::class, 'loginClient']);
    Route::post('refresh', [AuthController::class, 'refresh']);
    
    Route::middleware('auth:api')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
    });
});

// Webhooks (Públicas com validação própria)
Route::prefix('webhooks')->group(function () {
    Route::post('stripe', [StripeController::class, 'webhook']);
    Route::post('mercadopago', [MercadoPagoController::class, 'webhook']);
});

// Rotas Administrativas (Protegidas)
Route::prefix('admin')->middleware(['auth:api'])->group(function () {
    
    // Dashboard
    Route::get('dashboard', [DashboardController::class, 'index']);
    Route::get('dashboard/notifications', [DashboardController::class, 'notifications']);
    
    // Clientes
    Route::prefix('clients')->group(function () {
        Route::get('/', [ClientController::class, 'index']);
        Route::post('/', [ClientController::class, 'store']);
        Route::get('{id}', [ClientController::class, 'show']);
        Route::put('{id}', [ClientController::class, 'update']);
        Route::delete('{id}', [ClientController::class, 'destroy']);
        Route::get('responsaveis', [ClientController::class, 'responsaveis']);
        
        // Documentos por cliente
        Route::get('{id}/documents', [DocumentController::class, 'porCliente']);
    });
    
    // Processos
    Route::prefix('processes')->group(function () {
        Route::get('/', [ProcessController::class, 'index']);
        Route::post('/', [ProcessController::class, 'store']);
        Route::get('{id}', [ProcessController::class, 'show']);
        Route::put('{id}', [ProcessController::class, 'update']);
        Route::delete('{id}', [ProcessController::class, 'destroy']);
        Route::post('{id}/consultar', [ProcessController::class, 'consultar']);
        Route::get('tribunais', [ProcessController::class, 'tribunais']);
    });
    
    // Atendimentos
    Route::prefix('appointments')->group(function () {
        Route::get('/', [AppointmentController::class, 'index']);
        Route::post('/', [AppointmentController::class, 'store']);
        Route::get('{id}', [AppointmentController::class, 'show']);
        Route::put('{id}', [AppointmentController::class, 'update']);
        Route::delete('{id}', [AppointmentController::class, 'destroy']);
        Route::post('{id}/iniciar', [AppointmentController::class, 'iniciar']);
        Route::post('{id}/finalizar', [AppointmentController::class, 'finalizar']);
    });
    
    // Financeiro
    Route::prefix('financial')->group(function () {
        Route::get('/', [FinancialController::class, 'index']);
        Route::post('/', [FinancialController::class, 'store']);
        Route::get('{id}', [FinancialController::class, 'show']);
        Route::put('{id}', [FinancialController::class, 'update']);
        Route::delete('{id}', [FinancialController::class, 'destroy']);
        Route::post('{id}/marcar-pago', [FinancialController::class, 'marcarPago']);
        Route::get('dashboard', [FinancialController::class, 'dashboard']);
    });
    
    // Pagamentos Stripe
    Route::prefix('payments/stripe')->group(function () {
        Route::get('/', [StripeController::class, 'index']);
        Route::post('create-payment-intent', [StripeController::class, 'createPaymentIntent']);
        Route::post('{id}/refund', [StripeController::class, 'refund']);
    });
    
    // Pagamentos Mercado Pago
    Route::prefix('payments/mercadopago')->group(function () {
        Route::get('/', [MercadoPagoController::class, 'index']);
        Route::post('create-preference', [MercadoPagoController::class, 'createPreference']);
        Route::post('{id}/cancel', [MercadoPagoController::class, 'cancel']);
    });
    
    // Documentos
    Route::prefix('documents')->group(function () {
        Route::get('/', [DocumentController::class, 'index']);
        Route::post('upload', [DocumentController::class, 'upload']);
        Route::get('{id}', [DocumentController::class, 'show']);
        Route::put('{id}', [DocumentController::class, 'update']);
        Route::delete('{id}', [DocumentController::class, 'destroy']);
        Route::get('{id}/download', [DocumentController::class, 'download']);
        Route::get('estatisticas', [DocumentController::class, 'estatisticas']);
    });
    
    // Usuários
    Route::prefix('users')->group(function () {
        Route::get('/', [UserController::class, 'index']);
        Route::post('/', [UserController::class, 'store']);
        Route::get('{id}', [UserController::class, 'show']);
        Route::put('{id}', [UserController::class, 'update']);
        Route::delete('{id}', [UserController::class, 'destroy']);
        Route::post('{id}/toggle-status', [UserController::class, 'toggleStatus']);
        Route::post('{id}/redefinir-senha', [UserController::class, 'redefinirSenha']);
        Route::get('unidades', [UserController::class, 'unidades']);
        Route::get('perfis', [UserController::class, 'perfis']);
    });
    
    // Kanban
    Route::prefix('kanban')->group(function () {
        Route::get('/', [KanbanController::class, 'index']);
        Route::post('colunas', [KanbanController::class, 'criarColuna']);
        Route::put('colunas/{id}', [KanbanController::class, 'atualizarColuna']);
        Route::delete('colunas/{id}', [KanbanController::class, 'excluirColuna']);
        Route::post('cards', [KanbanController::class, 'criarCard']);
        Route::put('cards/{id}', [KanbanController::class, 'atualizarCard']);
        Route::post('cards/{id}/mover', [KanbanController::class, 'moverCard']);
        Route::delete('cards/{id}', [KanbanController::class, 'excluirCard']);
        Route::post('colunas/reordenar', [KanbanController::class, 'reordenarColunas']);
    });
    
    // Configurações
    Route::prefix('config')->group(function () {
        Route::get('/', [ConfigController::class, 'index']);
        Route::put('{chave}', [ConfigController::class, 'update']);
        Route::get('integrations', [ConfigController::class, 'integrations']);
        Route::put('integrations/{nome}', [ConfigController::class, 'updateIntegration']);
        Route::get('categories', [ConfigController::class, 'categories']);
    });
});

// Rotas do Portal do Cliente (Protegidas)
Route::prefix('portal')->middleware(['auth:cliente'])->group(function () {
    
    // Dashboard do Cliente
    Route::get('dashboard', [ClientDashboardController::class, 'index']);
    Route::get('profile', [ClientDashboardController::class, 'profile']);
    Route::put('profile', [ClientDashboardController::class, 'updateProfile']);
    Route::post('change-password', [ClientDashboardController::class, 'changePassword']);
    Route::get('notifications', [ClientDashboardController::class, 'notifications']);
    
    // Processos do Cliente
    Route::prefix('processes')->group(function () {
        Route::get('/', [ClientProcessController::class, 'index']);
        Route::get('{id}', [ClientProcessController::class, 'show']);
        Route::get('{id}/movements', [ClientProcessController::class, 'movements']);
        Route::get('{id}/timeline', [ClientProcessController::class, 'timeline']);
    });
    
    // Documentos do Cliente
    Route::prefix('documents')->group(function () {
        Route::get('/', [ClientDocumentController::class, 'index']);
        Route::get('{id}', [ClientDocumentController::class, 'show']);
        Route::get('{id}/download', [ClientDocumentController::class, 'download']);
        Route::post('upload', [ClientDocumentController::class, 'upload']);
        Route::get('statistics', [ClientDocumentController::class, 'statistics']);
    });
    
    // Pagamentos do Cliente
    Route::prefix('payments')->group(function () {
        Route::get('/', [ClientPaymentController::class, 'index']);
        Route::get('{id}', [ClientPaymentController::class, 'show']);
        Route::post('{id}/pay-stripe', [ClientPaymentController::class, 'payWithStripe']);
        Route::post('{id}/pay-mercadopago', [ClientPaymentController::class, 'payWithMercadoPago']);
        Route::get('history', [ClientPaymentController::class, 'history']);
        Route::get('{id}/receipt', [ClientPaymentController::class, 'receipt']);
        Route::get('dashboard', [ClientPaymentController::class, 'dashboard']);
    });
    
    // Mensagens do Cliente
    Route::prefix('messages')->group(function () {
        Route::get('/', [ClientMessageController::class, 'index']);
        Route::get('{id}', [ClientMessageController::class, 'show']);
        Route::post('/', [ClientMessageController::class, 'store']);
        Route::post('{id}/mark-read', [ClientMessageController::class, 'markAsRead']);
        Route::post('mark-all-read', [ClientMessageController::class, 'markAllAsRead']);
        Route::get('conversations', [ClientMessageController::class, 'conversations']);
        Route::get('statistics', [ClientMessageController::class, 'statistics']);
    });
});

// Rota de fallback para SPA
Route::fallback(function(){
    return response()->json([
        'message' => 'Rota não encontrada'
    ], 404);
});
EOF

# Bootstrap App - Inicialização do Laravel
cat > backend/bootstrap/app.php << 'EOF'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->api(prepend: [
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        ]);

        $middleware->alias([
            'verified' => \Illuminate\Auth\Middleware\EnsureEmailIsVerified::class,
            'jwt.auth' => \Tymon\JWTAuth\Http\Middleware\Authenticate::class,
            'jwt.refresh' => \Tymon\JWTAuth\Http\Middleware\RefreshToken::class,
        ]);

        // CORS Headers
        $middleware->append(\App\Http\Middleware\Cors::class);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
EOF

# Config App - Configuração principal
cat > backend/config/app.php << 'EOF'
<?php

use Illuminate\Support\Facades\Facade;

return [

    /*
    |--------------------------------------------------------------------------
    | Application Name
    |--------------------------------------------------------------------------
    */

    'name' => env('APP_NAME', 'Sistema Erlene Advogados'),

    /*
    |--------------------------------------------------------------------------
    | Application Environment
    |--------------------------------------------------------------------------
    */

    'env' => env('APP_ENV', 'production'),

    /*
    |--------------------------------------------------------------------------
    | Application Debug Mode
    |--------------------------------------------------------------------------
    */

    'debug' => (bool) env('APP_DEBUG', false),

    /*
    |--------------------------------------------------------------------------
    | Application URL
    |--------------------------------------------------------------------------
    */

    'url' => env('APP_URL', 'http://localhost'),
    'frontend_url' => env('FRONTEND_URL', 'http://localhost:3000'),

    /*
    |--------------------------------------------------------------------------
    | Application Timezone
    |--------------------------------------------------------------------------
    */

    'timezone' => 'America/Sao_Paulo',

    /*
    |--------------------------------------------------------------------------
    | Application Locale Configuration
    |--------------------------------------------------------------------------
    */

    'locale' => 'pt_BR',
    'fallback_locale' => 'en',
    'faker_locale' => 'pt_BR',

    /*
    |--------------------------------------------------------------------------
    | Encryption Key
    |--------------------------------------------------------------------------
    */

    'key' => env('APP_KEY'),
    'cipher' => 'AES-256-CBC',

    /*
    |--------------------------------------------------------------------------
    | Maintenance Mode Driver
    |--------------------------------------------------------------------------
    */

    'maintenance' => [
        'driver' => 'file',
    ],

    /*
    |--------------------------------------------------------------------------
    | Autoloaded Service Providers
    |--------------------------------------------------------------------------
    */

    'providers' => [
        /*
         * Laravel Framework Service Providers...
         */
        Illuminate\Auth\AuthServiceProvider::class,
        Illuminate\Broadcasting\BroadcastServiceProvider::class,
        Illuminate\Bus\BusServiceProvider::class,
        Illuminate\Cache\CacheServiceProvider::class,
        Illuminate\Foundation\Providers\ConsoleSupportServiceProvider::class,
        Illuminate\Cookie\CookieServiceProvider::class,
        Illuminate\Database\DatabaseServiceProvider::class,
        Illuminate\Encryption\EncryptionServiceProvider::class,
        Illuminate\Filesystem\FilesystemServiceProvider::class,
        Illuminate\Foundation\Providers\FoundationServiceProvider::class,
        Illuminate\Hashing\HashServiceProvider::class,
        Illuminate\Mail\MailServiceProvider::class,
        Illuminate\Notifications\NotificationServiceProvider::class,
        Illuminate\Pagination\PaginationServiceProvider::class,
        Illuminate\Pipeline\PipelineServiceProvider::class,
        Illuminate\Queue\QueueServiceProvider::class,
        Illuminate\Redis\RedisServiceProvider::class,
        Illuminate\Auth\Passwords\PasswordResetServiceProvider::class,
        Illuminate\Session\SessionServiceProvider::class,
        Illuminate\Translation\TranslationServiceProvider::class,
        Illuminate\Validation\ValidationServiceProvider::class,
        Illuminate\View\ViewServiceProvider::class,

        /*
         * Package Service Providers...
         */
        Tymon\JWTAuth\Providers\LaravelServiceProvider::class,

        /*
         * Application Service Providers...
         */
        App\Providers\AppServiceProvider::class,
        App\Providers\AuthServiceProvider::class,
        App\Providers\EventServiceProvider::class,
        App\Providers\RouteServiceProvider::class,
    ],

    /*
    |--------------------------------------------------------------------------
    | Class Aliases
    |--------------------------------------------------------------------------
    */

    'aliases' => Facade::defaultAliases()->merge([
        'JWTAuth' => Tymon\JWTAuth\Facades\JWTAuth::class,
        'JWTFactory' => Tymon\JWTAuth\Facades\JWTFactory::class,
    ])->toArray(),

];
EOF

# Config Database
cat > backend/config/database.php << 'EOF'
<?php

use Illuminate\Support\Str;

return [

    /*
    |--------------------------------------------------------------------------
    | Default Database Connection Name
    |--------------------------------------------------------------------------
    */

    'default' => env('DB_CONNECTION', 'mysql'),

    /*
    |--------------------------------------------------------------------------
    | Database Connections
    |--------------------------------------------------------------------------
    */

    'connections' => [

        'sqlite' => [
            'driver' => 'sqlite',
            'url' => env('DATABASE_URL'),
            'database' => env('DB_DATABASE', database_path('database.sqlite')),
            'prefix' => '',
            'foreign_key_constraints' => env('DB_FOREIGN_KEYS', true),
        ],

        'mysql' => [
            'driver' => 'mysql',
            'url' => env('DATABASE_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '3306'),
            'database' => env('DB_DATABASE', 'erlene_advogados'),
            'username' => env('DB_USERNAME', 'erlene_user'),
            'password' => env('DB_PASSWORD', ''),
            'unix_socket' => env('DB_SOCKET', ''),
            'charset' => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
            'prefix' => '',
            'prefix_indexes' => true,
            'strict' => true,
            'engine' => null,
            'options' => extension_loaded('pdo_mysql') ? array_filter([
                PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
            ]) : [],
        ],

        'pgsql' => [
            'driver' => 'pgsql',
            'url' => env('DATABASE_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '5432'),
            'database' => env('DB_DATABASE', 'forge'),
            'username' => env('DB_USERNAME', 'forge'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => 'utf8',
            'prefix' => '',
            'prefix_indexes' => true,
            'search_path' => 'public',
            'sslmode' => 'prefer',
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Migration Repository Table
    |--------------------------------------------------------------------------
    */

    'migrations' => 'migrations',

    /*
    |--------------------------------------------------------------------------
    | Redis Databases
    |--------------------------------------------------------------------------
    */

    'redis' => [

        'client' => env('REDIS_CLIENT', 'phpredis'),

        'options' => [
            'cluster' => env('REDIS_CLUSTER', 'redis'),
            'prefix' => env('REDIS_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_database_'),
        ],

        'default' => [
            'url' => env('REDIS_URL'),
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'username' => env('REDIS_USERNAME'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', '6379'),
            'database' => env('REDIS_DB', '0'),
        ],

        'cache' => [
            'url' => env('REDIS_URL'),
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'username' => env('REDIS_USERNAME'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', '6379'),
            'database' => env('REDIS_CACHE_DB', '1'),
        ],

    ],

];
EOF

echo "✅ Configurações Laravel criadas com sucesso!"
echo ""
echo "📦 ARQUIVOS CRÍTICOS CRIADOS:"
echo "   • composer.json - Dependências PHP/Laravel"
echo "   • routes/api.php - Todas as rotas da API"
echo "   • bootstrap/app.php - Inicialização do Laravel"
echo "   • config/app.php - Configuração principal"
echo "   • config/database.php - Configuração do banco"
echo ""
echo "🔧 DEPENDÊNCIAS INCLUÍDAS:"
echo "   • Laravel 10 + JWT Auth"
echo "   • Stripe + Mercado Pago"
echo "   • Google APIs + Microsoft Graph"
echo "   • Intervention Image + DomPDF"
echo "   • CORS + Pusher"
echo ""
echo "📍 ROTAS CONFIGURADAS:"
echo "   • 60+ rotas administrativas"
echo "   • 20+ rotas portal cliente"
echo "   • Webhooks Stripe/MercadoPago"
echo "   • Sistema de autenticação completo"
echo ""
echo "⏭️  Próximo: Configurações restantes + Docker!"