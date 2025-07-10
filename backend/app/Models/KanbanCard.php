<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KanbanCard extends Model
{
    use HasFactory;

    protected $table = 'kanban_cards';

    protected $fillable = [
        'titulo',
        'descricao',
        'coluna_id',
        'processo_id',
        'tarefa_id',
        'posicao',
        'prioridade',
        'prazo',
        'responsavel_id'
    ];

    protected $casts = [
        'prazo' => 'date',
    ];

    // Relationships
    public function coluna()
    {
        return $this->belongsTo(KanbanColuna::class, 'coluna_id');
    }

    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    public function tarefa()
    {
        return $this->belongsTo(Tarefa::class);
    }

    public function responsavel()
    {
        return $this->belongsTo(User::class, 'responsavel_id');
    }

    // Scopes
    public function scopeOrdenados($query)
    {
        return $query->orderBy('posicao');
    }

    public function scopePorPrioridade($query, $prioridade)
    {
        return $query->where('prioridade', $prioridade);
    }

    public function scopeComPrazoVencendo($query, $dias = 3)
    {
        return $query->whereNotNull('prazo')
                    ->whereBetween('prazo', [now(), now()->addDays($dias)]);
    }

    // Accessors
    public function getPrioridadeBadgeAttribute()
    {
        $badges = [
            'baixa' => 'success',
            'media' => 'info',
            'alta' => 'warning',
            'urgente' => 'danger'
        ];

        return $badges[$this->prioridade] ?? 'secondary';
    }

    public function getDiasPrazoAttribute()
    {
        if (!$this->prazo) return null;
        
        return $this->prazo->diffInDays(now(), false);
    }
}
