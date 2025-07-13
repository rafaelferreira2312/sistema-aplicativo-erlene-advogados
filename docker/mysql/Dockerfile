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
