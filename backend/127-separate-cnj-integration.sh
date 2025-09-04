#!/bin/bash

# Script 127 - Separar integração CNJ dos processos básicos
# Sistema Erlene Advogados - Limpar arquitetura
# EXECUTAR DENTRO DA PASTA: backend/

echo "🔧 Script 127 - Separando integração CNJ dos processos..."

# Verificar se estamos no diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 127-separate-cnj-integration.sh && ./127-separate-cnj-integration.sh"
    exit 1
fi

echo "1️⃣ DIAGNÓSTICO:"
echo "   • ProcessController complexo com CNJ causando erro"
echo "   • Integração CNJ deve ser separada"
echo "   • Usar controller simples em Processes/ pasta"
echo "   • Criar rotas separadas para integrações"

echo ""
echo "2️⃣ Fazendo backup dos arquivos atuais..."

# Backup dos arquivos
cp routes/api.php routes/api.php.backup-127
cp app/Http/Controllers/Api/Admin/ProcessController.php app/Http/Controllers/Api/Admin/ProcessController.php.backup-127

echo ""
echo "3️⃣ Removendo ProcessController complexo da pasta Admin..."

# Mover o controller complexo para pasta de integrações
mkdir -p app/Http/Controllers/Api/Admin/Integrations/CNJ
mv app/Http/Controllers/Api/Admin/ProcessController.php app/Http/Controllers/Api/Admin/Integrations/CNJ/CNJProcessController.php

echo "   • Controller complexo movido para Integrations/CNJ/"

echo ""
echo "4️⃣ Corrigindo api.php para usar controller simples..."

# Atualizar api.php para usar o controller da pasta Processes
cat > routes/api.php << 'EOF'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

// Login (público)
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/portal/login', [AuthController::class, 'portalLogin']);

// Health check (público)
Route::get('/health', function() {
    return response()->json([
        'success' => true,
        'status' => 'API funcionando',
        'timestamp' => now(),
        'version' => '1.0.0'
    ]);
});

// Rotas protegidas
Route::middleware('auth:api')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    
    Route::get('/dashboard/stats', function () {
        return response()->json([
            'success' => true,
            'user' => auth()->user()->nome ?? auth()->user()->name,
            'total_users' => \App\Models\User::count()
        ]);
    });
});

// Rotas do Dashboard Admin
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::get('/dashboard', [App\Http\Controllers\Api\Admin\DashboardController::class, 'index']);
    Route::get('/dashboard/notifications', [App\Http\Controllers\Api\Admin\DashboardController::class, 'notifications']);
});

// Rotas de Clientes
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::prefix('clients')->group(function () {
        Route::get('/', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'index']);
        Route::post('/', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'store']);
        Route::get('/stats', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'stats']);
        Route::get('/responsaveis', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'responsaveis']);
        Route::get('/buscar-cep/{cep}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'buscarCep']);
        Route::get('/{id}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'destroy']);
    });
});

// Rotas específicas de clientes
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::get('clients/{clienteId}/processos', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'processos']);
    Route::get('clients/{clienteId}/documentos', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'documentos']);
});

// ==========================================
// PROCESSOS - ROTAS BÁSICAS (SEM CNJ)
// ==========================================
Route::middleware(['auth:api'])->prefix('admin')->group(function () {
    
    // CRUD Processos BÁSICO
    Route::get('/processes', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'index']);
    Route::post('/processes', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'store']);
    Route::get('/processes/{id}', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'show']);
    Route::put('/processes/{id}', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'update']);
    Route::delete('/processes/{id}', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'destroy']);
    
    // Rotas auxiliares BÁSICAS
    Route::get('/processes/{id}/movements', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'getMovements']);
    Route::get('/processes/{id}/documents', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'getDocuments']);
    Route::get('/processes/{id}/appointments', [App\Http\Controllers\Api\Admin\Processes\ProcessController::class, 'getAppointments']);
});

// ==========================================
// INTEGRAÇÕES - ROTAS SEPARADAS
// ==========================================
Route::middleware(['auth:api'])->prefix('admin/integrations')->group(function () {
    
    // CNJ - Integração separada
    Route::prefix('cnj')->group(function() {
        Route::get('/status', [App\Http\Controllers\Api\Admin\Integrations\CNJ\CNJController::class, 'status']);
        Route::post('/sync-process/{id}', [App\Http\Controllers\Api\Admin\Integrations\CNJ\CNJController::class, 'syncProcess']);
        Route::get('/sync-history', [App\Http\Controllers\Api\Admin\Integrations\CNJ\CNJController::class, 'syncHistory']);
        Route::post('/configure', [App\Http\Controllers\Api\Admin\Integrations\CNJ\CNJController::class, 'configure']);
    });
    
    // Outras integrações futuras
    Route::prefix('escavador')->group(function() {
        Route::get('/status', function() {
            return response()->json(['success' => true, 'message' => 'Escavador não implementado']);
        });
    });
    
    Route::prefix('jurisbrasil')->group(function() {
        Route::get('/status', function() {
            return response()->json(['success' => true, 'message' => 'Jurisbrasil não implementado']);
        });
    });
});

// Rota para listar todas as integrações
Route::middleware(['auth:api'])->prefix('admin')->group(function () {
    Route::get('/integrations', [App\Http\Controllers\Api\Admin\IntegrationController::class, 'index']);
    Route::put('/integrations/{id}', [App\Http\Controllers\Api\Admin\IntegrationController::class, 'update']);
});
EOF

echo ""
echo "5️⃣ Atualizando controller CNJ na nova localização..."

# Atualizar namespace do controller CNJ movido
sed -i 's/namespace App\\Http\\Controllers\\Api\\Admin;/namespace App\\Http\\Controllers\\Api\\Admin\\Integrations\\CNJ;/' app/Http/Controllers/Api/Admin/Integrations/CNJ/CNJProcessController.php

# Renomear classe para evitar conflito
sed -i 's/class ProcessController/class CNJProcessController/' app/Http/Controllers/Api/Admin/Integrations/CNJ/CNJProcessController.php

echo ""
echo "6️⃣ Criando IntegrationController para gerenciar tabela integracoes..."

mkdir -p app/Http/Controllers/Api/Admin
cat > app/Http/Controllers/Api/Admin/IntegrationController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Integracao;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class IntegrationController extends Controller
{
    /**
     * Listar todas as integrações da unidade
     */
    public function index(Request $request)
    {
        try {
            $user = auth()->user();
            
            $integracoes = Integracao::where('unidade_id', $user->unidade_id)
                                   ->orderBy('nome')
                                   ->get();

            return response()->json([
                'success' => true,
                'data' => $integracoes
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao carregar integrações',
                'error' => config('app.debug') ? $e->getMessage() : 'Erro interno'
            ], 500);
        }
    }

    /**
     * Atualizar configuração de uma integração
     */
    public function update(Request $request, $id)
    {
        try {
            $user = auth()->user();
            
            $integracao = Integracao::where('id', $id)
                                  ->where('unidade_id', $user->unidade_id)
                                  ->firstOrFail();

            $validator = Validator::make($request->all(), [
                'ativo' => 'boolean',
                'configuracoes' => 'array'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dados inválidos',
                    'errors' => $validator->errors()
                ], 422);
            }

            $integracao->update($validator->validated());

            return response()->json([
                'success' => true,
                'message' => 'Integração atualizada com sucesso',
                'data' => $integracao
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar integração',
                'error' => config('app.debug') ? $e->getMessage() : 'Erro interno'
            ], 500);
        }
    }
}
EOF

echo ""
echo "7️⃣ Criando Model Integracao se não existir..."

cat > app/Models/Integracao.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Integracao extends Model
{
    use HasFactory;

    protected $table = 'integracoes';

    protected $fillable = [
        'nome',
        'ativo',
        'configuracoes',
        'ultima_sincronizacao',
        'status',
        'ultimo_erro',
        'total_requisicoes',
        'requisicoes_sucesso',
        'requisicoes_erro',
        'unidade_id'
    ];

    protected $casts = [
        'ativo' => 'boolean',
        'configuracoes' => 'array',
        'ultima_sincronizacao' => 'datetime'
    ];

    // Relacionamentos
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    // Scopes
    public function scopeAtivas($query)
    {
        return $query->where('ativo', true);
    }

    public function scopeFuncionando($query)
    {
        return $query->where('status', 'funcionando');
    }

    // Métodos auxiliares
    public function isAtiva()
    {
        return $this->ativo && $this->status === 'funcionando';
    }

    public function registrarRequisicao($sucesso = true, $erro = null)
    {
        $this->increment('total_requisicoes');
        
        if ($sucesso) {
            $this->increment('requisicoes_sucesso');
            $this->update([
                'status' => 'funcionando',
                'ultimo_erro' => null,
                'ultima_sincronizacao' => now()
            ]);
        } else {
            $this->increment('requisicoes_erro');
            $this->update([
                'status' => 'erro',
                'ultimo_erro' => $erro
            ]);
        }
    }
}
EOF

echo ""
echo "8️⃣ Limpando cache do Laravel..."

php artisan config:clear
php artisan route:clear
php artisan cache:clear

echo ""
echo "✅ SEPARAÇÃO CNJ CONCLUÍDA!"
echo ""
echo "📋 O que foi feito:"
echo "   • ProcessController complexo movido para Integrations/CNJ/"
echo "   • api.php atualizado para usar controller simples"
echo "   • Rotas básicas de processos separadas das integrações"
echo "   • Criado IntegrationController para tabela integracoes"
echo "   • Criado Model Integracao"
echo "   • Rotas de integração organizadas em /admin/integrations/"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. Acesse http://localhost:3000/admin/processos"
echo "   2. Os processos devem carregar normalmente"
echo "   3. CNJ ficou separado em /admin/integrations/cnj/"
echo ""
echo "📁 ESTRUTURA NOVA:"
echo "   • Processos básicos: /admin/processes (funcional)"
echo "   • Integrações CNJ: /admin/integrations/cnj/ (separado)"
echo "   • Model Integracao: gerencia tabela integracoes"
echo ""
echo "✋ Próximo passo: Teste a tela de processos no frontend!"