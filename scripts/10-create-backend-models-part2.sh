#!/bin/bash

# Script 10 - Criação dos Models do Backend (Parte 2)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/10-create-backend-models-part2.sh (executado da raiz do projeto)

echo "🚀 Continuando criação dos Models do Backend (Parte 2)..."

# Model - KanbanColuna
cat > backend/app/Models/KanbanColuna.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KanbanColuna extends Model
{
    use HasFactory;

    protected $table = 'kanban_colunas';

    protected $fillable = [
        'nome',
        'ordem',
        'cor',
        'unidade_id'
    ];

    // Relationships
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    public function cards()
    {
        return $this->hasMany(KanbanCard::class, 'coluna_id');
    }

    // Scopes
    public function scopeOrdenadas($query)
    {
        return $query->orderBy('ordem');
    }

    public function scopePorUnidade($query, $unidadeId)
    {
        return $query->where('unidade_id', $unidadeId);
    }

    // Accessors
    public function getTotalCardsAttribute()
    {
        return $this->cards()->count();
    }

    public function getCorComOpacidadeAttribute()
    {
        return $this->cor . '20'; // Adiciona opacidade
    }
}
EOF

# Model - KanbanCard
cat > backend/app/Models/KanbanCard.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KanbanCard extends Model
{
    use HasFactory;

    protected $table = 'kanban_cards';

    protected $fillable = [
        'titulo',
        'descricao',
        'coluna_id',
        'processo_id',
        'tarefa_id',
        'posicao',
        'prioridade',
        'prazo',
        'responsavel_id'
    ];

    protected $casts = [
        'prazo' => 'date',
    ];

    // Relationships
    public function coluna()
    {
        return $this->belongsTo(KanbanColuna::class, 'coluna_id');
    }

    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    public function tarefa()
    {
        return $this->belongsTo(Tarefa::class);
    }

    public function responsavel()
    {
        return $this->belongsTo(User::class, 'responsavel_id');
    }

    // Scopes
    public function scopeOrdenados($query)
    {
        return $query->orderBy('posicao');
    }

    public function scopePorPrioridade($query, $prioridade)
    {
        return $query->where('prioridade', $prioridade);
    }

    public function scopeComPrazoVencendo($query, $dias = 3)
    {
        return $query->whereNotNull('prazo')
                    ->whereBetween('prazo', [now(), now()->addDays($dias)]);
    }

    // Accessors
    public function getPrioridadeBadgeAttribute()
    {
        $badges = [
            'baixa' => 'success',
            'media' => 'info',
            'alta' => 'warning',
            'urgente' => 'danger'
        ];

        return $badges[$this->prioridade] ?? 'secondary';
    }

    public function getDiasPrazoAttribute()
    {
        if (!$this->prazo) return null;
        
        return $this->prazo->diffInDays(now(), false);
    }
}
EOF

# Model - Tarefa
cat > backend/app/Models/Tarefa.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tarefa extends Model
{
    use HasFactory;

    protected $fillable = [
        'titulo',
        'descricao',
        'tipo',
        'status',
        'prazo',
        'responsavel_id',
        'cliente_id',
        'processo_id',
        'kanban_posicao'
    ];

    protected $casts = [
        'prazo' => 'datetime',
    ];

    // Relationships
    public function responsavel()
    {
        return $this->belongsTo(User::class, 'responsavel_id');
    }

    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    public function kanbanCards()
    {
        return $this->hasMany(KanbanCard::class);
    }

    // Scopes
    public function scopePendentes($query)
    {
        return $query->where('status', 'pendente');
    }

    public function scopeVencidas($query)
    {
        return $query->where('status', 'pendente')
                    ->where('prazo', '<', now());
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    public function scopePorResponsavel($query, $responsavelId)
    {
        return $query->where('responsavel_id', $responsavelId);
    }

    // Accessors
    public function getStatusBadgeAttribute()
    {
        $badges = [
            'pendente' => 'warning',
            'em_andamento' => 'info',
            'concluida' => 'success',
            'cancelada' => 'danger'
        ];

        return $badges[$this->status] ?? 'secondary';
    }

    public function getTempoRestanteAttribute()
    {
        if (!$this->prazo || $this->status !== 'pendente') return null;
        
        return $this->prazo->diffForHumans();
    }
}
EOF

# Model - Movimentacao
cat > backend/app/Models/Movimentacao.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Movimentacao extends Model
{
    use HasFactory;

    protected $table = 'movimentacoes';

    protected $fillable = [
        'processo_id',
        'data',
        'descricao',
        'tipo',
        'documento_url',
        'metadata'
    ];

    protected $casts = [
        'data' => 'datetime',
        'metadata' => 'array',
    ];

    // Relationships
    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    // Scopes
    public function scopeRecentes($query, $dias = 30)
    {
        return $query->where('data', '>=', now()->subDays($dias));
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    public function scopeComDocumento($query)
    {
        return $query->whereNotNull('documento_url');
    }

    // Accessors
    public function getTipoBadgeAttribute()
    {
        $badges = [
            'automatica' => 'info',
            'manual' => 'primary',
            'tribunal' => 'success'
        ];

        return $badges[$this->tipo] ?? 'secondary';
    }

    public function getTemDocumentoAttribute()
    {
        return !empty($this->documento_url);
    }
}
EOF

# Model - Tribunal
cat > backend/app/Models/Tribunal.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tribunal extends Model
{
    use HasFactory;

    protected $table = 'tribunais';

    protected $fillable = [
        'nome',
        'codigo',
        'url_consulta',
        'tipo',
        'estado',
        'config_api',
        'ativo',
        'limite_consultas_dia'
    ];

    protected $casts = [
        'config_api' => 'array',
        'ativo' => 'boolean',
    ];

    // Relationships
    public function processos()
    {
        return $this->hasMany(Processo::class, 'tribunal', 'codigo');
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->where('ativo', true);
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    public function scopePorEstado($query, $estado)
    {
        return $query->where('estado', $estado);
    }

    // Accessors
    public function getTipoBadgeAttribute()
    {
        $badges = [
            'estadual' => 'primary',
            'federal' => 'info',
            'trabalhista' => 'warning',
            'superior' => 'success'
        ];

        return $badges[$this->tipo] ?? 'secondary';
    }

    public function getNomeCompletoAttribute()
    {
        return $this->nome . ' (' . $this->codigo . ')';
    }
}
EOF

# Model - PagamentoStripe
cat > backend/app/Models/PagamentoStripe.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PagamentoStripe extends Model
{
    use HasFactory;

    protected $table = 'pagamentos_stripe';

    protected $fillable = [
        'cliente_id',
        'processo_id',
        'atendimento_id',
        'financeiro_id',
        'valor',
        'moeda',
        'status',
        'stripe_payment_intent_id',
        'stripe_customer_id',
        'stripe_charge_id',
        'stripe_metadata',
        'data_criacao',
        'data_pagamento',
        'taxa_stripe',
        'observacoes'
    ];

    protected $casts = [
        'valor' => 'decimal:2',
        'taxa_stripe' => 'decimal:2',
        'stripe_metadata' => 'array',
        'data_criacao' => 'datetime',
        'data_pagamento' => 'datetime',
    ];

    // Relationships
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    public function atendimento()
    {
        return $this->belongsTo(Atendimento::class);
    }

    public function financeiro()
    {
        return $this->belongsTo(Financeiro::class);
    }

    // Scopes
    public function scopeSucesso($query)
    {
        return $query->where('status', 'succeeded');
    }

    public function scopePendentes($query)
    {
        return $query->whereIn('status', ['pending', 'processing']);
    }

    public function scopePorMoeda($query, $moeda)
    {
        return $query->where('moeda', $moeda);
    }

    // Accessors
    public function getStatusBadgeAttribute()
    {
        $badges = [
            'pending' => 'warning',
            'processing' => 'info',
            'succeeded' => 'success',
            'failed' => 'danger',
            'canceled' => 'secondary',
            'refunded' => 'dark'
        ];

        return $badges[$this->status] ?? 'secondary';
    }

    public function getValorLiquidoAttribute()
    {
        return $this->valor - ($this->taxa_stripe ?? 0);
    }
}
EOF

# Model - PagamentoMercadoPago
cat > backend/app/Models/PagamentoMercadoPago.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PagamentoMercadoPago extends Model
{
    use HasFactory;

    protected $table = 'pagamentos_mp';

    protected $fillable = [
        'cliente_id',
        'processo_id',
        'atendimento_id',
        'financeiro_id',
        'valor',
        'tipo',
        'status',
        'mp_payment_id',
        'mp_preference_id',
        'mp_external_reference',
        'mp_metadata',
        'data_criacao',
        'data_pagamento',
        'data_vencimento',
        'taxa_mp',
        'linha_digitavel',
        'qr_code',
        'observacoes'
    ];

    protected $casts = [
        'valor' => 'decimal:2',
        'taxa_mp' => 'decimal:2',
        'mp_metadata' => 'array',
        'data_criacao' => 'datetime',
        'data_pagamento' => 'datetime',
        'data_vencimento' => 'datetime',
    ];

    // Relationships
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    public function atendimento()
    {
        return $this->belongsTo(Atendimento::class);
    }

    public function financeiro()
    {
        return $this->belongsTo(Financeiro::class);
    }

    // Scopes
    public function scopeAprovados($query)
    {
        return $query->where('status', 'approved');
    }

    public function scopePendentes($query)
    {
        return $query->whereIn('status', ['pending', 'in_process']);
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    public function scopeBoletos($query)
    {
        return $query->where('tipo', 'boleto');
    }

    public function scopePix($query)
    {
        return $query->where('tipo', 'pix');
    }

    // Accessors
    public function getStatusBadgeAttribute()
    {
        $badges = [
            'pending' => 'warning',
            'approved' => 'success',
            'authorized' => 'info',
            'in_process' => 'info',
            'in_mediation' => 'warning',
            'rejected' => 'danger',
            'cancelled' => 'secondary',
            'refunded' => 'dark',
            'charged_back' => 'danger'
        ];

        return $badges[$this->status] ?? 'secondary';
    }

    public function getTipoBadgeAttribute()
    {
        $badges = [
            'pix' => 'success',
            'boleto' => 'info',
            'cartao_credito' => 'primary',
            'cartao_debito' => 'warning'
        ];

        return $badges[$this->tipo] ?? 'secondary';
    }

    public function getValorLiquidoAttribute()
    {
        return $this->valor - ($this->taxa_mp ?? 0);
    }
}
EOF

# Model - Mensagem
cat > backend/app/Models/Mensagem.php << 'EOF'
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
EOF

echo "✅ Models 8-15 criados com sucesso!"
echo "📊 Progresso: 15/15 Models do backend completos!"
echo ""
echo "🎉 Todos os Models do Backend criados:"
echo "   • User, Unidade, Cliente, Processo, Atendimento"
echo "   • Financeiro, DocumentoGed, KanbanColuna, KanbanCard"
echo "   • Tarefa, Movimentacao, Tribunal"
echo "   • PagamentoStripe, PagamentoMercadoPago, Mensagem"
echo ""
echo "⏭️  Próximo: Execute o script de criação dos Controllers"