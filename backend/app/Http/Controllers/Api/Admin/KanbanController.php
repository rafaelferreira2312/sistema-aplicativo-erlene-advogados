<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\KanbanColuna;
use App\Models\KanbanCard;
use App\Models\Processo;
use App\Models\Tarefa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class KanbanController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/kanban",
     *     summary="Obter dados do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do kanban")
     * )
     */
    public function index()
    {
        $user = auth()->user();
        
        $colunas = KanbanColuna::with(['cards' => function($query) {
                                    $query->with(['processo.cliente', 'tarefa', 'responsavel'])
                                          ->ordenados();
                                }])
                               ->where('unidade_id', $user->unidade_id)
                               ->ordenadas()
                               ->get();

        return $this->success([
            'colunas' => $colunas,
            'estatisticas' => [
                'total_cards' => KanbanCard::whereHas('coluna', function($q) use ($user) {
                    $q->where('unidade_id', $user->unidade_id);
                })->count(),
                'cards_urgentes' => KanbanCard::whereHas('coluna', function($q) use ($user) {
                    $q->where('unidade_id', $user->unidade_id);
                })->where('prioridade', 'urgente')->count(),
                'cards_vencendo' => KanbanCard::whereHas('coluna', function($q) use ($user) {
                    $q->where('unidade_id', $user->unidade_id);
                })->comPrazoVencendo(3)->count()
            ]
        ]);
    }

    /**
     * @OA\Post(
     *     path="/admin/kanban/colunas",
     *     summary="Criar coluna do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"nome"},
     *             @OA\Property(property="nome", type="string"),
     *             @OA\Property(property="cor", type="string"),
     *             @OA\Property(property="ordem", type="integer")
     *         )
     *     ),
     *     @OA\Response(response=201, description="Coluna criada com sucesso")
     * )
     */
    public function criarColuna(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nome' => 'required|string|max:100',
            'cor' => 'required|string|regex:/^#[0-9A-Fa-f]{6}$/',
            'ordem' => 'nullable|integer|min:1'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        // Se não especificada, definir ordem como última
        $ordem = $request->ordem ?? KanbanColuna::where('unidade_id', $user->unidade_id)->max('ordem') + 1;

        $coluna = KanbanColuna::create([
            'nome' => $request->nome,
            'cor' => $request->cor,
            'ordem' => $ordem,
            'unidade_id' => $user->unidade_id
        ]);

        return $this->success($coluna, 'Coluna criada com sucesso', 201);
    }

    /**
     * @OA\Put(
     *     path="/admin/kanban/colunas/{id}",
     *     summary="Atualizar coluna do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Coluna atualizada com sucesso")
     * )
     */
    public function atualizarColuna(Request $request, $id)
    {
        $user = auth()->user();
        $coluna = KanbanColuna::where('unidade_id', $user->unidade_id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nome' => 'string|max:100',
            'cor' => 'string|regex:/^#[0-9A-Fa-f]{6}$/',
            'ordem' => 'integer|min:1'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $coluna->update($request->all());

        return $this->success($coluna, 'Coluna atualizada com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/kanban/colunas/{id}",
     *     summary="Excluir coluna do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Coluna excluída com sucesso")
     * )
     */
    public function excluirColuna($id)
    {
        $user = auth()->user();
        $coluna = KanbanColuna::where('unidade_id', $user->unidade_id)->findOrFail($id);

        if ($coluna->cards()->count() > 0) {
            return $this->error('Não é possível excluir coluna com cards', 400);
        }

        $coluna->delete();
        return $this->success(null, 'Coluna excluída com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/admin/kanban/cards",
     *     summary="Criar card do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"titulo","coluna_id","responsavel_id"},
     *             @OA\Property(property="titulo", type="string"),
     *             @OA\Property(property="descricao", type="string"),
     *             @OA\Property(property="coluna_id", type="integer"),
     *             @OA\Property(property="processo_id", type="integer"),
     *             @OA\Property(property="responsavel_id", type="integer")
     *         )
     *     ),
     *     @OA\Response(response=201, description="Card criado com sucesso")
     * )
     */
    public function criarCard(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'titulo' => 'required|string|max:255',
            'descricao' => 'nullable|string',
            'coluna_id' => 'required|exists:kanban_colunas,id',
            'processo_id' => 'nullable|exists:processos,id',
            'tarefa_id' => 'nullable|exists:tarefas,id',
            'prioridade' => 'in:baixa,media,alta,urgente',
            'prazo' => 'nullable|date|after:today',
            'responsavel_id' => 'required|exists:users,id'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        // Verificar se coluna pertence à unidade
        $coluna = KanbanColuna::where('id', $request->coluna_id)
                             ->where('unidade_id', $user->unidade_id)
                             ->first();
        
        if (!$coluna) {
            return $this->error('Coluna não encontrada', 404);
        }

        // Definir posição como última da coluna
        $posicao = KanbanCard::where('coluna_id', $request->coluna_id)->max('posicao') + 1;

        $data = $request->all();
        $data['posicao'] = $posicao;
        $data['prioridade'] = $data['prioridade'] ?? 'media';

        $card = KanbanCard::create($data);
        $card->load(['processo.cliente', 'tarefa', 'responsavel', 'coluna']);

        return $this->success($card, 'Card criado com sucesso', 201);
    }

    /**
     * @OA\Put(
     *     path="/admin/kanban/cards/{id}",
     *     summary="Atualizar card do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Card atualizado com sucesso")
     * )
     */
    public function atualizarCard(Request $request, $id)
    {
        $user = auth()->user();
        $card = KanbanCard::whereHas('coluna', function($q) use ($user) {
                             $q->where('unidade_id', $user->unidade_id);
                         })->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'titulo' => 'string|max:255',
            'descricao' => 'nullable|string',
            'coluna_id' => 'exists:kanban_colunas,id',
            'processo_id' => 'nullable|exists:processos,id',
            'tarefa_id' => 'nullable|exists:tarefas,id',
            'prioridade' => 'in:baixa,media,alta,urgente',
            'prazo' => 'nullable|date',
            'responsavel_id' => 'exists:users,id'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $card->update($request->all());
        $card->load(['processo.cliente', 'tarefa', 'responsavel', 'coluna']);

        return $this->success($card, 'Card atualizado com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/admin/kanban/cards/{id}/mover",
     *     summary="Mover card entre colunas",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"coluna_id","posicao"},
     *             @OA\Property(property="coluna_id", type="integer"),
     *             @OA\Property(property="posicao", type="integer")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Card movido com sucesso")
     * )
     */
    public function moverCard(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'coluna_id' => 'required|exists:kanban_colunas,id',
            'posicao' => 'required|integer|min:1'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();
        
        DB::transaction(function() use ($request, $id, $user) {
            $card = KanbanCard::whereHas('coluna', function($q) use ($user) {
                                 $q->where('unidade_id', $user->unidade_id);
                             })->findOrFail($id);

            $colunaDestino = KanbanColuna::where('id', $request->coluna_id)
                                       ->where('unidade_id', $user->unidade_id)
                                       ->firstOrFail();

            $colunaOrigem = $card->coluna_id;
            $posicaoOrigem = $card->posicao;

            // Se mudou de coluna
            if ($colunaOrigem != $request->coluna_id) {
                // Reorganizar posições na coluna origem
                KanbanCard::where('coluna_id', $colunaOrigem)
                          ->where('posicao', '>', $posicaoOrigem)
                          ->decrement('posicao');

                // Reorganizar posições na coluna destino
                KanbanCard::where('coluna_id', $request->coluna_id)
                          ->where('posicao', '>=', $request->posicao)
                          ->increment('posicao');
            } else {
                // Mover dentro da mesma coluna
                if ($request->posicao > $posicaoOrigem) {
                    KanbanCard::where('coluna_id', $colunaOrigem)
                              ->whereBetween('posicao', [$posicaoOrigem + 1, $request->posicao])
                              ->decrement('posicao');
                } else {
                    KanbanCard::where('coluna_id', $colunaOrigem)
                              ->whereBetween('posicao', [$request->posicao, $posicaoOrigem - 1])
                              ->increment('posicao');
                }
            }

            // Atualizar o card
            $card->update([
                'coluna_id' => $request->coluna_id,
                'posicao' => $request->posicao
            ]);
        });

        return $this->success(null, 'Card movido com sucesso');
    }

    /**
     * @OA\Delete(
     *     path="/admin/kanban/cards/{id}",
     *     summary="Excluir card do kanban",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Card excluído com sucesso")
     * )
     */
    public function excluirCard($id)
    {
        $user = auth()->user();
        $card = KanbanCard::whereHas('coluna', function($q) use ($user) {
                             $q->where('unidade_id', $user->unidade_id);
                         })->findOrFail($id);

        // Reorganizar posições
        KanbanCard::where('coluna_id', $card->coluna_id)
                  ->where('posicao', '>', $card->posicao)
                  ->decrement('posicao');

        $card->delete();
        return $this->success(null, 'Card excluído com sucesso');
    }

    /**
     * Reordenar colunas
     */
    public function reordenarColunas(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'colunas' => 'required|array',
            'colunas.*.id' => 'required|exists:kanban_colunas,id',
            'colunas.*.ordem' => 'required|integer|min:1'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $user = auth()->user();

        DB::transaction(function() use ($request, $user) {
            foreach ($request->colunas as $colunaData) {
                KanbanColuna::where('id', $colunaData['id'])
                           ->where('unidade_id', $user->unidade_id)
                           ->update(['ordem' => $colunaData['ordem']]);
            }
        });

        return $this->success(null, 'Colunas reordenadas com sucesso');
    }
}
