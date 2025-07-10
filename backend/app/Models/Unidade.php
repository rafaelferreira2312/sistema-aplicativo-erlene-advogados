<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Unidade extends Model
{
    use HasFactory;

    protected $table = 'unidades';

    protected $fillable = [
        'nome',
        'cnpj',
        'endereco',
        'cep',
        'cidade',
        'estado',
        'telefone',
        'email',
        'matriz_id',
        'is_matriz',
        'status'
    ];

    protected $casts = [
        'is_matriz' => 'boolean',
    ];

    // Relationships
    public function matriz()
    {
        return $this->belongsTo(Unidade::class, 'matriz_id');
    }

    public function filiais()
    {
        return $this->hasMany(Unidade::class, 'matriz_id');
    }

    public function usuarios()
    {
        return $this->hasMany(User::class);
    }

    public function clientes()
    {
        return $this->hasMany(Cliente::class);
    }

    public function processos()
    {
        return $this->hasMany(Processo::class);
    }

    public function atendimentos()
    {
        return $this->hasMany(Atendimento::class);
    }

    public function kanbanColunas()
    {
        return $this->hasMany(KanbanColuna::class);
    }

    // Scopes
    public function scopeAtivas($query)
    {
        return $query->where('status', 'ativo');
    }

    public function scopeMatrizes($query)
    {
        return $query->where('is_matriz', true);
    }

    public function scopeFiliais($query)
    {
        return $query->where('is_matriz', false);
    }

    // Accessors
    public function getEnderecoCompletoAttribute()
    {
        return $this->endereco . ', ' . $this->cidade . '/' . $this->estado . ' - ' . $this->cep;
    }
}
