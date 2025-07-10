<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PagamentoMercadoPago extends Model
{
    use HasFactory;

    protected $table = 'pagamentos_mp';

    protected $fillable = [
        'cliente_id',
        'processo_id',
        'atendimento_id',
        'financeiro_id',
        'valor',
        'tipo',
        'status',
        'mp_payment_id',
        'mp_preference_id',
        'mp_external_reference',
        'mp_metadata',
        'data_criacao',
        'data_pagamento',
        'data_vencimento',
        'taxa_mp',
        'linha_digitavel',
        'qr_code',
        'observacoes'
    ];

    protected $casts = [
        'valor' => 'decimal:2',
        'taxa_mp' => 'decimal:2',
        'mp_metadata' => 'array',
        'data_criacao' => 'datetime',
        'data_pagamento' => 'datetime',
        'data_vencimento' => 'datetime',
    ];

    // Relationships
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    public function atendimento()
    {
        return $this->belongsTo(Atendimento::class);
    }

    public function financeiro()
    {
        return $this->belongsTo(Financeiro::class);
    }

    // Scopes
    public function scopeAprovados($query)
    {
        return $query->where('status', 'approved');
    }

    public function scopePendentes($query)
    {
        return $query->whereIn('status', ['pending', 'in_process']);
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    public function scopeBoletos($query)
    {
        return $query->where('tipo', 'boleto');
    }

    public function scopePix($query)
    {
        return $query->where('tipo', 'pix');
    }

    // Accessors
    public function getStatusBadgeAttribute()
    {
        $badges = [
            'pending' => 'warning',
            'approved' => 'success',
            'authorized' => 'info',
            'in_process' => 'info',
            'in_mediation' => 'warning',
            'rejected' => 'danger',
            'cancelled' => 'secondary',
            'refunded' => 'dark',
            'charged_back' => 'danger'
        ];

        return $badges[$this->status] ?? 'secondary';
    }

    public function getTipoBadgeAttribute()
    {
        $badges = [
            'pix' => 'success',
            'boleto' => 'info',
            'cartao_credito' => 'primary',
            'cartao_debito' => 'warning'
        ];

        return $badges[$this->tipo] ?? 'secondary';
    }

    public function getValorLiquidoAttribute()
    {
        return $this->valor - ($this->taxa_mp ?? 0);
    }
}
