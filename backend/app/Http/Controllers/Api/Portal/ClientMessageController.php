<?php

namespace App\Http\Controllers\Api\Portal;

use App\Http\Controllers\Controller;
use App\Models\Mensagem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ClientMessageController extends Controller
{
    /**
     * @OA\Get(
     *     path="/portal/messages",
     *     summary="Listar mensagens do cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Lista de mensagens")
     * )
     */
    public function index(Request $request)
    {
        $cliente = auth('cliente')->user();
        
        $query = Mensagem::where('cliente_id', $cliente->id)
                        ->with(['remetente', 'processo']);

        // Filtros
        if ($request->tipo) {
            $query->where('tipo', $request->tipo);
        }

        if ($request->processo_id) {
            $query->where('processo_id', $request->processo_id);
        }

        if ($request->nao_lidas) {
            $query->naoLidas();
        }

        $mensagens = $query->orderBy('data_envio', 'desc')
                          ->paginate($request->per_page ?? 20);

        // Registrar acesso
        $cliente->acessosPortal()->create([
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data_acesso' => now(),
            'acao' => 'visualizar_mensagens'
        ]);

        return $this->paginated($mensagens);
    }

    /**
     * @OA\Get(
     *     path="/portal/messages/{id}",
     *     summary="Obter mensagem",
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(name="id", in="path", required=true, @OA\Schema(type="integer")),
     *     @OA\Response(response=200, description="Dados da mensagem")
     * )
     */
    public function show($id)
    {
        $cliente = auth('cliente')->user();
        
        $mensagem = Mensagem::where('cliente_id', $cliente->id)
                          ->with(['remetente', 'processo'])
                          ->findOrFail($id);

        // Marcar como lida
        if (!$mensagem->lida && $mensagem->destinatario_id === null) {
            $mensagem->update([
                'lida' => true,
                'data_leitura' => now()
            ]);
        }

        return $this->success($mensagem);
    }

    /**
     * @OA\Post(
     *     path="/portal/messages",
     *     summary="Enviar mensagem",
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"conteudo"},
     *             @OA\Property(property="conteudo", type="string"),
     *             @OA\Property(property="processo_id", type="integer"),
     *             @OA\Property(property="destinatario_id", type="integer")
     *         )
     *     ),
     *     @OA\Response(response=201, description="Mensagem enviada com sucesso")
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'conteudo' => 'required|string',
            'processo_id' => 'nullable|exists:processos,id',
            'destinatario_id' => 'nullable|exists:users,id',
            'tipo' => 'in:texto,arquivo'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $cliente = auth('cliente')->user();

        // Verificar se processo pertence ao cliente
        if ($request->processo_id) {
            $processo = $cliente->processos()->find($request->processo_id);
            if (!$processo) {
                return $this->error('Processo não encontrado', 404);
            }
        }

        // Se não especificou destinatário, enviar para o responsável do cliente
        $destinatarioId = $request->destinatario_id ?? $cliente->responsavel_id;

        $mensagem = Mensagem::create([
            'remetente_id' => null, // Cliente não tem user_id
            'destinatario_id' => $destinatarioId,
            'cliente_id' => $cliente->id,
            'processo_id' => $request->processo_id,
            'conteudo' => $request->conteudo,
            'tipo' => $request->tipo ?? 'texto',
            'data_envio' => now(),
            'lida' => false
        ]);

        // Registrar acesso
        $cliente->acessosPortal()->create([
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data_acesso' => now(),
            'acao' => 'enviar_mensagem',
            'detalhes' => 'Mensagem para: ' . $mensagem->destinatario->nome
        ]);

        $mensagem->load(['destinatario', 'processo']);

        return $this->success($mensagem, 'Mensagem enviada com sucesso', 201);
    }

    /**
     * Marcar mensagem como lida
     */
    public function markAsRead($id)
    {
        $cliente = auth('cliente')->user();
        
        $mensagem = Mensagem::where('cliente_id', $cliente->id)
                          ->where('destinatario_id', null) // Mensagem para o cliente
                          ->findOrFail($id);

        $mensagem->update([
            'lida' => true,
            'data_leitura' => now()
        ]);

        return $this->success(null, 'Mensagem marcada como lida');
    }

    /**
     * Marcar todas as mensagens como lidas
     */
    public function markAllAsRead()
    {
        $cliente = auth('cliente')->user();
        
        Mensagem::where('cliente_id', $cliente->id)
               ->where('destinatario_id', null)
               ->where('lida', false)
               ->update([
                   'lida' => true,
                   'data_leitura' => now()
               ]);

        return $this->success(null, 'Todas as mensagens foram marcadas como lidas');
    }

    /**
     * Conversas agrupadas
     */
    public function conversations()
    {
        $cliente = auth('cliente')->user();
        
        // Buscar últimas mensagens de cada processo
        $conversasProcessos = Mensagem::where('cliente_id', $cliente->id)
                                    ->whereNotNull('processo_id')
                                    ->with(['processo', 'remetente'])
                                    ->get()
                                    ->groupBy('processo_id')
                                    ->map(function($mensagens) {
                                        $ultima = $mensagens->sortByDesc('data_envio')->first();
                                        return [
                                            'tipo' => 'processo',
                                            'processo' => $ultima->processo,
                                            'ultima_mensagem' => $ultima,
                                            'nao_lidas' => $mensagens->where('lida', false)->count()
                                        ];
                                    });

        // Mensagens gerais (sem processo)
        $mensagensGerais = Mensagem::where('cliente_id', $cliente->id)
                                 ->whereNull('processo_id')
                                 ->with(['remetente'])
                                 ->orderBy('data_envio', 'desc')
                                 ->limit(10)
                                 ->get();

        $conversaGeral = [
            'tipo' => 'geral',
            'titulo' => 'Conversa Geral',
            'mensagens' => $mensagensGerais,
            'nao_lidas' => $mensagensGerais->where('lida', false)->count()
        ];

        return $this->success([
            'processos' => $conversasProcessos->values(),
            'geral' => $conversaGeral
        ]);
    }

    /**
     * Estatísticas de mensagens
     */
    public function statistics()
    {
        $cliente = auth('cliente')->user();
        
        $stats = [
            'total_mensagens' => Mensagem::where('cliente_id', $cliente->id)->count(),
            'nao_lidas' => Mensagem::where('cliente_id', $cliente->id)->naoLidas()->count(),
            'enviadas' => Mensagem::where('cliente_id', $cliente->id)
                               ->whereNull('remetente_id')
                               ->count(),
            'recebidas' => Mensagem::where('cliente_id', $cliente->id)
                                ->whereNotNull('remetente_id')
                                ->count()
        ];

        return $this->success($stats);
    }
}
