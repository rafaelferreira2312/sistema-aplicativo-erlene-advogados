<?php

namespace App\Services;

use App\Models\LogSistema;
use Illuminate\Http\Request;

class LogService
{
    /**
     * Registrar login de usuário
     */
    public static function logLogin($user, $tipo = 'admin', Request $request = null)
    {
        $request = $request ?: request();
        
        LogSistema::info('auth', 'Login realizado com sucesso', [
            'user_id' => $user->id,
            'user_name' => $user->nome ?? $user->name,
            'user_email' => $user->email,
            'tipo_login' => $tipo,
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent()
        ], $user->id);
    }

    /**
     * Registrar login no portal
     */
    public static function logPortalLogin($cliente, Request $request = null)
    {
        $request = $request ?: request();
        
        LogSistema::info('auth', 'Login no portal realizado com sucesso', [
            'cliente_id' => $cliente->id,
            'cliente_nome' => $cliente->nome,
            'cliente_email' => $cliente->email,
            'tipo_login' => 'portal',
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent()
        ], null, $cliente->id);
    }

    /**
     * Registrar logout
     */
    public static function logLogout($user = null, $tipo = 'admin')
    {
        $user = $user ?: auth()->user();
        
        if ($user) {
            LogSistema::info('auth', 'Logout realizado', [
                'user_id' => $user->id,
                'user_name' => $user->nome ?? $user->name,
                'tipo_logout' => $tipo
            ], $user->id);
        }
    }

    /**
     * Registrar tentativa de login inválida
     */
    public static function logLoginFailed($email, $tipo = 'admin', Request $request = null)
    {
        $request = $request ?: request();
        
        LogSistema::warning('auth', 'Tentativa de login com credenciais inválidas', [
            'email' => $email,
            'tipo_login' => $tipo,
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent()
        ]);
    }

    /**
     * Registrar ações CRUD
     */
    public static function logCrud($acao, $modelo, $modeloId, $dados = [], $user = null)
    {
        $user = $user ?: auth()->user();
        
        $categoria = 'crud_' . strtolower(class_basename($modelo));
        $mensagem = ucfirst($acao) . ' ' . class_basename($modelo) . ' ID: ' . $modeloId;
        
        LogSistema::info($categoria, $mensagem, [
            'acao' => $acao,
            'modelo' => class_basename($modelo),
            'modelo_id' => $modeloId,
            'dados' => $dados,
            'user_id' => $user ? $user->id : null,
            'user_name' => $user ? ($user->nome ?? $user->name) : null
        ], $user ? $user->id : null);
    }

    /**
     * Registrar acesso a páginas/endpoints
     */
    public static function logAccess($endpoint, $metodo = 'GET', $parametros = [], $user = null)
    {
        $user = $user ?: auth()->user();
        
        LogSistema::debug('acesso', "Acesso ao endpoint: {$metodo} {$endpoint}", [
            'endpoint' => $endpoint,
            'metodo' => $metodo,
            'parametros' => $parametros,
            'user_id' => $user ? $user->id : null,
            'user_name' => $user ? ($user->nome ?? $user->name) : null
        ], $user ? $user->id : null);
    }

    /**
     * Registrar erros de aplicação
     */
    public static function logError($mensagem, $exception = null, $contexto = [], $user = null)
    {
        $user = $user ?: auth()->user();
        
        $contextoCompleto = array_merge([
            'error_message' => $mensagem,
            'exception' => $exception ? [
                'message' => $exception->getMessage(),
                'file' => $exception->getFile(),
                'line' => $exception->getLine(),
                'trace' => $exception->getTraceAsString()
            ] : null,
            'user_id' => $user ? $user->id : null,
            'user_name' => $user ? ($user->nome ?? $user->name) : null
        ], $contexto);

        LogSistema::error('sistema', $mensagem, $contextoCompleto, $user ? $user->id : null);
    }

    /**
     * Registrar ações específicas do sistema jurídico
     */
    public static function logJuridico($acao, $entidade, $entidadeId, $dados = [], $user = null)
    {
        $user = $user ?: auth()->user();
        
        LogSistema::info('juridico', "Ação jurídica: {$acao} - {$entidade} ID: {$entidadeId}", [
            'acao' => $acao,
            'entidade' => $entidade,
            'entidade_id' => $entidadeId,
            'dados' => $dados,
            'user_id' => $user ? $user->id : null,
            'user_name' => $user ? ($user->nome ?? $user->name) : null
        ], $user ? $user->id : null);
    }
}
