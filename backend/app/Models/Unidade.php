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
        'codigo',
        'endereco',
        'cidade',
        'estado',
        'cep',
        'telefone',
        'email',
        'cnpj',
        'status',
    ];

    public function usuarios()
    {
        return $this->hasMany(User::class);
    }

    public function scopeAtivas($query)
    {
        return $query->where('status', 'ativa');
    }

    public function isMatriz()
    {
        return $this->codigo === 'MATRIZ';
    }
}
