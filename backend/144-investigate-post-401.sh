#!/bin/bash

# Script 144 - Investigar erro 401 específico em POST
# Sistema Erlene Advogados - Diagnosticar diferença GET vs POST
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔍 Script 144 - Investigando erro 401 em POST audiências..."

# Verificar se estamos no diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📝 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 144-investigate-post-401.sh && ./144-investigate-post-401.sh"
    exit 1
fi

echo "🔍 PROBLEMA IDENTIFICADO:"
echo "   ✅ GET /admin/audiencias → 200 OK (funciona)"
echo "   ✅ GET /admin/audiencias/dashboard/stats → 200 OK (funciona)"
echo "   ❌ POST /admin/audiencias → 401 Unauthorized (falha)"
echo ""

echo "1️⃣ Investigando rotas de audiências em routes/api.php..."

if [ -f "routes/api.php" ]; then
    echo "📋 Rotas encontradas para audiências:"
    grep -n -A5 -B5 "audiencia" routes/api.php
    echo ""
    
    echo "📋 Middleware aplicado nas rotas de audiências:"
    grep -n "middleware.*auth" routes/api.php
    echo ""
else
    echo "❌ routes/api.php não encontrado"
fi

echo "2️⃣ Verificando se controller AudienciaController existe..."

CONTROLLER_PATH=""
if [ -f "app/Http/Controllers/Api/Admin/AudienciaController.php" ]; then
    CONTROLLER_PATH="app/Http/Controllers/Api/Admin/AudienciaController.php"
elif [ -f "app/Http/Controllers/Admin/AudienciaController.php" ]; then
    CONTROLLER_PATH="app/Http/Controllers/Admin/AudienciaController.php"
elif [ -f "app/Http/Controllers/AudienciaController.php" ]; then
    CONTROLLER_PATH="app/Http/Controllers/AudienciaController.php"
fi

if [ -n "$CONTROLLER_PATH" ]; then
    echo "✅ Controller encontrado: $CONTROLLER_PATH"
    echo ""
    echo "📋 Métodos disponíveis no controller:"
    grep -n "public function" "$CONTROLLER_PATH"
    echo ""
    
    echo "📋 Método store (POST) encontrado?"
    grep -n -A10 "public function store" "$CONTROLLER_PATH" || echo "❌ Método store NÃO encontrado"
    echo ""
else
    echo "❌ AudienciaController NÃO encontrado"
    echo "📋 Controllers disponíveis em app/Http/Controllers:"
    find app/Http/Controllers -name "*Controller.php" | head -10
fi

echo "3️⃣ Comparando com controller funcional (ClientController)..."

CLIENT_CONTROLLER=""
if [ -f "app/Http/Controllers/Api/Admin/ClientController.php" ]; then
    CLIENT_CONTROLLER="app/Http/Controllers/Api/Admin/ClientController.php"
elif [ -f "app/Http/Controllers/Admin/ClientController.php" ]; then
    CLIENT_CONTROLLER="app/Http/Controllers/Admin/ClientController.php"
fi

if [ -n "$CLIENT_CONTROLLER" ]; then
    echo "✅ ClientController encontrado: $CLIENT_CONTROLLER"
    echo ""
    echo "📋 Middleware no ClientController:"
    grep -n "middleware\|auth" "$CLIENT_CONTROLLER" | head -5
    echo ""
    echo "📋 Método store no ClientController:"
    grep -n -A5 "public function store" "$CLIENT_CONTROLLER" || echo "❌ store não encontrado"
    echo ""
else
    echo "❌ ClientController não encontrado para comparação"
fi

echo "4️⃣ Verificando middleware específico de audiências..."

if [ -d "app/Http/Middleware" ]; then
    echo "📋 Middleware relacionado a audiências:"
    find app/Http/Middleware -name "*[Aa]udien*" || echo "   Nenhum middleware específico"
    echo ""
fi

echo "5️⃣ Verificando Model Audiencia..."

MODEL_PATH=""
if [ -f "app/Models/Audiencia.php" ]; then
    MODEL_PATH="app/Models/Audiencia.php"
fi

if [ -n "$MODEL_PATH" ]; then
    echo "✅ Model encontrado: $MODEL_PATH"
    echo ""
    echo "📋 Propriedades fillable:"
    grep -n -A10 "fillable" "$MODEL_PATH"
    echo ""
else
    echo "❌ Model Audiencia NÃO encontrado"
fi

echo "6️⃣ Verificando tabela audiencias na migration..."

echo "📋 Migrations de audiências:"
find database/migrations -name "*audien*" -o -name "*create_audiencias*" || echo "   Nenhuma migration encontrada"

echo ""
echo "7️⃣ Testando endpoint POST com curl..."

echo "📋 Teste básico POST (sem autenticação):"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}' \
  http://localhost:8000/api/admin/audiencias

echo ""
echo "📋 Verificando se backend está rodando:"
curl -s -o /dev/null -w "Backend Status: %{http_code}\n" http://localhost:8000/api/health 2>/dev/null || echo "Backend pode não estar rodando"

echo ""
echo "8️⃣ POSSÍVEIS CAUSAS DO PROBLEMA:"
echo "   1. ❓ Controller AudienciaController não existe ou está incompleto"
echo "   2. ❓ Método store() não implementado no controller"
echo "   3. ❓ Rotas POST não configuradas corretamente"
echo "   4. ❓ Middleware de autenticação específico para POST"
echo "   5. ❓ Model Audiencia não existe ou mal configurado"
echo "   6. ❓ Migration não executada (tabela não existe)"
echo ""

echo "9️⃣ PRÓXIMOS PASSOS RECOMENDADOS:"
echo "   1. Verificar se backend tem controller completo"
echo "   2. Comparar rotas com módulo funcional (clientes)"
echo "   3. Verificar se tabela audiencias existe no banco"
echo "   4. Testar endpoint direto com Postman/curl"
echo ""

echo "✅ Investigação concluída!"
echo ""
echo "📝 Para continuar investigação no frontend:"
echo "   cd frontend && ./138-investigate-frontend-module.sh audiencias"