#!/bin/bash

# Script 208b - Corrigir Porta Backend para 3008
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔧 Script 208b - Corrigindo porta do backend para 3008..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# 1. Verificar arquivo .env atual
echo "🔍 Verificando configuração atual..."
if [ -f ".env" ]; then
    echo "📄 Arquivo .env atual:"
    grep -E "PORT|DATABASE_URL" .env || echo "   (sem configurações de porta)"
else
    echo "❌ Arquivo .env não encontrado"
fi

# 2. Corrigir .env para porta 3008
echo "🔧 Configurando porta 3008 no .env..."
if [ -f ".env" ]; then
    # Fazer backup
    cp .env .env.bak.208b
    
    # Remover PORT existente e adicionar PORT=3008
    sed -i '/^PORT=/d' .env
    echo "PORT=3008" >> .env
else
    # Criar .env se não existir
    cat > .env << 'EOF'
# Database
DATABASE_URL="mysql://erlene-advogados-vps:6pBAqNZS2qmgJLdsh8z7@localhost:3306/erlene-advogados-vps"

# JWT
JWT_SECRET=erlene_advogados_jwt_secret_super_secure_key_2024

# Server
PORT=3008
NODE_ENV=development

# App
APP_NAME="Sistema Erlene Advogados"
APP_VERSION="1.0.0"
EOF
fi

# 3. Verificar se server.ts está usando variável de ambiente
echo "🔍 Verificando server.ts..."
if grep -q "process.env.PORT" src/server.ts; then
    echo "✅ server.ts já usa process.env.PORT"
else
    echo "⚠️ server.ts não usa process.env.PORT - corrigindo..."
    # Fazer backup
    cp src/server.ts src/server.ts.bak.208b
    
    # Substituir porta hardcoded por variável de ambiente
    sed -i 's/const PORT = [0-9]*/const PORT = process.env.PORT || 3008/' src/server.ts
fi

# 4. Verificar configuração atual
echo "📋 Configuração atual após correção:"
echo "   .env:"
grep "PORT=" .env
echo "   server.ts:"
grep "const PORT" src/server.ts

# 5. Reiniciar servidor automaticamente se estiver rodando
echo "🔄 Verificando se servidor está rodando..."
PID=$(lsof -ti:3001 2>/dev/null)
if [ -n "$PID" ]; then
    echo "🛑 Parando servidor na porta 3001 (PID: $PID)..."
    kill $PID
    sleep 2
fi

# Verificar se algo está na porta 3008
PID_3008=$(lsof -ti:3008 2>/dev/null)
if [ -n "$PID_3008" ]; then
    echo "⚠️ Porta 3008 já está em uso (PID: $PID_3008)"
    echo "   Para liberar: kill $PID_3008"
fi

echo "✅ Porta do backend corrigida para 3008!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • .env: PORT=3008"
echo "   • server.ts: usando process.env.PORT"
echo "   • Servidor na porta 3001 parado"
echo ""
echo "🚀 PARA INICIAR:"
echo "   npm run dev"
echo ""
echo "🔗 URLs CORRETAS:"
echo "   http://localhost:3008/health"
echo "   http://localhost:3008/api/auth/health"
echo ""
echo "📋 PRÓXIMO: Corrigir .env do frontend para apontar para 3008"