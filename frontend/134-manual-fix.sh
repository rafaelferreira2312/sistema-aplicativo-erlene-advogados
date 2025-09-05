#!/bin/bash

# Script 134 - Correção manual direta (DEFINITIVA)
# Sistema Erlene Advogados - Remover linhas problemáticas específicas
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 134 - Correção manual direta das linhas problemáticas..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "1️⃣ PROBLEMA IDENTIFICADO:"
echo "   • NewProcess.js linha 153 e 196: parseFloat órfão"
echo "   • EditProcess.js linha 198: parseFloat órfão"  
echo "   • Solução: remover essas linhas específicas"

echo ""
echo "2️⃣ Fazendo backup antes da correção..."

cp src/components/processes/NewProcess.js src/components/processes/NewProcess.js.backup.134
cp src/components/processes/EditProcess.js src/components/processes/EditProcess.js.backup.134

echo "✅ Backups criados"

echo ""
echo "3️⃣ Removendo linhas problemáticas do NewProcess.js..."

# Remover linhas específicas problemáticas do NewProcess.js
sed -i '153d' src/components/processes/NewProcess.js  # Remove linha 153
sed -i '195d' src/components/processes/NewProcess.js  # Remove linha 196 (agora 195)

# Verificar se há mais linhas órfãs
sed -i '/^[[:space:]]*parseFloat.*$/d' src/components/processes/NewProcess.js
sed -i '/^[[:space:]]*null,[[:space:]]*$/d' src/components/processes/NewProcess.js

echo "✅ NewProcess.js - linhas problemáticas removidas"

echo ""
echo "4️⃣ Removendo linhas problemáticas do EditProcess.js..."

# Remover linhas específicas problemáticas do EditProcess.js
sed -i '198d' src/components/processes/EditProcess.js  # Remove linha 198
sed -i '199d' src/components/processes/EditProcess.js  # Remove linha 199 (null,)

# Verificar se há mais linhas órfãs
sed -i '/^[[:space:]]*parseFloat.*$/d' src/components/processes/EditProcess.js
sed -i '/^[[:space:]]*null,[[:space:]]*$/d' src/components/processes/EditProcess.js

echo "✅ EditProcess.js - linhas problemáticas removidas"

echo ""
echo "5️⃣ Verificando se as correções funcionaram..."

# Testar sintaxe NewProcess.js
echo "Testando NewProcess.js..."
if node -c src/components/processes/NewProcess.js 2>/dev/null; then
    echo "✅ NewProcess.js - sintaxe válida"
    newprocess_ok=true
else
    echo "❌ NewProcess.js ainda tem problemas:"
    node -c src/components/processes/NewProcess.js 2>&1 | head -2
    newprocess_ok=false
fi

# Testar sintaxe EditProcess.js
echo "Testando EditProcess.js..."
if node -c src/components/processes/EditProcess.js 2>/dev/null; then
    echo "✅ EditProcess.js - sintaxe válida"
    editprocess_ok=true
else
    echo "❌ EditProcess.js ainda tem problemas:"
    node -c src/components/processes/EditProcess.js 2>&1 | head -2
    editprocess_ok=false
fi

echo ""
echo "6️⃣ Adicionando função currencyToNumber se não existir..."

# Verificar se currencyToNumber existe no NewProcess.js
if ! grep -q "currencyToNumber" src/components/processes/NewProcess.js; then
    echo "Adicionando currencyToNumber ao NewProcess.js..."
    
    # Encontrar local após handleCurrencyChange
    sed -i '/const handleCurrencyChange/a\
\
  const currencyToNumber = (currencyString) => {\
    if (!currencyString) return null;\
    const numberStr = currencyString\
      .replace(/R\\$\\s?/g, "")\
      .replace(/\\./g, "")\
      .replace(/,/g, ".");\
    const number = parseFloat(numberStr);\
    return isNaN(number) ? null : number;\
  };' src/components/processes/NewProcess.js
fi

# Verificar se currencyToNumber existe no EditProcess.js
if ! grep -q "currencyToNumber" src/components/processes/EditProcess.js; then
    echo "Adicionando currencyToNumber ao EditProcess.js..."
    
    sed -i '/const handleCurrencyChange/a\
\
  const currencyToNumber = (currencyString) => {\
    if (!currencyString) return null;\
    const numberStr = currencyString\
      .replace(/R\\$\\s?/g, "")\
      .replace(/\\./g, "")\
      .replace(/,/g, ".");\
    const number = parseFloat(numberStr);\
    return isNaN(number) ? null : number;\
  };\
\
  const formatBrazilianCurrency = (value) => {\
    if (!value || value === 0) return "";\
    const number = parseFloat(value);\
    if (isNaN(number)) return "";\
    return new Intl.NumberFormat("pt-BR", {\
      style: "currency",\
      currency: "BRL"\
    }).format(number);\
  };' src/components/processes/EditProcess.js
fi

echo ""
echo "7️⃣ Verificação final..."

# Teste final
echo "Teste final de sintaxe..."
if node -c src/components/processes/NewProcess.js 2>/dev/null && node -c src/components/processes/EditProcess.js 2>/dev/null; then
    echo "✅ Ambos arquivos têm sintaxe válida!"
    
    echo ""
    echo "🎉 SCRIPT 134 CONCLUÍDO COM SUCESSO!"
    echo ""
    echo "✅ PROBLEMAS RESOLVIDOS:"
    echo "   • NewProcess.js: linhas órfãs removidas"
    echo "   • EditProcess.js: linhas órfãs removidas"
    echo "   • Sintaxe JavaScript válida"
    echo "   • Funções de formatação de moeda implementadas"
    echo ""
    echo "🧪 TESTE AGORA:"
    echo "   1. npm start (deve compilar sem erros)"
    echo "   2. Acesse /admin/processos/novo"
    echo "   3. Teste o campo valor da causa"
    echo ""
    echo "📁 BACKUPS DISPONÍVEIS:"
    echo "   • NewProcess.js.backup.134"
    echo "   • EditProcess.js.backup.134"
    
else
    echo "❌ Ainda há problemas de sintaxe"
    echo ""
    echo "🔧 SOLUÇÃO MANUAL NECESSÁRIA:"
    echo "Abra os arquivos e procure por:"
    echo "   • Linhas com apenas 'parseFloat('"
    echo "   • Linhas com apenas 'null,'"
    echo "   • Chaves { } não balanceadas"
    echo ""
    echo "📄 OU RESTAURE OS BACKUPS ORIGINAIS:"
    echo "   cp src/components/processes/NewProcess.js.backup.130 src/components/processes/NewProcess.js"
    echo "   cp src/components/processes/EditProcess.js.backup.130 src/components/processes/EditProcess.js"
fi

echo ""
echo "🔍 STATUS DOS ARQUIVOS:"
echo "NewProcess.js: $(wc -l < src/components/processes/NewProcess.js) linhas"
echo "EditProcess.js: $(wc -l < src/components/processes/EditProcess.js) linhas"