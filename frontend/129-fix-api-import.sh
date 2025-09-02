#!/bin/bash

# Script 129 - Corrigir Import da API
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 129-fix-api-import.sh && ./129-fix-api-import.sh
# EXECUTE NA PASTA: frontend/

echo "Corrigindo import da API no clientsService.js..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "1. Verificando estrutura de arquivos da API..."
find src/services -name "*.js" -type f | head -10

echo ""
echo "2. Verificando conteúdo dos arquivos de API..."

# Verificar se existe api.js
if [ -f "src/services/api/api.js" ]; then
    echo "✅ Encontrado: src/services/api/api.js"
    echo "Conteúdo das primeiras linhas:"
    head -10 src/services/api/api.js
    API_IMPORT="import { api } from './api';"
elif [ -f "src/services/api/apiClient.js" ]; then
    echo "✅ Encontrado: src/services/api/apiClient.js"
    echo "Conteúdo das primeiras linhas:"
    head -10 src/services/api/apiClient.js
    API_IMPORT="import apiClient from './apiClient';"
elif [ -f "src/services/apiClient.js" ]; then
    echo "✅ Encontrado: src/services/apiClient.js"
    echo "Conteúdo das primeiras linhas:"
    head -10 src/services/apiClient.js
    API_IMPORT="import apiClient from '../apiClient';"
else
    echo "❌ Arquivo da API não encontrado. Listando arquivos:"
    find src -name "*api*" -type f
    API_IMPORT="// IMPORT SERÁ AJUSTADO"
fi

echo ""
echo "3. Verificando como outros services fazem import..."

# Procurar por outros arquivos service para ver o padrão
OTHER_SERVICES=$(find src/services -name "*Service.js" -o -name "*service.js" | grep -v clientsService.js | head -1)

if [ ! -z "$OTHER_SERVICES" ]; then
    echo "Exemplo de outro service: $OTHER_SERVICES"
    echo "Primeiras linhas:"
    head -5 "$OTHER_SERVICES"
fi

echo ""
echo "4. Corrigindo import no clientsService.js..."

CLIENTS_SERVICE="src/services/api/clientsService.js"

# Fazer backup
cp "$CLIENTS_SERVICE" "${CLIENTS_SERVICE}.backup-import-$(date +%Y%m%d-%H%M%S)"

# Verificar qual é o padrão correto baseado nos outros arquivos
if grep -r "import.*api" src/services/ | head -1 | grep -q "apiClient"; then
    echo "Padrão encontrado: apiClient"
    # Corrigir para usar apiClient
    sed -i "1s/.*/import apiClient from '.\/apiClient';/" "$CLIENTS_SERVICE"
    sed -i "s/const apiClient = api;/\/\/ apiClient já importado/" "$CLIENTS_SERVICE"
elif grep -r "import.*api" src/services/ | head -1 | grep -q "{ api }"; then
    echo "Padrão encontrado: { api }"
    # Verificar se api.js existe
    if [ -f "src/services/api/api.js" ]; then
        echo "✅ api.js existe - import correto"
    else
        echo "❌ api.js não existe - criando referência correta"
        # Assumir que é apiClient
        sed -i "1s/.*/import apiClient from '.\/apiClient';/" "$CLIENTS_SERVICE" 
        sed -i "s/const apiClient = api;/\/\/ apiClient já importado/" "$CLIENTS_SERVICE"
    fi
else
    echo "Padrão não identificado - usando axios diretamente"
    # Usar axios diretamente
    sed -i "1s/.*/import axios from 'axios';/" "$CLIENTS_SERVICE"
    sed -i "s/const apiClient = api;/const apiClient = axios.create({ baseURL: 'http:\/\/localhost:8000\/api' });/" "$CLIENTS_SERVICE"
fi

echo ""
echo "5. Verificando se existe arquivo base da API..."

# Se não existe, criar um básico
if [ ! -f "src/services/api/api.js" ] && [ ! -f "src/services/api/apiClient.js" ]; then
    echo "Criando apiClient.js básico..."
    
    cat > src/services/api/apiClient.js << 'EOF'
import axios from 'axios';

// Configuração base da API
const apiClient = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8000/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// Interceptor para adicionar token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor para tratar respostas
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default apiClient;
EOF
    
    # Corrigir import no clientsService
    sed -i "1s/.*/import apiClient from '.\/apiClient';/" "$CLIENTS_SERVICE"
    sed -i "s/const apiClient = api;/\/\/ apiClient já importado/" "$CLIENTS_SERVICE"
    
    echo "✅ apiClient.js criado"
fi

echo ""
echo "6. Verificando clientsService.js após correção..."
echo "Primeiras 10 linhas:"
head -10 "$CLIENTS_SERVICE"

echo ""
echo "7. Testando sintaxe..."
if node -c "$CLIENTS_SERVICE" 2>/dev/null; then
    echo "✅ Sintaxe JavaScript válida"
else
    echo "❌ Erros de sintaxe:"
    node -c "$CLIENTS_SERVICE"
fi

echo ""
echo "8. Testando compilação..."

# Parar processos anteriores
pkill -f "npm start" 2>/dev/null || true
sleep 2

# Testar compilação
timeout 15s npm start > compile_test.log 2>&1 &
sleep 15

if grep -q "webpack compiled successfully" compile_test.log; then
    echo "✅ COMPILAÇÃO FUNCIONANDO!"
elif grep -q "Failed to compile" compile_test.log; then
    echo "❌ Ainda há erros:"
    grep -A 5 "Failed to compile" compile_test.log
else
    echo "⚠️ Status incerto:"
    tail -5 compile_test.log
fi

pkill -f "npm start" 2>/dev/null || true
rm -f compile_test.log

echo ""
echo "=== CORREÇÃO DE IMPORT FINALIZADA ==="
echo ""
echo "IMPORT CORRIGIDO:"
echo "- Verificada estrutura existente do projeto"
echo "- Import ajustado para padrão correto"
echo "- apiClient criado se necessário"
echo ""
echo "TESTE FINAL:"
echo "npm start"