#!/bin/bash

# Script 28 - Configurações Nginx, MySQL e Scripts Docker (Parte 2)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/28-create-docker-configs-part2.sh (executado da raiz do projeto)

echo "🐳 Criando configurações Nginx, MySQL e Scripts Docker (Parte 2)..."

# Nginx.conf principal
cat > docker/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Configurações de performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 20M;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;

    # Log format
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    'rt=$request_time uct="$upstream_connect_time" '
                    'uht="$upstream_header_time" urt="$upstream_response_time"';

    access_log /var/log/nginx/access.log main;

    # Include server configs
    include /etc/nginx/conf.d/*.conf;
}
EOF

# Default.conf - Configuração principal do servidor
cat > docker/nginx/default.conf << 'EOF'
# Upstream para PHP-FPM
upstream php-fpm {
    server php:9000;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name localhost erlene.local *.erlene.local;
    return 301 https://$server_name$request_uri;
}

# HTTPS Server - API Backend
server {
    listen 443 ssl http2;
    server_name localhost erlene.local;
    root /var/www/html/public;
    index index.php index.html;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # API Rate limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Auth endpoints with stricter rate limiting
    location ~ ^/api/auth/(login|refresh) {
        limit_req zone=login burst=5 nodelay;
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Handle PHP files
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php-fpm;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        
        # Performance settings
        fastcgi_buffering on;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_connect_timeout 60s;
        fastcgi_send_timeout 180s;
        fastcgi_read_timeout 180s;
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|pdf|txt)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Deny access to sensitive files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    location ~ /(composer\.(json|lock)|package\.(json|lock)|\.env) {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Default location
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
}

# Frontend Server
server {
    listen 443 ssl http2;
    server_name frontend.erlene.local;
    root /var/www/frontend;
    index index.html;

    # SSL Configuration (same as above)
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    # React Router - SPA handling
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # Static assets with caching
    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# SSL.conf - Configurações SSL extras
cat > docker/nginx/ssl.conf << 'EOF'
# SSL Security configurations
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /etc/nginx/ssl/nginx.crt;

# HSTS (HTTP Strict Transport Security)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# Additional security headers
add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive" always;
add_header X-Download-Options "noopen" always;
add_header X-Permitted-Cross-Domain-Policies "none" always;
EOF

# MySQL Dockerfile
cat > docker/mysql/Dockerfile << 'EOF'
FROM mysql:8.0

# Instalar dependências
RUN apt-get update && apt-get install -y \
    cron \
    gzip \
    && rm -rf /var/lib/apt/lists/*

# Copiar configuração customizada
COPY docker/mysql/my.cnf /etc/mysql/conf.d/custom.cnf

# Copiar scripts de inicialização
COPY docker/mysql/init.sql /docker-entrypoint-initdb.d/
COPY docker/mysql/backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Configurar cron para backup
RUN echo "0 2 * * * /usr/local/bin/backup.sh" | crontab -

EXPOSE 3306

CMD ["mysqld"]
EOF

# my.cnf - Configuração MySQL otimizada
cat > docker/mysql/my.cnf << 'EOF'
[mysqld]
# Configurações de performance
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT

# Configurações de conexão
max_connections = 200
max_connect_errors = 10000
thread_cache_size = 50
table_open_cache = 4000

# Configurações de query
query_cache_type = 1
query_cache_size = 256M
query_cache_limit = 2M

# Configurações de log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
log_queries_not_using_indexes = 1

# Configurações de charset
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Configurações de timezone
default-time-zone = '-03:00'

# Configurações de segurança
local-infile = 0
secure-file-priv = /var/lib/mysql-files/

# Configurações de binlog
log-bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7

[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4
EOF

# Script de inicialização MySQL
cat > docker/mysql/init.sql << 'EOF'
-- Configurações iniciais do banco
CREATE DATABASE IF NOT EXISTS erlene_advogados;
CREATE DATABASE IF NOT EXISTS erlene_testing;

-- Usuário principal
CREATE USER IF NOT EXISTS 'erlene_user'@'%' IDENTIFIED BY 'erlene_password';
GRANT ALL PRIVILEGES ON erlene_advogados.* TO 'erlene_user'@'%';
GRANT ALL PRIVILEGES ON erlene_testing.* TO 'erlene_user'@'%';

-- Usuário de backup
CREATE USER IF NOT EXISTS 'backup_user'@'%' IDENTIFIED BY 'backup_password';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON erlene_advogados.* TO 'backup_user'@'%';

-- Usuário de monitoramento
CREATE USER IF NOT EXISTS 'monitor_user'@'%' IDENTIFIED BY 'monitor_password';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'monitor_user'@'%';

FLUSH PRIVILEGES;

-- Configurações de timezone
SET GLOBAL time_zone = '-03:00';
EOF

# Script de backup MySQL
cat > docker/mysql/backup.sh << 'EOF'
#!/bin/bash

# Configurações
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
MYSQL_USER="backup_user"
MYSQL_PASS="backup_password"
DATABASE="erlene_advogados"

# Criar diretório de backup se não existir
mkdir -p $BACKUP_DIR

# Fazer backup
mysqldump -u$MYSQL_USER -p$MYSQL_PASS \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    --hex-blob \
    $DATABASE | gzip > $BACKUP_DIR/backup_${DATABASE}_${DATE}.sql.gz

# Manter apenas os últimos 7 backups
find $BACKUP_DIR -name "backup_${DATABASE}_*.sql.gz" -mtime +7 -delete

echo "Backup concluído: backup_${DATABASE}_${DATE}.sql.gz"
EOF

# Node.js Dockerfile
cat > docker/node/Dockerfile << 'EOF'
FROM node:18-alpine

# Instalar dependências
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++

# Configurar usuário
RUN addgroup -g 1001 -S nodejs \
    && adduser -S react -u 1001

# Definir diretório de trabalho
WORKDIR /app

# Copiar package files
COPY frontend/package*.json ./

# Instalar dependências
RUN npm ci --only=production

# Copiar código da aplicação
COPY --chown=react:nodejs frontend/ ./

# Mudar para usuário react
USER react

# Build da aplicação
RUN npm run build

# Expor porta
EXPOSE 3000

# Comando de inicialização
CMD ["npm", "start"]
EOF

# Docker Compose para produção
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  php:
    build:
      context: .
      dockerfile: docker/php/Dockerfile
      target: production
    container_name: erlene-php-prod
    restart: always
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
    volumes:
      - ./backend:/var/www/html:ro
      - php_storage:/var/www/html/storage
    networks:
      - erlene-network

  nginx:
    build:
      context: .
      dockerfile: docker/nginx/Dockerfile
    container_name: erlene-nginx-prod
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./backend:/var/www/html:ro
      - ./frontend/build:/var/www/frontend:ro
      - nginx_logs:/var/log/nginx
    networks:
      - erlene-network
    depends_on:
      - php

  mysql:
    build:
      context: .
      dockerfile: docker/mysql/Dockerfile
    container_name: erlene-mysql-prod
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - mysql_data_prod:/var/lib/mysql
      - mysql_backups:/backups
    networks:
      - erlene-network

  redis:
    image: redis:7-alpine
    container_name: erlene-redis-prod
    restart: always
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data_prod:/data
    networks:
      - erlene-network

volumes:
  php_storage:
  nginx_logs:
  mysql_data_prod:
  mysql_backups:
  redis_data_prod:

networks:
  erlene-network:
    driver: bridge
EOF

# Docker Compose para desenvolvimento
cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  php:
    build:
      context: .
      dockerfile: docker/php/Dockerfile
      target: development
    environment:
      - APP_ENV=local
      - APP_DEBUG=true
    volumes:
      - ./backend:/var/www/html
    ports:
      - "9000:9000"

  mysql:
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: erlene_advogados
      MYSQL_USER: erlene_user
      MYSQL_PASSWORD: password

  redis:
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes

  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: erlene-phpmyadmin
    ports:
      - "8081:80"
    environment:
      PMA_HOST: mysql
      PMA_USER: root
      PMA_PASSWORD: root
    networks:
      - erlene-network
    depends_on:
      - mysql

extends:
  file: docker-compose.yml
  service: php
EOF

echo "✅ Configurações Docker Parte 2 criadas com sucesso!"
echo ""
echo "📊 Arquivos criados:"
echo "   • docker/nginx/nginx.conf - Nginx otimizado com gzip e rate limiting"
echo "   • docker/nginx/default.conf - Virtual hosts (API + Frontend)"
echo "   • docker/nginx/ssl.conf - Configurações SSL/TLS seguras"
echo "   • docker/mysql/Dockerfile - MySQL 8.0 com backup automático"
echo "   • docker/mysql/my.cnf - MySQL otimizado para performance"
echo "   • docker/mysql/init.sql - Setup inicial de usuários/databases"
echo "   • docker/mysql/backup.sh - Script de backup automático"
echo "   • docker/node/Dockerfile - Node.js 18 Alpine otimizado"
echo "   • docker-compose.prod.yml - Configuração de produção"
echo "   • docker-compose.dev.yml - Configuração de desenvolvimento"
echo ""
echo "🔧 Funcionalidades configuradas:"
echo "   • Rate limiting (API: 10/s, Login: 1/s)"
echo "   • SSL/TLS com headers de segurança"
echo "   • Backup MySQL automático (diário às 2h)"
echo "   • Cache estático (1 ano para assets)"
echo "   • PHPMyAdmin no ambiente dev"
echo "   • Logs estruturados"
echo ""
echo "⏭️  Digite 'continuar' para criar scripts de inicialização (Parte 3 Final)..."