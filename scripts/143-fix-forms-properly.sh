#!/bin/bash

# Script 143 - Corrigir formulários de forma precisa
# Sistema Erlene Advogados - Integração simples e direta
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 143 - Corrigindo formulários de forma precisa..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "1️⃣ Restaurando backups para estado limpo..."

# Restaurar backups
if [ -f "src/components/audiencias/NewAudiencia.js.bak.142" ]; then
    cp "src/components/audiencias/NewAudiencia.js.bak.142" "src/components/audiencias/NewAudiencia.js"
    echo "✅ NewAudiencia.js restaurado"
fi

if [ -f "src/components/audiencias/EditAudiencia.js.bak.142" ]; then
    cp "src/components/audiencias/EditAudiencia.js.bak.142" "src/components/audiencias/EditAudiencia.js"
    echo "✅ EditAudiencia.js restaurado"
fi

echo "2️⃣ Corrigindo NewAudiencia.js - apenas adicionar import..."

# Verificar se já tem o import
if ! grep -q "import audienciasService" src/components/audiencias/NewAudiencia.js; then
    # Adicionar import após as outras importações
    sed -i '/} from.*@heroicons/a import audienciasService from '\''../../services/audienciasService'\'';' src/components/audiencias/NewAudiencia.js
    echo "✅ Import adicionado ao NewAudiencia.js"
fi

# Substituir apenas a linha do setTimeout por chamada real da API
sed -i 's/await new Promise(resolve => setTimeout(resolve, 1500));/const resultado = await audienciasService.criarAudiencia(audienciasService.formatarDadosParaAPI(formData)); if (!resultado.success) throw new Error(resultado.error);/' src/components/audiencias/NewAudiencia.js

echo "3️⃣ Corrigindo EditAudiencia.js - apenas adicionar import..."

# Verificar se já tem o import
if ! grep -q "import audienciasService" src/components/audiencias/EditAudiencia.js; then
    # Adicionar import após as outras importações
    sed -i '/} from.*@heroicons/a import audienciasService from '\''../../services/audienciasService'\'';' src/components/audiencias/EditAudiencia.js
    echo "✅ Import adicionado ao EditAudiencia.js"
fi

# Substituir carregamento mockado por API real (apenas a linha do setTimeout no useEffect)
sed -i 's/setTimeout(() => {/const resultado = await audienciasService.obterAudiencia(id); if (resultado.success) {/' src/components/audiencias/EditAudiencia.js
sed -i 's/setFormData(mockAudiencia);/setFormData({ tipo: resultado.audiencia.tipo || "", data: resultado.audiencia.data ? resultado.audiencia.data.split("T")[0] : "", hora: resultado.audiencia.hora ? resultado.audiencia.hora.substring(0, 5) : "", local: resultado.audiencia.local || "", sala: resultado.audiencia.sala || "", endereco: resultado.audiencia.endereco || "", advogado: resultado.audiencia.advogado || "", juiz: resultado.audiencia.juiz || "", status: resultado.audiencia.status || "agendada", observacoes: resultado.audiencia.observacoes || "" });/' src/components/audiencias/EditAudiencia.js
sed -i 's/}, 1000);/}/' src/components/audiencias/EditAudiencia.js

# Substituir salvamento mockado por API real (apenas a linha do setTimeout no handleSubmit)
sed -i 's/await new Promise(resolve => setTimeout(resolve, 1500));/const resultado = await audienciasService.atualizarAudiencia(id, audienciasService.formatarDadosParaAPI(formData)); if (!resultado.success) throw new Error(resultado.error);/' src/components/audiencias/EditAudiencia.js

echo "4️⃣ Corrigindo função useEffect para ser async..."

# Transformar useEffect em async
sed -i 's/useEffect(() => {/useEffect(() => { const carregarDados = async () => {/' src/components/audiencias/EditAudiencia.js
sed -i 's/}, \[id\]);/}; carregarDados(); }, [id]);/' src/components/audiencias/EditAudiencia.js

echo "5️⃣ Verificando sintaxe dos arquivos..."

echo "NewAudiencia.js:"
if node -c src/components/audiencias/NewAudiencia.js 2>/dev/null; then
    echo "✅ Sintaxe correta"
else
    echo "❌ Erro de sintaxe"
    node -c src/components/audiencias/NewAudiencia.js
fi

echo ""
echo "EditAudiencia.js:"
if node -c src/components/audiencias/EditAudiencia.js 2>/dev/null; then
    echo "✅ Sintaxe correta"
else
    echo "❌ Erro de sintaxe"
    node -c src/components/audiencias/EditAudiencia.js
fi

echo ""
echo "✅ Script 143 concluído!"
echo ""
echo "🔧 CORREÇÕES SIMPLES REALIZADAS:"
echo "   ✅ Imports do audienciasService adicionados"
echo "   ✅ Simulações substituídas por chamadas reais"
echo "   ✅ Formatação de dados integrada"
echo "   ✅ UseEffect corrigido para async"
echo ""
echo "📋 TESTE:"
echo "   1. Verificar se não há erros de sintaxe"
echo "   2. Testar criação de nova audiência"
echo "   3. Testar edição de audiência existente"
echo ""
echo "💡 ABORDAGEM MAIS SIMPLES:"
echo "   • Mantém estrutura original"
echo "   • Apenas substitui partes mockadas"
echo "   • Menos propenso a erros de sintaxe"