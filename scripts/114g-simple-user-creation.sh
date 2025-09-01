#!/bin/bash

# Script 114g - Apenas criar usuário com campos corretos
# EXECUTE DENTRO DA PASTA: backend/

echo "Script 114g - Criando usuário com TODOS os campos obrigatórios..."

if [ ! -f "artisan" ]; then
    echo "Erro: Execute dentro da pasta backend/"
    exit 1
fi

echo "1. Criando usuário admin diretamente no banco MySQL..."

# Inserir usuário diretamente no MySQL com todos os campos obrigatórios
mysql -u root -p12345678 erlene_advogados << 'EOF'
DELETE FROM users WHERE email = 'admin@erlene.com';

INSERT INTO users (nome, name, email, perfil, status, password, created_at, updated_at) 
VALUES (
    'Dra. Erlene Chaves Silva',
    'Dra. Erlene Chaves Silva', 
    'admin@erlene.com',
    'admin_geral',
    'ativo',
    '$2y$12$bKXQRYzCgEh64F1hOeMRO.hJVBGVI5aM3hWSS0RUsneO2yiREZ9XS',
    NOW(),
    NOW()
);
EOF

echo "2. Verificando se usuário foi criado..."
mysql -u root -p12345678 erlene_advogados -e "SELECT id, nome, name, email, perfil, status FROM users WHERE email = 'admin@erlene.com';"

echo "3. Testando login..."
php artisan serve --port=8000 &
LARAVEL_PID=$!
sleep 2

RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

echo "Resposta do login:"
echo "$RESPONSE"

if [[ $RESPONSE == *"access_token"* ]]; then
    echo ""
    echo "LOGIN FUNCIONOU!"
    
    TOKEN=$(echo $RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    echo "Token: $TOKEN"
    
    echo ""
    echo "Testando rota protegida:"
    curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/dashboard/stats
    echo ""
    
else
    echo ""
    echo "LOGIN NÃO FUNCIONOU"
    echo "Hash da senha no banco deve estar errado"
    
    echo ""
    echo "Recriando usuário com hash correto..."
    HASH=$(php artisan tinker --execute="echo \Illuminate\Support\Facades\Hash::make('123456');")
    
    mysql -u root -p12345678 erlene_advogados << EOF
    UPDATE users SET password = '$HASH' WHERE email = 'admin@erlene.com';
EOF
    
    echo "Testando novamente:"
    RESPONSE2=$(curl -s -X POST http://localhost:8000/api/auth/login \
      -H 'Content-Type: application/json' \
      -d '{"email":"admin@erlene.com","password":"123456"}')
    
    echo "$RESPONSE2"
fi

kill $LARAVEL_PID 2>/dev/null

echo ""
echo "TESTE MANUAL:"
echo "1. php artisan serve"
echo "2. POST /api/auth/login"
echo "3. Body: {\"email\":\"admin@erlene.com\",\"password\":\"123456\"}"