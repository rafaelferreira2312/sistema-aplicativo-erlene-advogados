#!/bin/bash

# Script 122 - Adicionar Métodos Diretamente no Controller
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 122-add-methods-directly.sh && ./122-add-methods-directly.sh
# EXECUTE NA PASTA: backend/

echo "🔧 Adicionando métodos diretamente no controller..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

CONTROLLER_PATH="app/Http/Controllers/Api/Admin/Clients/ClientController.php"

echo "1. Verificando controller atual..."
echo "Tamanho do arquivo: $(wc -l < "$CONTROLLER_PATH") linhas"

# Verificar se métodos já existem
if grep -q "function processos\|function documentos" "$CONTROLLER_PATH"; then
    echo "⚠️  Métodos já existem (mas não funcionam) - vou recriar"
else
    echo "❌ Métodos não encontrados"
fi

echo ""
echo "2. Fazendo backup..."
cp "$CONTROLLER_PATH" "${CONTROLLER_PATH}.backup-$(date +%Y%m%d-%H%M%S)"

echo ""
echo "3. Adicionando métodos usando abordagem diferente..."

# Criar arquivo temporário com os métodos
cat > temp_new_methods.php << 'EOF'

    /**
     * Obter processos do cliente
     */
    public function processos($clienteId)
    {
        try {
            $user = auth()->user();
            
            $cliente = Cliente::where('id', $clienteId)
                             ->where('unidade_id', $user->unidade_id)
                             ->first();
            
            if (!$cliente) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cliente não encontrado'
                ], 404);
            }
            
            $processos = $cliente->processos()
                               ->select('id', 'numero', 'tipo_acao', 'status', 'data_distribuicao', 'tribunal', 'vara')
                               ->orderBy('created_at', 'desc')
                               ->get();
            
            return response()->json([
                'success' => true,
                'data' => $processos,
                'total' => $processos->count()
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Erro ao buscar processos: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Obter documentos do cliente  
     */
    public function documentos($clienteId)
    {
        try {
            $user = auth()->user();
            
            $cliente = Cliente::where('id', $clienteId)
                             ->where('unidade_id', $user->unidade_id)
                             ->first();
            
            if (!$cliente) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cliente não encontrado'
                ], 404);
            }
            
            // Simulação pois DocumentoGed não existe
            $documentos = collect([
                [
                    'id' => 1,
                    'nome' => 'RG - Frente e Verso.pdf',
                    'tipo' => 'identidade',
                    'tamanho' => '2.1 MB',
                    'created_at' => now()->format('d/m/Y H:i')
                ],
                [
                    'id' => 2,
                    'nome' => 'Comprovante de Residência.pdf',
                    'tipo' => 'comprovante_residencia',
                    'tamanho' => '856 KB',
                    'created_at' => now()->subDays(5)->format('d/m/Y H:i')
                ]
            ]);
            
            return response()->json([
                'success' => true,
                'data' => $documentos,
                'total' => $documentos->count(),
                'message' => 'Dados de exemplo (DocumentoGed não existe)'
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Erro ao buscar documentos: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor',
                'error' => $e->getMessage()
            ], 500);
        }
    }
EOF

# Encontrar a última chave } e inserir antes dela
# Primeiro, criar uma versão sem a última linha
head -n -1 "$CONTROLLER_PATH" > temp_controller.php

# Adicionar os métodos
cat temp_new_methods.php >> temp_controller.php

# Adicionar a chave de fechamento
echo "}" >> temp_controller.php

# Substituir o arquivo original
mv temp_controller.php "$CONTROLLER_PATH"
rm temp_new_methods.php

echo "✅ Métodos adicionados usando substituição completa"

echo ""
echo "4. Verificando se métodos foram adicionados..."
if grep -q "function processos" "$CONTROLLER_PATH"; then
    echo "✅ Método processos() encontrado"
else
    echo "❌ Método processos() ainda não encontrado"
fi

if grep -q "function documentos" "$CONTROLLER_PATH"; then
    echo "✅ Método documentos() encontrado"
else
    echo "❌ Método documentos() ainda não encontrado"
fi

echo "Novo tamanho do arquivo: $(wc -l < "$CONTROLLER_PATH") linhas"

echo ""
echo "5. Verificando sintaxe PHP..."
if php -l "$CONTROLLER_PATH" > /dev/null 2>&1; then
    echo "✅ Sintaxe PHP válida"
else
    echo "❌ Erro de sintaxe PHP:"
    php -l "$CONTROLLER_PATH"
fi

echo ""
echo "6. Testando endpoints..."

# Limpar cache
php artisan config:clear
php artisan route:clear

# Login
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "✅ Login OK"
    
    # Testar processos
    echo "Testando processos..."
    PROC_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:8000/api/admin/clients/1/processos)
    
    if echo $PROC_RESULT | grep -q '"success":true'; then
        echo "✅ Endpoint processos funcionando!"
        echo "Processos encontrados: $(echo $PROC_RESULT | grep -o '"total":[0-9]*' | cut -d: -f2)"
    else
        echo "❌ Erro no endpoint processos:"
        echo $PROC_RESULT | head -3
    fi
    
    echo ""
    # Testar documentos
    echo "Testando documentos..."
    DOC_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:8000/api/admin/clients/1/documentos)
    
    if echo $DOC_RESULT | grep -q '"success":true'; then
        echo "✅ Endpoint documentos funcionando!"
        echo "Documentos encontrados: $(echo $DOC_RESULT | grep -o '"total":[0-9]*' | cut -d: -f2)"
    else
        echo "❌ Erro no endpoint documentos:"
        echo $DOC_RESULT | head -3
    fi
    
else
    echo "❌ Erro no login"
fi

echo ""
echo "7. Mostrando últimas linhas do controller..."
echo "Últimas 20 linhas do controller:"
tail -20 "$CONTROLLER_PATH"

echo ""
echo "=== RESULTADO FINAL ==="
echo ""
if grep -q "function processos\|function documentos" "$CONTROLLER_PATH"; then
    echo "✅ MÉTODOS ADICIONADOS COM SUCESSO"
    echo "- processos(): Busca processos do cliente"
    echo "- documentos(): Retorna dados de exemplo"
else
    echo "❌ MÉTODOS AINDA NÃO FORAM ADICIONADOS"
fi

echo ""
echo "📋 ENDPOINTS DISPONÍVEIS:"
echo "- GET /api/admin/clients/{id}/processos"
echo "- GET /api/admin/clients/{id}/documentos"
echo ""
echo "🎯 PRÓXIMO PASSO:"
echo "Se os endpoints funcionaram, podemos partir para o frontend!"
echo ""
echo "🔧 TESTE MANUAL:"
echo "curl -H 'Authorization: Bearer $TOKEN' http://localhost:8000/api/admin/clients/1/processos"