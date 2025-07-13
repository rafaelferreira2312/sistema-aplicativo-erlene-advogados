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
