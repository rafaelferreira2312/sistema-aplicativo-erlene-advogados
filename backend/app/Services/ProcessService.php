<?php

namespace App\Services;

use App\Models\Processo;
use App\Models\Movimentacao;
use App\Models\Cliente;
use Carbon\Carbon;

class ProcessService extends BaseService
{
    protected $model = Processo::class;

    /**
     * Criar processo
     */
    public function create(array $data)
    {
        return $this->executeWithLog(function() use ($data) {
            return $this->transaction(function() use ($data) {
                $validatedData = $this->validate($data, [
                    'numero' => 'required|string|unique:processos,numero|regex:/^\d{7}-\d{2}\.\d{4}\.\d{1}\.\d{2}\.\d{4}$/',
                    'tribunal' => 'required|string',
                    'vara' => 'nullable|string',
                    'cliente_id' => 'required|exists:clientes,id',
                    'tipo_acao' => 'required|string',
                    'status' => 'in:distribuido,em_andamento,suspenso,arquivado,finalizado',
                    'valor_causa' => 'nullable|numeric|min:0',
                    'data_distribuicao' => 'required|date',
                    'advogado_id' => 'required|exists:users,id',
                    'unidade_id' => 'required|exists:unidades,id',
                    'proximo_prazo' => 'nullable|date|after:today',
                    'observacoes' => 'nullable|string',
                    'prioridade' => 'in:baixa,media,alta,urgente'
                ]);

                $validatedData['status'] = $validatedData['status'] ?? 'distribuido';
                $validatedData['prioridade'] = $validatedData['prioridade'] ?? 'media';

                $processo = Processo::create($validatedData);

                // Criar movimentação inicial
                $this->createMovement($processo, [
                    'data' => $validatedData['data_distribuicao'],
                    'descricao' => 'Processo distribuído - Cadastro inicial no sistema',
                    'tipo' => 'manual'
                ]);

                $this->log('info', 'Processo criado com sucesso', [
                    'processo_id' => $processo->id,
                    'numero' => $processo->numero,
                    'cliente_id' => $processo->cliente_id
                ]);

                return $processo->load(['cliente', 'advogado', 'unidade']);
            });
        }, ['operation' => 'create_process']);
    }

    /**
     * Atualizar processo
     */
    public function update(Processo $processo, array $data)
    {
        return $this->executeWithLog(function() use ($processo, $data) {
            $validatedData = $this->validate($data, [
                'numero' => 'string|unique:processos,numero,' . $processo->id . '|regex:/^\d{7}-\d{2}\.\d{4}\.\d{1}\.\d{2}\.\d{4}$/',
                'tribunal' => 'string',
                'vara' => 'nullable|string',
                'tipo_acao' => 'string',
                'status' => 'in:distribuido,em_andamento,suspenso,arquivado,finalizado',
                'valor_causa' => 'nullable|numeric|min:0',
                'data_distribuicao' => 'date',
                'advogado_id' => 'exists:users,id',
                'proximo_prazo' => 'nullable|date',
                'observacoes' => 'nullable|string',
                'prioridade' => 'in:baixa,media,alta,urgente'
            ]);

            $oldData = $processo->toArray();
            $processo->update($validatedData);

            // Log de mudanças importantes
            $this->logProcessChanges($processo, $oldData, $validatedData);

            $this->log('info', 'Processo atualizado', [
                'processo_id' => $processo->id,
                'changes' => array_keys($validatedData)
            ]);

            return $processo->load(['cliente', 'advogado', 'unidade']);
        }, ['operation' => 'update_process', 'processo_id' => $processo->id]);
    }

    /**
     * Criar movimentação
     */
    public function createMovement(Processo $processo, array $data)
    {
        $validatedData = $this->validate($data, [
            'data' => 'required|date',
            'descricao' => 'required|string',
            'tipo' => 'required|in:automatica,manual,tribunal',
            'documento_url' => 'nullable|url',
            'metadata' => 'nullable|array'
        ]);

        $validatedData['processo_id'] = $processo->id;

        $movimentacao = Movimentacao::create($validatedData);

        $this->log('info', 'Movimentação criada', [
            'processo_id' => $processo->id,
            'movimentacao_id' => $movimentacao->id,
            'tipo' => $validatedData['tipo']
        ]);

        return $movimentacao;
    }

    /**
     * Log de mudanças importantes do processo
     */
    private function logProcessChanges(Processo $processo, array $oldData, array $newData)
    {
        $importantChanges = ['status', 'prioridade', 'advogado_id', 'proximo_prazo'];
        
        foreach ($importantChanges as $field) {
            if (isset($newData[$field]) && $oldData[$field] !== $newData[$field]) {
                $description = $this->getChangeDescription($field, $oldData[$field], $newData[$field]);
                
                $this->createMovement($processo, [
                    'data' => now(),
                    'descricao' => $description,
                    'tipo' => 'manual',
                    'metadata' => [
                        'field' => $field,
                        'old_value' => $oldData[$field],
                        'new_value' => $newData[$field],
                        'changed_by' => auth()->user()->nome ?? 'Sistema'
                    ]
                ]);
            }
        }
    }

    /**
     * Gerar descrição das mudanças
     */
    private function getChangeDescription($field, $oldValue, $newValue)
    {
        switch ($field) {
            case 'status':
                return "Status alterado de '{$oldValue}' para '{$newValue}'";
            case 'prioridade':
                return "Prioridade alterada de '{$oldValue}' para '{$newValue}'";
            case 'advogado_id':
                $oldAdvogado = \App\Models\User::find($oldValue);
                $newAdvogado = \App\Models\User::find($newValue);
                return "Advogado responsável alterado de '{$oldAdvogado->nome}' para '{$newAdvogado->nome}'";
            case 'proximo_prazo':
                $oldDate = $oldValue ? Carbon::parse($oldValue)->format('d/m/Y') : 'Não definido';
                $newDate = $newValue ? Carbon::parse($newValue)->format('d/m/Y') : 'Removido';
                return "Próximo prazo alterado de '{$oldDate}' para '{$newDate}'";
            default:
                return "Campo {$field} alterado";
        }
    }

    /**
     * Obter processos com prazo vencendo
     */
    public function getProcessosVencendo(int $dias = 7, int $unidadeId = null)
    {
        $query = Processo::with(['cliente', 'advogado'])
                        ->comPrazoVencendo($dias);

        if ($unidadeId) {
            $query->where('unidade_id', $unidadeId);
        }

        $processos = $query->orderBy('proximo_prazo')->get();

        foreach ($processos as $processo) {
            $diasRestantes = now()->diffInDays($processo->proximo_prazo, false);
            
            $this->log('warning', 'Processo com prazo vencendo', [
                'processo_id' => $processo->id,
                'numero' => $processo->numero,
                'prazo' => $processo->proximo_prazo,
                'dias_restantes' => $diasRestantes
            ]);
        }

        return $processos;
    }

    /**
     * Relatório de processos
     */
    public function generateReport(array $filters)
    {
        $cacheKey = 'process_report_' . md5(serialize($filters));
        
        return $this->cache($cacheKey, function() use ($filters) {
            $query = Processo::with(['cliente', 'advogado', 'unidade']);

            // Aplicar filtros
            if (isset($filters['unidade_id'])) {
                $query->where('unidade_id', $filters['unidade_id']);
            }

            if (isset($filters['advogado_id'])) {
                $query->where('advogado_id', $filters['advogado_id']);
            }

            if (isset($filters['status'])) {
                $query->where('status', $filters['status']);
            }

            if (isset($filters['data_inicio']) && isset($filters['data_fim'])) {
                $query->whereBetween('created_at', [$filters['data_inicio'], $filters['data_fim']]);
            }

            $processos = $query->get();

            $relatorio = [
                'resumo' => [
                    'total_processos' => $processos->count(),
                    'valor_total_causa' => $processos->sum('valor_causa'),
                    'media_valor_causa' => $processos->avg('valor_causa')
                ],
                'por_status' => $processos->groupBy('status')->map->count(),
                'por_prioridade' => $processos->groupBy('prioridade')->map->count(),
                'por_advogado' => $processos->groupBy('advogado.nome')->map->count(),
                'por_tribunal' => $processos->groupBy('tribunal')->map->count(),
                'distribuicao_mensal' => $this->getDistribuicaoMensal($processos),
                'prazos_vencendo' => $processos->filter(function($processo) {
                    return $processo->proximo_prazo && $processo->proximo_prazo <= now()->addDays(7);
                })->count(),
                'processos_sem_movimento' => $this->getProcessosSemMovimento($processos)
            ];

            $this->log('info', 'Relatório de processos gerado', [
                'filtros' => $filters,
                'total_processos' => $relatorio['resumo']['total_processos']
            ]);

            return $relatorio;
        }, 1800); // Cache por 30 minutos
    }

    /**
     * Obter distribuição mensal de processos
     */
    private function getDistribuicaoMensal($processos)
    {
        $distribuicao = [];
        $meses = [];
        
        // Últimos 12 meses
        for ($i = 11; $i >= 0; $i--) {
            $mes = now()->subMonths($i);
            $meses[$mes->format('Y-m')] = $mes->format('M/Y');
        }

        foreach ($meses as $key => $label) {
            $count = $processos->filter(function($processo) use ($key) {
                return $processo->created_at->format('Y-m') === $key;
            })->count();
            
            $distribuicao[] = [
                'mes' => $key,
                'label' => $label,
                'count' => $count
            ];
        }

        return $distribuicao;
    }

    /**
     * Processos sem movimentação recente
     */
    private function getProcessosSemMovimento($processos)
    {
        return $processos->filter(function($processo) {
            $ultimaMovimentacao = $processo->movimentacoes()
                                         ->orderBy('data', 'desc')
                                         ->first();
            
            if (!$ultimaMovimentacao) {
                return true;
            }
            
            return $ultimaMovimentacao->data < now()->subDays(30);
        })->count();
    }

    /**
     * Buscar processos com filtros avançados
     */
    public function search(array $filters)
    {
        $query = Processo::with(['cliente', 'advogado', 'unidade']);

        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where(function($q) use ($search) {
                $q->where('numero', 'like', "%{$search}%")
                  ->orWhere('tipo_acao', 'like', "%{$search}%")
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

        if (isset($filters['prioridade'])) {
            $query->where('prioridade', $filters['prioridade']);
        }

        if (isset($filters['advogado_id'])) {
            $query->where('advogado_id', $filters['advogado_id']);
        }

        if (isset($filters['cliente_id'])) {
            $query->where('cliente_id', $filters['cliente_id']);
        }

        if (isset($filters['unidade_id'])) {
            $query->where('unidade_id', $filters['unidade_id']);
        }

        if (isset($filters['tribunal'])) {
            $query->where('tribunal', 'like', "%{$filters['tribunal']}%");
        }

        if (isset($filters['prazo_vencendo'])) {
            $query->comPrazoVencendo($filters['prazo_vencendo']);
        }

        if (isset($filters['data_distribuicao_inicio']) && isset($filters['data_distribuicao_fim'])) {
            $query->whereBetween('data_distribuicao', [
                $filters['data_distribuicao_inicio'],
                $filters['data_distribuicao_fim']
            ]);
        }

        if (isset($filters['valor_causa_min'])) {
            $query->where('valor_causa', '>=', $filters['valor_causa_min']);
        }

        if (isset($filters['valor_causa_max'])) {
            $query->where('valor_causa', '<=', $filters['valor_causa_max']);
        }

        return $query->orderBy('created_at', 'desc');
    }

    /**
     * Obter estatísticas rápidas
     */
    public function getQuickStats(int $unidadeId = null)
    {
        $cacheKey = 'process_quick_stats_' . ($unidadeId ?? 'all');
        
        return $this->cache($cacheKey, function() use ($unidadeId) {
            $query = Processo::query();
            
            if ($unidadeId) {
                $query->where('unidade_id', $unidadeId);
            }

            return [
                'total' => $query->count(),
                'ativos' => $query->ativos()->count(),
                'vencendo_7_dias' => $query->comPrazoVencendo(7)->count(),
                'urgentes' => $query->where('prioridade', 'urgente')->count(),
                'sem_movimento_30_dias' => $query->whereDoesntHave('movimentacoes', function($q) {
                    $q->where('data', '>=', now()->subDays(30));
                })->count()
            ];
        }, 600); // Cache por 10 minutos
    }

    /**
     * Excluir processo
     */
    public function delete(Processo $processo)
    {
        return $this->executeWithLog(function() use ($processo) {
            // Verificar se pode ser excluído
            if ($processo->movimentacoes()->count() > 5) {
                throw new \Exception('Não é possível excluir processo com muitas movimentações');
            }

            if ($processo->financeiro()->where('status', 'pago')->count() > 0) {
                throw new \Exception('Não é possível excluir processo com pagamentos realizados');
            }

            $processo->delete();

            $this->log('info', 'Processo excluído', [
                'processo_id' => $processo->id,
                'numero' => $processo->numero
            ]);

            return true;
        }, ['operation' => 'delete_process', 'processo_id' => $processo->id]);
    }
}
