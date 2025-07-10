<?php

namespace App\Http\Controllers\Api\Admin\Processes;

use App\Http\Controllers\Controller;
use App\Models\Processo;
use App\Models\Cliente;
use App\Models\Tribunal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProcessController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/processes",
     *     summary="Listar processos",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="page", in="query", @OA\Schema(type="integer")),
     *     @OA\Parameter(name="search", in="query", @OA\Schema(type="string")),
     *     @OA\Parameter(name="status", in="query", @OA\Schema(type="string")),
     *     @OA\Parameter(name="prioridade", in="query", @OA\Schema(type="string")),
     *     @OA\Response(response=200, description="Lista de processos")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Processo::with(['cliente', 'advogado', 'unidade'])
                        ->where('unidade_id', $user->unidade_id);

        // Filtros
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('numero', 'like', "%{$search}%")
                  ->orWhere('tipo_acao', 'like', "%{$search}%")
                  ->orWhereHas('cliente', function($subQ) use ($search) {
                      $subQ->where('nome', 'like', "%{$search}%");
                  });
            });
        }

        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->prioridade) {
            $query->where('prioridade', $request->prioridade);
        }

        if ($request->advogado_id) {
            $query->where('advogado_id', $request->advogado_id);
        }

        if ($request->cliente_id) {
            $query->where('cliente_id', $request->cliente_id);
        }

        if ($request->prazo_vencendo) {
            $query->comPrazoVencendo(7);
        }

        $processos = $query->orderBy('created_at', 'desc')
                          ->paginate($request->per_page ?? 15);

        return $this->paginated($processos);
    }

    /**
     * @OA\Post(
     *     path="/admin/processes",
     *     summary="Criar processo",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"numero","cliente_id","tipo_acao","tribunal","data_distribuicao","advogado_id"},
     *             @OA\Property(property="numero", type="string"),
     *             @OA\Property(property="cliente_id", type="integer"),
     *             @OA\Property(property="tipo_acao", type="string"),
     *             @OA\Property(property="tribunal", type="string"),
     *             @OA\Property(property="data_distribuicao", type="string", format="date"),
     *             @OA\Property(property="advogado_id", type="integer")
     *         )
     *     ),
     *     @OA\Response(response=201, description="Processo criado com sucesso")
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'numero' => 'required|string|unique:processos,numero|regex:/^\d{7}-\d{2}\.\d{4}\.\d{1}\.\d{2}\.\d{4}$/',
            'tribunal' => 'required|string',
            'vara' => 'nullable|string',
            'cliente_id' => 'required|exists:clientes,id',
            'tipo_acao' => 'required|string',
            'status' => 'in:distribuido,em_andamento,suspenso,arquivado,finalizado',
            'valor_causa' => 'nullable|numeric|min:0',
            'data_distribuicao' => 'required|date',
            'advogado_id' => 'required|exists:users,id',
            'proximo_prazo' => 'nullable|date|after:today',
            'observacoes' => 'nullable|string',
            'prioridade' => 'in:baixa,media,alta,urgente'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        // Verificar se cliente pertence à unidade
        $cliente = Cliente::where('id', $request->cliente_id)
                         ->where('unidade_id', $user->unidade_id)
                         ->first();
        
        if (!$cliente) {
            return $this->error('Cliente não encontrado', 404);
        }

        $data = $request->all();
        $data['unidade_id'] = $user->unidade_id;
        $data['status'] = $data['status'] ?? 'distribuido';
        $data['prioridade'] = $data['prioridade'] ?? 'media';

        $processo = Processo::create($data);
        $processo->load(['cliente', 'advogado', 'unidade']);

        return $this->success($processo, 'Processo criado com sucesso', 201);
    }

    /**
     * @OA\Get(
     *     path="/admin/processes/{id}",
     *     summary="Obter processo",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Dados do processo")
     * )
     */
    public function show($id)
    {
        $user = auth()->user();
        $processo = Processo::with([
                                'cliente', 
                                'advogado', 
                                'unidade', 
                                'movimentacoes', 
                                'atendimentos',
                                'financeiro',
                                'tarefas'
                            ])
                           ->where('unidade_id', $user->unidade_id)
                           ->findOrFail($id);

        return $this->success($processo);
    }

    /**
     * @OA\Put(
     *     path="/admin/processes/{id}",
     *     summary="Atualizar processo",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Processo atualizado com sucesso")
     * )
     */
    public function update(Request $request, $id)
    {
        $user = auth()->user();
        $processo = Processo::where('unidade_id', $user->unidade_id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'numero' => 'string|unique:processos,numero,' . $id . '|regex:/^\d{7}-\d{2}\.\d{4}\.\d{1}\.\d{2}\.\d{4}$/',
            'tribunal' => 'string',
            'vara' => 'nullable|string',
            'cliente_id' => 'exists:clientes,id',
            'tipo_acao' => 'string',
            'status' => 'in:distribuido,em_andamento,suspenso,arquivado,finalizado',
            'valor_causa' => 'nullable|numeric|min:0',
            'data_distribuicao' => 'date',
            'advogado_id' => 'exists:users,id',
            'proximo_prazo' => 'nullable|date',
            'observacoes' => 'nullable|string',
            'prioridade' => 'in:baixa,media,alta,urgente'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $processo->update($request->all());
        $processo->load(['cliente', 'advogado', 'unidade']);

        return $this->success($processo, 'Processo atualizado com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/processes/{id}",
     *     summary="Excluir processo",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Processo excluído com sucesso")
     * )
     */
    public function destroy($id)
    {
        $user = auth()->user();
        $processo = Processo::where('unidade_id', $user->unidade_id)->findOrFail($id);
        
        // Verificar se pode ser excluído
        if ($processo->movimentacoes()->count() > 0) {
            return $this->error('Não é possível excluir processo com movimentações', 400);
        }

        $processo->delete();
        return $this->success(null, 'Processo excluído com sucesso');
    }

    /**
     * Consultar processo nos tribunais
     */
    public function consultar($id)
    {
        $user = auth()->user();
        $processo = Processo::where('unidade_id', $user->unidade_id)->findOrFail($id);
        
        // TODO: Implementar integração com tribunais
        // Por enquanto, retorna mock
        
        return $this->success([
            'processo' => $processo->numero_formatado,
            'ultima_consulta' => now(),
            'movimentacoes_encontradas' => 0,
            'status_tribunal' => 'Em andamento'
        ], 'Consulta realizada com sucesso');
    }

    /**
     * Obter tribunais disponíveis
     */
    public function tribunais()
    {
        $tribunais = Tribunal::ativos()
                           ->select('id', 'nome', 'codigo', 'tipo', 'estado')
                           ->orderBy('nome')
                           ->get();

        return $this->success($tribunais);
    }
}
