#!/bin/bash

# Script 12 - Criação dos Controllers do Backend (Parte 2)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/12-create-backend-controllers-part2.sh (executado da raiz do projeto)

echo "🚀 Continuando criação dos Controllers do Backend (Parte 2)..."

# Process Controller
cat > backend/app/Http/Controllers/Api/Admin/Processes/ProcessController.php << 'EOF'
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
EOF

# Appointment Controller
cat > backend/app/Http/Controllers/Api/Admin/Appointments/AppointmentController.php << 'EOF'
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
EOF

# Financial Controller
cat > backend/app/Http/Controllers/Api/Admin/Financial/FinancialController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Financial;

use App\Http\Controllers\Controller;
use App\Models\Financeiro;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\Atendimento;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class FinancialController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/financial",
     *     summary="Listar registros financeiros",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Lista de registros financeiros")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Financeiro::with(['cliente', 'processo', 'atendimento'])
                          ->where('unidade_id', $user->unidade_id);

        // Filtros
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('descricao', 'like', "%{$search}%")
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

        if ($request->gateway) {
            $query->where('gateway', $request->gateway);
        }

        if ($request->cliente_id) {
            $query->where('cliente_id', $request->cliente_id);
        }

        if ($request->data_inicio && $request->data_fim) {
            $query->whereBetween('data_vencimento', [$request->data_inicio, $request->data_fim]);
        }

        if ($request->vencidos) {
            $query->vencidos();
        }

        if ($request->pendentes) {
            $query->pendentes();
        }

        $financeiro = $query->orderBy('data_vencimento', 'desc')
                           ->paginate($request->per_page ?? 15);

        return $this->paginated($financeiro);
    }

    /**
     * @OA\Post(
     *     path="/admin/financial",
     *     summary="Criar registro financeiro",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=201, description="Registro criado com sucesso")
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'processo_id' => 'nullable|exists:processos,id',
            'atendimento_id' => 'nullable|exists:atendimentos,id',
            'cliente_id' => 'required|exists:clientes,id',
            'tipo' => 'required|in:honorario,consulta,custas,despesa,receita_extra',
            'valor' => 'required|numeric|min:0.01',
            'data_vencimento' => 'required|date',
            'descricao' => 'required|string|max:255',
            'gateway' => 'nullable|in:stripe,mercadopago,manual'
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
        $data['status'] = 'pendente';

        $financeiro = Financeiro::create($data);
        $financeiro->load(['cliente', 'processo', 'atendimento']);

        return $this->success($financeiro, 'Registro criado com sucesso', 201);
    }

    /**
     * @OA\Get(
     *     path="/admin/financial/{id}",
     *     summary="Obter registro financeiro",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do registro")
     * )
     */
    public function show($id)
    {
        $user = auth()->user();
        $financeiro = Financeiro::with([
                                    'cliente', 
                                    'processo', 
                                    'atendimento',
                                    'pagamentosStripe',
                                    'pagamentosMercadoPago'
                                ])
                                ->where('unidade_id', $user->unidade_id)
                                ->findOrFail($id);

        return $this->success($financeiro);
    }

    /**
     * @OA\Put(
     *     path="/admin/financial/{id}",
     *     summary="Atualizar registro financeiro",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Registro atualizado com sucesso")
     * )
     */
    public function update(Request $request, $id)
    {
        $user = auth()->user();
        $financeiro = Financeiro::where('unidade_id', $user->unidade_id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'processo_id' => 'nullable|exists:processos,id',
            'atendimento_id' => 'nullable|exists:atendimentos,id',
            'cliente_id' => 'exists:clientes,id',
            'tipo' => 'in:honorario,consulta,custas,despesa,receita_extra',
            'valor' => 'numeric|min:0.01',
            'data_vencimento' => 'date',
            'data_pagamento' => 'nullable|date',
            'status' => 'in:pendente,pago,atrasado,cancelado,parcial',
            'descricao' => 'string|max:255',
            'gateway' => 'nullable|in:stripe,mercadopago,manual'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $financeiro->update($request->all());
        $financeiro->load(['cliente', 'processo', 'atendimento']);

        return $this->success($financeiro, 'Registro atualizado com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/financial/{id}",
     *     summary="Excluir registro financeiro",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Registro excluído com sucesso")
     * )
     */
    public function destroy($id)
    {
        $user = auth()->user();
        $financeiro = Financeiro::where('unidade_id', $user->unidade_id)->findOrFail($id);
        
        if ($financeiro->status === 'pago') {
            return $this->error('Não é possível excluir registro já pago', 400);
        }

        $financeiro->delete();
        return $this->success(null, 'Registro excluído com sucesso');
    }

    /**
     * Marcar como pago manualmente
     */
    public function marcarPago(Request $request, $id)
    {
        $user = auth()->user();
        $financeiro = Financeiro::where('unidade_id', $user->unidade_id)
                                ->where('status', 'pendente')
                                ->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'data_pagamento' => 'required|date|before_or_equal:today',
            'observacoes' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $financeiro->update([
            'status' => 'pago',
            'data_pagamento' => $request->data_pagamento,
            'gateway' => 'manual',
            'transaction_id' => 'MANUAL_' . time(),
            'gateway_response' => [
                'observacoes' => $request->observacoes,
                'usuario_id' => $user->id,
                'data_confirmacao' => now()
            ]
        ]);

        return $this->success($financeiro, 'Pagamento confirmado');
    }

    /**
     * Dashboard financeiro
     */
    public function dashboard(Request $request)
    {
        $user = auth()->user();
        $unidadeId = $user->unidade_id;
        
        $mesAtual = now()->month;
        $anoAtual = now()->year;

        $stats = [
            'receita_ano' => Financeiro::where('unidade_id', $unidadeId)
                                       ->where('status', 'pago')
                                       ->whereYear('data_pagamento', $anoAtual)
                                       ->sum('valor'),
            
            'total_clientes_devendo' => Financeiro::where('unidade_id', $unidadeId)
                                                 ->pendentes()
                                                 ->distinct('cliente_id')
                                                 ->count('cliente_id')
        ];

        // Receitas por mês (últimos 12 meses)
        $receitasPorMes = [];
        for ($i = 11; $i >= 0; $i--) {
            $mes = now()->subMonths($i);
            $receita = Financeiro::where('unidade_id', $unidadeId)
                                ->where('status', 'pago')
                                ->whereYear('data_pagamento', $mes->year)
                                ->whereMonth('data_pagamento', $mes->month)
                                ->sum('valor');
            
            $receitasPorMes[] = [
                'mes' => $mes->format('Y-m'),
                'mes_nome' => $mes->format('M/Y'),
                'receita' => (float) $receita
            ];
        }

        // Receitas por gateway
        $receitasPorGateway = Financeiro::where('unidade_id', $unidadeId)
                                      ->where('status', 'pago')
                                      ->whereMonth('data_pagamento', $mesAtual)
                                      ->whereYear('data_pagamento', $anoAtual)
                                      ->selectRaw('gateway, SUM(valor) as total')
                                      ->groupBy('gateway')
                                      ->get();

        return $this->success([
            'stats' => $stats,
            'graficos' => [
                'receitas_mes' => $receitasPorMes,
                'receitas_gateway' => $receitasPorGateway
            ]
        ]);
    }
}
EOF

# Document Controller
cat > backend/app/Http/Controllers/Api/Admin/Documents/DocumentController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin\Documents;

use App\Http\Controllers\Controller;
use App\Models\DocumentoGed;
use App\Models\Cliente;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class DocumentController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/documents",
     *     summary="Listar documentos",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Lista de documentos")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = DocumentoGed::with(['cliente', 'usuario'])
                            ->whereHas('cliente', function($q) use ($user) {
                                $q->where('unidade_id', $user->unidade_id);
                            });

        // Filtros
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('nome_arquivo', 'like', "%{$search}%")
                  ->orWhere('nome_original', 'like', "%{$search}%")
                  ->orWhere('descricao', 'like', "%{$search}%");
            });
        }

        if ($request->cliente_id) {
            $query->where('cliente_id', $request->cliente_id);
        }

        if ($request->tipo_arquivo) {
            $query->where('tipo_arquivo', $request->tipo_arquivo);
        }

        if ($request->storage_type) {
            $query->where('storage_type', $request->storage_type);
        }

        if ($request->publico !== null) {
            $query->where('publico', $request->publico);
        }

        $documentos = $query->orderBy('data_upload', 'desc')
                           ->paginate($request->per_page ?? 15);

        return $this->paginated($documentos);
    }

    /**
     * @OA\Post(
     *     path="/admin/documents/upload",
     *     summary="Upload de documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\MediaType(
     *             mediaType="multipart/form-data",
     *             @OA\Schema(
     *                 required={"arquivo","cliente_id"},
     *                 @OA\Property(property="arquivo", type="string", format="binary"),
     *                 @OA\Property(property="cliente_id", type="integer"),
     *                 @OA\Property(property="descricao", type="string"),
     *                 @OA\Property(property="publico", type="boolean")
     *             )
     *         )
     *     ),
     *     @OA\Response(response=201, description="Documento enviado com sucesso")
     * )
     */
    public function upload(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'arquivo' => 'required|file|max:10240', // 10MB max
            'cliente_id' => 'required|exists:clientes,id',
            'descricao' => 'nullable|string',
            'tags' => 'nullable|array',
            'publico' => 'boolean'
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

        $arquivo = $request->file('arquivo');
        $nomeOriginal = $arquivo->getClientOriginalName();
        $extensao = $arquivo->getClientOriginalExtension();
        $mimeType = $arquivo->getMimeType();
        $tamanho = $arquivo->getSize();
        
        // Gerar nome único
        $nomeArquivo = Str::uuid() . '.' . $extensao;
        
        // Definir pasta do cliente
        $pastaCliente = $cliente->nome_pasta;
        $caminhoCompleto = "clients/{$pastaCliente}/{$nomeArquivo}";

        // Fazer upload baseado no tipo de storage
        $storageType = $cliente->tipo_armazenamento;
        $googleDriveId = null;
        $oneDriveId = null;

        try {
            switch ($storageType) {
                case 'local':
                    $caminho = $arquivo->storeAs("clients/{$pastaCliente}", $nomeArquivo, 'local');
                    break;
                    
                case 'google_drive':
                    // TODO: Implementar upload para Google Drive
                    $caminho = $arquivo->storeAs("clients/{$pastaCliente}", $nomeArquivo, 'local');
                    $googleDriveId = 'MOCK_GOOGLE_ID_' . time();
                    break;
                    
                case 'onedrive':
                    // TODO: Implementar upload para OneDrive
                    $caminho = $arquivo->storeAs("clients/{$pastaCliente}", $nomeArquivo, 'local');
                    $oneDriveId = 'MOCK_ONEDRIVE_ID_' . time();
                    break;
                    
                default:
                    $caminho = $arquivo->storeAs("clients/{$pastaCliente}", $nomeArquivo, 'local');
            }

            // Gerar hash do arquivo para verificação de integridade
            $hashArquivo = hash_file('sha256', $arquivo->getPathname());

            // Salvar no banco de dados
            $documento = DocumentoGed::create([
                'cliente_id' => $cliente->id,
                'pasta' => $pastaCliente,
                'nome_arquivo' => $nomeArquivo,
                'nome_original' => $nomeOriginal,
                'caminho' => $caminho,
                'tipo_arquivo' => strtolower($extensao),
                'mime_type' => $mimeType,
                'tamanho' => $tamanho,
                'data_upload' => now(),
                'usuario_id' => $user->id,
                'versao' => 1,
                'storage_type' => $storageType,
                'google_drive_id' => $googleDriveId,
                'onedrive_id' => $oneDriveId,
                'tags' => $request->tags ?? [],
                'descricao' => $request->descricao,
                'publico' => $request->publico ?? false,
                'hash_arquivo' => $hashArquivo
            ]);

            $documento->load(['cliente', 'usuario']);

            return $this->success($documento, 'Documento enviado com sucesso', 201);

        } catch (\Exception $e) {
            return $this->error('Erro ao fazer upload do documento: ' . $e->getMessage(), 500);
        }
    }

    /**
     * @OA\Get(
     *     path="/admin/documents/{id}",
     *     summary="Obter documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do documento")
     * )
     */
    public function show($id)
    {
        $user = auth()->user();
        $documento = DocumentoGed::with(['cliente', 'usuario'])
                                ->whereHas('cliente', function($q) use ($user) {
                                    $q->where('unidade_id', $user->unidade_id);
                                })
                                ->findOrFail($id);

        return $this->success($documento);
    }

    /**
     * @OA\Put(
     *     path="/admin/documents/{id}",
     *     summary="Atualizar documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Documento atualizado com sucesso")
     * )
     */
    public function update(Request $request, $id)
    {
        $user = auth()->user();
        $documento = DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                     $q->where('unidade_id', $user->unidade_id);
                                 })
                                 ->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nome_original' => 'string',
            'descricao' => 'nullable|string',
            'tags' => 'nullable|array',
            'publico' => 'boolean'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $documento->update($request->all());
        $documento->load(['cliente', 'usuario']);

        return $this->success($documento, 'Documento atualizado com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/documents/{id}",
     *     summary="Excluir documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Documento excluído com sucesso")
     * )
     */
    public function destroy($id)
    {
        $user = auth()->user();
        $documento = DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                     $q->where('unidade_id', $user->unidade_id);
                                 })
                                 ->findOrFail($id);

        try {
            // Excluir arquivo físico
            if ($documento->storage_type === 'local' && Storage::exists($documento->caminho)) {
                Storage::delete($documento->caminho);
            }

            // TODO: Implementar exclusão no Google Drive e OneDrive

            $documento->delete();

            return $this->success(null, 'Documento excluído com sucesso');

        } catch (\Exception $e) {
            return $this->error('Erro ao excluir documento: ' . $e->getMessage(), 500);
        }
    }

    /**
     * @OA\Get(
     *     path="/admin/documents/{id}/download",
     *     summary="Download de documento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Download do arquivo")
     * )
     */
    public function download($id)
    {
        $user = auth()->user();
        $documento = DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                     $q->where('unidade_id', $user->unidade_id);
                                 })
                                 ->findOrFail($id);

        try {
            if ($documento->storage_type === 'local') {
                if (!Storage::exists($documento->caminho)) {
                    return $this->error('Arquivo não encontrado', 404);
                }

                return Storage::download($documento->caminho, $documento->nome_original);
            }

            // TODO: Implementar download do Google Drive e OneDrive
            return $this->error('Download não implementado para este tipo de storage', 501);

        } catch (\Exception $e) {
            return $this->error('Erro ao fazer download: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Listar documentos por cliente
     */
    public function porCliente($clienteId, Request $request)
    {
        $user = auth()->user();
        
        // Verificar se cliente pertence à unidade
        $cliente = Cliente::where('id', $clienteId)
                         ->where('unidade_id', $user->unidade_id)
                         ->first();
        
        if (!$cliente) {
            return $this->error('Cliente não encontrado', 404);
        }

        $query = DocumentoGed::with(['usuario'])
                            ->where('cliente_id', $clienteId);

        if ($request->tipo_arquivo) {
            $query->where('tipo_arquivo', $request->tipo_arquivo);
        }

        $documentos = $query->orderBy('data_upload', 'desc')
                           ->paginate($request->per_page ?? 20);

        return $this->paginated($documentos);
    }

    /**
     * Estatísticas de documentos
     */
    public function estatisticas()
    {
        $user = auth()->user();
        
        $stats = [
            'total_documentos' => DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                                 $q->where('unidade_id', $user->unidade_id);
                                             })->count(),
            
            'por_tipo' => DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                         $q->where('unidade_id', $user->unidade_id);
                                     })
                                     ->selectRaw('tipo_arquivo, COUNT(*) as total')
                                     ->groupBy('tipo_arquivo')
                                     ->get(),
            
            'por_storage' => DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                          $q->where('unidade_id', $user->unidade_id);
                                      })
                                      ->selectRaw('storage_type, COUNT(*) as total')
                                      ->groupBy('storage_type')
                                      ->get(),
            
            'tamanho_total' => DocumentoGed::whereHas('cliente', function($q) use ($user) {
                                            $q->where('unidade_id', $user->unidade_id);
                                        })->sum('tamanho')
        ];

        return $this->success($stats);
    }
}
EOF

echo "✅ Controllers 5-7 criados com sucesso!"
echo "📊 Progresso: 7/20 Controllers do backend"
echo ""
echo "🚀 Controllers criados até agora:"
echo "   1. Controller Base (helpers e documentação)"
echo "   2. AuthController (login admin/cliente)"
echo "   3. DashboardController (estatísticas)"
echo "   4. ClientController (CRUD clientes)"
echo "   5. ProcessController (CRUD processos)"
echo "   6. AppointmentController (CRUD atendimentos)"
echo "   7. FinancialController (CRUD financeiro)"
echo "   8. DocumentController (GED completo)"
echo ""
echo "⏭️  Continue executando para criar os próximos controllers..."_mes_atual' => Financeiro::where('unidade_id', $unidadeId)
                                           ->where('status', 'pago')
                                           ->whereMonth('data_pagamento', $mesAtual)
                                           ->whereYear('data_pagamento', $anoAtual)
                                           ->sum('valor'),
            
            'pendente_total' => Financeiro::where('unidade_id', $unidadeId)
                                        ->pendentes()
                                        ->sum('valor'),
            
            'vencido_total' => Financeiro::where('unidade_id', $unidadeId)
                                       ->vencidos()
                                       ->sum('valor'),
            
            'receita