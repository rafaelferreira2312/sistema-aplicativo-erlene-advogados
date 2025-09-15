#!/bin/bash

# Script 137 - Investigação Backend Módulo (GENÉRICO)
# Sistema Erlene Advogados - Mapeamento completo de qualquer módulo
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/
# USO: ./137-investigate-backend-module.sh audiencias

echo "🔍 Script 137 - Investigação Backend Módulo..."

# Verificar se foi passado o parâmetro
if [ $# -eq 0 ]; then
    echo "❌ Erro: Informe o nome do módulo a investigar"
    echo "📝 Uso correto:"
    echo "   cd backend"
    echo "   chmod +x 137-investigate-backend-module.sh && ./137-investigate-backend-module.sh audiencias"
    echo "   chmod +x 137-investigate-backend-module.sh && ./137-investigate-backend-module.sh prazos"
    echo "   chmod +x 137-investigate-backend-module.sh && ./137-investigate-backend-module.sh atendimentos"
    exit 1
fi

MODULE_NAME="$1"
MODULE_NAME_UPPER="$(echo $MODULE_NAME | tr '[:lower:]' '[:upper:]')"
MODULE_NAME_LOWER="$(echo $MODULE_NAME | tr '[:upper:]' '[:lower:]')"
MODULE_NAME_SINGULAR=""

# Verificar se estamos no diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

# Função para obter singular (básico)
get_singular() {
    case "$1" in
        "audiencias") echo "audiencia" ;;
        "prazos") echo "prazo" ;;
        "atendimentos") echo "atendimento" ;;
        "processos") echo "processo" ;;
        "clientes") echo "cliente" ;;
        "financeiro") echo "financeiro" ;;
        *) echo "$1" ;;
    esac
}

MODULE_NAME_SINGULAR=$(get_singular "$MODULE_NAME_LOWER")

echo "==================== RELATÓRIO DE INVESTIGAÇÃO BACKEND ===================="
echo "Módulo: $MODULE_NAME"
echo "Singular: $MODULE_NAME_SINGULAR"
echo "Data: $(date)"
echo "Objetivo: Mapear todos os arquivos relacionados ao módulo $MODULE_NAME"
echo ""

# Criar arquivo de relatório
REPORT_FILE="investigation_report_backend_${MODULE_NAME_LOWER}.txt"
echo "📝 Gerando relatório: $REPORT_FILE"

{
    echo "RELATÓRIO DE INVESTIGAÇÃO BACKEND - $MODULE_NAME"
    echo "================================================"
    echo "Data: $(date)"
    echo ""

    echo "1️⃣ ESTRUTURA DE PASTAS"
    echo "======================"
    echo "Procurando pastas relacionadas a: $MODULE_NAME, $MODULE_NAME_SINGULAR"
    find . -type d -iname "*${MODULE_NAME_LOWER}*" -o -type d -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null
    echo ""

    echo "2️⃣ MODELS"
    echo "=========="
    echo "Procurando models em app/Models/:"
    find app/Models/ -type f -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null
    find app/Models/ -type f -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null
    echo ""
    echo "Conteúdo dos models encontrados:"
    for model_file in $(find app/Models/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null); do
        echo "--- ARQUIVO: $model_file ---"
        if [ -f "$model_file" ]; then
            head -50 "$model_file"
        else
            echo "Arquivo não encontrado"
        fi
        echo ""
    done

    echo "3️⃣ CONTROLLERS"
    echo "=============="
    echo "Procurando controllers:"
    find app/Http/Controllers/ -type f -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null
    find app/Http/Controllers/ -type f -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null
    echo ""
    echo "Conteúdo dos controllers encontrados:"
    for controller_file in $(find app/Http/Controllers/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null); do
        echo "--- ARQUIVO: $controller_file ---"
        if [ -f "$controller_file" ]; then
            head -100 "$controller_file"
        else
            echo "Arquivo não encontrado"
        fi
        echo ""
    done

    echo "4️⃣ MIGRATIONS"
    echo "============="
    echo "Procurando migrations:"
    find database/migrations/ -type f -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null
    find database/migrations/ -type f -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null
    echo ""

    echo "5️⃣ SEEDERS"
    echo "=========="
    echo "Procurando seeders:"
    find database/seeders/ -type f -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null
    find database/seeders/ -type f -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null
    echo ""

    echo "6️⃣ ROTAS (routes/api.php)"
    echo "========================="
    echo "Procurando rotas relacionadas ao módulo:"
    if [ -f "routes/api.php" ]; then
        grep -n -i "$MODULE_NAME_LOWER\|$MODULE_NAME_SINGULAR" routes/api.php
    else
        echo "Arquivo routes/api.php não encontrado"
    fi
    echo ""

    echo "7️⃣ SERVICES"
    echo "==========="
    echo "Procurando services:"
    find app/Services/ -type f -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null
    find app/Services/ -type f -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null
    echo ""

    echo "8️⃣ REQUESTS"
    echo "==========="
    echo "Procurando form requests:"
    find app/Http/Requests/ -type f -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null
    find app/Http/Requests/ -type f -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null
    echo ""

    echo "9️⃣ RECURSOS (Resources)"
    echo "======================="
    echo "Procurando API resources:"
    find app/Http/Resources/ -type f -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null
    find app/Http/Resources/ -type f -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null
    echo ""

    echo "🔟 MIDDLEWARE ESPECÍFICO"
    echo "======================="
    echo "Procurando middlewares específicos:"
    find app/Http/Middleware/ -type f -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null
    find app/Http/Middleware/ -type f -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null
    echo ""

    echo "1️⃣1️⃣ TODOS OS ARQUIVOS RELACIONADOS"
    echo "=================================="
    echo "Busca geral por qualquer arquivo que contenha o nome do módulo:"
    find . -type f -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_SINGULAR}*" | head -20
    echo ""

    echo "1️⃣2️⃣ VERIFICAÇÃO DE TABELA NO BANCO"
    echo "==================================="
    echo "Verificando se existe tabela no banco (via migration):"
    if [ -f ".env" ]; then
        echo "Arquivo .env encontrado - configurações de banco:"
        grep "DB_" .env
    else
        echo "Arquivo .env não encontrado"
    fi
    echo ""

    echo "1️⃣3️⃣ ANÁLISE DE DEPENDÊNCIAS"
    echo "============================"
    echo "Procurando referencias ao módulo em outros arquivos:"
    grep -r -l "$MODULE_NAME_LOWER\|$MODULE_NAME_SINGULAR" app/ --include="*.php" | head -10
    echo ""

} > "$REPORT_FILE"

echo ""
echo "✅ Relatório gerado: $REPORT_FILE"
echo ""
echo "📋 RESUMO DA INVESTIGAÇÃO:"
echo "=========================="

# Mostrar resumo na tela
echo "📁 Pastas encontradas:"
find . -type d -iname "*${MODULE_NAME_LOWER}*" -o -type d -iname "*${MODULE_NAME_SINGULAR}*" 2>/dev/null || echo "   Nenhuma pasta específica encontrada"

echo ""
echo "📄 Models encontrados:"
find app/Models/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null || echo "   Nenhum model encontrado"

echo ""
echo "🎛️ Controllers encontrados:"
find app/Http/Controllers/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null || echo "   Nenhum controller encontrado"

echo ""
echo "🗄️ Migrations encontradas:"
find database/migrations/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null || echo "   Nenhuma migration encontrada"

echo ""
echo "🌱 Seeders encontrados:"
find database/seeders/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" 2>/dev/null || echo "   Nenhum seeder encontrado"

echo ""
echo "🛣️ Rotas em routes/api.php:"
if [ -f "routes/api.php" ]; then
    grep -n -i "$MODULE_NAME_LOWER\|$MODULE_NAME_SINGULAR" routes/api.php || echo "   Nenhuma rota encontrada"
else
    echo "   Arquivo routes/api.php não encontrado"
fi

echo ""
echo "==================== FIM DA INVESTIGAÇÃO ===================="
echo ""
echo "📝 PRÓXIMOS PASSOS:"
echo "1. Revisar o relatório completo: cat $REPORT_FILE"
echo "2. Executar script de investigação do frontend"
echo "3. Comparar com módulos funcionais (processos, clientes)"
echo "4. Identificar o que está faltando para o módulo $MODULE_NAME"
echo ""
echo "🔄 Para investigar outro módulo:"
echo "   ./137-investigate-backend-module.sh prazos"
echo "   ./137-investigate-backend-module.sh atendimentos"