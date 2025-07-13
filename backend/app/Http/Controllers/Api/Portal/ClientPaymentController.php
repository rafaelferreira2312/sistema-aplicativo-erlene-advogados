<?php

namespace App\Http\Controllers\Api\Portal;

use App\Http\Controllers\Controller;
use App\Models\Financeiro;
use App\Models\PagamentoStripe;
use App\Models\PagamentoMercadoPago;
use Illuminate\Http\Request;

class ClientPaymentController extends Controller
{
    /**
     * @OA\Get(
     *     path="/portal/payments",
     *     summary="Listar pagamentos do cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Lista de pagamentos")
     * )
     */
    public function index(Request $request)
    {
        $cliente = auth('cliente')->user();
        
        $query = $cliente->financeiro()->with(['processo', 'atendimento']);

        // Filtros
        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->tipo) {
            $query->where('tipo', $request->tipo);
        }

        if ($request->vencidos) {
            $query->vencidos();
        }

        if ($request->pendentes) {
            $query->pendentes();
        }

        $pagamentos = $query->orderBy('data_vencimento', 'desc')
                           ->paginate($request->per_page ?? 15);

        // Registrar acesso
        $cliente->acessosPortal()->create([
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data_acesso' => now(),
            'acao' => 'visualizar_pagamentos'
        ]);

        return $this->paginated($pagamentos);
    }

    /**
     * @OA\Get(
     *     path="/portal/payments/{id}",
     *     summary="Obter detalhes do pagamento",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Detalhes do pagamento")
     * )
     */
    public function show($id)
    {
        $cliente = auth('cliente')->user();
        
        $pagamento = $cliente->financeiro()
                           ->with([
                               'processo',
                               'atendimento',
                               'pagamentosStripe',
                               'pagamentosMercadoPago'
                           ])
                           ->findOrFail($id);

        return $this->success($pagamento);
    }

    /**
     * Iniciar pagamento via Stripe
     */
    public function payWithStripe(Request $request, $id)
    {
        $validator = \Validator::make($request->all(), [
            'moeda' => 'required|in:BRL,USD,EUR'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $cliente = auth('cliente')->user();
        $financeiro = $cliente->financeiro()
                            ->where('status', 'pendente')
                            ->findOrFail($id);

        try {
            // Usar o StripeController para criar payment intent
            $stripeController = new \App\Http\Controllers\Api\Admin\Financial\StripeController();
            
            $fakeRequest = new Request([
                'financeiro_id' => $financeiro->id,
                'moeda' => $request->moeda
            ]);

            // Simular autenticação admin temporariamente
            $originalUser = auth()->user();
            auth()->login($cliente->responsavel);
            
            $response = $stripeController->createPaymentIntent($fakeRequest);
            
            // Restaurar autenticação do cliente
            auth('cliente')->login($cliente);

            return $response;

        } catch (\Exception $e) {
            return $this->error('Erro ao iniciar pagamento: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Iniciar pagamento via Mercado Pago
     */
    public function payWithMercadoPago(Request $request, $id)
    {
        $validator = \Validator::make($request->all(), [
            'tipo' => 'required|in:pix,boleto,cartao_credito,cartao_debito'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $cliente = auth('cliente')->user();
        $financeiro = $cliente->financeiro()
                            ->where('status', 'pendente')
                            ->findOrFail($id);

        try {
            // Usar o MercadoPagoController
            $mpController = new \App\Http\Controllers\Api\Admin\Financial\MercadoPagoController();
            
            $fakeRequest = new Request([
                'financeiro_id' => $financeiro->id,
                'tipo' => $request->tipo
            ]);

            // Simular autenticação admin temporariamente
            auth()->login($cliente->responsavel);
            
            $response = $mpController->createPreference($fakeRequest);
            
            // Restaurar autenticação do cliente
            auth('cliente')->login($cliente);

            return $response;

        } catch (\Exception $e) {
            return $this->error('Erro ao iniciar pagamento: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Histórico de pagamentos realizados
     */
    public function history(Request $request)
    {
        $cliente = auth('cliente')->user();
        
        $query = $cliente->financeiro()
                       ->where('status', 'pago')
                       ->with(['processo', 'atendimento']);

        if ($request->data_inicio && $request->data_fim) {
            $query->whereBetween('data_pagamento', [$request->data_inicio, $request->data_fim]);
        }

        $historico = $query->orderBy('data_pagamento', 'desc')
                          ->paginate($request->per_page ?? 15);

        return $this->paginated($historico);
    }

    /**
     * Comprovantes de pagamento
     */
    public function receipt($id)
    {
        $cliente = auth('cliente')->user();
        
        $pagamento = $cliente->financeiro()
                           ->where('status', 'pago')
                           ->with([
                               'processo',
                               'atendimento',
                               'pagamentosStripe',
                               'pagamentosMercadoPago'
                           ])
                           ->findOrFail($id);

        // Registrar acesso ao comprovante
        $cliente->acessosPortal()->create([
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data_acesso' => now(),
            'acao' => 'visualizar_comprovante',
            'detalhes' => "Pagamento ID: {$pagamento->id}"
        ]);

        return $this->success([
            'pagamento' => $pagamento,
            'comprovante' => [
                'numero_comprovante' => 'COMP-' . str_pad($pagamento->id, 8, '0', STR_PAD_LEFT),
                'data_pagamento' => $pagamento->data_pagamento,
                'valor_pago' => $pagamento->valor,
                'gateway' => $pagamento->gateway,
                'transaction_id' => $pagamento->transaction_id,
                'cliente' => [
                    'nome' => $cliente->nome,
                    'documento' => $cliente->cpf_cnpj,
                    'email' => $cliente->email
                ]
            ]
        ]);
    }

    /**
     * Dashboard financeiro do cliente
     */
    public function dashboard()
    {
        $cliente = auth('cliente')->user();
        
        $stats = [
            'total_pendente' => $cliente->financeiro()->pendentes()->sum('valor'),
            'total_pago_ano' => $cliente->financeiro()
                                     ->where('status', 'pago')
                                     ->whereYear('data_pagamento', now()->year)
                                     ->sum('valor'),
            'proximos_vencimentos' => $cliente->financeiro()
                                            ->pendentes()
                                            ->where('data_vencimento', '<=', now()->addDays(30))
                                            ->count(),
            'em_atraso' => $cliente->financeiro()->vencidos()->count()
        ];

        // Próximos vencimentos
        $proximosVencimentos = $cliente->financeiro()
                                     ->pendentes()
                                     ->orderBy('data_vencimento')
                                     ->limit(5)
                                     ->get();

        // Histórico dos últimos 6 meses
        $historicoMensal = [];
        for ($i = 5; $i >= 0; $i--) {
            $mes = now()->subMonths($i);
            $valor = $cliente->financeiro()
                           ->where('status', 'pago')
                           ->whereYear('data_pagamento', $mes->year)
                           ->whereMonth('data_pagamento', $mes->month)
                           ->sum('valor');
            
            $historicoMensal[] = [
                'mes' => $mes->format('Y-m'),
                'mes_nome' => $mes->format('M/Y'),
                'valor' => (float) $valor
            ];
        }

        return $this->success([
            'stats' => $stats,
            'proximos_vencimentos' => $proximosVencimentos,
            'historico_mensal' => $historicoMensal
        ]);
    }
}
