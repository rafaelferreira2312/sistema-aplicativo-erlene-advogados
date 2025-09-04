<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Integracao;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class IntegrationController extends Controller
{
    /**
     * Listar todas as integrações da unidade
     */
    public function index(Request $request)
    {
        try {
            $user = auth()->user();
            
            $integracoes = Integracao::where('unidade_id', $user->unidade_id)
                                   ->orderBy('nome')
                                   ->get();

            return response()->json([
                'success' => true,
                'data' => $integracoes
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao carregar integrações',
                'error' => config('app.debug') ? $e->getMessage() : 'Erro interno'
            ], 500);
        }
    }

    /**
     * Atualizar configuração de uma integração
     */
    public function update(Request $request, $id)
    {
        try {
            $user = auth()->user();
            
            $integracao = Integracao::where('id', $id)
                                  ->where('unidade_id', $user->unidade_id)
                                  ->firstOrFail();

            $validator = Validator::make($request->all(), [
                'ativo' => 'boolean',
                'configuracoes' => 'array'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dados inválidos',
                    'errors' => $validator->errors()
                ], 422);
            }

            $integracao->update($validator->validated());

            return response()->json([
                'success' => true,
                'message' => 'Integração atualizada com sucesso',
                'data' => $integracao
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar integração',
                'error' => config('app.debug') ? $e->getMessage() : 'Erro interno'
            ], 500);
        }
    }
}
