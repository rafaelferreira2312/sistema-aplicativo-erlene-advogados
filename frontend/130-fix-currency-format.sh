#!/bin/bash

# Script 130 - Corrigir formatação de moeda nos formulários
# Sistema Erlene Advogados - Corrigir conversão de R$ 12.821,20 para 12.82
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 130 - Corrigindo formatação de moeda nos formulários..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 130-fix-currency-format.sh && ./130-fix-currency-format.sh"
    exit 1
fi

echo "1️⃣ DIAGNÓSTICO DO PROBLEMA:"
echo "   • R$ 12.821,20 está sendo enviado como 12.82 ❌"
echo "   • R$ 25.000,00 está sendo enviado como 25.00 ❌"
echo "   • Problema: formatação brasileira não está sendo convertida corretamente"
echo "   • Solução: corrigir função de conversão moeda → número"

echo ""
echo "2️⃣ Analisando problema na formatação..."

# Encontrar arquivos que usam formatação de moeda
echo "Arquivos que usam formatação de moeda:"
find src -name "*.js" -exec grep -l "formatCurrency\|handleCurrencyChange\|valor_causa" {} \;

echo ""
echo "3️⃣ Corrigindo NewProcess.js..."

# Backup do NewProcess.js
cp src/components/processes/NewProcess.js src/components/processes/NewProcess.js.backup.130

# Corrigir função de formatação no NewProcess.js
sed -i '/const formatCurrency = (value) => {/,/};/c\
  const formatCurrency = (value) => {\
    if (!value) return "";\
    \
    // Remove tudo exceto números\
    const numbers = value.replace(/\D/g, "");\
    \
    if (!numbers) return "";\
    \
    // Converte para número com 2 casas decimais\
    const amount = parseInt(numbers) / 100;\
    \
    return new Intl.NumberFormat("pt-BR", {\
      style: "currency",\
      currency: "BRL"\
    }).format(amount);\
  };\
\
  const handleCurrencyChange = (e) => {\
    const formatted = formatCurrency(e.target.value);\
    setFormData(prev => ({\
      ...prev,\
      valor_causa: formatted\
    }));\
  };\
\
  // Função para converter moeda formatada para número\
  const currencyToNumber = (currencyString) => {\
    if (!currencyString) return null;\
    \
    // Remove "R$", espaços, pontos (milhares) e converte vírgula para ponto\
    const numberStr = currencyString\
      .replace(/R\$\s?/g, "")\
      .replace(/\./g, "")\
      .replace(/,/g, ".");\
    \
    const number = parseFloat(numberStr);\
    return isNaN(number) ? null : number;\
  };' src/components/processes/NewProcess.js

# Corrigir parte do submit no NewProcess.js
sed -i '/valor_causa: formData.valor_causa ?/,/null,/c\
        valor_causa: currencyToNumber(formData.valor_causa),' src/components/processes/NewProcess.js

echo "4️⃣ Corrigindo EditProcess.js..."

# Backup do EditProcess.js
cp src/components/processes/EditProcess.js src/components/processes/EditProcess.js.backup.130

# Corrigir função de formatação no EditProcess.js
sed -i '/const formatCurrency = (value) => {/,/};/c\
  const formatCurrency = (value) => {\
    if (!value) return "";\
    \
    // Remove tudo exceto números\
    const numbers = value.replace(/\D/g, "");\
    \
    if (!numbers) return "";\
    \
    // Converte para número com 2 casas decimais\
    const amount = parseInt(numbers) / 100;\
    \
    return new Intl.NumberFormat("pt-BR", {\
      style: "currency",\
      currency: "BRL"\
    }).format(amount);\
  };\
\
  const handleCurrencyChange = (e) => {\
    const formatted = formatCurrency(e.target.value);\
    setFormData(prev => ({\
      ...prev,\
      valor_causa: formatted\
    }));\
  };\
\
  // Função para converter moeda formatada para número\
  const currencyToNumber = (currencyString) => {\
    if (!currencyString) return null;\
    \
    // Remove "R$", espaços, pontos (milhares) e converte vírgula para ponto\
    const numberStr = currencyString\
      .replace(/R\$\s?/g, "")\
      .replace(/\./g, "")\
      .replace(/,/g, ".");\
    \
    const number = parseFloat(numberStr);\
    return isNaN(number) ? null : number;\
  };' src/components/processes/EditProcess.js

# Corrigir parte do submit no EditProcess.js
sed -i '/valor_causa: formData.valor_causa ?/,/null,/c\
        valor_causa: currencyToNumber(formData.valor_causa),' src/components/processes/EditProcess.js

# Corrigir carregamento inicial de dados no EditProcess.js
sed -i '/valor_causa: process.valor_causa ? formatCurrency(process.valor_causa.toString()) : "",/c\
            valor_causa: process.valor_causa ? formatBrazilianCurrency(process.valor_causa) : "",' src/components/processes/EditProcess.js

# Adicionar função para formatar valor vindo do backend
sed -i '/const currencyToNumber = (currencyString) => {/i\
  // Função para formatar valor vindo do backend (número) para moeda brasileira\
  const formatBrazilianCurrency = (value) => {\
    if (!value || value === 0) return "";\
    \
    const number = parseFloat(value);\
    if (isNaN(number)) return "";\
    \
    return new Intl.NumberFormat("pt-BR", {\
      style: "currency",\
      currency: "BRL"\
    }).format(number);\
  };\
' src/components/processes/EditProcess.js

echo ""
echo "5️⃣ Criando arquivo de teste para validar formatação..."

cat > test-currency-format.js << 'EOF'
// Teste da formatação de moeda

// Função corrigida
const currencyToNumber = (currencyString) => {
  if (!currencyString) return null;
  
  // Remove "R$", espaços, pontos (milhares) e converte vírgula para ponto
  const numberStr = currencyString
    .replace(/R\$\s?/g, "")
    .replace(/\./g, "")
    .replace(/,/g, ".");
  
  const number = parseFloat(numberStr);
  return isNaN(number) ? null : number;
};

// Testes
console.log("=== TESTES DE FORMATAÇÃO ===");
console.log("R$ 12.821,20 →", currencyToNumber("R$ 12.821,20")); // Deve ser 12821.20
console.log("R$ 25.000,00 →", currencyToNumber("R$ 25.000,00")); // Deve ser 25000.00
console.log("R$ 1.234.567,89 →", currencyToNumber("R$ 1.234.567,89")); // Deve ser 1234567.89
console.log("R$ 100,50 →", currencyToNumber("R$ 100,50")); // Deve ser 100.50
console.log("R$ 0,99 →", currencyToNumber("R$ 0,99")); // Deve ser 0.99

// Função para formatar valor do backend
const formatBrazilianCurrency = (value) => {
  if (!value || value === 0) return "";
  
  const number = parseFloat(value);
  if (isNaN(number)) return "";
  
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL"
  }).format(number);
};

console.log("\n=== TESTES DE FORMATAÇÃO BACKEND ===");
console.log("12823.00 →", formatBrazilianCurrency("12823.00")); // Deve ser R$ 12.823,00
console.log("25000.00 →", formatBrazilianCurrency("25000.00")); // Deve ser R$ 25.000,00
console.log("100.50 →", formatBrazilianCurrency("100.50")); // Deve ser R$ 100,50
EOF

echo "Executando teste de formatação..."
node test-currency-format.js
rm test-currency-format.js

echo ""
echo "6️⃣ Verificando se correções foram aplicadas..."

# Verificar se funções foram corrigidas
if grep -q "currencyToNumber" src/components/processes/NewProcess.js && \
   grep -q "currencyToNumber" src/components/processes/EditProcess.js; then
    echo "✅ Função currencyToNumber adicionada aos dois arquivos"
else
    echo "❌ Erro ao adicionar função currencyToNumber"
    exit 1
fi

if grep -q "formatBrazilianCurrency" src/components/processes/EditProcess.js; then
    echo "✅ Função formatBrazilianCurrency adicionada ao EditProcess"
else
    echo "❌ Erro ao adicionar função formatBrazilianCurrency"
    exit 1
fi

echo ""
echo "✅ SCRIPT 130 CONCLUÍDO COM SUCESSO!"
echo ""
echo "🔧 PROBLEMAS CORRIGIDOS:"
echo "   ❌ Problema anterior: R$ 12.821,20 → 12.82 (ERRADO)"
echo "   ✅ Correção atual: R$ 12.821,20 → 12821.20 (CORRETO)"
echo ""
echo "   ❌ Problema anterior: R$ 25.000,00 → 25.00 (ERRADO)"
echo "   ✅ Correção atual: R$ 25.000,00 → 25000.00 (CORRETO)"
echo ""
echo "🔧 FUNÇÕES IMPLEMENTADAS:"
echo "   ✅ currencyToNumber() - converte moeda BR para número"
echo "   ✅ formatBrazilianCurrency() - formata número do backend"
echo "   ✅ formatCurrency() - formatação durante digitação"
echo "   ✅ handleCurrencyChange() - handler do input"
echo ""
echo "📋 ARQUIVOS CORRIGIDOS:"
echo "   ✅ src/components/processes/NewProcess.js"
echo "   ✅ src/components/processes/EditProcess.js"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. Reinicie o servidor React (Ctrl+C e npm start)"
echo "   2. Teste digitar: R$ 12.821,20"
echo "   3. Verifique se salva como 12821.20 no banco"
echo "   4. Teste editar um processo existente"
echo "   5. Verifique se o valor aparece formatado corretamente"
echo ""
echo "💡 EXPLICAÇÃO DO PROBLEMA:"
echo "   • O problema estava na conversão de string BR para número"
echo "   • R$ 12.821,20 tem ponto como separador de milhares"
echo "   • E vírgula como separador decimal"
echo "   • A função anterior não tratava isso corretamente"
echo "   • Agora remove pontos (milhares) e converte vírgula em ponto"