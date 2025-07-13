<?php

namespace App\Services;

use App\Models\Atendimento;
use App\Models\Cliente;
use App\Models\User;
use App\Models\Agenda;
use Carbon\Carbon;

class AppointmentService extends BaseService
{
    protected $model = Atendimento::class;

    /**
     * Criar atendimento
     */
    public function create(array $data)
    {
        return $this->executeWithLog(function() use ($data) {
            return $this->transaction(function() use ($data) {
                $validatedData = $this->validate($data, [
                    'cliente_id' => 'required|exists:clientes,id',
                    'advogado_id' => 'required|exists:users,id',
                    'data_hora' => 'required|date|after:now',
                    'tipo' => 'required|in:presencial,online,telefone',
                    'assunto' => 'required|string|max:255',
                    'descricao' => 'required|string',
                    'duracao' => 'nullable|integer|min:15|max:480',
                    'valor' => 'nullable|numeric|min:0',
                    'proximos_passos' => 'nullable|string',
                    'unidade_id' => 'required|exists:unidades,id',
                    'processos' => 'nullable|array',
                    'processos.*' => 'exists:processos,id'
                ]);

                // Verificar disponibilidade do advogado
                $this->checkAvailability(
                    $validatedData['advogado_id'], 
                    $validatedData['data_hora'], 
                    $validatedData['duracao'] ?? 60
                );

                $processos = $validatedData['processos'] ?? [];
                unset($validatedData['processos']);

                $validatedData['status'] = 'agendado';
                $validatedData['duracao'] = $validatedData['duracao'] ?? 60;

                $atendimento = Atendimento::create($validatedData);

                // Vincular processos se fornecidos
                if (!empty($processos)) {
                    $atendimento->processos()->sync($processos);
                }

                // Criar evento na agenda
                $this->createCalendarEvent($atendimento);

                $this->log('info', 'Atendimento criado com sucesso', [
                    'atendimento_id' => $atendimento->id,
                    'cliente_id' => $atendimento->cliente_id,
                    'advogado_id' => $atendimento->advogado_id,
                    'data_hora' => $atendimento->data_hora
                ]);

                return $atendimento->load(['cliente', 'advogado', 'processos']);
            });
        }, ['operation' => 'create_appointment']);
    }

    /**
     * Verificar disponibilidade do advogado
     */
    private function checkAvailability(int $advogadoId, string $dataHora, int $duracao)
    {
        $inicio = Carbon::parse($dataHora);
        $fim = $inicio->copy()->addMinutes($duracao);

        // Verificar conflitos com outros atendimentos
        $conflitos = Atendimento::where('advogado_id', $advogadoId)
                               ->where('status', '!=', 'cancelado')
                               ->where(function($query) use ($inicio, $fim) {
                                   $query->whereBetween('data_hora', [$inicio, $fim])
                                         ->orWhere(function($q) use ($inicio, $fim) {
                                             $q->where('data_hora', '<=', $inicio)
                                               ->whereRaw('DATE_ADD(data_hora, INTERVAL duracao MINUTE) > ?', [$inicio]);
                                         });
                               })
                               ->exists();

        if ($conflitos) {
            throw new \InvalidArgumentException('Horário não disponível para o advogado');
        }

        // Verificar horário comercial (8h às 18h, seg-sex)
        if ($inicio->isWeekend()) {
            throw new \InvalidArgumentException('Atendimentos não podem ser agendados em finais de semana');
        }

        if ($inicio->hour < 8 || $inicio->hour >= 18) {
            throw new \InvalidArgumentException('Atendimentos devem ser agendados entre 8h e 18h');
        }

        return true;
    }

    /**
     * Criar evento na agenda
     */
    private function createCalendarEvent(Atendimento $atendimento)
    {
        $dataFim = Carbon::parse($atendimento->data_hora)->addMinutes($atendimento->duracao);

        Agenda::create([
            'titulo' => 'Atendimento - ' . $atendimento->assunto,
            'descricao' => "Cliente: {$atendimento->cliente->nome}\nTipo: {$atendimento->tipo}\n{$atendimento->descricao}",
            'data_inicio' => $atendimento->data_hora,
            'data_fim' => $dataFim,
            'tipo' => 'consulta',
            'cliente_id' => $atendimento->cliente_id,
            'atendimento_id' => $atendimento->id,
            'usuario_id' => $atendimento->advogado_id,
            'lembrete' => 30, // 30 minutos antes
            'cor' => $this->getTipoColor($atendimento->tipo)
        ]);
    }

    /**
     * Obter cor por tipo de atendimento
     */
    private function getTipoColor(string $tipo)
    {
        $cores = [
            'presencial' => '#3B82F6', // Azul
            'online' => '#10B981',      // Verde
            'telefone' => '#F59E0B'     // Amarelo
        ];

        return $cores[$tipo] ?? '#6B7280';
    }

    /**
     * Atualizar atendimento
     */
    public function update(Atendimento $atendimento, array $data)
    {
        return $this->executeWithLog(function() use ($atendimento, $data) {
            $validatedData = $this->validate($data, [
                'cliente_id' => 'exists:clientes,id',
                'advogado_id' => 'exists:users,id',
                'data_hora' => 'date',
                'tipo' => 'in:presencial,online,telefone',
                'assunto' => 'string|max:255',
                'descricao' => 'string',
                'status' => 'in:agendado,em_andamento,concluido,cancelado',
                'duracao' => 'nullable|integer|min:15|max:480',
                'valor' => 'nullable|numeric|min:0',
                'proximos_passos' => 'nullable|string',
                'processos' => 'nullable|array',
                'processos.*' => 'exists:processos,id'
            ]);

            // Se mudou data/hora ou advogado, verificar disponibilidade
            if (isset($validatedData['data_hora']) || isset($validatedData['advogado_id'])) {
                $advogadoId = $validatedData['advogado_id'] ?? $atendimento->advogado_id;
                $dataHora = $validatedData['data_hora'] ?? $atendimento->data_hora;
                $duracao = $validatedData['duracao'] ?? $atendimento->duracao;

                $this->checkAvailabilityForUpdate($atendimento->id, $advogadoId, $dataHora, $duracao);
            }

            $processos = $validatedData['processos'] ?? null;
            unset($validatedData['processos']);

            $oldStatus = $atendimento->status;
            $atendimento->update($validatedData);

            // Atualizar processos vinculados
            if ($processos !== null) {
                $atendimento->processos()->sync($processos);
            }

            // Atualizar agenda se necessário
            if (isset($validatedData['data_hora']) || isset($validatedData['assunto'])) {
                $this->updateCalendarEvent($atendimento);
            }

            // Log de mudança de status
            if (isset($validatedData['status']) && $oldStatus !== $validatedData['status']) {
                $this->logStatusChange($atendimento, $oldStatus, $validatedData['status']);
            }

            $this->log('info', 'Atendimento atualizado', [
                'atendimento_id' => $atendimento->id,
                'changes' => array_keys($validatedData)
            ]);

            return $atendimento->load(['cliente', 'advogado', 'processos']);
        }, ['operation' => 'update_appointment', 'atendimento_id' => $atendimento->id]);
    }

    /**
     * Verificar disponibilidade para atualização
     */
    private function checkAvailabilityForUpdate(int $atendimentoId, int $advogadoId, string $dataHora, int $duracao)
    {
        $inicio = Carbon::parse($dataHora);
        $fim = $inicio->copy()->addMinutes($duracao);

        $conflitos = Atendimento::where('advogado_id', $advogadoId)
                               ->where('id', '!=', $atendimentoId)
                               ->where('status', '!=', 'cancelado')
                               ->where(function($query) use ($inicio, $fim) {
                                   $query->whereBetween('data_hora', [$inicio, $fim])
                                         ->orWhere(function($q) use ($inicio, $fim) {
                                             $q->where('data_hora', '<=', $inicio)
                                               ->whereRaw('DATE_ADD(data_hora, INTERVAL duracao MINUTE) > ?', [$inicio]);
                                         });
                               })
                               ->exists();

        if ($conflitos) {
            throw new \InvalidArgumentException('Horário não disponível para o advogado');
        }

        return true;
    }

    /**
     * Atualizar evento na agenda
     */
    private function updateCalendarEvent(Atendimento $atendimento)
    {
        $agenda = Agenda::where('atendimento_id', $atendimento->id)->first();
        
        if ($agenda) {
            $dataFim = Carbon::parse($atendimento->data_hora)->addMinutes($atendimento->duracao);
            
            $agenda->update([
                'titulo' => 'Atendimento - ' . $atendimento->assunto,
                'descricao' => "Cliente: {$atendimento->cliente->nome}\nTipo: {$atendimento->tipo}\n{$atendimento->descricao}",
                'data_inicio' => $atendimento->data_hora,
                'data_fim' => $dataFim,
                'cor' => $this->getTipoColor($atendimento->tipo)
            ]);
        }
    }

    /**
     * Log de mudança de status
     */
    private function logStatusChange(Atendimento $atendimento, string $oldStatus, string $newStatus)
    {
        $this->log('info', 'Status do atendimento alterado', [
            'atendimento_id' => $atendimento->id,
            'old_status' => $oldStatus,
            'new_status' => $newStatus,
            'changed_by' => auth()->user()->nome ?? 'Sistema'
        ]);
    }

    /**
     * Iniciar atendimento
     */
    public function start(Atendimento $atendimento)
    {
        return $this->executeWithLog(function() use ($atendimento) {
            if ($atendimento->status !== 'agendado') {
                throw new \InvalidArgumentException('Apenas atendimentos agendados podem ser iniciados');
            }

            $atendimento->update(['status' => 'em_andamento']);

            $this->log('info', 'Atendimento iniciado', [
                'atendimento_id' => $atendimento->id,
                'started_at' => now()
            ]);

            return $atendimento;
        }, ['operation' => 'start_appointment', 'atendimento_id' => $atendimento->id]);
    }

    /**
     * Finalizar atendimento
     */
    public function finish(Atendimento $atendimento, array $data = [])
    {
        return $this->executeWithLog(function() use ($atendimento, $data) {
            if ($atendimento->status !== 'em_andamento') {
                throw new \InvalidArgumentException('Apenas atendimentos em andamento podem ser finalizados');
            }

            $validatedData = $this->validate($data, [
                'proximos_passos' => 'nullable|string',
                'observacoes_finais' => 'nullable|string',
                'valor' => 'nullable|numeric|min:0'
            ]);

            $updateData = [
                'status' => 'concluido',
                'proximos_passos' => $validatedData['proximos_passos'] ?? $atendimento->proximos_passos
            ];

            if (isset($validatedData['valor'])) {
                $updateData['valor'] = $validatedData['valor'];
            }

            if (isset($validatedData['observacoes_finais'])) {
                $observacoes = $atendimento->observacoes ?? '';
                $updateData['observacoes'] = $observacoes . "\n\nObservações finais: " . $validatedData['observacoes_finais'];
            }

            $atendimento->update($updateData);

            // Gerar cobrança automaticamente se tem valor
            if ($atendimento->valor > 0) {
                $this->generateBilling($atendimento);
            }

            $this->log('info', 'Atendimento finalizado', [
                'atendimento_id' => $atendimento->id,
                'finished_at' => now(),
                'valor' => $atendimento->valor
            ]);

            return $atendimento;
        }, ['operation' => 'finish_appointment', 'atendimento_id' => $atendimento->id]);
    }

    /**
     * Gerar cobrança para o atendimento
     */
    private function generateBilling(Atendimento $atendimento)
    {
        \App\Models\Financeiro::create([
            'atendimento_id' => $atendimento->id,
            'cliente_id' => $atendimento->cliente_id,
            'tipo' => 'consulta',
            'valor' => $atendimento->valor,
            'data_vencimento' => now()->addDays(30),
            'status' => 'pendente',
            'descricao' => "Atendimento - {$atendimento->assunto}",
            'unidade_id' => $atendimento->unidade_id
        ]);
    }

    /**
     * Cancelar atendimento
     */
    public function cancel(Atendimento $atendimento, string $motivo = null)
    {
        return $this->executeWithLog(function() use ($atendimento, $motivo) {
            if (in_array($atendimento->status, ['concluido', 'cancelado'])) {
                throw new \InvalidArgumentException('Atendimento não pode ser cancelado');
            }

            $atendimento->update([
                'status' => 'cancelado',
                'observacoes' => ($atendimento->observacoes ?? '') . "\n\nCancelado: " . ($motivo ?? 'Sem motivo especificado')
            ]);

            // Remover da agenda
            Agenda::where('atendimento_id', $atendimento->id)->delete();

            $this->log('info', 'Atendimento cancelado', [
                'atendimento_id' => $atendimento->id,
                'motivo' => $motivo,
                'cancelled_at' => now()
            ]);

            return $atendimento;
        }, ['operation' => 'cancel_appointment', 'atendimento_id' => $atendimento->id]);
    }

    /**
     * Obter agenda do advogado
     */
    public function getAdvogadoSchedule(int $advogadoId, string $dataInicio, string $dataFim)
    {
        $agenda = Atendimento::where('advogado_id', $advogadoId)
                            ->whereBetween('data_hora', [$dataInicio, $dataFim])
                            ->where('status', '!=', 'cancelado')
                            ->with(['cliente'])
                            ->orderBy('data_hora')
                            ->get();

        return $agenda->map(function($atendimento) {
            $inicio = Carbon::parse($atendimento->data_hora);
            $fim = $inicio->copy()->addMinutes($atendimento->duracao);

            return [
                'id' => $atendimento->id,
                'title' => $atendimento->assunto,
                'start' => $inicio->toISOString(),
                'end' => $fim->toISOString(),
                'cliente' => $atendimento->cliente->nome,
                'tipo' => $atendimento->tipo,
                'status' => $atendimento->status,
                'color' => $this->getTipoColor($atendimento->tipo)
            ];
        });
    }

    /**
     * Buscar atendimentos com filtros
     */
    public function search(array $filters)
    {
        $query = Atendimento::with(['cliente', 'advogado', 'processos']);

        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where(function($q) use ($search) {
                $q->where('assunto', 'like', "%{$search}%")
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

        if (isset($filters['advogado_id'])) {
            $query->where('advogado_id', $filters['advogado_id']);
        }

        if (isset($filters['cliente_id'])) {
            $query->where('cliente_id', $filters['cliente_id']);
        }

        if (isset($filters['unidade_id'])) {
            $query->where('unidade_id', $filters['unidade_id']);
        }

        if (isset($filters['data_inicio']) && isset($filters['data_fim'])) {
            $query->whereBetween('data_hora', [$filters['data_inicio'], $filters['data_fim']]);
        }

        if (isset($filters['hoje'])) {
            $query->whereDate('data_hora', today());
        }

        if (isset($filters['semana'])) {
            $query->whereBetween('data_hora', [now()->startOfWeek(), now()->endOfWeek()]);
        }

        return $query->orderBy('data_hora', 'desc');
    }

    /**
     * Estatísticas de atendimentos
     */
    public function getStats(array $filters = [])
    {
        $cacheKey = 'appointment_stats_' . md5(serialize($filters));
        
        return $this->cache($cacheKey, function() use ($filters) {
            $query = Atendimento::query();

            if (isset($filters['unidade_id'])) {
                $query->where('unidade_id', $filters['unidade_id']);
            }

            if (isset($filters['advogado_id'])) {
                $query->where('advogado_id', $filters['advogado_id']);
            }

            if (isset($filters['data_inicio']) && isset($filters['data_fim'])) {
                $query->whereBetween('data_hora', [$filters['data_inicio'], $filters['data_fim']]);
            }

            $atendimentos = $query->get();

            return [
                'total' => $atendimentos->count(),
                'por_status' => $atendimentos->groupBy('status')->map->count(),
                'por_tipo' => $atendimentos->groupBy('tipo')->map->count(),
                'valor_total' => $atendimentos->where('status', 'concluido')->sum('valor'),
                'duracao_media' => $atendimentos->avg('duracao'),
                'hoje' => $atendimentos->where('data_hora', '>=', today())->where('data_hora', '<', tomorrow())->count(),
                'esta_semana' => $atendimentos->whereBetween('data_hora', [now()->startOfWeek(), now()->endOfWeek()])->count()
            ];
        }, 600); // Cache por 10 minutos
    }
}
