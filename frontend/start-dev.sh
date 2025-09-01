#!/bin/bash

echo "🚀 Iniciando ambiente de desenvolvimento..."

# Verificar se backend está rodando
if ! curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "Backend não está rodando. Execute:"
    echo "cd ../backend && php artisan serve"
    echo ""
fi

# Limpar cache do npm
npm start
