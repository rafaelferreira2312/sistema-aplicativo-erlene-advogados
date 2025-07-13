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
