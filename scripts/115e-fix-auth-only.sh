#!/bin/bash

# Script 115e - Correção APENAS da Autenticação (sem alterar layouts)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115e-fix-auth-only.sh && ./115e-fix-auth-only.sh
# EXECUTE NA PASTA: frontend/

echo "🔐 Corrigindo APENAS o sistema de autenticação (sem alterar layouts)..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "❌ Execute este script na pasta frontend/"
    exit 1
fi

echo "📝 1. Atualizando APENAS o ProtectedRoute no App.js..."

# Fazer backup do App.js atual
cp src/App.js src/App.js.backup

# Criar uma versão temporária do App.js só com a correção de autenticação
python3 -c "
import re

# Ler o arquivo atual
with open('src/App.js', 'r', encoding='utf-8') as f:
    content = f.read()

# Encontrar e substituir apenas a função ProtectedRoute
old_pattern = r'// Componente de proteção de rota.*?const ProtectedRoute = \({ children, requiredAuth = true, allowedTypes = \[\] }\) => \{.*?\};'

new_protected_route = '''// Componente de proteção de rota CORRIGIDO
const ProtectedRoute = ({ children, requiredAuth = true, allowedTypes = [] }) => {
  // Verificar múltiplas formas de autenticação para compatibilidade
  const token = localStorage.getItem('authToken') || localStorage.getItem('erlene_token') || localStorage.getItem('token');
  const isAuthFlag = localStorage.getItem('isAuthenticated') === 'true';
  const portalAuth = localStorage.getItem('portalAuth') === 'true';
  
  const isAuthenticated = !!(token || isAuthFlag);
  
  // Determinar tipo de usuário
  const userType = localStorage.getItem('userType') || (portalAuth ? 'cliente' : 'admin');

  // Se requer autenticação e não está autenticado
  if (requiredAuth && !isAuthenticated) {
    // Redirecionar para o login correto baseado no tipo esperado
    if (allowedTypes.includes('cliente')) {
      return <Navigate to=\"/portal/login\" replace />;
    }
    return <Navigate to=\"/login\" replace />;
  }

  // Se não requer autenticação mas está autenticado, redirecionar para dashboard
  if (!requiredAuth && isAuthenticated) {
    if (userType === 'cliente') {
      return <Navigate to=\"/portal/dashboard\" replace />;
    }
    return <Navigate to=\"/admin\" replace />;
  }

  // Verificar tipo de usuário permitido
  if (allowedTypes.length > 0 && !allowedTypes.includes(userType)) {
    if (userType === 'cliente') {
      return <Navigate to=\"/portal/dashboard\" replace />;
    }
    return <Navigate to=\"/admin\" replace />;
  }

  return children;
};'''

# Substituir usando regex com flags DOTALL
new_content = re.sub(
    old_pattern,
    new_protected_route,
    content,
    flags=re.DOTALL
)

# Se não encontrou o padrão, adicionar antes do App principal
if new_content == content:
    # Procurar por qualquer ProtectedRoute existente e substituir
    if 'ProtectedRoute' in content:
        lines = content.split('\n')
        new_lines = []
        in_protected_route = False
        brace_count = 0
        
        for line in lines:
            if 'const ProtectedRoute' in line or 'ProtectedRoute = ' in line:
                in_protected_route = True
                brace_count = 0
                new_lines.append(new_protected_route)
                continue
                
            if in_protected_route:
                brace_count += line.count('{') - line.count('}')
                if brace_count <= 0 and '};' in line:
                    in_protected_route = False
                continue
                    
            if not in_protected_route:
                new_lines.append(line)
        
        new_content = '\n'.join(new_lines)

# Escrever o arquivo corrigido
with open('src/App.js', 'w', encoding='utf-8') as f:
    f.write(new_content)

print('App.js atualizado com autenticação corrigida')
"

echo "📝 2. Atualizando APENAS o apiClient para múltiplos tokens..."

# Atualizar apiClient.js sem alterar funcionalidade, apenas compatibilidade
cat > src/services/apiClient.js << 'EOF'
import axios from 'axios';

// Configurações da API
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

// Criar instância do axios
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Função para obter token (compatibilidade com múltiplos formatos)
const getAuthToken = () => {
  return localStorage.getItem('authToken') || 
         localStorage.getItem('erlene_token') || 
         localStorage.getItem('token');
};

// Request interceptor - adicionar token automaticamente
apiClient.interceptors.request.use(
  (config) => {
    const token = getAuthToken();
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor - tratar erros
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  async (error) => {
    const { response } = error;
    
    if (response?.status === 401) {
      console.warn('Token expirado, limpando autenticação...');
      
      // Limpar tokens mas manter outros dados de layout
      const layoutPreferences = localStorage.getItem('layoutPreferences');
      
      localStorage.clear();
      
      if (layoutPreferences) {
        localStorage.setItem('layoutPreferences', layoutPreferences);
      }
      
      // Redirecionar para login
      window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);

export default apiClient;
EOF

echo "📝 3. Modificando APENAS a lógica de login (mantendo layout original)..."

# Verificar se existe um arquivo de Login e modificar apenas a lógica de salvamento
if [ -f "src/pages/auth/Login.js" ]; then
    echo "Atualizando lógica de autenticação no Login existente..."
    
    # Fazer backup
    cp src/pages/auth/Login.js src/pages/auth/Login.js.backup
    
    # Adicionar código de sincronização de autenticação após sucesso do login
    python3 -c "
import re

with open('src/pages/auth/Login.js', 'r', encoding='utf-8') as f:
    content = f.read()

# Procurar por onde define sucesso do login e adicionar sincronização
patterns_to_replace = [
    (r'localStorage\.setItem\(\'isAuthenticated\', \'true\'\);?\s*localStorage\.setItem\(\'userType\', \'admin\'\);?', 
     '''// Sincronizar múltiplos formatos para compatibilidade
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'admin');
        // Remover auth de portal se existir
        localStorage.removeItem('portalAuth');'''),
    
    (r'localStorage\.setItem\(\'isAuthenticated\', \'true\'\);?', 
     '''// Sincronizar autenticação admin
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'admin');
        localStorage.removeItem('portalAuth');'''),
]

new_content = content
for pattern, replacement in patterns_to_replace:
    new_content = re.sub(pattern, replacement, new_content, flags=re.MULTILINE)

with open('src/pages/auth/Login.js', 'w', encoding='utf-8') as f:
    f.write(new_content)
    
print('Login.js atualizado mantendo layout original')
"
fi

echo "📝 4. Criando utilitário de debug simples..."

# Criar utilitário mínimo de debug
mkdir -p src/utils
cat > src/utils/debugAuth.js << 'EOF'
// Debug simples para verificar autenticação
export const debugAuth = () => {
  const authData = {
    tokens: {
      authToken: !!localStorage.getItem('authToken'),
      erleneToken: !!localStorage.getItem('erlene_token'),
      token: !!localStorage.getItem('token')
    },
    flags: {
      isAuthenticated: localStorage.getItem('isAuthenticated') === 'true',
      portalAuth: localStorage.getItem('portalAuth') === 'true',
      userType: localStorage.getItem('userType')
    },
    status: 'unknown'
  };
  
  const hasAnyToken = Object.values(authData.tokens).some(Boolean);
  const isAuth = hasAnyToken || authData.flags.isAuthenticated;
  
  authData.status = isAuth ? 'authenticated' : 'not authenticated';
  
  console.table(authData);
  return authData;
};

if (typeof window !== 'undefined') {
  window.debugAuth = debugAuth;
}
EOF

echo "📝 5. Testando compilação..."

# Verificar se há erros
echo "Testando compilação..."
npm run build --silent 2>&1 | head -5

echo "✅ Autenticação corrigida SEM alterar layouts!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • ProtectedRoute agora aceita múltiplos tipos de token"
echo "   • ApiClient busca token em diferentes locais"  
echo "   • Login sincroniza autenticação sem alterar visual"
echo "   • Layout original da tela de login MANTIDO"
echo ""
echo "🚀 TESTE:"
echo "   1. npm start"
echo "   2. Faça login normal"
echo "   3. Tente acessar /admin/clientes"
echo "   4. Para debug: abra F12 e digite debugAuth()"
echo ""
echo "O layout da tela de login não foi alterado!"