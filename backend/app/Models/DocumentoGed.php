<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DocumentoGed extends Model
{
    use HasFactory;

    protected $table = 'documentos_ged';

    protected $fillable = [
        'cliente_id',
        'pasta',
        'nome_arquivo',
        'nome_original',
        'caminho',
        'tipo_arquivo',
        'mime_type',
        'tamanho',
        'data_upload',
        'usuario_id',
        'versao',
        'storage_type',
        'google_drive_id',
        'onedrive_id',
        'tags',
        'descricao',
        'publico',
        'hash_arquivo'
    ];

    protected $casts = [
        'data_upload' => 'datetime',
        'tags' => 'array',
        'publico' => 'boolean',
    ];

    // Relationships
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function usuario()
    {
        return $this->belongsTo(User::class);
    }

    // Scopes
    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo_arquivo', $tipo);
    }

    public function scopePublicos($query)
    {
        return $query->where('publico', true);
    }

    public function scopePorStorage($query, $storage)
    {
        return $query->where('storage_type', $storage);
    }

    // Accessors
    public function getTamanhoFormatadoAttribute()
    {
        $bytes = $this->tamanho;
        $units = ['B', 'KB', 'MB', 'GB'];
        
        for ($i = 0; $bytes > 1024; $i++) {
            $bytes /= 1024;
        }
        
        return round($bytes, 2) . ' ' . $units[$i];
    }

    public function getUrlDownloadAttribute()
    {
        return route('api.documentos.download', $this->id);
    }

    public function getIsImagemAttribute()
    {
        return in_array($this->tipo_arquivo, ['jpg', 'jpeg', 'png', 'gif', 'webp']);
    }

    public function getIsPdfAttribute()
    {
        return $this->tipo_arquivo === 'pdf';
    }
}
