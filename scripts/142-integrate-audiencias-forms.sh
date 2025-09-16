#!/bin/bash

# Script 142 - Integrar formulários NewAudiencia e EditAudiencia com API real
# Sistema Erlene Advogados - Conectar formulários com audienciasService
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: frontend/

echo "📝 Script 142 - Integrando formulários de audiências com API real..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "1️⃣ Verificando arquivos dos formulários..."

# Verificar se formulários existem
if [ ! -f "src/components/audiencias/NewAudiencia.js" ]; then
    echo "❌ NewAudiencia.js não encontrado"
    exit 1
fi

if [ ! -f "src/components/audiencias/EditAudiencia.js" ]; then
    echo "❌ EditAudiencia.js não encontrado"
    exit 1
fi

echo "✅ Formulários encontrados"

echo "2️⃣ Fazendo backup dos formulários..."

cp "src/components/audiencias/NewAudiencia.js" "src/components/audiencias/NewAudiencia.js.bak.142"
cp "src/components/audiencias/EditAudiencia.js" "src/components/audiencias/EditAudiencia.js.bak.142"

echo "✅ Backups criados"

echo "3️⃣ Analisando uso atual do audienciasService nos formulários..."

echo "📋 NewAudiencia.js - imports:"
grep -n "import.*audiencias" src/components/audiencias/NewAudiencia.js || echo "   Nenhum import de audienciasService encontrado"

echo ""
echo "📋 EditAudiencia.js - imports:"
grep -n "import.*audiencias" src/components/audiencias/EditAudiencia.js || echo "   Nenhum import de audienciasService encontrado"

echo ""
echo "📋 NewAudiencia.js - uso de service:"
grep -n "audienciasService" src/components/audiencias/NewAudiencia.js || echo "   Nenhum uso encontrado"

echo ""
echo "📋 EditAudiencia.js - uso de service:"
grep -n "audienciasService" src/components/audiencias/EditAudiencia.js || echo "   Nenhum uso encontrado"

echo "4️⃣ Integrando NewAudiencia.js com API real..."

# Verificar se já importa audienciasService
if ! grep -q "import.*audienciasService" src/components/audiencias/NewAudiencia.js; then
    echo "Adicionando import do audienciasService..."
    
    # Adicionar import após os outros imports
    sed -i '/import.*@heroicons/a import audienciasService from "../../services/audienciasService";' src/components/audiencias/NewAudiencia.js
fi

# Substituir handleSubmit mockado por integração real
if grep -q "// Simular salvamento" src/components/audiencias/NewAudiencia.js; then
    echo "Substituindo salvamento mockado por API real..."
    
    # Criar nova implementação do handleSubmit
    cat > temp_new_handlesubmit.js << 'EOF'
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setLoading(true);
    
    try {
      // Validar dados antes do envio
      const validacao = audienciasService.validarDadosAudiencia(formData);
      if (!validacao.valido) {
        setErrors(validacao.erros.reduce((acc, erro) => {
          const campo = erro.toLowerCase().includes('processo') ? 'processoId' :
                       erro.toLowerCase().includes('cliente') ? 'clienteId' :
                       erro.toLowerCase().includes('tipo') ? 'tipo' :
                       erro.toLowerCase().includes('data') ? 'data' :
                       erro.toLowerCase().includes('hora') ? 'hora' :
                       erro.toLowerCase().includes('local') ? 'local' :
                       erro.toLowerCase().includes('advogado') ? 'advogado' : 'geral';
          acc[campo] = erro;
          return acc;
        }, {}));
        return;
      }

      // Formatar dados para a API
      const dadosFormatados = audienciasService.formatarDadosParaAPI(formData);
      
      // Enviar para API
      const resultado = await audienciasService.criarAudiencia(dadosFormatados);
      
      if (resultado.success) {
        alert('Audiência agendada com sucesso!');
        navigate('/admin/audiencias');
      } else {
        alert('Erro ao agendar audiência: ' + resultado.error);
        
        // Tratar erros de validação do backend
        if (resultado.errors) {
          setErrors(resultado.errors);
        }
      }
    } catch (error) {
      console.error('Erro ao criar audiência:', error);
      alert('Erro inesperado ao agendar audiência');
    } finally {
      setLoading(false);
    }
  };
EOF

    # Substituir função handleSubmit
    awk '
    BEGIN { in_handlesubmit = 0; skip_lines = 0 }
    
    /const handleSubmit = async \(e\) => \{/ {
        while ((getline line < "temp_new_handlesubmit.js") > 0) {
            print line
        }
        close("temp_new_handlesubmit.js")
        in_handlesubmit = 1
        skip_lines = 1
        next
    }
    
    in_handlesubmit && /^  \};$/ {
        in_handlesubmit = 0
        skip_lines = 0
        next
    }
    
    skip_lines { next }
    { print }
    ' src/components/audiencias/NewAudiencia.js > src/components/audiencias/NewAudiencia_temp.js
    
    mv src/components/audiencias/NewAudiencia_temp.js src/components/audiencias/NewAudiencia.js
    rm temp_new_handlesubmit.js
fi

echo "5️⃣ Integrando EditAudiencia.js com API real..."

# Verificar se já importa audienciasService
if ! grep -q "import.*audienciasService" src/components/audiencias/EditAudiencia.js; then
    echo "Adicionando import do audienciasService..."
    
    sed -i '/import.*@heroicons/a import audienciasService from "../../services/audienciasService";' src/components/audiencias/EditAudiencia.js
fi

# Substituir carregamento de dados mockados
if grep -q "const mockAudiencia" src/components/audiencias/EditAudiencia.js; then
    echo "Substituindo carregamento mockado por API real..."
    
    # Criar nova implementação do useEffect
    cat > temp_edit_useeffect.js << 'EOF'
  useEffect(() => {
    const carregarAudiencia = async () => {
      if (!id) return;
      
      setLoadingData(true);
      
      try {
        const resultado = await audienciasService.obterAudiencia(id);
        
        if (resultado.success && resultado.audiencia) {
          const audiencia = resultado.audiencia;
          
          // Formatar dados para o formulário
          setFormData({
            tipo: audiencia.tipo || '',
            data: audiencia.data ? (audiencia.data.includes('T') ? audiencia.data.split('T')[0] : audiencia.data) : '',
            hora: audiencia.hora ? audiencia.hora.substring(0, 5) : '',
            local: audiencia.local || '',
            sala: audiencia.sala || '',
            endereco: audiencia.endereco || '',
            advogado: audiencia.advogado || '',
            juiz: audiencia.juiz || '',
            status: audiencia.status || 'agendada',
            observacoes: audiencia.observacoes || ''
          });
        } else {
          alert('Erro ao carregar audiência: ' + (resultado.error || 'Audiência não encontrada'));
          navigate('/admin/audiencias');
        }
      } catch (error) {
        console.error('Erro ao carregar audiência:', error);
        alert('Erro ao carregar dados da audiência');
        navigate('/admin/audiencias');
      } finally {
        setLoadingData(false);
      }
    };

    carregarAudiencia();
  }, [id, navigate]);
EOF

    # Substituir useEffect
    awk '
    BEGIN { in_useeffect = 0; brace_count = 0 }
    
    /useEffect\(\(\) => \{/ {
        while ((getline line < "temp_edit_useeffect.js") > 0) {
            print line
        }
        close("temp_edit_useeffect.js")
        in_useeffect = 1
        brace_count = 1
        next
    }
    
    in_useeffect {
        gsub(/\{/, "", $0); brace_count += gsub(/\{/, "", $0)
        gsub(/\}/, "", $0); brace_count -= gsub(/\}/, "", $0)
        if (brace_count <= 0) {
            in_useeffect = 0
            next
        }
        next
    }
    
    { print }
    ' src/components/audiencias/EditAudiencia.js > src/components/audiencias/EditAudiencia_temp.js
    
    mv src/components/audiencias/EditAudiencia_temp.js src/components/audiencias/EditAudiencia.js
    rm temp_edit_useeffect.js
fi

# Substituir handleSubmit de edição
if grep -q "// Simular salvamento" src/components/audiencias/EditAudiencia.js; then
    echo "Substituindo salvamento de edição por API real..."
    
    cat > temp_edit_handlesubmit.js << 'EOF'
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setLoading(true);
    
    try {
      // Formatar dados para a API
      const dadosFormatados = audienciasService.formatarDadosParaAPI(formData);
      
      // Atualizar via API
      const resultado = await audienciasService.atualizarAudiencia(id, dadosFormatados);
      
      if (resultado.success) {
        alert('Audiência atualizada com sucesso!');
        navigate('/admin/audiencias');
      } else {
        alert('Erro ao atualizar audiência: ' + resultado.error);
        
        if (resultado.errors) {
          setErrors(resultado.errors);
        }
      }
    } catch (error) {
      console.error('Erro ao atualizar audiência:', error);
      alert('Erro inesperado ao atualizar audiência');
    } finally {
      setLoading(false);
    }
  };
EOF

    # Substituir função handleSubmit de edição
    awk '
    BEGIN { in_handlesubmit = 0; skip_lines = 0 }
    
    /const handleSubmit = async \(e\) => \{/ {
        while ((getline line < "temp_edit_handlesubmit.js") > 0) {
            print line
        }
        close("temp_edit_handlesubmit.js")
        in_handlesubmit = 1
        skip_lines = 1
        next
    }
    
    in_handlesubmit && /^  \};$/ {
        in_handlesubmit = 0
        skip_lines = 0
        next
    }
    
    skip_lines { next }
    { print }
    ' src/components/audiencias/EditAudiencia.js > src/components/audiencias/EditAudiencia_temp2.js
    
    mv src/components/audiencias/EditAudiencia_temp2.js src/components/audiencias/EditAudiencia.js
    rm temp_edit_handlesubmit.js
fi

echo "6️⃣ Verificando sintaxe dos formulários..."

if node -c src/components/audiencias/NewAudiencia.js 2>/dev/null; then
    echo "✅ NewAudiencia.js - sintaxe correta"
else
    echo "❌ NewAudiencia.js - erro de sintaxe"
    node -c src/components/audiencias/NewAudiencia.js
fi

if node -c src/components/audiencias/EditAudiencia.js 2>/dev/null; then
    echo "✅ EditAudiencia.js - sintaxe correta" 
else
    echo "❌ EditAudiencia.js - erro de sintaxe"
    node -c src/components/audiencias/EditAudiencia.js
fi

echo ""
echo "✅ Script 142 concluído!"
echo ""
echo "🔧 INTEGRAÇÕES REALIZADAS:"
echo "   ✅ NewAudiencia.js conectado com audienciasService"
echo "   ✅ EditAudiencia.js conectado com audienciasService"
echo "   ✅ Dados mockados substituídos por API real"
echo "   ✅ Validação e formatação integradas"
echo ""
echo "📋 FUNCIONALIDADES:"
echo "   • Criar nova audiência via API"
echo "   • Carregar dados para edição via API"
echo "   • Atualizar audiência existente via API"
echo "   • Validação de dados antes do envio"
echo "   • Tratamento de erros do backend"
echo ""
echo "🧪 TESTE:"
echo "   1. Ir para /admin/audiencias/nova"
echo "   2. Preencher formulário e testar criação"
echo "   3. Clicar em 'Editar' numa audiência existente"
echo "   4. Testar atualização dos dados"
echo ""
echo "🔄 Se houver erro:"
echo "   Restaurar backups: .bak.142"