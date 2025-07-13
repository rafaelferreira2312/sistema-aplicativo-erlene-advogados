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
