#!/bin/bash

# Script 13 - Criação dos Controllers do Backend (Parte 3)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/13-create-backend-controllers-part3.sh (executado da raiz do projeto)

echo "🚀 Continuando criação dos Controllers do Backend (Parte 3)..."

# Kanban Controller
cat > backend/app/Http/Controllers/Api/Admin/KanbanController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\KanbanColuna;
use App\Models\KanbanCard;
use App\Models\Processo;
use App\Models\Tarefa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class KanbanController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/kanban",
     *     summary="Obter dados do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do kanban")
     * )
     */
    public function index()
    {
        $user = auth()->user();
        
        $colunas = KanbanColuna::with(['cards' => function($query) {
                                    $query->with(['processo.cliente', 'tarefa', 'responsavel'])
                                          ->ordenados();
                                }])
                               ->where('unidade_id', $user->unidade_id)
                               ->ordenadas()
                               ->get();

        return $this->success([
            'colunas' => $colunas,
            'estatisticas' => [
                'total_cards' => KanbanCard::whereHas('coluna', function($q) use ($user) {
                    $q->where('unidade_id', $user->unidade_id);
                })->count(),
                'cards_urgentes' => KanbanCard::whereHas('coluna', function($q) use ($user) {
                    $q->where('unidade_id', $user->unidade_id);
                })->where('prioridade', 'urgente')->count(),
                'cards_vencendo' => KanbanCard::whereHas('coluna', function($q) use ($user) {
                    $q->where('unidade_id', $user->unidade_id);
                })->comPrazoVencendo(3)->count()
            ]
        ]);
    }

    /**
     * @OA\Post(
     *     path="/admin/kanban/colunas",
     *     summary="Criar coluna do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"nome"},
     *             @OA\Property(property="nome", type="string"),
     *             @OA\Property(property="cor", type="string"),
     *             @OA\Property(property="ordem", type="integer")
     *         )
     *     ),
     *     @OA\Response(response=201, description="Coluna criada com sucesso")
     * )
     */
    public function criarColuna(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nome' => 'required|string|max:100',
            'cor' => 'required|string|regex:/^#[0-9A-Fa-f]{6}$/',
            'ordem' => 'nullable|integer|min:1'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        // Se não especificada, definir ordem como última
        $ordem = $request->ordem ?? KanbanColuna::where('unidade_id', $user->unidade_id)->max('ordem') + 1;

        $coluna = KanbanColuna::create([
            'nome' => $request->nome,
            'cor' => $request->cor,
            'ordem' => $ordem,
            'unidade_id' => $user->unidade_id
        ]);

        return $this->success($coluna, 'Coluna criada com sucesso', 201);
    }

    /**
     * @OA\Put(
     *     path="/admin/kanban/colunas/{id}",
     *     summary="Atualizar coluna do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Coluna atualizada com sucesso")
     * )
     */
    public function atualizarColuna(Request $request, $id)
    {
        $user = auth()->user();
        $coluna = KanbanColuna::where('unidade_id', $user->unidade_id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nome' => 'string|max:100',
            'cor' => 'string|regex:/^#[0-9A-Fa-f]{6}$/',
            'ordem' => 'integer|min:1'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $coluna->update($request->all());

        return $this->success($coluna, 'Coluna atualizada com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/kanban/colunas/{id}",
     *     summary="Excluir coluna do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Coluna excluída com sucesso")
     * )
     */
    public function excluirColuna($id)
    {
        $user = auth()->user();
        $coluna = KanbanColuna::where('unidade_id', $user->unidade_id)->findOrFail($id);

        if ($coluna->cards()->count() > 0) {
            return $this->error('Não é possível excluir coluna com cards', 400);
        }

        $coluna->delete();
        return $this->success(null, 'Coluna excluída com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/admin/kanban/cards",
     *     summary="Criar card do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"titulo","coluna_id","responsavel_id"},
     *             @OA\Property(property="titulo", type="string"),
     *             @OA\Property(property="descricao", type="string"),
     *             @OA\Property(property="coluna_id", type="integer"),
     *             @OA\Property(property="processo_id", type="integer"),
     *             @OA\Property(property="responsavel_id", type="integer")
     *         )
     *     ),
     *     @OA\Response(response=201, description="Card criado com sucesso")
     * )
     */
    public function criarCard(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'titulo' => 'required|string|max:255',
            'descricao' => 'nullable|string',
            'coluna_id' => 'required|exists:kanban_colunas,id',
            'processo_id' => 'nullable|exists:processos,id',
            'tarefa_id' => 'nullable|exists:tarefas,id',
            'prioridade' => 'in:baixa,media,alta,urgente',
            'prazo' => 'nullable|date|after:today',
            'responsavel_id' => 'required|exists:users,id'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        // Verificar se coluna pertence à unidade
        $coluna = KanbanColuna::where('id', $request->coluna_id)
                             ->where('unidade_id', $user->unidade_id)
                             ->first();
        
        if (!$coluna) {
            return $this->error('Coluna não encontrada', 404);
        }

        // Definir posição como última da coluna
        $posicao = KanbanCard::where('coluna_id', $request->coluna_id)->max('posicao') + 1;

        $data = $request->all();
        $data['posicao'] = $posicao;
        $data['prioridade'] = $data['prioridade'] ?? 'media';

        $card = KanbanCard::create($data);
        $card->load(['processo.cliente', 'tarefa', 'responsavel', 'coluna']);

        return $this->success($card, 'Card criado com sucesso', 201);
    }

    /**
     * @OA\Put(
     *     path="/admin/kanban/cards/{id}",
     *     summary="Atualizar card do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Card atualizado com sucesso")
     * )
     */
    public function atualizarCard(Request $request, $id)
    {
        $user = auth()->user();
        $card = KanbanCard::whereHas('coluna', function($q) use ($user) {
                             $q->where('unidade_id', $user->unidade_id);
                         })->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'titulo' => 'string|max:255',
            'descricao' => 'nullable|string',
            'coluna_id' => 'exists:kanban_colunas,id',
            'processo_id' => 'nullable|exists:processos,id',
            'tarefa_id' => 'nullable|exists:tarefas,id',
            'prioridade' => 'in:baixa,media,alta,urgente',
            'prazo' => 'nullable|date',
            'responsavel_id' => 'exists:users,id'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $card->update($request->all());
        $card->load(['processo.cliente', 'tarefa', 'responsavel', 'coluna']);

        return $this->success($card, 'Card atualizado com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/admin/kanban/cards/{id}/mover",
     *     summary="Mover card entre colunas",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"coluna_id","posicao"},
     *             @OA\Property(property="coluna_id", type="integer"),
     *             @OA\Property(property="posicao", type="integer")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Card movido com sucesso")
     * )
     */
    public function moverCard(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'coluna_id' => 'required|exists:kanban_colunas,id',
            'posicao' => 'required|integer|min:1'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        DB::transaction(function() use ($request, $id, $user) {
            $card = KanbanCard::whereHas('coluna', function($q) use ($user) {
                                 $q->where('unidade_id', $user->unidade_id);
                             })->findOrFail($id);

            $colunaDestino = KanbanColuna::where('id', $request->coluna_id)
                                       ->where('unidade_id', $user->unidade_id)
                                       ->firstOrFail();

            $colunaOrigem = $card->coluna_id;
            $posicaoOrigem = $card->posicao;

            // Se mudou de coluna
            if ($colunaOrigem != $request->coluna_id) {
                // Reorganizar posições na coluna origem
                KanbanCard::where('coluna_id', $colunaOrigem)
                          ->where('posicao', '>', $posicaoOrigem)
                          ->decrement('posicao');

                // Reorganizar posições na coluna destino
                KanbanCard::where('coluna_id', $request->coluna_id)
                          ->where('posicao', '>=', $request->posicao)
                          ->increment('posicao');
            } else {
                // Mover dentro da mesma coluna
                if ($request->posicao > $posicaoOrigem) {
                    KanbanCard::where('coluna_id', $colunaOrigem)
                              ->whereBetween('posicao', [$posicaoOrigem + 1, $request->posicao])
                              ->decrement('posicao');
                } else {
                    KanbanCard::where('coluna_id', $colunaOrigem)
                              ->whereBetween('posicao', [$request->posicao, $posicaoOrigem - 1])
                              ->increment('posicao');
                }
            }

            // Atualizar o card
            $card->update([
                'coluna_id' => $request->coluna_id,
                'posicao' => $request->posicao
            ]);
        });

        return $this->success(null, 'Card movido com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/kanban/cards/{id}",
     *     summary="Excluir card do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Card excluído com sucesso")
     * )
     */
    public function excluirCard($id)
    {
        $user = auth()->user();
        $card = KanbanCard::whereHas('coluna', function($q) use ($user) {
                             $q->where('unidade_id', $user->unidade_id);
                         })->findOrFail($id);

        // Reorganizar posições
        KanbanCard::where('coluna_id', $card->coluna_id)
                  ->where('posicao', '>', $card->posicao)
                  ->decrement('posicao');

        $card->delete();
        return $this->success(null, 'Card excluído com sucesso');
    }

    /**
     * Reordenar colunas
     */
    public function reordenarColunas(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'colunas' => 'required|array',
            'colunas.*.id' => 'required|exists:kanban_colunas,id',
            'colunas.*.ordem' => 'required|integer|min:1'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();

        DB::transaction(function() use ($request, $user) {
            foreach ($request->colunas as $colunaData) {
                KanbanColuna::where('id', $colunaData['id'])
                           ->where('unidade_id', $user->unidade_id)
                           ->update(['ordem' => $colunaData['ordem']]);
            }
        });

        return $this->success(null, 'Colunas reordenadas com sucesso');
    }
}
EOF

# Users Controller
cat > backend/app/Http/Controllers/Api/Admin/Users/UserController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Users;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Unidade;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/users",
     *     summary="Listar usuários",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Lista de usuários")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = User::with(['unidade']);

        // Admin geral vê todos, admin unidade vê só da sua unidade
        if ($user->perfil !== 'admin_geral') {
            $query->where('unidade_id', $user->unidade_id);
        }

        // Filtros
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('nome', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('cpf', 'like', "%{$search}%")
                  ->orWhere('oab', 'like', "%{$search}%");
            });
        }

        if ($request->perfil) {
            $query->where('perfil', $request->perfil);
        }

        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->unidade_id) {
            $query->where('unidade_id', $request->unidade_id);
        }

        $usuarios = $query->orderBy('nome')
                         ->paginate($request->per_page ?? 15);

        return $this->paginated($usuarios);
    }

    /**
     * @OA\Post(
     *     path="/admin/users",
     *     summary="Criar usuário",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"nome","email","password","cpf","perfil","unidade_id"},
     *             @OA\Property(property="nome", type="string"),
     *             @OA\Property(property="email", type="string", format="email"),
     *             @OA\Property(property="password", type="string", format="password"),
     *             @OA\Property(property="cpf", type="string"),
     *             @OA\Property(property="perfil", type="string")
     *         )
     *     ),
     *     @OA\Response(response=201, description="Usuário criado com sucesso")
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nome' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'cpf' => 'required|string|unique:users,cpf',
            'oab' => 'nullable|string',
            'telefone' => 'required|string|max:15',
            'perfil' => 'required|in:admin_geral,admin_unidade,advogado,secretario,financeiro,consulta',
            'unidade_id' => 'required|exists:unidades,id',
            'status' => 'in:ativo,inativo'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $currentUser = auth()->user();
        
        // Verificar permissões
        if ($currentUser->perfil === 'admin_unidade' && $request->unidade_id != $currentUser->unidade_id) {
            return $this->error('Sem permissão para criar usuários em outras unidades', 403);
        }

        if ($currentUser->perfil !== 'admin_geral' && $request->perfil === 'admin_geral') {
            return $this->error('Sem permissão para criar administradores gerais', 403);
        }

        $data = $request->all();
        $data['password'] = Hash::make($request->password);
        $data['status'] = $data['status'] ?? 'ativo';

        $usuario = User::create($data);
        $usuario->load(['unidade']);

        return $this->success($usuario, 'Usuário criado com sucesso', 201);
    }

    /**
     * @OA\Get(
     *     path="/admin/users/{id}",
     *     summary="Obter usuário",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Dados do usuário")
     * )
     */
    public function show($id)
    {
        $currentUser = auth()->user();
        $query = User::with(['unidade', 'clientes', 'processos']);

        if ($currentUser->perfil !== 'admin_geral') {
            $query->where('unidade_id', $currentUser->unidade_id);
        }

        $usuario = $query->findOrFail($id);

        return $this->success($usuario);
    }

    /**
     * @OA\Put(
     *     path="/admin/users/{id}",
     *     summary="Atualizar usuário",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Usuário atualizado com sucesso")
     * )
     */
    public function update(Request $request, $id)
    {
        $currentUser = auth()->user();
        $query = User::query();

        if ($currentUser->perfil !== 'admin_geral') {
            $query->where('unidade_id', $currentUser->unidade_id);
        }

        $usuario = $query->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nome' => 'string|max:255',
            'email' => 'email|unique:users,email,' . $id,
            'password' => 'nullable|string|min:8|confirmed',
            'cpf' => 'string|unique:users,cpf,' . $id,
            'oab' => 'nullable|string',
            'telefone' => 'string|max:15',
            'perfil' => 'in:admin_geral,admin_unidade,advogado,secretario,financeiro,consulta',
            'unidade_id' => 'exists:unidades,id',
            'status' => 'in:ativo,inativo'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        // Verificar permissões de mudança de perfil
        if ($request->has('perfil') && $currentUser->perfil !== 'admin_geral' && $request->perfil === 'admin_geral') {
            return $this->error('Sem permissão para definir administrador geral', 403);
        }

        $data = $request->except('password_confirmation');
        
        if ($request->password) {
            $data['password'] = Hash::make($request->password);
        } else {
            unset($data['password']);
        }

        $usuario->update($data);
        $usuario->load(['unidade']);

        return $this->success($usuario, 'Usuário atualizado com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/users/{id}",
     *     summary="Excluir usuário",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Usuário excluído com sucesso")
     * )
     */
    public function destroy($id)
    {
        $currentUser = auth()->user();
        
        if ($currentUser->id == $id) {
            return $this->error('Não é possível excluir seu próprio usuário', 400);
        }

        $query = User::query();

        if ($currentUser->perfil !== 'admin_geral') {
            $query->where('unidade_id', $currentUser->unidade_id);
        }

        $usuario = $query->findOrFail($id);

        // Verificar se tem clientes ou processos vinculados
        if ($usuario->clientes()->count() > 0 || $usuario->processos()->count() > 0) {
            return $this->error('Não é possível excluir usuário com clientes ou processos vinculados', 400);
        }

        $usuario->delete();
        return $this->success(null, 'Usuário excluído com sucesso');
    }

    /**
     * Ativar/Desativar usuário
     */
    public function toggleStatus($id)
    {
        $currentUser = auth()->user();
        $query = User::query();

        if ($currentUser->perfil !== 'admin_geral') {
            $query->where('unidade_id', $currentUser->unidade_id);
        }

        $usuario = $query->findOrFail($id);

        if ($currentUser->id == $id) {
            return $this->error('Não é possível alterar status do seu próprio usuário', 400);
        }

        $novoStatus = $usuario->status === 'ativo' ? 'inativo' : 'ativo';
        $usuario->update(['status' => $novoStatus]);

        return $this->success($usuario, "Usuário {$novoStatus} com sucesso");
    }

    /**
     * Redefinir senha
     */
    public function redefinirSenha(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'password' => 'required|string|min:8|confirmed'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $currentUser = auth()->user();
        $query = User::query();

        if ($currentUser->perfil !== 'admin_geral') {
            $query->where('unidade_id', $currentUser->unidade_id);
        }

        $usuario = $query->findOrFail($id);

        $usuario->update([
            'password' => Hash::make($request->password)
        ]);

        return $this->success(null, 'Senha redefinida com sucesso');
    }

    /**
     * Obter unidades disponíveis
     */
    public function unidades()
    {
        $currentUser = auth()->user();
        $query = Unidade::ativas();

        // Admin geral vê todas, admin unidade vê só a sua
        if ($currentUser->perfil !== 'admin_geral') {
            $query->where('id', $currentUser->unidade_id);
        }

        $unidades = $query->select('id', 'nome', 'is_matriz')
                         ->orderBy('nome')
                         ->get();

        return $this->success($unidades);
    }

    /**
     * Obter perfis disponíveis
     */
    public function perfis()
    {
        $currentUser = auth()->user();
        
        $perfis = [
            'admin_unidade' => 'Administrador da Unidade',
            'advogado' => 'Advogado',
            'secretario' => 'Secretário',
            'financeiro' => 'Financeiro',
            'consulta' => 'Apenas Consulta'
        ];

        // Apenas admin geral pode criar outros admin gerais
        if ($currentUser->perfil === 'admin_geral') {
            $perfis = ['admin_geral' => 'Administrador Geral'] + $perfis;
        }

        return $this->success($perfis);
    }
}
EOF

# Stripe Payment Controller
cat > backend/app/Http/Controllers/Api/Admin/Financial/StripeController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Financial;

use App\Http\Controllers\Controller;
use App\Models\Financeiro;
use App\Models\PagamentoStripe;
use App\Models\Cliente;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Stripe\Stripe;
use Stripe\PaymentIntent;
use Stripe\Customer;

class StripeController extends Controller
{
    public function __construct()
    {
        Stripe::setApiKey(config('services.stripe.secret'));
    }

    /**
     * @OA\Post(
     *     path="/admin/payments/stripe/create-payment-intent",
     *     summary="Criar Payment Intent no Stripe",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"financeiro_id","moeda"},
     *             @OA\Property(property="financeiro_id", type="integer"),
     *             @OA\Property(property="moeda", type="string", enum={"BRL","USD","EUR"})
     *         )
     *     ),
     *     @OA\Response(response=200, description="Payment Intent criado com sucesso")
     * )
     */
    public function createPaymentIntent(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'financeiro_id' => 'required|exists:financeiro,id',
            'moeda' => 'required|in:BRL,USD,EUR'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        $financeiro = Financeiro::where('unidade_id', $user->unidade_id)
                               ->where('status', 'pendente')
                               ->findOrFail($request->financeiro_id);

        $cliente = $financeiro->cliente;

        try {
            // Converter valor para centavos
            $valor = intval($financeiro->valor * 100);

            // Criar ou buscar cliente no Stripe
            $stripeCustomer = null;
            $existingPayment = PagamentoStripe::where('financeiro_id', $financeiro->id)
                                            ->where('moeda', $request->moeda)
                                            ->first();

            if ($existingPayment && $existingPayment->stripe_customer_id) {
                $stripeCustomerId = $existingPayment->stripe_customer_id;
            } else {
                $stripeCustomer = Customer::create([
                    'email' => $cliente->email,
                    'name' => $cliente->nome,
                    'metadata' => [
                        'cliente_id' => $cliente->id,
                        'unidade_id' => $user->unidade_id
                    ]
                ]);
                $stripeCustomerId = $stripeCustomer->id;
            }

            // Criar Payment Intent
            $paymentIntent = PaymentIntent::create([
                'amount' => $valor,
                'currency' => strtolower($request->moeda),
                'customer' => $stripeCustomerId,
                'metadata' => [
                    'financeiro_id' => $financeiro->id,
                    'cliente_id' => $cliente->id,
                    'unidade_id' => $user->unidade_id,
                    'processo_id' => $financeiro->processo_id,
                    'atendimento_id' => $financeiro->atendimento_id
                ],
                'payment_method_types' => ['card'],
                'setup_future_usage' => 'off_session'
            ]);

            // Salvar no banco
            $pagamentoStripe = PagamentoStripe::updateOrCreate(
                [
                    'financeiro_id' => $financeiro->id,
                    'moeda' => $request->moeda
                ],
                [
                    'cliente_id' => $cliente->id,
                    'processo_id' => $financeiro->processo_id,
                    'atendimento_id' => $financeiro->atendimento_id,
                    'valor' => $financeiro->valor,
                    'status' => $paymentIntent->status,
                    'stripe_payment_intent_id' => $paymentIntent->id,
                    'stripe_customer_id' => $stripeCustomerId,
                    'stripe_metadata' => $paymentIntent->metadata->toArray(),
                    'data_criacao' => now()
                ]
            );

            return $this->success([
                'client_secret' => $paymentIntent->client_secret,
                'payment_intent_id' => $paymentIntent->id,
                'valor' => $financeiro->valor,
                'moeda' => $request->moeda,
                'pagamento_id' => $pagamentoStripe->id
            ], 'Payment Intent criado com sucesso');

        } catch (\Exception $e) {
            return $this->error('Erro ao criar Payment Intent: ' . $e->getMessage(), 500);
        }
    }

    /**
     * @OA\Post(
     *     path="/admin/payments/stripe/webhook",
     *     summary="Webhook do Stripe",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(type="object")
     *     ),
     *     @OA\Response(response=200, description="Webhook processado")
     * )
     */
    public function webhook(Request $request)
    {
        $payload = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        $endpointSecret = config('services.stripe.webhook_secret');

        try {
            $event = \Stripe\Webhook::constructEvent(
                $payload, $sigHeader, $endpointSecret
            );
        } catch(\UnexpectedValueException $e) {
            return response('Invalid payload', 400);
        } catch(\Stripe\Exception\SignatureVerificationException $e) {
            return response('Invalid signature', 400);
        }

        // Processar evento
        switch ($event->type) {
            case 'payment_intent.succeeded':
                $this->handlePaymentSucceeded($event->data->object);
                break;
                
            case 'payment_intent.payment_failed':
                $this->handlePaymentFailed($event->data->object);
                break;
                
            case 'payment_intent.canceled':
                $this->handlePaymentCanceled($event->data->object);
                break;
        }

        return response('Webhook handled', 200);
    }

    /**
     * Processar pagamento bem-sucedido
     */
    private function handlePaymentSucceeded($paymentIntent)
    {
        $pagamento = PagamentoStripe::where('stripe_payment_intent_id', $paymentIntent->id)->first();
        
        if ($pagamento) {
            $pagamento->update([
                'status' => 'succeeded',
                'data_pagamento' => now(),
                'stripe_charge_id' => $paymentIntent->charges->data[0]->id ?? null,
                'taxa_stripe' => ($paymentIntent->charges->data[0]->application_fee_amount ?? 0) / 100
            ]);

            // Atualizar status do financeiro
            $pagamento->financeiro->update([
                'status' => 'pago',
                'data_pagamento' => now(),
                'gateway' => 'stripe',
                'transaction_id' => $paymentIntent->id
            ]);
        }
    }

    /**
     * Processar falha no pagamento
     */
    private function handlePaymentFailed($paymentIntent)
    {
        $pagamento = PagamentoStripe::where('stripe_payment_intent_id', $paymentIntent->id)->first();
        
        if ($pagamento) {
            $pagamento->update([
                'status' => 'failed',
                'observacoes' => $paymentIntent->last_payment_error->message ?? 'Pagamento falhou'
            ]);
        }
    }

    /**
     * Processar cancelamento do pagamento
     */
    private function handlePaymentCanceled($paymentIntent)
    {
        $pagamento = PagamentoStripe::where('stripe_payment_intent_id', $paymentIntent->id)->first();
        
        if ($pagamento) {
            $pagamento->update([
                'status' => 'canceled'
            ]);
        }
    }

    /**
     * Listar pagamentos Stripe
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = PagamentoStripe::with(['cliente', 'processo', 'atendimento', 'financeiro'])
                               ->whereHas('financeiro', function($q) use ($user) {
                                   $q->where('unidade_id', $user->unidade_id);
                               });

        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->moeda) {
            $query->where('moeda', $request->moeda);
        }

        if ($request->cliente_id) {
            $query->where('cliente_id', $request->cliente_id);
        }

        $pagamentos = $query->orderBy('data_criacao', 'desc')
                           ->paginate($request->per_page ?? 15);

        return $this->paginated($pagamentos);
    }

    /**
     * Reembolsar pagamento
     */
    public function refund(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'valor' => 'nullable|numeric|min:0.01',
            'motivo' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        $pagamento = PagamentoStripe::whereHas('financeiro', function($q) use ($user) {
                                       $q->where('unidade_id', $user->unidade_id);
                                   })
                                   ->where('status', 'succeeded')
                                   ->findOrFail($id);

        try {
            $refundAmount = $request->valor ? intval($request->valor * 100) : null;

            $refund = \Stripe\Refund::create([
                'payment_intent' => $pagamento->stripe_payment_intent_id,
                'amount' => $refundAmount,
                'reason' => 'requested_by_customer',
                'metadata' => [
                    'motivo' => $request->motivo ?? 'Reembolso solicitado',
                    'usuario_id' => $user->id
                ]
            ]);

            $pagamento->update([
                'status' => 'refunded',
                'observacoes' => 'Reembolsado: ' . ($request->motivo ?? 'Sem motivo especificado')
            ]);

            // Atualizar financeiro se reembolso total
            if (!$refundAmount || $refundAmount >= ($pagamento->valor * 100)) {
                $pagamento->financeiro->update([
                    'status' => 'cancelado'
                ]);
            }

            return $this->success($refund, 'Reembolso processado com sucesso');

        } catch (\Exception $e) {
            return $this->error('Erro ao processar reembolso: ' . $e->getMessage(), 500);
        }
    }
}
EOF

# Mercado Pago Controller
cat > backend/app/Http/Controllers/Api/Admin/Financial/MercadoPagoController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Financial;

use App\Http\Controllers\Controller;
use App\Models\Financeiro;
use App\Models\PagamentoMercadoPago;
use App\Models\Cliente;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;

class MercadoPagoController extends Controller
{
    private $accessToken;
    private $baseUrl;

    public function __construct()
    {
        $this->accessToken = config('services.mercadopago.access_token');
        $this->baseUrl = 'https://api.mercadopago.com';
    }

    /**
     * @OA\Post(
     *     path="/admin/payments/mercadopago/create-preference",
     *     summary="Criar preferência de pagamento no Mercado Pago",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"financeiro_id","tipo"},
     *             @OA\Property(property="financeiro_id", type="integer"),
     *             @OA\Property(property="tipo", type="string", enum={"pix","boleto","cartao_credito","cartao_debito"})
     *         )
     *     ),
     *     @OA\Response(response=200, description="Preferência criada com sucesso")
     * )
     */
    public function createPreference(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'financeiro_id' => 'required|exists:financeiro,id',
            'tipo' => 'required|in:pix,boleto,cartao_credito,cartao_debito'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        $financeiro = Financeiro::where('unidade_id', $user->unidade_id)
                               ->where('status', 'pendente')
                               ->findOrFail($request->financeiro_id);

        $cliente = $financeiro->cliente;

        try {
            // Configurar métodos de pagamento baseado no tipo
            $paymentMethods = $this->getPaymentMethods($request->tipo);

            // Criar referência externa única
            $externalReference = 'FINANCEIRO_' . $financeiro->id . '_' . time();

            $preference = [
                'items' => [
                    [
                        'title' => $financeiro->descricao,
                        'quantity' => 1,
                        'unit_price' => (float) $financeiro->valor,
                        'currency_id' => 'BRL'
                    ]
                ],
                'payer' => [
                    'name' => $cliente->nome,
                    'email' => $cliente->email,
                    'identification' => [
                        'type' => strlen($cliente->cpf_cnpj) == 14 ? 'CPF' : 'CNPJ',
                        'number' => preg_replace('/\D/', '', $cliente->cpf_cnpj)
                    ]
                ],
                'payment_methods' => $paymentMethods,
                'external_reference' => $externalReference,
                'statement_descriptor' => 'Erlene Advogados',
                'expires' => true,
                'expiration_date_from' => now()->toISOString(),
                'expiration_date_to' => now()->addDays(30)->toISOString(),
                'notification_url' => route('api.mercadopago.webhook'),
                'back_urls' => [
                    'success' => config('app.frontend_url') . '/pagamento/sucesso',
                    'failure' => config('app.frontend_url') . '/pagamento/erro',
                    'pending' => config('app.frontend_url') . '/pagamento/pendente'
                ],
                'auto_return' => 'approved'
            ];

            // Configurações específicas por tipo
            if ($request->tipo === 'boleto') {
                $preference['expires'] = true;
                $preference['expiration_date_to'] = now()->addDays(3)->toISOString();
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->accessToken,
                'Content-Type' => 'application/json'
            ])->post($this->baseUrl . '/checkout/preferences', $preference);

            if (!$response->successful()) {
                throw new \Exception('Erro na API do Mercado Pago: ' . $response->body());
            }

            $responseData = $response->json();

            // Salvar no banco
            $pagamentoMP = PagamentoMercadoPago::create([
                'cliente_id' => $cliente->id,
                'processo_id' => $financeiro->processo_id,
                'atendimento_id' => $financeiro->atendimento_id,
                'financeiro_id' => $financeiro->id,
                'valor' => $financeiro->valor,
                'tipo' => $request->tipo,
                'status' => 'pending',
                'mp_preference_id' => $responseData['id'],
                'mp_external_reference' => $externalReference,
                'data_criacao' => now(),
                'data_vencimento' => $request->tipo === 'boleto' ? now()->addDays(3) : null
            ]);

            $result = [
                'preference_id' => $responseData['id'],
                'init_point' => $responseData['init_point'],
                'sandbox_init_point' => $responseData['sandbox_init_point'],
                'tipo' => $request->tipo,
                'valor' => $financeiro->valor,
                'pagamento_id' => $pagamentoMP->id
            ];

            // Para PIX, gerar QR Code
            if ($request->tipo === 'pix') {
                $result['qr_code'] = $this->generatePixQRCode($responseData['id']);
            }

            return $this->success($result, 'Preferência criada com sucesso');

        } catch (\Exception $e) {
            return $this->error('Erro ao criar preferência: ' . $e->getMessage(), 500);
        }
    }

    /**
     * @OA\Post(
     *     path="/admin/payments/mercadopago/webhook",
     *     summary="Webhook do Mercado Pago",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(type="object")
     *     ),
     *     @OA\Response(response=200, description="Webhook processado")
     * )
     */
    public function webhook(Request $request)
    {
        try {
            $type = $request->input('type');
            $dataId = $request->input('data.id');

            if ($type === 'payment') {
                $this->processPaymentNotification($dataId);
            }

            return response('OK', 200);

        } catch (\Exception $e) {
            \Log::error('Erro no webhook Mercado Pago: ' . $e->getMessage(), [
                'request' => $request->all()
            ]);
            
            return response('Error', 500);
        }
    }

    /**
     * Processar notificação de pagamento
     */
    private function processPaymentNotification($paymentId)
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->accessToken
        ])->get($this->baseUrl . '/v1/payments/' . $paymentId);

        if (!$response->successful()) {
            throw new \Exception('Erro ao buscar pagamento no Mercado Pago');
        }

        $payment = $response->json();
        $externalReference = $payment['external_reference'] ?? null;

        if (!$externalReference) {
            return;
        }

        $pagamentoMP = PagamentoMercadoPago::where('mp_external_reference', $externalReference)->first();

        if (!$pagamentoMP) {
            return;
        }

        // Atualizar dados do pagamento
        $pagamentoMP->update([
            'mp_payment_id' => $payment['id'],
            'status' => $payment['status'],
            'mp_metadata' => $payment,
            'data_pagamento' => $payment['status'] === 'approved' ? now() : null,
            'taxa_mp' => ($payment['fee_details'][0]['amount'] ?? 0),
            'linha_digitavel' => $payment['transaction_details']['payment_method_reference_id'] ?? null
        ]);

        // Atualizar financeiro se aprovado
        if ($payment['status'] === 'approved') {
            $pagamentoMP->financeiro->update([
                'status' => 'pago',
                'data_pagamento' => now(),
                'gateway' => 'mercadopago',
                'transaction_id' => $payment['id']
            ]);
        }
    }

    /**
     * Gerar QR Code PIX
     */
    private function generatePixQRCode($preferenceId)
    {
        // TODO: Implementar geração de QR Code PIX
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==";
    }

    /**
     * Configurar métodos de pagamento
     */
    private function getPaymentMethods($tipo)
    {
        switch ($tipo) {
            case 'pix':
                return [
                    'excluded_payment_types' => [
                        ['id' => 'credit_card'],
                        ['id' => 'debit_card'],
                        ['id' => 'ticket']
                    ],
                    'included_payment_methods' => [
                        ['id' => 'pix']
                    ]
                ];
                
            case 'boleto':
                return [
                    'excluded_payment_types' => [
                        ['id' => 'credit_card'],
                        ['id' => 'debit_card'],
                        ['id' => 'digital_wallet']
                    ],
                    'included_payment_methods' => [
                        ['id' => 'bolbradesco'],
                        ['id' => 'boletobancario']
                    ]
                ];
                
            case 'cartao_credito':
                return [
                    'excluded_payment_types' => [
                        ['id' => 'ticket'],
                        ['id' => 'bank_transfer'],
                        ['id' => 'debit_card']
                    ],
                    'installments' => 12
                ];
                
            case 'cartao_debito':
                return [
                    'excluded_payment_types' => [
                        ['id' => 'ticket'],
                        ['id' => 'bank_transfer'],
                        ['id' => 'credit_card']
                    ]
                ];
                
            default:
                return [];
        }
    }

    /**
     * Listar pagamentos Mercado Pago
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = PagamentoMercadoPago::with(['cliente', 'processo', 'atendimento', 'financeiro'])
                                   ->whereHas('financeiro', function($q) use ($user) {
                                       $q->where('unidade_id', $user->unidade_id);
                                   });

        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->tipo) {
            $query->where('tipo', $request->tipo);
        }

        if ($request->cliente_id) {
            $query->where('cliente_id', $request->cliente_id);
        }

        $pagamentos = $query->orderBy('data_criacao', 'desc')
                           ->paginate($request->per_page ?? 15);

        return $this->paginated($pagamentos);
    }

    /**
     * Cancelar pagamento
     */
    public function cancel($id)
    {
        $user = auth()->user();
        $pagamento = PagamentoMercadoPago::whereHas('financeiro', function($q) use ($user) {
                                           $q->where('unidade_id', $user->unidade_id);
                                       })
                                       ->whereIn('status', ['pending', 'in_process'])
                                       ->findOrFail($id);

        try {
            if ($pagamento->mp_payment_id) {
                $response = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $this->accessToken,
                    'Content-Type' => 'application/json'
                ])->put($this->baseUrl . '/v1/payments/' . $pagamento->mp_payment_id, [
                    'status' => 'cancelled'
                ]);

                if (!$response->successful()) {
                    throw new \Exception('Erro ao cancelar no Mercado Pago');
                }
            }

            $pagamento->update(['status' => 'cancelled']);

            return $this->success(null, 'Pagamento cancelado com sucesso');

        } catch (\Exception $e) {
            return $this->error('Erro ao cancelar pagamento: ' . $e->getMessage(), 500);
        }
    }
}
EOF

echo "✅ Controllers 9-12 criados com sucesso!"
echo "📊 Progresso: 12/20 Controllers do backend"
echo ""
echo "🚀 Controllers criados nesta parte:"
echo "   9. KanbanController (sistema kanban completo)"
echo "   10. UserController (gestão de usuários)"
echo "   11. StripeController (pagamentos internacionais)"
echo "   12. MercadoPagoController (PIX, Boleto, Cartão)"
echo ""
echo "⏭️  Continue executando para criar os próximos controllers..."