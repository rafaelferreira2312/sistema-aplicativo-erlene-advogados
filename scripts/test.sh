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
