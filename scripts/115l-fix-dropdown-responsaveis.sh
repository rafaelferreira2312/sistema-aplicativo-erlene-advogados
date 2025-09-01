#!/bin/bash

# Script 115l - Correção Final do Dropdown de Responsáveis
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115l-fix-dropdown-responsaveis.sh && ./115l-fix-dropdown-responsaveis.sh
# EXECUTE NA PASTA: frontend/

echo "Corrigindo dropdown de responsáveis no frontend..."

# Verificar se estamos na pasta frontend
if [ ! -f "package.json" ]; then
    echo "Execute este script na pasta frontend/"
    exit 1
fi

echo "1. Corrigindo NewClient.js - campo 'nome' para 'name'..."

# Corrigir NewClient.js
sed -i 's/resp\.nome/resp.name/g' src/components/clients/NewClient.js
sed -i 's/{resp\.nome}/{resp.name}/g' src/components/clients/NewClient.js

echo "2. Corrigindo EditClient.js - adicionando dropdown de responsáveis..."

# Fazer backup
cp src/components/clients/EditClient.js src/components/clients/EditClient.js.backup

# Adicionar carregamento de responsáveis no EditClient.js
python3 -c "
import re

# Ler arquivo
with open('src/components/clients/EditClient.js', 'r') as f:
    content = f.read()

# Adicionar import do clientsService se não existir
if 'clientsService' not in content:
    content = re.sub(
        r'(import.*from \'@heroicons/react/24/outline\';)',
        r'\1\nimport { clientsService } from \'../../services/api/clientsService\';',
        content
    )

# Adicionar estado para responsáveis
if 'responsaveis' not in content:
    content = re.sub(
        r'(\s+const \[showDeleteModal, setShowDeleteModal\] = useState\(false\);)',
        r'\1\n  const [responsaveis, setResponsaveis] = useState([]);',
        content
    )

# Adicionar useEffect para carregar responsáveis
useeffect_code = '''
  // Carregar responsáveis
  useEffect(() => {
    const loadResponsaveis = async () => {
      try {
        const response = await clientsService.getResponsaveis();
        setResponsaveis(response.data || []);
      } catch (error) {
        console.error('Erro ao carregar responsáveis:', error);
      }
    };
    
    loadResponsaveis();
  }, []);
'''

if 'loadResponsaveis' not in content:
    # Encontrar onde inserir o useEffect
    content = re.sub(
        r'(useEffect\(\(\) => \{.*?loadClient\(\);.*?\}, \[id\]\);)',
        r'\1\n' + useeffect_code,
        content,
        flags=re.DOTALL
    )

# Adicionar campo responsável antes do primeiro campo (após telefone)
responsavel_field = '''
            <div>
              <label className=\"block text-sm font-medium text-gray-700 mb-2\">Responsável *</label>
              <select
                name=\"responsavel_id\"
                value={formData.responsavel_id || ''}
                onChange={handleChange}
                className=\"w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500\"
              >
                <option value=\"\">Selecione um responsável</option>
                {responsaveis.map(resp => (
                  <option key={resp.id} value={resp.id}>
                    {resp.name} {resp.oab ? \`- OAB: \${resp.oab}\` : ''}
                  </option>
                ))}
              </select>
            </div>'''

# Inserir após o campo telefone
if 'Responsável' not in content:
    content = re.sub(
        r'(              <div className=\"relative\">.*?PhoneIcon.*?</div>\s*</div>)',
        r'\1\n\n' + responsavel_field,
        content,
        flags=re.DOTALL
    )

# Escrever arquivo corrigido
with open('src/components/clients/EditClient.js', 'w') as f:
    f.write(content)

print('EditClient.js corrigido')
"

echo "3. Verificando se clientsService.getResponsaveis() existe..."

# Verificar se método existe no service
if ! grep -q "getResponsaveis" src/services/api/clientsService.js; then
    echo "Adicionando método getResponsaveis() ao clientsService..."
    
    # Adicionar método ao service
    sed -i '/async deleteClient/a\\n  // Obter responsáveis disponíveis\n  async getResponsaveis() {\n    try {\n      const response = await apiClient.get("/admin/clients/responsaveis");\n      return response.data;\n    } catch (error) {\n      console.error("Erro ao buscar responsáveis:", error);\n      throw error;\n    }\n  },' src/services/api/clientsService.js
fi

echo "4. Testando se o endpoint funciona..."

# Testar se backend está rodando
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "Backend está rodando, testando endpoint responsaveis..."
    
    # Fazer login e testar
    LOGIN_RESP=$(curl -s -X POST http://localhost:8000/api/auth/login \
      -H 'Content-Type: application/json' \
      -d '{"email":"admin@erlene.com","password":"123456"}')
    
    TOKEN=$(echo $LOGIN_RESP | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    
    if [ ! -z "$TOKEN" ]; then
        echo "Testando responsaveis com token..."
        RESP_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
             http://localhost:8000/api/admin/clients/responsaveis)
        echo "Resultado: $(echo $RESP_RESULT | head -c 100)..."
    fi
else
    echo "Backend não está rodando. Inicie com: cd ../backend && php artisan serve"
fi

echo ""
echo "CORREÇÃO CONCLUÍDA!"
echo ""
echo "ALTERAÇÕES FEITAS:"
echo "• NewClient.js: resp.nome → resp.name"
echo "• EditClient.js: adicionado dropdown de responsáveis"  
echo "• clientsService: verificado método getResponsaveis()"
echo ""
echo "TESTE:"
echo "1. Certifique-se que o backend está rodando"
echo "2. Recarregue a página do frontend (Ctrl+F5)"
echo "3. Acesse /admin/clientes/novo"
echo "4. O dropdown deve mostrar os nomes dos usuários"
echo ""
echo "Se não funcionar, abra F12 → Network e veja se:"
echo "• Aparece requisição para /responsaveis"
echo "• Status da requisição (200, 401, 404, 500)"
echo "• Response com os dados dos usuários"