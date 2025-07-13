#!/bin/bash

# Script 27 - Criação dos Docker Files Completos
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/27-create-docker-files.sh (executado da raiz do projeto)

echo "🐳 Criando Docker Files completos..."

# Docker Compose principal
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # PHP-FPM Backend
  php:
    build:
      context: .
      dockerfile: docker/php/Dockerfile
    container_name: erlene-php
    restart: unless-stopped
    working_dir: /var/www/html
    volumes:
      - ./backend:/var/www/html
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
      - ./docker/php/opcache.ini:/usr/local/etc/php/conf.d/opcache.ini
      - ./docker/php/www.conf:/usr/local/etc/php-fpm.d/www.conf
    environment:
      - PHP_IDE_CONFIG=serverName=erlene-docker
    networks:
      - erlene-network
    depends_on:
      - mysql
      - redis

  # Nginx Web Server
  nginx:
    build:
      context: .
      dockerfile: docker/nginx/Dockerfile
    container_name: erlene-nginx
    restart: unless-stopped
    ports:
      - "8080:80"
      - "8443:443"
    volumes:
      - ./backend:/var/www/html
      - ./frontend/build:/var/www/frontend
      - ./docker/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf
      - ./docker/nginx/ssl.conf:/etc/nginx/conf.d/ssl.conf
      - ./storage/logs/nginx:/var/log/nginx
    networks:
      - erlene-network
    depends_on:
      - php

  # MySQL Database
  mysql:
    build:
      context: .
      dockerfile: docker/mysql/Dockerfile
    container_name: erlene-mysql
    restart: unless-stopped
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: erlene_root_password
      MYSQL_DATABASE: erlene_advogados
      MYSQL_USER: erlene_user
      MYSQL_PASSWORD: erlene_password
    volumes:
      - mysql_data:/var/lib/mysql
      - ./docker/mysql/my.cnf:/etc/mysql/conf.d/custom.cnf
      - ./storage/backups/mysql:/backups
    networks:
      - erlene-network

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: erlene-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes --requirepass erlene_redis_password
    volumes:
      - redis_data:/data
    networks:
      - erlene-network

  # Node.js para Frontend
  node:
    build:
      context: .
      dockerfile: docker/node/Dockerfile
    container_name: erlene-node
    restart: unless-stopped
    working_dir: /app
    volumes:
      - ./frontend:/app
      - node_modules:/app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - REACT_APP_API_URL=http://localhost:8080/api
    networks:
      - erlene-network
    command: npm start

  # Mailpit (Email Testing)
  mailpit:
    image: axllent/mailpit:latest
    container_name: erlene-mailpit
    restart: unless-stopped
    ports:
      - "8025:8025"
      - "1025:1025"
    networks:
      - erlene-network

volumes:
  mysql_data:
    driver: local
  redis_data:
    driver: local
  node_modules:
    driver: local

networks:
  erlene-network:
    driver: bridge
EOF

# Dockerfile PHP
cat > docker/php/Dockerfile << 'EOF'
FROM php:8.2-fpm

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libgd-dev \
    libicu-dev \
    zip \
    unzip \
    nano \
    cron \
    supervisor \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        opcache

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Instalar Node.js (para Laravel Mix)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Criar usuário www
RUN groupadd -g 1000 www \
    && useradd -u 1000 -ms /bin/bash -g www www

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar arquivos de configuração
COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Copiar supervisor config
COPY docker/php/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Criar diretórios necessários
RUN mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/bootstrap/cache

# Definir permissões
RUN chown -R www:www /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Copiar código da aplicação
COPY --chown=www:www backend/ /var/www/html/

# Mudar para usuário www
USER www

# Instalar dependências do Composer
RUN composer install --no-dev --optimize-autoloader

# Voltar para root para comandos finais
USER root

# Expor porta
EXPOSE 9000

# Comando de inicialização
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
EOF

# PHP.ini customizado
cat > docker/php/php.ini << 'EOF'
[PHP]
; Configurações de desenvolvimento/produção
display_errors = Off
log_errors = On
error_log = /var/log/php_errors.log

; Configurações de memória
memory_limit = 512M
max_execution_time = 300
max_input_time = 300

; Upload de arquivos
upload_max_filesize = 20M
post_max_size = 20M
max_file_uploads = 20

; Timezone
date.timezone = America/Sao_Paulo

; Session
session.gc_maxlifetime = 7200
session.cookie_lifetime = 0

; Realpath cache
realpath_cache_size = 4096K
realpath_cache_ttl = 600

; OPcache (configurado em arquivo separado)
; Configurações de segurança
expose_php = Off
allow_url_fopen = Off
allow_url_include = Off

; Configurações de charset
default_charset = "UTF-8"
EOF

# OPcache.ini
cat > docker/php/opcache.ini << 'EOF'
[opcache]
; Enable OPcache
opcache.enable=1
opcache.enable_cli=1

; Memory settings
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000

; Performance settings
opcache.revalidate_freq=2
opcache.validate_timestamps=1
opcache.save_comments=1
opcache.enable_file_override=1

; Security
opcache.blacklist_filename=/var/www/html/opcache.blacklist

; JIT (PHP 8.0+)
opcache.jit=1255
opcache.jit_buffer_size=128M
EOF

# www.conf para PHP-FPM
cat > docker/php/www.conf << 'EOF'
[www]
user = www
group = www
listen = 9000
listen.owner = www
listen.group = www
listen.mode = 0660

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 1000

; Logs
access.log = /var/log/php-fpm-access.log
slowlog = /var/log/php-fpm-slow.log
request_slowlog_timeout = 10s

; Environment variables
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp

; Security
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
EOF

# Supervisord config
cat > docker/php/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[program:php-fpm]
command=php-fpm
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/php-fpm.log
stderr_logfile=/var/log/supervisor/php-fpm-error.log

[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/artisan queue:work --sleep=3 --tries=3
autostart=true
autorestart=true
user=www
numprocs=2
redirect_stderr=true
stdout_logfile=/var/log/supervisor/worker.log

[program:cron]
command=cron -f
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/cron.log
stderr_logfile=/var/log/supervisor/cron-error.log
EOF

# Dockerfile Nginx
cat > docker/nginx/Dockerfile << 'EOF'
FROM nginx:1.24-alpine

# Instalar dependências
RUN apk add --no-cache \
    curl \
    openssl

# Copiar configurações
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Criar diretórios necessários
RUN mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx \
    && mkdir -p /etc/nginx/ssl

# Gerar certificado SSL autoassinado (desenvolvimento)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=BR/ST=RJ/L=RioDeJaneiro/O=ErleneAdvogados/CN=localhost"

# Definir permissões
RUN chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
EOF

echo "✅ Docker Files principais criados!"
echo "📊 Arquivos criados nesta parte:"
echo "   • docker-compose.yml - Orquestração completa"
echo "   • docker/php/Dockerfile - Container PHP 8.2 + Laravel"
echo "   • docker/php/php.ini - Configuração PHP otimizada"
echo "   • docker/php/opcache.ini - OPcache + JIT ativado"
echo "   • docker/php/www.conf - PHP-FPM configurado"
echo "   • docker/php/supervisord.conf - Queue workers + Cron"
echo "   • docker/nginx/Dockerfile - Nginx otimizado"
echo ""
echo "⏭️  Digite 'continuar' para criar configs Nginx e MySQL (Parte 2)..."