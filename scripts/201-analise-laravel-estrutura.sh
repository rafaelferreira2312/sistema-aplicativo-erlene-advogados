#!/bin/bash

# Script 201 - Análise Completa da Estrutura Laravel
# Sistema Erlene Advogados - Migração Laravel → Node.js Express
# Data: $(date +%Y-%m-%d)
# EXECUTE NA PASTA RAIZ DO PROJETO: sistema-aplicativo-erlene-advogados/

echo "🔍 Script 201 - Análise Completa da Estrutura Laravel"
echo "====================================================="
echo "📊 Analisando Controllers, Models, Routes, Middleware do Laravel"
echo "🎯 Objetivo: Mapear TODA estrutura para migração Node.js"
echo "🕒 Iniciado em: $(date '+%Y-%m-%d %H:%M:%S')"

# Verificar se estamos no diretório correto
if [ ! -d "backend" ]; then
    echo "❌ ERRO: Pasta backend/ não encontrada!"
    echo "   Execute este script na pasta raiz do projeto"
    exit 1
fi

echo "✅ Diretório backend/ encontrado"

# Criar diretório para relatórios de análise
ANALYSIS_DIR="migration_analysis/$(date +%Y%m%d_%H%M%S)_laravel_structure"
echo "📁 Criando diretório de análise: $ANALYSIS_DIR"
mkdir -p "$ANALYSIS_DIR"

echo ""
echo "🛣️  1. ANÁLISE DE ROTAS (routes/)"
echo "================================"

ROUTES_REPORT="$ANALYSIS_DIR/01_routes_analysis.md"
echo "# Análise das Rotas Laravel" > "$ROUTES_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$ROUTES_REPORT"
echo "" >> "$ROUTES_REPORT"

if [ -f "backend/routes/api.php" ]; then
    echo "📋 Analisando routes/api.php..."
    
    echo "## Rotas da API (routes/api.php)" >> "$ROUTES_REPORT"
    echo "\`\`\`php" >> "$ROUTES_REPORT"
    cat "backend/routes/api.php" >> "$ROUTES_REPORT"
    echo "\`\`\`" >> "$ROUTES_REPORT"
    echo "" >> "$ROUTES_REPORT"
    
    # Extrair rotas específicas
    echo "## Resumo das Rotas Encontradas" >> "$ROUTES_REPORT"
    
    # Contar rotas por método HTTP
    GET_ROUTES=$(grep -c "Route::get" "backend/routes/api.php" 2>/dev/null || echo "0")
    POST_ROUTES=$(grep -c "Route::post" "backend/routes/api.php" 2>/dev/null || echo "0")
    PUT_ROUTES=$(grep -c "Route::put" "backend/routes/api.php" 2>/dev/null || echo "0")
    DELETE_ROUTES=$(grep -c "Route::delete" "backend/routes/api.php" 2>/dev/null || echo "0")
    RESOURCE_ROUTES=$(grep -c "Route::resource" "backend/routes/api.php" 2>/dev/null || echo "0")
    
    echo "- **GET**: $GET_ROUTES rotas" >> "$ROUTES_REPORT"
    echo "- **POST**: $POST_ROUTES rotas" >> "$ROUTES_REPORT"  
    echo "- **PUT**: $PUT_ROUTES rotas" >> "$ROUTES_REPORT"
    echo "- **DELETE**: $DELETE_ROUTES rotas" >> "$ROUTES_REPORT"
    echo "- **RESOURCE**: $RESOURCE_ROUTES rotas" >> "$ROUTES_REPORT"
    echo "" >> "$ROUTES_REPORT"
    
    # Listar controllers usados nas rotas
    echo "## Controllers Utilizados nas Rotas" >> "$ROUTES_REPORT"
    grep -o "[A-Z][a-zA-Z]*Controller" "backend/routes/api.php" 2>/dev/null | sort | uniq | sed 's/^/- /' >> "$ROUTES_REPORT"
    echo "" >> "$ROUTES_REPORT"
    
    echo "✅ Rotas API analisadas: $((GET_ROUTES + POST_ROUTES + PUT_ROUTES + DELETE_ROUTES + RESOURCE_ROUTES)) total"
else
    echo "⚠️  Arquivo routes/api.php não encontrado"
    echo "⚠️  routes/api.php não encontrado" >> "$ROUTES_REPORT"
fi

# Verificar outras rotas
if [ -f "backend/routes/web.php" ]; then
    echo "📋 Analisando routes/web.php..."
    echo "## Rotas Web (routes/web.php)" >> "$ROUTES_REPORT"
    echo "\`\`\`php" >> "$ROUTES_REPORT"
    cat "backend/routes/web.php" >> "$ROUTES_REPORT"
    echo "\`\`\`" >> "$ROUTES_REPORT"
    echo "✅ Rotas Web analisadas"
else
    echo "⚠️  Arquivo routes/web.php não encontrado"
fi

echo ""
echo "🏗️  2. ANÁLISE DE CONTROLLERS"
echo "============================"

CONTROLLERS_REPORT="$ANALYSIS_DIR/02_controllers_analysis.md"
echo "# Análise dos Controllers Laravel" > "$CONTROLLERS_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$CONTROLLERS_REPORT"
echo "" >> "$CONTROLLERS_REPORT"

if [ -d "backend/app/Http/Controllers" ]; then
    echo "📁 Mapeando estrutura de Controllers..."
    
    # Listar todos os controllers
    echo "## Estrutura de Controllers" >> "$CONTROLLERS_REPORT"
    find "backend/app/Http/Controllers" -name "*.php" -type f | sort | sed 's|backend/app/Http/Controllers/||' | sed 's/^/- /' >> "$CONTROLLERS_REPORT"
    echo "" >> "$CONTROLLERS_REPORT"
    
    TOTAL_CONTROLLERS=$(find "backend/app/Http/Controllers" -name "*.php" -type f | wc -l)
    echo "✅ Controllers encontrados: $TOTAL_CONTROLLERS"
    
    # Analisar controllers principais
    echo "## Detalhes dos Controllers Principais" >> "$CONTROLLERS_REPORT"
    
    for CONTROLLER in $(find "backend/app/Http/Controllers" -name "*.php" -type f | head -10); do
        CONTROLLER_NAME=$(basename "$CONTROLLER" .php)
        echo "📄 Analisando: $CONTROLLER_NAME"
        
        echo "### $CONTROLLER_NAME" >> "$CONTROLLERS_REPORT"
        echo "**Arquivo:** \`$(echo $CONTROLLER | sed 's|backend/||')\`" >> "$CONTROLLERS_REPORT"
        
        # Extrair métodos públicos
        METHODS=$(grep -n "public function" "$CONTROLLER" 2>/dev/null | grep -v "__construct" | cut -d':' -f2 | sed 's/public function //' | sed 's/(.*//' | sort)
        if [ ! -z "$METHODS" ]; then
            echo "**Métodos:**" >> "$CONTROLLERS_REPORT"
            echo "$METHODS" | sed 's/^/- /' >> "$CONTROLLERS_REPORT"
        fi
        
        # Verificar imports/dependências
        IMPORTS=$(grep "^use " "$CONTROLLER" 2>/dev/null | head -5)
        if [ ! -z "$IMPORTS" ]; then
            echo "**Dependências principais:**" >> "$CONTROLLERS_REPORT"
            echo "\`\`\`php" >> "$CONTROLLERS_REPORT"
            echo "$IMPORTS" >> "$CONTROLLERS_REPORT"
            echo "\`\`\`" >> "$CONTROLLERS_REPORT"
        fi
        
        echo "" >> "$CONTROLLERS_REPORT"
    done
    
    # Contar por tipo de controller
    API_CONTROLLERS=$(find "backend/app/Http/Controllers" -path "*/Api/*" -name "*.php" | wc -l)
    AUTH_CONTROLLERS=$(find "backend/app/Http/Controllers" -path "*Auth*" -name "*.php" | wc -l)
    
    echo "## Resumo por Categoria" >> "$CONTROLLERS_REPORT"
    echo "- **Total**: $TOTAL_CONTROLLERS controllers" >> "$CONTROLLERS_REPORT"
    echo "- **API Controllers**: $API_CONTROLLERS" >> "$CONTROLLERS_REPORT"
    echo "- **Auth Controllers**: $AUTH_CONTROLLERS" >> "$CONTROLLERS_REPORT"
    echo "" >> "$CONTROLLERS_REPORT"
    
else
    echo "⚠️  Diretório Controllers não encontrado"
    echo "⚠️  Diretório Controllers não encontrado" >> "$CONTROLLERS_REPORT"
fi

echo ""
echo "🗃️  3. ANÁLISE DE MODELS"
echo "======================"

MODELS_REPORT="$ANALYSIS_DIR/03_models_analysis.md"
echo "# Análise dos Models Laravel" > "$MODELS_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$MODELS_REPORT"
echo "" >> "$MODELS_REPORT"

if [ -d "backend/app/Models" ]; then
    echo "📊 Mapeando Models e relacionamentos..."
    
    echo "## Lista de Models" >> "$MODELS_REPORT"
    find "backend/app/Models" -name "*.php" -type f | sort | sed 's|backend/app/Models/||' | sed 's/.php$//' | sed 's/^/- /' >> "$MODELS_REPORT"
    echo "" >> "$MODELS_REPORT"
    
    TOTAL_MODELS=$(find "backend/app/Models" -name "*.php" -type f | wc -l)
    echo "✅ Models encontrados: $TOTAL_MODELS"
    
    # Analisar cada model
    echo "## Detalhes dos Models" >> "$MODELS_REPORT"
    
    for MODEL in $(find "backend/app/Models" -name "*.php" -type f); do
        MODEL_NAME=$(basename "$MODEL" .php)
        echo "📄 Analisando Model: $MODEL_NAME"
        
        echo "### $MODEL_NAME" >> "$MODELS_REPORT"
        echo "**Arquivo:** \`$(echo $MODEL | sed 's|backend/||')\`" >> "$MODELS_REPORT"
        
        # Extrair fillable fields
        FILLABLE=$(grep -A 10 "\$fillable" "$MODEL" 2>/dev/null | grep -E "['\"]\w+['\"]" | tr -d "',\" " | grep -v "^$")
        if [ ! -z "$FILLABLE" ]; then
            echo "**Campos fillable:**" >> "$MODELS_REPORT"
            echo "$FILLABLE" | sed 's/^/- /' >> "$MODELS_REPORT"
        fi
        
        # Extrair relacionamentos
        RELATIONSHIPS=$(grep -n "public function.*belongsTo\|hasMany\|hasOne\|belongsToMany" "$MODEL" 2>/dev/null | cut -d':' -f2 | sed 's/public function //' | sed 's/().*$//' | head -5)
        if [ ! -z "$RELATIONSHIPS" ]; then
            echo "**Relacionamentos:**" >> "$MODELS_REPORT"
            echo "$RELATIONSHIPS" | sed 's/^/- /' >> "$MODELS_REPORT"
        fi
        
        echo "" >> "$MODELS_REPORT"
    done
    
else
    echo "⚠️  Diretório Models não encontrado"
    echo "⚠️  Diretório Models não encontrado" >> "$MODELS_REPORT"
fi

echo ""
echo "🔒 4. ANÁLISE DE MIDDLEWARE"
echo "========================="

MIDDLEWARE_REPORT="$ANALYSIS_DIR/04_middleware_analysis.md"
echo "# Análise dos Middleware Laravel" > "$MIDDLEWARE_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$MIDDLEWARE_REPORT"
echo "" >> "$MIDDLEWARE_REPORT"

if [ -d "backend/app/Http/Middleware" ]; then
    echo "🔐 Analisando Middleware de segurança e autenticação..."
    
    echo "## Lista de Middleware" >> "$MIDDLEWARE_REPORT"
    find "backend/app/Http/Middleware" -name "*.php" -type f | sort | sed 's|backend/app/Http/Middleware/||' | sed 's/.php$//' | sed 's/^/- /' >> "$MIDDLEWARE_REPORT"
    echo "" >> "$MIDDLEWARE_REPORT"
    
    TOTAL_MIDDLEWARE=$(find "backend/app/Http/Middleware" -name "*.php" -type f | wc -l)
    echo "✅ Middleware encontrados: $TOTAL_MIDDLEWARE"
    
    # Listar métodos handle de cada middleware
    echo "## Detalhes dos Middleware" >> "$MIDDLEWARE_REPORT"
    
    for MIDDLEWARE in $(find "backend/app/Http/Middleware" -name "*.php" -type f); do
        MIDDLEWARE_NAME=$(basename "$MIDDLEWARE" .php)
        echo "🔒 Analisando: $MIDDLEWARE_NAME"
        
        echo "### $MIDDLEWARE_NAME" >> "$MIDDLEWARE_REPORT"
        echo "**Arquivo:** \`$(echo $MIDDLEWARE | sed 's|backend/||')\`" >> "$MIDDLEWARE_REPORT"
        
        # Verificar se tem método handle
        if grep -q "function handle" "$MIDDLEWARE" 2>/dev/null; then
            echo "**Possui método handle:** ✅" >> "$MIDDLEWARE_REPORT"
        else
            echo "**Possui método handle:** ❌" >> "$MIDDLEWARE_REPORT"
        fi
        
        echo "" >> "$MIDDLEWARE_REPORT"
    done
    
else
    echo "⚠️  Diretório Middleware não encontrado"
    echo "⚠️  Diretório Middleware não encontrado" >> "$MIDDLEWARE_REPORT"
fi

echo ""
echo "📦 5. ANÁLISE DE DEPENDÊNCIAS"
echo "============================"

DEPENDENCIES_REPORT="$ANALYSIS_DIR/05_dependencies_analysis.md"
echo "# Análise das Dependências Laravel" > "$DEPENDENCIES_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$DEPENDENCIES_REPORT"
echo "" >> "$DEPENDENCIES_REPORT"

if [ -f "backend/composer.json" ]; then
    echo "📋 Analisando composer.json..."
    
    echo "## Dependências do Composer" >> "$DEPENDENCIES_REPORT"
    echo "\`\`\`json" >> "$DEPENDENCIES_REPORT"
    cat "backend/composer.json" >> "$DEPENDENCIES_REPORT"
    echo "\`\`\`" >> "$DEPENDENCIES_REPORT"
    echo "" >> "$DEPENDENCIES_REPORT"
    
    # Extrair principais dependências
    echo "## Principais Pacotes Identificados" >> "$DEPENDENCIES_REPORT"
    
    if grep -q "laravel/framework" "backend/composer.json"; then
        LARAVEL_VERSION=$(grep "laravel/framework" "backend/composer.json" | cut -d'"' -f4)
        echo "- **Laravel Framework**: $LARAVEL_VERSION" >> "$DEPENDENCIES_REPORT"
    fi
    
    grep -E "jwt|stripe|mercadopago|google|microsoft" "backend/composer.json" 2>/dev/null | sed 's/.*"\(.*\)": "\(.*\)".*/- **\1**: \2/' >> "$DEPENDENCIES_REPORT"
    
    echo "✅ composer.json analisado"
    
else
    echo "⚠️  Arquivo composer.json não encontrado"
    echo "⚠️  composer.json não encontrado" >> "$DEPENDENCIES_REPORT"
fi

echo ""
echo "🗄️  6. ANÁLISE DE MIGRATIONS"
echo "=========================="

MIGRATIONS_REPORT="$ANALYSIS_DIR/06_migrations_analysis.md"
echo "# Análise das Migrations Laravel" > "$MIGRATIONS_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$MIGRATIONS_REPORT"
echo "" >> "$MIGRATIONS_REPORT"

if [ -d "backend/database/migrations" ]; then
    echo "🗃️  Analisando estrutura do banco via migrations..."
    
    echo "## Lista de Migrations" >> "$MIGRATIONS_REPORT"
    find "backend/database/migrations" -name "*.php" -type f | sort | sed 's|backend/database/migrations/||' | sed 's/^/- /' >> "$MIGRATIONS_REPORT"
    echo "" >> "$MIGRATIONS_REPORT"
    
    TOTAL_MIGRATIONS=$(find "backend/database/migrations" -name "*.php" -type f | wc -l)
    echo "✅ Migrations encontradas: $TOTAL_MIGRATIONS"
    
    # Identificar tabelas principais
    echo "## Tabelas Identificadas" >> "$MIGRATIONS_REPORT"
    find "backend/database/migrations" -name "*.php" -type f | xargs grep -l "Schema::create" | while read migration; do
        TABLE_NAME=$(grep "Schema::create" "$migration" | sed "s/.*create('\([^']*\)'.*/\1/" | head -1)
        if [ ! -z "$TABLE_NAME" ]; then
            echo "- **$TABLE_NAME**" >> "$MIGRATIONS_REPORT"
        fi
    done
    echo "" >> "$MIGRATIONS_REPORT"
    
else
    echo "⚠️  Diretório migrations não encontrado"
    echo "⚠️  Diretório migrations não encontrado" >> "$MIGRATIONS_REPORT"
fi

echo ""
echo "📊 7. RELATÓRIO FINAL DA ANÁLISE"
echo "================================"

SUMMARY_REPORT="$ANALYSIS_DIR/00_summary_migration.md"
echo "# RELATÓRIO FINAL - Análise Laravel para Migração Node.js" > "$SUMMARY_REPORT"
echo "## Sistema Erlene Advogados" >> "$SUMMARY_REPORT"
echo "### Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$SUMMARY_REPORT"
echo "" >> "$SUMMARY_REPORT"

echo "## 📊 Resumo Geral" >> "$SUMMARY_REPORT"
echo "- **Controllers**: ${TOTAL_CONTROLLERS:-0}" >> "$SUMMARY_REPORT"
echo "- **Models**: ${TOTAL_MODELS:-0}" >> "$SUMMARY_REPORT"
echo "- **Middleware**: ${TOTAL_MIDDLEWARE:-0}" >> "$SUMMARY_REPORT"
echo "- **Migrations**: ${TOTAL_MIGRATIONS:-0}" >> "$SUMMARY_REPORT"
echo "- **Rotas API**: $((GET_ROUTES + POST_ROUTES + PUT_ROUTES + DELETE_ROUTES + RESOURCE_ROUTES))" >> "$SUMMARY_REPORT"
echo "" >> "$SUMMARY_REPORT"

echo "## 🎯 Prioridades para Migração Node.js" >> "$SUMMARY_REPORT"
echo "1. **Autenticação JWT** (crítico)" >> "$SUMMARY_REPORT"
echo "2. **CRUD Clientes** (alta prioridade)" >> "$SUMMARY_REPORT"
echo "3. **CRUD Processos** (alta prioridade)" >> "$SUMMARY_REPORT"
echo "4. **Dashboard** (média prioridade)" >> "$SUMMARY_REPORT"
echo "5. **Portal Cliente** (média prioridade)" >> "$SUMMARY_REPORT"
echo "6. **APIs de Pagamento** (baixa prioridade)" >> "$SUMMARY_REPORT"
echo "" >> "$SUMMARY_REPORT"

echo "## 📁 Arquivos Gerados" >> "$SUMMARY_REPORT"
echo "- [Análise de Rotas](01_routes_analysis.md)" >> "$SUMMARY_REPORT"
echo "- [Análise de Controllers](02_controllers_analysis.md)" >> "$SUMMARY_REPORT"
echo "- [Análise de Models](03_models_analysis.md)" >> "$SUMMARY_REPORT"
echo "- [Análise de Middleware](04_middleware_analysis.md)" >> "$SUMMARY_REPORT"
echo "- [Análise de Dependências](05_dependencies_analysis.md)" >> "$SUMMARY_REPORT"
echo "- [Análise de Migrations](06_migrations_analysis.md)" >> "$SUMMARY_REPORT"
echo "" >> "$SUMMARY_REPORT"

echo "✅ ANÁLISE COMPLETA FINALIZADA!"
echo "==============================="
echo "📁 Relatórios salvos em: $ANALYSIS_DIR"
echo "📊 Total de arquivos analisados:"
echo "   • Controllers: ${TOTAL_CONTROLLERS:-0}"
echo "   • Models: ${TOTAL_MODELS:-0}" 
echo "   • Middleware: ${TOTAL_MIDDLEWARE:-0}"
echo "   • Migrations: ${TOTAL_MIGRATIONS:-0}"
echo "   • Rotas API: $((GET_ROUTES + POST_ROUTES + PUT_ROUTES + DELETE_ROUTES + RESOURCE_ROUTES))"
echo ""
echo "📋 Próximo script: 202-analise-banco-mysql.sh"
echo "💡 Para continuar, digite: 'continuar'"