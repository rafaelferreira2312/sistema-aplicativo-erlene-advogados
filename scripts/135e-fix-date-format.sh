#!/bin/bash

# Script 135e - Corrigir Formato de Data na Lista de Audiências
# Sistema Erlene Advogados - Ajustar formatação de data
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "📅 Script 135e - Corrigindo formato de data..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📝 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 135e-fix-date-format.sh && ./135e-fix-date-format.sh"
    exit 1
fi

echo "1️⃣ Fazendo backup do arquivo atual..."

if [ -f "src/pages/admin/Audiencias.js" ]; then
    cp "src/pages/admin/Audiencias.js" "src/pages/admin/Audiencias.js.bak.135e"
fi

echo "2️⃣ Corrigindo formato de data na função carregarDados..."

# Usar sed para corrigir apenas a linha que formata a data
sed -i.bak '
/const audienciasFormatadas = resultadoLista.audiencias.map/,/});/ {
    s/data: audiencia\.data,/data: audiencia.data.split("T")[0], \/\/ Extrair apenas YYYY-MM-DD/
}
' src/pages/admin/Audiencias.js

echo "3️⃣ Verificando se a correção foi aplicada..."

if grep -q "data.split" src/pages/admin/Audiencias.js; then
    echo "✅ Correção aplicada com sucesso!"
else
    echo "⚠️ Correção via sed falhou, aplicando manualmente..."
    
    # Método manual - recriar apenas a parte que precisa
    # Buscar linha e substituir
    sed -i 's/data: audiencia\.data,/data: audiencia.data.split("T")[0],/' src/pages/admin/Audiencias.js
    
    if grep -q "split.*T.*0" src/pages/admin/Audiencias.js; then
        echo "✅ Correção manual aplicada!"
    else
        echo "❌ Correção falhou, aplicando patch completo..."
        
        # Método de backup - substituir a função inteira
        cat > temp_patch.js << 'EOF'
        // Converter dados da API para formato do frontend
        const audienciasFormatadas = resultadoLista.audiencias.map(audiencia => ({
          id: audiencia.id,
          processo: audiencia.processo?.numero || `Processo #${audiencia.processo_id}`,
          cliente: audiencia.cliente?.nome || `Cliente #${audiencia.cliente_id}`,
          tipo: formatarTipo(audiencia.tipo),
          data: audiencia.data.split('T')[0], // Extrair apenas YYYY-MM-DD
          hora: audiencia.hora,
          local: audiencia.local,
          endereco: audiencia.endereco || '',
          sala: audiencia.sala || '',
          status: formatarStatus(audiencia.status),
          advogado: audiencia.advogado,
          juiz: audiencia.juiz || '',
          observacoes: audiencia.observacoes || '',
          createdAt: audiencia.created_at
        }));
EOF
        
        # Substituir na linha específica
        awk '
        /const audienciasFormatadas = resultadoLista.audiencias.map/ {
            print "        // Converter dados da API para formato do frontend"
            print "        const audienciasFormatadas = resultadoLista.audiencias.map(audiencia => ({"
            print "          id: audiencia.id,"
            print "          processo: audiencia.processo?.numero || `Processo #${audiencia.processo_id}`,"
            print "          cliente: audiencia.cliente?.nome || `Cliente #${audiencia.cliente_id}`,"
            print "          tipo: formatarTipo(audiencia.tipo),"
            print "          data: audiencia.data.split(\"T\")[0], // Extrair apenas YYYY-MM-DD"
            print "          hora: audiencia.hora,"
            print "          local: audiencia.local,"
            print "          endereco: audiencia.endereco || \"\","
            print "          sala: audiencia.sala || \"\","
            print "          status: formatarStatus(audiencia.status),"
            print "          advogado: audiencia.advogado,"
            print "          juiz: audiencia.juiz || \"\","
            print "          observacoes: audiencia.observacoes || \"\","
            print "          createdAt: audiencia.created_at"
            print "        }));"
            # Pular as linhas originais até encontrar }));
            while (getline && !/})\);/) continue
            next
        }
        { print }
        ' src/pages/admin/Audiencias.js > src/pages/admin/Audiencias_temp.js
        
        mv src/pages/admin/Audiencias_temp.js src/pages/admin/Audiencias.js
        rm -f temp_patch.js
        
        echo "✅ Patch completo aplicado!"
    fi
fi

echo "4️⃣ Verificando se hora também precisa de formatação..."

# Verificar se hora está vindo em formato estranho também
if grep -q "hora: audiencia.hora," src/pages/admin/Audiencias.js; then
    echo "🕐 Adicionando formatação para hora também..."
    
    sed -i 's/hora: audiencia\.hora,/hora: typeof audiencia.hora === "string" ? audiencia.hora.substring(0, 5) : audiencia.hora,/' src/pages/admin/Audiencias.js
    
    echo "✅ Hora também formatada (remover segundos se existirem)"
fi

echo "5️⃣ Limpando arquivos temporários..."

rm -f src/pages/admin/Audiencias.js.bak

echo "6️⃣ Verificando resultado final..."

echo "Verificando se as correções estão no arquivo:"
grep -n "data.*split" src/pages/admin/Audiencias.js || echo "❌ Não encontrado"
grep -n "hora.*substring" src/pages/admin/Audiencias.js && echo "✅ Hora formatada" || echo "ℹ️ Hora não precisou de correção"

echo ""
echo "✅ Script 135e concluído!"
echo ""
echo "🔧 CORREÇÕES REALIZADAS:"
echo "   ✅ Data formatada de '2025-09-15T09:00:00.000000Z' para '2025-09-15'"
echo "   ✅ Hora formatada para mostrar apenas HH:MM (se necessário)"
echo ""
echo "📋 TESTE:"
echo "   1. Recarregue a página /admin/audiências"
echo "   2. Verifique se a data aparece como 15/09/2025 na tabela"
echo "   3. Confira se a hora aparece como 09:00 (sem segundos)"
echo ""
echo "✨ A integração backend/frontend está completa!"