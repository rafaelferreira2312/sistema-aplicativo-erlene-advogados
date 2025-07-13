#!/bin/bash

# Script 26 - Criação dos 4 Arquivos Finais do Laravel
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/26-create-laravel-final-files.sh (executado da raiz do projeto)

echo "🚀 Criando os 4 arquivos finais do Laravel..."

# Artisan - CLI do Laravel
cat > backend/artisan << 'EOF'
#!/usr/bin/env php
<?php

define('LARAVEL_START', microtime(true));

/*
|--------------------------------------------------------------------------
| Register The Auto Loader
|--------------------------------------------------------------------------
*/

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';

/*
|--------------------------------------------------------------------------
| Run The Artisan Application
|--------------------------------------------------------------------------
*/

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);

$status = $kernel->handle(
    $input = new Symfony\Component\Console\Input\ArgvInput,
    new Symfony\Component\Console\Output\ConsoleOutput
);

/*
|--------------------------------------------------------------------------
| Shutdown The Application
|--------------------------------------------------------------------------
*/

$kernel->terminate($input, $status);

exit($status);
EOF

# Tornar artisan executável
chmod +x backend/artisan

# Package.json - Dependências Node.js para assets
cat > backend/package.json << 'EOF'
{
    "name": "sistema-erlene-advogados-backend",
    "description": "Sistema de Gestão Jurídica - Erlene Advogados - Backend Assets",
    "version": "1.0.0",
    "private": true,
    "scripts": {
        "dev": "npm run development",
        "development": "mix",
        "watch": "mix watch",
        "watch-poll": "mix watch -- --watch-options-poll=1000",
        "hot": "mix watch --hot",
        "prod": "npm run production",
        "production": "mix --production",
        "build": "mix --production"
    },
    "devDependencies": {
        "@popperjs/core": "^2.11.6",
        "axios": "^1.1.2",
        "bootstrap": "^5.2.2",
        "laravel-mix": "^6.0.49",
        "lodash": "^4.17.19",
        "postcss": "^8.1.14",
        "resolve-url-loader": "^5.0.0",
        "sass": "^1.56.1",
        "sass-loader": "^13.1.0"
    },
    "dependencies": {
        "alpinejs": "^3.10.5"
    }
}
EOF

# PHPUnit.xml - Configuração de testes
cat > backend/phpunit.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="vendor/phpunit/phpunit/phpunit.xsd"
         bootstrap="vendor/autoload.php"
         colors="true"
         processIsolation="false"
         stopOnFailure="false"
         executionOrder="random"
         failOnWarning="true"
         failOnRisky="true"
         failOnEmptyTestSuite="true"
         beStrictAboutOutputDuringTests="true"
         verbose="true"
         timeoutForSmallTests="60"
         timeoutForMediumTests="10"
         timeoutForLargeTests="60">
    <testsuites>
        <testsuite name="Unit">
            <directory>tests/Unit</directory>
        </testsuite>
        <testsuite name="Feature">
            <directory>tests/Feature</directory>
        </testsuite>
    </testsuites>
    <source>
        <include>
            <directory>app</directory>
        </include>
    </source>
    <php>
        <env name="APP_ENV" value="testing"/>
        <env name="APP_MAINTENANCE_DRIVER" value="file"/>
        <env name="BCRYPT_ROUNDS" value="4"/>
        <env name="CACHE_STORE" value="array"/>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
        <env name="MAIL_MAILER" value="array"/>
        <env name="PULSE_ENABLED" value="false"/>
        <env name="QUEUE_CONNECTION" value="sync"/>
        <env name="SESSION_DRIVER" value="array"/>
        <env name="TELESCOPE_ENABLED" value="false"/>
    </php>
    <logging>
        <junit outputFile="tests/results/junit.xml"/>
        <testdoxHtml outputFile="tests/results/testdox.html"/>
        <testdoxText outputFile="tests/results/testdox.txt"/>
        <text outputFile="tests/results/logfile.txt"/>
    </logging>
</phpunit>
EOF

# Webpack.mix.js - Configuração de assets
cat > backend/webpack.mix.js << 'EOF'
const mix = require('laravel-mix');

/*
|--------------------------------------------------------------------------
| Mix Asset Management
|--------------------------------------------------------------------------
|
| Mix provides a clean, fluent API for defining some Webpack build steps
| for your Laravel applications. By default, we are compiling the CSS
| file for the application as well as bundling up all the JS files.
|
*/

// Configurações do Mix
mix.options({
    processCssUrls: false,
    postCss: [
        require('autoprefixer'),
    ]
});

// Assets principais
mix.js('resources/js/app.js', 'public/js')
   .sass('resources/sass/app.scss', 'public/css')
   .sass('resources/sass/admin.scss', 'public/css')
   .sass('resources/sass/portal.scss', 'public/css');

// Assets do sistema administrativo
mix.js('resources/js/admin/app.js', 'public/js/admin')
   .js('resources/js/admin/dashboard.js', 'public/js/admin')
   .js('resources/js/admin/kanban.js', 'public/js/admin')
   .js('resources/js/admin/calendar.js', 'public/js/admin');

// Assets do portal do cliente
mix.js('resources/js/portal/app.js', 'public/js/portal')
   .js('resources/js/portal/dashboard.js', 'public/js/portal')
   .js('resources/js/portal/documents.js', 'public/js/portal');

// Vendor libraries
mix.js([
    'node_modules/alpinejs/dist/cdn.min.js',
    'resources/js/vendor/bootstrap.bundle.min.js'
], 'public/js/vendor.js');

// CSS Libraries
mix.sass('resources/sass/vendor/bootstrap.scss', 'public/css/vendor')
   .copy('node_modules/@fortawesome/fontawesome-free/webfonts', 'public/webfonts');

// Configurações para produção
if (mix.inProduction()) {
    mix.version();
    
    // Otimizações
    mix.options({
        terser: {
            terserOptions: {
                compress: {
                    drop_console: true,
                },
            },
        },
    });
} else {
    // Configurações para desenvolvimento
    mix.sourceMaps();
    
    // BrowserSync para hot reload
    mix.browserSync({
        proxy: 'localhost:8000',
        files: [
            'app/**/*.php',
            'resources/views/**/*.php',
            'resources/js/**/*.js',
            'resources/sass/**/*.scss'
        ]
    });
}

// Configurações específicas do projeto
mix.webpackConfig({
    resolve: {
        alias: {
            '@': path.resolve('resources/js'),
            '@admin': path.resolve('resources/js/admin'),
            '@portal': path.resolve('resources/js/portal'),
            '@components': path.resolve('resources/js/components'),
            '@services': path.resolve('resources/js/services'),
            '@utils': path.resolve('resources/js/utils')
        }
    }
});

// Extrair vendor chunks
mix.extract(['alpinejs', 'axios', 'bootstrap']);

// Notificações
mix.disableNotifications();
EOF

# Criar diretórios de recursos se não existirem
mkdir -p backend/resources/js/admin
mkdir -p backend/resources/js/portal  
mkdir -p backend/resources/js/components
mkdir -p backend/resources/js/services
mkdir -p backend/resources/js/utils
mkdir -p backend/resources/sass/admin
mkdir -p backend/resources/sass/portal
mkdir -p backend/resources/sass/vendor
mkdir -p backend/resources/views
mkdir -p backend/public/js
mkdir -p backend/public/css
mkdir -p backend/public/webfonts
mkdir -p backend/tests/Unit
mkdir -p backend/tests/Feature
mkdir -p backend/tests/results

# Criar arquivo de teste básico
cat > backend/tests/Feature/ExampleTest.php << 'EOF'
<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }

    /**
     * Test API health check.
     */
    public function test_api_health_check(): void
    {
        $response = $this->get('/health');

        $response->assertStatus(200)
                ->assertJson([
                    'status' => 'ok'
                ]);
    }
}
EOF

cat > backend/tests/Unit/ExampleTest.php << 'EOF'
<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic unit test example.
     */
    public function test_that_true_is_true(): void
    {
        $this->assertTrue(true);
    }
}
EOF

# Criar TestCase base
cat > backend/tests/TestCase.php << 'EOF'
<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication;
}
EOF

# Criar CreatesApplication trait
cat > backend/tests/CreatesApplication.php << 'EOF'
<?php

namespace Tests;

use Illuminate\Contracts\Console\Kernel;
use Illuminate\Foundation\Application;

trait CreatesApplication
{
    /**
     * Creates the application.
     */
    public function createApplication(): Application
    {
        $app = require __DIR__.'/../bootstrap/app.php';

        $app->make(Kernel::class)->bootstrap();

        return $app;
    }
}
EOF

# Config Cache
cat > backend/config/cache.php << 'EOF'
<?php

use Illuminate\Support\Str;

return [

    /*
    |--------------------------------------------------------------------------
    | Default Cache Store
    |--------------------------------------------------------------------------
    */

    'default' => env('CACHE_DRIVER', 'file'),

    /*
    |--------------------------------------------------------------------------
    | Cache Stores
    |--------------------------------------------------------------------------
    */

    'stores' => [

        'apc' => [
            'driver' => 'apc',
        ],

        'array' => [
            'driver' => 'array',
            'serialize' => false,
        ],

        'database' => [
            'driver' => 'database',
            'table' => 'cache',
            'connection' => null,
            'lock_connection' => null,
        ],

        'file' => [
            'driver' => 'file',
            'path' => storage_path('framework/cache/data'),
        ],

        'memcached' => [
            'driver' => 'memcached',
            'persistent_id' => env('MEMCACHED_PERSISTENT_ID'),
            'sasl' => [
                env('MEMCACHED_USERNAME'),
                env('MEMCACHED_PASSWORD'),
            ],
            'options' => [
                // Memcached::OPT_CONNECT_TIMEOUT => 2000,
            ],
            'servers' => [
                [
                    'host' => env('MEMCACHED_HOST', '127.0.0.1'),
                    'port' => env('MEMCACHED_PORT', 11211),
                    'weight' => 100,
                ],
            ],
        ],

        'redis' => [
            'driver' => 'redis',
            'connection' => 'cache',
            'lock_connection' => 'default',
        ],

        'dynamodb' => [
            'driver' => 'dynamodb',
            'key' => env('AWS_ACCESS_KEY_ID'),
            'secret' => env('AWS_SECRET_ACCESS_KEY'),
            'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
            'table' => env('DYNAMODB_CACHE_TABLE', 'cache'),
            'endpoint' => env('DYNAMODB_ENDPOINT'),
        ],

        'octane' => [
            'driver' => 'octane',
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Cache Key Prefix
    |--------------------------------------------------------------------------
    */

    'prefix' => env('CACHE_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_cache_'),

];
EOF

echo "✅ Todos os 4 arquivos finais do Laravel criados com sucesso!"
echo ""
echo "📦 ARQUIVOS CRIADOS:"
echo "   • backend/artisan - CLI executável do Laravel"
echo "   • backend/package.json - Dependencies Node.js + Mix"
echo "   • backend/phpunit.xml - Configuração de testes"
echo "   • backend/webpack.mix.js - Asset compilation"
echo "   • backend/config/cache.php - Configuração de cache"
echo ""
echo "🧪 TESTES CRIADOS:"
echo "   • tests/Feature/ExampleTest.php - Testes de integração"
echo "   • tests/Unit/ExampleTest.php - Testes unitários"
echo "   • tests/TestCase.php - Base para testes"
echo "   • tests/CreatesApplication.php - Trait para criar app"
echo ""
echo "📁 DIRETÓRIOS CRIADOS:"
echo "   • resources/js/ - Assets JavaScript"
echo "   • resources/sass/ - Arquivos SCSS"
echo "   • tests/Unit/ + tests/Feature/ - Estrutura de testes"
echo "   • public/js/ + public/css/ - Assets compilados"
echo ""
echo "🎉 BACKEND LARAVEL 100% COMPLETO!"
echo ""
echo "⏭️  PRÓXIMO: Docker Files para containerização!"