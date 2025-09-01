#!/bin/bash

# Script 115j - Correção Responsáveis por Unidade
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115j-fix-responsaveis-por-unidade.sh && ./115j-fix-responsaveis-por-unidade.sh
# EXECUTE NA PASTA: backend/

echo "Corrigindo método responsaveis() para filtrar por unidade..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "Execute este script na pasta backend/"
    exit 1
fi

echo "1. Atualizando método responsaveis() no ClientController..."

# Criar versão corrigida do método
cat > temp_responsaveis_method.txt << 'EOF'
    /**
     * Obter responsáveis disponíveis da mesma unidade
     */
    public function responsaveis()
    {
        try {
            $user = auth()->user();
            
            if (!$user) {
                return $this->error('Usuário não autenticado', 401);
            }
            
            // Buscar usuários da mesma unidade que podem ser responsáveis
            $query = User::whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado'])
                        ->where('status', 'ativo');
            
            // Filtrar pela unidade do usuário logado
            if ($user->unidade_id) {
                $query->where('unidade_id', $user->unidade_id);
            }
            
            $responsaveis = $query->select('id', 'nome', 'email', 'oab', 'perfil')
                                ->orderBy('nome')
                                ->get();
            
            return $this->success($responsaveis);
            
        } catch (\Exception $e) {
            \Log::error('Erro ao buscar responsáveis: ' . $e->getMessage());
            return $this->error('Erro interno', 500);
        }
    }
EOF

# Substituir o método no arquivo
python3 -c "
import re

# Ler arquivo do controller
with open('app/Http/Controllers/Api/Admin/Clients/ClientController.php', 'r') as f:
    content = f.read()

# Ler novo método
with open('temp_responsaveis_method.txt', 'r') as f:
    new_method = f.read().strip()

# Padrões para encontrar o método responsaveis
patterns = [
    r'\/\*\*.*?Obter responsáveis disponíveis.*?\*\/.*?public function responsaveis\(\).*?return.*?success.*?;.*?\}',
    r'public function responsaveis\(\).*?(?=\n\s*\/\*\*|\n\s*public|\n\s*\})',
    r'public function responsaveis\(\)[^}]*\}'
]

found = False
for pattern in patterns:
    if re.search(pattern, content, re.DOTALL):
        new_content = re.sub(pattern, new_method, content, flags=re.DOTALL)
        found = True
        break

if not found:
    # Se não encontrou, adicionar antes do final da classe
    new_content = re.sub(r'(\n\s*)\}(\s*)$', r'\1\n' + new_method + r'\n\1}\2', content)

# Escrever arquivo atualizado
with open('app/Http/Controllers/Api/Admin/Clients/ClientController.php', 'w') as f:
    f.write(new_content)

print('Método responsaveis() atualizado para filtrar por unidade')
"

# Remover arquivo temporário
rm -f temp_responsaveis_method.txt

echo "2. Verificando rota responsaveis..."

if ! grep -q "responsaveis" routes/api.php; then
    echo "Adicionando rota responsaveis..."
    
    # Adicionar rota no grupo correto
    sed -i '/Route::get.*buscar-cep/a\        Route::get("/responsaveis", [App\\Http\\Controllers\\Api\\Admin\\Clients\\ClientController::class, "responsaveis"]);' routes/api.php
fi

echo "3. Testando com usuário autenticado..."

# Limpar cache primeiro
php artisan config:clear
php artisan route:clear

# Iniciar servidor para teste
php artisan serve --port=8000 &
SERVER_PID=$!
sleep 3

# Fazer login para obter token
echo "Fazendo login para obter token..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

# Extrair token (assumindo formato JSON)
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "Token obtido, testando endpoint responsaveis..."
    curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:8000/api/admin/clients/responsaveis | head -5
else
    echo "Não conseguiu obter token, testando sem autenticação:"
    curl -s -H "Accept: application/json" \
         http://localhost:8000/api/admin/clients/responsaveis | head -3
fi

# Parar servidor
kill $SERVER_PID 2>/dev/null

echo ""
echo "4. Verificando estrutura da tabela users..."

# Mostrar estrutura para confirmar campos
php artisan tinker --execute "
echo 'Colunas da tabela users:';
\Schema::getColumnListing('users');
echo 'Total de usuários: ' . \App\Models\User::count();
echo 'Usuários por unidade:';
\App\Models\User::selectRaw('unidade_id, count(*) as total')->groupBy('unidade_id')->get();
"

echo ""
echo "CORREÇÃO CONCLUÍDA!"
echo ""
echo "O método responsaveis() agora:"
echo "- Filtra usuários pela MESMA unidade_id do usuário logado"
echo "- Busca apenas perfis: admin_geral, admin_unidade, advogado"  
echo "- Filtra por status = 'ativo'"
echo "- Retorna: id, nome, email, oab, perfil"
echo ""
echo "O FRONTEND não precisa de alteração."
echo "Ele já chama clientsService.getResponsaveis() automaticamente."
echo ""
echo "TESTE:"
echo "1. php artisan serve"
echo "2. Acesse o frontend e vá em 'Novo Cliente'"
echo "3. O dropdown 'Responsável' deve aparecer com os usuários da unidade"