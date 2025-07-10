<?php

namespace App\Http\Controllers\Api\Admin\Appointments;

use App\Http\Controllers\Controller;
use App\Models\Atendimento;
use App\Models\Cliente;
use App\Models\Processo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AppointmentController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/appointments",
     *     summary="Listar atendimentos",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Lista de atendimentos")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Atendimento::with(['cliente', 'advogado', 'processos'])
                           ->where('unidade_id', $user->unidade_id);

        // Filtros
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('assunto', 'like', "%{$search}%")
                  ->orWhereHas('cliente', function($subQ) use ($search) {
                      $subQ->where('nome', 'like', "%{$search}%");
                  });
            });
        }

        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->tipo) {
            $query->where('tipo', $request->tipo);
        }

        if ($request->advogado_id) {
            $query->where('advogado_id', $request->advogado_id);
        }

        if ($request->data_inicio && $request->data_fim) {
            $query->whereBetween('data_hora', [$request->data_inicio, $request->data_fim]);
        }

        if ($request->hoje) {
            $query->hoje();
        }

        $atendimentos = $query->orderBy('data_hora', 'desc')
                             ->paginate($request->per_page ?? 15);

        return $this->paginated($atendimentos);
    }

    /**
     * @OA\Post(
     *     path="/admin/appointments",
     *     summary="Criar atendimento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=201, description="Atendimento criado com sucesso")
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'cliente_id' => 'required|exists:clientes,id',
            'advogado_id' => 'required|exists:users,id',
            'data_hora' => 'required|date|after:now',
            'tipo' => 'required|in:presencial,online,telefone',
            'assunto' => 'required|string|max:255',
            'descricao' => 'required|string',
            'duracao' => 'nullable|integer|min:15|max:480',
            'valor' => 'nullable|numeric|min:0',
            'proximos_passos' => 'nullable|string',
            'processos' => 'nullable|array',
            'processos.*' => 'exists:processos,id'
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

        $data = $request->except('processos');
        $data['unidade_id'] = $user->unidade_id;
        $data['status'] = 'agendado';

        $atendimento = Atendimento::create($data);

        // Vincular processos se fornecidos
        if ($request->processos) {
            $atendimento->processos()->sync($request->processos);
        }

        $atendimento->load(['cliente', 'advogado', 'processos']);

        return $this->success($atendimento, 'Atendimento criado com sucesso', 201);
    }

    /**
     * @OA\Get(
     *     path="/admin/appointments/{id}",
     *     summary="Obter atendimento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do atendimento")
     * )
     */
    public function show($id)
    {
        $user = auth()->user();
        $atendimento = Atendimento::with(['cliente', 'advogado', 'processos', 'financeiro'])
                                 ->where('unidade_id', $user->unidade_id)
                                 ->findOrFail($id);

        return $this->success($atendimento);
    }

    /**
     * @OA\Put(
     *     path="/admin/appointments/{id}",
     *     summary="Atualizar atendimento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Atendimento atualizado com sucesso")
     * )
     */
    public function update(Request $request, $id)
    {
        $user = auth()->user();
        $atendimento = Atendimento::where('unidade_id', $user->unidade_id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'cliente_id' => 'exists:clientes,id',
            'advogado_id' => 'exists:users,id',
            'data_hora' => 'date',
            'tipo' => 'in:presencial,online,telefone',
            'assunto' => 'string|max:255',
            'descricao' => 'string',
            'status' => 'in:agendado,em_andamento,concluido,cancelado',
            'duracao' => 'nullable|integer|min:15|max:480',
            'valor' => 'nullable|numeric|min:0',
            'proximos_passos' => 'nullable|string',
            'processos' => 'nullable|array',
            'processos.*' => 'exists:processos,id'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $atendimento->update($request->except('processos'));

        // Atualizar processos vinculados
        if ($request->has('processos')) {
            $atendimento->processos()->sync($request->processos ?? []);
        }

        $atendimento->load(['cliente', 'advogado', 'processos']);

        return $this->success($atendimento, 'Atendimento atualizado com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/appointments/{id}",
     *     summary="Excluir atendimento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Atendimento excluído com sucesso")
     * )
     */
    public function destroy($id)
    {
        $user = auth()->user();
        $atendimento = Atendimento::where('unidade_id', $user->unidade_id)->findOrFail($id);
        
        if ($atendimento->status === 'concluido') {
            return $this->error('Não é possível excluir atendimento concluído', 400);
        }

        $atendimento->delete();
        return $this->success(null, 'Atendimento excluído com sucesso');
    }

    /**
     * Iniciar atendimento
     */
    public function iniciar($id)
    {
        $user = auth()->user();
        $atendimento = Atendimento::where('unidade_id', $user->unidade_id)
                                 ->where('status', 'agendado')
                                 ->findOrFail($id);

        $atendimento->update(['status' => 'em_andamento']);

        return $this->success($atendimento, 'Atendimento iniciado');
    }

    /**
     * Finalizar atendimento
     */
    public function finalizar(Request $request, $id)
    {
        $user = auth()->user();
        $atendimento = Atendimento::where('unidade_id', $user->unidade_id)
                                 ->where('status', 'em_andamento')
                                 ->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'proximos_passos' => 'nullable|string',
            'observacoes_finais' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $atendimento->update([
            'status' => 'concluido',
            'proximos_passos' => $request->proximos_passos,
            'observacoes' => $request->observacoes_finais
        ]);

        return $this->success($atendimento, 'Atendimento finalizado');
    }
}
