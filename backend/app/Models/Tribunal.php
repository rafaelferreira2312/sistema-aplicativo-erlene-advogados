<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tribunal extends Model
{
    use HasFactory;

    protected $table = 'tribunais';

    protected $fillable = [
        'nome',
        'codigo',
        'url_consulta',
        'tipo',
        'estado',
        'config_api',
        'ativo',
        'limite_consultas_dia'
    ];

    protected $casts = [
        'config_api' => 'array',
        'ativo' => 'boolean',
    ];

    // Relationships
    public function processos()
    {
        return $this->hasMany(Processo::class, 'tribunal', 'codigo');
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->where('ativo', true);
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    public function scopePorEstado($query, $estado)
    {
        return $query->where('estado', $estado);
    }

    // Accessors
    public function getTipoBadgeAttribute()
    {
        $badges = [
            'estadual' => 'primary',
            'federal' => 'info',
            'trabalhista' => 'warning',
            'superior' => 'success'
        ];

        return $badges[$this->tipo] ?? 'secondary';
    }

    public function getNomeCompletoAttribute()
    {
        return $this->nome . ' (' . $this->codigo . ')';
    }
}
