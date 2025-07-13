<?php

namespace App\Services;

use App\Models\Notificacao;
use App\Models\User;
use App\Models\Cliente;
use App\Models\Processo;
use App\Models\Atendimento;
use App\Models\Financeiro;
use App\Services\Integration\EmailService;

class NotificationService extends BaseService
{
    protected $model = Notificacao::class;
    protected $emailService;

    public function __construct(EmailService $emailService)
    {
        $this->emailService = $emailService;
    }

    /**
     * Criar notificação
     */
    public function create(array $data)
    {
        return $this->executeWithLog(function() use ($data) {
            return $this->transaction(function() use ($data) {
                $validatedData = $this->validate($data, [
                    'usuario_id' => 'nullable|exists:users,id',
                    'cliente_id' => 'nullable|exists:clientes,id',
                    'titulo' => 'required|string|max:255',
                    'mensagem' => 'required|string',
                    'tipo' => 'required|in:prazo_vencendo,novo_processo,movimentacao,pagamento,documento,mensagem,sistema',
                    'canal' => 'required|in:sistema,email,sms,push,whatsapp',
                    'dados_extras' => 'nullable|array',
                    'icone' => 'nullable|string',
                    'cor' => 'nullable|string',
                    'auto_send' => 'boolean'
                ]);

                $validatedData['lida'] = false;
                $validatedData['enviada'] = false;

                $notificacao = Notificacao::create($validatedData);

                // Enviar automaticamente se solicitado
                if ($validatedData['auto_send'] ?? true) {
                    $this->send($notificacao);
                }

                $this->log('info', 'Notificação criada', [
                    'notificacao_id' => $notificacao->id,
                    'tipo' => $notificacao->tipo,
                    'canal' => $notificacao->canal,
                    'usuario_id' => $notificacao->usuario_id,
                    'cliente_id' => $notificacao->cliente_id
                ]);

                return $notificacao;
            });
        }, ['operation' => 'create_notification']);
    }

    /**
     * Enviar notificação
     */
    public function send(Notificacao $notificacao)
    {
        return $this->executeWithLog(function() use ($notificacao) {
            if ($notificacao->enviada) {
                return ['success' => true, 'message' => 'Notificação já foi enviada'];
            }

            $result = false;

            switch ($notificacao->canal) {
                case 'sistema':
                    $result = $this->sendSystemNotification($notificacao);
                    break;
                    
                case 'email':
                    $result = $this->sendEmailNotification($notificacao);
                    break;
                    
                case 'sms':
                    $result = $this->sendSmsNotification($notificacao);
                    break;
                    
                case 'push':
                    $result = $this->sendPushNotification($notificacao);
                    break;
                    
                case 'whatsapp':
                    $result = $this->sendWhatsAppNotification($notificacao);
                    break;
                    
                default:
                    throw new \InvalidArgumentException('Canal de notificação não suportado');
            }

            if ($result) {
                $notificacao->update([
                    'enviada' => true,
                    'data_envio' => now()
                ]);
            }

            $this->log($result ? 'info' : 'error', 'Notificação processada', [
                'notificacao_id' => $notificacao->id,
                'canal' => $notificacao->canal,
                'success' => $result
            ]);

            return ['success' => $result];
        }, ['operation' => 'send_notification', 'notificacao_id' => $notificacao->id]);
    }

    /**
     * Enviar notificação do sistema (apenas marca como enviada)
     */
    private function sendSystemNotification(Notificacao $notificacao)
    {
        // Notificação do sistema já está no banco, apenas marca como enviada
        return true;
    }

    /**
     * Enviar notificação por email
     */
    private function sendEmailNotification(Notificacao $notificacao)
    {
        try {
            if ($notificacao->usuario_id) {
                $email = $notificacao->usuario->email;
                $nome = $notificacao->usuario->nome;
            } elseif ($notificacao->cliente_id) {
                $email = $notificacao->cliente->email;
                $nome = $notificacao->cliente->nome;
            } else {
                throw new \Exception('Destinatário não definido para email');
            }

            // TODO: Implementar envio real de email
            $this->log('info', 'Email enviado (simulado)', [
                'destinatario' => $email,
                'assunto' => $notificacao->titulo
            ]);

            return true;
        } catch (\Exception $e) {
            $this->log('error', 'Erro ao enviar email', [
                'notificacao_id' => $notificacao->id,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }

    /**
     * Enviar SMS
     */
    private function sendSmsNotification(Notificacao $notificacao)
    {
        try {
            if ($notificacao->usuario_id) {
                $telefone = $notificacao->usuario->telefone;
            } elseif ($notificacao->cliente_id) {
                $telefone = $notificacao->cliente->telefone;
            } else {
                throw new \Exception('Destinatário não definido para SMS');
            }

            // TODO: Implementar envio real de SMS
            $this->log('info', 'SMS enviado (simulado)', [
                'telefone' => $telefone,
                'mensagem' => substr($notificacao->mensagem, 0, 100)
            ]);

            return true;
        } catch (\Exception $e) {
            $this->log('error', 'Erro ao enviar SMS', [
                'notificacao_id' => $notificacao->id,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }

    /**
     * Enviar notificação push
     */
    private function sendPushNotification(Notificacao $notificacao)
    {
        try {
            // TODO: Implementar push notification (Firebase/OneSignal)
            $this->log('info', 'Push notification enviada (simulado)', [
                'notificacao_id' => $notificacao->id,
                'titulo' => $notificacao->titulo
            ]);

            return true;
        } catch (\Exception $e) {
            $this->log('error', 'Erro ao enviar push notification', [
                'notificacao_id' => $notificacao->id,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }

    /**
     * Enviar WhatsApp
     */
    private function sendWhatsAppNotification(Notificacao $notificacao)
    {
        try {
            // TODO: Implementar WhatsApp Business API
            $this->log('info', 'WhatsApp enviado (simulado)', [
                'notificacao_id' => $notificacao->id,
                'mensagem' => substr($notificacao->mensagem, 0, 100)
            ]);

            return true;
        } catch (\Exception $e) {
            $this->log('error', 'Erro ao enviar WhatsApp', [
                'notificacao_id' => $notificacao->id,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }

    /**
     * Notificar prazo vencendo
     */
    public function notifyPrazoVencendo(Processo $processo, int $dias)
    {
        $message = "O processo {$processo->numero_formatado} tem prazo vencendo em {$dias} dia(s).";
        
        return $this->create([
            'usuario_id' => $processo->advogado_id,
            'titulo' => 'Prazo Vencendo',
            'mensagem' => $message,
            'tipo' => 'prazo_vencendo',
            'canal' => 'sistema',
            'dados_extras' => [
                'processo_id' => $processo->id,
                'prazo' => $processo->proximo_prazo,
                'dias_restantes' => $dias
            ],
            'icone' => 'clock',
            'cor' => '#F59E0B'
        ]);
    }

    /**
     * Notificar nova movimentação
     */
    public function notifyNovaMovimentacao($processo, $movimentacao)
    {
        $message = "Nova movimentação no processo {$processo->numero_formatado}: {$movimentacao->descricao}";
        
        // Notificar advogado
        $this->create([
            'usuario_id' => $processo->advogado_id,
            'titulo' => 'Nova Movimentação',
            'mensagem' => $message,
            'tipo' => 'movimentacao',
            'canal' => 'sistema',
            'dados_extras' => [
                'processo_id' => $processo->id,
                'movimentacao_id' => $movimentacao->id
            ],
            'icone' => 'gavel',
            'cor' => '#3B82F6'
        ]);

        // Notificar cliente se o portal estiver habilitado
        if ($processo->cliente->acesso_portal) {
            $this->create([
                'cliente_id' => $processo->cliente_id,
                'titulo' => 'Atualização do Processo',
                'mensagem' => $message,
                'tipo' => 'movimentacao',
                'canal' => 'email',
                'dados_extras' => [
                    'processo_id' => $processo->id,
                    'movimentacao_id' => $movimentacao->id
                ],
                'icone' => 'gavel',
                'cor' => '#3B82F6'
            ]);
        }
    }

    /**
     * Notificar pagamento vencido
     */
    public function notifyPagamentoVencido(Financeiro $financeiro)
    {
        $diasVencido = now()->diffInDays($financeiro->data_vencimento);
        $message = "Pagamento de R$ {$financeiro->valor} está vencido há {$diasVencido} dia(s).";
        
        return $this->create([
            'cliente_id' => $financeiro->cliente_id,
            'titulo' => 'Pagamento Vencido',
            'mensagem' => $message,
            'tipo' => 'pagamento',
            'canal' => 'email',
            'dados_extras' => [
                'financeiro_id' => $financeiro->id,
                'valor' => $financeiro->valor,
                'dias_vencido' => $diasVencido
            ],
            'icone' => 'credit-card',
            'cor' => '#EF4444'
        ]);
    }

    /**
     * Notificar novo documento
     */
    public function notifyNovoDocumento($documento)
    {
        $message = "Novo documento adicionado: {$documento->nome_original}";
        
        // Notificar cliente se o portal estiver habilitado
        if ($documento->cliente->acesso_portal) {
            return $this->create([
                'cliente_id' => $documento->cliente_id,
                'titulo' => 'Novo Documento',
                'mensagem' => $message,
                'tipo' => 'documento',
                'canal' => 'sistema',
                'dados_extras' => [
                    'documento_id' => $documento->id
                ],
                'icone' => 'file-text',
                'cor' => '#10B981'
            ]);
        }
    }

    /**
     * Marcar como lida
     */
    public function markAsRead(Notificacao $notificacao)
    {
        return $this->executeWithLog(function() use ($notificacao) {
            $notificacao->update([
                'lida' => true,
                'data_leitura' => now()
            ]);

            return $notificacao;
        }, ['operation' => 'mark_as_read', 'notificacao_id' => $notificacao->id]);
    }

    /**
     * Marcar todas como lidas para um usuário
     */
    public function markAllAsRead($userId, $isClient = false)
    {
        return $this->executeWithLog(function() use ($userId, $isClient) {
            $query = Notificacao::where('lida', false);
            
            if ($isClient) {
                $query->where('cliente_id', $userId);
            } else {
                $query->where('usuario_id', $userId);
            }
            
            $updated = $query->update([
                'lida' => true,
                'data_leitura' => now()
            ]);

            $this->log('info', 'Notificações marcadas como lidas', [
                'user_id' => $userId,
                'is_client' => $isClient,
                'total_updated' => $updated
            ]);

            return $updated;
        }, ['operation' => 'mark_all_as_read']);
    }

    /**
     * Buscar notificações
     */
    public function search(array $filters)
    {
        $query = Notificacao::query();

        if (isset($filters['usuario_id'])) {
            $query->where('usuario_id', $filters['usuario_id']);
        }

        if (isset($filters['cliente_id'])) {
            $query->where('cliente_id', $filters['cliente_id']);
        }

        if (isset($filters['tipo'])) {
            if (is_array($filters['tipo'])) {
                $query->whereIn('tipo', $filters['tipo']);
            } else {
                $query->where('tipo', $filters['tipo']);
            }
        }

        if (isset($filters['canal'])) {
            $query->where('canal', $filters['canal']);
        }

        if (isset($filters['lida'])) {
            $query->where('lida', $filters['lida']);
        }

        if (isset($filters['enviada'])) {
            $query->where('enviada', $filters['enviada']);
        }

        if (isset($filters['data_inicio']) && isset($filters['data_fim'])) {
            $query->whereBetween('created_at', [
                $filters['data_inicio'],
                $filters['data_fim']
            ]);
        }

        return $query->orderBy('created_at', 'desc');
    }

    /**
     * Obter estatísticas de notificações
     */
    public function getStats(array $filters = [])
    {
        $cacheKey = 'notification_stats_' . md5(serialize($filters));
        
        return $this->cache($cacheKey, function() use ($filters) {
            $query = Notificacao::query();

            if (isset($filters['usuario_id'])) {
                $query->where('usuario_id', $filters['usuario_id']);
            }

            if (isset($filters['cliente_id'])) {
                $query->where('cliente_id', $filters['cliente_id']);
            }

            if (isset($filters['data_inicio']) && isset($filters['data_fim'])) {
                $query->whereBetween('created_at', [
                    $filters['data_inicio'],
                    $filters['data_fim']
                ]);
            }

            $notificacoes = $query->get();

            return [
                'total' => $notificacoes->count(),
                'nao_lidas' => $notificacoes->where('lida', false)->count(),
                'nao_enviadas' => $notificacoes->where('enviada', false)->count(),
                'por_tipo' => $notificacoes->groupBy('tipo')->map->count(),
                'por_canal' => $notificacoes->groupBy('canal')->map->count(),
                'taxa_leitura' => $notificacoes->count() > 0 
                    ? round(($notificacoes->where('lida', true)->count() / $notificacoes->count()) * 100, 2)
                    : 0,
                'taxa_envio' => $notificacoes->count() > 0
                    ? round(($notificacoes->where('enviada', true)->count() / $notificacoes->count()) * 100, 2)
                    : 0
            ];
        }, 600); // Cache por 10 minutos
    }

    /**
     * Processar notificações pendentes
     */
    public function processarPendentes()
    {
        return $this->executeWithLog(function() {
            $pendentes = Notificacao::where('enviada', false)
                                   ->where('created_at', '<=', now()->subMinutes(5))
                                   ->limit(100)
                                   ->get();

            $processadas = 0;
            $errors = 0;

            foreach ($pendentes as $notificacao) {
                try {
                    $this->send($notificacao);
                    $processadas++;
                } catch (\Exception $e) {
                    $errors++;
                    $this->log('error', 'Erro ao processar notificação pendente', [
                        'notificacao_id' => $notificacao->id,
                        'error' => $e->getMessage()
                    ]);
                }
            }

            $this->log('info', 'Processamento de notificações pendentes concluído', [
                'total_pendentes' => $pendentes->count(),
                'processadas' => $processadas,
                'errors' => $errors
            ]);

            return [
                'total_pendentes' => $pendentes->count(),
                'processadas' => $processadas,
                'errors' => $errors
            ];
        }, ['operation' => 'process_pending_notifications']);
    }

    /**
     * Limpar notificações antigas
     */
    public function limparAntigas(int $dias = 90)
    {
        return $this->executeWithLog(function() use ($dias) {
            $deleted = Notificacao::where('lida', true)
                                 ->where('created_at', '<', now()->subDays($dias))
                                 ->delete();

            $this->log('info', 'Notificações antigas removidas', [
                'dias' => $dias,
                'total_removed' => $deleted
            ]);

            return $deleted;
        }, ['operation' => 'cleanup_old_notifications', 'dias' => $dias]);
    }
}
