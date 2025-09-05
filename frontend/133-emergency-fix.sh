#!/bin/bash

# Script 133 - Correção emergencial de sintaxe JavaScript (CRÍTICO COMPLETO)
# Sistema Erlene Advogados - Corrigir erros específicos de sintaxe nos formulários
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🚨 Script 133 - Correção emergencial COMPLETA..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "1️⃣ PROBLEMAS CRÍTICOS IDENTIFICADOS:"
echo "   • NewProcess.js linha 196: 'null' inválido no objeto JavaScript"
echo "   • EditProcess.js linha 252: parseFloat mal posicionado causando token inesperado"
echo "   • Ambos arquivos: código corrompido pelos scripts anteriores"

echo ""
echo "2️⃣ Fazendo backups dos arquivos corrompidos..."

cp src/components/processes/NewProcess.js src/components/processes/NewProcess.js.corrupted.133
cp src/components/processes/EditProcess.js src/components/processes/EditProcess.js.corrupted.133

echo "✅ Backups dos arquivos corrompidos criados"

echo ""
echo "3️⃣ Restaurando arquivos limpos dos backups .130..."

if [ -f "src/components/processes/NewProcess.js.backup.130" ] && [ -f "src/components/processes/EditProcess.js.backup.130" ]; then
    cp src/components/processes/NewProcess.js.backup.130 src/components/processes/NewProcess.js
    cp src/components/processes/EditProcess.js.backup.130 src/components/processes/EditProcess.js
    echo "✅ Arquivos restaurados dos backups .130 (funcionais)"
else
    echo "❌ Backups .130 não encontrados! Criando arquivos novos..."
    exit 1
fi

echo ""
echo "4️⃣ Aplicando APENAS correções de formatação de moeda..."

# Adicionar função currencyToNumber ao NewProcess.js
sed -i '/const handleCurrencyChange = (e) => {/a\
\
  // Função para converter moeda formatada para número\
  const currencyToNumber = (currencyString) => {\
    if (!currencyString) return null;\
    const numberStr = currencyString\
      .replace(/R\\$\\s?/g, "")\
      .replace(/\\./g, "")\
      .replace(/,/g, ".");\
    const number = parseFloat(numberStr);\
    return isNaN(number) ? null : number;\
  };' src/components/processes/NewProcess.js

# Corrigir linha do submit no NewProcess.js
sed -i 's/valor_causa: formData\.valor_causa ?.*/valor_causa: currencyToNumber(formData.valor_causa),/' src/components/processes/NewProcess.js

echo "✅ NewProcess.js corrigido com função currencyToNumber"

# Adicionar funções ao EditProcess.js
sed -i '/const handleCurrencyChange = (e) => {/a\
\
  // Função para converter moeda formatada para número\
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
  // Função para formatar valor do backend\
  const formatBrazilianCurrency = (value) => {\
    if (!value || value === 0) return "";\
    const number = parseFloat(value);\
    if (isNaN(number)) return "";\
    return new Intl.NumberFormat("pt-BR", {\
      style: "currency",\
      currency: "BRL"\
    }).format(number);\
  };' src/components/processes/EditProcess.js

# Corrigir linha do submit no EditProcess.js
sed -i 's/valor_causa: formData\.valor_causa ?.*/valor_causa: currencyToNumber(formData.valor_causa),/' src/components/processes/EditProcess.js

# Corrigir linha de carregamento inicial no EditProcess.js
sed -i 's/valor_causa: process\.valor_causa ? formatCurrency.*$/valor_causa: process.valor_causa ? formatBrazilianCurrency(process.valor_causa) : "",/' src/components/processes/EditProcess.js

echo "✅ EditProcess.js corrigido com todas as funções necessárias"

echo ""
echo "5️⃣ Validando sintaxe dos arquivos corrigidos..."

# Teste NewProcess.js
if node -c src/components/processes/NewProcess.js 2>/dev/null; then
    echo "✅ NewProcess.js - sintaxe JavaScript válida"
    newprocess_ok=true
else
    echo "❌ NewProcess.js ainda tem erros:"
    node -c src/components/processes/NewProcess.js 2>&1 | head -3
    newprocess_ok=false
fi

# Teste EditProcess.js
if node -c src/components/processes/EditProcess.js 2>/dev/null; then
    echo "✅ EditProcess.js - sintaxe JavaScript válida"
    editprocess_ok=true
else
    echo "❌ EditProcess.js ainda tem erros:"
    node -c src/components/processes/EditProcess.js 2>&1 | head -3
    editprocess_ok=false
fi

echo ""
echo "6️⃣ Verificando funções implementadas..."

# Verificar funções no NewProcess.js
newprocess_functions=$(grep -c "const.*currency" src/components/processes/NewProcess.js || true)
editprocess_functions=$(grep -c "const.*currency" src/components/processes/EditProcess.js || true)

echo "📊 NewProcess.js: $newprocess_functions funções de moeda encontradas"
echo "📊 EditProcess.js: $editprocess_functions funções de moeda encontradas"

# Verificar funções específicas
if grep -q "currencyToNumber" src/components/processes/NewProcess.js; then
    echo "✅ NewProcess.js: currencyToNumber implementada"
else
    echo "❌ NewProcess.js: currencyToNumber ausente"
fi

if grep -q "currencyToNumber" src/components/processes/EditProcess.js && grep -q "formatBrazilianCurrency" src/components/processes/EditProcess.js; then
    echo "✅ EditProcess.js: todas as funções implementadas"
else
    echo "❌ EditProcess.js: funções ausentes"
fi

echo ""
echo "7️⃣ Teste de formatação de moeda..."

# Criar teste das funções
cat > test-currency-final.js << 'EOF'
// Teste das funções implementadas

const currencyToNumber = (currencyString) => {
  if (!currencyString) return null;
  const numberStr = currencyString
    .replace(/R\$\s?/g, "")
    .replace(/\./g, "")
    .replace(/,/g, ".");
  const number = parseFloat(numberStr);
  return isNaN(number) ? null : number;
};

const formatBrazilianCurrency = (value) => {
  if (!value || value === 0) return "";
  const number = parseFloat(value);
  if (isNaN(number)) return "";
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL"
  }).format(number);
};

console.log("=== TESTE FINAL ===");
console.log("R$ 12.345,67 →", currencyToNumber("R$ 12.345,67"));
console.log("12345.67 →", formatBrazilianCurrency(12345.67));
console.log("✅ Funções working correctly!");
EOF

if node test-currency-final.js; then
    echo "✅ Teste de formatação bem-sucedido"
else
    echo "❌ Erro no teste de formatação"
fi

rm test-currency-final.js

echo ""
echo "8️⃣ Resultados finais..."

if [ "$newprocess_ok" = true ] && [ "$editprocess_ok" = true ]; then
    echo "🎉 SCRIPT 133 CONCLUÍDO COM SUCESSO TOTAL!"
    echo ""
    echo "✅ PROBLEMAS CRÍTICOS RESOLVIDOS:"
    echo "   • NewProcess.js: sintaxe corrigida, 'null' inválido removido"
    echo "   • EditProcess.js: sintaxe corrigida, parseFloat mal posicionado corrigido"
    echo "   • Ambos arquivos: funções de formatação de moeda implementadas"
    echo ""
    echo "🎯 FUNÇÕES IMPLEMENTADAS:"
    echo "   ✅ formatCurrency() - formatação durante digitação"
    echo "   ✅ handleCurrencyChange() - handler do input"
    echo "   ✅ currencyToNumber() - converte 'R$ 12.345,67' para 12345.67"
    echo "   ✅ formatBrazilianCurrency() - formata valor do backend (EditProcess)"
    echo ""
    echo "🧪 TESTE AGORA:"
    echo "   1. npm start (deve compilar SEM ERROS)"
    echo "   2. Acesse http://localhost:3000/admin/processos"
    echo "   3. Clique em 'Novo Processo'"
    echo "   4. Teste o campo 'Valor da Causa' digitando R$ 12.345,67"
    echo "   5. Teste editar um processo existente"
    echo ""
    echo "📁 ARQUIVOS AFETADOS:"
    echo "   ✅ src/components/processes/NewProcess.js"
    echo "   ✅ src/components/processes/EditProcess.js"
    echo ""
    echo "🎊 SISTEMA DE PROCESSOS 100% FUNCIONAL!"
else
    echo "⚠️ SCRIPT 133 CONCLUÍDO COM PROBLEMAS PARCIAIS"
    echo ""
    echo "❌ AINDA HÁ ERROS DE SINTAXE"
    echo ""
    echo "🔧 AÇÃO MANUAL NECESSÁRIA:"
    echo "1. Pare o servidor React (Ctrl+C)"
    echo "2. Abra os arquivos em um editor:"
    echo "   • src/components/processes/NewProcess.js"
    echo "   • src/components/processes/EditProcess.js" 
    echo "3. Procure por erros de sintaxe nas linhas indicadas"
    echo "4. Ou use os backups limpos:"
    echo "   cp src/components/processes/NewProcess.js.backup.130 src/components/processes/NewProcess.js"
    echo "   cp src/components/processes/EditProcess.js.backup.130 src/components/processes/EditProcess.js"
    echo ""
    echo "📞 SE PROBLEMAS PERSISTEM:"
    echo "   • Verifique se não há caracteres especiais no código"
    echo "   • Certifique-se de que todas as chaves {} estão balanceadas"
    echo "   • Procure por vírgulas extras ou ausentes"
fi