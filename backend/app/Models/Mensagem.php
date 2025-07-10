<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mensagem extends Model
{
    use HasFactory;

    protected $table = 'mensagens';

    protected $fillable = [
        'remetente_id',
        'destinatario_id',
        'cliente_id',
        'processo_id',
        'conteudo',
        'tipo',
        'arquivo_url',
        'data_envio',
        'lida',
        'data_leitura',
        'importante'
    ];

    protected $casts = [
        'data_envio' => 'datetime',
        'data_leitura' => 'datetime',
        'lida' => 'boolean',
        'importante' => 'boolean',
    ];

    // Relationships
    public function remetente()
    {
        return $this->belongsTo(User::class, 'remetente_id');
    }

    public function destinatario()
    {
        return $this->belongsTo(User::class, 'destinatario_id');
    }

    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    // Scopes
    public function scopeNaoLidas($query)
    {
        return $query->where('lida', false);
    }

    public function scopeImportantes($query)
    {
        return $query->where('importante', true);
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    public function scopeEntre($query, $user1Id, $user2Id)
    {
        return $query->where(function($q) use ($user1Id, $user2Id) {
            $q->where('remetente_id', $user1Id)->where('destinatario_id', $user2Id);
        })->orWhere(function($q) use ($user1Id, $user2Id) {
            $q->where('remetente_id', $user2Id)->where('destinatario_id', $user1Id);
        });
    }

    // Accessors
    public function getTipoBadgeAttribute()
    {
        $badges = [
            'texto' => 'primary',
            'arquivo' => 'info',
            'imagem' => 'success',
            'audio' => 'warning',
            'video' => 'danger',
            'sistema' => 'secondary'
        ];

        return $badges[$this->tipo] ?? 'secondary';
    }

    public function getTemArquivoAttribute()
    {
        return !empty($this->arquivo_url);
    }

    public function getDataEnvioFormatadaAttribute()
    {
        return $this->data_envio->diffForHumans();
    }
}
