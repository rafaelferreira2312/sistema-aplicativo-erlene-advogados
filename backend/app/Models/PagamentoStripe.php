<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PagamentoStripe extends Model
{
    use HasFactory;

    protected $table = 'pagamentos_stripe';

    protected $fillable = [
        'cliente_id',
        'processo_id',
        'atendimento_id',
        'financeiro_id',
        'valor',
        'moeda',
        'status',
        'stripe_payment_intent_id',
        'stripe_customer_id',
        'stripe_charge_id',
        'stripe_metadata',
        'data_criacao',
        'data_pagamento',
        'taxa_stripe',
        'observacoes'
    ];

    protected $casts = [
        'valor' => 'decimal:2',
        'taxa_stripe' => 'decimal:2',
        'stripe_metadata' => 'array',
        'data_criacao' => 'datetime',
        'data_pagamento' => 'datetime',
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
    public function scopeSucesso($query)
    {
        return $query->where('status', 'succeeded');
    }

    public function scopePendentes($query)
    {
        return $query->whereIn('status', ['pending', 'processing']);
    }

    public function scopePorMoeda($query, $moeda)
    {
        return $query->where('moeda', $moeda);
    }

    // Accessors
    public function getStatusBadgeAttribute()
    {
        $badges = [
            'pending' => 'warning',
            'processing' => 'info',
            'succeeded' => 'success',
            'failed' => 'danger',
            'canceled' => 'secondary',
            'refunded' => 'dark'
        ];

        return $badges[$this->status] ?? 'secondary';
    }

    public function getValorLiquidoAttribute()
    {
        return $this->valor - ($this->taxa_stripe ?? 0);
    }
}
