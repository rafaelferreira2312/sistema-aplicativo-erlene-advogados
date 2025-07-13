#!/bin/bash

# Script 24 - Middleware e Service Providers (Parte 2)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/24-create-laravel-auth-configs-part2.sh (executado da raiz do projeto)

echo "🚀 Criando Middleware e Service Providers (Parte 2)..."

# Criar diretórios necessários
mkdir -p backend/app/Http/Middleware
mkdir -p backend/app/Providers
mkdir -p backend/app/Exceptions

# Middleware CORS customizado
cat > backend/app/Http/Middleware/Cors.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class Cors
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        $allowedOrigins = [
            'http://localhost:3000',
            'http://localhost:3001',
            'http://127.0.0.1:3000',
            'http://127.0.0.1:3001',
            config('app.frontend_url'),
        ];

        $origin = $request->header('Origin');

        if (in_array($origin, $allowedOrigins) || 
            str_contains($origin, '.erleneadvogados.com.br') ||
            str_contains($origin, '.localhost')) {
            
            $response = $next($request);
            
            $response->headers->set('Access-Control-Allow-Origin', $origin);
            $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
            $response->headers->set('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization, X-Requested-With');
            $response->headers->set('Access-Control-Allow-Credentials', 'true');
            $response->headers->set('Access-Control-Max-Age', '86400');

            return $response;
        }

        if ($request->getMethod() === 'OPTIONS') {
            return response('', 200);
        }

        return $next($request);
    }
}
EOF

# Middleware de autenticação JWT personalizada
cat > backend/app/Http/Middleware/JwtMiddleware.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use Tymon\JWTAuth\Exceptions\JWTException;

class JwtMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, $guard = 'api')
    {
        try {
            // Configurar o guard para o JWT
            JWTAuth::setDefaultDriver($guard);
            
            $user = JWTAuth::parseToken()->authenticate();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuário não encontrado'
                ], 404);
            }

            // Verificar se o usuário está ativo (apenas para usuários admin)
            if ($guard === 'api' && $user->status !== 'ativo') {
                return response()->json([
                    'success' => false,
                    'message' => 'Usuário inativo'
                ], 403);
            }

        } catch (TokenExpiredException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token expirado'
            ], 401);
            
        } catch (TokenInvalidException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token inválido'
            ], 401);
            
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token não fornecido'
            ], 401);
        }

        return $next($request);
    }
}
EOF

# Auth Service Provider
cat > backend/app/Providers/AuthServiceProvider.php << 'EOF'
<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        // 'App\Models\Model' => 'App\Policies\ModelPolicy',
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void
    {
        $this->registerPolicies();

        // Gates para controle de acesso
        Gate::define('admin-geral', function ($user) {
            return $user->perfil === 'admin_geral';
        });

        Gate::define('admin-unidade', function ($user) {
            return in_array($user->perfil, ['admin_geral', 'admin_unidade']);
        });

        Gate::define('advogado', function ($user) {
            return in_array($user->perfil, ['admin_geral', 'admin_unidade', 'advogado']);
        });

        Gate::define('financeiro', function ($user) {
            return in_array($user->perfil, ['admin_geral', 'admin_unidade', 'financeiro']);
        });

        Gate::define('same-unidade', function ($user, $model) {
            if ($user->perfil === 'admin_geral') {
                return true;
            }
            
            return $user->unidade_id === $model->unidade_id;
        });
    }
}
EOF

# App Service Provider
cat > backend/app/Providers/AppServiceProvider.php << 'EOF'
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Schema;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Registrar services personalizados
        $this->app->bind(\App\Services\ClientService::class, function ($app) {
            return new \App\Services\ClientService();
        });

        $this->app->bind(\App\Services\ProcessService::class, function ($app) {
            return new \App\Services\ProcessService();
        });

        $this->app->bind(\App\Services\AppointmentService::class, function ($app) {
            return new \App\Services\AppointmentService();
        });

        $this->app->bind(\App\Services\FinancialService::class, function ($app) {
            return new \App\Services\FinancialService();
        });

        $this->app->bind(\App\Services\DocumentService::class, function ($app) {
            return new \App\Services\DocumentService();
        });

        $this->app->bind(\App\Services\NotificationService::class, function ($app) {
            return new \App\Services\NotificationService(
                $app->make(\App\Services\Integration\EmailService::class)
            );
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Configurar comprimento padrão das strings no banco
        Schema::defaultStringLength(191);

        // Configurar timezone
        date_default_timezone_set('America/Sao_Paulo');
        
        // Configurar locale
        setlocale(LC_TIME, 'pt_BR.UTF-8');
    }
}
EOF

# Route Service Provider
cat > backend/app/Providers/RouteServiceProvider.php << 'EOF'
<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Route;

class RouteServiceProvider extends ServiceProvider
{
    /**
     * The path to your application's "home" route.
     */
    public const HOME = '/dashboard';

    /**
     * Define your route model bindings, pattern filters, and other route configuration.
     */
    public function boot(): void
    {
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
        });

        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(5)->by($request->ip());
        });

        $this->routes(function () {
            Route::middleware('api')
                ->prefix('api')
                ->group(base_path('routes/api.php'));

            Route::middleware('web')
                ->group(base_path('routes/web.php'));
        });
    }
}
EOF

# Event Service Provider
cat > backend/app/Providers/EventServiceProvider.php << 'EOF'
<?php

namespace App\Providers;

use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Listeners\SendEmailVerificationNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Event;

class EventServiceProvider extends ServiceProvider
{
    /**
     * The event to listener mappings for the application.
     *
     * @var array<class-string, array<int, class-string>>
     */
    protected $listen = [
        Registered::class => [
            SendEmailVerificationNotification::class,
        ],
    ];

    /**
     * Register any events for your application.
     */
    public function boot(): void
    {
        //
    }

    /**
     * Determine if events and listeners should be automatically discovered.
     */
    public function shouldDiscoverEvents(): bool
    {
        return false;
    }
}
EOF

echo "✅ Middleware e Service Providers criados (Parte 2)!"
echo "📊 Arquivos criados:"
echo "   • app/Http/Middleware/Cors.php - CORS personalizado"
echo "   • app/Http/Middleware/JwtMiddleware.php - JWT guard customizado"
echo "   • app/Providers/AuthServiceProvider.php - Gates de autorização"
echo "   • app/Providers/AppServiceProvider.php - Registro de services"
echo "   • app/Providers/RouteServiceProvider.php - Rate limiting"
echo "   • app/Providers/EventServiceProvider.php - Event listeners"
echo ""
echo "⏭️  Digite 'continuar' para criar Exception Handler e configs restantes (Parte 3)..."