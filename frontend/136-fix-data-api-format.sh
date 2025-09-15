#!/bin/bash

# Script 136 - Corrigir formato de data da API backend
# Sistema Erlene Advogados - Converter formato ISO para formato esperado
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "🔧 Script 136 - Corrigindo formato de data da API backend..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📝 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 136-fix-data-api-format.sh && ./136-fix-data-api-format.sh"
    exit 1
fi

echo "1️⃣ Fazendo backup do componente atual..."

# Fazer backup do Audiencias.js atual
if [ -f "src/pages/admin/Audiencias.js" ]; then
    cp "src/pages/admin/Audiencias.js" "src/pages/admin/Audiencias.js.bak.136"
    echo "✅ Backup criado: Audiencias.js.bak.136"
fi

echo "2️⃣ Corrigindo formatação de dados da API..."

# Atualizar apenas a parte de formatação dos dados da API
cat > temp_audiencias_fix.js << 'EOF'
  const carregarDados = async () => {
    setLoading(true);
    
    try {
      console.log('📄 Carregando dados das audiências...');
      
      // Carregar estatísticas
      const resultadoStats = await audienciasService.obterEstatisticas();
      if (resultadoStats.success) {
        setStats(prevStats => prevStats.map(stat => {
          switch (stat.name) {
            case 'Audiências Hoje':
              return { ...stat, value: resultadoStats.stats.hoje.toString() };
            case 'Próximas 2h':
              return { ...stat, value: resultadoStats.stats.proximas_2h.toString() };
            case 'Em Andamento':
              return { ...stat, value: resultadoStats.stats.em_andamento.toString() };
            case 'Total do Mês':
              return { ...stat, value: resultadoStats.stats.total_mes.toString() };
            default:
              return stat;
          }
        }));
        console.log('📊 Estatísticas carregadas:', resultadoStats.stats);
      }

      // Carregar lista de audiências
      const resultadoLista = await audienciasService.listarAudiencias();
      if (resultadoLista.success) {
        // Converter dados da API para formato do frontend
        const audienciasFormatadas = resultadoLista.audiencias.map(audiencia => {
          // Extrair apenas a data (YYYY-MM-DD) do formato ISO completo
          let dataFormatada = audiencia.data;
          if (typeof dataFormatada === 'string' && dataFormatada.includes('T')) {
            dataFormatada = dataFormatada.split('T')[0];
          }
          
          // Extrair apenas HH:MM da hora se vier com segundos
          let horaFormatada = audiencia.hora;
          if (typeof horaFormatada === 'string' && horaFormatada.length > 5) {
            horaFormatada = horaFormatada.substring(0, 5);
          }
          
          return {
            id: audiencia.id,
            processo: audiencia.processo?.numero || `Processo #${audiencia.processo_id}`,
            cliente: audiencia.cliente?.nome || `Cliente #${audiencia.cliente_id}`,
            tipo: formatarTipo(audiencia.tipo),
            data: dataFormatada,
            hora: horaFormatada,
            local: audiencia.local,
            endereco: audiencia.endereco || '',
            sala: audiencia.sala || '',
            status: formatarStatus(audiencia.status),
            advogado: audiencia.advogado,
            juiz: audiencia.juiz || '',
            observacoes: audiencia.observacoes || '',
            createdAt: audiencia.created_at
          };
        });
        
        setAudiencias(audienciasFormatadas);
        console.log('📋 Audiências carregadas:', audienciasFormatadas);
      } else {
        console.error('Erro ao carregar audiências:', resultadoLista.error);
      }
      
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
    } finally {
      setLoading(false);
    }
  };
EOF

echo "3️⃣ Aplicando correção no arquivo Audiencias.js..."

# Localizar e substituir a função carregarDados
awk '
BEGIN { in_function = 0; skip_function = 0 }
/const carregarDados = async \(\) => \{/ {
    in_function = 1
    skip_function = 1
    # Inserir função corrigida
    while ((getline line < "temp_audiencias_fix.js") > 0) {
        print line
    }
    close("temp_audiencias_fix.js")
    next
}
in_function && /^  \};$/ {
    in_function = 0
    skip_function = 0
    next
}
skip_function { next }
{ print }
' src/pages/admin/Audiencias.js > src/pages/admin/Audiencias_fixed.js

# Substituir arquivo original
mv src/pages/admin/Audiencias_fixed.js src/pages/admin/Audiencias.js

echo "4️⃣ Removendo arquivo temporário..."
rm -f temp_audiencias_fix.js

echo "5️⃣ Verificando se a correção foi aplicada..."

if grep -q "dataFormatada.split('T')" src/pages/admin/Audiencias.js; then
    echo "✅ Correção aplicada com sucesso!"
else
    echo "⚠️ Correção pode não ter sido aplicada completamente"
    echo "Restaurando backup..."
    if [ -f "src/pages/admin/Audiencias.js.bak.136" ]; then
        cp "src/pages/admin/Audiencias.js.bak.136" "src/pages/admin/Audiencias.js"
        echo "Backup restaurado"
    fi
fi

echo "6️⃣ Limpando arquivos temporários..."
rm -f src/pages/admin/Audiencias.js.bak

echo ""
echo "✅ Script 136 concluído!"
echo ""
echo "🔧 CORREÇÕES REALIZADAS:"
echo "   ✅ Data ISO (2025-09-15T09:00:00.000000Z) → Data simples (2025-09-15)"
echo "   ✅ Hora com segundos (09:00:00) → Hora simples (09:00)"
echo "   ✅ Formatação mantém compatibilidade com dados mockados"
echo ""
echo "📋 TESTE:"
echo "   1. Recarregue a página /admin/audiencias"
echo "   2. Verifique se a data aparece como 15/09/2025 na tabela"
echo "   3. Confirme se não há erros no console do navegador"
echo ""
echo "💡 PRÓXIMO PASSO:"
echo "   Testar integração completa com formulários NewAudiencia e EditAudiencia"