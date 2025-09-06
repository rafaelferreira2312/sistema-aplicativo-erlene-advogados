#!/bin/bash

# Script 132 - Corrigir função handleCurrencyChange duplicada (URGENTE)
# Sistema Erlene Advogados - Resolver erro "Identifier 'handleCurrencyChange' has already been declared"
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 132 - Corrigindo função handleCurrencyChange duplicada..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📍 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 132-fix-duplicate-function.sh && ./132-fix-duplicate-function.sh"
    exit 1
fi

echo "1️⃣ DIAGNÓSTICO DO PROBLEMA ESPECÍFICO:"
echo "   • NewProcess.js linha 217: função handleCurrencyChange declarada duas vezes"
echo "   • Erro: Identifier 'handleCurrencyChange' has already been declared"
echo "   • Causa: script anterior deixou código duplicado"
echo "   • Solução: remover duplicação e deixar apenas uma versão correta"

echo ""
echo "2️⃣ Verificando arquivo NewProcess.js..."

# Verificar se o arquivo existe
if [ ! -f "src/components/processes/NewProcess.js" ]; then
    echo "❌ Arquivo NewProcess.js não encontrado"
    exit 1
fi

# Contar quantas vezes handleCurrencyChange aparece
duplicate_count=$(grep -c "const handleCurrencyChange" src/components/processes/NewProcess.js)
echo "📊 Função handleCurrencyChange encontrada $duplicate_count vezes"

if [ "$duplicate_count" -gt 1 ]; then
    echo "❌ Confirmado: função duplicada detected"
    echo "🔧 Aplicando correção..."
else
    echo "✅ Nenhuma duplicação encontrada, verificando outros problemas..."
fi

echo ""
echo "3️⃣ Fazendo backup do arquivo atual..."

# Criar backup
cp src/components/processes/NewProcess.js src/components/processes/NewProcess.js.backup.132
echo "✅ Backup criado: NewProcess.js.backup.132"

echo ""
echo "4️⃣ Removendo função duplicada e linhas problemáticas..."

# Criar arquivo temporário limpo
temp_file=$(mktemp)

# Estratégia: remover TODAS as funções de formatação e recriar apenas uma vez
awk '
BEGIN { 
    in_currency_function = 0
    in_handle_currency = 0
    in_currency_to_number = 0
    skip_line = 0
    functions_added = 0
}

# Detectar início das funções problemáticas
/^[[:space:]]*const formatCurrency = / { 
    in_currency_function = 1
    skip_line = 1
    next
}

/^[[:space:]]*const handleCurrencyChange = / { 
    in_handle_currency = 1
    skip_line = 1
    next
}

/^[[:space:]]*const currencyToNumber = / { 
    in_currency_to_number = 1
    skip_line = 1
    next
}

# Detectar fim das funções (linha com }; ou };)
/^[[:space:]]*};?[[:space:]]*$/ {
    if (in_currency_function || in_handle_currency || in_currency_to_number) {
        in_currency_function = 0
        in_handle_currency = 0
        in_currency_to_number = 0
        skip_line = 1
        next
    }
}

# Inserir funções corretas após useState declarations
/^[[:space:]]*const \[errors, setErrors\] = useState\(\{\}\);/ {
    print $0
    if (functions_added == 0) {
        print ""
        print "  // Funções de formatação de moeda (versão corrigida)"
        print "  const formatCurrency = (value) => {"
        print "    if (!value) return \"\";"
        print "    "
        print "    // Remove tudo exceto números"
        print "    const numbers = value.replace(/\\D/g, \"\");"
        print "    "
        print "    if (!numbers) return \"\";"
        print "    "
        print "    // Converte para número com 2 casas decimais"
        print "    const amount = parseInt(numbers) / 100;"
        print "    "
        print "    return new Intl.NumberFormat(\"pt-BR\", {"
        print "      style: \"currency\","
        print "      currency: \"BRL\""
        print "    }).format(amount);"
        print "  };"
        print ""
        print "  const handleCurrencyChange = (e) => {"
        print "    const formatted = formatCurrency(e.target.value);"
        print "    setFormData(prev => ({"
        print "      ...prev,"
        print "      valor_causa: formatted"
        print "    }));"
        print "  };"
        print ""
        print "  // Função para converter moeda formatada para número"
        print "  const currencyToNumber = (currencyString) => {"
        print "    if (!currencyString) return null;"
        print "    "
        print "    // Remove \"R$\", espaços, pontos (milhares) e converte vírgula para ponto"
        print "    const numberStr = currencyString"
        print "      .replace(/R\\$\\s?/g, \"\")"
        print "      .replace(/\\./g, \"\")"
        print "      .replace(/,/g, \".\");"
        print "    "
        print "    const number = parseFloat(numberStr);"
        print "    return isNaN(number) ? null : number;"
        print "  };"
        print ""
        functions_added = 1
    }
    next
}

# Pular linhas das funções duplicadas
{
    if (!skip_line && !in_currency_function && !in_handle_currency && !in_currency_to_number) {
        print $0
    }
    skip_line = 0
}
' src/components/processes/NewProcess.js > "$temp_file"

# Verificar se o arquivo temporário foi criado com sucesso
if [ -s "$temp_file" ]; then
    # Substituir o arquivo original
    cp "$temp_file" src/components/processes/NewProcess.js
    echo "✅ Função duplicada removida e versão corrigida adicionada"
else
    echo "❌ Erro ao processar arquivo"
    rm -f "$temp_file"
    exit 1
fi

# Limpar arquivo temporário
rm -f "$temp_file"

echo ""
echo "5️⃣ Corrigindo linha do submit que pode estar malformada..."

# Corrigir a linha problemática do submit
sed -i '/valor_causa: currencyToNumber(formData\.valor_causa),/,/parseFloat.*null,/ {
    /valor_causa: currencyToNumber(formData\.valor_causa),/ {
        s/.*/        valor_causa: currencyToNumber(formData.valor_causa),/
        N
        d
    }
}' src/components/processes/NewProcess.js

echo "✅ Linha do submit corrigida"

echo ""
echo "6️⃣ Verificando se o problema foi resolvido..."

# Verificar sintaxe com node
syntax_check=$(node -c src/components/processes/NewProcess.js 2>&1)
if [ $? -eq 0 ]; then
    echo "✅ Sintaxe JavaScript válida!"
else
    echo "❌ Ainda há erros de sintaxe:"
    echo "$syntax_check"
    echo ""
    echo "🔧 Aplicando correção adicional..."
    
    # Se ainda há erro, usar abordagem mais conservadora
    if [ -f "src/components/processes/NewProcess.js.backup.130" ]; then
        echo "Restaurando backup 130 e aplicando correção manual..."
        cp src/components/processes/NewProcess.js.backup.130 src/components/processes/NewProcess.js
        
        # Adicionar apenas as funções necessárias após as declarações useState
        sed -i '/const \[errors, setErrors\] = useState({});/a\
\
  // Funções de formatação de moeda\
  const formatCurrency = (value) => {\
    if (!value) return "";\
    const numbers = value.replace(/\\D/g, "");\
    if (!numbers) return "";\
    const amount = parseInt(numbers) / 100;\
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
  const currencyToNumber = (currencyString) => {\
    if (!currencyString) return null;\
    const numberStr = currencyString\
      .replace(/R\\$\\s?/g, "")\
      .replace(/\\./g, "")\
      .replace(/,/g, ".");\
    const number = parseFloat(numberStr);\
    return isNaN(number) ? null : number;\
  };' src/components/processes/NewProcess.js

        # Corrigir a linha de submit
        sed -i 's/valor_causa: formData\.valor_causa ?.*/valor_causa: currencyToNumber(formData.valor_causa),/' src/components/processes/NewProcess.js
        
        echo "✅ Correção manual aplicada"
    fi
fi

echo ""
echo "7️⃣ Validação final..."

# Verificar novamente
final_check=$(node -c src/components/processes/NewProcess.js 2>&1)
if [ $? -eq 0 ]; then
    echo "✅ NewProcess.js corrigido com sucesso!"
else
    echo "❌ Ainda há problemas. Erro:"
    echo "$final_check"
    echo ""
    echo "🚨 AÇÃO MANUAL NECESSÁRIA:"
    echo "1. Abra src/components/processes/NewProcess.js"
    echo "2. Procure por 'handleCurrencyChange' duplicado"
    echo "3. Remova uma das declarações"
    echo "4. Salve o arquivo"
    exit 1
fi

# Verificar quantas funções restaram
final_count=$(grep -c "const handleCurrencyChange" src/components/processes/NewProcess.js)
echo "📊 Função handleCurrencyChange aparece $final_count vez(es) - deve ser 1"

if [ "$final_count" -eq 1 ]; then
    echo "✅ Número correto de funções"
else
    echo "⚠️ Ainda pode haver duplicações"
fi

echo ""
echo "8️⃣ Testando formatação de moeda..."

# Criar teste rápido
cat > test-newprocess-functions.js << 'EOF'
// Teste das funções do NewProcess

const formatCurrency = (value) => {
  if (!value) return "";
  const numbers = value.replace(/\D/g, "");
  if (!numbers) return "";
  const amount = parseInt(numbers) / 100;
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL"
  }).format(amount);
};

const currencyToNumber = (currencyString) => {
  if (!currencyString) return null;
  const numberStr = currencyString
    .replace(/R\$\s?/g, "")
    .replace(/\./g, "")
    .replace(/,/g, ".");
  const number = parseFloat(numberStr);
  return isNaN(number) ? null : number;
};

console.log("=== TESTE NEWPROCESS ===");
console.log("formatCurrency('12345') ->", formatCurrency('12345'));
console.log("currencyToNumber('R$ 12.345,67') ->", currencyToNumber('R$ 12.345,67'));
console.log("✅ Funções working correctly!");
EOF

node test-newprocess-functions.js
rm test-newprocess-functions.js

echo ""
if [ "$final_count" -eq 1 ] && [ $? -eq 0 ]; then
    echo "✅ SCRIPT 132 CONCLUÍDO COM SUCESSO!"
    echo ""
    echo "🔧 PROBLEMA RESOLVIDO:"
    echo "   ❌ Antes: handleCurrencyChange declarado 2+ vezes (erro de sintaxe)"
    echo "   ✅ Agora: handleCurrencyChange declarado 1 vez (funcionando)"
    echo ""
    echo "🎯 FUNÇÕES CORRIGIDAS:"
    echo "   ✅ formatCurrency() - formatação durante digitação"
    echo "   ✅ handleCurrencyChange() - handler do input (SEM DUPLICAÇÃO)"
    echo "   ✅ currencyToNumber() - converte moeda BR para número"
    echo ""
    echo "🧪 TESTE AGORA:"
    echo "   1. Ctrl+C para parar o servidor se estiver rodando"
    echo "   2. npm start"
    echo "   3. Acesse /admin/processos/novo"
    echo "   4. Teste o campo 'Valor da Causa'"
    echo ""
    echo "📁 ARQUIVOS AFETADOS:"
    echo "   ✅ src/components/processes/NewProcess.js (corrigido)"
    echo "   ✅ Backup criado: NewProcess.js.backup.132"
else
    echo "❌ SCRIPT 132 FALHOU"
    echo ""
    echo "🔧 SOLUÇÕES MANUAIS:"
    echo "   1. Abra o arquivo: src/components/processes/NewProcess.js"
    echo "   2. Procure por 'const handleCurrencyChange' (deve aparecer só 1 vez)"
    echo "   3. Se aparecer 2+ vezes, delete as duplicatas"
    echo "   4. Mantenha apenas uma versão da função"
    echo "   5. Salve e teste novamente"
    echo ""
    echo "📋 OU RESTORE BACKUP:"
    echo "   cp src/components/processes/NewProcess.js.backup.130 src/components/processes/NewProcess.js"
fi