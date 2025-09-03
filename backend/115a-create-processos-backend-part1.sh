#!/bin/bash

# Script 115a - Criar Backend PROCESSOS - Parte 1 (Models e Migration)
# Sistema Erlene Advogados - Implementação funcionalidade PROCESSOS
# Execução: chmod +x 115a-create-processos-backend-part1.sh && ./115a-create-processos-backend-part1.sh
# EXECUTAR DENTRO DA PASTA: backend/

echo "🚀 Script 115a - Implementando Backend PROCESSOS (Parte 1)..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 115a-create-processos-backend-part1.sh && ./115a-create-processos-backend-part1.sh"
    exit 1
fi

echo "1️⃣ Verificando estrutura existente..."

# Verificar se migration de processos já existe
if [ -f "database/migrations/*_create_processos_table.php" ]; then
    echo "✅ Migration de processos já existe, continuando..."
else
    echo "📋 Criando migration de processos..."
    php artisan make:migration create_processos_table --create=processos
fi

echo "2️⃣ Atualizando Model Processo com funcionalidades CNJ..."

cat > app/Models/Processo.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Carbon\Carbon;

class Processo extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'processos';

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
        'kanban_coluna_id',
        'metadata_cnj',
        'ultima_consulta_cnj',
        'sincronizado_cnj'
    ];

    protected $casts = [
        'data_distribuicao' => 'date',
        'proximo_prazo' => 'date',
        'valor_causa' => 'decimal:2',
        'metadata_cnj' => 'json',
        'ultima_consulta_cnj' => 'datetime',
        'sincronizado_cnj' => 'boolean'
    ];

    protected $dates = [
        'created_at',
        'updated_at', 
        'deleted_at',
        'data_distribuicao',
        'proximo_prazo',
        'ultima_consulta_cnj'
    ];

    // === RELACIONAMENTOS ===
    
    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'cliente_id');
    }

    public function advogado()
    {
        return $this->belongsTo(User::class, 'advogado_id');
    }

    public function unidade()
    {
        return $this->belongsTo(Unidade::class, 'unidade_id');
    }

    public function movimentacoes()
    {
        return $this->hasMany(Movimentacao::class, 'processo_id')->orderBy('data', 'desc');
    }

    public function documentos()
    {
        return $this->morphMany(DocumentoGed::class, 'entidade');
    }

    public function atendimentos()
    {
        return $this->hasMany(Atendimento::class, 'processo_id');
    }

    public function tarefas()
    {
        return $this->hasMany(Tarefa::class, 'processo_id');
    }

    // === SCOPES ===
    
    public function scopeAtivos($query)
    {
        return $query->whereIn('status', ['distribuido', 'em_andamento']);
    }

    public function scopeComPrazoVencendo($query, $dias = 7)
    {
        return $query->whereNotNull('proximo_prazo')
                    ->where('proximo_prazo', '<=', Carbon::now()->addDays($dias))
                    ->where('proximo_prazo', '>=', Carbon::now());
    }

    public function scopeVencidos($query)
    {
        return $query->whereNotNull('proximo_prazo')
                    ->where('proximo_prazo', '<', Carbon::now());
    }

    public function scopePorUnidade($query, $unidadeId)
    {
        return $query->where('unidade_id', $unidadeId);
    }

    public function scopePorAdvogado($query, $advogadoId)
    {
        return $query->where('advogado_id', $advogadoId);
    }

    public function scopeBuscar($query, $termo)
    {
        return $query->where(function($q) use ($termo) {
            $q->where('numero', 'like', "%{$termo}%")
              ->orWhere('tipo_acao', 'like', "%{$termo}%")
              ->orWhereHas('cliente', function($clienteQuery) use ($termo) {
                  $clienteQuery->where('nome', 'like', "%{$termo}%");
              });
        });
    }

    // === ACESSORES ===
    
    public function getStatusFormatadoAttribute()
    {
        $status = [
            'distribuido' => 'Distribuído',
            'em_andamento' => 'Em Andamento',
            'suspenso' => 'Suspenso', 
            'arquivado' => 'Arquivado',
            'finalizado' => 'Finalizado'
        ];

        return $status[$this->status] ?? $this->status;
    }

    public function getPrioridadeFormatadaAttribute()
    {
        $prioridades = [
            'baixa' => 'Baixa',
            'media' => 'Média',
            'alta' => 'Alta',
            'urgente' => 'Urgente'
        ];

        return $prioridades[$this->prioridade] ?? $this->prioridade;
    }

    public function getValorCausaFormatadoAttribute()
    {
        return $this->valor_causa ? 'R$ ' . number_format($this->valor_causa, 2, ',', '.') : null;
    }

    public function getDiasAteVencimentoAttribute()
    {
        if (!$this->proximo_prazo) {
            return null;
        }

        return Carbon::now()->diffInDays($this->proximo_prazo, false);
    }

    public function getStatusPrazoAttribute()
    {
        if (!$this->proximo_prazo) {
            return 'sem_prazo';
        }

        $dias = $this->dias_ate_vencimento;

        if ($dias < 0) {
            return 'vencido';
        } elseif ($dias <= 3) {
            return 'urgente';
        } elseif ($dias <= 7) {
            return 'atencao';
        } else {
            return 'normal';
        }
    }

    public function getPrecisaSincronizarCnjAttribute()
    {
        if (!$this->sincronizado_cnj) {
            return true;
        }

        // Sincronizar se última consulta foi há mais de 24h
        if (!$this->ultima_consulta_cnj) {
            return true;
        }

        return $this->ultima_consulta_cnj->diffInHours(Carbon::now()) >= 24;
    }

    // === MÉTODOS PÚBLICOS ===
    
    public function adicionarMovimentacao($descricao, $tipo = 'manual', $documentoUrl = null, $metadata = null)
    {
        return $this->movimentacoes()->create([
            'data' => now(),
            'descricao' => $descricao,
            'tipo' => $tipo,
            'documento_url' => $documentoUrl,
            'metadata' => $metadata
        ]);
    }

    public function atualizarStatusPorMovimentacao($novaMovimentacao)
    {
        // Lógica para atualizar status baseado em movimentações
        $descricao = strtolower($novaMovimentacao);
        
        if (str_contains($descricao, 'arquivado')) {
            $this->status = 'arquivado';
        } elseif (str_contains($descricao, 'suspenso')) {
            $this->status = 'suspenso'; 
        } elseif (str_contains($descricao, 'sentença')) {
            $this->status = 'finalizado';
        } elseif ($this->status === 'distribuido') {
            $this->status = 'em_andamento';
        }

        $this->save();
    }

    public function marcarComoSincronizado($metadataCnj = null)
    {
        $this->sincronizado_cnj = true;
        $this->ultima_consulta_cnj = now();
        
        if ($metadataCnj) {
            $this->metadata_cnj = array_merge($this->metadata_cnj ?? [], $metadataCnj);
        }

        $this->save();
    }
}
EOF

echo "3️⃣ Atualizando migration para adicionar campos CNJ..."

# Encontrar o arquivo de migration mais recente de processos
MIGRATION_FILE=$(find database/migrations -name "*create_processos_table.php" | head -1)

if [ -n "$MIGRATION_FILE" ]; then
    echo "📝 Atualizando migration: $MIGRATION_FILE"
    
cat > "$MIGRATION_FILE" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('processos', function (Blueprint $table) {
            $table->id();
            $table->string('numero', 25)->unique();
            $table->string('tribunal');
            $table->string('vara')->nullable();
            $table->unsignedBigInteger('cliente_id');
            $table->string('tipo_acao');
            $table->enum('status', [
                'distribuido',
                'em_andamento', 
                'suspenso',
                'arquivado',
                'finalizado'
            ])->default('distribuido');
            $table->decimal('valor_causa', 15, 2)->nullable();
            $table->date('data_distribuicao');
            $table->unsignedBigInteger('advogado_id');
            $table->unsignedBigInteger('unidade_id');
            $table->date('proximo_prazo')->nullable();
            $table->text('observacoes')->nullable();
            $table->enum('prioridade', ['baixa', 'media', 'alta', 'urgente'])->default('media');
            $table->integer('kanban_posicao')->default(0);
            $table->unsignedBigInteger('kanban_coluna_id')->nullable();
            
            // Campos para integração CNJ DataJud
            $table->json('metadata_cnj')->nullable();
            $table->timestamp('ultima_consulta_cnj')->nullable();
            $table->boolean('sincronizado_cnj')->default(false);
            
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('advogado_id')->references('id')->on('users');
            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['numero']);
            $table->index(['status', 'prioridade']);
            $table->index(['cliente_id', 'advogado_id']);
            $table->index(['proximo_prazo']);
            $table->index(['sincronizado_cnj', 'ultima_consulta_cnj']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('processos');
    }
};
EOF
else
    echo "⚠️ Migration de processos não encontrada, criando nova..."
    php artisan make:migration add_cnj_fields_to_processos_table --table=processos
fi

echo "✅ Parte 1 concluída com sucesso!"
echo ""
echo "📋 O que foi implementado:"
echo "   • Model Processo atualizado com funcionalidades CNJ"
echo "   • Métodos para sincronização automática"
echo "   • Scopes para filtros avançados"
echo "   • Acessores para formatação de dados"
echo "   • Migration atualizada com campos CNJ"
echo ""
echo "⏭️ Próximo passo: Executar Parte 2 (Controller e Service CNJ)"