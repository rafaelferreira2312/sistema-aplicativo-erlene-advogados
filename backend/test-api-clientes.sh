#!/bin/bash

# Testes cURL para API de Clientes
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x test-api-clientes.sh && ./test-api-clientes.sh

echo "🧪 Testando API de Clientes..."

BASE_URL="http://localhost:8000/api"
TOKEN=""

echo ""
echo "1. Fazendo login para obter token..."

# Login
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@erlene.com","password":"123456"}')

echo "Response do login:"
echo $LOGIN_RESPONSE | jq '.' 2>/dev/null || echo $LOGIN_RESPONSE

# Extrair token do response
if command -v jq &> /dev/null; then
    TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.access_token // .access_token // empty')
else
    TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ]; then
    echo "❌ Não conseguiu obter token. Verifique as credenciais."
    echo "Testando sem autenticação..."
    AUTH_HEADER=""
else
    echo "✅ Token obtido: ${TOKEN:0:20}..."
    AUTH_HEADER="Authorization: Bearer $TOKEN"
fi

echo ""
echo "2. Testando endpoint de responsáveis..."

RESP_RESPONSE=$(curl -s -H "$AUTH_HEADER" \
  -H "Accept: application/json" \
  "$BASE_URL/admin/clients/responsaveis")

echo "Response dos responsáveis:"
echo $RESP_RESPONSE | jq '.' 2>/dev/null || echo $RESP_RESPONSE

echo ""
echo "3. Testando listagem de clientes..."

CLIENTS_RESPONSE=$(curl -s -H "$AUTH_HEADER" \
  -H "Accept: application/json" \
  "$BASE_URL/admin/clients")

echo "Response dos clientes:"
echo $CLIENTS_RESPONSE | jq '.' 2>/dev/null || echo $CLIENTS_RESPONSE

echo ""
echo "4. Testando estatísticas de clientes..."

STATS_RESPONSE=$(curl -s -H "$AUTH_HEADER" \
  -H "Accept: application/json" \
  "$BASE_URL/admin/clients/stats")

echo "Response das estatísticas:"
echo $STATS_RESPONSE | jq '.' 2>/dev/null || echo $STATS_RESPONSE

echo ""
echo "5. Testando busca de CEP..."

CEP_RESPONSE=$(curl -s -H "$AUTH_HEADER" \
  -H "Accept: application/json" \
  "$BASE_URL/admin/clients/buscar-cep/01310100")

echo "Response do CEP:"
echo $CEP_RESPONSE | jq '.' 2>/dev/null || echo $CEP_RESPONSE

echo ""
echo "6. Criando cliente de teste..."

if [ ! -z "$TOKEN" ]; then
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/admin/clients" \
      -H "$AUTH_HEADER" \
      -H "Content-Type: application/json" \
      -d '{
        "nome": "Cliente Teste cURL",
        "cpf_cnpj": "11122233344",
        "tipo_pessoa": "PF",
        "email": "teste.curl@email.com",
        "telefone": "11987654321",
        "endereco": "Rua Teste, 123",
        "cidade": "São Paulo",
        "estado": "SP",
        "cep": "01234567",
        "responsavel_id": 1,
        "status": "ativo",
        "tipo_armazenamento": "local",
        "acesso_portal": false
      }')
    
    echo "Response da criação:"
    echo $CREATE_RESPONSE | jq '.' 2>/dev/null || echo $CREATE_RESPONSE
else
    echo "❌ Pulando teste de criação (sem token)"
fi

echo ""
echo "🏁 Testes concluídos!"
echo ""
echo "COMANDOS PARA TESTAR MANUALMENTE:"
echo ""
echo "# 1. Login:"
echo 'curl -X POST http://localhost:8000/api/auth/login -H "Content-Type: application/json" -d '"'"'{"email":"admin@erlene.com","password":"123456"}'"'"''
echo ""
echo "# 2. Responsáveis (substitua SEU_TOKEN):"
echo 'curl -H "Authorization: Bearer SEU_TOKEN" http://localhost:8000/api/admin/clients/responsaveis'
echo ""
echo "# 3. Lista de clientes:"
echo 'curl -H "Authorization: Bearer SEU_TOKEN" http://localhost:8000/api/admin/clients'
echo ""
echo "# 4. Estatísticas:"
echo 'curl -H "Authorization: Bearer SEU_TOKEN" http://localhost:8000/api/admin/clients/stats'