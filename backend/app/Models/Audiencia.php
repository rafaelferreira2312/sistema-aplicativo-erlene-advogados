<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

/**
 * Model Audiencia
 * 
 * @property int $id
 * @property int $processo_id
 * @property int $cliente_id
 * @property int $advogado_id
 * @property int $unidade_id
 * @property string $tipo ENUM: conciliacao, instrucao, preliminar, julgamento, outras
 * @property string $data
 * @property string $hora
 * @property string $local
 * @property string $advogado
 * @property string|null $endereco
 * @property string|null $sala
 * @property string|null $juiz
 * @property string|null $observacoes
 * @property string $status ENUM: agendada, confirmada, em_andamento, realizada, cancelada, adiada
 * @property bool $lembrete
 * @property int $horas_lembrete
 */
class Audiencia extends Model
{
    use SoftDeletes;

    protected $table = 'audiencias';

    /**
     * Campos preenchíveis em massa
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
        'observacoes',
        'status',
        'lembrete',
        'horas_lembrete',
    ];

    /**
     * Conversões de tipo automáticas
     */
    protected $casts = [
        'data' => 'date',
        'hora' => 'datetime:H:i',
        'lembrete' => 'boolean',
        'horas_lembrete' => 'integer',
    ];

    /**
     * Valores ENUM válidos para tipo
     */
    const TIPOS_VALIDOS = [
        'conciliacao',
        'instrucao',
        'preliminar', 
        'julgamento',
        'outras'
    ];

    /**
     * Valores ENUM válidos para status
     */
    const STATUS_VALIDOS = [
        'agendada',
        'confirmada',
        'em_andamento',
        'realizada',
        'cancelada',
        'adiada'
    ];

    /**
     * Relacionamento com Processo
     */
    public function processo(): BelongsTo
    {
        return $this->belongsTo(Processo::class);
    }

    /**
     * Relacionamento com Cliente  
     */
    public function cliente(): BelongsTo
    {
        return $this->belongsTo(Cliente::class);
    }

    /**
     * Relacionamento com Advogado Responsável
     */
    public function advogado(): BelongsTo
    {
        return $this->belongsTo(User::class, 'advogado_id');
    }

    /**
     * Relacionamento com Unidade
     */
    public function unidade(): BelongsTo
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
     * Scope para próximas audiências
     */
    public function scopeProximas($query, $horas = 2)
    {
        $agora = Carbon::now();
        $limite = $agora->copy()->addHours($horas);
        
        return $query->where(function($q) use ($agora, $limite) {
            $q->whereDate('data', $agora->toDateString())
              ->whereTime('hora', '>=', $agora->toTimeString())
              ->whereTime('hora', '<=', $limite->toTimeString());
        });
    }

    /**
     * Scope para audiências em andamento
     */
    public function scopeEmAndamento($query)
    {
        return $query->where('status', 'em_andamento');
    }

    /**
     * Scope para audiências do mês atual
     */
    public function scopeMesAtual($query)
    {
        return $query->whereYear('data', Carbon::now()->year)
                    ->whereMonth('data', Carbon::now()->month);
    }

    /**
     * Accessor para formatação da data/hora
     */
    public function getDataHoraFormatadaAttribute()
    {
        return Carbon::parse($this->data . ' ' . $this->hora)->format('d/m/Y H:i');
    }

    /**
     * Accessor para status formatado
     */
    public function getStatusFormatadoAttribute()
    {
        $statusMap = [
            'agendada' => 'Agendada',
            'confirmada' => 'Confirmada',
            'em_andamento' => 'Em Andamento',
            'realizada' => 'Realizada',
            'cancelada' => 'Cancelada',
            'adiada' => 'Adiada'
        ];

        return $statusMap[$this->status] ?? $this->status;
    }

    /**
     * Accessor para tipo formatado
     */
    public function getTipoFormatadoAttribute()
    {
        $tiposMap = [
            'conciliacao' => 'Conciliação',
            'instrucao' => 'Instrução',
            'preliminar' => 'Preliminar',
            'julgamento' => 'Julgamento',
            'outras' => 'Outras'
        ];

        return $tiposMap[$this->tipo] ?? $this->tipo;
    }
}
