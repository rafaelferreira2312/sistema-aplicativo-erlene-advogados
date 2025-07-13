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
