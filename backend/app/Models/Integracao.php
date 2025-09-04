<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Integracao extends Model
{
    use HasFactory;

    protected $table = 'integracoes';

    protected $fillable = [
        'nome',
        'ativo',
        'configuracoes',
        'ultima_sincronizacao',
        'status',
        'ultimo_erro',
        'total_requisicoes',
        'requisicoes_sucesso',
        'requisicoes_erro',
        'unidade_id'
    ];

    protected $casts = [
        'ativo' => 'boolean',
        'configuracoes' => 'array',
        'ultima_sincronizacao' => 'datetime'
    ];

    // Relacionamentos
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    // Scopes
    public function scopeAtivas($query)
    {
        return $query->where('ativo', true);
    }

    public function scopeFuncionando($query)
    {
        return $query->where('status', 'funcionando');
    }

    // Métodos auxiliares
    public function isAtiva()
    {
        return $this->ativo && $this->status === 'funcionando';
    }

    public function registrarRequisicao($sucesso = true, $erro = null)
    {
        $this->increment('total_requisicoes');
        
        if ($sucesso) {
            $this->increment('requisicoes_sucesso');
            $this->update([
                'status' => 'funcionando',
                'ultimo_erro' => null,
                'ultima_sincronizacao' => now()
            ]);
        } else {
            $this->increment('requisicoes_erro');
            $this->update([
                'status' => 'erro',
                'ultimo_erro' => $erro
            ]);
        }
    }
}
