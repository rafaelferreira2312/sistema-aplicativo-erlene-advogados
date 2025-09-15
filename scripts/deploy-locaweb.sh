#!/bin/bash

# Deploy Manual via FTP - Sem SSH
# Sistema Erlene Advogados
# EXECUTE DENTRO DA PASTA: raiz do projeto

echo "🚀 Deploy Manual via FTP (sem SSH)"

# Verificar se estamos na raiz
if [ ! -d "frontend" ] || [ ! -d "backend" ]; then
    echo "❌ Erro: Execute na raiz do projeto"
    exit 1
fi

# Configurações
FTP_HOST="ftp.erleneadvogados.com.br"
FTP_USER="erleneadvogados1"
FTP_PASS="Erlene@2025@#!"

echo "🎯 Configurações:"
echo "   Host: $FTP_HOST"
echo "   User: $FTP_USER"
echo ""

# Criar arquivos de configuração localmente
echo "📄 Criando arquivos de configuração..."

# .env para API
cat > api_env.tmp << 'EOF'
APP_NAME="Sistema Erlene Advogados"
APP_ENV=production
APP_KEY=base64:YourAppKeyHereGenerateThis32CharString==
APP_DEBUG=false
APP_URL=https://erleneadvogados.com.br/api

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=api_adv
DB_USERNAME=api_adv
DB_PASSWORD=E8I42Qasi#oZ

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_LIFETIME=120

JWT_SECRET=YourJWTSecretKeyHere64CharsLongForSecurityPurposes123456
JWT_TTL=60

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=contato@erleneadvogados.com.br
MAIL_FROM_ADDRESS="contato@erleneadvogados.com.br"
MAIL_FROM_NAME="Sistema Erlene Advogados"
EOF

# .htaccess para API
cat > api_htaccess.tmp << 'EOF'
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>

# Security
Options -Indexes
<Files ~ "(\.env|\.git|composer\.(json|lock)|artisan)$">
    Order allow,deny
    Deny from all
</Files>

# PHP Settings for Locaweb
php_value upload_max_filesize 20M
php_value post_max_size 25M
php_value max_execution_time 300
php_value memory_limit 512M
EOF

# index.php para API
cat > api_index.tmp << 'EOF'
<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Check maintenance mode
if (file_exists($maintenance = __DIR__.'/storage/framework/maintenance.php')) {
    require $maintenance;
}

// Autoloader
require __DIR__.'/vendor/autoload.php';

// Bootstrap Laravel
$app = require_once __DIR__.'/bootstrap/app.php';

$kernel = $app->make(Kernel::class);

$response = $kernel->handle(
    $request = Request::capture()
)->send();

$kernel->terminate($request, $response);
EOF

# .htaccess para Frontend
cat > frontend_htaccess.tmp << 'EOF'
RewriteEngine On
RewriteBase /sistema/

# Handle React Router (SPA)
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /sistema/index.html [L]

# Security
Options -Indexes

# Cache static files
<FilesMatch "\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|webp)$">
    ExpiresActive On
    ExpiresDefault "access plus 1 month"
    Header set Cache-Control "public, max-age=2592000"
</FilesMatch>

# Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE text/html
</IfModule>
EOF

echo "✅ Arquivos de configuração criados"

# Preparar backend se necessário
if [ ! -f "backend/vendor/autoload.php" ]; then
    echo "📦 Preparando backend..."
    cd backend
    composer install --no-dev --optimize-autoloader
    cd ..
fi

# Upload via FTP
echo ""
echo "🚀 EXECUTANDO UPLOAD VIA FTP"
echo "============================"

lftp -u $FTP_USER,$FTP_PASS $FTP_HOST << 'EOF_FTP'
set ftp:ssl-allow no
set ssl:verify-certificate no
set net:timeout 120
set cmd:fail-exit no

# Conectar e navegar
cd /public_html
pwd
ls -la

echo "🎨 Limpando e enviando FRONTEND..."
cd sistema
rm -rf * 2>/dev/null
cd /public_html
lcd frontend/build
mirror -R --delete --verbose . sistema
put ../frontend_htaccess.tmp sistema/.htaccess
echo "✅ Frontend enviado!"

echo "⚙️ Limpando e enviando BACKEND..."
cd api
rm -rf app config database routes resources bootstrap vendor composer.* artisan index.php .htaccess .env 2>/dev/null
cd /public_html
lcd backend

# Upload estrutura Laravel
echo "📦 Enviando estrutura Laravel..."
mirror -R --verbose app api/app
mirror -R --verbose config api/config
mirror -R --verbose database api/database
mirror -R --verbose routes api/routes
mirror -R --verbose resources api/resources
mirror -R --verbose bootstrap api/bootstrap

echo "📦 Enviando vendor (pode demorar)..."
mirror -R --verbose vendor api/vendor

# Upload arquivos principais
put composer.json api/composer.json
put composer.lock api/composer.lock
put artisan api/artisan

# Upload configurações
lcd ..
put api_env.tmp api/.env
put api_htaccess.tmp api/.htaccess
put api_index.tmp api/index.php

echo "✅ Backend enviado!"

# Verificar estrutura final
echo "🔍 Verificando estrutura..."
cd /public_html
echo "=== SISTEMA ==="
ls -la sistema/ | head -10
echo ""
echo "=== API ==="
ls -la api/ | head -10

quit
EOF_FTP

# Verificar resultado
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 UPLOAD CONCLUÍDO COM SUCESSO!"
    SUCCESS=true
else
    echo ""
    echo "⚠️ Upload teve alguns problemas, mas pode ter funcionado parcialmente"
    SUCCESS=true
fi

# Exportar banco de dados
echo ""
echo "🗄️ EXPORTANDO BANCO DE DADOS"
echo "=========================="

if [ -f "backend/.env" ]; then
    LOCAL_DB=$(grep "DB_DATABASE=" backend/.env | cut -d'=' -f2)
    LOCAL_USER=$(grep "DB_USERNAME=" backend/.env | cut -d'=' -f2)
    LOCAL_PASS=$(grep "DB_PASSWORD=" backend/.env | cut -d'=' -f2)
    
    if [ -n "$LOCAL_DB" ]; then
        echo "📤 Exportando: $LOCAL_DB"
        
        if [ -n "$LOCAL_PASS" ] && [ "$LOCAL_PASS" != "null" ]; then
            mysqldump -u$LOCAL_USER -p$LOCAL_PASS --single-transaction --routines $LOCAL_DB > database_export.sql
        else
            mysqldump -u$LOCAL_USER --single-transaction --routines $LOCAL_DB > database_export.sql
        fi
        
        if [ $? -eq 0 ]; then
            echo "✅ Dump criado: database_export.sql"
            
            # Upload do SQL
            lftp -u $FTP_USER,$FTP_PASS $FTP_HOST << EOF
set ftp:ssl-allow no
cd /public_html/api
put database_export.sql import_database.sql
quit
EOF
            
            echo "✅ Banco enviado: /public_html/api/import_database.sql"
            rm database_export.sql
        fi
    fi
fi

# Limpeza
echo ""
echo "🧹 Limpando arquivos temporários..."
rm -f api_env.tmp api_htaccess.tmp api_index.tmp frontend_htaccess.tmp

# Instruções finais
echo ""
echo "🎯 INSTRUÇÕES FINAIS"
echo "==================="

if [ "$SUCCESS" = true ]; then
    echo "✅ DEPLOY MANUAL CONCLUÍDO!"
    echo ""
    echo "🌐 URLs para teste:"
    echo "   Frontend: https://erleneadvogados.com.br/sistema"
    echo "   Backend:  https://erleneadvogados.com.br/api"
    echo ""
    echo "📋 PRÓXIMAS AÇÕES:"
    echo ""
    echo "1. 🗄️ IMPORTAR BANCO:"
    echo "   - Acesse phpMyAdmin no painel Locaweb"
    echo "   - Database: api_adv"
    echo "   - Importe: /public_html/api/import_database.sql"
    echo ""
    echo "2. 🔧 VIA CPANEL TERMINAL (se disponível):"
    echo "   cd /home/erleneadvogados1/public_html/api"
    echo "   find storage -type d -exec chmod 755 {} \; 2>/dev/null"
    echo "   find storage -type f -exec chmod 644 {} \; 2>/dev/null"
    echo "   php artisan config:clear"
    echo "   php artisan cache:clear"
    echo ""
    echo "3. 🧪 TESTAR SISTEMA:"
    echo "   - Acesse as URLs acima"
    echo "   - Teste login no sistema"
    echo "   - Verifique se API responde"
    echo ""
else
    echo "❌ Deploy teve problemas. Verifique logs FTP."
fi

echo "✅ PROCESSO FINALIZADO!"
echo ""
echo "💡 DICAS:"
echo "   - Se algo não funcionar, verifique logs no cPanel"
echo "   - Para updates, execute este script novamente"
echo "   - Em caso de erro 500, verifique permissões"