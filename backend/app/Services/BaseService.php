<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;
use Exception;

abstract class BaseService
{
    protected $model;
    protected $logChannel = 'default';

    /**
     * Log de atividades do service
     */
    protected function log($level, $message, $context = [])
    {
        Log::channel($this->logChannel)->log($level, $message, array_merge([
            'service' => get_class($this),
            'user_id' => auth()->id() ?? null,
            'timestamp' => now()->toISOString()
        ], $context));
    }

    /**
     * Executar operação com log e tratamento de erro
     */
    protected function executeWithLog($operation, $context = [])
    {
        try {
            $this->log('info', 'Iniciando operação', $context);
            $result = $operation();
            $this->log('info', 'Operação concluída com sucesso', $context);
            return $result;
        } catch (Exception $e) {
            $this->log('error', 'Erro na operação: ' . $e->getMessage(), array_merge($context, [
                'exception' => $e->getTraceAsString()
            ]));
            throw $e;
        }
    }

    /**
     * Validar entrada de dados
     */
    protected function validate($data, $rules)
    {
        $validator = Validator::make($data, $rules);
        
        if ($validator->fails()) {
            throw new \Illuminate\Validation\ValidationException($validator);
        }
        
        return $validator->validated();
    }

    /**
     * Executar em transação
     */
    protected function transaction($callback)
    {
        return DB::transaction($callback);
    }

    /**
     * Cache helper
     */
    protected function cache($key, $callback, $ttl = 3600)
    {
        return Cache::remember($key, $ttl, $callback);
    }

    /**
     * Limpar cache específico
     */
    protected function forgetCache($pattern)
    {
        if (is_array($pattern)) {
            foreach ($pattern as $key) {
                Cache::forget($key);
            }
        } else {
            Cache::forget($pattern);
        }
    }

    /**
     * Criar resposta padronizada
     */
    protected function createResponse($success, $data = null, $message = null, $errors = null)
    {
        return [
            'success' => $success,
            'data' => $data,
            'message' => $message,
            'errors' => $errors,
            'timestamp' => now()->toISOString()
        ];
    }

    /**
     * Resposta de sucesso
     */
    protected function success($data = null, $message = 'Operação realizada com sucesso')
    {
        return $this->createResponse(true, $data, $message);
    }

    /**
     * Resposta de erro
     */
    protected function error($message = 'Erro interno', $errors = null)
    {
        return $this->createResponse(false, null, $message, $errors);
    }
}
