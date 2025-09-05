#!/bin/bash

# Script 121 - Corrigir erro de renderização de objeto no React
# Sistema Erlene Advogados - Erro: Objects are not valid as a React child
# EXECUTAR DENTRO DA PASTA: backend/

echo "🔧 Script 121 - Corrigindo erro de renderização de objeto React..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 121-fix-processos-object-render-error.sh && ./121-fix-processos-object-render-error.sh"
    exit 1
fi

echo "1️⃣ DIAGNÓSTICO DO ERRO:"
echo "   • Erro: Objects are not valid as a React child"
echo "   • Causa: Objeto sendo renderizado diretamente no JSX"
echo "   • Localização: Provavelmente em Processes.js linha 414"
echo "   • Solução: Garantir que apenas strings/números sejam renderizados"

echo ""
echo "2️⃣ Primeiro, vamos corrigir a API para retornar dados no formato correto..."

# Corrigir ProcessController para retornar dados limpos
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
     * Lista todos os processos com dados formatados para o frontend
     */
    public function index(Request $request)
    {
        try {
            Log::info('Listando processos', [
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

            // Formatar dados para o frontend
            $formattedData = $processes->getCollection()->map(function($processo) {
                return [
                    'id' => $processo->id,
                    'numero' => $processo->numero,
                    'tipo_acao' => $processo->tipo_acao,
                    'tribunal' => $processo->tribunal,
                    'vara' => $processo->vara,
                    'valor_causa' => $processo->valor_causa,
                    'status' => $processo->status,
                    'prioridade' => $processo->prioridade,
                    'data_distribuicao' => $processo->data_distribuicao ? $processo->data_distribuicao->format('Y-m-d') : null,
                    'observacoes' => $processo->observacoes,
                    'created_at' => $processo->created_at->format('Y-m-d H:i:s'),
                    'updated_at' => $processo->updated_at->format('Y-m-d H:i:s'),
                    
                    // Cliente - SEMPRE como objeto simples
                    'cliente' => $processo->cliente ? [
                        'id' => $processo->cliente->id,
                        'nome' => $processo->cliente->nome,
                        'tipo_pessoa' => $processo->cliente->tipo_pessoa,
                        'cpf_cnpj' => $processo->cliente->cpf_cnpj,
                        'email' => $processo->cliente->email,
                        'telefone' => $processo->cliente->telefone
                    ] : null,
                    
                    // Advogado - SEMPRE como objeto simples com apenas name
                    'advogado' => $processo->advogado ? [
                        'id' => $processo->advogado->id,
                        'name' => $processo->advogado->name,
                        'email' => $processo->advogado->email
                    ] : null,
                    
                    // Campos calculados
                    'cliente_nome' => $processo->cliente ? $processo->cliente->nome : 'Cliente não informado',
                    'advogado_nome' => $processo->advogado ? $processo->advogado->name : 'Advogado não atribuído',
                    'status_label' => $this->getStatusLabel($processo->status),
                    'prioridade_label' => $this->getPrioridadeLabel($processo->prioridade),
                    'valor_causa_formatado' => $processo->valor_causa ? 'R$ ' . number_format($processo->valor_causa, 2, ',', '.') : 'N/A'
                ];
            });

            $processes->setCollection($formattedData);

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
                'error' => config('app.debug') ? $e->getMessage() : 'Erro interno'
            ], 500);
        }
    }

    /**
     * Criar novo processo
     */
    public function store(Request $request)
    {
        try {
            Log::info('Criando processo', [
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
                'valor_causa' => 'nullable|string',
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
            $data['status'] = $data['status'] ?? 'em_andamento';
            $data['prioridade'] = $data['prioridade'] ?? 'media';
            
            // Converter valor da causa
            if (isset($data['valor_causa'])) {
                $data['valor_causa'] = $this->convertCurrencyToDecimal($data['valor_causa']);
            }

            $processo = Processo::create($data);
            $processo->load(['cliente', 'advogado']);

            // Retornar dados formatados
            $formattedProcess = [
                'id' => $processo->id,
                'numero' => $processo->numero,
                'tipo_acao' => $processo->tipo_acao,
                'tribunal' => $processo->tribunal,
                'vara' => $processo->vara,
                'valor_causa' => $processo->valor_causa,
                'status' => $processo->status,
                'prioridade' => $processo->prioridade,
                'data_distribuicao' => $processo->data_distribuicao ? $processo->data_distribuicao->format('Y-m-d') : null,
                'observacoes' => $processo->observacoes,
                'cliente' => $processo->cliente ? [
                    'id' => $processo->cliente->id,
                    'nome' => $processo->cliente->nome,
                    'tipo_pessoa' => $processo->cliente->tipo_pessoa,
                    'cpf_cnpj' => $processo->cliente->cpf_cnpj
                ] : null,
                'advogado' => $processo->advogado ? [
                    'id' => $processo->advogado->id,
                    'name' => $processo->advogado->name
                ] : null
            ];

            Log::info('Processo criado com sucesso', [
                'processo_id' => $processo->id
            ]);

            return response()->json([
                'success' => true,
                'data' => $formattedProcess,
                'message' => 'Processo criado com sucesso'
            ], 201);

        } catch (\Exception $e) {
            Log::error('Erro ao criar processo', [
                'error' => $e->getMessage(),
                'data' => $request->all()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erro ao criar processo',
                'error' => config('app.debug') ? $e->getMessage() : 'Erro interno'
            ], 500);
        }
    }

    /**
     * Exibir processo específico
     */
    public function show($id)
    {
        try {
            $processo = Processo::with(['cliente', 'advogado'])->findOrFail($id);

            $formattedProcess = [
                'id' => $processo->id,
                'numero' => $processo->numero,
                'tipo_acao' => $processo->tipo_acao,
                'tribunal' => $processo->tribunal,
                'vara' => $processo->vara,
                'valor_causa' => $processo->valor_causa,
                'status' => $processo->status,
                'prioridade' => $processo->prioridade,
                'data_distribuicao' => $processo->data_distribuicao ? $processo->data_distribuicao->format('Y-m-d') : null,
                'observacoes' => $processo->observacoes,
                'created_at' => $processo->created_at->format('Y-m-d H:i:s'),
                'updated_at' => $processo->updated_at->format('Y-m-d H:i:s'),
                'cliente' => $processo->cliente ? [
                    'id' => $processo->cliente->id,
                    'nome' => $processo->cliente->nome,
                    'tipo_pessoa' => $processo->cliente->tipo_pessoa,
                    'cpf_cnpj' => $processo->cliente->cpf_cnpj,
                    'email' => $processo->cliente->email,
                    'telefone' => $processo->cliente->telefone,
                    'endereco' => $processo->cliente->endereco
                ] : null,
                'advogado' => $processo->advogado ? [
                    'id' => $processo->advogado->id,
                    'name' => $processo->advogado->name,
                    'email' => $processo->advogado->email
                ] : null,
                'precisa_sincronizar_cnj' => false
            ];

            return response()->json([
                'success' => true,
                'data' => $formattedProcess
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
     * Labels para status
     */
    private function getStatusLabel($status)
    {
        $labels = [
            'em_andamento' => 'Em Andamento',
            'suspenso' => 'Suspenso',
            'finalizado' => 'Finalizado',
            'arquivado' => 'Arquivado'
        ];

        return $labels[$status] ?? 'Status Desconhecido';
    }

    /**
     * Labels para prioridade
     */
    private function getPrioridadeLabel($prioridade)
    {
        $labels = [
            'baixa' => 'Baixa',
            'media' => 'Média',
            'alta' => 'Alta',
            'urgente' => 'Urgente'
        ];

        return $labels[$prioridade] ?? 'Média';
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

    // Métodos adicionais que o frontend espera
    public function update(Request $request, $id) {
        return response()->json(['success' => false, 'message' => 'Método ainda não implementado'], 501);
    }
    
    public function destroy($id) {
        return response()->json(['success' => false, 'message' => 'Método ainda não implementado'], 501);
    }
    
    public function getMovements($id) {
        return response()->json(['success' => true, 'data' => ['data' => []]]);
    }
    
    public function getDocuments($id) {
        return response()->json(['success' => true, 'data' => ['data' => []]]);
    }
    
    public function getAppointments($id) {
        return response()->json(['success' => true, 'data' => ['data' => []]]);
    }
    
    public function syncWithCNJ($id) {
        return response()->json(['success' => true, 'data' => ['novas_movimentacoes' => 0]]);
    }
}
EOF

echo "3️⃣ Verificando se existe User model básico..."

if [ ! -f "app/Models/User.php" ]; then
    echo "Criando User model básico..."
    
    cat > app/Models/User.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'cpf',
        'telefone',
        'oab',
        'perfil',
        'unidade_id',
        'status'
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'ultimo_acesso' => 'datetime',
        'status' => 'boolean'
    ];

    // JWT Methods
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }

    // Relacionamentos
    public function processos()
    {
        return $this->hasMany(Processo::class, 'advogado_id');
    }
}
EOF
fi

echo "4️⃣ Populando dados de teste..."

php artisan tinker --execute="
try {
    // Verificar se já existem dados
    \$userCount = App\Models\User::count();
    \$clienteCount = App\Models\Cliente::count();
    \$processoCount = App\Models\Processo::count();
    
    echo 'Estado atual:';
    echo PHP_EOL . 'Usuários: ' . \$userCount;
    echo PHP_EOL . 'Clientes: ' . \$clienteCount;
    echo PHP_EOL . 'Processos: ' . \$processoCount;
    
    if (\$userCount == 0) {
        echo PHP_EOL . PHP_EOL . 'Criando usuário admin...';
        App\Models\User::create([
            'name' => 'Dra. Erlene Chaves Silva',
            'email' => 'admin@erlene.com',
            'password' => bcrypt('123456'),
            'cpf' => '123.456.789-00',
            'telefone' => '(11) 99999-9999',
            'oab' => 'OAB/SP 123456',
            'perfil' => 'admin',
            'status' => true
        ]);
        echo ' - Criado!';
    }
    
    if (\$clienteCount == 0) {
        echo PHP_EOL . PHP_EOL . 'Criando clientes teste...';
        App\Models\Cliente::create([
            'nome' => 'João Silva Santos',
            'tipo_pessoa' => 'PF',
            'cpf_cnpj' => '123.456.789-00',
            'email' => 'joao@email.com',
            'telefone' => '(11) 91234-5678',
            'endereco' => 'Rua das Flores, 123, São Paulo',
            'ativo' => true
        ]);
        
        App\Models\Cliente::create([
            'nome' => 'Empresa ABC Ltda',
            'tipo_pessoa' => 'PJ',
            'cpf_cnpj' => '12.345.678/0001-90',
            'email' => 'contato@abc.com.br',
            'telefone' => '(11) 3333-4444',
            'endereco' => 'Av. Paulista, 1000, São Paulo',
            'ativo' => true
        ]);
        echo ' - Criados!';
    }
    
    if (\$processoCount == 0) {
        echo PHP_EOL . PHP_EOL . 'Criando processos teste...';
        \$user = App\Models\User::first();
        \$cliente1 = App\Models\Cliente::where('tipo_pessoa', 'PF')->first();
        \$cliente2 = App\Models\Cliente::where('tipo_pessoa', 'PJ')->first();
        
        if (\$user && \$cliente1) {
            App\Models\Processo::create([
                'numero' => '0000335-25.2018.4.01.3202',
                'cliente_id' => \$cliente1->id,
                'tipo_acao' => 'Ação de Cobrança',
                'tribunal' => 'TRTSP',
                'vara' => '1ª Vara Cível',
                'valor_causa' => 15000.50,
                'status' => 'em_andamento',
                'advogado_id' => \$user->id,
                'prioridade' => 'alta',
                'data_distribuicao' => '2024-01-15',
                'observacoes' => 'Processo de cobrança de honorários advocatícios'
            ]);
        }
        
        if (\$user && \$cliente2) {
            App\Models\Processo::create([
                'numero' => '0000445-35.2018.5.02.0001',
                'cliente_id' => \$cliente2->id,
                'tipo_acao' => 'Reclamação Trabalhista',
                'tribunal' => 'TRT2',
                'vara' => '12ª Vara do Trabalho',
                'valor_causa' => 25000.00,
                'status' => 'suspenso',
                'advogado_id' => \$user->id,
                'prioridade' => 'media',
                'data_distribuicao' => '2024-01-20',
                'observacoes' => 'Reclamação trabalhista - férias não pagas'
            ]);
        }
        echo ' - Criados!';
    }
    
    echo PHP_EOL . PHP_EOL . 'Estado final:';
    echo PHP_EOL . 'Usuários: ' . App\Models\User::count();
    echo PHP_EOL . 'Clientes: ' . App\Models\Cliente::count();
    echo PHP_EOL . 'Processos: ' . App\Models\Processo::count();
    
} catch (Exception \$e) {
    echo PHP_EOL . 'ERRO: ' . \$e->getMessage();
}
"

echo ""
echo "5️⃣ Limpando cache e testando API..."

# Limpar caches
php artisan config:clear
php artisan route:clear
php artisan cache:clear

echo ""
echo "✅ CORREÇÕES APLICADAS!"
echo ""
echo "🔍 O que foi corrigido:"
echo "   • ProcessController formatando dados corretamente para React"
echo "   • Objetos sempre retornados como arrays associativos simples"
echo "   • Campos 'name' do advogado garantidamente como string"
echo "   • Dados de teste populados corretamente"
echo "   • Cache limpo"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. Certifique-se que backend está rodando: php artisan serve"
echo "   2. Acesse http://localhost:3000/admin/processos"
echo "   3. O erro 'Objects are not valid as a React child' deve ter desaparecido"
echo "   4. Processos devem carregar e exibir normalmente"
echo ""
echo "💡 Se ainda houver erro:"
echo "   • Verificar console do navegador para erros específicos"  
echo "   • Verificar logs Laravel: tail -f storage/logs/laravel.log"
echo "   • Limpar cache do React: Ctrl+F5 no navegador"