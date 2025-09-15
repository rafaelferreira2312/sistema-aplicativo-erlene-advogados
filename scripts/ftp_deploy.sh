#!/bin/bash

echo "📡 Conectando ao servidor FTP..."

lftp -u $PROD_FTP_USER,$PROD_FTP_PASS $PROD_FTP_HOST << EOF_LFTP
set ftp:ssl-allow no
set ssl:verify-certificate no

# Navegar para pasta raiz
cd $PROD_FTP_ROOT

# 1. DEPLOY DO FRONTEND
echo "📦 Deploy do Frontend..."
lcd frontend/build

# Criar pasta sistema se não existir
mkdir -p $PROD_FRONTEND_PATH

# Limpar pasta anterior (cuidado!)
rm -rf $PROD_FRONTEND_PATH/*

# Upload do build
mirror -R . $PROD_FRONTEND_PATH

# Voltar para local
lcd ../..

# 2. DEPLOY DO BACKEND
echo "⚙️  Deploy do Backend..."
lcd backend

# Criar pasta api se não existir
mkdir -p $PROD_BACKEND_PATH

# Upload de arquivos específicos (evitar node_modules, etc)
mirror -R --exclude-glob=node_modules/ --exclude-glob=.git/ --exclude-glob=storage/logs/ --exclude-glob=bootstrap/cache/ . $PROD_BACKEND_PATH

# Upload do .env de produção
put .env.production $PROD_BACKEND_PATH/.env

# Voltar para local
lcd ..

# 3. UPLOAD DO BANCO DE DADOS (se existe)
if [ -f "import_database.sql" ]; then
    echo "🗄️  Upload do script de banco..."
    put import_database.sql $PROD_BACKEND_PATH/import_database.sql
fi

# 4. UPLOAD DE ARQUIVOS DE CONFIGURAÇÃO
echo "📄 Upload de arquivos de configuração..."

# .htaccess para o frontend (SPA)
put - $PROD_FRONTEND_PATH/.htaccess << EOF_HTACCESS
RewriteEngine On
RewriteBase /sistema/

# Handle React Router
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /sistema/index.html [L]

# Cache estático
<filesMatch "\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
ExpiresActive On
ExpiresDefault "access plus 1 month"
</filesMatch>

# Compressão GZIP
<ifModule mod_gzip.c>
mod_gzip_on Yes
mod_gzip_dechunk Yes
mod_gzip_item_include file \.(html|txt|css|js|php|pl)$
mod_gzip_item_include mime ^application/javascript$
mod_gzip_item_include mime ^text/.*
</ifModule>
EOF_HTACCESS

# .htaccess para o backend (Laravel)
put - $PROD_BACKEND_PATH/.htaccess << EOF_LARAVEL
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
EOF_LARAVEL

echo "✅ Deploy FTP concluído!"
quit
EOF_LFTP
