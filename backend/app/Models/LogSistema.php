<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class LogSistema extends Model
{
    protected $table = 'logs_sistema';
    
    protected $fillable = [
        'nivel',
        'categoria',
        'mensagem', 
        'contexto',
        'usuario_id',
        'cliente_id',
        'ip',
        'user_agent',
        'request_id',
        'data_hora'
    ];

    protected $casts = [
        'contexto' => 'array',
        'data_hora' => 'datetime'
    ];

    // Relacionamentos
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    public function cliente(): BelongsTo
    {
        return $this->belongsTo(Cliente::class, 'cliente_id');
    }

    // Métodos estáticos para facilitar uso
    public static function info($categoria, $mensagem, $contexto = [], $usuarioId = null, $clienteId = null)
    {
        return self::criarLog('info', $categoria, $mensagem, $contexto, $usuarioId, $clienteId);
    }

    public static function warning($categoria, $mensagem, $contexto = [], $usuarioId = null, $clienteId = null)
    {
        return self::criarLog('warning', $categoria, $mensagem, $contexto, $usuarioId, $clienteId);
    }

    public static function error($categoria, $mensagem, $contexto = [], $usuarioId = null, $clienteId = null)
    {
        return self::criarLog('error', $categoria, $mensagem, $contexto, $usuarioId, $clienteId);
    }

    public static function debug($categoria, $mensagem, $contexto = [], $usuarioId = null, $clienteId = null)
    {
        return self::criarLog('debug', $categoria, $mensagem, $contexto, $usuarioId, $clienteId);
    }

    private static function criarLog($nivel, $categoria, $mensagem, $contexto, $usuarioId, $clienteId)
    {
        try {
            $request = request();
            
            return self::create([
                'nivel' => $nivel,
                'categoria' => $categoria,
                'mensagem' => $mensagem,
                'contexto' => $contexto,
                'usuario_id' => $usuarioId ?: (auth()->check() ? auth()->id() : null),
                'cliente_id' => $clienteId,
                'ip' => $request ? $request->ip() : null,
                'user_agent' => $request ? $request->userAgent() : null,
                'request_id' => $request ? $request->header('X-Request-ID', uniqid()) : null,
                'data_hora' => now()
            ]);
        } catch (\Exception $e) {
            // Log no arquivo se falhar no banco
            \Log::error('Erro ao criar log no banco', [
                'error' => $e->getMessage(),
                'nivel' => $nivel,
                'categoria' => $categoria,
                'mensagem' => $mensagem
            ]);
            return null;
        }
    }

    // Scopes úteis
    public function scopeUsuario($query, $usuarioId)
    {
        return $query->where('usuario_id', $usuarioId);
    }

    public function scopeCategoria($query, $categoria)
    {
        return $query->where('categoria', $categoria);
    }

    public function scopeNivel($query, $nivel)
    {
        return $query->where('nivel', $nivel);
    }

    public function scopePeriodo($query, $inicio, $fim)
    {
        return $query->whereBetween('data_hora', [$inicio, $fim]);
    }

    public function scopeHoje($query)
    {
        return $query->whereDate('data_hora', today());
    }
}
