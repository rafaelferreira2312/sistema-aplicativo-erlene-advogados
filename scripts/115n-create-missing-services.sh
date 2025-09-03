#!/bin/bash

# Script 115n - Criar Services Faltantes e Corrigir Imports
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115n-create-missing-services.sh && ./115n-create-missing-services.sh
# EXECUTE NA PASTA: frontend/

echo "🔧 Criando services faltantes e corrigindo imports..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "1. Criando dashboardService.js..."

# Criar dashboardService que está faltando
cat > src/services/api/dashboardService.js << 'EOF'
import apiClient from './apiClient';

export const dashboardService = {
  // Obter estatísticas do dashboard
  async getStats() {
    try {
      const response = await apiClient.get('/admin/dashboard');
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar estatísticas do dashboard:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar estatísticas',
        data: {
          totalClients: 0,
          activeProcesses: 0,
          pendingAppointments: 0,
          monthlyRevenue: 0
        }
      };
    }
  },

  // Obter notificações recentes
  async getNotifications() {
    try {
      const response = await apiClient.get('/admin/dashboard/notifications');
      return {
        success: true,
        data: response.data.data || response.data || []
      };
    } catch (error) {
      console.error('Erro ao buscar notificações:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar notificações',
        data: []
      };
    }
  },

  // Obter atividades recentes
  async getRecentActivities() {
    try {
      const response = await apiClient.get('/admin/dashboard/activities');
      return {
        success: true,
        data: response.data.data || response.data || []
      };
    } catch (error) {
      console.error('Erro ao buscar atividades:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar atividades',
        data: []
      };
    }
  },

  // Obter gráficos do dashboard
  async getCharts(period = 'month') {
    try {
      const response = await apiClient.get('/admin/dashboard/charts', {
        params: { period }
      });
      return {
        success: true,
        data: response.data.data || response.data
      };
    } catch (error) {
      console.error('Erro ao buscar gráficos:', error);
      return {
        success: false,
        error: error.response?.data?.message || 'Erro ao buscar gráficos',
        data: {}
      };
    }
  }
};

export default dashboardService;
EOF

echo "✅ dashboardService.js criado"

echo ""
echo "2. Criando arquivo index.js para exports centralizados..."

# Criar index.js para centralizar exports
cat > src/services/api/index.js << 'EOF'
// Exports centralizados dos services da API

export { default as apiClient } from './apiClient';
export { clientsService } from './clientsService';
export { dashboardService } from './dashboardService';
export { authService } from '../auth/authService';

// Re-export para compatibilidade
export { default as authService } from '../auth/authService';
export { default as clientsService } from './clientsService';
export { default as dashboardService } from './dashboardService';
EOF

echo "✅ index.js criado"

echo ""
echo "3. Corrigindo imports no Dashboard..."

# Corrigir import no Dashboard se existir
if [ -f "src/pages/admin/Dashboard/index.js" ]; then
    echo "Corrigindo import do dashboardService no Dashboard..."
    
    # Substituir import quebrado
    sed -i 's|import.*dashboardService.*from.*services/api/dashboardService.*|import { dashboardService } from "../../../services/api/dashboardService";|g' src/pages/admin/Dashboard/index.js
    
    echo "✅ Import do Dashboard corrigido"
else
    echo "⚠️  Arquivo Dashboard/index.js não encontrado"
fi

echo ""
echo "4. Corrigindo imports no Login..."

# Corrigir imports no Login
if [ -f "src/pages/auth/Login/index.js" ]; then
    echo "Corrigindo imports no Login..."
    
    # Substituir import da API
    sed -i 's|import.*from.*services/api.*|import { authService } from "../../../services/auth/authService";|g' src/pages/auth/Login/index.js
    
    echo "✅ Import do Login corrigido"
else
    echo "⚠️  Arquivo Login/index.js não encontrado"
fi

echo ""
echo "5. Corrigindo imports no PortalLogin..."

# Corrigir imports no PortalLogin
if [ -f "src/pages/portal/PortalLogin.js" ]; then
    echo "Corrigindo imports no PortalLogin..."
    
    # Substituir import da API
    sed -i 's|import.*from.*services/api.*|import { authService } from "../../services/auth/authService";|g' src/pages/portal/PortalLogin.js
    
    echo "✅ Import do PortalLogin corrigido"
else
    echo "⚠️  Arquivo PortalLogin.js não encontrado"
fi

echo ""
echo "6. Corrigindo import no EditClient..."

# Corrigir EditClient se existir
if [ -f "src/components/clients/EditClient.js" ]; then
    echo "Corrigindo import do clientsService no EditClient..."
    
    # Verificar se já tem import correto
    if ! grep -q "import.*clientsService.*from" src/components/clients/EditClient.js; then
        # Adicionar import no início do arquivo
        sed -i '1i import { clientsService } from "../../services/api/clientsService";' src/components/clients/EditClient.js
    fi
    
    echo "✅ Import do EditClient corrigido"
else
    echo "⚠️  Arquivo EditClient.js não encontrado"
fi

echo ""
echo "7. Corrigindo outros imports comuns..."

# Função para corrigir imports em arquivos que existem
fix_imports_in_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "Corrigindo imports em: $file"
        
        # Corrigir clientsService
        sed -i 's|import.*clientsService.*from.*services/api/clientsService.*|import { clientsService } from "../../services/api/clientsService";|g' "$file" 2>/dev/null
        
        # Corrigir authService
        sed -i 's|import.*authService.*from.*services/auth/authService.*|import { authService } from "../../services/auth/authService";|g' "$file" 2>/dev/null
        
        # Corrigir dashboardService
        sed -i 's|import.*dashboardService.*from.*services/api/dashboardService.*|import { dashboardService } from "../../services/api/dashboardService";|g' "$file" 2>/dev/null
    fi
}

# Arquivos comuns que podem ter imports quebrados
COMMON_FILES=(
    "src/components/clients/NewClient.js"
    "src/components/clients/ClientList.js"
    "src/pages/admin/Clients/index.js"
    "src/hooks/useClients.js"
)

for file in "${COMMON_FILES[@]}"; do
    fix_imports_in_file "$file"
done

echo "✅ Imports corrigidos em arquivos existentes"

echo ""
echo "8. Criando utilitários básicos..."

# Criar formatters básicos se não existir
if [ ! -f "src/utils/formatters.js" ]; then
    cat > src/utils/formatters.js << 'EOF'
// Formatadores para campos de entrada

export const formatDocument = (value, type = 'PF') => {
  const numbers = value.replace(/\D/g, '');
  
  if (type === 'PF') {
    // CPF: 000.000.000-00
    return numbers.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
  } else {
    // CNPJ: 00.000.000/0000-00
    return numbers.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
  }
};

export const formatPhone = (value) => {
  const numbers = value.replace(/\D/g, '');
  
  if (numbers.length <= 10) {
    return numbers.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
  } else {
    return numbers.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
  }
};

export const formatCEP = (value) => {
  const numbers = value.replace(/\D/g, '');
  return numbers.replace(/(\d{5})(\d{3})/, '$1-$2');
};
EOF
    echo "✅ formatters.js criado"
fi

echo ""
echo "9. Verificando estrutura final..."

# Listar arquivos de services
echo ""
echo "📁 ESTRUTURA DE SERVICES ATUAL:"
find src/services -name "*.js" 2>/dev/null | sort

echo ""
echo "🎉 CORREÇÃO CONCLUÍDA!"
echo ""
echo "SERVICES CRIADOS/CORRIGIDOS:"
echo "✅ dashboardService.js - Para o Dashboard"
echo "✅ index.js - Exports centralizados"
echo "✅ Imports corrigidos nos componentes"
echo "✅ formatters.js - Utilitários básicos"
echo ""
echo "🔄 PRÓXIMOS PASSOS:"
echo "1. Recarregue o frontend (Ctrl+C e npm start)"
echo "2. Teste se não há mais erros de importação"
echo "3. Verifique se Dashboard e Login funcionam"
echo ""
echo "Se ainda houver erros, me informe quais arquivos específicos"
echo "estão com problemas para corrigir individualmente."