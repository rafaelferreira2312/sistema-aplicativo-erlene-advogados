<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Movimentacao extends Model
{
    use HasFactory;

    protected $table = 'movimentacoes';

    protected $fillable = [
        'processo_id',
        'data',
        'descricao',
        'tipo',
        'documento_url',
        'metadata'
    ];

    protected $casts = [
        'data' => 'datetime',
        'metadata' => 'array',
    ];

    // Relationships
    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    // Scopes
    public function scopeRecentes($query, $dias = 30)
    {
        return $query->where('data', '>=', now()->subDays($dias));
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    public function scopeComDocumento($query)
    {
        return $query->whereNotNull('documento_url');
    }

    // Accessors
    public function getTipoBadgeAttribute()
    {
        $badges = [
            'automatica' => 'info',
            'manual' => 'primary',
            'tribunal' => 'success'
        ];

        return $badges[$this->tipo] ?? 'secondary';
    }

    public function getTemDocumentoAttribute()
    {
        return !empty($this->documento_url);
    }
}
