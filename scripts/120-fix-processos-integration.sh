#!/bin/bash

# Script 120 - Corrigir integração Processos Frontend-Backend
# Sistema Erlene Advogados - Correção específica tela Processos
# EXECUTAR DENTRO DA PASTA: backend/

echo "🔧 Script 120 - Corrigindo integração tela Processos..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 120-fix-processos-integration.sh && ./120-fix-processos-integration.sh"
    exit 1
fi

echo "1️⃣ Verificando se rota /api/admin/processes existe..."

# Verificar se rota existe nas rotas
grep -n "processes" routes/api.php || echo "❌ Rota processes não encontrada"

echo "2️⃣ Criando/Corrigindo ProcessController..."

# Criar diretório se não existe
mkdir -p app/Http/Controllers/Api/Admin/Processes

# Criar ProcessController corrigido
cat > app/Http/Controllers/Api/Admin/Processes/ProcessController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Processes;

use App\Http\Controllers\Controller;
use App\Models\Processo;
use App\Models\Cliente;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class ProcessController extends Controller
{
    /**
     * Lista todos os processos
     */
    public function index(Request $request)
    {
        try {
            Log::info('Iniciando listagem de processos', [
                'user_id' => auth()->id(),
                'params' => $request->all()
            ]);

            $query = Processo::with(['cliente', 'advogado']);
            
            // Filtros
            if ($request->filled('search')) {
                $search = $request->search;
                $query->where(function($q) use ($search) {
                    $q->where('numero', 'like', "%{$search}%")
                      ->orWhere('tipo_acao', 'like', "%{$search}%")
                      ->orWhere('tribunal', 'like', "%{$search}%")
                      ->orWhereHas('cliente', function($clienteQuery) use ($search) {
                          $clienteQuery->where('nome', 'like', "%{$search}%");
                      });
                });
            }

            if ($request->filled('status')) {
                $query->where('status', $request->status);
            }

            if ($request->filled('tribunal')) {
                $query->where('tribunal', $request->tribunal);
            }

            if ($request->filled('advogado_id')) {
                $query->where('advogado_id', $request->advogado_id);
            }

            // Ordenação
            $sortField = $request->get('sort', 'created_at');
            $sortDirection = $request->get('direction', 'desc');
            
            $query->orderBy($sortField, $sortDirection);

            // Paginação
            $perPage = $request->get('per_page', 15);
            $processes = $query->paginate($perPage);

            Log::info('Processos listados com sucesso', [
                'total' => $processes->total(),
                'per_page' => $perPage
            ]);

            return response()->json([
                'success' => true,
                'data' => $processes->items(),
                'meta' => [
                    'current_page' => $processes->currentPage(),
                    'last_page' => $processes->lastPage(),
                    'per_page' => $processes->perPage(),
                    'total' => $processes->total(),
                    'from' => $processes->firstItem(),
                    'to' => $processes->lastItem(),
                ],
                'links' => [
                    'first' => $processes->url(1),
                    'last' => $processes->url($processes->lastPage()),
                    'prev' => $processes->previousPageUrl(),
                    'next' => $processes->nextPageUrl(),
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Erro ao listar processos', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Criar novo processo
     */
    public function store(Request $request)
    {
        try {
            Log::info('Iniciando criação de processo', [
                'user_id' => auth()->id(),
                'data' => $request->all()
            ]);

            $validator = Validator::make($request->all(), [
                'numero' => 'required|string|unique:processos,numero',
                'cliente_id' => 'required|exists:clientes,id',
                'tipo_acao' => 'required|string|max:255',
                'tribunal' => 'required|string|max:100',
                'vara' => 'nullable|string|max:100',
                'advogado_id' => 'required|exists:users,id',
                'data_distribuicao' => 'required|date',
                'valor_causa' => 'nullable|string', // Aceita formato monetário
                'prioridade' => 'nullable|in:baixa,media,alta,urgente',
                'observacoes' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dados inválidos',
                    'errors' => $validator->errors()
                ], 422);
            }

            $data = $request->all();
            
            // Definir valores padrão
            $data['status'] = $data['status'] ?? 'em_andamento';
            $data['prioridade'] = $data['prioridade'] ?? 'media';
            
            // Converter valor da causa de string para decimal
            if (isset($data['valor_causa'])) {
                $data['valor_causa'] = $this->convertCurrencyToDecimal($data['valor_causa']);
            }

            $processo = Processo::create($data);
            $processo->load(['cliente', 'advogado']);

            Log::info('Processo criado com sucesso', [
                'processo_id' => $processo->id,
                'numero' => $processo->numero
            ]);

            return response()->json([
                'success' => true,
                'data' => $processo,
                'message' => 'Processo criado com sucesso'
            ], 201);

        } catch (\Exception $e) {
            Log::error('Erro ao criar processo', [
                'error' => $e->getMessage(),
                'data' => $request->all(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erro ao criar processo',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Exibir processo específico
     */
    public function show($id)
    {
        try {
            Log::info('Buscando processo específico', [
                'processo_id' => $id,
                'user_id' => auth()->id()
            ]);

            $processo = Processo::with(['cliente', 'advogado', 'movimentacoes'])
                               ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $processo
            ]);

        } catch (\Exception $e) {
            Log::error('Erro ao buscar processo', [
                'processo_id' => $id,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Processo não encontrado'
            ], 404);
        }
    }

    /**
     * Atualizar processo
     */
    public function update(Request $request, $id)
    {
        try {
            Log::info('Iniciando atualização de processo', [
                'processo_id' => $id,
                'user_id' => auth()->id(),
                'data' => $request->all()
            ]);

            $processo = Processo::findOrFail($id);

            $validator = Validator::make($request->all(), [
                'numero' => 'required|string|unique:processos,numero,' . $id,
                'cliente_id' => 'required|exists:clientes,id',
                'tipo_acao' => 'required|string|max:255',
                'tribunal' => 'required|string|max:100',
                'vara' => 'nullable|string|max:100',
                'advogado_id' => 'required|exists:users,id',
                'data_distribuicao' => 'required|date',
                'valor_causa' => 'nullable|string',
                'status' => 'nullable|in:em_andamento,suspenso,finalizado,arquivado',
                'prioridade' => 'nullable|in:baixa,media,alta,urgente',
                'observacoes' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dados inválidos',
                    'errors' => $validator->errors()
                ], 422);
            }

            $data = $request->all();
            
            // Converter valor da causa se presente
            if (isset($data['valor_causa'])) {
                $data['valor_causa'] = $this->convertCurrencyToDecimal($data['valor_causa']);
            }

            $processo->update($data);
            $processo->load(['cliente', 'advogado']);

            Log::info('Processo atualizado com sucesso', [
                'processo_id' => $processo->id
            ]);

            return response()->json([
                'success' => true,
                'data' => $processo,
                'message' => 'Processo atualizado com sucesso'
            ]);

        } catch (\Exception $e) {
            Log::error('Erro ao atualizar processo', [
                'processo_id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar processo',
                'error' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Excluir processo
     */
    public function destroy($id)
    {
        try {
            Log::info('Iniciando exclusão de processo', [
                'processo_id' => $id,
                'user_id' => auth()->id()
            ]);

            $processo = Processo::findOrFail($id);
            
            // Verificar se tem movimentações (pode ser regra de negócio)
            $movimentacoes = $processo->movimentacoes()->count();
            if ($movimentacoes > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Não é possível excluir processo com movimentações'
                ], 422);
            }

            $processo->delete();

            Log::info('Processo excluído com sucesso', [
                'processo_id' => $id
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Processo excluído com sucesso'
            ]);

        } catch (\Exception $e) {
            Log::error('Erro ao excluir processo', [
                'processo_id' => $id,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erro ao excluir processo'
            ], 500);
        }
    }

    /**
     * Obter movimentações de um processo
     */
    public function getMovements($id)
    {
        try {
            $processo = Processo::findOrFail($id);
            $movimentacoes = $processo->movimentacoes()
                                    ->orderBy('data', 'desc')
                                    ->paginate(20);

            return response()->json([
                'success' => true,
                'data' => $movimentacoes
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar movimentações'
            ], 500);
        }
    }

    /**
     * Obter documentos de um processo
     */
    public function getDocuments($id)
    {
        try {
            // Por enquanto retorna array vazio já que não temos documentos implementados
            return response()->json([
                'success' => true,
                'data' => [
                    'data' => [],
                    'total' => 0
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar documentos'
            ], 500);
        }
    }

    /**
     * Obter atendimentos de um processo
     */
    public function getAppointments($id)
    {
        try {
            // Por enquanto retorna array vazio já que não temos atendimentos implementados
            return response()->json([
                'success' => true,
                'data' => [
                    'data' => [],
                    'total' => 0
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar atendimentos'
            ], 500);
        }
    }

    /**
     * Sincronizar com CNJ (mock por enquanto)
     */
    public function syncWithCNJ($id)
    {
        try {
            $processo = Processo::findOrFail($id);
            
            // Mock de sincronização CNJ
            return response()->json([
                'success' => true,
                'data' => [
                    'novas_movimentacoes' => 0,
                    'ultima_sincronizacao' => now()
                ],
                'message' => 'Sincronização CNJ simulada com sucesso'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro na sincronização CNJ'
            ], 500);
        }
    }

    /**
     * Converter valor monetário para decimal
     */
    private function convertCurrencyToDecimal($value)
    {
        if (empty($value)) {
            return null;
        }

        // Remover caracteres não numéricos exceto vírgula e ponto
        $value = preg_replace('/[^\d,.-]/', '', $value);
        
        // Substituir vírgula por ponto
        $value = str_replace(',', '.', $value);
        
        return floatval($value);
    }
}
EOF

echo "3️⃣ Corrigindo rotas da API..."

# Verificar e criar arquivo de rotas se necessário
if [ ! -f "routes/api.php" ]; then
    echo "Criando arquivo de rotas API..."
    
    cat > routes/api.php << 'EOF'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Api\Admin\Processes\ProcessController;
use App\Http\Controllers\Api\Admin\Clients\ClientController;

/*
|--------------------------------------------------------------------------
| API Routes  
|--------------------------------------------------------------------------
*/

// Rota de teste/saúde
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now(),
        'service' => 'Sistema Erlene Advogados API'
    ]);
});

// Rotas de Autenticação
Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:api');
    Route::post('refresh', [AuthController::class, 'refresh'])->middleware('auth:api');
    Route::get('me', [AuthController::class, 'me'])->middleware('auth:api');
});

// Rotas Administrativas (Protegidas)
Route::prefix('admin')->middleware(['auth:api'])->group(function () {
    
    // Processos
    Route::prefix('processes')->group(function () {
        Route::get('/', [ProcessController::class, 'index']);
        Route::post('/', [ProcessController::class, 'store']);
        Route::get('{id}', [ProcessController::class, 'show']);
        Route::put('{id}', [ProcessController::class, 'update']);
        Route::delete('{id}', [ProcessController::class, 'destroy']);
        Route::get('{id}/movements', [ProcessController::class, 'getMovements']);
        Route::get('{id}/documents', [ProcessController::class, 'getDocuments']);
        Route::get('{id}/appointments', [ProcessController::class, 'getAppointments']);
        Route::post('{id}/sync-cnj', [ProcessController::class, 'syncWithCNJ']);
    });
    
    // Clientes (básico para selects)
    Route::prefix('clients')->group(function () {
        Route::get('/', [ClientController::class, 'index']);
        Route::get('for-select', [ClientController::class, 'getClientsForSelect']);
    });
    
});

// Fallback para rotas não encontradas
Route::fallback(function(){
    return response()->json([
        'success' => false,
        'message' => 'Rota não encontrada'
    ], 404);
});
EOF

else
    echo "Arquivo de rotas existe, verificando se rota de processos está presente..."
    
    # Adicionar rotas de processos se não existirem
    if ! grep -q "processes" routes/api.php; then
        echo "Adicionando rotas de processos ao arquivo existente..."
        
        # Backup do arquivo atual
        cp routes/api.php routes/api.php.backup
        
        # Adicionar import se não existe
        if ! grep -q "ProcessController" routes/api.php; then
            sed -i '2a use App\Http\Controllers\Api\Admin\Processes\ProcessController;' routes/api.php
        fi
        
        # Procurar seção admin e adicionar rotas de processos
        if grep -q "Route::prefix('admin')" routes/api.php; then
            # Adicionar após linha do admin prefix
            sed -i "/Route::prefix('admin')/a\\    \\n    // Processos\\n    Route::prefix('processes')->group(function () {\\n        Route::get('/', [ProcessController::class, 'index']);\\n        Route::post('/', [ProcessController::class, 'store']);\\n        Route::get('{id}', [ProcessController::class, 'show']);\\n        Route::put('{id}', [ProcessController::class, 'update']);\\n        Route::delete('{id}', [ProcessController::class, 'destroy']);\\n        Route::get('{id}/movements', [ProcessController::class, 'getMovements']);\\n        Route::get('{id}/documents', [ProcessController::class, 'getDocuments']);\\n        Route::get('{id}/appointments', [ProcessController::class, 'getAppointments']);\\n        Route::post('{id}/sync-cnj', [ProcessController::class, 'syncWithCNJ']);\\n    });" routes/api.php
        fi
    fi
fi

echo "4️⃣ Verificando Model Processo..."

# Criar model básico se não existe
if [ ! -f "app/Models/Processo.php" ]; then
    echo "Criando Model Processo..."
    
    mkdir -p app/Models
    
    cat > app/Models/Processo.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Processo extends Model
{
    use HasFactory;

    protected $table = 'processos';

    protected $fillable = [
        'numero',
        'cliente_id', 
        'tipo_acao',
        'tribunal',
        'vara',
        'valor_causa',
        'status',
        'advogado_id',
        'prioridade',
        'data_distribuicao',
        'observacoes',
        'precisa_sincronizar_cnj',
        'metadata_cnj'
    ];

    protected $casts = [
        'data_distribuicao' => 'date',
        'valor_causa' => 'decimal:2',
        'precisa_sincronizar_cnj' => 'boolean',
        'metadata_cnj' => 'array'
    ];

    // Relacionamentos
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function advogado()
    {
        return $this->belongsTo(User::class, 'advogado_id');
    }

    public function movimentacoes()
    {
        return $this->hasMany(Movimentacao::class);
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->where('status', '!=', 'arquivado');
    }

    public function scopePorTribunal($query, $tribunal)
    {
        return $query->where('tribunal', $tribunal);
    }

    // Métodos auxiliares
    public function marcarComoSincronizado($metadata = [])
    {
        $this->update([
            'precisa_sincronizar_cnj' => false,
            'metadata_cnj' => $metadata
        ]);
    }

    public function atualizarStatusPorMovimentacao($descricao)
    {
        // Lógica para atualizar status baseado na movimentação
        // Por enquanto mantém o status atual
    }

    // Accessors
    public function getStatusLabelAttribute()
    {
        $labels = [
            'em_andamento' => 'Em Andamento',
            'suspenso' => 'Suspenso', 
            'finalizado' => 'Finalizado',
            'arquivado' => 'Arquivado'
        ];

        return $labels[$this->status] ?? 'Status Desconhecido';
    }

    public function getPrioridadeLabelAttribute()
    {
        $labels = [
            'baixa' => 'Baixa',
            'media' => 'Média',
            'alta' => 'Alta',
            'urgente' => 'Urgente'
        ];

        return $labels[$this->prioridade] ?? 'Média';
    }
}
EOF
fi

echo "5️⃣ Verificando Model Cliente..."

if [ ! -f "app/Models/Cliente.php" ]; then
    echo "Criando Model Cliente..."
    
    cat > app/Models/Cliente.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Cliente extends Model
{
    use HasFactory;

    protected $table = 'clientes';

    protected $fillable = [
        'nome',
        'tipo_pessoa',
        'cpf_cnpj',
        'email',
        'telefone',
        'endereco',
        'ativo'
    ];

    protected $casts = [
        'ativo' => 'boolean'
    ];

    // Relacionamentos
    public function processos()
    {
        return $this->hasMany(Processo::class);
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->where('ativo', true);
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo_pessoa', $tipo);
    }
}
EOF
fi

echo "6️⃣ Verificando Model Movimentacao..."

if [ ! -f "app/Models/Movimentacao.php" ]; then
    echo "Criando Model Movimentacao..."
    
    cat > app/Models/Movimentacao.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Movimentacao extends Model
{
    use HasFactory;

    protected $table = 'movimentacoes';

    protected $fillable = [
        'processo_id',
        'data',
        'descricao',
        'tipo',
        'metadata'
    ];

    protected $casts = [
        'data' => 'datetime',
        'metadata' => 'array'
    ];

    // Relacionamentos
    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }
}
EOF
fi

echo "7️⃣ Verificando Controller de Clientes para selects..."

# Criar controller básico de clientes se não existe
if [ ! -f "app/Http/Controllers/Api/Admin/Clients/ClientController.php" ]; then
    echo "Criando ClientController básico..."
    
    mkdir -p app/Http/Controllers/Api/Admin/Clients
    
    cat > app/Http/Controllers/Api/Admin/Clients/ClientController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Clients;

use App\Http\Controllers\Controller;
use App\Models\Cliente;

class ClientController extends Controller
{
    public function index()
    {
        $clientes = Cliente::ativos()->paginate(15);
        
        return response()->json([
            'success' => true,
            'data' => $clientes
        ]);
    }

    public function getClientsForSelect()
    {
        $clientes = Cliente::ativos()
                          ->select('id', 'nome', 'tipo_pessoa', 'cpf_cnpj')
                          ->orderBy('nome')
                          ->get();
        
        return response()->json([
            'success' => true,
            'data' => $clientes
        ]);
    }
}
EOF
fi

echo "8️⃣ Limpando cache e testando rota..."

# Limpar caches
php artisan config:clear
php artisan route:clear
php artisan cache:clear

# Verificar se tabela processos existe
echo "Verificando tabela processos..."
php artisan tinker --execute="
try {
    echo 'Processos na tabela: ' . App\Models\Processo::count();
} catch (Exception \$e) {
    echo 'Erro: ' . \$e->getMessage();
    echo PHP_EOL . 'Executar: php artisan migrate';
}
"

echo "9️⃣ Testando endpoint diretamente..."

# Iniciar servidor temporário para teste
php artisan serve --port=8001 --host=127.0.0.1 > /dev/null 2>&1 &
SERVER_PID=$!

# Aguardar servidor iniciar
sleep 3

echo "Testando rota de saúde:"
curl -s http://127.0.0.1:8001/api/health | head -3

echo ""
echo "Testando rota de processos (deve dar 401 sem token):"
curl -s http://127.0.0.1:8001/api/admin/processes | head -3

# Parar servidor
kill $SERVER_PID 2>/dev/null

echo ""
echo "✅ CORREÇÕES APLICADAS!"
echo ""
echo "🔍 O que foi corrigido:"
echo "   • ProcessController criado/corrigido com logs detalhados"
echo "   • Rotas de processos adicionadas/verificadas"
echo "   • Models básicos criados (Processo, Cliente, Movimentacao)"
echo "   • ClientController para selects de clientes"
echo "   • Cache limpo"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. Certifique-se que o backend está rodando: php artisan serve"
echo "   2. Acesse http://localhost:3000/admin/processos"
echo "   3. Verifique o console do navegador para erros específicos"
echo "   4. Verifique logs: tail -f storage/logs/laravel.log"
echo ""
echo "💡 Se ainda houver erro 401:"
echo "   • Verificar se usuário está logado"
echo "   • Token JWT válido no localStorage"
echo "   • Middleware auth:api funcionando"
echo ""
echo "💡 Se erro 500:"
echo "   • Verificar logs do Laravel"
echo "   • Executar migrations se necessário"
echo "   • Verificar conexão com banco de dados"