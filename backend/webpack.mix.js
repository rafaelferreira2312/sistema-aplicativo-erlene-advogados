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
