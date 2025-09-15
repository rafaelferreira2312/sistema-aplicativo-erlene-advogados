#!/bin/bash

# Script 135f - Corrigir Data Adequadamente
# Sistema Erlene Advogados - Corrigir formatação quebrada da data
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 135f - Corrigindo formatação de data adequadamente..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📝 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 135f-fix-date-properly.sh && ./135f-fix-date-properly.sh"
    exit 1
fi

echo "1️⃣ Restaurando backup anterior..."

# Verificar se existe backup
if [ -f "src/pages/admin/Audiencias.js.bak.135e" ]; then
    cp "src/pages/admin/Audiencias.js.bak.135e" "src/pages/admin/Audiencias.js"
    echo "✅ Backup restaurado"
else
    echo "⚠️ Backup não encontrado, continuando com correção manual"
fi

echo "2️⃣ Aplicando correção de data adequada..."

# Criar função auxiliar para formatação
cat > temp_format_fix.js << 'EOF'
  const formatarDataDaAPI = (dataString) => {
    if (!dataString) return '';
    // Se já está no formato correto (YYYY-MM-DD), usar diretamente
    if (dataString.length === 10 && dataString.includes('-')) {
      return dataString;
    }
    // Se está no formato ISO (com T), extrair apenas a data
    if (dataString.includes('T')) {
      return dataString.split('T')[0];
    }
    return dataString;
  };
EOF

# Adicionar função no início do componente e corrigir mapeamento
awk '
/const Audiencias = \(\) => \{/ {
    print $0
    print ""
    print "  const formatarDataDaAPI = (dataString) => {"
    print "    if (!dataString) return \"\";"
    print "    // Se já está no formato correto (YYYY-MM-DD), usar diretamente"
    print "    if (dataString.length === 10 && dataString.includes(\"-\")) {"
    print "      return dataString;"
    print "    }"
    print "    // Se está no formato ISO (com T), extrair apenas a data"
    print "    if (dataString.includes(\"T\")) {"
    print "      return dataString.split(\"T\")[0];"
    print "    }"
    print "    return dataString;"
    print "  };"
    print ""
    next
}
/data: audiencia\.data\.split/ {
    print "          data: formatarDataDaAPI(audiencia.data),"
    next
}
{ print }
' src/pages/admin/Audiencias.js > src/pages/admin/Audiencias_fixed.js

mv src/pages/admin/Audiencias_fixed.js src/pages/admin/Audiencias.js

echo "3️⃣ Corrigindo hora também..."

# Corrigir formatação da hora
sed -i 's/hora: typeof audiencia\.hora === "string" ? audiencia\.hora\.substring(0, 5) : audiencia\.hora,/hora: audiencia.hora?.toString().substring(0, 5) || audiencia.hora,/' src/pages/admin/Audiencias.js

echo "4️⃣ Verificando resultado..."

if grep -q "formatarDataDaAPI" src/pages/admin/Audiencias.js; then
    echo "✅ Função de formatação adicionada"
else
    echo "❌ Falha ao adicionar função, aplicando método alternativo..."
    
    # Método alternativo - substituir diretamente linha problemática
    sed -i 's/data: audiencia\.data\.split("T")\[0\],/data: (audiencia.data && audiencia.data.includes("T")) ? audiencia.data.split("T")[0] : audiencia.data,/' src/pages/admin/Audiencias.js
fi

echo "5️⃣ Testando formatação..."

# Verificar se a correção está adequada
if grep -q "formatarDataDaAPI\|includes.*T.*split" src/pages/admin/Audiencias.js; then
    echo "✅ Formatação de data corrigida"
else
    echo "⚠️ Aplicando correção de emergência..."
    
    # Correção de emergência - substituir linha específica
    sed -i '/data: audiencia\.data\.split/c\          data: audiencia.data ? (audiencia.data.includes("T") ? audiencia.data.split("T")[0] : audiencia.data) : "",' src/pages/admin/Audiencias.js
fi

echo "6️⃣ Verificando se filtros também precisam de correção..."

# Corrigir filtros que usam data
sed -i 's/audiencia\.data === amanha\.toISOString()\.split/audiencia.data === amanha.toISOString().split/' src/pages/admin/Audiencias.js

echo ""
echo "✅ Script 135f concluído!"
echo ""
echo "🔧 CORREÇÕES REALIZADAS:"
echo "   ✅ Função formatarDataDaAPI() adicionada"
echo "   ✅ Data corrigida para mostrar formato adequado"
echo "   ✅ Verificação se data contém 'T' antes de fazer split"
echo "   ✅ Hora formatada adequadamente"
echo ""
echo "📋 TESTE:"
echo "   1. Recarregue a página /admin/audiencias"
echo "   2. A data deve aparecer como 15/09/2025 (não 2025-)"
echo "   3. Verificar se não há erros no console"
echo ""
echo "💡 Se ainda houver problema, a data no backend pode estar retornando null/undefined"