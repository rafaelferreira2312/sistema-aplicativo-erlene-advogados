#!/bin/bash

# Script 148 - Debug backend audiências autenticação
# Sistema Erlene Advogados - Investigar problema 401 no backend
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔍 Script 148 - Investigando problema de autenticação no backend..."

# Verificar se estamos no diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

echo "📋 PROBLEMA IDENTIFICADO:"
echo "   ❌ Frontend: Token JWT válido existe"
echo "   ❌ Backend: /admin/audiencias retorna 401 para GET e POST"
echo "   ✅ Outros módulos (clientes/processos) funcionam"
echo ""

echo "1️⃣ Verificando rotas de audiências em routes/api.php..."

if [ -f "routes/api.php" ]; then
    echo "✅ routes/api.php encontrado"
    echo ""
    echo "📋 Rotas de audiências cadastradas:"
    grep -n -A5 -B5 "audiencias\|AudienciaController" routes/api.php || echo "   Nenhuma rota encontrada"
    
    echo ""
    echo "📋 Middleware aplicado às rotas de audiências:"
    grep -n -A10 -B5 "auth.*audiencias\|audiencias.*auth" routes/api.php || echo "   Middleware não encontrado"
    
else
    echo "❌ routes/api.php NÃO encontrado"
    exit 1
fi

echo ""
echo "2️⃣ Comparando com rotas funcionais (clientes/processos)..."

echo "📋 Rotas de clientes (funcionam):"
grep -n -A3 -B2 "clients\|ClientController" routes/api.php | head -10

echo ""
echo "📋 Rotas de processos (funcionam):"
grep -n -A3 -B2 "processes\|ProcessController" routes/api.php | head -10

echo ""
echo "3️⃣ Verificando AudienciaController..."

if [ -f "app/Http/Controllers/Api/Admin/AudienciaController.php" ]; then
    echo "✅ AudienciaController encontrado"
    echo ""
    echo "📋 Namespace e imports:"
    head -20 app/Http/Controllers/Api/Admin/AudienciaController.php | grep -E "namespace|use|class"
    
    echo ""
    echo "📋 Métodos disponíveis:"
    grep -n "public function" app/Http/Controllers/Api/Admin/AudienciaController.php
    
    echo ""
    echo "📋 Middleware no controller:"
    grep -n -A5 -B2 "middleware\|auth" app/Http/Controllers/Api/Admin/AudienciaController.php || echo "   Nenhum middleware específico"
    
else
    echo "❌ AudienciaController NÃO encontrado"
    echo "📋 Verificando se existe em outro local:"
    find app/ -name "*Audiencia*Controller*" -type f
fi

echo ""
echo "4️⃣ Verificando modelo Audiencia..."

if [ -f "app/Models/Audiencia.php" ]; then
    echo "✅ Model Audiencia encontrado"
    echo ""
    echo "📋 Fillable fields:"
    grep -n -A10 "fillable" app/Models/Audiencia.php | head -15
    
    echo ""
    echo "📋 Relacionamentos:"
    grep -n -A5 "belongsTo\|hasMany\|hasOne" app/Models/Audiencia.php || echo "   Nenhum relacionamento específico"
    
else
    echo "❌ Model Audiencia NÃO encontrado"
    echo "📋 Verificando se existe em outro local:"
    find app/ -name "*Audiencia*" -type f
fi

echo ""
echo "5️⃣ Verificando migração da tabela audiencias..."

if ls database/migrations/*create_audiencias_table.php 1> /dev/null 2>&1; then
    echo "✅ Migration audiencias encontrada"
    echo ""
    echo "📋 Estrutura da tabela:"
    grep -n -A20 "Schema::create.*audiencias" database/migrations/*create_audiencias_table.php | head -25
else
    echo "❌ Migration audiencias NÃO encontrada"
    echo "📋 Verificando se tabela existe no banco:"
    php artisan tinker --execute="echo Schema::hasTable('audiencias') ? 'Tabela existe' : 'Tabela NÃO existe';" 2>/dev/null || echo "   Erro ao verificar tabela"
fi

echo ""
echo "6️⃣ Testando autenticação com usuário atual..."

echo "📋 Testando token atual via artisan tinker:"

cat > test_token_backend.php << 'EOF'
<?php
// Teste do token atual
use App\Models\User;
use Tymon\JWTAuth\Facades\JWTAuth;

echo "=== TESTE TOKEN BACKEND ===\n";

// Token do frontend (cole aqui)
$token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwMDAvYXBpL2F1dGgvbG9naW4iLCJpYXQiOjE3NTc5Njg4MDQsImV4cCI6MTc1Nzk3MjQwNCwibmJmIjoxNzU3OTY4ODA0LCJqdGkiOiJyYjJrNkhNMXNVZFU0dXF5Iiwic3ViIjoiMSIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjciLCJwZXJmaWwiOiJhZG1pbl9nZXJhbCIsInVuaWRhZGVfaWQiOjJ9.64a83oU9KFLYl5r_bv3s97DCiFZn7bIeWo-IZpNbQ-E';

try {
    // Configurar token manualmente
    JWTAuth::setToken($token);
    
    // Verificar validade
    $payload = JWTAuth::getPayload();
    echo "✅ Token válido\n";
    echo "Sub (User ID): " . $payload->get('sub') . "\n";
    echo "Perfil: " . $payload->get('perfil') . "\n";
    echo "Unidade ID: " . $payload->get('unidade_id') . "\n";
    
    // Buscar usuário
    $user = JWTAuth::authenticate();
    if ($user) {
        echo "✅ Usuário encontrado: " . $user->name . "\n";
        echo "Email: " . $user->email . "\n";
        echo "Perfil ativo: " . $user->perfil . "\n";
        echo "Unidade ativa: " . $user->unidade_id . "\n";
    } else {
        echo "❌ Usuário não encontrado\n";
    }
    
} catch (Exception $e) {
    echo "❌ Erro ao validar token: " . $e->getMessage() . "\n";
}
EOF

echo "📋 Executando teste de token:"
php artisan tinker --execute="require 'test_token_backend.php';" 2>/dev/null || echo "   Erro ao executar teste"

echo ""
echo "7️⃣ Verificando middleware auth:api..."

if [ -f "app/Http/Kernel.php" ]; then
    echo "📋 Middleware registrados:"
    grep -n -A5 -B5 "auth.*api\|api.*auth" app/Http/Kernel.php || echo "   Middleware auth:api não encontrado"
else
    echo "❌ Kernel.php não encontrado"
fi

echo ""
echo "8️⃣ Testando rotas diretamente via artisan..."

echo "📋 Listando todas as rotas de audiências:"
php artisan route:list --path=audiencias 2>/dev/null || echo "   Erro ao listar rotas"

echo ""
echo "📋 Testando rota específica (GET):"
php artisan route:list | grep -i "audiencias.*GET" || echo "   Rota GET não encontrada"

echo ""
echo "📋 Testando rota específica (POST):"
php artisan route:list | grep -i "audiencias.*POST" || echo "   Rota POST não encontrada"

echo ""
echo "9️⃣ Comparando com módulo funcional (clientes)..."

echo "📋 Rotas de clientes (para comparação):"
php artisan route:list --path=clients 2>/dev/null | head -5 || echo "   Erro ao listar rotas de clientes"

echo ""
echo "🔟 Verificando configuração JWT..."

if [ -f "config/jwt.php" ]; then
    echo "✅ Configuração JWT encontrada"
    echo ""
    echo "📋 TTL do token:"
    grep -n "ttl" config/jwt.php | head -3
    
    echo ""
    echo "📋 Algoritmo de assinatura:"
    grep -n "algo" config/jwt.php | head -3
else
    echo "❌ Configuração JWT não encontrada"
fi

echo ""
echo "1️⃣1️⃣ Gerando diagnóstico final..."

echo "📊 RESUMO DO DIAGNÓSTICO BACKEND:"
echo "================================"

# Verificar se controller existe
if [ -f "app/Http/Controllers/Api/Admin/AudienciaController.php" ]; then
    echo "✅ AudienciaController existe"
else
    echo "❌ AudienciaController MISSING"
fi

# Verificar se model existe
if [ -f "app/Models/Audiencia.php" ]; then
    echo "✅ Model Audiencia existe"
else
    echo "❌ Model Audiencia MISSING"
fi

# Verificar se migration existe
if ls database/migrations/*create_audiencias_table.php 1> /dev/null 2>&1; then
    echo "✅ Migration audiencias existe"
else
    echo "❌ Migration audiencias MISSING"
fi

# Verificar se rotas estão registradas
if grep -q "audiencias" routes/api.php; then
    echo "✅ Rotas audiências registradas"
else
    echo "❌ Rotas audiências NÃO registradas"
fi

echo ""
echo "🎯 PROBLEMAS MAIS PROVÁVEIS:"
echo "============================"

# Análise dos problemas mais comuns
if ! grep -q "audiencias" routes/api.php; then
    echo "1. ❌ ROTAS NÃO REGISTRADAS - Adicionar rotas em api.php"
fi

if ! ls database/migrations/*create_audiencias_table.php 1> /dev/null 2>&1; then
    echo "2. ❌ TABELA NÃO EXISTE - Executar migration"
fi

if [ ! -f "app/Http/Controllers/Api/Admin/AudienciaController.php" ]; then
    echo "3. ❌ CONTROLLER NÃO EXISTE - Criar AudienciaController"
fi

echo ""
echo "🔧 SOLUÇÕES SUGERIDAS:"
echo "====================="

echo "1. Verificar se rotas estão no middleware auth:api correto"
echo "2. Confirmar se AudienciaController está no namespace correto"
echo "3. Executar migrations se tabela não existir"
echo "4. Verificar se usuário tem permissões adequadas"
echo "5. Comparar configuração com módulo funcional (ClientController)"

echo ""
echo "📋 COMANDOS PARA TESTE MANUAL:"
echo "============================="

cat > test_manual_commands.txt << 'EOF'
# Comandos para executar manualmente

# 1. Verificar se tabela existe
php artisan tinker --execute="echo Schema::hasTable('audiencias') ? 'Tabela existe' : 'Tabela não existe';"

# 2. Verificar registros na tabela
php artisan tinker --execute="echo App\Models\Audiencia::count() . ' registros encontrados';"

# 3. Testar criação de audiência
php artisan tinker --execute="
\$a = new App\Models\Audiencia();
\$a->processo_id = 1;
\$a->cliente_id = 1;
\$a->tipo = 'conciliacao';
\$a->data = '2025-09-17';
\$a->hora = '14:00';
\$a->local = 'Teste Backend';
\$a->advogado = 'Dr. Teste';
\$a->save();
echo 'Audiência criada: ' . \$a->id;
"

# 4. Listar audiências
php artisan tinker --execute="App\Models\Audiencia::all()->each(function(\$a) { echo \$a->id . ' - ' . \$a->tipo . ' - ' . \$a->data . PHP_EOL; });"

# 5. Testar middleware
curl -X GET "http://localhost:8000/api/admin/audiencias" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -H "Accept: application/json"
EOF

echo "📋 Execute os comandos em test_manual_commands.txt para teste detalhado"

# Cleanup
rm -f test_token_backend.php

echo ""
echo "✅ Script 148 concluído!"
echo ""
echo "📄 PRÓXIMO SCRIPT BASEADO NO RESULTADO:"
echo "   Se rotas não existem: 149-create-backend-audiencias.sh"
echo "   Se middleware incorreto: 150-fix-audiencias-middleware.sh"
echo "   Se tudo existe: 151-fix-permissions-audiencias.sh"