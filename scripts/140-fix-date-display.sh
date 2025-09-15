#!/bin/bash

# Script 140 - Corrigir formatação de data na exibição
# Sistema Erlene Advogados - Corrigir formatDate no componente
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "📅 Script 140 - Corrigindo formatação de data na exibição..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📝 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 140-fix-date-display.sh && ./140-fix-date-display.sh"
    exit 1
fi

echo "1️⃣ Fazendo backup do componente..."

if [ -f "src/pages/admin/Audiencias.js" ]; then
    cp "src/pages/admin/Audiencias.js" "src/pages/admin/Audiencias.js.bak.140"
    echo "✅ Backup criado: Audiencias.js.bak.140"
fi

echo "2️⃣ Corrigindo função formatDate..."

# Localizar e substituir a função formatDate
sed -i.tmp '
/const formatDate = (dateString) => {/,/};/{
  c\
  const formatDate = (dateString) => {\
    if (!dateString) return "N/A";\
    try {\
      // Se vier no formato ISO, extrair apenas a data\
      let cleanDate = dateString;\
      if (typeof dateString === "string" && dateString.includes("T")) {\
        cleanDate = dateString.split("T")[0];\
      }\
      \
      // Converter para Date e formatar\
      const date = new Date(cleanDate + "T00:00:00.000Z");\
      return date.toLocaleDateString("pt-BR");\
    } catch (e) {\
      console.error("Erro ao formatar data:", dateString, e);\
      return "Data inválida";\
    }\
  };
}
' src/pages/admin/Audiencias.js

# Remover arquivo temporário
rm -f src/pages/admin/Audiencias.js.tmp

echo "3️⃣ Verificando se correção foi aplicada..."

if grep -q "cleanDate = dateString.split" src/pages/admin/Audiencias.js; then
    echo "✅ Função formatDate corrigida"
else
    echo "⚠️ Sed falhou, aplicando correção manual..."
    
    # Método alternativo - encontrar linha e substituir arquivo inteiro
    awk '
    BEGIN { in_function = 0 }
    /const formatDate = \(dateString\) => \{/ {
        print "  const formatDate = (dateString) => {"
        print "    if (!dateString) return \"N/A\";"
        print "    try {"
        print "      // Se vier no formato ISO, extrair apenas a data"
        print "      let cleanDate = dateString;"
        print "      if (typeof dateString === \"string\" && dateString.includes(\"T\")) {"
        print "        cleanDate = dateString.split(\"T\")[0];"
        print "      }"
        print "      "
        print "      // Converter para Date e formatar"
        print "      const date = new Date(cleanDate + \"T00:00:00.000Z\");"
        print "      return date.toLocaleDateString(\"pt-BR\");"
        print "    } catch (e) {"
        print "      console.error(\"Erro ao formatar data:\", dateString, e);"
        print "      return \"Data inválida\";"
        print "    }"
        print "  };"
        in_function = 1
        next
    }
    in_function && /^  };$/ {
        in_function = 0
        next
    }
    in_function { next }
    { print }
    ' src/pages/admin/Audiencias.js > src/pages/admin/Audiencias_temp.js
    
    mv src/pages/admin/Audiencias_temp.js src/pages/admin/Audiencias.js
    echo "✅ Correção manual aplicada"
fi

echo "4️⃣ Corrigindo também a função isToday..."

# Corrigir função isToday para usar o mesmo padrão
sed -i.tmp2 '
/const isToday = (dateString) => {/,/};/{
  c\
  const isToday = (dateString) => {\
    if (!dateString) return false;\
    try {\
      // Extrair apenas a data se vier no formato ISO\
      let cleanDate = dateString;\
      if (typeof dateString === "string" && dateString.includes("T")) {\
        cleanDate = dateString.split("T")[0];\
      }\
      \
      const hoje = new Date().toISOString().split("T")[0];\
      return cleanDate === hoje;\
    } catch (e) {\
      return false;\
    }\
  };
}
' src/pages/admin/Audiencias.js

rm -f src/pages/admin/Audiencias.js.tmp2

echo "5️⃣ Verificando sintaxe do arquivo..."

if node -c src/pages/admin/Audiencias.js 2>/dev/null; then
    echo "✅ Sintaxe correta"
else
    echo "❌ Erro de sintaxe, restaurando backup..."
    cp "src/pages/admin/Audiencias.js.bak.140" "src/pages/admin/Audiencias.js"
    exit 1
fi

echo "6️⃣ Limpando arquivos temporários..."

rm -f src/pages/admin/Audiencias.js.bak

echo ""
echo "✅ Script 140 concluído!"
echo ""
echo "🔧 CORREÇÕES REALIZADAS:"
echo "   ✅ Função formatDate() corrigida para lidar com formato ISO"
echo "   ✅ Função isToday() também corrigida"
echo "   ✅ Tratamento de erro adicionado"
echo "   ✅ Conversão adequada para pt-BR"
echo ""
echo "📋 FUNCIONAMENTO:"
echo "   • Data ISO: '2025-09-15T09:00:00Z' → '15/09/2025'"
echo "   • Data simples: '2025-09-15' → '15/09/2025'"
echo "   • Data inválida: 'null/undefined' → 'N/A'"
echo ""
echo "📋 TESTE:"
echo "   1. Recarregue a página /admin/audiencias"
echo "   2. A data deve aparecer como '15/09/2025'"
echo "   3. Verificar se badge 'Hoje' aparece corretamente"
echo ""
echo "💡 Se ainda houver problema:"
echo "   console.log das audiências para ver formato exato da data"