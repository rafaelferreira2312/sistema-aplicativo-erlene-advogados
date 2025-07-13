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
