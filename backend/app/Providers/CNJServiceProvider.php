<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\Integration\CNJService;

class CNJServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        $this->app->singleton(CNJService::class, function ($app) {
            return new CNJService();
        });
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
