#!/bin/bash

# Script 29 - Scripts de Inicialização e Setup Completo (Parte 3 Final)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/29-create-docker-scripts-final.sh (executado da raiz do projeto)

echo "🚀 Criando Scripts de Inicialização e Setup Completo (Parte 3 Final)..."

# .env de exemplo para Docker
cat > .env.example << 'EOF'
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
JWT_SECRET=
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

# Stripe
STRIPE_PUBLIC_KEY=pk_test_your_stripe_public_key
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_stripe_webhook_secret

# Mercado Pago
MERCADOPAGO_PUBLIC_KEY=TEST-your-mp-public-key
MERCADOPAGO_ACCESS_TOKEN=TEST-your-mp-access-token
MERCADOPAGO_WEBHOOK_SECRET=your-mp-webhook-secret
MERCADOPAGO_SANDBOX=true

# Google APIs
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URL=https://localhost:8443/auth/google/callback
GOOGLE_DRIVE_FOLDER_ID=your-drive-folder-id

# Microsoft
MICROSOFT_CLIENT_ID=your-microsoft-client-id
MICROSOFT_CLIENT_SECRET=your-microsoft-client-secret
MICROSOFT_TENANT_ID=your-tenant-id
MICROSOFT_REDIRECT_URL=https://localhost:8443/auth/microsoft/callback

# CNJ API
CNJ_API_KEY=your-cnj-api-key
CNJ_BASE_URL=https://api.cnj.jus.br

# Cache/Session
CACHE_DRIVER=redis
SESSION_DRIVER=redis
SESSION_LIFETIME=120

# Queue
QUEUE_CONNECTION=redis

# Filesystem
FILESYSTEM_DISK=local

# Docker específico
COMPOSE_PROJECT_NAME=erlene
DOCKER_BUILDKIT=1
EOF

# Script principal de setup
cat > scripts/setup.sh << 'EOF'
#!/bin/bash

# Setup completo do Sistema Erlene Advogados
# Execução: ./scripts/setup.sh

set -e

echo "🚀 Iniciando setup do Sistema Erlene Advogados..."

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado. Instale o Docker primeiro."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado. Instale o Docker Compose primeiro."
    exit 1
fi

# Criar .env se não existir
if [ ! -f .env ]; then
    echo "📝 Criando arquivo .env..."
    cp .env.example .env
    echo "✅ Arquivo .env criado. Configure suas variáveis de ambiente."
fi

# Criar diretórios necessários
echo "📁 Criando diretórios necessários..."
mkdir -p storage/logs/nginx
mkdir -p storage/backups/mysql
mkdir -p storage/uploads
mkdir -p backend/storage/app/clients
mkdir -p backend/storage/framework/cache
mkdir -p backend/storage/framework/sessions
mkdir -p backend/storage/framework/views
mkdir -p backend/bootstrap/cache

# Configurar permissões
echo "🔧 Configurando permissões..."
chmod -R 755 storage/
chmod -R 755 backend/storage/
chmod -R 755 backend/bootstrap/cache/
chmod +x scripts/*.sh

# Gerar chave da aplicação
echo "🔑 Gerando chaves de segurança..."
if [ ! -f backend/.env ]; then
    cp backend/.env.example backend/.env
fi

# Construir e iniciar containers
echo "🐳 Construindo e iniciando containers Docker..."
docker-compose down --remove-orphans
docker-compose build --no-cache
docker-compose up -d

# Aguardar MySQL ficar disponível
echo "⏳ Aguardando MySQL ficar disponível..."
until docker-compose exec mysql mysqladmin ping -h"localhost" --silent; do
    printf '.'
    sleep 2
done
echo ""

# Instalar dependências do Laravel
echo "📦 Instalando dependências do Laravel..."
docker-compose exec php composer install --no-dev --optimize-autoloader

# Gerar chave da aplicação
echo "🔐 Gerando chave da aplicação..."
docker-compose exec php php artisan key:generate

# Gerar JWT secret
echo "🔑 Gerando JWT secret..."
docker-compose exec php php artisan jwt:secret

# Executar migrações
echo "🗄️ Executando migrações do banco de dados..."
docker-compose exec php php artisan migrate --force

# Executar seeders
echo "🌱 Executando seeders..."
docker-compose exec php php artisan db:seed --force

# Otimizar Laravel
echo "⚡ Otimizando Laravel..."
docker-compose exec php php artisan config:cache
docker-compose exec php php artisan route:cache
docker-compose exec php php artisan view:cache

# Instalar dependências do Frontend
if [ -d "frontend" ]; then
    echo "📦 Instalando dependências do Frontend..."
    docker-compose exec node npm install
fi

# Verificar se tudo está funcionando
echo "🔍 Verificando saúde dos serviços..."
sleep 5

# Verificar API
if curl -f -s http://localhost:8080/health > /dev/null; then
    echo "✅ API Backend funcionando: http://localhost:8080"
else
    echo "❌ API Backend não está respondendo"
fi

# Verificar Frontend
if curl -f -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend funcionando: http://localhost:3000"
else
    echo "⚠️  Frontend não está respondendo (normal se não foi construído ainda)"
fi

echo ""
echo "🎉 Setup concluído com sucesso!"
echo ""
echo "📍 URLs de acesso:"
echo "   • API Backend: https://localhost:8443"
echo "   • Frontend: http://localhost:3000"
echo "   • PHPMyAdmin: http://localhost:8081"
echo "   • Mailpit: http://localhost:8025"
echo ""
echo "🔑 Usuário padrão (admin):"
echo "   • Email: admin@erleneadvogados.com.br"
echo "   • Senha: admin123"
echo ""
echo "📚 Próximos passos:"
echo "   1. Configure suas APIs no arquivo .env"
echo "   2. Acesse https://localhost:8443 para testar a API"
echo "   3. Execute './scripts/test.sh' para rodar os testes"
echo ""
EOF

# Script de inicialização
cat > scripts/start.sh << 'EOF'
#!/bin/bash

# Iniciar todos os serviços
echo "🚀 Iniciando Sistema Erlene Advogados..."

# Verificar se .env existe
if [ ! -f .env ]; then
    echo "❌ Arquivo .env não encontrado. Execute './scripts/setup.sh' primeiro."
    exit 1
fi

# Iniciar containers
docker-compose up -d

# Aguardar serviços ficarem prontos
echo "⏳ Aguardando serviços ficarem prontos..."
sleep 10

# Verificar status
./scripts/health-check.sh

echo "✅ Sistema iniciado com sucesso!"
EOF

# Script de parada
cat > scripts/stop.sh << 'EOF'
#!/bin/bash

# Parar todos os serviços
echo "🛑 Parando Sistema Erlene Advogados..."

docker-compose down

echo "✅ Sistema parado com sucesso!"
EOF

# Script de reinicialização
cat > scripts/restart.sh << 'EOF'
#!/bin/bash

# Reiniciar todos os serviços
echo "🔄 Reiniciando Sistema Erlene Advogados..."

./scripts/stop.sh
sleep 5
./scripts/start.sh
EOF

# Script de backup
cat > scripts/backup.sh << 'EOF'
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
EOF

# Script de health check
cat > scripts/health-check.sh << 'EOF'
#!/bin/bash

# Verificar saúde de todos os serviços
echo "🔍 Verificando saúde dos serviços..."

# Verificar containers
echo "📦 Status dos containers:"
docker-compose ps

# Verificar API
echo ""
echo "🔗 Verificando API..."
if curl -f -s http://localhost:8080/health > /dev/null; then
    echo "✅ API: Funcionando"
    # Testar endpoint protegido
    API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/admin/dashboard)
    if [ "$API_RESPONSE" = "401" ]; then
        echo "✅ Autenticação: Funcionando (401 esperado sem token)"
    else
        echo "⚠️  Autenticação: Status $API_RESPONSE"
    fi
else
    echo "❌ API: Não está respondendo"
fi

# Verificar MySQL
echo ""
echo "🗄️ Verificando MySQL..."
if docker-compose exec mysql mysqladmin ping -h"localhost" --silent; then
    echo "✅ MySQL: Funcionando"
else
    echo "❌ MySQL: Não está respondendo"
fi

# Verificar Redis
echo ""
echo "🔴 Verificando Redis..."
if docker-compose exec redis redis-cli ping | grep -q "PONG"; then
    echo "✅ Redis: Funcionando"
else
    echo "❌ Redis: Não está respondendo"
fi

# Verificar espaço em disco
echo ""
echo "💾 Verificando espaço em disco:"
df -h | grep -E "Filesystem|/dev/"

# Verificar logs de erro
echo ""
echo "📝 Últimos logs de erro:"
if [ -f storage/logs/nginx/error.log ]; then
    tail -n 5 storage/logs/nginx/error.log
else
    echo "Nenhum log de erro encontrado"
fi

echo ""
echo "✅ Verificação de saúde concluída!"
EOF

# Script de teste
cat > scripts/test.sh << 'EOF'
#!/bin/bash

# Executar todos os testes
echo "🧪 Executando testes do sistema..."

# Testes do backend
echo "📊 Executando testes do backend..."
docker-compose exec php php artisan test

# Testes da API
echo "🔗 Testando endpoints da API..."

# Testar health check
echo "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:8080/health)
if echo "$HEALTH_RESPONSE" | grep -q "ok"; then
    echo "✅ Health check: Passou"
else
    echo "❌ Health check: Falhou"
fi

# Testar endpoint de login
echo "Testing auth endpoint..."
LOGIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"invalid","password":"invalid"}')

if [ "$LOGIN_RESPONSE" = "422" ]; then
    echo "✅ Auth endpoint: Passou (422 esperado para dados inválidos)"
else
    echo "❌ Auth endpoint: Falhou (status: $LOGIN_RESPONSE)"
fi

echo ""
echo "✅ Testes concluídos!"
EOF

# Makefile para comandos rápidos
cat > Makefile << 'EOF'
.PHONY: help setup start stop restart backup test health logs clean

# Mostrar ajuda
help:
	@echo "🏛️  Sistema Erlene Advogados - Comandos disponíveis:"
	@echo ""
	@echo "  setup     - Setup inicial completo"
	@echo "  start     - Iniciar todos os serviços"
	@echo "  stop      - Parar todos os serviços"
	@echo "  restart   - Reiniciar todos os serviços"
	@echo "  backup    - Fazer backup completo"
	@echo "  test      - Executar todos os testes"
	@echo "  health    - Verificar saúde dos serviços"
	@echo "  logs      - Mostrar logs em tempo real"
	@echo "  clean     - Limpar containers e volumes"
	@echo "  shell     - Acessar shell do container PHP"
	@echo "  mysql     - Acessar MySQL"
	@echo ""

# Setup inicial
setup:
	@chmod +x scripts/*.sh
	@./scripts/setup.sh

# Iniciar serviços
start:
	@./scripts/start.sh

# Parar serviços
stop:
	@./scripts/stop.sh

# Reiniciar serviços
restart:
	@./scripts/restart.sh

# Backup
backup:
	@./scripts/backup.sh

# Testes
test:
	@./scripts/test.sh

# Health check
health:
	@./scripts/health-check.sh

# Logs em tempo real
logs:
	@docker-compose logs -f

# Logs específicos
logs-php:
	@docker-compose logs -f php

logs-nginx:
	@docker-compose logs -f nginx

logs-mysql:
	@docker-compose logs -f mysql

# Limpar tudo
clean:
	@docker-compose down -v --remove-orphans
	@docker system prune -f

# Acessar shell do PHP
shell:
	@docker-compose exec php bash

# Acessar MySQL
mysql:
	@docker-compose exec mysql mysql -u erlene_user -p erlene_advogados

# Laravel Artisan
artisan:
	@docker-compose exec php php artisan $(cmd)

# Composer
composer:
	@docker-compose exec php composer $(cmd)

# NPM Frontend
npm:
	@docker-compose exec node npm $(cmd)
EOF

# Arquivo de instruções de deployment
cat > INSTALL.md << 'EOF'
# 🚀 Instalação - Sistema Erlene Advogados

## Pré-requisitos

- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM mínimo
- 10GB espaço em disco

## Instalação Rápida

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/sistema-aplicativo-erlene-advogados.git
cd sistema-aplicativo-erlene-advogados

# 2. Execute o setup
make setup

# 3. Acesse o sistema
# API: https://localhost:8443
# Frontend: http://localhost:3000
```

## Comandos Disponíveis

```bash
make help      # Ver todos os comandos
make start     # Iniciar sistema
make stop      # Parar sistema  
make restart   # Reiniciar sistema
make backup    # Fazer backup
make test      # Executar testes
make health    # Verificar saúde
make logs      # Ver logs
make clean     # Limpar tudo
```

## Configuração das APIs

1. Edite o arquivo `.env`
2. Configure suas chaves de API:
   - Stripe (pagamentos)
   - Mercado Pago (PIX/Boleto)
   - Google Drive (documentos)
   - CNJ (tribunais)

## Usuário Padrão

- **Email**: admin@erleneadvogados.com.br
- **Senha**: admin123

## Troubleshooting

### Porta ocupada
```bash
# Alterar portas no docker-compose.yml
ports:
  - "8081:80"  # Mudar 8080 para 8081
```

### Erro de permissão
```bash
sudo chown -R $USER:$USER .
chmod -R 755 storage/
```

### Container não inicia
```bash
make logs      # Ver logs
make clean     # Limpar e tentar novamente
make setup
```
EOF

# Tornar scripts executáveis
chmod +x scripts/*.sh

echo "✅ Scripts de inicialização e setup completo criados!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • .env.example - Variáveis de ambiente completas"
echo "   • scripts/setup.sh - Setup inicial automático"
echo "   • scripts/start.sh - Iniciar sistema"
echo "   • scripts/stop.sh - Parar sistema"
echo "   • scripts/restart.sh - Reiniciar sistema"
echo "   • scripts/backup.sh - Backup automático"
echo "   • scripts/health-check.sh - Verificação de saúde"
echo "   • scripts/test.sh - Executar testes"
echo "   • Makefile - Comandos rápidos"
echo "   • INSTALL.md - Instruções de instalação"
echo ""
echo "🎉 DOCKER STACK 100% COMPLETO!"
echo ""
echo "🚀 PRÓXIMOS PASSOS:"
echo "   1. Execute: make setup"
echo "   2. Configure o .env com suas chaves de API"
echo "   3. Execute: make start"
echo "   4. Acesse: https://localhost:8443"
echo ""
echo "📋 COMANDOS ÚTEIS:"
echo "   • make help - Ver todos os comandos"
echo "   • make health - Verificar se tudo está funcionando"
echo "   • make logs - Ver logs em tempo real"
echo "   • make backup - Fazer backup completo"
echo ""
echo "✅ O BACKEND ESTÁ 100% PRONTO PARA RODAR!"