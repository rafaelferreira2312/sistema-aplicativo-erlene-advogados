<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'nome',
        'email',
        'password',
        'cpf',
        'oab',
        'telefone',
        'perfil',
        'unidade_id',
        'status',
        'ultimo_acesso'
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'ultimo_acesso' => 'datetime',
    ];

    // JWT Methods
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [
            'perfil' => $this->perfil,
            'unidade_id' => $this->unidade_id
        ];
    }

    // Relationships
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    public function clientes()
    {
        return $this->hasMany(Cliente::class, 'responsavel_id');
    }

    public function processos()
    {
        return $this->hasMany(Processo::class, 'advogado_id');
    }

    public function atendimentos()
    {
        return $this->hasMany(Atendimento::class, 'advogado_id');
    }

    public function tarefas()
    {
        return $this->hasMany(Tarefa::class, 'responsavel_id');
    }

    public function notificacoes()
    {
        return $this->hasMany(Notificacao::class, 'usuario_id');
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->where('status', 'ativo');
    }

    public function scopePorPerfil($query, $perfil)
    {
        return $query->where('perfil', $perfil);
    }

    public function scopePorUnidade($query, $unidadeId)
    {
        return $query->where('unidade_id', $unidadeId);
    }

    // Accessors
    public function getNomeCompletoAttribute()
    {
        return $this->nome . ($this->oab ? ' - OAB ' . $this->oab : '');
    }

    public function getIsAdminAttribute()
    {
        return in_array($this->perfil, ['admin_geral', 'admin_unidade']);
    }
}
