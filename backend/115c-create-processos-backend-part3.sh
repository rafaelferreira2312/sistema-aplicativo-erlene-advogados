#!/bin/bash

# Script 115c - Criar Backend PROCESSOS - Parte 3 (Rotas e Configurações)
# Sistema Erlene Advogados - Implementação funcionalidade PROCESSOS
# Execução: chmod +x 115c-create-processos-backend-part3.sh && ./115c-create-processos-backend-part3.sh
# EXECUTAR DENTRO DA PASTA: backend/

echo "🚀 Script 115c - Implementando Backend PROCESSOS (Parte 3)..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 115c-create-processos-backend-part3.sh && ./115c-create-processos-backend-part3.sh"
    exit 1
fi

echo "1️⃣ Atualizando rotas API para processos..."

# Backup das rotas existentes
cp routes/api.php routes/api.php.backup

# Adicionar rotas de processos nas rotas existentes
cat >> routes/api.php << 'EOF'

// Rotas de Processos - Sistema Erlene Advogados
Route::middleware(['auth:api'])->prefix('admin')->group(function () {
    
    // CRUD Processos
    Route::get('/processes', [App\Http\Controllers\Api\Admin\ProcessController::class, 'index']);
    Route::post('/processes', [App\Http\Controllers\Api\Admin\ProcessController::class, 'store']);
    Route::get('/processes/{id}', [App\Http\Controllers\Api\Admin\ProcessController::class, 'show']);
    Route::put('/processes/{id}', [App\Http\Controllers\Api\Admin\ProcessController::class, 'update']);
    Route::delete('/processes/{id}', [App\Http\Controllers\Api\Admin\ProcessController::class, 'destroy']);
    
    // Sincronização CNJ
    Route::post('/processes/{id}/sync-cnj', [App\Http\Controllers\Api\Admin\ProcessController::class, 'syncWithCNJ']);
    
    // Rotas auxiliares para processos
    Route::get('/processes/{id}/movements', [App\Http\Controllers\Api\Admin\ProcessController::class, 'getMovements']);
    Route::post('/processes/{id}/movements', [App\Http\Controllers\Api\Admin\ProcessController::class, 'addMovement']);
    Route::get('/processes/{id}/documents', [App\Http\Controllers\Api\Admin\ProcessController::class, 'getDocuments']);
    Route::get('/processes/{id}/appointments', [App\Http\Controllers\Api\Admin\ProcessController::class, 'getAppointments']);
});
EOF

echo "2️⃣ Criando configuração de serviços CNJ..."

# Criar configuração CNJ
cat > config/services.php << 'EOF'
<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this configuration.
    |
    */

    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
        'endpoint' => env('MAILGUN_ENDPOINT', 'api.mailgun.net'),
        'scheme' => 'https',
    ],

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    // Integração CNJ DataJud
    'cnj' => [
        'api_key' => env('CNJ_API_KEY'),
        'base_url' => env('CNJ_BASE_URL', 'https://api-publica.datajud.cnj.jus.br'),
        'timeout' => env('CNJ_TIMEOUT', 30),
        'enabled' => env('CNJ_ENABLED', false),
    ],

    // Outras integrações jurídicas
    'escavador' => [
        'api_key' => env('ESCAVADOR_API_KEY'),
        'base_url' => env('ESCAVADOR_BASE_URL', 'https://api.escavador.com'),
        'enabled' => env('ESCAVADOR_ENABLED', false),
    ],

    'jurisbrasil' => [
        'api_key' => env('JURISBRASIL_API_KEY'),
        'base_url' => env('JURISBRASIL_BASE_URL', 'https://api.jurisbrasil.com.br'),
        'enabled' => env('JURISBRASIL_ENABLED', false),
    ],

];
EOF

echo "3️⃣ Adicionando métodos auxiliares ao ProcessController..."

# Adicionar métodos auxiliares ao controller
cat >> app/Http/Controllers/Api/Admin/ProcessController.php << 'EOF'

    /**
     * Obter movimentações do processo
     */
    public function getMovements($id): JsonResponse
    {
        $processo = Processo::porUnidade(auth()->user()->unidade_id)->findOrFail($id);

        $movimentacoes = $processo->movimentacoes()
                                 ->orderBy('data', 'desc')
                                 ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $movimentacoes
        ]);
    }

    /**
     * Adicionar nova movimentação
     */
    public function addMovement(Request $request, $id): JsonResponse
    {
        $processo = Processo::porUnidade(auth()->user()->unidade_id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'descricao' => 'required|string|max:1000',
            'documento_url' => 'nullable|url'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $movimentacao = $processo->adicionarMovimentacao(
            $request->descricao,
            'manual',
            $request->documento_url,
            ['usuario_id' => auth()->id()]
        );

        return response()->json([
            'success' => true,
            'message' => 'Movimentação adicionada com sucesso',
            'data' => $movimentacao
        ], 201);
    }

    /**
     * Obter documentos do processo
     */
    public function getDocuments($id): JsonResponse
    {
        $processo = Processo::porUnidade(auth()->user()->unidade_id)->findOrFail($id);

        $documentos = $processo->documentos()
                              ->orderBy('created_at', 'desc')
                              ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $documentos
        ]);
    }

    /**
     * Obter atendimentos do processo
     */
    public function getAppointments($id): JsonResponse
    {
        $processo = Processo::porUnidade(auth()->user()->unidade_id)->findOrFail($id);

        $atendimentos = $processo->atendimentos()
                                ->with(['cliente', 'responsavel'])
                                ->orderBy('data_hora', 'desc')
                                ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $atendimentos
        ]);
    }

    /**
     * Dashboard de processos - estatísticas
     */
    public function dashboard(): JsonResponse
    {
        $unidadeId = auth()->user()->unidade_id;

        $stats = [
            'total_processos' => Processo::porUnidade($unidadeId)->count(),
            'processos_ativos' => Processo::porUnidade($unidadeId)->ativos()->count(),
            'processos_vencidos' => Processo::porUnidade($unidadeId)->vencidos()->count(),
            'processos_vencendo' => Processo::porUnidade($unidadeId)->comPrazoVencendo(7)->count(),
            'por_status' => Processo::porUnidade($unidadeId)
                                  ->selectRaw('status, count(*) as total')
                                  ->groupBy('status')
                                  ->pluck('total', 'status'),
            'por_prioridade' => Processo::porUnidade($unidadeId)
                                      ->selectRaw('prioridade, count(*) as total')
                                      ->groupBy('prioridade')
                                      ->pluck('total', 'prioridade'),
            'valor_total_causas' => Processo::porUnidade($unidadeId)
                                          ->sum('valor_causa')
        ];

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    /**
     * Sincronização em lote com CNJ
     */
    public function batchSyncCNJ(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'processo_ids' => 'required|array|min:1',
            'processo_ids.*' => 'exists:processos,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'IDs de processos inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $processos = Processo::porUnidade(auth()->user()->unidade_id)
                            ->whereIn('id', $request->processo_ids)
                            ->get();

        $resultados = [];
        $sucessos = 0;
        $erros = 0;

        foreach ($processos as $processo) {
            try {
                $resultado = $this->sincronizarComCNJ($processo);
                $resultados[] = [
                    'processo_id' => $processo->id,
                    'numero_processo' => $processo->numero,
                    'status' => 'sucesso',
                    'novas_movimentacoes' => $resultado['novas_movimentacoes'] ?? 0
                ];
                $sucessos++;
            } catch (\Exception $e) {
                $resultados[] = [
                    'processo_id' => $processo->id,
                    'numero_processo' => $processo->numero,
                    'status' => 'erro',
                    'erro' => $e->getMessage()
                ];
                $erros++;
            }
        }

        return response()->json([
            'success' => true,
            'message' => "Sincronização concluída: {$sucessos} sucessos, {$erros} erros",
            'data' => [
                'total_processos' => count($processos),
                'sucessos' => $sucessos,
                'erros' => $erros,
                'detalhes' => $resultados
            ]
        ]);
    }
}
EOF

echo "4️⃣ Criando middleware para validação de processos..."

mkdir -p app/Http/Middleware

cat > app/Http/Middleware/ValidateProcessAccess.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\Processo;

class ValidateProcessAccess
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        $user = auth()->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Usuário não autenticado'
            ], 401);
        }

        // Verificar se está acessando um processo específico
        $processoId = $request->route('id');
        
        if ($processoId) {
            $processo = Processo::find($processoId);
            
            if (!$processo) {
                return response()->json([
                    'success' => false,
                    'message' => 'Processo não encontrado'
                ], 404);
            }

            // Verificar se o processo pertence à unidade do usuário
            if ($processo->unidade_id !== $user->unidade_id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Acesso negado a este processo'
                ], 403);
            }
        }

        return $next($request);
    }
}
EOF

echo "5️⃣ Registrando middleware no Kernel..."

# Adicionar middleware ao Kernel (se não existir)
if ! grep -q "ValidateProcessAccess" app/Http/Kernel.php; then
    sed -i "/protected \$routeMiddleware = \[/a\\        'process.access' => \\App\\Http\\Middleware\\ValidateProcessAccess::class," app/Http/Kernel.php
fi

echo "6️⃣ Atualizando arquivo .env.example com configurações CNJ..."

cat >> .env.example << 'EOF'

# Integração CNJ DataJud
CNJ_ENABLED=false
CNJ_API_KEY=your_cnj_api_key_here
CNJ_BASE_URL=https://api-publica.datajud.cnj.jus.br
CNJ_TIMEOUT=30

# Outras integrações jurídicas
ESCAVADOR_ENABLED=false
ESCAVADOR_API_KEY=
ESCAVADOR_BASE_URL=https://api.escavador.com

JURISBRASIL_ENABLED=false
JURISBRASIL_API_KEY=
JURISBRASIL_BASE_URL=https://api.jurisbrasil.com.br
EOF

echo "7️⃣ Registrando service provider se necessário..."

# Criar service provider para CNJ se não existir
if [ ! -f "app/Providers/CNJServiceProvider.php" ]; then
    cat > app/Providers/CNJServiceProvider.php << 'EOF'
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\Integration\CNJService;

class CNJServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        $this->app->singleton(CNJService::class, function ($app) {
            return new CNJService();
        });
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
EOF
fi

echo "8️⃣ Executando migrations se necessário..."

# Verificar se migrations precisam ser executadas
php artisan migrate:status | grep -q "create_processos_table"
if [ $? -ne 0 ]; then
    echo "🔄 Executando migrations..."
    php artisan migrate
else
    echo "✅ Migrations já executadas"
fi

echo "✅ Parte 3 concluída com sucesso!"
echo ""
echo "📋 O que foi implementado:"
echo "   • Rotas API completas para processos"
echo "   • Configuração de serviços CNJ/Escavador/JurisBrasil"
echo "   • Métodos auxiliares (movimentações, documentos, atendimentos)"
echo "   • Dashboard de estatísticas de processos"
echo "   • Sincronização em lote com CNJ"
echo "   • Middleware de validação de acesso"
echo "   • Service Provider para CNJ"
echo "   • Variáveis de ambiente configuradas"
echo ""
echo "🚀 Backend de PROCESSOS completo!"
echo "⏭️ Próximo passo: Executar Parte 4 (Frontend React - Componentes)"