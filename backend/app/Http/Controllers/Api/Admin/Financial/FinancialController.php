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
