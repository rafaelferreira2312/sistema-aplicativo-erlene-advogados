#!/bin/bash

# Script 09 - Criação dos Models do Backend (Laravel)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/09-create-backend-models.sh (executado da raiz do projeto)

echo "🚀 Criando Models do Backend Laravel..."

# Model Principal - User
cat > backend/app/Models/User.php << 'EOF'
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
EOF

# Model - Unidade
cat > backend/app/Models/Unidade.php << 'EOF'
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
EOF

# Model - Cliente
cat > backend/app/Models/Cliente.php << 'EOF'
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
EOF

# Model - Processo
cat > backend/app/Models/Processo.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Processo extends Model
{
    use HasFactory;

    protected $fillable = [
        'numero',
        'tribunal',
        'vara',
        'cliente_id',
        'tipo_acao',
        'status',
        'valor_causa',
        'data_distribuicao',
        'advogado_id',
        'unidade_id',
        'proximo_prazo',
        'observacoes',
        'prioridade',
        'kanban_posicao',
        'kanban_coluna_id'
    ];

    protected $casts = [
        'valor_causa' => 'decimal:2',
        'data_distribuicao' => 'date',
        'proximo_prazo' => 'date',
    ];

    // Relationships
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function advogado()
    {
        return $this->belongsTo(User::class, 'advogado_id');
    }

    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    public function atendimentos()
    {
        return $this->belongsToMany(Atendimento::class, 'atendimento_processos');
    }

    public function movimentacoes()
    {
        return $this->hasMany(Movimentacao::class);
    }

    public function kanbanCards()
    {
        return $this->hasMany(KanbanCard::class);
    }

    public function tarefas()
    {
        return $this->hasMany(Tarefa::class);
    }

    public function financeiro()
    {
        return $this->hasMany(Financeiro::class);
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->whereIn('status', ['distribuido', 'em_andamento']);
    }

    public function scopePorPrioridade($query, $prioridade)
    {
        return $query->where('prioridade', $prioridade);
    }

    public function scopeComPrazoVencendo($query, $dias = 7)
    {
        return $query->whereNotNull('proximo_prazo')
                    ->whereBetween('proximo_prazo', [now(), now()->addDays($dias)]);
    }

    // Accessors
    public function getNumeroFormatadoAttribute()
    {
        return preg_replace('/(\d{7})(\d{2})(\d{4})(\d{1})(\d{2})(\d{4})/', 
                           '$1-$2.$3.$4.$5.$6', $this->numero);
    }

    public function getStatusBadgeAttribute()
    {
        $badges = [
            'distribuido' => 'info',
            'em_andamento' => 'primary',
            'suspenso' => 'warning',
            'arquivado' => 'secondary',
            'finalizado' => 'success'
        ];

        return $badges[$this->status] ?? 'secondary';
    }
}
EOF

# Model - Atendimento
cat > backend/app/Models/Atendimento.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Atendimento extends Model
{
    use HasFactory;

    protected $fillable = [
        'cliente_id',
        'advogado_id',
        'data_hora',
        'tipo',
        'assunto',
        'descricao',
        'status',
        'duracao',
        'valor',
        'proximos_passos',
        'anexos',
        'unidade_id'
    ];

    protected $casts = [
        'data_hora' => 'datetime',
        'valor' => 'decimal:2',
        'anexos' => 'array',
    ];

    // Relationships
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function advogado()
    {
        return $this->belongsTo(User::class, 'advogado_id');
    }

    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    public function processos()
    {
        return $this->belongsToMany(Processo::class, 'atendimento_processos');
    }

    public function financeiro()
    {
        return $this->hasMany(Financeiro::class);
    }

    // Scopes
    public function scopeAgendados($query)
    {
        return $query->where('status', 'agendado');
    }

    public function scopeHoje($query)
    {
        return $query->whereDate('data_hora', today());
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    // Accessors
    public function getDuracaoFormatadaAttribute()
    {
        if (!$this->duracao) return null;
        
        $horas = intval($this->duracao / 60);
        $minutos = $this->duracao % 60;
        
        return ($horas > 0 ? $horas . 'h ' : '') . ($minutos > 0 ? $minutos . 'min' : '');
    }

    public function getStatusBadgeAttribute()
    {
        $badges = [
            'agendado' => 'info',
            'em_andamento' => 'warning',
            'concluido' => 'success',
            'cancelado' => 'danger'
        ];

        return $badges[$this->status] ?? 'secondary';
    }
}
EOF

# Model - Financeiro
cat > backend/app/Models/Financeiro.php << 'EOF'
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
EOF

# Model - DocumentoGed
cat > backend/app/Models/DocumentoGed.php << 'EOF'
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
EOF

echo "✅ Models principais criados!"
echo "📊 Progresso: 7/15 Models do backend"
echo ""
echo "⏭️  Continue executando para criar os próximos models..."