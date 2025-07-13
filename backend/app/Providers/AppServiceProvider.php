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
