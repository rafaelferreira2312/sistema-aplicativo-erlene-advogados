#!/bin/bash

# Script 31 - Corrigir MySQL Dockerfile e outros erros Docker
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/31-fix-mysql-dockerfile.sh (executado da raiz do projeto)

echo "🔧 Corrigindo MySQL Dockerfile e outros erros Docker..."

# Corrigir MySQL Dockerfile (usar apt-get corretamente)
cat > docker/mysql/Dockerfile << 'EOF'
FROM mysql:8.0

# Instalar dependências (MySQL usa Debian/Ubuntu, não Alpine)
RUN apt-get update && apt-get install -y \
    cron \
    gzip \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Copiar configuração customizada
COPY docker/mysql/my.cnf /etc/mysql/conf.d/custom.cnf

# Copiar scripts de inicialização
COPY docker/mysql/init.sql /docker-entrypoint-initdb.d/
COPY docker/mysql/backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Configurar cron para backup (comentado por enquanto)
# RUN echo "0 2 * * * /usr/local/bin/backup.sh" | crontab -

# Criar diretório de backup
RUN mkdir -p /backups && chown mysql:mysql /backups

EXPOSE 3306

CMD ["mysqld"]
EOF

# Simplificar Docker Compose (remover version obsoleta)
cat > docker-compose.yml << 'EOF'
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

# Simplificar PHP Dockerfile (remover supervisor por enquanto)
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
    libgd-dev \
    libicu-dev \
    zip \
    unzip \
    nano \
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
        opcache \
    && rm -rf /var/lib/apt/lists/*

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

# Criar diretórios necessários
RUN mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/bootstrap/cache

# Definir permissões
RUN chown -R www:www /var/www/html

# Expor porta
EXPOSE 9000

# Comando de inicialização
CMD ["php-fpm"]
EOF

# Criar arquivo .env padrão se não existir
if [ ! -f .env ]; then
    cat > .env << 'EOF'
# Aplicação
APP_NAME="Sistema Erlene Advogados"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=https://localhost:8443
FRONTEND_URL=https://localhost:8443

# Banco de Dados
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=erlene_advogados
DB_USERNAME=erlene_user
DB_PASSWORD=erlene_password

# MySQL Root
MYSQL_ROOT_PASSWORD=erlene_root_password
MYSQL_DATABASE=erlene_advogados
MYSQL_USER=erlene_user
MYSQL_PASSWORD=erlene_password

# Redis
REDIS_HOST=redis
REDIS_PASSWORD=erlene_redis_password
REDIS_PORT=6379

# JWT
JWT_SECRET=base64:your-secret-key-here
JWT_TTL=60
JWT_REFRESH_TTL=20160

# Email
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="noreply@erleneadvogados.com.br"
MAIL_FROM_NAME="Erlene Advogados"

# Cache/Session
CACHE_DRIVER=file
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Queue
QUEUE_CONNECTION=sync

# Filesystem
FILESYSTEM_DISK=local
EOF
fi

# Copiar .env para backend se não existir
if [ ! -f backend/.env ]; then
    cp .env backend/.env
fi

# Corrigir permissões
chmod -R 755 storage/ 2>/dev/null || true
chmod -R 755 backend/storage/ 2>/dev/null || true
chmod +x scripts/*.sh

echo "✅ Correções aplicadas!"
echo ""
echo "🔧 CORREÇÕES FEITAS:"
echo "   • MySQL Dockerfile corrigido (apt-get em vez de apk)"
echo "   • Docker Compose simplificado (removido version obsoleta)"
echo "   • PHP Dockerfile simplificado (removido supervisor)"
echo "   • Arquivo .env criado com valores padrão"
echo "   • Permissões corrigidas"
echo ""
echo "🚀 AGORA TESTE:"
echo "   1. make clean  # Limpar containers antigos"
echo "   2. make setup  # Executar setup novamente"
echo ""
echo "💡 Se ainda der erro, use:"
echo "   docker system prune -a  # Limpar tudo do Docker"
echo "   make setup              # Tentar novamente"
EOF

chmod +x scripts/31-fix-mysql-dockerfile.sh

echo "✅ Script de correção criado!"
echo ""
echo "🔧 EXECUTE AGORA:"
echo "   ./scripts/31-fix-mysql-dockerfile.sh"
echo "   make clean"
echo "   make setup"
echo ""
echo "💡 PROBLEMAS CORRIGIDOS:"
echo "   • MySQL Dockerfile (apt-get vs apk)"
echo "   • Docker Compose version obsoleta"
echo "   • PHP Dockerfile simplificado" 
echo "   • Arquivo .env padrão"