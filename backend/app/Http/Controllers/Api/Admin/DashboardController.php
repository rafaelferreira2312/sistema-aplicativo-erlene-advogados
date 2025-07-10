<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\Atendimento;
use App\Models\Financeiro;
use App\Models\Tarefa;
use Illuminate\Http\Request;
use Carbon\Carbon;

class DashboardController extends Controller
{
    /**
     * @OA\Get(
     *     path="/admin/dashboard",
     *     summary="Dashboard administrativo",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do dashboard")
     * )
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $unidadeId = $user->unidade_id;
        
        // Estatísticas gerais
        $stats = [
            'clientes' => [
                'total' => Cliente::where('unidade_id', $unidadeId)->count(),
                'ativos' => Cliente::where('unidade_id', $unidadeId)->where('status', 'ativo')->count(),
                'novos_mes' => Cliente::where('unidade_id', $unidadeId)
                                   ->whereMonth('created_at', now()->month)
                                   ->count()
            ],
            'processos' => [
                'total' => Processo::where('unidade_id', $unidadeId)->count(),
                'ativos' => Processo::where('unidade_id', $unidadeId)->ativos()->count(),
                'urgentes' => Processo::where('unidade_id', $unidadeId)
                                    ->where('prioridade', 'urgente')
                                    ->count(),
                'prazos_vencendo' => Processo::where('unidade_id', $unidadeId)
                                           ->comPrazoVencendo(7)
                                           ->count()
            ],
            'atendimentos' => [
                'hoje' => Atendimento::where('unidade_id', $unidadeId)->hoje()->count(),
                'semana' => Atendimento::where('unidade_id', $unidadeId)
                                     ->whereBetween('data_hora', [now()->startOfWeek(), now()->endOfWeek()])
                                     ->count(),
                'agendados' => Atendimento::where('unidade_id', $unidadeId)->agendados()->count()
            ],
            'financeiro' => [
                'receita_mes' => Financeiro::where('unidade_id', $unidadeId)
                                         ->where('status', 'pago')
                                         ->whereMonth('data_pagamento', now()->month)
                                         ->sum('valor'),
                'pendente' => Financeiro::where('unidade_id', $unidadeId)->pendentes()->sum('valor'),
                'vencidos' => Financeiro::where('unidade_id', $unidadeId)->vencidos()->sum('valor')
            ],
            'tarefas' => [
                'pendentes' => Tarefa::where('responsavel_id', $user->id)->pendentes()->count(),
                'vencidas' => Tarefa::where('responsavel_id', $user->id)->vencidas()->count()
            ]
        ];

        // Gráfico de atendimentos dos últimos 30 dias
        $atendimentosGrafico = [];
        for ($i = 29; $i >= 0; $i--) {
            $data = now()->subDays($i)->format('Y-m-d');
            $count = Atendimento::where('unidade_id', $unidadeId)
                               ->whereDate('data_hora', $data)
                               ->count();
            
            $atendimentosGrafico[] = [
                'data' => $data,
                'quantidade' => $count
            ];
        }

        // Receitas dos últimos 12 meses
        $receitasGrafico = [];
        for ($i = 11; $i >= 0; $i--) {
            $mes = now()->subMonths($i);
            $receita = Financeiro::where('unidade_id', $unidadeId)
                                ->where('status', 'pago')
                                ->whereYear('data_pagamento', $mes->year)
                                ->whereMonth('data_pagamento', $mes->month)
                                ->sum('valor');
            
            $receitasGrafico[] = [
                'mes' => $mes->format('Y-m'),
                'mes_nome' => $mes->format('M/Y'),
                'receita' => (float) $receita
            ];
        }

        // Próximos atendimentos
        $proximosAtendimentos = Atendimento::with(['cliente', 'advogado'])
                                         ->where('unidade_id', $unidadeId)
                                         ->where('status', 'agendado')
                                         ->where('data_hora', '>=', now())
                                         ->orderBy('data_hora')
                                         ->limit(5)
                                         ->get();

        // Processos com prazos vencendo
        $processosUrgentes = Processo::with(['cliente', 'advogado'])
                                   ->where('unidade_id', $unidadeId)
                                   ->comPrazoVencendo(7)
                                   ->orderBy('proximo_prazo')
                                   ->limit(5)
                                   ->get();

        // Tarefas pendentes do usuário
        $tarefasPendentes = Tarefa::with(['cliente', 'processo'])
                                 ->where('responsavel_id', $user->id)
                                 ->pendentes()
                                 ->orderBy('prazo')
                                 ->limit(5)
                                 ->get();

        return $this->success([
            'stats' => $stats,
            'graficos' => [
                'atendimentos' => $atendimentosGrafico,
                'receitas' => $receitasGrafico
            ],
            'listas' => [
                'proximos_atendimentos' => $proximosAtendimentos,
                'processos_urgentes' => $processosUrgentes,
                'tarefas_pendentes' => $tarefasPendentes
            ]
        ]);
    }

    /**
     * @OA\Get(
     *     path="/admin/dashboard/notifications",
     *     summary="Notificações do dashboard",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Notificações")
     * )
     */
    public function notifications()
    {
        $user = auth()->user();
        
        $notifications = [];

        // Prazos vencendo
        $prazosVencendo = Processo::where('unidade_id', $user->unidade_id)
                                ->comPrazoVencendo(3)
                                ->count();
        
        if ($prazosVencendo > 0) {
            $notifications[] = [
                'type' => 'warning',
                'title' => 'Prazos Vencendo',
                'message' => "{$prazosVencendo} processo(s) com prazo vencendo em 3 dias",
                'action' => '/admin/processos?filter=prazo_vencendo'
            ];
        }

        // Atendimentos hoje
        $atendimentosHoje = Atendimento::where('unidade_id', $user->unidade_id)
                                     ->hoje()
                                     ->agendados()
                                     ->count();
        
        if ($atendimentosHoje > 0) {
            $notifications[] = [
                'type' => 'info',
                'title' => 'Atendimentos Hoje',
                'message' => "{$atendimentosHoje} atendimento(s) agendado(s) para hoje",
                'action' => '/admin/atendimentos?filter=hoje'
            ];
        }

        // Pagamentos vencidos
        $pagamentosVencidos = Financeiro::where('unidade_id', $user->unidade_id)
                                      ->vencidos()
                                      ->count();
        
        if ($pagamentosVencidos > 0) {
            $notifications[] = [
                'type' => 'danger',
                'title' => 'Pagamentos Vencidos',
                'message' => "{$pagamentosVencidos} pagamento(s) em atraso",
                'action' => '/admin/financeiro?filter=vencidos'
            ];
        }

        return $this->success($notifications);
    }
}
