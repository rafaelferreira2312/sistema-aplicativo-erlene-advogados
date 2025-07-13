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
