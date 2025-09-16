<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Carbon\Carbon;

class Audiencia extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'audiencias';

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'processo_id',
        'cliente_id', 
        'advogado_id',
        'unidade_id',
        'tipo',
        'data',
        'hora',
        'local',
        'endereco',
        'sala',
        'advogado',
        'juiz',
        'status',
        'observacoes',
        'lembrete',
        'horas_lembrete'
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'data' => 'date',
        'hora' => 'datetime:H:i',
        'lembrete' => 'boolean',
        'horas_lembrete' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime'
    ];

    /**
     * Relacionamento com Processo
     */
    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    /**
     * Relacionamento com Cliente  
     */
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    /**
     * Relacionamento com Advogado Responsável
     */
    public function advogadoResponsavel()
    {
        return $this->belongsTo(User::class, 'advogado_id');
    }

    /**
     * Relacionamento com Unidade
     */
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    /**
     * Scope para audiências de hoje
     */
    public function scopeHoje($query)
    {
        return $query->whereDate('data', Carbon::today());
    }

    /**
     * Scope para próximas audiências (próximas 2 horas)
     */
    public function scopeProximas($query, $horas = 2)
    {
        $agora = Carbon::now();
        $limite = $agora->copy()->addHours($horas);
        
        return $query->whereDate('data', Carbon::today())
                    ->whereTime('hora', '>=', $agora->format('H:i:s'))
                    ->whereTime('hora', '<=', $limite->format('H:i:s'));
    }

    /**
     * Scope para audiências em andamento
     */
    public function scopeEmAndamento($query)
    {
        return $query->where('status', 'confirmada')
                    ->whereDate('data', Carbon::today());
    }

    /**
     * Scope para audiências agendadas
     */
    public function scopeAgendadas($query)
    {
        return $query->where('status', 'agendada');
    }

    /**
     * Scope para filtrar por período
     */
    public function scopePorPeriodo($query, $dataInicio, $dataFim)
    {
        return $query->whereBetween('data', [$dataInicio, $dataFim]);
    }

    /**
     * Scope para filtrar por tipo
     */
    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    /**
     * Scope para filtrar por status
     */
    public function scopePorStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Accessor para data formatada
     */
    public function getDataFormatadaAttribute()
    {
        return $this->data ? $this->data->format('d/m/Y') : null;
    }

    /**
     * Accessor para hora formatada
     */
    public function getHoraFormatadaAttribute()
    {
        return $this->hora ? Carbon::parse($this->hora)->format('H:i') : null;
    }

    /**
     * Accessor para status formatado
     */
    public function getStatusFormatadoAttribute()
    {
        $status = [
            'agendada' => 'Agendada',
            'confirmada' => 'Confirmada', 
            'realizada' => 'Realizada',
            'cancelada' => 'Cancelada',
            'adiada' => 'Adiada'
        ];

        return $status[$this->status] ?? $this->status;
    }

    /**
     * Accessor para tipo formatado
     */
    public function getTipoFormatadoAttribute()
    {
        $tipos = [
            'conciliacao' => 'Audiência de Conciliação',
            'instrucao' => 'Audiência de Instrução',
            'preliminar' => 'Audiência Preliminar',
            'julgamento' => 'Audiência de Julgamento',
            'outras' => 'Outras'
        ];

        return $tipos[$this->tipo] ?? $this->tipo;
    }

    /**
     * Verificar se a audiência está próxima (nas próximas X horas)
     */
    public function isProxima($horas = 2)
    {
        if ($this->data->isToday()) {
            $agora = Carbon::now();
            $horaAudiencia = Carbon::parse($this->data->format('Y-m-d') . ' ' . $this->hora);
            
            return $horaAudiencia->diffInHours($agora, false) <= $horas && $horaAudiencia->isFuture();
        }
        
        return false;
    }

    /**
     * Verificar se a audiência é hoje
     */
    public function isHoje()
    {
        return $this->data->isToday();
    }
}
