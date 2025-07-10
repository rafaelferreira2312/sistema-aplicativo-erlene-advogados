<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tarefa extends Model
{
    use HasFactory;

    protected $fillable = [
        'titulo',
        'descricao',
        'tipo',
        'status',
        'prazo',
        'responsavel_id',
        'cliente_id',
        'processo_id',
        'kanban_posicao'
    ];

    protected $casts = [
        'prazo' => 'datetime',
    ];

    // Relationships
    public function responsavel()
    {
        return $this->belongsTo(User::class, 'responsavel_id');
    }

    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    public function kanbanCards()
    {
        return $this->hasMany(KanbanCard::class);
    }

    // Scopes
    public function scopePendentes($query)
    {
        return $query->where('status', 'pendente');
    }

    public function scopeVencidas($query)
    {
        return $query->where('status', 'pendente')
                    ->where('prazo', '<', now());
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    public function scopePorResponsavel($query, $responsavelId)
    {
        return $query->where('responsavel_id', $responsavelId);
    }

    // Accessors
    public function getStatusBadgeAttribute()
    {
        $badges = [
            'pendente' => 'warning',
            'em_andamento' => 'info',
            'concluida' => 'success',
            'cancelada' => 'danger'
        ];

        return $badges[$this->status] ?? 'secondary';
    }

    public function getTempoRestanteAttribute()
    {
        if (!$this->prazo || $this->status !== 'pendente') return null;
        
        return $this->prazo->diffForHumans();
    }
}
