<?php

namespace App\Http\Controllers\Api\Portal;

use App\Http\Controllers\Controller;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\Atendimento;
use App\Models\Financeiro;
use App\Models\DocumentoGed;
use App\Models\Mensagem;
use Illuminate\Http\Request;

class ClientDashboardController extends Controller
{
    /**
     * @OA\Get(
     *     path="/portal/dashboard",
     *     summary="Dashboard do cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do dashboard do cliente")
     * )
     */
    public function index()
    {
        $cliente = auth('cliente')->user();

        // Estatísticas do cliente
        $stats = [
            'processos' => [
                'total' => $cliente->processos()->count(),
                'ativos' => $cliente->processos()->ativos()->count(),
                'finalizados' => $cliente->processos()->where('status', 'finalizado')->count(),
                'proximos_prazos' => $cliente->processos()->comPrazoVencendo(30)->count()
            ],
            'atendimentos' => [
                'total' => $cliente->atendimentos()->count(),
                'proximos' => $cliente->atendimentos()
                                    ->where('status', 'agendado')
                                    ->where('data_hora', '>=', now())
                                    ->count(),
                'realizados' => $cliente->atendimentos()->where('status', 'concluido')->count()
            ],
            'financeiro' => [
                'pendente' => $cliente->financeiro()->pendentes()->sum('valor'),
                'pago_mes_atual' => $cliente->financeiro()
                                          ->where('status', 'pago')
                                          ->whereMonth('data_pagamento', now()->month)
                                          ->sum('valor'),
                'vencidos' => $cliente->financeiro()->vencidos()->count()
            ],
            'documentos' => [
                'total' => $cliente->documentos()->count(),
                'recentes' => $cliente->documentos()
                                    ->where('data_upload', '>=', now()->subDays(30))
                                    ->count()
            ],
            'mensagens' => [
                'nao_lidas' => Mensagem::where('cliente_id', $cliente->id)
                                     ->where('destinatario_id', null) // Mensagens para o cliente
                                     ->naoLidas()
                                     ->count()
            ]
        ];

        // Próximos atendimentos
        $proximosAtendimentos = $cliente->atendimentos()
                                      ->with(['advogado'])
                                      ->where('status', 'agendado')
                                      ->where('data_hora', '>=', now())
                                      ->orderBy('data_hora')
                                      ->limit(3)
                                      ->get();

        // Processos com movimentações recentes
        $processosRecentes = $cliente->processos()
                                   ->with(['movimentacoes' => function($q) {
                                       $q->orderBy('data', 'desc')->limit(1);
                                   }])
                                   ->whereHas('movimentacoes', function($q) {
                                       $q->where('data', '>=', now()->subDays(30));
                                   })
                                   ->limit(5)
                                   ->get();

        // Pagamentos pendentes
        $pagamentosPendentes = $cliente->financeiro()
                                     ->pendentes()
                                     ->orderBy('data_vencimento')
                                     ->limit(5)
                                     ->get();

        // Documentos recentes
        $documentosRecentes = $cliente->documentos()
                                    ->with(['usuario'])
                                    ->orderBy('data_upload', 'desc')
                                    ->limit(5)
                                    ->get();

        // Mensagens não lidas
        $mensagensNaoLidas = Mensagem::where('cliente_id', $cliente->id)
                                   ->where('destinatario_id', null)
                                   ->naoLidas()
                                   ->with(['remetente'])
                                   ->orderBy('data_envio', 'desc')
                                   ->limit(5)
                                   ->get();

        return $this->success([
            'stats' => $stats,
            'dados' => [
                'proximos_atendimentos' => $proximosAtendimentos,
                'processos_recentes' => $processosRecentes,
                'pagamentos_pendentes' => $pagamentosPendentes,
                'documentos_recentes' => $documentosRecentes,
                'mensagens_nao_lidas' => $mensagensNaoLidas
            ]
        ]);
    }

    /**
     * @OA\Get(
     *     path="/portal/profile",
     *     summary="Perfil do cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do perfil")
     * )
     */
    public function profile()
    {
        $cliente = auth('cliente')->user();
        $cliente->load(['unidade', 'responsavel']);

        // Registrar acesso
        $cliente->acessosPortal()->create([
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'data_acesso' => now(),
            'acao' => 'visualizar_perfil'
        ]);

        return $this->success($cliente);
    }

    /**
     * @OA\Put(
     *     path="/portal/profile",
     *     summary="Atualizar perfil do cliente",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Perfil atualizado com sucesso")
     * )
     */
    public function updateProfile(Request $request)
    {
        $cliente = auth('cliente')->user();

        $validator = \Validator::make($request->all(), [
            'telefone' => 'string|max:15',
            'endereco' => 'string',
            'cep' => 'string|max:9',
            'cidade' => 'string|max:100',
            'estado' => 'string|size:2'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        // Apenas campos permitidos para o cliente alterar
        $cliente->update($request->only([
            'telefone', 'endereco', 'cep', 'cidade', 'estado'
        ]));

        return $this->success($cliente, 'Perfil atualizado com sucesso');
    }

    /**
     * Alterar senha do portal
     */
    public function changePassword(Request $request)
    {
        $validator = \Validator::make($request->all(), [
            'current_password' => 'required|string',
            'password' => 'required|string|min:8|confirmed'
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $cliente = auth('cliente')->user();

        if (!\Hash::check($request->current_password, $cliente->senha_portal)) {
            return $this->error('Senha atual incorreta', 401);
        }

        $cliente->update([
            'senha_portal' => \Hash::make($request->password)
        ]);

        return $this->success(null, 'Senha alterada com sucesso');
    }

    /**
     * Notificações do cliente
     */
    public function notifications()
    {
        $cliente = auth('cliente')->user();

        $notifications = [];

        // Pagamentos vencidos
        $vencidos = $cliente->financeiro()->vencidos()->count();
        if ($vencidos > 0) {
            $notifications[] = [
                'type' => 'warning',
                'title' => 'Pagamentos Vencidos',
                'message' => "{$vencidos} pagamento(s) em atraso",
                'action' => '/portal/pagamentos?filter=vencidos'
            ];
        }

        // Próximos atendimentos
        $proximosAtendimentos = $cliente->atendimentos()
                                      ->where('status', 'agendado')
                                      ->where('data_hora', '>=', now())
                                      ->where('data_hora', '<=', now()->addDays(3))
                                      ->count();

        if ($proximosAtendimentos > 0) {
            $notifications[] = [
                'type' => 'info',
                'title' => 'Próximos Atendimentos',
                'message' => "{$proximosAtendimentos} atendimento(s) nos próximos 3 dias",
                'action' => '/portal/atendimentos'
            ];
        }

        // Mensagens não lidas
        $mensagensNaoLidas = Mensagem::where('cliente_id', $cliente->id)
                                   ->naoLidas()
                                   ->count();

        if ($mensagensNaoLidas > 0) {
            $notifications[] = [
                'type' => 'primary',
                'title' => 'Novas Mensagens',
                'message' => "{$mensagensNaoLidas} mensagem(ns) não lida(s)",
                'action' => '/portal/mensagens'
            ];
        }

        return $this->success($notifications);
    }
}
