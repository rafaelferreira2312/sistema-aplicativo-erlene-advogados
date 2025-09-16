<?php

namespace App\Http\Controllers\Api\Admin\Integrations\CNJ;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CNJController extends Controller
{
    /**
     * Integração com CNJ - Em desenvolvimento
     */
    public function index(Request $request): JsonResponse
    {
        return response()->json([
            'message' => 'Integração CNJ em desenvolvimento',
            'data' => []
        ]);
    }

    /**
     * Consultar processo no CNJ
     */
    public function consultarProcesso(Request $request): JsonResponse
    {
        return response()->json([
            'message' => 'Consulta CNJ em desenvolvimento',
            'data' => null
        ]);
    }

    /**
     * Sincronizar movimentações
     */
    public function sincronizar(Request $request): JsonResponse
    {
        return response()->json([
            'message' => 'Sincronização CNJ em desenvolvimento',
            'data' => []
        ]);
    }
}
