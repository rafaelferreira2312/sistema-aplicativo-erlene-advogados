#!/bin/bash

# Script 203a - Instalação de Dependências Node.js
# Sistema Erlene Advogados - Migração Laravel → Node.js Express
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend-nodejs/

echo "📦 Script 203a - Instalação de Dependências Node.js"
echo "=================================================="
echo "🔧 Instalando todas as dependências do projeto"
echo "🕒 Iniciado em: $(date '+%Y-%m-%d %H:%M:%S')"

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ ERRO: Execute este script dentro da pasta backend-nodejs/"
    echo "Comando correto:"
    echo "   cd backend-nodejs"
    echo "   chmod +x 203a-nodejs-install-dependencies.sh && ./203a-nodejs-install-dependencies.sh"
    exit 1
fi

echo "✅ Diretório backend-nodejs/ confirmado"

# Verificar Node.js novamente
if ! command -v npm >/dev/null 2>&1; then
    echo "❌ npm não encontrado!"
    exit 1
fi

echo ""
echo "🧹 1. LIMPANDO CACHE NPM"
echo "======================="

echo "🗑️ Limpando cache do npm..."
npm cache clean --force 2>/dev/null || echo "Cache já limpo"

echo ""
echo "📦 2. INSTALANDO DEPENDÊNCIAS DE PRODUÇÃO"
echo "========================================"

echo "⬇️ Instalando dependências principais..."

# Instalar dependências principais em lotes menores para evitar timeout
echo "🔗 Instalando Core (Express, Prisma, etc)..."
npm install express @prisma/client cors helmet morgan dotenv --save

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências core"
    exit 1
fi

echo "🔐 Instalando Auth (JWT, bcrypt, etc)..."
npm install bcryptjs jsonwebtoken joi --save

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências auth"
    exit 1
fi

echo "📤 Instalando Utils (multer, compression, etc)..."
npm install multer compression express-rate-limit winston express-validator --save

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências utils"
    exit 1
fi

echo "💳 Instalando Integrations (Stripe, axios, etc)..."
npm install stripe axios moment uuid --save

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar dependências integrations"
    exit 1
fi

echo "✅ Dependências de produção instaladas"

echo ""
echo "🛠️ 3. INSTALANDO DEPENDÊNCIAS DE DESENVOLVIMENTO"
echo "=============================================="

echo "📘 Instalando TypeScript e tipos..."
npm install --save-dev typescript ts-node nodemon @types/node @types/express

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar TypeScript"
    exit 1
fi

echo "🔍 Instalando ESLint e Prettier..."
npm install --save-dev @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint prettier

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar ESLint/Prettier"
    exit 1
fi

echo "🧪 Instalando Jest para testes..."
npm install --save-dev jest @types/jest ts-jest supertest @types/supertest

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar Jest"
    exit 1
fi

echo "🗄️ Instalando Prisma CLI..."
npm install --save-dev prisma

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar Prisma CLI"
    exit 1
fi

echo "📦 Instalando tipos adicionais..."
npm install --save-dev @types/cors @types/morgan @types/bcryptjs @types/jsonwebtoken @types/multer @types/compression @types/uuid

if [ $? -ne 0 ]; then
    echo "❌ Erro ao instalar tipos adicionais"
    exit 1
fi

echo "✅ Dependências de desenvolvimento instaladas"

echo ""
echo "🔧 4. CONFIGURANDO PRISMA"
echo "======================="

echo "📝 Inicializando Prisma..."
npx prisma init --datasource-provider mysql

if [ $? -ne 0 ]; then
    echo "❌ Erro ao inicializar Prisma"
    exit 1
fi

echo "✅ Prisma inicializado"

echo ""
echo "📋 5. CRIANDO ARQUIVO .ENV"
echo "========================"

# Ler configurações do backend Laravel
if [ -f "../backend/.env" ]; then
    echo "📄 Copiando configurações do Laravel..."
    
    # Extrair dados do MySQL do Laravel
    DB_HOST=$(grep "^DB_HOST=" "../backend/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    DB_PORT=$(grep "^DB_PORT=" "../backend/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    DB_DATABASE=$(grep "^DB_DATABASE=" "../backend/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    DB_USERNAME=$(grep "^DB_USERNAME=" "../backend/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    DB_PASSWORD=$(grep "^DB_PASSWORD=" "../backend/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
    
    # Usar defaults se não encontrados
    DB_HOST=${DB_HOST:-localhost}
    DB_PORT=${DB_PORT:-3306}
    DB_DATABASE=${DB_DATABASE:-erlene_advogados}
    DB_USERNAME=${DB_USERNAME:-root}
    
    echo "✅ Configurações MySQL extraídas do Laravel"
else
    echo "⚠️ Arquivo Laravel .env não encontrado, usando defaults"
    DB_HOST="localhost"
    DB_PORT="3306"
    DB_DATABASE="erlene_advogados"
    DB_USERNAME="root"
    DB_PASSWORD=""
fi

# Criar .env para Node.js
cat > .env << EOF
# Database - Copiado do Laravel
DATABASE_URL="mysql://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_DATABASE}"

# App
NODE_ENV="development"
PORT=3001
APP_URL="http://localhost:3001"

# JWT
JWT_SECRET="erlene_jwt_secret_2024_nodejs_migration"
JWT_EXPIRES_IN="7d"
JWT_REFRESH_EXPIRES_IN="30d"

# CORS
FRONTEND_URL="http://localhost:3000"
ALLOWED_ORIGINS="http://localhost:3000,http://localhost:3001"

# Uploads
MAX_FILE_SIZE="10485760"
UPLOAD_PATH="./uploads"

# Logs
LOG_LEVEL="info"
LOG_FILE="./logs/app.log"

# Rate Limiting
RATE_LIMIT_WINDOW_MS="900000"
RATE_LIMIT_MAX_REQUESTS="100"

# Stripe (placeholder)
STRIPE_SECRET_KEY=""
STRIPE_WEBHOOK_SECRET=""

# MercadoPago (placeholder)
MERCADOPAGO_ACCESS_TOKEN=""
MERCADOPAGO_WEBHOOK_SECRET=""

# Email (placeholder)
SMTP_HOST=""
SMTP_PORT="587"
SMTP_USER=""
SMTP_PASS=""

# Google Drive (placeholder)
GOOGLE_DRIVE_CLIENT_ID=""
GOOGLE_DRIVE_CLIENT_SECRET=""
GOOGLE_DRIVE_REFRESH_TOKEN=""
EOF

echo "✅ Arquivo .env criado com configurações do Laravel"

echo ""
echo "🎯 6. VERIFICANDO INSTALAÇÃO"
echo "=========================="

echo "📊 Verificando package.json..."
if [ -f "package.json" ]; then
    PACKAGE_COUNT=$(npm list --depth=0 2>/dev/null | grep -c "├──\|└──" || echo "0")
    echo "✅ Pacotes instalados: aproximadamente $PACKAGE_COUNT"
else
    echo "❌ package.json não encontrado"
fi

echo "📁 Verificando node_modules..."
if [ -d "node_modules" ]; then
    NODE_MODULES_SIZE=$(du -sh node_modules 2>/dev/null | cut -f1)
    echo "✅ node_modules criado: $NODE_MODULES_SIZE"
else
    echo "❌ node_modules não foi criado"
fi

echo "🗄️ Verificando Prisma..."
if [ -f "prisma/schema.prisma" ]; then
    echo "✅ Prisma schema.prisma criado"
else
    echo "❌ Prisma schema não encontrado"
fi

echo "🔧 Verificando .env..."
if [ -f ".env" ]; then
    echo "✅ Arquivo .env configurado"
    echo "   Database: $DB_DATABASE"
    echo "   Host: $DB_HOST:$DB_PORT"
else
    echo "❌ Arquivo .env não foi criado"
fi

echo ""
echo "🧪 7. TESTANDO COMANDOS NPM"
echo "========================="

echo "🔍 Testando TypeScript..."
if npx tsc --version >/dev/null 2>&1; then
    TSC_VERSION=$(npx tsc --version)
    echo "✅ TypeScript: $TSC_VERSION"
else
    echo "❌ TypeScript não funcionando"
fi

echo "📋 Testando ESLint..."
if npx eslint --version >/dev/null 2>&1; then
    ESLINT_VERSION=$(npx eslint --version)
    echo "✅ ESLint: $ESLINT_VERSION"
else
    echo "❌ ESLint não funcionando"
fi

echo "🎨 Testando Prettier..."
if npx prettier --version >/dev/null 2>&1; then
    PRETTIER_VERSION=$(npx prettier --version)
    echo "✅ Prettier: $PRETTIER_VERSION"
else
    echo "❌ Prettier não funcionando"
fi

echo "🗄️ Testando Prisma..."
if npx prisma --version >/dev/null 2>&1; then
    PRISMA_VERSION=$(npx prisma --version | head -1)
    echo "✅ Prisma: $PRISMA_VERSION"
else
    echo "❌ Prisma não funcionando"
fi

echo ""
echo "✅ DEPENDÊNCIAS INSTALADAS COM SUCESSO!"
echo "======================================"
echo "📦 Todas as dependências Node.js instaladas"
echo "🗄️ Prisma configurado e pronto"
echo "🔧 Arquivo .env criado com dados do Laravel"
echo "🧪 Ferramentas de desenvolvimento prontas"
echo ""
echo "📋 Próximo script: 203b-nodejs-prisma-schema.sh"
echo "💡 Para continuar, digite: 'continuar'"