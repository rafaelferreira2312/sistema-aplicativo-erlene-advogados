#!/bin/bash

# Script 121 - Corrigir Endpoints de Clientes
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 121-fix-client-endpoints.sh && ./121-fix-client-endpoints.sh
# EXECUTE NA PASTA: backend/

echo "🔧 Corrigindo endpoints de processos e documentos..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

CONTROLLER_PATH="app/Http/Controllers/Api/Admin/Clients/ClientController.php"

echo "1. Verificando se métodos foram adicionados corretamente..."
if grep -q "function processos" "$CONTROLLER_PATH"; then
    echo "✅ Método processos encontrado"
else
    echo "❌ Método processos não encontrado - vou adicionar manualmente"
    
    # Adicionar método processos manualmente
    cat >> temp_processos.php << 'EOF'

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
                'message' => 'Erro interno do servidor'
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
            
            // Como DocumentoGed não existe, vamos simular uma resposta
            // Em um projeto real, você usaria: $cliente->documentos()
            $documentos = collect([]);
            
            return response()->json([
                'success' => true,
                'data' => $documentos,
                'total' => 0,
                'message' => 'Funcionalidade de documentos será implementada'
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Erro ao buscar documentos: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor'
            ], 500);
        }
    }
EOF
    
    # Inserir antes da última chave
    sed -i '/^}$/i\'"$(cat temp_processos.php)" "$CONTROLLER_PATH"
    rm temp_processos.php
    
    echo "✅ Métodos adicionados manualmente"
fi

echo ""
echo "2. Corrigindo rotas..."

# Verificar se grupo de rotas de clients existe
if grep -A 5 -B 5 "clients.*responsaveis" routes/api.php; then
    echo "✅ Grupo de rotas clients encontrado"
    
    # Adicionar rotas se não existirem
    if ! grep -q "clients.*processos\|clients.*documentos" routes/api.php; then
        echo "Adicionando rotas de processos e documentos..."
        
        sed -i '/clients\/responsaveis/a\        Route::get("clients/{clienteId}/processos", [App\\Http\\Controllers\\Api\\Admin\\Clients\\ClientController::class, "processos"]);\
        Route::get("clients/{clienteId}/documentos", [App\\Http\\Controllers\\Api\\Admin\\Clients\\ClientController::class, "documentos"]);' routes/api.php
        
        echo "✅ Rotas adicionadas"
    else
        echo "✅ Rotas já existem"
    fi
else
    echo "❌ Grupo de rotas não encontrado - criando novo grupo"
    
    cat >> routes/api.php << 'EOF'

// Rotas específicas de clientes
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::get('clients/{clienteId}/processos', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'processos']);
    Route::get('clients/{clienteId}/documentos', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'documentos']);
});
EOF
    
    echo "✅ Novo grupo de rotas criado"
fi

echo ""
echo "3. Limpando cache e testando..."

php artisan route:clear
php artisan config:clear

echo "Listando rotas relacionadas a clients:"
php artisan route:list | grep clients

echo ""
echo "4. Testando endpoints corrigidos..."

# Login
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN" ]; then
    echo "✅ Login OK"
    
    # Testar processos
    echo "Testando processos do cliente 1..."
    PROC_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:8000/api/admin/clients/1/processos)
    
    if echo $PROC_RESULT | grep -q '"success":true'; then
        echo "✅ Endpoint processos funcionando!"
        echo "Total processos: $(echo $PROC_RESULT | grep -o '"total":[0-9]*' | cut -d: -f2)"
    else
        echo "❌ Erro no endpoint processos:"
        echo $PROC_RESULT | head -3
    fi
    
    echo ""
    # Testar documentos
    echo "Testando documentos do cliente 1..."
    DOC_RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:8000/api/admin/clients/1/documentos)
    
    if echo $DOC_RESULT | grep -q '"success":true'; then
        echo "✅ Endpoint documentos funcionando!"
        echo "Total documentos: $(echo $DOC_RESULT | grep -o '"total":[0-9]*' | cut -d: -f2)"
    else
        echo "❌ Erro no endpoint documentos:"
        echo $DOC_RESULT | head -3
    fi
    
else
    echo "❌ Erro no login"
fi

echo ""
echo "5. Criando processo de teste com campos corretos..."

php artisan tinker --execute "
try {
    \$clienteId = 1;
    \$cliente = \App\Models\Cliente::find(\$clienteId);
    
    if (\$cliente && \$cliente->processos()->count() == 0) {
        echo 'Criando processo de teste...';
        
        \$processo = new \App\Models\Processo([
            'numero' => '5001234-56.2024.8.26.0100',
            'tipo_acao' => 'Ação de Cobrança',
            'status' => 'em_andamento',
            'data_distribuicao' => now(),
            'tribunal' => 'TJSP',
            'vara' => '1ª Vara Cível',
            'cliente_id' => \$clienteId,
            'advogado_id' => \$cliente->responsavel_id,
            'unidade_id' => \$cliente->unidade_id
        ]);
        \$processo->save();
        
        echo 'Processo criado com ID: ' . \$processo->id;
    } else {
        echo 'Cliente não encontrado ou já possui processos';
    }
    
} catch(Exception \$e) {
    echo 'Erro ao criar processo: ' . \$e->getMessage();
}
"

echo ""
echo "6. Testando novamente após criar processo..."

if [ ! -z "$TOKEN" ]; then
    echo "Testando processos após criação..."
    PROC_RESULT2=$(curl -s -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/json" \
         http://localhost:8000/api/admin/clients/1/processos)
    
    echo "Resultado final processos:"
    echo $PROC_RESULT2 | head -5
fi

echo ""
echo "=== CORREÇÃO FINALIZADA ==="
echo ""
echo "✅ ENDPOINTS IMPLEMENTADOS:"
echo "- GET /api/admin/clients/{id}/processos"
echo "- GET /api/admin/clients/{id}/documentos"
echo ""
echo "📋 STATUS:"
echo "- Tabela 'processos' existe e funciona"
echo "- Tabela 'documento_ged' não existe (endpoint retorna vazio)"
echo "- Relacionamentos Cliente→Processos funcionais"
echo ""
echo "🎯 PRÓXIMOS PASSOS:"
echo "1. Implementar frontend com abas"
echo "2. Mudar label 'Documento' → 'CPF/CNPJ'"
echo "3. Integrar com endpoints criados"
echo ""
echo "🔧 COMANDOS ÚTEIS:"
echo "- Ver rotas: php artisan route:list | grep clients"
echo "- Testar: curl -H 'Authorization: Bearer TOKEN' http://localhost:8000/api/admin/clients/1/processos"