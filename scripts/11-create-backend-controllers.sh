#!/bin/bash

# Script 11 - Criação dos Controllers do Backend (Laravel)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/11-create-backend-controllers.sh (executado da raiz do projeto)

echo "🚀 Criando Controllers do Backend Laravel..."

# Controller Base
cat > backend/app/Http/Controllers/Controller.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;

/**
 * @OA\Info(
 *     title="Sistema Erlene Advogados API",
 *     version="1.0.0",
 *     description="API completa para gestão jurídica",
 *     @OA\Contact(
 *         email="contato@erleneadvogados.com"
 *     )
 * )
 *
 * @OA\Server(
 *     url="http://localhost:8080/api",
 *     description="Servidor de desenvolvimento"
 * )
 *
 * @OA\SecurityScheme(
 *     securityScheme="bearerAuth",
 *     type="http",
 *     scheme="bearer",
 *     bearerFormat="JWT"
 * )
 */
class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

    /**
     * Resposta de sucesso padrão
     */
    protected function success($data = null, $message = 'Operação realizada com sucesso', $code = 200)
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $code);
    }

    /**
     * Resposta de erro padrão
     */
    protected function error($message = 'Erro interno do servidor', $code = 500, $errors = null)
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors
        ], $code);
    }

    /**
     * Resposta paginada
     */
    protected function paginated($data, $message = 'Dados recuperados com sucesso')
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data->items(),
            'pagination' => [
                'current_page' => $data->currentPage(),
                'last_page' => $data->lastPage(),
                'per_page' => $data->perPage(),
                'total' => $data->total(),
                'from' => $data->firstItem(),
                'to' => $data->lastItem()
            ]
        ]);
    }
}
EOF

# Auth Controller
cat > backend/app/Http/Controllers/Auth/AuthController.php << 'EOF'
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Cliente;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    /**
     * @OA\Post(
     *     path="/auth/login",
     *     summary="Login do usuário administrativo",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"email","password"},
     *             @OA\Property(property="email", type="string", format="email"),
     *             @OA\Property(property="password", type="string", format="password")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Login realizado com sucesso"),
     *     @OA\Response(response=401, description="Credenciais inválidas")
     * )
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $credentials = $request->only('email', 'password');

        if (!$token = auth()->attempt($credentials)) {
            return $this->error('Credenciais inválidas', 401);
        }

        $user = auth()->user();
        
        // Atualizar último acesso
        $user->update(['ultimo_acesso' => now()]);

        return $this->success([
            'user' => [
                'id' => $user->id,
                'nome' => $user->nome,
                'email' => $user->email,
                'perfil' => $user->perfil,
                'unidade_id' => $user->unidade_id,
                'unidade' => $user->unidade->nome,
                'is_admin' => $user->is_admin
            ],
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60
        ], 'Login realizado com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/auth/login-client",
     *     summary="Login do cliente no portal",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"cpf_cnpj","password"},
     *             @OA\Property(property="cpf_cnpj", type="string"),
     *             @OA\Property(property="password", type="string", format="password")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Login do cliente realizado com sucesso"),
     *     @OA\Response(response=401, description="Credenciais inválidas")
     * )
     */
    public function loginClient(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'cpf_cnpj' => 'required|string',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $cliente = Cliente::where('cpf_cnpj', $request->cpf_cnpj)
                         ->where('acesso_portal', true)
                         ->where('status', 'ativo')
                         ->first();

        if (!$cliente || !Hash::check($request->password, $cliente->senha_portal)) {
            return $this->error('Credenciais inválidas', 401);
        }

        // Registrar acesso
        $cliente->acessosPortal()->create([
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'data_acesso' => now(),
            'acao' => 'login'
        ]);

        $token = auth('cliente')->login($cliente);

        return $this->success([
            'cliente' => [
                'id' => $cliente->id,
                'nome' => $cliente->nome,
                'email' => $cliente->email,
                'tipo_pessoa' => $cliente->tipo_pessoa,
                'documento' => $cliente->documento,
                'unidade' => $cliente->unidade->nome
            ],
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth('cliente')->factory()->getTTL() * 60
        ], 'Login realizado com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/auth/logout",
     *     summary="Logout do usuário",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Logout realizado com sucesso")
     * )
     */
    public function logout()
    {
        auth()->logout();
        return $this->success(null, 'Logout realizado com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/auth/refresh",
     *     summary="Renovar token",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Token renovado com sucesso")
     * )
     */
    public function refresh()
    {
        $token = auth()->refresh();
        
        return $this->success([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60
        ], 'Token renovado com sucesso');
    }

    /**
     * @OA\Get(
     *     path="/auth/me",
     *     summary="Obter dados do usuário autenticado",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do usuário")
     * )
     */
    public function me()
    {
        $user = auth()->user();
        
        return $this->success([
            'id' => $user->id,
            'nome' => $user->nome,
            'email' => $user->email,
            'perfil' => $user->perfil,
            'unidade_id' => $user->unidade_id,
            'unidade' => $user->unidade->nome,
            'is_admin' => $user->is_admin,
            'ultimo_acesso' => $user->ultimo_acesso
        ]);
    }
}
EOF

# Dashboard Controller
cat > backend/app/Http/Controllers/Api/Admin/DashboardController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\Atendimento;
use App\Models\Financeiro;
use App\Models\Tarefa;
use Illuminate\Http\Request;
use Carbon\Carbon;

class DashboardController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/dashboard",
     *     summary="Dashboard administrativo",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do dashboard")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $unidadeId = $user->unidade_id;
        
        // Estatísticas gerais
        $stats = [
            'clientes' => [
                'total' => Cliente::where('unidade_id', $unidadeId)->count(),
                'ativos' => Cliente::where('unidade_id', $unidadeId)->where('status', 'ativo')->count(),
                'novos_mes' => Cliente::where('unidade_id', $unidadeId)
                                   ->whereMonth('created_at', now()->month)
                                   ->count()
            ],
            'processos' => [
                'total' => Processo::where('unidade_id', $unidadeId)->count(),
                'ativos' => Processo::where('unidade_id', $unidadeId)->ativos()->count(),
                'urgentes' => Processo::where('unidade_id', $unidadeId)
                                    ->where('prioridade', 'urgente')
                                    ->count(),
                'prazos_vencendo' => Processo::where('unidade_id', $unidadeId)
                                           ->comPrazoVencendo(7)
                                           ->count()
            ],
            'atendimentos' => [
                'hoje' => Atendimento::where('unidade_id', $unidadeId)->hoje()->count(),
                'semana' => Atendimento::where('unidade_id', $unidadeId)
                                     ->whereBetween('data_hora', [now()->startOfWeek(), now()->endOfWeek()])
                                     ->count(),
                'agendados' => Atendimento::where('unidade_id', $unidadeId)->agendados()->count()
            ],
            'financeiro' => [
                'receita_mes' => Financeiro::where('unidade_id', $unidadeId)
                                         ->where('status', 'pago')
                                         ->whereMonth('data_pagamento', now()->month)
                                         ->sum('valor'),
                'pendente' => Financeiro::where('unidade_id', $unidadeId)->pendentes()->sum('valor'),
                'vencidos' => Financeiro::where('unidade_id', $unidadeId)->vencidos()->sum('valor')
            ],
            'tarefas' => [
                'pendentes' => Tarefa::where('responsavel_id', $user->id)->pendentes()->count(),
                'vencidas' => Tarefa::where('responsavel_id', $user->id)->vencidas()->count()
            ]
        ];

        // Gráfico de atendimentos dos últimos 30 dias
        $atendimentosGrafico = [];
        for ($i = 29; $i >= 0; $i--) {
            $data = now()->subDays($i)->format('Y-m-d');
            $count = Atendimento::where('unidade_id', $unidadeId)
                               ->whereDate('data_hora', $data)
                               ->count();
            
            $atendimentosGrafico[] = [
                'data' => $data,
                'quantidade' => $count
            ];
        }

        // Receitas dos últimos 12 meses
        $receitasGrafico = [];
        for ($i = 11; $i >= 0; $i--) {
            $mes = now()->subMonths($i);
            $receita = Financeiro::where('unidade_id', $unidadeId)
                                ->where('status', 'pago')
                                ->whereYear('data_pagamento', $mes->year)
                                ->whereMonth('data_pagamento', $mes->month)
                                ->sum('valor');
            
            $receitasGrafico[] = [
                'mes' => $mes->format('Y-m'),
                'mes_nome' => $mes->format('M/Y'),
                'receita' => (float) $receita
            ];
        }

        // Próximos atendimentos
        $proximosAtendimentos = Atendimento::with(['cliente', 'advogado'])
                                         ->where('unidade_id', $unidadeId)
                                         ->where('status', 'agendado')
                                         ->where('data_hora', '>=', now())
                                         ->orderBy('data_hora')
                                         ->limit(5)
                                         ->get();

        // Processos com prazos vencendo
        $processosUrgentes = Processo::with(['cliente', 'advogado'])
                                   ->where('unidade_id', $unidadeId)
                                   ->comPrazoVencendo(7)
                                   ->orderBy('proximo_prazo')
                                   ->limit(5)
                                   ->get();

        // Tarefas pendentes do usuário
        $tarefasPendentes = Tarefa::with(['cliente', 'processo'])
                                 ->where('responsavel_id', $user->id)
                                 ->pendentes()
                                 ->orderBy('prazo')
                                 ->limit(5)
                                 ->get();

        return $this->success([
            'stats' => $stats,
            'graficos' => [
                'atendimentos' => $atendimentosGrafico,
                'receitas' => $receitasGrafico
            ],
            'listas' => [
                'proximos_atendimentos' => $proximosAtendimentos,
                'processos_urgentes' => $processosUrgentes,
                'tarefas_pendentes' => $tarefasPendentes
            ]
        ]);
    }

    /**
     * @OA\Get(
     *     path="/admin/dashboard/notifications",
     *     summary="Notificações do dashboard",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Notificações")
     * )
     */
    public function notifications()
    {
        $user = auth()->user();
        
        $notifications = [];

        // Prazos vencendo
        $prazosVencendo = Processo::where('unidade_id', $user->unidade_id)
                                ->comPrazoVencendo(3)
                                ->count();
        
        if ($prazosVencendo > 0) {
            $notifications[] = [
                'type' => 'warning',
                'title' => 'Prazos Vencendo',
                'message' => "{$prazosVencendo} processo(s) com prazo vencendo em 3 dias",
                'action' => '/admin/processos?filter=prazo_vencendo'
            ];
        }

        // Atendimentos hoje
        $atendimentosHoje = Atendimento::where('unidade_id', $user->unidade_id)
                                     ->hoje()
                                     ->agendados()
                                     ->count();
        
        if ($atendimentosHoje > 0) {
            $notifications[] = [
                'type' => 'info',
                'title' => 'Atendimentos Hoje',
                'message' => "{$atendimentosHoje} atendimento(s) agendado(s) para hoje",
                'action' => '/admin/atendimentos?filter=hoje'
            ];
        }

        // Pagamentos vencidos
        $pagamentosVencidos = Financeiro::where('unidade_id', $user->unidade_id)
                                      ->vencidos()
                                      ->count();
        
        if ($pagamentosVencidos > 0) {
            $notifications[] = [
                'type' => 'danger',
                'title' => 'Pagamentos Vencidos',
                'message' => "{$pagamentosVencidos} pagamento(s) em atraso",
                'action' => '/admin/financeiro?filter=vencidos'
            ];
        }

        return $this->success($notifications);
    }
}
EOF

# Client Controller
cat > backend/app/Http/Controllers/Api/Admin/Clients/ClientController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Clients;

use App\Http\Controllers\Controller;
use App\Models\Cliente;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class ClientController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/clients",
     *     summary="Listar clientes",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="page", in="query", @OA\Schema(type="integer")),
     *     @OA\Parameter(name="search", in="query", @OA\Schema(type="string")),
     *     @OA\Parameter(name="status", in="query", @OA\Schema(type="string")),
     *     @OA\Response(response=200, description="Lista de clientes")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Cliente::with(['unidade', 'responsavel'])
                       ->where('unidade_id', $user->unidade_id);

        // Filtros
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('nome', 'like', "%{$search}%")
                  ->orWhere('cpf_cnpj', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->tipo_pessoa) {
            $query->where('tipo_pessoa', $request->tipo_pessoa);
        }

        $clientes = $query->orderBy('nome')
                         ->paginate($request->per_page ?? 15);

        return $this->paginated($clientes);
    }

    /**
     * @OA\Post(
     *     path="/admin/clients",
     *     summary="Criar cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"nome","cpf_cnpj","email","telefone","tipo_pessoa"},
     *             @OA\Property(property="nome", type="string"),
     *             @OA\Property(property="cpf_cnpj", type="string"),
     *             @OA\Property(property="email", type="string", format="email"),
     *             @OA\Property(property="telefone", type="string"),
     *             @OA\Property(property="tipo_pessoa", type="string", enum={"PF","PJ"})
     *         )
     *     ),
     *     @OA\Response(response=201, description="Cliente criado com sucesso")
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nome' => 'required|string|max:255',
            'cpf_cnpj' => 'required|string|unique:clientes,cpf_cnpj',
            'tipo_pessoa' => 'required|in:PF,PJ',
            'email' => 'required|email|unique:clientes,email',
            'telefone' => 'required|string|max:15',
            'endereco' => 'required|string',
            'cep' => 'required|string|max:9',
            'cidade' => 'required|string|max:100',
            'estado' => 'required|string|size:2',
            'observacoes' => 'nullable|string',
            'acesso_portal' => 'boolean',
            'tipo_armazenamento' => 'in:local,google_drive,onedrive',
            'responsavel_id' => 'required|exists:users,id'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        $data = $request->all();
        $data['unidade_id'] = $user->unidade_id;
        
        // Criar pasta local automaticamente
        $data['pasta_local'] = Str::slug($data['nome']);
        
        // Se habilitou acesso ao portal, gerar senha
        if ($request->acesso_portal) {
            $senhaTemporaria = Str::random(8);
            $data['senha_portal'] = Hash::make($senhaTemporaria);
        }

        $cliente = Cliente::create($data);

        // Criar pasta física se armazenamento local
        if ($cliente->tipo_armazenamento === 'local') {
            $pastaPath = storage_path('app/clients/' . $cliente->pasta_local);
            if (!file_exists($pastaPath)) {
                mkdir($pastaPath, 0755, true);
            }
        }

        $cliente->load(['unidade', 'responsavel']);

        $response = $cliente->toArray();
        if (isset($senhaTemporaria)) {
            $response['senha_temporaria'] = $senhaTemporaria;
        }

        return $this->success($response, 'Cliente criado com sucesso', 201);
    }

    /**
     * @OA\Get(
     *     path="/admin/clients/{id}",
     *     summary="Obter cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Dados do cliente")
     * )
     */
    public function show($id)
    {
        $user = auth()->user();
        $cliente = Cliente::with(['unidade', 'responsavel', 'processos', 'atendimentos'])
                         ->where('unidade_id', $user->unidade_id)
                         ->findOrFail($id);

        return $this->success($cliente);
    }

    /**
     * @OA\Put(
     *     path="/admin/clients/{id}",
     *     summary="Atualizar cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Cliente atualizado com sucesso")
     * )
     */
    public function update(Request $request, $id)
    {
        $user = auth()->user();
        $cliente = Cliente::where('unidade_id', $user->unidade_id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nome' => 'string|max:255',
            'cpf_cnpj' => 'string|unique:clientes,cpf_cnpj,' . $id,
            'tipo_pessoa' => 'in:PF,PJ',
            'email' => 'email|unique:clientes,email,' . $id,
            'telefone' => 'string|max:15',
            'endereco' => 'string',
            'cep' => 'string|max:9',
            'cidade' => 'string|max:100',
            'estado' => 'string|size:2',
            'observacoes' => 'nullable|string',
            'acesso_portal' => 'boolean',
            'tipo_armazenamento' => 'in:local,google_drive,onedrive',
            'responsavel_id' => 'exists:users,id',
            'status' => 'in:ativo,inativo'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $cliente->update($request->all());
        $cliente->load(['unidade', 'responsavel']);

        return $this->success($cliente, 'Cliente atualizado com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/clients/{id}",
     *     summary="Excluir cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Cliente excluído com sucesso")
     * )
     */
    public function destroy($id)
    {
        $user = auth()->user();
        $cliente = Cliente::where('unidade_id', $user->unidade_id)->findOrFail($id);
        
        // Verificar se tem processos ativos
        if ($cliente->processos()->ativos()->count() > 0) {
            return $this->error('Não é possível excluir cliente com processos ativos', 400);
        }

        $cliente->delete();
        return $this->success(null, 'Cliente excluído com sucesso');
    }

    /**
     * Obter responsáveis disponíveis
     */
    public function responsaveis()
    {
        $user = auth()->user();
        $responsaveis = User::where('unidade_id', $user->unidade_id)
                          ->whereIn('perfil', ['admin_geral', 'admin_unidade', 'advogado'])
                          ->where('status', 'ativo')
                          ->select('id', 'nome', 'email', 'oab')
                          ->orderBy('nome')
                          ->get();

        return $this->success($responsaveis);
    }
}
EOF

echo "✅ Controllers principais criados!"
echo "📊 Progresso: 4/20 Controllers do backend"
echo ""
echo "⏭️  Continue executando para criar os próximos controllers..."