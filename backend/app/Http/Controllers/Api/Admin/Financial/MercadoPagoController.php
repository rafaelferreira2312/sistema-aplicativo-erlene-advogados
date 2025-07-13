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
