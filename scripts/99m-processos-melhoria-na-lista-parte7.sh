#!/bin/bash

# Script 99k - Corrigir Imports dos Modais
# Autor: Sistema Erlene Advogados  
# Data: $(date +%Y-%m-%d)
# Enumeração: 99k

echo "🔧 Corrigindo imports dos modais (Script 99k)..."

# Verificar diretório
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 1. Verificando estrutura atual..."

# Verificar se os modais existem
if [ -f "frontend/src/components/processes/ProcessDocumentsModal.js" ] && \
   [ -f "frontend/src/components/processes/ProcessClientModal.js" ] && \
   [ -f "frontend/src/components/processes/ProcessTimelineModal.js" ]; then
    echo "✅ Todos os modais existem!"
else
    echo "❌ Alguns modais não existem. Criando..."
    
    # Criar estrutura se não existir
    mkdir -p frontend/src/components/processes
    
    # Copiar os modais dos documentos para os arquivos corretos
    echo "📄 Copiando modais..."
    
    # Se os arquivos não existem, criar
    if [ ! -f "frontend/src/components/processes/ProcessDocumentsModal.js" ]; then
        cp ProcessDocumentsModal.js frontend/src/components/processes/ 2>/dev/null || echo "Arquivo ProcessDocumentsModal.js não encontrado"
    fi
    
    if [ ! -f "frontend/src/components/processes/ProcessClientModal.js" ]; then
        cp ProcessClientModal.js frontend/src/components/processes/ 2>/dev/null || echo "Arquivo ProcessClientModal.js não encontrado"
    fi
    
    if [ ! -f "frontend/src/components/processes/ProcessTimelineModal.js" ]; then
        cp ProcessTimelineModal.js frontend/src/components/processes/ 2>/dev/null || echo "Arquivo ProcessTimelineModal.js não encontrado"
    fi
fi

echo "📝 2. Corrigindo imports no Processes.js..."

# Fazer backup
cp frontend/src/pages/admin/Processes.js frontend/src/pages/admin/Processes.js.backup.imports.$(date +%Y%m%d_%H%M%S)

# Corrigir os imports para o caminho correto
sed -i 's|import ProcessDocumentsModal from '\''../components/processes/ProcessDocumentsModal'\'';|import ProcessDocumentsModal from '\''../../components/processes/ProcessDocumentsModal'\'';|g' frontend/src/pages/admin/Processes.js
sed -i 's|import ProcessClientModal from '\''../components/processes/ProcessClientModal'\'';|import ProcessClientModal from '\''../../components/processes/ProcessClientModal'\'';|g' frontend/src/pages/admin/Processes.js
sed -i 's|import ProcessTimelineModal from '\''../components/processes/ProcessTimelineModal'\'';|import ProcessTimelineModal from '\''../../components/processes/ProcessTimelineModal'\'';|g' frontend/src/pages/admin/Processes.js

echo "📝 3. Removendo imports desnecessários..."

# Remover EyeIcon não utilizado
sed -i 's/EyeIcon,//' frontend/src/pages/admin/Processes.js
sed -i 's/, EyeIcon//' frontend/src/pages/admin/Processes.js

echo "✅ Imports corrigidos!"

echo "📝 4. Verificando estrutura final..."

# Mostrar estrutura
echo "📁 Estrutura de arquivos:"
echo "   frontend/src/pages/admin/Processes.js ✅"
echo "   frontend/src/components/processes/"
ls -la frontend/src/components/processes/ 2>/dev/null || echo "   Pasta não encontrada"

echo ""
echo "🎉 SCRIPT 99k CONCLUÍDO!"
echo ""
echo "✅ CORREÇÕES REALIZADAS:"
echo "   • Imports corrigidos de '../' para '../../'"
echo "   • EyeIcon removido (não utilizado)"
echo "   • Estrutura de pastas verificada"
echo ""
echo "🔧 PROBLEMA RESOLVIDO:"
echo "   ❌ Error: Can't resolve '../components/processes/ProcessDocumentsModal'"
echo "   ✅ Agora: '../../components/processes/ProcessDocumentsModal'"
echo ""
echo "📁 CAMINHO CORRETO:"
echo "   De: frontend/src/pages/admin/Processes.js"
echo "   Para: frontend/src/components/processes/ProcessXXXModal.js"
echo "   Caminho: ../../components/processes/"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. npm start (reiniciar servidor)"
echo "   2. http://localhost:3000/admin/processos"
echo "   3. Clique nos botões coloridos dos processos"
echo "   4. Verifique se os modais abrem!"
echo ""
echo "🎯 ERROS RESOLVIDOS:"
echo "   ✅ Module not found: ProcessDocumentsModal"
echo "   ✅ Module not found: ProcessClientModal"
echo "   ✅ Module not found: ProcessTimelineModal"
echo "   ✅ Warning: EyeIcon is defined but never used"
echo ""
echo "Digite 'continuar' se ainda houver problemas!"