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
