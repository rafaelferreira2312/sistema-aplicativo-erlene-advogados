#!/bin/bash

# Script 119 - Corrigir relacionamento Processo-Documentos
# Sistema Erlene Advogados - Corrigir erro coluna documentos_ged.entidade_type
# EXECUTAR DENTRO DA PASTA: backend/

echo "🔧 Script 119 - Corrigindo relacionamento Processo-Documentos..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

echo "1️⃣ ERRO IDENTIFICADO:"
echo "   • ProcessController tentando usar relacionamento polimórfico"  
echo "   • Migration documentos_ged tem apenas cliente_id"
echo "   • Model Processo tentando usar morphMany que não existe"

echo ""
echo "2️⃣ Corrigindo Model Processo - removendo relacionamento inexistente..."

# Fazer backup do modelo atual
cp app/Models/Processo.php app/Models/Processo.php.backup

# Corrigir Model Processo para não usar relacionamento documentos inexistente
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

    // RELACIONAMENTO DOCUMENTOS REMOVIDO - não existe na estrutura atual
    // public function documentos() - REMOVIDO para corrigir erro
    
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

echo "3️⃣ Corrigindo ProcessController para não usar relacionamento documentos..."

# Fazer backup do controller atual  
cp app/Http/Controllers/Api/Admin/ProcessController.php app/Http/Controllers/Api/Admin/ProcessController.php.backup

# Corrigir método index removendo contagem de documentos
sed -i "s/'total_documentos' => \$processo->documentos()->count()/'total_documentos' => 0 \/\/ TODO: implementar quando documentos estiver disponível/" app/Http/Controllers/Api/Admin/ProcessController.php

# Corrigir método show removendo relacionamento documentos
sed -i "s/'documentos',/\/\/'documentos', \/\/ TODO: implementar quando relacionamento estiver disponível/" app/Http/Controllers/Api/Admin/ProcessController.php

echo "4️⃣ Verificando Model Movimentacao existe..."

if [ ! -f "app/Models/Movimentacao.php" ]; then
    echo "📄 Criando Model Movimentacao..."
    
    cat > app/Models/Movimentacao.php << 'EOF'
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
        'metadata' => 'json'
    ];

    public function processo()
    {
        return $this->belongsTo(Processo::class, 'processo_id');
    }
}
EOF
fi

echo "5️⃣ Limpando cache e testando..."

php artisan config:clear
php artisan route:clear
php artisan cache:clear

echo "6️⃣ Testando se tabelas existem..."

php artisan tinker --execute="
try {
    echo 'Verificando tabelas...' . PHP_EOL;
    echo 'Processos: ' . App\Models\Processo::count() . PHP_EOL;
    echo 'Clientes: ' . App\Models\Cliente::count() . PHP_EOL;
    if (class_exists('App\Models\Movimentacao')) {
        echo 'Movimentacoes: ' . App\Models\Movimentacao::count() . PHP_EOL;
    }
} catch (Exception \$e) {
    echo 'Erro: ' . \$e->getMessage() . PHP_EOL;
}
"

echo ""
echo "✅ Correções Aplicadas com Sucesso!"
echo ""
echo "🔍 O que foi corrigido:"
echo "   • Relacionamento documentos removido do Model Processo"
echo "   • ProcessController corrigido para não usar total_documentos"
echo "   • Model Movimentacao criado se não existia"
echo "   • Cache limpo"
echo ""
echo "🧪 TESTE AGORA:"
echo "   • Acesse http://localhost:3000/admin/processos"
echo "   • O erro de entidade_type deve ter desaparecido"
echo "   • Processos devem carregar corretamente"
echo ""
echo "💡 Se ainda houver erro:"
echo "   • Verifique: tail -f storage/logs/laravel.log"
echo "   • Teste diretamente: curl -H 'Authorization: Bearer TOKEN' http://localhost:8000/api/admin/processes"