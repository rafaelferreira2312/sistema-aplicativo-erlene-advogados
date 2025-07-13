#!/bin/bash

# Backup completo do sistema
BACKUP_DIR="storage/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "💾 Iniciando backup completo..."

# Criar diretório de backup
mkdir -p $BACKUP_DIR/$DATE

# Backup do banco de dados
echo "📊 Fazendo backup do banco de dados..."
docker-compose exec mysql mysqldump -u erlene_user -p'erlene_password' \
    --single-transaction --routines --triggers erlene_advogados \
    | gzip > $BACKUP_DIR/$DATE/database.sql.gz

# Backup dos uploads
echo "📁 Fazendo backup dos arquivos..."
tar -czf $BACKUP_DIR/$DATE/uploads.tar.gz backend/storage/app/clients/

# Backup das configurações
echo "⚙️ Fazendo backup das configurações..."
cp .env $BACKUP_DIR/$DATE/
cp backend/.env $BACKUP_DIR/$DATE/backend.env

# Backup dos logs
echo "📝 Fazendo backup dos logs..."
tar -czf $BACKUP_DIR/$DATE/logs.tar.gz storage/logs/

echo "✅ Backup concluído em: $BACKUP_DIR/$DATE"

# Limpar backups antigos (manter últimos 7 dias)
find $BACKUP_DIR -type d -mtime +7 -exec rm -rf {} +

echo "🧹 Backups antigos removidos"
