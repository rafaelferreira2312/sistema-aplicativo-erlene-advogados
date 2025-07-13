#!/bin/bash

# Reiniciar todos os serviços
echo "🔄 Reiniciando Sistema Erlene Advogados..."

./scripts/stop.sh
sleep 5
./scripts/start.sh
