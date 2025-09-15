#!/bin/bash

# Script 141 - Corrigir função duplicada formatDate
# Sistema Erlene Advogados - Remover duplicação e corrigir formatação
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 141 - Corrigindo função duplicada formatDate..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "1️⃣ Restaurando backup anterior..."

# Restaurar backup antes do erro
if [ -f "src/pages/admin/Audiencias.js.bak.140" ]; then
    cp "src/pages/admin/Audiencias.js.bak.140" "src/pages/admin/Audiencias.js"
    echo "✅ Backup restaurado"
else
    echo "❌ Backup não encontrado"
    exit 1
fi

echo "2️⃣ Localizando e substituindo função formatDate existente..."

# Criar arquivo temporário com a correção
cat > temp_fix_formatdate.js << 'EOF'
  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    try {
      // Se vier no formato ISO, extrair apenas a data
      let cleanDate = dateString;
      if (typeof dateString === 'string' && dateString.includes('T')) {
        cleanDate = dateString.split('T')[0];
      }
      
      // Converter para Date e formatar
      const date = new Date(cleanDate + 'T00:00:00.000Z');
      return date.toLocaleDateString('pt-BR');
    } catch (e) {
      console.error('Erro ao formatar data:', dateString, e);
      return 'Data inválida';
    }
  };
EOF

# Substituir a função formatDate existente
awk '
BEGIN { in_formatdate = 0; skip_lines = 0 }

# Detectar início da função formatDate
/const formatDate = \(dateString\) => \{/ {
    # Inserir nova função
    while ((getline line < "temp_fix_formatdate.js") > 0) {
        print line
    }
    close("temp_fix_formatdate.js")
    in_formatdate = 1
    skip_lines = 1
    next
}

# Detectar fim da função formatDate
in_formatdate && /^  \};$/ {
    in_formatdate = 0
    skip_lines = 0
    next
}

# Pular linhas da função antiga
skip_lines { next }

# Imprimir outras linhas normalmente
{ print }
' src/pages/admin/Audiencias.js > src/pages/admin/Audiencias_fixed.js

# Substituir arquivo original
mv src/pages/admin/Audiencias_fixed.js src/pages/admin/Audiencias.js

echo "3️⃣ Corrigindo também função isToday..."

# Substituir função isToday da mesma forma
cat > temp_fix_istoday.js << 'EOF'
  const isToday = (dateString) => {
    if (!dateString) return false;
    try {
      // Extrair apenas a data se vier no formato ISO
      let cleanDate = dateString;
      if (typeof dateString === 'string' && dateString.includes('T')) {
        cleanDate = dateString.split('T')[0];
      }
      
      const hoje = new Date().toISOString().split('T')[0];
      return cleanDate === hoje;
    } catch (e) {
      return false;
    }
  };
EOF

awk '
BEGIN { in_istoday = 0; skip_lines = 0 }

# Detectar início da função isToday
/const isToday = \(dateString\) => \{/ {
    # Inserir nova função
    while ((getline line < "temp_fix_istoday.js") > 0) {
        print line
    }
    close("temp_fix_istoday.js")
    in_istoday = 1
    skip_lines = 1
    next
}

# Detectar fim da função isToday
in_istoday && /^  \};$/ {
    in_istoday = 0
    skip_lines = 0
    next
}

# Pular linhas da função antiga
skip_lines { next }

# Imprimir outras linhas normalmente
{ print }
' src/pages/admin/Audiencias.js > src/pages/admin/Audiencias_fixed2.js

mv src/pages/admin/Audiencias_fixed2.js src/pages/admin/Audiencias.js

echo "4️⃣ Limpando arquivos temporários..."

rm -f temp_fix_formatdate.js temp_fix_istoday.js

echo "5️⃣ Verificando sintaxe..."

if node -c src/pages/admin/Audiencias.js 2>/dev/null; then
    echo "✅ Sintaxe correta"
else
    echo "❌ Ainda há erro de sintaxe"
    node -c src/pages/admin/Audiencias.js
    echo "Restaurando backup..."
    cp "src/pages/admin/Audiencias.js.bak.140" "src/pages/admin/Audiencias.js"
    exit 1
fi

echo "6️⃣ Verificando se não há duplicação..."

formatdate_count=$(grep -c "const formatDate" src/pages/admin/Audiencias.js)
if [ "$formatdate_count" -eq 1 ]; then
    echo "✅ Apenas uma função formatDate encontrada"
else
    echo "❌ Ainda há $formatdate_count funções formatDate"
    exit 1
fi

echo ""
echo "✅ Script 141 concluído!"
echo ""
echo "🔧 CORREÇÕES REALIZADAS:"
echo "   ✅ Função formatDate duplicada removida"
echo "   ✅ Função formatDate corrigida para formato ISO"
echo "   ✅ Função isToday também corrigida"
echo "   ✅ Sintaxe validada"
echo ""
echo "📋 TESTE:"
echo "   1. A página deve carregar sem erro de sintaxe"
echo "   2. Data deve aparecer como '15/09/2025'"
echo "   3. Badge 'Hoje' deve funcionar corretamente"