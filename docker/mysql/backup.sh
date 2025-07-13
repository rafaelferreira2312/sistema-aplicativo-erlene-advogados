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
