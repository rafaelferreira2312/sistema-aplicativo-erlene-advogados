<?php

namespace App\Services;

use App\Models\Financeiro;
use App\Models\PagamentoStripe;
use App\Models\PagamentoMercadoPago;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\Atendimento;
use Carbon\Carbon;

class FinancialService extends BaseService
{
    protected $model = Financeiro::class;

    /**
     * Criar registro financeiro
     */
    public function create(array $data)
    {
        return $this->executeWithLog(function() use ($data) {
            return $this->transaction(function() use ($data) {
                $validatedData = $this->validate($data, [
                    'processo_id' => 'nullable|exists:processos,id',
                    'atendimento_id' => 'nullable|exists:atendimentos,id',
                    'cliente_id' => 'required|exists:clientes,id',
                    'tipo' => 'required|in:honorario,consulta,custas,despesa,receita_extra',
                    'valor' => 'required|numeric|min:0.01',
                    'data_vencimento' => 'required|date',
                    'descricao' => 'required|string|max:255',
                    'gateway' => 'nullable|in:stripe,mercadopago,manual',
                    'unidade_id' => 'required|exists:unidades,id'
                ]);

                $validatedData['status'] = 'pendente';

                // Validar se cliente pertence à unidade
                $this->validateClientUnit($validatedData['cliente_id'], $validatedData['unidade_id']);

                $financeiro = Financeiro::create($validatedData);

                $this->log('info', 'Registro financeiro criado', [
                    'financeiro_id' => $financeiro->id,
                    'cliente_id' => $financeiro->cliente_id,
                    'valor' => $financeiro->valor,
                    'tipo' => $financeiro->tipo
                ]);

                return $financeiro->load(['cliente', 'processo', 'atendimento']);
            });
        }, ['operation' => 'create_financial']);
    }

    /**
     * Validar se cliente pertence à unidade
     */
    private function validateClientUnit(int $clienteId, int $unidadeId)
    {
        $cliente = Cliente::where('id', $clienteId)->where('unidade_id', $unidadeId)->first();
        
        if (!$cliente) {
            throw new \InvalidArgumentException('Cliente não pertence à unidade especificada');
        }

        return true;
    }

    /**
     * Atualizar registro financeiro
     */
    public function update(Financeiro $financeiro, array $data)
    {
        return $this->executeWithLog(function() use ($financeiro, $data) {
            if ($financeiro->status === 'pago') {
                throw new \InvalidArgumentException('Não é possível alterar registro já pago');
            }

            $validatedData = $this->validate($data, [
                'processo_id' => 'nullable|exists:processos,id',
                'atendimento_id' => 'nullable|exists:atendimentos,id',
                'tipo' => 'in:honorario,consulta,custas,despesa,receita_extra',
                'valor' => 'numeric|min:0.01',
                'data_vencimento' => 'date',
                'data_pagamento' => 'nullable|date',
                'status' => 'in:pendente,pago,atrasado,cancelado,parcial',
                'descricao' => 'string|max:255',
                'gateway' => 'nullable|in:stripe,mercadopago,manual'
            ]);

            $oldStatus = $financeiro->status;
            $financeiro->update($validatedData);

            // Log mudança de status
            if (isset($validatedData['status']) && $oldStatus !== $validatedData['status']) {
                $this->logStatusChange($financeiro, $oldStatus, $validatedData['status']);
            }

            $this->log('info', 'Registro financeiro atualizado', [
                'financeiro_id' => $financeiro->id,
                'changes' => array_keys($validatedData)
            ]);

            return $financeiro->load(['cliente', 'processo', 'atendimento']);
        }, ['operation' => 'update_financial', 'financeiro_id' => $financeiro->id]);
    }

    /**
     * Log de mudança de status
     */
    private function logStatusChange(Financeiro $financeiro, string $oldStatus, string $newStatus)
    {
        $this->log('info', 'Status financeiro alterado', [
            'financeiro_id' => $financeiro->id,
            'old_status' => $oldStatus,
            'new_status' => $newStatus,
            'changed_by' => auth()->user()->nome ?? 'Sistema'
        ]);
    }

    /**
     * Marcar como pago manualmente
     */
    public function markAsPaid(Financeiro $financeiro, array $data = [])
    {
        return $this->executeWithLog(function() use ($financeiro, $data) {
            if ($financeiro->status === 'pago') {
                throw new \InvalidArgumentException('Registro já está pago');
            }

            $validatedData = $this->validate($data, [
                'data_pagamento' => 'required|date|before_or_equal:today',
                'observacoes' => 'nullable|string',
                'comprovante_url' => 'nullable|url'
            ]);

            $financeiro->update([
                'status' => 'pago',
                'data_pagamento' => $validatedData['data_pagamento'],
                'gateway' => 'manual',
                'transaction_id' => 'MANUAL_' . time(),
                'gateway_response' => [
                    'observacoes' => $validatedData['observacoes'] ?? null,
                    'comprovante_url' => $validatedData['comprovante_url'] ?? null,
                    'usuario_id' => auth()->id(),
                    'data_confirmacao' => now()
                ]
            ]);

            $this->log('info', 'Pagamento manual confirmado', [
                'financeiro_id' => $financeiro->id,
                'valor' => $financeiro->valor,
                'data_pagamento' => $validatedData['data_pagamento']
            ]);

            return $financeiro;
        }, ['operation' => 'mark_paid', 'financeiro_id' => $financeiro->id]);
    }

    /**
     * Criar cobrança para processo/atendimento
     */
    public function createBilling(array $data)
    {
        return $this->executeWithLog(function() use ($data) {
            return $this->transaction(function() use ($data) {
                $validatedData = $this->validate($data, [
                    'source_type' => 'required|in:processo,atendimento',
                    'source_id' => 'required|integer',
                    'tipo' => 'required|in:honorario,consulta,custas',
                    'valor' => 'required|numeric|min:0.01',
                    'descricao' => 'nullable|string|max:255',
                    'data_vencimento' => 'nullable|date|after:today',
                    'parcelas' => 'nullable|integer|min:1|max:12'
                ]);

                $source = $this->getSourceModel($validatedData['source_type'], $validatedData['source_id']);
                
                $baseData = [
                    'cliente_id' => $source->cliente_id,
                    'unidade_id' => $source->unidade_id,
                    'tipo' => $validatedData['tipo'],
                    'status' => 'pendente'
                ];

                if ($validatedData['source_type'] === 'processo') {
                    $baseData['processo_id'] = $source->id;
                } else {
                    $baseData['atendimento_id'] = $source->id;
                }

                $parcelas = $validatedData['parcelas'] ?? 1;
                $valorParcela = $validatedData['valor'] / $parcelas;
                $dataVencimento = Carbon::parse($validatedData['data_vencimento'] ?? now()->addDays(30));
                
                $financeiros = [];

                for ($i = 1; $i <= $parcelas; $i++) {
                    $descricao = $validatedData['descricao'] ?? $this->generateDescription($validatedData['source_type'], $source);
                    
                    if ($parcelas > 1) {
                        $descricao .= " - Parcela {$i}/{$parcelas}";
                    }

                    $financeiro = Financeiro::create(array_merge($baseData, [
                        'valor' => $valorParcela,
                        'data_vencimento' => $dataVencimento->copy()->addMonths($i - 1),
                        'descricao' => $descricao
                    ]));

                    $financeiros[] = $financeiro;
                }

                $this->log('info', 'Cobrança criada', [
                    'source_type' => $validatedData['source_type'],
                    'source_id' => $validatedData['source_id'],
                    'total_valor' => $validatedData['valor'],
                    'parcelas' => $parcelas,
                    'financeiros_ids' => collect($financeiros)->pluck('id')
                ]);

                return $financeiros;
            });
        }, ['operation' => 'create_billing']);
    }

    /**
     * Obter modelo de origem
     */
    private function getSourceModel(string $type, int $id)
    {
        switch ($type) {
            case 'processo':
                return Processo::findOrFail($id);
            case 'atendimento':
                return Atendimento::findOrFail($id);
            default:
                throw new \InvalidArgumentException('Tipo de origem inválido');
        }
    }

    /**
     * Gerar descrição automática
     */
    private function generateDescription(string $sourceType, $source)
    {
        switch ($sourceType) {
            case 'processo':
                return "Honorários - Processo {$source->numero}";
            case 'atendimento':
                return "Consulta - {$source->assunto}";
            default:
                return 'Serviços jurídicos';
        }
    }

    /**
     * Buscar registros financeiros
     */
    public function search(array $filters)
    {
        $query = Financeiro::with(['cliente', 'processo', 'atendimento']);

        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where(function($q) use ($search) {
                $q->where('descricao', 'like', "%{$search}%")
                  ->orWhereHas('cliente', function($subQ) use ($search) {
                      $subQ->where('nome', 'like', "%{$search}%");
                  });
            });
        }

        if (isset($filters['status'])) {
            if (is_array($filters['status'])) {
                $query->whereIn('status', $filters['status']);
            } else {
                $query->where('status', $filters['status']);
            }
        }

        if (isset($filters['tipo'])) {
            $query->where('tipo', $filters['tipo']);
        }

        if (isset($filters['gateway'])) {
            $query->where('gateway', $filters['gateway']);
        }

        if (isset($filters['cliente_id'])) {
            $query->where('cliente_id', $filters['cliente_id']);
        }

        if (isset($filters['unidade_id'])) {
            $query->where('unidade_id', $filters['unidade_id']);
        }

        if (isset($filters['data_vencimento_inicio']) && isset($filters['data_vencimento_fim'])) {
            $query->whereBetween('data_vencimento', [
                $filters['data_vencimento_inicio'],
                $filters['data_vencimento_fim']
            ]);
        }

        if (isset($filters['vencidos'])) {
            $query->vencidos();
        }

        if (isset($filters['pendentes'])) {
            $query->pendentes();
        }

        if (isset($filters['valor_min'])) {
            $query->where('valor', '>=', $filters['valor_min']);
        }

        if (isset($filters['valor_max'])) {
            $query->where('valor', '<=', $filters['valor_max']);
        }

        return $query->orderBy('data_vencimento', 'desc');
    }

    /**
     * Dashboard financeiro
     */
    public function getDashboard(array $filters = [])
    {
        $cacheKey = 'financial_dashboard_' . md5(serialize($filters));
        
        return $this->cache($cacheKey, function() use ($filters) {
            $query = Financeiro::query();
            
            if (isset($filters['unidade_id'])) {
                $query->where('unidade_id', $filters['unidade_id']);
            }

            $mesAtual = now()->month;
            $anoAtual = now()->year;

            // Estatísticas gerais
            $stats = [
                'receita_ano' => $query->where('status', 'pago')
                                     ->whereYear('data_pagamento', $anoAtual)
                                     ->sum('valor'),
                
                'receita_mes_atual' => $query->where('status', 'pago')
                                           ->whereMonth('data_pagamento', $mesAtual)
                                           ->whereYear('data_pagamento', $anoAtual)
                                           ->sum('valor'),
                
                'pendente_total' => $query->pendentes()->sum('valor'),
                
                'vencido_total' => $query->vencidos()->sum('valor'),
                
                'total_clientes_devendo' => $query->pendentes()
                                                 ->distinct('cliente_id')
                                                 ->count('cliente_id')
            ];

            // Receitas por mês (últimos 12 meses)
            $receitasPorMes = [];
            for ($i = 11; $i >= 0; $i--) {
                $mes = now()->subMonths($i);
                $receita = Financeiro::where('status', 'pago')
                                    ->whereYear('data_pagamento', $mes->year)
                                    ->whereMonth('data_pagamento', $mes->month);
                
                if (isset($filters['unidade_id'])) {
                    $receita->where('unidade_id', $filters['unidade_id']);
                }
                
                $valor = $receita->sum('valor');
                
                $receitasPorMes[] = [
                    'mes' => $mes->format('Y-m'),
                    'mes_nome' => $mes->format('M/Y'),
                    'receita' => (float) $valor
                ];
            }

            // Receitas por gateway
            $receitasPorGateway = Financeiro::where('status', 'pago')
                                          ->whereMonth('data_pagamento', $mesAtual)
                                          ->whereYear('data_pagamento', $anoAtual);
            
            if (isset($filters['unidade_id'])) {
                $receitasPorGateway->where('unidade_id', $filters['unidade_id']);
            }
            
            $receitasPorGateway = $receitasPorGateway->selectRaw('gateway, SUM(valor) as total')
                                                   ->groupBy('gateway')
                                                   ->get();

            // Receitas por tipo
            $receitasPorTipo = Financeiro::where('status', 'pago')
                                       ->whereYear('data_pagamento', $anoAtual);
            
            if (isset($filters['unidade_id'])) {
                $receitasPorTipo->where('unidade_id', $filters['unidade_id']);
            }
            
            $receitasPorTipo = $receitasPorTipo->selectRaw('tipo, SUM(valor) as total')
                                             ->groupBy('tipo')
                                             ->get();

            return [
                'stats' => $stats,
                'graficos' => [
                    'receitas_mes' => $receitasPorMes,
                    'receitas_gateway' => $receitasPorGateway,
                    'receitas_tipo' => $receitasPorTipo
                ]
            ];
        }, 1800); // Cache por 30 minutos
    }

    /**
     * Relatório de inadimplência
     */
    public function getInadimplenciaReport(array $filters = [])
    {
        $query = Financeiro::with(['cliente'])
                          ->where('status', 'pendente')
                          ->where('data_vencimento', '<', now());

        if (isset($filters['unidade_id'])) {
            $query->where('unidade_id', $filters['unidade_id']);
        }

        if (isset($filters['dias_vencido'])) {
            $query->where('data_vencimento', '<=', now()->subDays($filters['dias_vencido']));
        }

        $vencidos = $query->get();

        $relatorio = [
            'resumo' => [
                'total_registros' => $vencidos->count(),
                'valor_total' => $vencidos->sum('valor'),
                'clientes_unicos' => $vencidos->unique('cliente_id')->count()
            ],
            'por_tempo_vencimento' => [
                'ate_30_dias' => $vencidos->filter(function($item) {
                    return $item->data_vencimento >= now()->subDays(30);
                })->sum('valor'),
                'de_31_a_60_dias' => $vencidos->filter(function($item) {
                    return $item->data_vencimento >= now()->subDays(60) && 
                           $item->data_vencimento < now()->subDays(30);
                })->sum('valor'),
                'acima_60_dias' => $vencidos->filter(function($item) {
                    return $item->data_vencimento < now()->subDays(60);
                })->sum('valor')
            ],
            'por_cliente' => $vencidos->groupBy('cliente.nome')
                                   ->map(function($items, $cliente) {
                                       return [
                                           'cliente' => $cliente,
                                           'registros' => $items->count(),
                                           'valor_total' => $items->sum('valor'),
                                           'mais_antigo' => $items->min('data_vencimento')
                                       ];
                                   })
                                   ->sortByDesc('valor_total')
                                   ->values()
        ];

        $this->log('info', 'Relatório de inadimplência gerado', [
            'total_vencidos' => $relatorio['resumo']['total_registros'],
            'valor_total' => $relatorio['resumo']['valor_total']
        ]);

        return $relatorio;
    }

    /**
     * Atualizar registros vencidos
     */
    public function updateOverdueRecords()
    {
        return $this->executeWithLog(function() {
            $updated = Financeiro::where('status', 'pendente')
                                ->where('data_vencimento', '<', now())
                                ->update(['status' => 'atrasado']);

            $this->log('info', 'Registros vencidos atualizados', [
                'total_updated' => $updated
            ]);

            return $updated;
        }, ['operation' => 'update_overdue']);
    }

    /**
     * Excluir registro financeiro
     */
    public function delete(Financeiro $financeiro)
    {
        return $this->executeWithLog(function() use ($financeiro) {
            if ($financeiro->status === 'pago') {
                throw new \InvalidArgumentException('Não é possível excluir registro já pago');
            }

            // Verificar se tem pagamentos associados
            if ($financeiro->pagamentosStripe()->count() > 0 || 
                $financeiro->pagamentosMercadoPago()->count() > 0) {
                throw new \InvalidArgumentException('Não é possível excluir registro com pagamentos associados');
            }

            $financeiro->delete();

            $this->log('info', 'Registro financeiro excluído', [
                'financeiro_id' => $financeiro->id,
                'valor' => $financeiro->valor
            ]);

            return true;
        }, ['operation' => 'delete_financial', 'financeiro_id' => $financeiro->id]);
    }

    /**
     * Estatísticas rápidas
     */
    public function getQuickStats(int $unidadeId = null)
    {
        $cacheKey = 'financial_quick_stats_' . ($unidadeId ?? 'all');
        
        return $this->cache($cacheKey, function() use ($unidadeId) {
            $query = Financeiro::query();
            
            if ($unidadeId) {
                $query->where('unidade_id', $unidadeId);
            }

            return [
                'pendente_valor' => $query->pendentes()->sum('valor'),
                'pendente_count' => $query->pendentes()->count(),
                'vencido_valor' => $query->vencidos()->sum('valor'),
                'vencido_count' => $query->vencidos()->count(),
                'pago_mes_valor' => $query->where('status', 'pago')
                                         ->whereMonth('data_pagamento', now()->month)
                                         ->sum('valor'),
                'receita_ano' => $query->where('status', 'pago')
                                      ->whereYear('data_pagamento', now()->year)
                                      ->sum('valor')
            ];
        }, 600); // Cache por 10 minutos
    }
}
