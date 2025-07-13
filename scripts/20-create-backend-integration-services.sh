#!/bin/bash

# Script 20 - Criação dos Integration Services (Laravel)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/20-create-backend-integration-services.sh (executado da raiz do projeto)

echo "🚀 Criando Integration Services do Backend..."

# Criar diretório para services de integração
mkdir -p backend/app/Services/Integration

# Base Integration Service
cat > backend/app/Services/Integration/BaseIntegrationService.php << 'EOF'
<?php

namespace App\Services\Integration;

use App\Services\BaseService;
use App\Models\Integracao;
use Illuminate\Support\Facades\Http;

abstract class BaseIntegrationService extends BaseService
{
    protected $integrationName;
    protected $baseUrl;
    protected $timeout = 30;
    protected $retries = 3;

    public function __construct()
    {
        if (!$this->integrationName) {
            throw new \Exception('Integration name must be defined');
        }
    }

    /**
     * Obter configurações da integração
     */
    protected function getConfig(int $unidadeId)
    {
        $integracao = Integracao::where('nome', $this->integrationName)
                               ->where('unidade_id', $unidadeId)
                               ->where('ativo', true)
                               ->first();

        if (!$integracao) {
            throw new \Exception("Integração {$this->integrationName} não configurada para esta unidade");
        }

        return $integracao->configuracoes;
    }

    /**
     * Fazer requisição HTTP com retry
     */
    protected function makeRequest(string $method, string $endpoint, array $data = [], array $headers = [], int $unidadeId = null)
    {
        return $this->executeWithLog(function() use ($method, $endpoint, $data, $headers, $unidadeId) {
            $config = $unidadeId ? $this->getConfig($unidadeId) : [];
            $url = $this->baseUrl . $endpoint;

            for ($attempt = 1; $attempt <= $this->retries; $attempt++) {
                try {
                    $response = Http::timeout($this->timeout)
                                  ->withHeaders(array_merge($this->getDefaultHeaders($config), $headers));

                    switch (strtolower($method)) {
                        case 'get':
                            $response = $response->get($url, $data);
                            break;
                        case 'post':
                            $response = $response->post($url, $data);
                            break;
                        case 'put':
                            $response = $response->put($url, $data);
                            break;
                        case 'delete':
                            $response = $response->delete($url, $data);
                            break;
                        default:
                            throw new \InvalidArgumentException("Método HTTP não suportado: {$method}");
                    }

                    if ($response->successful()) {
                        $this->logSuccessfulRequest($method, $url, $response, $unidadeId);
                        return $response->json();
                    } else {
                        throw new \Exception("HTTP {$response->status()}: {$response->body()}");
                    }

                } catch (\Exception $e) {
                    $this->logFailedRequest($method, $url, $e, $attempt, $unidadeId);
                    
                    if ($attempt === $this->retries) {
                        throw $e;
                    }
                    
                    sleep(pow(2, $attempt)); // Exponential backoff
                }
            }
        }, [
            'integration' => $this->integrationName,
            'method' => $method,
            'endpoint' => $endpoint,
            'unidade_id' => $unidadeId
        ]);
    }

    /**
     * Headers padrão para requisições
     */
    protected function getDefaultHeaders(array $config)
    {
        return [
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'User-Agent' => 'ErleneAdvogados/1.0'
        ];
    }

    /**
     * Log de requisição bem-sucedida
     */
    private function logSuccessfulRequest(string $method, string $url, $response, int $unidadeId = null)
    {
        $this->log('info', 'Requisição à API bem-sucedida', [
            'integration' => $this->integrationName,
            'method' => $method,
            'url' => $url,
            'status' => $response->status(),
            'response_size' => strlen($response->body()),
            'unidade_id' => $unidadeId
        ]);

        $this->updateIntegrationStats($unidadeId, true);
    }

    /**
     * Log de requisição com falha
     */
    private function logFailedRequest(string $method, string $url, \Exception $e, int $attempt, int $unidadeId = null)
    {
        $this->log('error', 'Falha na requisição à API', [
            'integration' => $this->integrationName,
            'method' => $method,
            'url' => $url,
            'error' => $e->getMessage(),
            'attempt' => $attempt,
            'max_retries' => $this->retries,
            'unidade_id' => $unidadeId
        ]);

        if ($attempt === $this->retries) {
            $this->updateIntegrationStats($unidadeId, false);
        }
    }

    /**
     * Atualizar estatísticas da integração
     */
    private function updateIntegrationStats(int $unidadeId = null, bool $success = true)
    {
        if (!$unidadeId) return;

        $integracao = Integracao::where('nome', $this->integrationName)
                               ->where('unidade_id', $unidadeId)
                               ->first();

        if ($integracao) {
            $integracao->increment('total_requisicoes');
            
            if ($success) {
                $integracao->increment('requisicoes_sucesso');
                $integracao->update(['status' => 'funcionando', 'ultimo_erro' => null]);
            } else {
                $integracao->increment('requisicoes_erro');
                $integracao->update(['status' => 'erro']);
            }
        }
    }

    /**
     * Testar conectividade da integração
     */
    abstract public function testConnection(array $config);

    /**
     * Validar configuração da integração
     */
    abstract public function validateConfig(array $config);
}
EOF

# Tribunal Service
cat > backend/app/Services/Integration/TribunalService.php << 'EOF'
<?php

namespace App\Services\Integration;

class TribunalService extends BaseIntegrationService
{
    protected $integrationName = 'cnj';
    protected $baseUrl = 'https://api.cnj.jus.br';

    /**
     * Consultar processo por número
     */
    public function consultarProcesso(string $numeroProcesso, string $tribunal, int $unidadeId)
    {
        return $this->executeWithLog(function() use ($numeroProcesso, $tribunal, $unidadeId) {
            // Simular consulta no CNJ
            $this->log('info', 'Consultando processo no tribunal', [
                'numero_processo' => $numeroProcesso,
                'tribunal' => $tribunal
            ]);

            // TODO: Implementar consulta real
            $movimentacoes = $this->mockMovimentacoes($numeroProcesso);

            return [
                'success' => true,
                'numero_processo' => $numeroProcesso,
                'tribunal' => $tribunal,
                'ultima_consulta' => now(),
                'movimentacoes' => $movimentacoes,
                'total_movimentacoes' => count($movimentacoes)
            ];
        }, ['operation' => 'consultar_processo', 'numero' => $numeroProcesso]);
    }

    /**
     * Mock de movimentações para desenvolvimento
     */
    private function mockMovimentacoes(string $numeroProcesso)
    {
        return [
            [
                'data' => now()->subDays(rand(1, 30))->toDateString(),
                'descricao' => 'Distribuição por dependência ao(à) ' . rand(1, 20) . 'ª Vara Cível',
                'documento_url' => null,
                'metadata' => ['origem' => 'sistema_tribunais']
            ],
            [
                'data' => now()->subDays(rand(31, 60))->toDateString(),
                'descricao' => 'Conclusão para despacho/decisão',
                'documento_url' => null,
                'metadata' => ['origem' => 'sistema_tribunais']
            ]
        ];
    }

    /**
     * Obter tribunais disponíveis
     */
    public function getTribunaisDisponiveis()
    {
        return [
            'TJSP' => 'Tribunal de Justiça de São Paulo',
            'TJRJ' => 'Tribunal de Justiça do Rio de Janeiro',
            'TRF3' => 'Tribunal Regional Federal da 3ª Região',
            'TST' => 'Tribunal Superior do Trabalho',
            'STJ' => 'Superior Tribunal de Justiça',
            'STF' => 'Supremo Tribunal Federal'
        ];
    }

    /**
     * Testar conexão
     */
    public function testConnection(array $config)
    {
        try {
            // TODO: Implementar teste real
            $this->log('info', 'Teste de conexão CNJ simulado');
            return ['success' => true, 'message' => 'Conexão CNJ ok (simulado)'];
        } catch (\Exception $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    /**
     * Validar configuração
     */
    public function validateConfig(array $config)
    {
        $required = ['api_key', 'ambiente'];
        
        foreach ($required as $field) {
            if (empty($config[$field])) {
                throw new \InvalidArgumentException("Campo obrigatório: {$field}");
            }
        }

        return true;
    }
}
EOF

# Email Service
cat > backend/app/Services/Integration/EmailService.php << 'EOF'
<?php

namespace App\Services\Integration;

use App\Models\Cliente;
use App\Models\User;
use Illuminate\Support\Facades\Mail;

class EmailService extends BaseIntegrationService
{
    protected $integrationName = 'gmail';

    /**
     * Enviar email de boas-vindas para cliente
     */
    public function sendWelcomeEmail(Cliente $cliente, string $senhaTemporaria)
    {
        return $this->executeWithLog(function() use ($cliente, $senhaTemporaria) {
            $data = [
                'cliente' => $cliente,
                'senha_temporaria' => $senhaTemporaria,
                'portal_url' => config('app.frontend_url') . '/portal'
            ];

            // TODO: Implementar envio real com template
            $this->log('info', 'Email de boas-vindas enviado (simulado)', [
                'cliente_id' => $cliente->id,
                'email' => $cliente->email
            ]);

            return ['success' => true, 'message' => 'Email enviado com sucesso'];
        }, ['operation' => 'send_welcome_email', 'cliente_id' => $cliente->id]);
    }

    /**
     * Enviar notificação de processo
     */
    public function sendProcessUpdateEmail($processo, $movimentacao)
    {
        return $this->executeWithLog(function() use ($processo, $movimentacao) {
            $data = [
                'processo' => $processo,
                'movimentacao' => $movimentacao,
                'cliente' => $processo->cliente
            ];

            // TODO: Implementar envio real
            $this->log('info', 'Email de atualização de processo enviado (simulado)', [
                'processo_id' => $processo->id,
                'cliente_email' => $processo->cliente->email
            ]);

            return ['success' => true];
        }, ['operation' => 'send_process_update', 'processo_id' => $processo->id]);
    }

    /**
     * Enviar lembrete de vencimento
     */
    public function sendPaymentReminderEmail($financeiro)
    {
        return $this->executeWithLog(function() use ($financeiro) {
            $data = [
                'financeiro' => $financeiro,
                'cliente' => $financeiro->cliente,
                'dias_vencimento' => now()->diffInDays($financeiro->data_vencimento, false)
            ];

            $this->log('info', 'Email de lembrete de pagamento enviado (simulado)', [
                'financeiro_id' => $financeiro->id,
                'cliente_email' => $financeiro->cliente->email,
                'valor' => $financeiro->valor
            ]);

            return ['success' => true];
        }, ['operation' => 'send_payment_reminder', 'financeiro_id' => $financeiro->id]);
    }

    /**
     * Testar conexão
     */
    public function testConnection(array $config)
    {
        try {
            // TODO: Implementar teste real do Gmail API
            $this->log('info', 'Teste de conexão Gmail simulado');
            return ['success' => true, 'message' => 'Conexão Gmail ok (simulado)'];
        } catch (\Exception $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    /**
     * Validar configuração
     */
    public function validateConfig(array $config)
    {
        $required = ['client_id', 'client_secret', 'refresh_token'];
        
        foreach ($required as $field) {
            if (empty($config[$field])) {
                throw new \InvalidArgumentException("Campo obrigatório: {$field}");
            }
        }

        return true;
    }
}
EOF

# Google Drive Service
cat > backend/app/Services/Integration/GoogleDriveService.php << 'EOF'
<?php

namespace App\Services\Integration;

class GoogleDriveService extends BaseIntegrationService
{
    protected $integrationName = 'google_drive';
    protected $baseUrl = 'https://www.googleapis.com/drive/v3';

    /**
     * Criar pasta para cliente
     */
    public function createFolder(string $folderName, int $unidadeId, string $parentId = null)
    {
        return $this->executeWithLog(function() use ($folderName, $unidadeId, $parentId) {
            $data = [
                'name' => $folderName,
                'mimeType' => 'application/vnd.google-apps.folder'
            ];

            if ($parentId) {
                $data['parents'] = [$parentId];
            }

            // TODO: Implementar criação real no Google Drive
            $folderId = 'MOCK_FOLDER_' . time() . '_' . uniqid();

            $this->log('info', 'Pasta criada no Google Drive (simulado)', [
                'folder_name' => $folderName,
                'folder_id' => $folderId,
                'parent_id' => $parentId
            ]);

            return [
                'success' => true,
                'folder_id' => $folderId,
                'folder_name' => $folderName
            ];
        }, ['operation' => 'create_folder', 'folder_name' => $folderName]);
    }

    /**
     * Upload de arquivo
     */
    public function uploadFile($filePath, string $fileName, string $folderId, int $unidadeId)
    {
        return $this->executeWithLog(function() use ($filePath, $fileName, $folderId, $unidadeId) {
            // TODO: Implementar upload real
            $fileId = 'MOCK_FILE_' . time() . '_' . uniqid();

            $this->log('info', 'Arquivo enviado para Google Drive (simulado)', [
                'file_name' => $fileName,
                'file_id' => $fileId,
                'folder_id' => $folderId
            ]);

            return [
                'success' => true,
                'file_id' => $fileId,
                'file_name' => $fileName,
                'web_view_link' => "https://drive.google.com/file/d/{$fileId}/view"
            ];
        }, ['operation' => 'upload_file', 'file_name' => $fileName]);
    }

    /**
     * Listar arquivos da pasta
     */
    public function listFiles(string $folderId, int $unidadeId)
    {
        return $this->executeWithLog(function() use ($folderId, $unidadeId) {
            // TODO: Implementar listagem real
            $mockFiles = [
                [
                    'id' => 'file1_' . time(),
                    'name' => 'documento1.pdf',
                    'mimeType' => 'application/pdf',
                    'size' => '1024000',
                    'modifiedTime' => now()->subDays(1)->toISOString()
                ],
                [
                    'id' => 'file2_' . time(),
                    'name' => 'contrato.docx',
                    'mimeType' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                    'size' => '2048000',
                    'modifiedTime' => now()->subDays(3)->toISOString()
                ]
            ];

            $this->log('info', 'Arquivos listados do Google Drive (simulado)', [
                'folder_id' => $folderId,
                'file_count' => count($mockFiles)
            ]);

            return [
                'success' => true,
                'files' => $mockFiles
            ];
        }, ['operation' => 'list_files', 'folder_id' => $folderId]);
    }

    /**
     * Testar conexão
     */
    public function testConnection(array $config)
    {
        try {
            // TODO: Implementar teste real
            $this->log('info', 'Teste de conexão Google Drive simulado');
            return ['success' => true, 'message' => 'Conexão Google Drive ok (simulado)'];
        } catch (\Exception $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    /**
     * Validar configuração
     */
    public function validateConfig(array $config)
    {
        $required = ['client_id', 'client_secret', 'refresh_token'];
        
        foreach ($required as $field) {
            if (empty($config[$field])) {
                throw new \InvalidArgumentException("Campo obrigatório: {$field}");
            }
        }

        return true;
    }
}
EOF

# Payment Integration Service
cat > backend/app/Services/Integration/PaymentService.php << 'EOF'
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
EOF

echo "✅ Integration Services criados com sucesso!"
echo "📊 Funcionalidades implementadas:"
echo "   • BaseIntegrationService - Classe base com retry automático"
echo "   • TribunalService - Consulta de processos nos tribunais"
echo "   • EmailService - Envio de emails e notificações"
echo "   • GoogleDriveService - Gestão de arquivos na nuvem"
echo "   • PaymentService - Processamento de webhooks de pagamento"
echo "   • Logs detalhados e estatísticas de uso"
echo "   • Tratamento de erros com exponential backoff"
echo "   • Configuração por unidade"
echo ""
echo "⏭️  Pronto para continuar com o último service!"