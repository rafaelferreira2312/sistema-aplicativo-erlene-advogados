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
