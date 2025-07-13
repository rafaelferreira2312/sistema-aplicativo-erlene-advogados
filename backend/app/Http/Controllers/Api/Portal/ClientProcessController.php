<?php

namespace App\Http\Controllers\Api\Portal;

use App\Http\Controllers\Controller;
use App\Models\Processo;
use Illuminate\Http\Request;

class ClientProcessController extends Controller
{
    /**
     * @OA\Get(
     *     path="/portal/processes",
     *     summary="Listar processos do cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Lista de processos")
     * )
     */
    public function index(Request $request)
    {
        $cliente = auth('cliente')->user();
        
        $query = $cliente->processos()->with(['advogado', 'unidade']);

        // Filtros
        if ($request->status) {
            $query->where('status', $request->status);
        }

        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('numero', 'like', "%{$search}%")
                  ->orWhere('tipo_acao', 'like', "%{$search}%");
            });
        }

        $processos = $query->orderBy('created_at', 'desc')
                          ->paginate($request->per_page ?? 10);

        // Registrar acesso
        $cliente->acessosPortal()->create([
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data_acesso' => now(),
            'acao' => 'visualizar_processos'
        ]);

        return $this->paginated($processos);
    }

    /**
     * @OA\Get(
     *     path="/portal/processes/{id}",
     *     summary="Obter detalhes do processo",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Detalhes do processo")
     * )
     */
    public function show($id)
    {
        $cliente = auth('cliente')->user();
        
        $processo = $cliente->processos()
                          ->with([
                              'advogado',
                              'unidade',
                              'movimentacoes' => function($q) {
                                  $q->orderBy('data', 'desc');
                              },
                              'atendimentos' => function($q) {
                                  $q->with(['advogado'])->orderBy('data_hora', 'desc');
                              }
                          ])
                          ->findOrFail($id);

        // Registrar acesso
        $cliente->acessosPortal()->create([
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data_acesso' => now(),
            'acao' => 'visualizar_processo',
            'detalhes' => "Processo: {$processo->numero}"
        ]);

        return $this->success($processo);
    }

    /**
     * @OA\Get(
     *     path="/portal/processes/{id}/movements",
     *     summary="Obter movimentações do processo",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Movimentações do processo")
     * )
     */
    public function movements($id, Request $request)
    {
        $cliente = auth('cliente')->user();
        
        $processo = $cliente->processos()->findOrFail($id);
        
        $movimentacoes = $processo->movimentacoes()
                                 ->orderBy('data', 'desc')
                                 ->paginate($request->per_page ?? 20);

        return $this->paginated($movimentacoes);
    }

    /**
     * Timeline do processo
     */
    public function timeline($id)
    {
        $cliente = auth('cliente')->user();
        
        $processo = $cliente->processos()->findOrFail($id);
        
        $timeline = collect();

        // Adicionar movimentações
        $processo->movimentacoes->each(function($movimentacao) use ($timeline) {
            $timeline->push([
                'tipo' => 'movimentacao',
                'data' => $movimentacao->data,
                'titulo' => 'Movimentação Processual',
                'descricao' => $movimentacao->descricao,
                'documento_url' => $movimentacao->documento_url,
                'icone' => 'gavel',
                'cor' => 'blue'
            ]);
        });

        // Adicionar atendimentos
        $processo->atendimentos->each(function($atendimento) use ($timeline) {
            $timeline->push([
                'tipo' => 'atendimento',
                'data' => $atendimento->data_hora,
                'titulo' => 'Atendimento - ' . $atendimento->assunto,
                'descricao' => $atendimento->descricao,
                'advogado' => $atendimento->advogado->nome,
                'icone' => 'users',
                'cor' => 'green'
            ]);
        });

        // Ordenar por data decrescente
        $timeline = $timeline->sortByDesc('data')->values();

        return $this->success($timeline);
    }
}
