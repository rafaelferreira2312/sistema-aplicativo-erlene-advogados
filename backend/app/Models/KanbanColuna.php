<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KanbanColuna extends Model
{
    use HasFactory;

    protected $table = 'kanban_colunas';

    protected $fillable = [
        'nome',
        'ordem',
        'cor',
        'unidade_id'
    ];

    // Relationships
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    public function cards()
    {
        return $this->hasMany(KanbanCard::class, 'coluna_id');
    }

    // Scopes
    public function scopeOrdenadas($query)
    {
        return $query->orderBy('ordem');
    }

    public function scopePorUnidade($query, $unidadeId)
    {
        return $query->where('unidade_id', $unidadeId);
    }

    // Accessors
    public function getTotalCardsAttribute()
    {
        return $this->cards()->count();
    }

    public function getCorComOpacidadeAttribute()
    {
        return $this->cor . '20'; // Adiciona opacidade
    }
}
