<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Foundation\Auth\User as Authenticatable;

class Cliente extends Authenticatable
{
    use HasFactory;

    protected $fillable = [
        'nome',
        'cpf_cnpj',
        'tipo_pessoa',
        'email',
        'telefone',
        'endereco',
        'cep',
        'cidade',
        'estado',
        'observacoes',
        'acesso_portal',
        'senha_portal',
        'tipo_armazenamento',
        'google_drive_config',
        'onedrive_config',
        'pasta_local',
        'unidade_id',
        'responsavel_id',
        'status'
    ];

    protected $hidden = [
        'senha_portal',
    ];

    protected $casts = [
        'acesso_portal' => 'boolean',
        'google_drive_config' => 'array',
        'onedrive_config' => 'array',
    ];

    // Relationships
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    public function responsavel()
    {
        return $this->belongsTo(User::class, 'responsavel_id');
    }

    public function processos()
    {
        return $this->hasMany(Processo::class);
    }

    public function atendimentos()
    {
        return $this->hasMany(Atendimento::class);
    }

    public function documentos()
    {
        return $this->hasMany(DocumentoGed::class);
    }

    public function financeiro()
    {
        return $this->hasMany(Financeiro::class);
    }

    public function acessosPortal()
    {
        return $this->hasMany(AcessoPortal::class);
    }

    public function mensagens()
    {
        return $this->hasMany(Mensagem::class);
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->where('status', 'ativo');
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo_pessoa', $tipo);
    }

    public function scopeComAcessoPortal($query)
    {
        return $query->where('acesso_portal', true);
    }

    // Accessors
    public function getDocumentoAttribute()
    {
        return $this->cpf_cnpj;
    }

    public function getEnderecoCompletoAttribute()
    {
        return $this->endereco . ', ' . $this->cidade . '/' . $this->estado . ' - ' . $this->cep;
    }

    public function getNomePastaAttribute()
    {
        return $this->pasta_local ?: str_slug($this->nome);
    }
}
