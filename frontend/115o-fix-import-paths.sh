#!/bin/bash

# Script 115o - Corrigir Caminhos de Import Corretos
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115o-fix-import-paths.sh && ./115o-fix-import-paths.sh
# EXECUTE NA PASTA: frontend/

echo "🔧 Corrigindo caminhos de import corretos..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "1. Analisando estrutura atual de src/..."

# Mostrar estrutura de src/services
echo "📁 ESTRUTURA src/services/:"
find src/services -type f -name "*.js" 2>/dev/null | head -10

echo ""
echo "2. Corrigindo imports em useClients.js..."

# Corrigir useClients.js se existir
if [ -f "src/hooks/useClients.js" ]; then
    echo "Corrigindo import em useClients.js..."
    
    # Substituir import incorreto por correto
    sed -i "s|import.*from.*services/api/clientsService.*|import { clientsService } from '../services/api/clientsService';|g" src/hooks/useClients.js
    
    echo "✅ useClients.js corrigido"
else
    echo "⚠️  useClients.js não encontrado"
fi

echo ""
echo "3. Corrigindo imports em Dashboard..."

if [ -f "src/pages/admin/Dashboard/index.js" ]; then
    echo "Corrigindo import em Dashboard..."
    
    # Corrigir import do dashboardService
    sed -i "s|import.*dashboardService.*from.*|import { dashboardService } from '../../../services/api/dashboardService';|g" src/pages/admin/Dashboard/index.js
    
    # Remover imports não utilizados
    sed -i "/import.*ClockIcon.*from/d" src/pages/admin/Dashboard/index.js
    
    echo "✅ Dashboard corrigido"
else
    echo "⚠️  Dashboard não encontrado"
fi

echo ""
echo "4. Corrigindo imports em Login..."

if [ -f "src/pages/auth/Login/index.js" ]; then
    echo "Corrigindo import em Login..."
    
    # Substituir import incorreto e adicionar apiService
    sed -i "s|import.*authService.*from.*|import { authService } from '../../../services/auth/authService';\nimport apiService from '../../../services/api';|g" src/pages/auth/Login/index.js
    
    echo "✅ Login corrigido"
else
    echo "⚠️  Login não encontrado"
fi

echo ""
echo "5. Corrigindo imports em PortalLogin..."

if [ -f "src/pages/portal/PortalLogin.js" ]; then
    echo "Corrigindo import em PortalLogin..."
    
    # Substituir import incorreto e adicionar apiService
    sed -i "s|import.*authService.*from.*|import { authService } from '../../services/auth/authService';\nimport apiService from '../../services/api';|g" src/pages/portal/PortalLogin.js
    
    echo "✅ PortalLogin corrigido"
else
    echo "⚠️  PortalLogin não encontrado"
fi

echo ""
echo "6. Criando apiService principal que está faltando..."

# Criar apiService principal que está sendo chamado
cat > src/services/api.js << 'EOF'
// API Service principal - compatibilidade com código existente
import { authService } from './auth/authService';
import { clientsService } from './api/clientsService';
import { dashboardService } from './api/dashboardService';
import apiClient from './api/apiClient';

class ApiService {
  constructor() {
    this.client = apiClient;
  }

  // Métodos de autenticação
  async loginAdmin(email, password) {
    try {
      const result = await authService.login(email, password);
      
      if (result.success && result.token) {
        // Salvar token e usuário
        localStorage.setItem('authToken', result.token);
        localStorage.setItem('erlene_token', result.token);
        localStorage.setItem('token', result.token);
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'admin');
        localStorage.setItem('user', JSON.stringify(result.user));
        
        return { 
          success: true, 
          user: result.user,
          access_token: result.token 
        };
      }
      
      return result;
    } catch (error) {
      return { 
        success: false, 
        message: error.message || 'Erro ao fazer login' 
      };
    }
  }

  async loginPortal(cpf_cnpj, password) {
    try {
      const result = await authService.portalLogin(cpf_cnpj, password);
      
      if (result.success && result.token) {
        // Salvar token e usuário do portal
        localStorage.setItem('authToken', result.token);
        localStorage.setItem('erlene_token', result.token);
        localStorage.setItem('token', result.token);
        localStorage.setItem('portalAuth', 'true');
        localStorage.setItem('userType', 'cliente');
        localStorage.setItem('user', JSON.stringify(result.user));
        
        return { 
          success: true, 
          user: result.user,
          access_token: result.token 
        };
      }
      
      return result;
    } catch (error) {
      return { 
        success: false, 
        message: error.message || 'Erro ao fazer login no portal' 
      };
    }
  }

  async logout() {
    try {
      await authService.logout();
    } catch (error) {
      console.error('Erro no logout:', error);
    } finally {
      // Limpar todos os dados de autenticação
      localStorage.removeItem('authToken');
      localStorage.removeItem('erlene_token');
      localStorage.removeItem('token');
      localStorage.removeItem('isAuthenticated');
      localStorage.removeItem('portalAuth');
      localStorage.removeItem('userType');
      localStorage.removeItem('user');
    }
  }

  // Métodos do dashboard
  async getDashboardStats() {
    return await dashboardService.getStats();
  }

  async getDashboardNotifications() {
    return await dashboardService.getNotifications();
  }

  // Método para verificar autenticação
  isAuthenticated() {
    const token = localStorage.getItem('authToken') || 
                  localStorage.getItem('erlene_token') || 
                  localStorage.getItem('token');
    return !!token;
  }

  getUser() {
    const userData = localStorage.getItem('user');
    return userData ? JSON.parse(userData) : null;
  }
}

// Exportar instância singleton
const apiService = new ApiService();
export default apiService;

// Exportar para uso direto
export { apiService };
EOF

echo "✅ apiService principal criado"

echo ""
echo "7. Atualizando index.js dos services..."

# Atualizar index.js para incluir apiService
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

// Export do apiService principal
export { default as apiService } from '../api';
EOF

echo "✅ index.js atualizado"

echo ""
echo "8. Corrigindo EditClient..."

if [ -f "src/components/clients/EditClient.js" ]; then
    echo "Corrigindo EditClient..."
    
    # Verificar se já tem import, se não adicionar
    if ! grep -q "import.*clientsService" src/components/clients/EditClient.js; then
        # Adicionar import no início do arquivo após os outros imports
        sed -i '/import.*from.*@heroicons/a import { clientsService } from "../../services/api/clientsService";' src/components/clients/EditClient.js
    fi
    
    echo "✅ EditClient corrigido"
fi

echo ""
echo "9. Corrigindo outros caminhos comuns..."

# Função para corrigir caminhos em arquivos específicos
fix_paths_in_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "Corrigindo caminhos em: $file"
        
        # Determinar quantos níveis acima para chegar em src/
        local levels=$(echo "$file" | sed 's|src/||' | tr '/' '\n' | wc -l)
        levels=$((levels - 1))
        
        local prefix=""
        for ((i=0; i<levels; i++)); do
            prefix="../$prefix"
        done
        
        # Corrigir imports de services
        sed -i "s|from ['\"].*services/api/clientsService['\"]|from '${prefix}services/api/clientsService'|g" "$file" 2>/dev/null
        sed -i "s|from ['\"].*services/auth/authService['\"]|from '${prefix}services/auth/authService'|g" "$file" 2>/dev/null
        sed -i "s|from ['\"].*services/api/dashboardService['\"]|from '${prefix}services/api/dashboardService'|g" "$file" 2>/dev/null
    fi
}

# Lista de arquivos que podem ter imports incorretos
FILES_TO_FIX=(
    "src/components/clients/NewClient.js"
    "src/pages/admin/Clients/index.js"
)

for file in "${FILES_TO_FIX[@]}"; do
    fix_paths_in_file "$file"
done

echo "✅ Caminhos corrigidos em arquivos existentes"

echo ""
echo "10. Verificando estrutura final..."

echo ""
echo "📁 ESTRUTURA FINAL src/services/:"
find src/services -type f -name "*.js" 2>/dev/null | sort

echo ""
echo "🎉 CORREÇÃO DE CAMINHOS CONCLUÍDA!"
echo ""
echo "PROBLEMAS RESOLVIDOS:"
echo "✅ Caminhos relativos corretos"
echo "✅ Import de clientsService corrigido"
echo "✅ apiService principal criado"
echo "✅ Imports não utilizados removidos"
echo "✅ Compatibilidade com código existente"
echo ""
echo "🔄 PRÓXIMOS PASSOS:"
echo "1. Recarregue o frontend (Ctrl+C e npm start)"
echo "2. Teste se os erros de importação foram resolvidos"
echo "3. Verifique se login e dashboard funcionam"
echo ""
echo "Os imports agora seguem o padrão correto:"
echo "- src/services/api/clientsService.js"
echo "- src/services/auth/authService.js"
echo "- src/services/api/dashboardService.js"
echo "- src/services/api.js (principal)"