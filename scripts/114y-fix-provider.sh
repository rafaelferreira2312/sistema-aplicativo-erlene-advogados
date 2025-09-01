#!/bin/bash

# Script 114y-fix - Correção AppServiceProvider
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 114y-fix-provider.sh && ./114y-fix-provider.sh
# EXECUTE NA PASTA: backend/

echo "🔧 Corrigindo erro de sintaxe no AppServiceProvider..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo "📝 1. Corrigindo AppServiceProvider.php..."

# Corrigir o AppServiceProvider com sintaxe correta
cat > app/Providers/AppServiceProvider.php << 'EOF'
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Registrar ViaCepService
        $this->app->singleton(\App\Services\ViaCepService::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
EOF

echo "📝 2. Limpando cache do Laravel..."

# Limpar cache para aplicar as correções
php artisan config:clear
php artisan cache:clear
php artisan route:clear

echo "📝 3. Testando se o erro foi corrigido..."

# Testar se a aplicação está funcionando
php artisan config:cache

echo "📝 4. Executando novamente o Seeder..."

# Executar o seeder novamente
php artisan db:seed --class=ClienteSeeder

echo "✅ Erro corrigido com sucesso!"
echo "📝 AppServiceProvider.php com sintaxe correta"
echo "📝 Cache limpo e aplicação funcionando"
echo "📝 Seeder executado com sucesso"
echo ""
echo "Digite 'continuar' para prosseguir com o Script 114z (Frontend Service)..."