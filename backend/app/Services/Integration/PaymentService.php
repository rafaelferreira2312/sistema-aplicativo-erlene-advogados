<?php

namespace App\Services\Integration;

use App\Models\Financeiro;
use App\Models\PagamentoStripe;
use App\Models\PagamentoMercadoPago;

class PaymentService extends BaseIntegrationService
{
    protected $integrationName = 'payment';

    /**
     * Processar webhook do Stripe
     */
    public function processStripeWebhook(array $payload)
    {
        return $this->executeWithLog(function() use ($payload) {
            $eventType = $payload['type'] ?? null;
            $data = $payload['data']['object'] ?? [];

            switch ($eventType) {
                case 'payment_intent.succeeded':
                    return $this->handleStripePaymentSuccess($data);
                    
                case 'payment_intent.payment_failed':
                    return $this->handleStripePaymentFailed($data);
                    
                default:
                    $this->log('info', 'Evento Stripe ignorado', ['type' => $eventType]);
                    return ['success' => true, 'message' => 'Evento ignorado'];
            }
        }, ['operation' => 'process_stripe_webhook', 'event_type' => $payload['type'] ?? 'unknown']);
    }

    /**
     * Processar pagamento Stripe bem-sucedido
     */
    private function handleStripePaymentSuccess(array $data)
    {
        $paymentIntentId = $data['id'] ?? null;
        
        if (!$paymentIntentId) {
            throw new \InvalidArgumentException('Payment Intent ID não encontrado');
        }

        $pagamento = PagamentoStripe::where('stripe_payment_intent_id', $paymentIntentId)->first();
        
        if (!$pagamento) {
            throw new \Exception('Pagamento Stripe não encontrado no sistema');
        }

        $pagamento->update([
            'status' => 'succeeded',
            'data_pagamento' => now(),
            'stripe_charge_id' => $data['charges']['data'][0]['id'] ?? null
        ]);

        // Atualizar financeiro
        $pagamento->financeiro->update([
            'status' => 'pago',
            'data_pagamento' => now(),
            'gateway' => 'stripe',
            'transaction_id' => $paymentIntentId
        ]);

        $this->log('info', 'Pagamento Stripe processado com sucesso', [
            'payment_intent_id' => $paymentIntentId,
            'financeiro_id' => $pagamento->financeiro_id
        ]);

        return ['success' => true, 'message' => 'Pagamento processado'];
    }

    /**
     * Processar falha no pagamento Stripe
     */
    private function handleStripePaymentFailed(array $data)
    {
        $paymentIntentId = $data['id'] ?? null;
        $pagamento = PagamentoStripe::where('stripe_payment_intent_id', $paymentIntentId)->first();
        
        if ($pagamento) {
            $pagamento->update([
                'status' => 'failed',
                'observacoes' => $data['last_payment_error']['message'] ?? 'Pagamento falhou'
            ]);
        }

        $this->log('warning', 'Pagamento Stripe falhou', [
            'payment_intent_id' => $paymentIntentId,
            'error' => $data['last_payment_error']['message'] ?? 'Erro desconhecido'
        ]);

        return ['success' => true, 'message' => 'Falha processada'];
    }

    /**
     * Processar webhook do Mercado Pago
     */
    public function processMercadoPagoWebhook(array $payload)
    {
        return $this->executeWithLog(function() use ($payload) {
            $type = $payload['type'] ?? null;
            $dataId = $payload['data']['id'] ?? null;

            if ($type !== 'payment' || !$dataId) {
                return ['success' => true, 'message' => 'Evento ignorado'];
            }

            // TODO: Buscar dados do pagamento na API do Mercado Pago
            $paymentData = $this->getMercadoPagoPaymentData($dataId);
            
            return $this->handleMercadoPagoPayment($paymentData);
            
        }, ['operation' => 'process_mp_webhook', 'data_id' => $payload['data']['id'] ?? null]);
    }

    /**
     * Buscar dados do pagamento no Mercado Pago
     */
    private function getMercadoPagoPaymentData(string $paymentId)
    {
        // TODO: Implementar consulta real na API do Mercado Pago
        return [
            'id' => $paymentId,
            'status' => 'approved',
            'external_reference' => 'FINANCEIRO_123_' . time(),
            'transaction_amount' => 150.00
        ];
    }

    /**
     * Processar pagamento do Mercado Pago
     */
    private function handleMercadoPagoPayment(array $paymentData)
    {
        $externalReference = $paymentData['external_reference'] ?? null;
        
        if (!$externalReference) {
            throw new \InvalidArgumentException('External reference não encontrada');
        }

        $pagamento = PagamentoMercadoPago::where('mp_external_reference', $externalReference)->first();
        
        if (!$pagamento) {
            throw new \Exception('Pagamento Mercado Pago não encontrado no sistema');
        }

        $pagamento->update([
            'mp_payment_id' => $paymentData['id'],
            'status' => $paymentData['status'],
            'mp_metadata' => $paymentData,
            'data_pagamento' => $paymentData['status'] === 'approved' ? now() : null
        ]);

        // Atualizar financeiro se aprovado
        if ($paymentData['status'] === 'approved') {
            $pagamento->financeiro->update([
                'status' => 'pago',
                'data_pagamento' => now(),
                'gateway' => 'mercadopago',
                'transaction_id' => $paymentData['id']
            ]);
        }

        $this->log('info', 'Pagamento Mercado Pago processado', [
            'mp_payment_id' => $paymentData['id'],
            'status' => $paymentData['status'],
            'financeiro_id' => $pagamento->financeiro_id
        ]);

        return ['success' => true, 'message' => 'Pagamento processado'];
    }

    /**
     * Testar conexão
     */
    public function testConnection(array $config)
    {
        return ['success' => true, 'message' => 'Service de pagamentos ativo'];
    }

    /**
     * Validar configuração
     */
    public function validateConfig(array $config)
    {
        return true; // Service interno, não precisa de configuração externa
    }
}
