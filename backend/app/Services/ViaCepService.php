<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class ViaCepService
{
    private $baseUrl = 'https://viacep.com.br/ws/';
    private $timeout = 10;

    /**
     * Buscar endereço por CEP
     */
    public function buscarCep(string $cep): array
    {
        // Limpar CEP
        $cep = preg_replace('/\D/', '', $cep);
        
        if (strlen($cep) !== 8) {
            throw new \InvalidArgumentException('CEP deve ter 8 dígitos');
        }

        // Cache por 24 horas
        $cacheKey = "viacep_{$cep}";
        
        return Cache::remember($cacheKey, 86400, function() use ($cep) {
            $response = Http::timeout($this->timeout)
                          ->get($this->baseUrl . $cep . '/json/');

            if (!$response->successful()) {
                throw new \Exception('Erro ao consultar ViaCEP');
            }

            $data = $response->json();

            if (isset($data['erro'])) {
                throw new \Exception('CEP não encontrado');
            }

            return [
                'cep' => $data['cep'] ?? '',
                'logradouro' => $data['logradouro'] ?? '',
                'complemento' => $data['complemento'] ?? '',
                'bairro' => $data['bairro'] ?? '',
                'localidade' => $data['localidade'] ?? '',
                'uf' => $data['uf'] ?? '',
                'ibge' => $data['ibge'] ?? '',
                'gia' => $data['gia'] ?? '',
                'ddd' => $data['ddd'] ?? '',
                'siafi' => $data['siafi'] ?? ''
            ];
        });
    }

    /**
     * Buscar endereços por cidade e logradouro
     */
    public function buscarEndereco(string $uf, string $cidade, string $logradouro): array
    {
        $uf = strtoupper($uf);
        $cidade = urlencode($cidade);
        $logradouro = urlencode($logradouro);

        if (strlen($uf) !== 2) {
            throw new \InvalidArgumentException('UF deve ter 2 caracteres');
        }

        $cacheKey = "viacep_endereco_{$uf}_{$cidade}_{$logradouro}";
        
        return Cache::remember($cacheKey, 3600, function() use ($uf, $cidade, $logradouro) {
            $response = Http::timeout($this->timeout)
                          ->get($this->baseUrl . "{$uf}/{$cidade}/{$logradouro}/json/");

            if (!$response->successful()) {
                throw new \Exception('Erro ao consultar ViaCEP');
            }

            $data = $response->json();

            if (empty($data)) {
                throw new \Exception('Endereço não encontrado');
            }

            return $data;
        });
    }
}
