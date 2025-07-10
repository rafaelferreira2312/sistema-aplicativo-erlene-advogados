<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;

/**
 * @OA\Info(
 *     title="Sistema Erlene Advogados API",
 *     version="1.0.0",
 *     description="API completa para gestão jurídica",
 *     @OA\Contact(
 *         email="contato@erleneadvogados.com"
 *     )
 * )
 *
 * @OA\Server(
 *     url="http://localhost:8080/api",
 *     description="Servidor de desenvolvimento"
 * )
 *
 * @OA\SecurityScheme(
 *     securityScheme="bearerAuth",
 *     type="http",
 *     scheme="bearer",
 *     bearerFormat="JWT"
 * )
 */
class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

    /**
     * Resposta de sucesso padrão
     */
    protected function success($data = null, $message = 'Operação realizada com sucesso', $code = 200)
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $code);
    }

    /**
     * Resposta de erro padrão
     */
    protected function error($message = 'Erro interno do servidor', $code = 500, $errors = null)
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors
        ], $code);
    }

    /**
     * Resposta paginada
     */
    protected function paginated($data, $message = 'Dados recuperados com sucesso')
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data->items(),
            'pagination' => [
                'current_page' => $data->currentPage(),
                'last_page' => $data->lastPage(),
                'per_page' => $data->perPage(),
                'total' => $data->total(),
                'from' => $data->firstItem(),
                'to' => $data->lastItem()
            ]
        ]);
    }
}
