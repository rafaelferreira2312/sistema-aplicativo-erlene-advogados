#!/bin/bash

# Script 114w - Backend Dashboard Completo com Dados Reais e Funcionalidades
# Sistema Erlene Advogados - Backend Laravel
# EXECUTE DENTRO DA PASTA: backend/
# Comando: chmod +x 114w-backend-dashboard-complete.sh && ./114w-backend-dashboard-complete.sh

echo "Script 114w - Backend Dashboard Completo com Dados Reais..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "Erro: Execute este script dentro da pasta backend/"
    echo "Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 114w-backend-dashboard-complete.sh && ./114w-backend-dashboard-complete.sh"
    exit 1
fi

echo "1. Verificando estrutura Laravel..."

echo "2. Atualizando DashboardController com dados reais e porcentagens funcionais..."

# Atualizar DashboardController com cálculos reais
cat > app/Http/Controllers/Api/Admin/DashboardController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\Atendimento;
use App\Models\Financeiro;
use App\Models\Tarefa;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = auth()->user();
            $unidadeId = $user->unidade_id ?? 1;
            
            // Calcular dados com comparação para porcentagens
            $mesAtual = now();
            $mesAnterior = now()->copy()->subMonth();
            
            // CLIENTES - contagem real da tabela users
            $totalClientes = User::where('unidade_id', $unidadeId)->count();
            $clientesAtivos = User::where('unidade_id', $unidadeId)
                                 ->where('status', 'ativo')
                                 ->count();
            $clientesNovos = User::where('unidade_id', $unidadeId)
                                ->whereMonth('created_at', $mesAtual->month)
                                ->whereYear('created_at', $mesAtual->year)
                                ->count();
                                
            // Clientes mês anterior para cálculo de porcentagem
            $clientesMesAnterior = User::where('unidade_id', $unidadeId)
                                      ->where('created_at', '<', $mesAtual->startOfMonth())
                                      ->count();
                                      
            $porcentagemClientes = $this->calcularPorcentagem($totalClientes, $clientesMesAnterior);
            
            // PROCESSOS - dados reais
            $processosTotal = Processo::where('unidade_id', $unidadeId)->count();
            $processosAtivos = Processo::where('unidade_id', $unidadeId)
                                     ->whereIn('status', ['ativo', 'em_andamento'])
                                     ->count();
            $processosUrgentes = Processo::where('unidade_id', $unidadeId)
                                       ->where('prioridade', 'urgente')
                                       ->count();
                                       
            $processosMesAnterior = Processo::where('unidade_id', $unidadeId)
                                          ->where('created_at', '<', $mesAtual->startOfMonth())
                                          ->count();
                                          
            $porcentagemProcessos = $this->calcularPorcentagem($processosTotal, $processosMesAnterior);
            
            // ATENDIMENTOS - dados reais
            $atendimentosHoje = Atendimento::where('unidade_id', $unidadeId)
                                         ->whereDate('data_hora', today())
                                         ->count();
            $atendimentosSemana = Atendimento::where('unidade_id', $unidadeId)
                                           ->whereBetween('data_hora', [
                                               now()->startOfWeek(),
                                               now()->endOfWeek()
                                           ])
                                           ->count();
            $atendimentosAgendados = Atendimento::where('unidade_id', $unidadeId)
                                              ->where('status', 'agendado')
                                              ->where('data_hora', '>=', now())
                                              ->count();
                                              
            $atendimentosSemanaAnterior = Atendimento::where('unidade_id', $unidadeId)
                                                   ->whereBetween('data_hora', [
                                                       now()->subWeek()->startOfWeek(),
                                                       now()->subWeek()->endOfWeek()
                                                   ])
                                                   ->count();
                                                   
            $porcentagemAtendimentos = $this->calcularPorcentagem($atendimentosSemana, $atendimentosSemanaAnterior);
            
            // FINANCEIRO - dados reais
            $receitaMesAtual = Financeiro::where('unidade_id', $unidadeId)
                                       ->where('tipo', 'receita')
                                       ->where('status', 'pago')
                                       ->whereMonth('data_pagamento', $mesAtual->month)
                                       ->whereYear('data_pagamento', $mesAtual->year)
                                       ->sum('valor');
                                       
            $receitaMesAnterior = Financeiro::where('unidade_id', $unidadeId)
                                          ->where('tipo', 'receita')
                                          ->where('status', 'pago')
                                          ->whereMonth('data_pagamento', $mesAnterior->month)
                                          ->whereYear('data_pagamento', $mesAnterior->year)
                                          ->sum('valor');
                                          
            $receitaPendente = Financeiro::where('unidade_id', $unidadeId)
                                       ->where('tipo', 'receita')
                                       ->where('status', 'pendente')
                                       ->sum('valor');
                                       
            $receitaVencida = Financeiro::where('unidade_id', $unidadeId)
                                      ->where('tipo', 'receita')
                                      ->where('status', 'pendente')
                                      ->where('data_vencimento', '<', now())
                                      ->sum('valor');
                                      
            $porcentagemReceita = $this->calcularPorcentagem($receitaMesAtual, $receitaMesAnterior);
            
            // TAREFAS - dados reais
            $tarefasPendentes = Tarefa::where('responsavel_id', $user->id)
                                    ->where('status', 'pendente')
                                    ->count();
            $tarefasVencidas = Tarefa::where('responsavel_id', $user->id)
                                   ->where('status', 'pendente')
                                   ->where('prazo', '<', now())
                                   ->count();
            
            // Montar resposta com dados reais
            $stats = [
                'clientes' => [
                    'total' => $totalClientes,
                    'ativos' => $clientesAtivos,
                    'novos_mes' => $clientesNovos,
                    'porcentagem' => $porcentagemClientes['valor'],
                    'tipo_mudanca' => $porcentagemClientes['tipo']
                ],
                'processos' => [
                    'total' => $processosTotal,
                    'ativos' => $processosAtivos,
                    'urgentes' => $processosUrgentes,
                    'prazos_vencendo' => $this->getProcessosComPrazoVencendo($unidadeId, 7),
                    'porcentagem' => $porcentagemProcessos['valor'],
                    'tipo_mudanca' => $porcentagemProcessos['tipo']
                ],
                'atendimentos' => [
                    'hoje' => $atendimentosHoje,
                    'semana' => $atendimentosSemana,
                    'agendados' => $atendimentosAgendados,
                    'porcentagem' => $porcentagemAtendimentos['valor'],
                    'tipo_mudanca' => $porcentagemAtendimentos['tipo']
                ],
                'financeiro' => [
                    'receita_mes' => (float) $receitaMesAtual,
                    'receita_mes_formatada' => 'R$ ' . number_format($receitaMesAtual, 2, ',', '.'),
                    'pendente' => (float) $receitaPendente,
                    'pendente_formatada' => 'R$ ' . number_format($receitaPendente, 2, ',', '.'),
                    'vencidos' => (float) $receitaVencida,
                    'vencidos_formatada' => 'R$ ' . number_format($receitaVencida, 2, ',', '.'),
                    'porcentagem' => $porcentagemReceita['valor'],
                    'tipo_mudanca' => $porcentagemReceita['tipo']
                ],
                'tarefas' => [
                    'pendentes' => $tarefasPendentes,
                    'vencidas' => $tarefasVencidas
                ]
            ];

            // URLs funcionais para navegação
            $acoes_rapidas = [
                'novo_cliente' => '/admin/clientes/novo',
                'novo_processo' => '/admin/processos/novo', 
                'agendar_atendimento' => '/admin/atendimentos/novo',
                'novo_prazo' => '/admin/prazos/novo',
                'relatorios' => '/admin/reports',
                'upload_documento' => '/admin/documentos/novo',
                'lancar_pagamento' => '/admin/financeiro/novo'
            ];

            // Gráfico de atendimentos (últimos 30 dias)
            $atendimentosGrafico = $this->getAtendimentosGrafico($unidadeId);
            
            // Gráfico de receitas (últimos 12 meses)
            $receitasGrafico = $this->getReceitasGrafico($unidadeId);
            
            // Listas para widgets
            $proximosAtendimentos = $this->getProximosAtendimentos($unidadeId);
            $processosUrgentes = $this->getProcessosUrgentes($unidadeId);
            $tarefasPendentesLista = $this->getTarefasPendentes($user->id);

            return response()->json([
                'success' => true,
                'message' => 'Dashboard carregado com dados reais',
                'data' => [
                    'stats' => $stats,
                    'graficos' => [
                        'atendimentos' => $atendimentosGrafico,
                        'receitas' => $receitasGrafico
                    ],
                    'listas' => [
                        'proximos_atendimentos' => $proximosAtendimentos,
                        'processos_urgentes' => $processosUrgentes,
                        'tarefas_pendentes' => $tarefasPendentesLista
                    ],
                    'acoes_rapidas' => $acoes_rapidas,
                    'ultima_atualizacao' => now()->format('d/m/Y H:i:s')
                ]
            ]);

        } catch (\Exception $e) {
            \Log::error('Erro no Dashboard: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Erro ao carregar dashboard',
                'error' => config('app.debug') ? $e->getMessage() : 'Erro interno do servidor'
            ], 500);
        }
    }

    /**
     * Calcular porcentagem real de mudança
     */
    private function calcularPorcentagem($valorAtual, $valorAnterior)
    {
        if ($valorAnterior == 0) {
            if ($valorAtual > 0) {
                return ['valor' => '+100%', 'tipo' => 'increase'];
            }
            return ['valor' => '0%', 'tipo' => 'stable'];
        }
        
        $percentual = (($valorAtual - $valorAnterior) / $valorAnterior) * 100;
        $percentualFormatado = ($percentual >= 0 ? '+' : '') . number_format($percentual, 0) . '%';
        
        $tipo = 'stable';
        if ($percentual > 5) $tipo = 'increase';
        elseif ($percentual < -5) $tipo = 'decrease';
        
        return [
            'valor' => $percentualFormatado,
            'tipo' => $tipo
        ];
    }

    private function getProcessosComPrazoVencendo($unidadeId, $days)
    {
        return Processo::where('unidade_id', $unidadeId)
                      ->whereNotNull('proximo_prazo')
                      ->where('proximo_prazo', '>=', now())
                      ->where('proximo_prazo', '<=', now()->addDays($days))
                      ->count();
    }

    private function getAtendimentosGrafico($unidadeId)
    {
        $dados = [];
        for ($i = 29; $i >= 0; $i--) {
            $data = now()->subDays($i);
            $count = Atendimento::where('unidade_id', $unidadeId)
                              ->whereDate('data_hora', $data->format('Y-m-d'))
                              ->count();
            
            $dados[] = [
                'data' => $data->format('Y-m-d'),
                'data_formatada' => $data->format('d/m'),
                'quantidade' => $count
            ];
        }
        return $dados;
    }

    private function getReceitasGrafico($unidadeId)
    {
        $dados = [];
        for ($i = 11; $i >= 0; $i--) {
            $mes = now()->subMonths($i);
            $receita = Financeiro::where('unidade_id', $unidadeId)
                                ->where('tipo', 'receita')
                                ->where('status', 'pago')
                                ->whereYear('data_pagamento', $mes->year)
                                ->whereMonth('data_pagamento', $mes->month)
                                ->sum('valor');
            
            $dados[] = [
                'mes' => $mes->format('Y-m'),
                'mes_nome' => $mes->format('M/Y'),
                'receita' => (float) $receita,
                'receita_formatada' => 'R$ ' . number_format($receita, 2, ',', '.')
            ];
        }
        return $dados;
    }

    private function getProximosAtendimentos($unidadeId)
    {
        return Atendimento::with(['cliente:id,nome', 'advogado:id,nome'])
                         ->where('unidade_id', $unidadeId)
                         ->where('status', 'agendado')
                         ->where('data_hora', '>=', now())
                         ->orderBy('data_hora')
                         ->limit(5)
                         ->get()
                         ->map(function ($item) {
                             return [
                                 'id' => $item->id,
                                 'cliente_nome' => $item->cliente->nome ?? 'N/A',
                                 'advogado_nome' => $item->advogado->nome ?? 'N/A',
                                 'data_formatada' => Carbon::parse($item->data_hora)->format('d/m/Y H:i'),
                                 'assunto' => $item->assunto ?? 'Atendimento'
                             ];
                         });
    }

    private function getProcessosUrgentes($unidadeId)
    {
        return Processo::with(['cliente:id,nome'])
                      ->where('unidade_id', $unidadeId)
                      ->whereNotNull('proximo_prazo')
                      ->where('proximo_prazo', '>=', now())
                      ->where('proximo_prazo', '<=', now()->addDays(7))
                      ->orderBy('proximo_prazo')
                      ->limit(5)
                      ->get()
                      ->map(function ($item) {
                          return [
                              'id' => $item->id,
                              'numero' => $item->numero,
                              'cliente_nome' => $item->cliente->nome ?? 'N/A',
                              'prazo_formatado' => Carbon::parse($item->proximo_prazo)->format('d/m/Y'),
                              'dias_restantes' => Carbon::parse($item->proximo_prazo)->diffInDays(now())
                          ];
                      });
    }

    private function getTarefasPendentes($userId)
    {
        return Tarefa::with(['cliente:id,nome'])
                     ->where('responsavel_id', $userId)
                     ->where('status', 'pendente')
                     ->orderBy('prazo')
                     ->limit(5)
                     ->get()
                     ->map(function ($item) {
                         return [
                             'id' => $item->id,
                             'titulo' => $item->titulo,
                             'cliente_nome' => $item->cliente->nome ?? null,
                             'prazo_formatado' => $item->prazo ? Carbon::parse($item->prazo)->format('d/m/Y') : null,
                             'vencida' => $item->prazo ? Carbon::parse($item->prazo)->isPast() : false
                         ];
                     });
    }

    public function notifications()
    {
        try {
            $user = auth()->user();
            $unidadeId = $user->unidade_id ?? 1;
            $notifications = [];

            // Verificar cada tipo de notificação
            $prazosVencendo = $this->getProcessosComPrazoVencendo($unidadeId, 3);
            if ($prazosVencendo > 0) {
                $notifications[] = [
                    'type' => 'warning',
                    'title' => 'Prazos Vencendo',
                    'message' => "{$prazosVencendo} processo(s) com prazo em 3 dias",
                    'action' => '/admin/processos?filter=prazo_vencendo'
                ];
            }

            return response()->json([
                'success' => true,
                'data' => $notifications
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao carregar notificações'
            ], 500);
        }
    }
}
EOF

echo "3. Verificando se as rotas estão configuradas..."

# Verificar e adicionar rotas se necessário
if ! grep -q "DashboardController" routes/api.php; then
    echo "Adicionando rotas do dashboard..."
    cat >> routes/api.php << 'EOF'

// Dashboard Admin com dados reais
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::get('/dashboard', [App\Http\Controllers\Api\Admin\DashboardController::class, 'index']);
    Route::get('/dashboard/notifications', [App\Http\Controllers\Api\Admin\DashboardController::class, 'notifications']);
});
EOF
fi

echo ""
echo "SCRIPT 114w CONCLUÍDO!"
echo ""
echo "FUNCIONALIDADES IMPLEMENTADAS:"
echo "   ✓ Contagem real de usuários da tabela 'users'"
echo "   ✓ Cálculo real de porcentagens com comparação mensal"
echo "   ✓ Dados financeiros reais com formatação brasileira"
echo "   ✓ URLs funcionais para navegação (acoes_rapidas)"
echo "   ✓ Gráficos com dados dos últimos 30 dias/12 meses"
echo "   ✓ Listas funcionais de atendimentos e processos urgentes"
echo ""
echo "PRÓXIMO PASSO:"
echo "   Execute o frontend e teste o dashboard"
echo "   Agora deve mostrar:"
echo "   • Números reais do banco de dados"
echo "   • Porcentagens funcionais (verde/vermelho)"
echo "   • Valores formatados em R$"
echo ""
echo "Digite 'continuar' para o próximo script (114x - Frontend Dashboard Links)"