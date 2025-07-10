<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Atendimento extends Model
{
    use HasFactory;

    protected $fillable = [
        'cliente_id',
        'advogado_id',
        'data_hora',
        'tipo',
        'assunto',
        'descricao',
        'status',
        'duracao',
        'valor',
        'proximos_passos',
        'anexos',
        'unidade_id'
    ];

    protected $casts = [
        'data_hora' => 'datetime',
        'valor' => 'decimal:2',
        'anexos' => 'array',
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

    public function processos()
    {
        return $this->belongsToMany(Processo::class, 'atendimento_processos');
    }

    public function financeiro()
    {
        return $this->hasMany(Financeiro::class);
    }

    // Scopes
    public function scopeAgendados($query)
    {
        return $query->where('status', 'agendado');
    }

    public function scopeHoje($query)
    {
        return $query->whereDate('data_hora', today());
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    // Accessors
    public function getDuracaoFormatadaAttribute()
    {
        if (!$this->duracao) return null;
        
        $horas = intval($this->duracao / 60);
        $minutos = $this->duracao % 60;
        
        return ($horas > 0 ? $horas . 'h ' : '') . ($minutos > 0 ? $minutos . 'min' : '');
    }

    public function getStatusBadgeAttribute()
    {
        $badges = [
            'agendado' => 'info',
            'em_andamento' => 'warning',
            'concluido' => 'success',
            'cancelado' => 'danger'
        ];

        return $badges[$this->status] ?? 'secondary';
    }
}
