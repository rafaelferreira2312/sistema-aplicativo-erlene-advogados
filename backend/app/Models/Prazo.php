<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Prazo extends Model
{
    use HasFactory;

    protected $table = 'prazos';

    protected $fillable = [
        'client_id',
        'process_id', 
        'user_id',
        'descricao',
        'tipo_prazo',
        'data_vencimento',
        'hora_vencimento',
        'status',
        'prioridade',
        'observacoes',
        'dias_antecedencia',
        'alerta_enviado'
    ];

    protected $casts = [
        'data_vencimento' => 'date',
        'hora_vencimento' => 'datetime:H:i',
        'alerta_enviado' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];

    // Relacionamentos usando os Models CORRETOS
    public function client()
    {
        return $this->belongsTo(\App\Models\Cliente::class, 'client_id');
    }

    public function process()
    {
        return $this->belongsTo(\App\Models\Processo::class, 'process_id');
    }

    public function user()
    {
        return $this->belongsTo(\App\Models\User::class, 'user_id');
    }

    // Aliases para facilitar uso
    public function cliente()
    {
        return $this->client();
    }

    public function processo()
    {
        return $this->process();
    }

    public function advogado()
    {
        return $this->user();
    }

    // Scopes
    public function scopePendentes($query)
    {
        return $query->where('status', 'Pendente');
    }

    public function scopePorPrioridade($query, $prioridade)
    {
        return $query->where('prioridade', $prioridade);
    }

    public function scopeVencendoHoje($query)
    {
        return $query->whereDate('data_vencimento', Carbon::today());
    }

    public function scopeVencendoEm($query, $dias)
    {
        $dataFutura = Carbon::today()->addDays($dias);
        return $query->whereDate('data_vencimento', '<=', $dataFutura)
                    ->whereDate('data_vencimento', '>=', Carbon::today());
    }

    public function scopeVencidos($query)
    {
        return $query->whereDate('data_vencimento', '<', Carbon::today())
                    ->where('status', '!=', 'Concluído');
    }

    // Accessors
    public function getDiasRestantesAttribute()
    {
        if ($this->status === 'Concluído') {
            return null;
        }

        $hoje = Carbon::today();
        $vencimento = Carbon::parse($this->data_vencimento);
        
        return $hoje->diffInDays($vencimento, false);
    }

    public function getIsVencidoAttribute()
    {
        if ($this->status === 'Concluído') {
            return false;
        }
        
        return Carbon::parse($this->data_vencimento)->isPast();
    }

    public function getPrecisaAlertaAttribute()
    {
        if ($this->alerta_enviado || $this->status === 'Concluído') {
            return false;
        }

        $diasRestantes = $this->dias_restantes;
        return $diasRestantes <= $this->dias_antecedencia && $diasRestantes >= 0;
    }

    public function getCorPrioridadeAttribute()
    {
        return match($this->prioridade) {
            'Urgente' => 'red',
            'Alta' => 'yellow', 
            'Normal' => 'blue',
            default => 'gray'
        };
    }

    public function getCorStatusAttribute()
    {
        return match($this->status) {
            'Pendente' => 'yellow',
            'Em Andamento' => 'blue',
            'Concluído' => 'green',
            'Vencido' => 'red',
            default => 'gray'
        };
    }

    // Métodos auxiliares
    public function marcarComoConcluido()
    {
        $this->update(['status' => 'Concluído']);
    }

    public function marcarAlertaEnviado()
    {
        $this->update(['alerta_enviado' => true]);
    }
}
