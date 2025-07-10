<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Processo extends Model
{
    use HasFactory;

    protected $fillable = [
        'numero',
        'tribunal',
        'vara',
        'cliente_id',
        'tipo_acao',
        'status',
        'valor_causa',
        'data_distribuicao',
        'advogado_id',
        'unidade_id',
        'proximo_prazo',
        'observacoes',
        'prioridade',
        'kanban_posicao',
        'kanban_coluna_id'
    ];

    protected $casts = [
        'valor_causa' => 'decimal:2',
        'data_distribuicao' => 'date',
        'proximo_prazo' => 'date',
    ];

    // Relationships
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function advogado()
    {
        return $this->belongsTo(User::class, 'advogado_id');
    }

    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    public function atendimentos()
    {
        return $this->belongsToMany(Atendimento::class, 'atendimento_processos');
    }

    public function movimentacoes()
    {
        return $this->hasMany(Movimentacao::class);
    }

    public function kanbanCards()
    {
        return $this->hasMany(KanbanCard::class);
    }

    public function tarefas()
    {
        return $this->hasMany(Tarefa::class);
    }

    public function financeiro()
    {
        return $this->hasMany(Financeiro::class);
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->whereIn('status', ['distribuido', 'em_andamento']);
    }

    public function scopePorPrioridade($query, $prioridade)
    {
        return $query->where('prioridade', $prioridade);
    }

    public function scopeComPrazoVencendo($query, $dias = 7)
    {
        return $query->whereNotNull('proximo_prazo')
                    ->whereBetween('proximo_prazo', [now(), now()->addDays($dias)]);
    }

    // Accessors
    public function getNumeroFormatadoAttribute()
    {
        return preg_replace('/(\d{7})(\d{2})(\d{4})(\d{1})(\d{2})(\d{4})/', 
                           '$1-$2.$3.$4.$5.$6', $this->numero);
    }

    public function getStatusBadgeAttribute()
    {
        $badges = [
            'distribuido' => 'info',
            'em_andamento' => 'primary',
            'suspenso' => 'warning',
            'arquivado' => 'secondary',
            'finalizado' => 'success'
        ];

        return $badges[$this->status] ?? 'secondary';
    }
}
