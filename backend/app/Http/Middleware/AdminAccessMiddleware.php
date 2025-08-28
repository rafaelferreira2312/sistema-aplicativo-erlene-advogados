<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminAccessMiddleware
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
        
        if (!in_array($user->perfil, ['admin_geral', 'admin_unidade', 'advogado'])) {
            return response()->json([
                'success' => false,
                'message' => 'Acesso negado. Permissões insuficientes.'
            ], 403);
        }
        
        return $next($request);
    }
}
