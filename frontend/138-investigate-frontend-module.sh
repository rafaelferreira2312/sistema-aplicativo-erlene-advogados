#!/bin/bash

# Script 138 - Investigação Frontend Módulo (GENÉRICO)
# Sistema Erlene Advogados - Mapeamento completo de qualquer módulo frontend
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/
# USO: ./138-investigate-frontend-module.sh audiencias

echo "🎨 Script 138 - Investigação Frontend Módulo..."

# Verificar se foi passado o parâmetro
if [ $# -eq 0 ]; then
    echo "❌ Erro: Informe o nome do módulo a investigar"
    echo "📝 Uso correto:"
    echo "   cd frontend"
    echo "   chmod +x 138-investigate-frontend-module.sh && ./138-investigate-frontend-module.sh audiencias"
    echo "   chmod +x 138-investigate-frontend-module.sh && ./138-investigate-frontend-module.sh prazos"
    echo "   chmod +x 138-investigate-frontend-module.sh && ./138-investigate-frontend-module.sh atendimentos"
    exit 1
fi

MODULE_NAME="$1"
MODULE_NAME_UPPER="$(echo $MODULE_NAME | tr '[:lower:]' '[:upper:]')"
MODULE_NAME_LOWER="$(echo $MODULE_NAME | tr '[:upper:]' '[:lower:]')"
MODULE_NAME_SINGULAR=""

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
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

# Função para obter nome em inglês
get_english_name() {
    case "$1" in
        "audiencias") echo "hearings" ;;
        "audiencia") echo "hearing" ;;
        "prazos") echo "deadlines" ;;
        "prazo") echo "deadline" ;;
        "atendimentos") echo "appointments" ;;
        "atendimento") echo "appointment" ;;
        "processos") echo "processes" ;;
        "processo") echo "process" ;;
        "clientes") echo "clients" ;;
        "cliente") echo "client" ;;
        "financeiro") echo "financial" ;;
        *) echo "$1" ;;
    esac
}

MODULE_NAME_SINGULAR=$(get_singular "$MODULE_NAME_LOWER")
MODULE_NAME_ENGLISH=$(get_english_name "$MODULE_NAME_LOWER")
MODULE_NAME_ENGLISH_SINGULAR=$(get_english_name "$MODULE_NAME_SINGULAR")

echo "==================== RELATÓRIO DE INVESTIGAÇÃO FRONTEND ===================="
echo "Módulo: $MODULE_NAME"
echo "Singular: $MODULE_NAME_SINGULAR"
echo "Inglês: $MODULE_NAME_ENGLISH / $MODULE_NAME_ENGLISH_SINGULAR"
echo "Data: $(date)"
echo "Objetivo: Mapear todos os arquivos relacionados ao módulo $MODULE_NAME"
echo ""

# Criar arquivo de relatório
REPORT_FILE="investigation_report_frontend_${MODULE_NAME_LOWER}.txt"
echo "📝 Gerando relatório: $REPORT_FILE"

{
    echo "RELATÓRIO DE INVESTIGAÇÃO FRONTEND - $MODULE_NAME"
    echo "================================================="
    echo "Data: $(date)"
    echo ""

    echo "1️⃣ ESTRUTURA DE PASTAS"
    echo "======================"
    echo "Procurando pastas relacionadas a: $MODULE_NAME, $MODULE_NAME_SINGULAR, $MODULE_NAME_ENGLISH"
    find src/ -type d -iname "*${MODULE_NAME_LOWER}*" -o -type d -iname "*${MODULE_NAME_SINGULAR}*" -o -type d -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""

    echo "2️⃣ PÁGINAS PRINCIPAIS (src/pages/)"
    echo "=================================="
    echo "Procurando páginas principais:"
    find src/pages/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""
    echo "Conteúdo das páginas encontradas (primeiras 50 linhas):"
    for page_file in $(find src/pages/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null); do
        echo "--- ARQUIVO: $page_file ---"
        if [ -f "$page_file" ]; then
            head -50 "$page_file"
        else
            echo "Arquivo não encontrado"
        fi
        echo ""
    done

    echo "3️⃣ COMPONENTES (src/components/)"
    echo "================================"
    echo "Procurando componentes:"
    find src/components/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""
    echo "Pastas de componentes:"
    find src/components/ -type d -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""

    echo "4️⃣ SERVICES (src/services/)"
    echo "============================"
    echo "Procurando services:"
    find src/services/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""
    echo "Conteúdo dos services encontrados:"
    for service_file in $(find src/services/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null); do
        echo "--- ARQUIVO: $service_file ---"
        if [ -f "$service_file" ]; then
            head -100 "$service_file"
        else
            echo "Arquivo não encontrado"
        fi
        echo ""
    done

    echo "5️⃣ ROTAS (App.js)"
    echo "=================="
    echo "Procurando rotas relacionadas ao módulo no App.js:"
    if [ -f "src/App.js" ]; then
        grep -n -i "$MODULE_NAME_LOWER\|$MODULE_NAME_SINGULAR\|$MODULE_NAME_ENGLISH" src/App.js
    else
        echo "Arquivo src/App.js não encontrado"
    fi
    echo ""

    echo "6️⃣ HOOKS CUSTOMIZADOS (src/hooks/)"
    echo "=================================="
    echo "Procurando hooks customizados:"
    find src/hooks/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""

    echo "7️⃣ CONTEXTS (src/context/)"
    echo "=========================="
    echo "Procurando contexts:"
    find src/context/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""

    echo "8️⃣ UTILS/HELPERS (src/utils/)"
    echo "=============================="
    echo "Procurando utilitários:"
    find src/utils/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""

    echo "9️⃣ TIPOS/INTERFACES (src/types/)"
    echo "================================"
    echo "Procurando definições de tipos:"
    find src/types/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""

    echo "🔟 LAYOUTS ESPECÍFICOS (src/layouts/)"
    echo "====================================="
    echo "Procurando layouts específicos:"
    find src/layouts/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null
    echo ""

    echo "1️⃣1️⃣ VERIFICAÇÃO DE IMPORTS/EXPORTS"
    echo "===================================="
    echo "Procurando referências ao módulo em outros arquivos:"
    grep -r -l "$MODULE_NAME_LOWER\|$MODULE_NAME_SINGULAR\|$MODULE_NAME_ENGLISH" src/ --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" | head -15
    echo ""

    echo "1️⃣2️⃣ VERIFICAÇÃO EM PACKAGE.JSON"
    echo "================================"
    echo "Verificando dependências relacionadas:"
    if [ -f "package.json" ]; then
        grep -i "$MODULE_NAME_LOWER\|$MODULE_NAME_SINGULAR\|$MODULE_NAME_ENGLISH" package.json
    else
        echo "Arquivo package.json não encontrado"
    fi
    echo ""

    echo "1️⃣3️⃣ TODOS OS ARQUIVOS RELACIONADOS"
    echo "==================================="
    echo "Busca geral por qualquer arquivo que contenha o nome do módulo:"
    find src/ -type f -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_ENGLISH}*" | head -20
    echo ""

    echo "1️⃣4️⃣ ANÁLISE DE NAVEGAÇÃO"
    echo "========================="
    echo "Verificando menu/navegação (AdminLayout, Sidebar, etc.):"
    find src/components/layout/ -type f -name "*.js" -o -name "*.jsx" 2>/dev/null | xargs grep -l "$MODULE_NAME_LOWER\|$MODULE_NAME_SINGULAR\|$MODULE_NAME_ENGLISH" 2>/dev/null
    echo ""

    echo "1️⃣5️⃣ VERIFICAÇÃO DE ESTILOS"
    echo "==========================="
    echo "Procurando estilos específicos (CSS, Tailwind):"
    find src/ -type f -name "*.css" -o -name "*.scss" -o -name "*.sass" | xargs grep -l "$MODULE_NAME_LOWER\|$MODULE_NAME_SINGULAR\|$MODULE_NAME_ENGLISH" 2>/dev/null
    echo ""

} > "$REPORT_FILE"

echo ""
echo "✅ Relatório gerado: $REPORT_FILE"
echo ""
echo "📋 RESUMO DA INVESTIGAÇÃO:"
echo "=========================="

# Mostrar resumo na tela
echo "📁 Pastas encontradas:"
find src/ -type d -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null || echo "   Nenhuma pasta específica encontrada"

echo ""
echo "📄 Páginas encontradas:"
find src/pages/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null || echo "   Nenhuma página encontrada"

echo ""
echo "🎛️ Componentes encontrados:"
find src/components/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null || echo "   Nenhum componente encontrado"

echo ""
echo "🔧 Services encontrados:"
find src/services/ -type f -iname "*${MODULE_NAME_SINGULAR}*" -o -iname "*${MODULE_NAME_LOWER}*" -o -iname "*${MODULE_NAME_ENGLISH}*" 2>/dev/null || echo "   Nenhum service encontrado"

echo ""
echo "🛣️ Rotas no App.js:"
if [ -f "src/App.js" ]; then
    grep -n -i "$MODULE_NAME_LOWER\|$MODULE_NAME_SINGULAR\|$MODULE_NAME_ENGLISH" src/App.js || echo "   Nenhuma rota encontrada"
else
    echo "   Arquivo src/App.js não encontrado"
fi

echo ""
echo "📱 Verificação de integrações com módulos funcionais:"
echo "Comparando com processos e clientes que funcionam..."
if [ -f "src/services/processesService.js" ]; then
    echo "   ✅ processesService.js existe"
else
    echo "   ❌ processesService.js NÃO existe"
fi

if [ -f "src/services/clientsService.js" ]; then
    echo "   ✅ clientsService.js existe"
else
    echo "   ❌ clientsService.js NÃO existe"
fi

echo ""
echo "🔗 Verificação de apiClient:"
if [ -f "src/services/apiClient.js" ]; then
    echo "   ✅ apiClient.js existe"
else
    echo "   ❌ apiClient.js NÃO existe"
fi

echo ""
echo "==================== FIM DA INVESTIGAÇÃO ===================="
echo ""
echo "📝 PRÓXIMOS PASSOS:"
echo "1. Revisar o relatório completo: cat $REPORT_FILE"
echo "2. Comparar com o relatório do backend"
echo "3. Identificar o que está faltando para integração"
echo "4. Analisar diferenças com módulos funcionais"
echo ""
echo "🔄 Para investigar outro módulo:"
echo "   ./138-investigate-frontend-module.sh prazos"
echo "   ./138-investigate-frontend-module.sh atendimentos"
echo ""
echo "🔧 Para comparar com módulo funcional:"
echo "   ./138-investigate-frontend-module.sh processos"
echo "   ./138-investigate-frontend-module.sh clientes"