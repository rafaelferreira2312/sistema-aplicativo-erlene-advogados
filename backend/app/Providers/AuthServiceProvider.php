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
