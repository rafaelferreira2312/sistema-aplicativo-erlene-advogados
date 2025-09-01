#!/bin/bash

# Script 114y - Backend Clientes Controller (Parte 1)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 114y-clientes-backend.sh && ./114y-clientes-backend.sh
# EXECUTE NA PASTA: backend/

echo "🚀 Criando Backend API para Clientes - Parte 1..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo "📝 1. Criando diretórios necessários..."

# Criar diretórios
mkdir -p app/Http/Controllers/Api/Admin/Clients
mkdir -p app/Services

echo "📝 2. Criando Controller de Clientes..."

# Criar Controller de Clientes
cat > app/Http/Controllers/Api/Admin/Clients/ClientController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Clients;

use App\Http\Controllers\Controller;
use App\Models\Cliente;
use App\Models\User;
use App\Services\ViaCepService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class ClientController extends Controller
{
    protected $viaCepService;

    public function __construct(ViaCepService $viaCepService)
    {
        $this->viaCepService = $viaCepService;
    }

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

        return $this->success($clientes);
    }

    /**
     * @OA\Get(
     *     path="/admin/clients/stats",
     *     summary="Estatísticas de clientes",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Estatísticas")
     * )
     */
    public function stats()
    {
        $user = auth()->user();
        
        $stats = [
            'total' => Cliente::where('unidade_id', $user->unidade_id)->count(),
            'ativos' => Cliente::where('unidade_id', $user->unidade_id)
                              ->where('status', 'ativo')->count(),
            'pf' => Cliente::where('unidade_id', $user->unidade_id)
                          ->where('tipo_pessoa', 'PF')->count(),
            'pj' => Cliente::where('unidade_id', $user->unidade_id)
                          ->where('tipo_pessoa', 'PJ')->count(),
        ];

        return $this->success($stats);
    }

    /**
     * @OA\Post(
     *     path="/admin/clients",
     *     summary="Criar cliente",
     *     security={{"bearerAuth":{}}},
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
            'endereco' => 'nullable|string',
            'cep' => 'nullable|string|max:9',
            'cidade' => 'nullable|string|max:100',
            'estado' => 'nullable|string|size:2',
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
            'endereco' => 'nullable|string',
            'cep' => 'nullable|string|max:9',
            'cidade' => 'nullable|string|max:100',
            'estado' => 'nullable|string|size:2',
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
     *     @OA\Response(response=200, description="Cliente excluído com sucesso")
     * )
     */
    public function destroy($id)
    {
        $user = auth()->user();
        $cliente = Cliente::where('unidade_id', $user->unidade_id)->findOrFail($id);
        
        // Verificar se tem processos ativos
        if ($cliente->processos()->where('status', '!=', 'arquivado')->count() > 0) {
            return $this->error('Não é possível excluir cliente com processos ativos', 400);
        }

        $cliente->delete();
        return $this->success(null, 'Cliente excluído com sucesso');
    }

    /**
     * @OA\Get(
     *     path="/admin/clients/buscar-cep/{cep}",
     *     summary="Buscar endereço por CEP",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Endereço encontrado")
     * )
     */
    public function buscarCep($cep)
    {
        try {
            $endereco = $this->viaCepService->buscarCep($cep);
            return $this->success($endereco);
        } catch (\Exception $e) {
            return $this->error('CEP não encontrado', 404);
        }
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

echo "✅ Script 114y Parte 1 concluído!"
echo "📝 Controller ClientController criado com sucesso"
echo ""
echo "Digite 'continuar' para prosseguir com a Parte 2 (ViaCEP Service)..."