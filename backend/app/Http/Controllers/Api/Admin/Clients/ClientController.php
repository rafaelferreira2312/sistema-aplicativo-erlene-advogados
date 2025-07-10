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
