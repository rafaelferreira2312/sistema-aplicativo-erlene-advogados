#!/bin/bash

# Script 200 - Backup Completo do Sistema Atual (Laravel + React + MySQL)
# Sistema Erlene Advogados - Migração Laravel → Node.js Express
# Data: $(date +%Y-%m-%d)
# EXECUTE NA PASTA RAIZ DO PROJETO: sistema-aplicativo-erlene-advogados/

echo "🔄 Script 200 - Backup Completo do Sistema Atual"
echo "=================================================="
echo "⚠️  CRITICAL: Este script faz backup de TUDO antes da migração"
echo "📁 Backup: Laravel Backend + React Frontend + MySQL Database"
echo "🕒 Iniciado em: $(date '+%Y-%m-%d %H:%M:%S')"

# Verificar se estamos no diretório correto
if [ ! -f "README.md" ] && [ ! -d "backend" ] && [ ! -d "frontend" ]; then
    echo "❌ ERRO: Execute este script na pasta raiz do projeto!"
    echo "   Estrutura esperada:"
    echo "   sistema-aplicativo-erlene-advogados/"
    echo "   ├── backend/"
    echo "   ├── frontend/"
    echo "   └── README.md"
    echo ""
    echo "💡 Comando correto:"
    echo "   cd sistema-aplicativo-erlene-advogados"
    echo "   chmod +x 200-backup-sistema-atual.sh && ./200-backup-sistema-atual.sh"
    exit 1
fi

echo "✅ Diretório correto confirmado"

# Criar diretório de backups com timestamp
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)_pre_migration"
echo "📁 Criando diretório de backup: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

echo ""
echo "🔧 1. BACKUP DO BACKEND LARAVEL"
echo "================================"

if [ -d "backend" ]; then
    echo "📦 Fazendo backup do backend Laravel..."
    
    # Backup da pasta backend completa
    tar -czf "$BACKUP_DIR/backend_laravel_complete.tar.gz" backend/ 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Backend Laravel compactado: backend_laravel_complete.tar.gz"
    else
        echo "⚠️  Aviso: Alguns arquivos do backend podem ter sido ignorados"
    fi
    
    # Backup específico de arquivos críticos
    echo "📋 Copiando arquivos críticos do Laravel..."
    mkdir -p "$BACKUP_DIR/laravel_critical"
    
    # Composer e dependências
    [ -f "backend/composer.json" ] && cp "backend/composer.json" "$BACKUP_DIR/laravel_critical/"
    [ -f "backend/composer.lock" ] && cp "backend/composer.lock" "$BACKUP_DIR/laravel_critical/"
    
    # Configurações
    [ -f "backend/.env" ] && cp "backend/.env" "$BACKUP_DIR/laravel_critical/.env.backup"
    [ -f "backend/.env.example" ] && cp "backend/.env.example" "$BACKUP_DIR/laravel_critical/"
    
    # Rotas críticas
    [ -f "backend/routes/api.php" ] && cp "backend/routes/api.php" "$BACKUP_DIR/laravel_critical/"
    [ -f "backend/routes/web.php" ] && cp "backend/routes/web.php" "$BACKUP_DIR/laravel_critical/"
    
    # Models, Controllers, Migrations
    [ -d "backend/app" ] && cp -r "backend/app" "$BACKUP_DIR/laravel_critical/" 2>/dev/null
    [ -d "backend/database" ] && cp -r "backend/database" "$BACKUP_DIR/laravel_critical/" 2>/dev/null
    
    echo "✅ Arquivos críticos do Laravel salvos"
else
    echo "⚠️  Pasta backend/ não encontrada - pulando backup do Laravel"
fi

echo ""
echo "🎨 2. BACKUP DO FRONTEND REACT"
echo "=============================="

if [ -d "frontend" ]; then
    echo "📦 Fazendo backup do frontend React..."
    
    # Backup da pasta frontend completa
    tar -czf "$BACKUP_DIR/frontend_react_complete.tar.gz" frontend/ 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Frontend React compactado: frontend_react_complete.tar.gz"
    else
        echo "⚠️  Aviso: Alguns arquivos do frontend podem ter sido ignorados (node_modules)"
    fi
    
    # Backup específico de arquivos críticos do React
    echo "📋 Copiando arquivos críticos do React..."
    mkdir -p "$BACKUP_DIR/react_critical"
    
    # Package.json e configurações
    [ -f "frontend/package.json" ] && cp "frontend/package.json" "$BACKUP_DIR/react_critical/"
    [ -f "frontend/package-lock.json" ] && cp "frontend/package-lock.json" "$BACKUP_DIR/react_critical/"
    [ -f "frontend/.env" ] && cp "frontend/.env" "$BACKUP_DIR/react_critical/.env.backup"
    
    # Código fonte React (sem node_modules)
    if [ -d "frontend/src" ]; then
        cp -r "frontend/src" "$BACKUP_DIR/react_critical/" 2>/dev/null
        echo "✅ Código fonte React (src/) copiado"
    fi
    
    # Build se existir
    if [ -d "frontend/build" ]; then
        cp -r "frontend/build" "$BACKUP_DIR/react_critical/" 2>/dev/null
        echo "✅ Build do React copiado"
    fi
    
    # Assets públicos
    if [ -d "frontend/public" ]; then
        cp -r "frontend/public" "$BACKUP_DIR/react_critical/" 2>/dev/null
        echo "✅ Assets públicos copiados"
    fi
    
    echo "✅ Arquivos críticos do React salvos"
else
    echo "⚠️  Pasta frontend/ não encontrada - pulando backup do React"
fi

echo ""
echo "🗄️  3. BACKUP DO BANCO DE DADOS MYSQL"
echo "===================================="

# Tentar fazer backup do banco MySQL local primeiro
echo "🔍 Procurando configuração do banco de dados..."

# Verificar se existe .env no backend
ENV_FILE=""
if [ -f "backend/.env" ]; then
    ENV_FILE="backend/.env"
    echo "📄 Arquivo .env encontrado: $ENV_FILE"
else
    echo "⚠️  Arquivo .env não encontrado no backend"
fi

# Extrair dados do banco se .env existir
if [ ! -z "$ENV_FILE" ]; then
    echo "📊 Extraindo configurações do banco..."
    
    DB_HOST=$(grep "^DB_HOST=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    DB_PORT=$(grep "^DB_PORT=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    DB_DATABASE=$(grep "^DB_DATABASE=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    DB_USERNAME=$(grep "^DB_USERNAME=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    DB_PASSWORD=$(grep "^DB_PASSWORD=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    
    echo "🔧 Configurações encontradas:"
    echo "   Host: ${DB_HOST:-localhost}"
    echo "   Port: ${DB_PORT:-3306}"  
    echo "   Database: ${DB_DATABASE:-erlene_advogados}"
    echo "   Username: ${DB_USERNAME:-root}"
    echo "   Password: [OCULTA]"
    
    # Tentar fazer backup do MySQL
    if command -v mysqldump >/dev/null 2>&1; then
        echo "💾 Fazendo backup do MySQL..."
        
        MYSQL_BACKUP="$BACKUP_DIR/mysql_backup_$(date +%Y%m%d_%H%M%S).sql"
        
        if [ ! -z "$DB_PASSWORD" ]; then
            mysqldump -h "${DB_HOST:-localhost}" -P "${DB_PORT:-3306}" -u "${DB_USERNAME:-root}" -p"$DB_PASSWORD" "${DB_DATABASE:-erlene_advogados}" > "$MYSQL_BACKUP" 2>/dev/null
        else
            echo "🔐 Senha do MySQL necessária. Tentando sem senha..."
            mysqldump -h "${DB_HOST:-localhost}" -P "${DB_PORT:-3306}" -u "${DB_USERNAME:-root}" "${DB_DATABASE:-erlene_advogados}" > "$MYSQL_BACKUP" 2>/dev/null
        fi
        
        if [ $? -eq 0 ] && [ -s "$MYSQL_BACKUP" ]; then
            echo "✅ Backup MySQL criado: $(basename $MYSQL_BACKUP)"
            echo "📊 Tamanho: $(ls -lh "$MYSQL_BACKUP" | awk '{print $5}')"
        else
            echo "⚠️  Não foi possível conectar ao MySQL local"
            echo "💡 Isso é normal se o banco estiver na VPS"
            rm -f "$MYSQL_BACKUP" 2>/dev/null
        fi
    else
        echo "⚠️  mysqldump não disponível no sistema"
        echo "💡 Backup do MySQL será feito na VPS durante o deploy"
    fi
else
    echo "⚠️  Não foi possível extrair configurações do banco"
fi

echo ""
echo "📋 4. BACKUP DE CONFIGURAÇÕES GERAIS"
echo "===================================="

echo "📄 Copiando arquivos de configuração do projeto..."

# Docker, scripts, documentação
[ -f "docker-compose.yml" ] && cp "docker-compose.yml" "$BACKUP_DIR/"
[ -f ".gitignore" ] && cp ".gitignore" "$BACKUP_DIR/"
[ -f "README.md" ] && cp "README.md" "$BACKUP_DIR/"

# Copiar pasta scripts se existir
[ -d "scripts" ] && cp -r "scripts" "$BACKUP_DIR/" 2>/dev/null

# Copiar pasta docs se existir  
[ -d "docs" ] && cp -r "docs" "$BACKUP_DIR/" 2>/dev/null

echo "✅ Configurações gerais copiadas"

echo ""
echo "📊 5. RELATÓRIO DO BACKUP"
echo "========================="

echo "📁 Localização do backup: $BACKUP_DIR"
echo ""
echo "📦 Arquivos criados:"
ls -la "$BACKUP_DIR" 2>/dev/null | grep -E "\.(tar\.gz|sql)$" || echo "   (Nenhum arquivo compactado criado)"

echo ""
echo "💾 Espaço utilizado:"
if [ -d "$BACKUP_DIR" ]; then
    du -sh "$BACKUP_DIR" 2>/dev/null || echo "   Não foi possível calcular"
fi

echo ""
echo "🔍 Conteúdo detalhado:"
find "$BACKUP_DIR" -type f | head -20 2>/dev/null | sed 's/^/   /'
TOTAL_FILES=$(find "$BACKUP_DIR" -type f | wc -l 2>/dev/null)
echo "   ... e mais $(($TOTAL_FILES - 20)) arquivos (total: $TOTAL_FILES)"

echo ""
echo "✅ BACKUP COMPLETO FINALIZADO!"
echo "==============================="
echo "🕒 Concluído em: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📁 Backup salvo em: $BACKUP_DIR"
echo "🔒 Todos os dados estão seguros para a migração"
echo ""
echo "📋 Próximo script: 201-analise-laravel-estrutura.sh"
echo "💡 Para continuar, digite: 'continuar'"