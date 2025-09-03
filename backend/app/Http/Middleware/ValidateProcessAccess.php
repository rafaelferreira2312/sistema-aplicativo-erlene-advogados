<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\Processo;

class ValidateProcessAccess
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        $user = auth()->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Usuário não autenticado'
            ], 401);
        }

        // Verificar se está acessando um processo específico
        $processoId = $request->route('id');
        
        if ($processoId) {
            $processo = Processo::find($processoId);
            
            if (!$processo) {
                return response()->json([
                    'success' => false,
                    'message' => 'Processo não encontrado'
                ], 404);
            }

            // Verificar se o processo pertence à unidade do usuário
            if ($processo->unidade_id !== $user->unidade_id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Acesso negado a este processo'
                ], 403);
            }
        }

        return $next($request);
    }
}
