<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Financeiro extends Model
{
    use HasFactory;

    protected $table = 'financeiro';

    protected $fillable = [
        'processo_id',
        'atendimento_id',
        'cliente_id',
        'tipo',
        'valor',
        'data_vencimento',
        'data_pagamento',
        'status',
        'descricao',
        'gateway',
        'transaction_id',
        'gateway_response',
        'unidade_id'
    ];

    protected $casts = [
        'valor' => 'decimal:2',
        'data_vencimento' => 'date',
        'data_pagamento' => 'date',
        'gateway_response' => 'array',
    ];

    // Relationships
    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    public function atendimento()
    {
        return $this->belongsTo(Atendimento::class);
    }

    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    public function pagamentosStripe()
    {
        return $this->hasMany(PagamentoStripe::class);
    }

    public function pagamentosMercadoPago()
    {
        return $this->hasMany(PagamentoMercadoPago::class);
    }

    // Scopes
    public function scopePendentes($query)
    {
        return $query->where('status', 'pendente');
    }

    public function scopeVencidos($query)
    {
        return $query->where('status', 'pendente')
                    ->where('data_vencimento', '<', now());
    }

    public function scopePorGateway($query, $gateway)
    {
        return $query->where('gateway', $gateway);
    }

    // Accessors
    public function getStatusBadgeAttribute()
    {
        $badges = [
            'pendente' => 'warning',
            'pago' => 'success',
            'atrasado' => 'danger',
            'cancelado' => 'secondary',
            'parcial' => 'info'
        ];

        return $badges[$this->status] ?? 'secondary';
    }

    public function getDiasVencimentoAttribute()
    {
        return $this->data_vencimento->diffInDays(now(), false);
    }
}
