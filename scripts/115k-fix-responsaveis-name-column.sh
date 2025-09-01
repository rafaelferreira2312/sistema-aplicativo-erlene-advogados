#!/bin/bash

# Script 115k - Correção do método responsaveis com campo 'name'
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 115k-fix-responsaveis-name-column.sh && ./115k-fix-responsaveis-name-column.sh
# EXECUTE NA PASTA: backend/

echo "Corrigindo método responsaveis() com campo 'name'..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "Execute este script na pasta backend/"
    exit 1
fi

echo "1. Fazendo backup do Controller atual..."
cp app/Http/Controllers/Api/Admin/Clients/ClientController.php app/Http/Controllers/Api/Admin/Clients/ClientController.php.backup

echo "2. Editando método responsaveis() no ClientController..."

# Criar o método correto usando field 'name'
cat > temp_method.txt << 'EOF'
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
            
            $responsaveis = $query->select('id', 'name', 'email', 'oab', 'perfil')
                                ->orderBy('name')
                                ->get();
            
            return $this->success($responsaveis);
            
        } catch (\Exception $e) {
            \Log::error('Erro ao buscar responsáveis: ' . $e->getMessage());
            return $this->error('Erro interno', 500);
        }
    }
EOF

# Substituir método usando sed mais simples
sed -i '/\/\*\*.*Obter responsáveis disponíveis/,/^    }$/c\
    /**\
     * Obter responsáveis disponíveis da mesma unidade\
     */\
    public function responsaveis()\
    {\
        try {\
            $user = auth()->user();\
            \
            if (!$user) {\
                return $this->error("Usuário não autenticado", 401);\
            }\
            \
            // Buscar usuários da mesma unidade que podem ser responsáveis\
            $query = User::whereIn("perfil", ["admin_geral", "admin_unidade", "advogado"])\
                        ->where("status", "ativo");\
            \
            // Filtrar pela unidade do usuário logado\
            if ($user->unidade_id) {\
                $query->where("unidade_id", $user->unidade_id);\
            }\
            \
            $responsaveis = $query->select("id", "name", "email", "oab", "perfil")\
                                ->orderBy("name")\
                                ->get();\
            \
            return $this->success($responsaveis);\
            \
        } catch (\Exception $e) {\
            \Log::error("Erro ao buscar responsáveis: " . $e->getMessage());\
            return $this->error("Erro interno", 500);\
        }\
    }' app/Http/Controllers/Api/Admin/Clients/ClientController.php

# Limpar arquivo temporário
rm -f temp_method.txt

echo "3. Verificando se método success existe no Controller base..."

if ! grep -q "function success" app/Http/Controllers/Controller.php; then
    echo "Adicionando métodos success e error ao Controller base..."
    
    sed -i '/class Controller extends BaseController/a\\n    protected function success($data, $message = "Sucesso", $code = 200)\n    {\n        return response()->json([\n            "success" => true,\n            "message" => $message,\n            "data" => $data\n        ], $code);\n    }\n\n    protected function error($message = "Erro", $code = 400, $errors = null)\n    {\n        return response()->json([\n            "success" => false,\n            "message" => $message,\n            "errors" => $errors\n        ], $code);\n    }' app/Http/Controllers/Controller.php
fi

echo "4. Limpando cache..."
php artisan config:clear
php artisan route:clear

echo "5. Testando endpoint responsaveis..."

# Testar se o backend está rodando em outra porta
if curl -s http://localhost:8001/api/health > /dev/null 2>&1; then
    PORT=8001
elif curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    PORT=8000
else
    echo "Backend não está rodando. Inicie com: php artisan serve"
    exit 1
fi

echo "Testando em localhost:$PORT..."

# Fazer login
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:$PORT/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

# Extrair token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "Login OK, testando responsaveis..."
    RESP_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:$PORT/api/admin/clients/responsaveis)
    
    echo "Resultado:"
    echo $RESP_RESULT | head -3
else
    echo "Não conseguiu fazer login. Verifique credenciais."
fi

echo ""
echo "CORREÇÃO CONCLUÍDA!"
echo ""
echo "O método responsaveis() foi corrigido para usar o campo 'name' da tabela users"
echo ""
echo "Agora faça:"
echo "1. Recarregue a página do frontend (Ctrl+F5)"
echo "2. Acesse /admin/clientes/novo"
echo "3. O dropdown 'Responsável' deve funcionar"