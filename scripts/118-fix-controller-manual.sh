#!/bin/bash

# Script 118 - Corrigir Controller Manualmente 
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 118-fix-controller-manual.sh && ./118-fix-controller-manual.sh
# EXECUTE NA PASTA: backend/

echo "🔧 Corrigindo controller manualmente..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

CONTROLLER_PATH="app/Http/Controllers/Api/Admin/Clients/ClientController.php"

echo "1. Fazendo backup do controller..."
cp "$CONTROLLER_PATH" "${CONTROLLER_PATH}.backup-manual-$(date +%Y%m%d-%H%M%S)"

echo "2. Verificando método atual..."
echo "Linha 261 atual:"
sed -n '261p' "$CONTROLLER_PATH"

echo ""
echo "3. Mostrando método responsaveis atual:"
grep -A 20 -B 5 "function responsaveis" "$CONTROLLER_PATH"

echo ""
echo "4. Substituindo método responsaveis completo..."

# Usar sed para substituir especificamente as ocorrências de 'nome' por 'name' no método responsaveis
sed -i '
/function responsaveis/,/^    }/ {
    s/nome/name/g
    s/\bname as name\b/name/g
}
' "$CONTROLLER_PATH"

echo "5. Verificando alteração:"
echo "Nova linha 261:"
sed -n '261p' "$CONTROLLER_PATH"

echo ""
echo "6. Verificando método completo após alteração:"
grep -A 20 -B 5 "function responsaveis" "$CONTROLLER_PATH"

echo ""
echo "7. Limpando cache..."
php artisan config:clear
php artisan route:clear
php artisan cache:clear

echo ""
echo "8. Testando endpoint..."

# Fazer login e testar
echo "Fazendo login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "✅ Login OK"
    
    echo "Testando endpoint responsaveis..."
    RESP_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:8000/api/admin/clients/responsaveis)
    
    echo "Resultado:"
    echo "$RESP_RESULT"
    
    if echo $RESP_RESULT | grep -q '"success":true'; then
        echo ""
        echo "✅ ENDPOINT FUNCIONANDO!"
        COUNT=$(echo $RESP_RESULT | grep -o '"name"' | wc -l)
        echo "✅ Retornou $COUNT responsáveis"
    else
        echo ""
        echo "❌ Ainda com erro. Vamos ver o código atual:"
        echo "Método responsaveis atual:"
        grep -A 30 "function responsaveis" "$CONTROLLER_PATH"
    fi
else
    echo "❌ Erro no login"
fi

echo ""
echo "=== VERIFICAÇÃO FINAL ==="
echo "Se ainda houver erro 'nome', o problema pode estar em:"
echo "1. Cache não limpo - reinicie o servidor"
echo "2. Outro método ou classe usando 'nome'"
echo "3. Filtro por unidade_id causando problema"
echo ""
echo "Vamos verificar todas as ocorrências de 'nome' no controller:"
grep -n "nome" "$CONTROLLER_PATH" || echo "✅ Nenhuma ocorrência de 'nome' encontrada"