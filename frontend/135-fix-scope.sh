#!/bin/bash

# Script 135 - Corrigir escopo das funções (FINAL)
# Sistema Erlene Advogados - Mover funções para escopo correto
# EXECUTAR DENTRO DA PASTA: frontend/

echo "Script 135 - Corrigindo escopo das funções de formatação..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "1. PROBLEMA IDENTIFICADO:"
echo "   • Funções currencyToNumber e formatBrazilianCurrency estão fora do escopo"
echo "   • Precisam estar dentro do componente React"

echo ""
echo "2. Fazendo backup..."

cp src/components/processes/NewProcess.js src/components/processes/NewProcess.js.backup.135
cp src/components/processes/EditProcess.js src/components/processes/EditProcess.js.backup.135

echo ""
echo "3. Corrigindo NewProcess.js..."

# Remover funções que estão fora do escopo
sed -i '/^[[:space:]]*const currencyToNumber = /,/^[[:space:]]*};$/d' src/components/processes/NewProcess.js

# Adicionar função no local correto (após os useStates)
sed -i '/const \[errors, setErrors\] = useState({});/a\
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

echo "NewProcess.js corrigido"

echo ""
echo "4. Corrigindo EditProcess.js..."

# Remover funções que estão fora do escopo
sed -i '/^[[:space:]]*const currencyToNumber = /,/^[[:space:]]*};$/d' src/components/processes/EditProcess.js
sed -i '/^[[:space:]]*const formatBrazilianCurrency = /,/^[[:space:]]*};$/d' src/components/processes/EditProcess.js

# Adicionar funções no local correto (após os useStates)
sed -i '/const \[errors, setErrors\] = useState({});/a\
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

echo "EditProcess.js corrigido"

echo ""
echo "5. Corrigindo linha de carregamento no EditProcess.js..."

# Corrigir linha que usa formatBrazilianCurrency
sed -i 's/valor_causa: process\.valor_causa ? formatCurrency(process\.valor_causa\.toString()) : "",/valor_causa: process.valor_causa ? formatBrazilianCurrency(process.valor_causa) : "",/' src/components/processes/EditProcess.js

echo ""
echo "6. Verificando sintaxe..."

# Testar sintaxe
if node -c src/components/processes/NewProcess.js 2>/dev/null; then
    echo "✓ NewProcess.js sintaxe válida"
else
    echo "✗ NewProcess.js tem erros:"
    node -c src/components/processes/NewProcess.js
fi

if node -c src/components/processes/EditProcess.js 2>/dev/null; then
    echo "✓ EditProcess.js sintaxe válida"
else
    echo "✗ EditProcess.js tem erros:"
    node -c src/components/processes/EditProcess.js
fi

echo ""
echo "7. Verificando se funções estão no escopo correto..."

# Verificar se as funções estão dentro do componente
if grep -A5 -B5 "currencyToNumber" src/components/processes/NewProcess.js | grep -q "const NewProcess"; then
    echo "✓ NewProcess.js: currencyToNumber no escopo correto"
else
    echo "! NewProcess.js: currencyToNumber pode estar fora do escopo"
fi

if grep -A5 -B5 "formatBrazilianCurrency" src/components/processes/EditProcess.js | grep -q "const EditProcess"; then
    echo "✓ EditProcess.js: formatBrazilianCurrency no escopo correto"
else
    echo "! EditProcess.js: formatBrazilianCurrency pode estar fora do escopo"
fi

echo ""
echo "Script 135 concluído."
echo ""
echo "TESTE AGORA:"
echo "1. npm start"
echo "2. Verifique se compila sem erros"
echo "3. Teste /admin/processos/novo"
echo ""
echo "Se ainda houver erros de escopo, as funções precisam estar DENTRO do componente React."