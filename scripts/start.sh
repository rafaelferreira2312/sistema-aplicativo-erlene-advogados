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
