<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\SoftDeletes;

class Cliente extends Authenticatable
{
    use HasFactory, SoftDeletes;

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
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected $dates = ['deleted_at'];

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
        $partes = array_filter([
            $this->endereco,
            $this->cidade,
            $this->estado,
            $this->cep
        ]);
        
        return implode(', ', $partes);
    }

    public function getNomePastaAttribute()
    {
        return $this->pasta_local ?: \Str::slug($this->nome);
    }

    public function getAvatarAttribute()
    {
        return 'https://ui-avatars.com/api/?name=' . urlencode($this->nome) . '&color=8B1538&background=F8F9FA';
    }

    // Mutators
    public function setCpfCnpjAttribute($value)
    {
        $this->attributes['cpf_cnpj'] = preg_replace('/\D/', '', $value);
    }

    public function getTelefoneFormatadoAttribute()
    {
        $telefone = preg_replace('/\D/', '', $this->telefone);
        
        if (strlen($telefone) === 11) {
            return preg_replace('/(\d{2})(\d{5})(\d{4})/', '($1) $2-$3', $telefone);
        } elseif (strlen($telefone) === 10) {
            return preg_replace('/(\d{2})(\d{4})(\d{4})/', '($1) $2-$3', $telefone);
        }
        
        return $this->telefone;
    }

    public function getCpfCnpjFormatadoAttribute()
    {
        $documento = preg_replace('/\D/', '', $this->cpf_cnpj);
        
        if (strlen($documento) === 11) {
            // CPF
            return preg_replace('/(\d{3})(\d{3})(\d{3})(\d{2})/', '$1.$2.$3-$4', $documento);
        } elseif (strlen($documento) === 14) {
            // CNPJ  
            return preg_replace('/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/', '$1.$2.$3/$4-$5', $documento);
        }
        
        return $this->cpf_cnpj;
    }

    // Métodos auxiliares
    public function isPessoaFisica()
    {
        return $this->tipo_pessoa === 'PF';
    }

    public function isPessoaJuridica()
    {
        return $this->tipo_pessoa === 'PJ';
    }

    public function isAtivo()
    {
        return $this->status === 'ativo';
    }

    public function temAcessoPortal()
    {
        return $this->acesso_portal;
    }
}
