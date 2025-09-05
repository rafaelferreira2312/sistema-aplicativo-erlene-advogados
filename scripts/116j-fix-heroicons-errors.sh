#!/bin/bash

# Script 116j - Corrigir Erros de Ícones Heroicons
# Sistema Erlene Advogados - Substituir ícones inexistentes
# Execução: chmod +x 116j-fix-heroicons-errors.sh && ./116j-fix-heroicons-errors.sh
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 116j - Corrigindo erros de ícones Heroicons..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    exit 1
fi

echo "1️⃣ Corrigindo imports de ícones no ProcessDetails.js..."

# Substituir RefreshIcon por ArrowPathIcon no ProcessDetails.js
sed -i 's/RefreshIcon/ArrowPathIcon/g' src/components/processes/ProcessDetails.js
sed -i 's/import {/import {\n  ArrowPathIcon,/' src/components/processes/ProcessDetails.js
sed -i '/CheckCircleIcon,/d' src/components/processes/ProcessDetails.js

# Corrigir imports no cabeçalho
cat > temp_processdetails_imports.txt << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import { processesService } from '../../services/processesService';
import {
  ArrowLeftIcon,
  ArrowPathIcon,
  ScaleIcon,
  UserIcon,
  DocumentTextIcon,
  CurrencyDollarIcon,
  BuildingLibraryIcon,
  CalendarIcon,
  ClockIcon,
  PencilIcon,
  DocumentIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon
} from '@heroicons/react/24/outline';
EOF

# Substituir apenas a seção de imports
sed -i '1,/^} from.*heroicons/c\' src/components/processes/ProcessDetails.js
cat temp_processdetails_imports.txt > temp_new_processdetails.js
sed -n '/^const ProcessDetails/,$p' src/components/processes/ProcessDetails.js >> temp_new_processdetails.js
mv temp_new_processdetails.js src/components/processes/ProcessDetails.js
rm temp_processdetails_imports.txt

echo "2️⃣ Corrigindo imports de ícones no Processes.js..."

# Substituir RefreshIcon por ArrowPathIcon no Processes.js
sed -i 's/RefreshIcon/ArrowPathIcon/g' src/pages/admin/Processes.js

# Corrigir import no Processes.js
sed -i 's/RefreshIcon,/ArrowPathIcon,/' src/pages/admin/Processes.js

echo "3️⃣ Removendo variáveis não utilizadas..."

# Remover variável navigate não utilizada do ProcessDetails.js
sed -i '/const navigate = useNavigate();/d' src/components/processes/ProcessDetails.js

echo "4️⃣ Corrigindo hook useEffect dependency..."

# Corrigir o useEffect no ProcessDetails.js
cat > temp_useeffect.txt << 'EOF'
  useEffect(() => {
    const loadData = async () => {
      await loadProcessDetails();
    };
    loadData();
  }, [id]);
EOF

# Substituir o useEffect problemático
sed -i '/useEffect(() => {/,/}, \[id\]);/{
  /useEffect(() => {/r temp_useeffect.txt
  d
}' src/components/processes/ProcessDetails.js

rm temp_useeffect.txt

echo "5️⃣ Verificando se correções foram aplicadas..."

# Verificar se ArrowPathIcon está sendo usado
if grep -q "ArrowPathIcon" src/components/processes/ProcessDetails.js; then
    echo "✅ ProcessDetails.js - ArrowPathIcon corrigido"
else
    echo "❌ Erro ao corrigir ProcessDetails.js"
fi

if grep -q "ArrowPathIcon" src/pages/admin/Processes.js; then
    echo "✅ Processes.js - ArrowPathIcon corrigido"
else
    echo "❌ Erro ao corrigir Processes.js"
fi

# Verificar se RefreshIcon não existe mais
if ! grep -q "RefreshIcon" src/components/processes/ProcessDetails.js && ! grep -q "RefreshIcon" src/pages/admin/Processes.js; then
    echo "✅ RefreshIcon removido com sucesso"
else
    echo "⚠️ Ainda existem referências ao RefreshIcon"
fi

echo ""
echo "📋 Correções Aplicadas:"
echo "   • RefreshIcon → ArrowPathIcon (ícone de atualizar)"
echo "   • Removido CheckCircleIcon não utilizado"
echo "   • Removido navigate não utilizado"
echo "   • Corrigido useEffect dependency"
echo ""
echo "✅ Script 116j concluído!"
echo "🎯 Erros de Heroicons resolvidos!"