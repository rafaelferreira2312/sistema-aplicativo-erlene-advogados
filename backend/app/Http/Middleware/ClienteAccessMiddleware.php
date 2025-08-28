<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ClienteAccessMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $user = auth()->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Token de autenticação necessário'
            ], 401);
        }
        
        if ($user->perfil !== 'consulta') {
            return response()->json([
                'success' => false,
                'message' => 'Acesso negado. Esta área é exclusiva para clientes.'
            ], 403);
        }
        
        return $next($request);
    }
}
