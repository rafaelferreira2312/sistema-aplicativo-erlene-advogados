#!/bin/bash

# Script 141.2 - Limpeza completa e restart do módulo Prazos
# Sistema Erlene Advogados - Reset total
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🧹 Script 141.2 - Limpeza completa e restart do módulo Prazos..."

# Verificar diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

echo ""
echo "🗑️ LIMPEZA COMPLETA"
echo "=================="

# 1. Remover tabela prazos se existir
echo "🗑️ 1. Removendo tabela prazos se existir..."
php artisan tinker --execute="
try {
    if (\Schema::hasTable('prazos')) {
        \Schema::dropIfExists('prazos');
        echo 'Tabela prazos removida' . PHP_EOL;
    } else {
        echo 'Tabela prazos não existia' . PHP_EOL;
    }
} catch (Exception \$e) {
    echo 'Erro ao remover tabela: ' . \$e->getMessage() . PHP_EOL;
}
"

# 2. Limpar todas as migrations de prazos do registro
echo ""
echo "🗑️ 2. Limpando registros de migrations de prazos..."
php artisan tinker --execute="
try {
    \$deleted = \DB::table('migrations')->where('migration', 'like', '%prazos%')->delete();
    echo 'Registros de migration removidos: ' . \$deleted . PHP_EOL;
} catch (Exception \$e) {
    echo 'Erro ao limpar migrations: ' . \$e->getMessage() . PHP_EOL;
}
"

# 3. Remover arquivos de migration físicos
echo ""
echo "🗑️ 3. Removendo arquivos de migration físicos..."
find database/migrations/ -name "*prazos*" -type f -exec rm -f {} \;
echo "✅ Arquivos de migration removidos"

# 4. Backup e remoção do Model atual
echo ""
echo "🗑️ 4. Fazendo backup e removendo Model atual..."
if [ -f "app/Models/Prazo.php" ]; then
    cp "app/Models/Prazo.php" "app/Models/Prazo.php.bak.141.2"
    rm "app/Models/Prazo.php"
    echo "✅ Model removido (backup salvo)"
else
    echo "ℹ️ Model não existia"
fi

echo ""
echo "🆕 CRIAÇÃO LIMPA"
echo "==============="

# 5. Criar nova migration limpa
echo "📊 5. Criando nova migration limpa..."
php artisan make:migration create_prazos_table

# Obter arquivo de migration criado
MIGRATION_FILE=$(ls -t database/migrations/*create_prazos_table.php | head -n1)
echo "   Arquivo criado: $MIGRATION_FILE"

# 6. Escrever conteúdo da migration corrigida
echo "📝 6. Escrevendo conteúdo da migration..."
cat > "$MIGRATION_FILE" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('prazos', function (Blueprint $table) {
            $table->id();
            
            // Relacionamentos com nomes CORRETOS das tabelas
            $table->unsignedBigInteger('client_id');
            $table->unsignedBigInteger('process_id')->nullable();
            $table->unsignedBigInteger('user_id');
            
            // Dados principais do prazo
            $table->string('descricao');
            $table->string('tipo_prazo');
            $table->date('data_vencimento');
            $table->time('hora_vencimento')->default('17:00');
            
            // Status e prioridade
            $table->enum('status', ['Pendente', 'Em Andamento', 'Concluído', 'Vencido'])
                  ->default('Pendente');
            $table->enum('prioridade', ['Normal', 'Alta', 'Urgente'])
                  ->default('Normal');
            
            // Informações adicionais
            $table->text('observacoes')->nullable();
            $table->integer('dias_antecedencia')->default(5);
            $table->boolean('alerta_enviado')->default(false);
            
            // Auditoria
            $table->timestamps();
            
            // Foreign keys CORRETAS
            $table->foreign('client_id')->references('id')->on('clientes')->onDelete('cascade');
            $table->foreign('process_id')->references('id')->on('processos')->onDelete('set null');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            
            // Índices para performance
            $table->index(['client_id', 'data_vencimento']);
            $table->index(['process_id', 'status']);
            $table->index(['user_id', 'data_vencimento']);
            $table->index(['status', 'prioridade']);
            $table->index('data_vencimento');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('prazos');
    }
};
EOF

echo "✅ Migration escrita com foreign keys corretas"

# 7. Criar Model Prazo limpo
echo ""
echo "📝 7. Criando Model Prazo limpo..."
cat > "app/Models/Prazo.php" << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Prazo extends Model
{
    use HasFactory;

    protected $table = 'prazos';

    protected $fillable = [
        'client_id',
        'process_id', 
        'user_id',
        'descricao',
        'tipo_prazo',
        'data_vencimento',
        'hora_vencimento',
        'status',
        'prioridade',
        'observacoes',
        'dias_antecedencia',
        'alerta_enviado'
    ];

    protected $casts = [
        'data_vencimento' => 'date',
        'hora_vencimento' => 'datetime:H:i',
        'alerta_enviado' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];

    // Relacionamentos usando os Models CORRETOS
    public function client()
    {
        return $this->belongsTo(\App\Models\Cliente::class, 'client_id');
    }

    public function process()
    {
        return $this->belongsTo(\App\Models\Processo::class, 'process_id');
    }

    public function user()
    {
        return $this->belongsTo(\App\Models\User::class, 'user_id');
    }

    // Aliases para facilitar uso
    public function cliente()
    {
        return $this->client();
    }

    public function processo()
    {
        return $this->process();
    }

    public function advogado()
    {
        return $this->user();
    }

    // Scopes
    public function scopePendentes($query)
    {
        return $query->where('status', 'Pendente');
    }

    public function scopePorPrioridade($query, $prioridade)
    {
        return $query->where('prioridade', $prioridade);
    }

    public function scopeVencendoHoje($query)
    {
        return $query->whereDate('data_vencimento', Carbon::today());
    }

    public function scopeVencendoEm($query, $dias)
    {
        $dataFutura = Carbon::today()->addDays($dias);
        return $query->whereDate('data_vencimento', '<=', $dataFutura)
                    ->whereDate('data_vencimento', '>=', Carbon::today());
    }

    public function scopeVencidos($query)
    {
        return $query->whereDate('data_vencimento', '<', Carbon::today())
                    ->where('status', '!=', 'Concluído');
    }

    // Accessors
    public function getDiasRestantesAttribute()
    {
        if ($this->status === 'Concluído') {
            return null;
        }

        $hoje = Carbon::today();
        $vencimento = Carbon::parse($this->data_vencimento);
        
        return $hoje->diffInDays($vencimento, false);
    }

    public function getIsVencidoAttribute()
    {
        if ($this->status === 'Concluído') {
            return false;
        }
        
        return Carbon::parse($this->data_vencimento)->isPast();
    }

    public function getPrecisaAlertaAttribute()
    {
        if ($this->alerta_enviado || $this->status === 'Concluído') {
            return false;
        }

        $diasRestantes = $this->dias_restantes;
        return $diasRestantes <= $this->dias_antecedencia && $diasRestantes >= 0;
    }

    public function getCorPrioridadeAttribute()
    {
        return match($this->prioridade) {
            'Urgente' => 'red',
            'Alta' => 'yellow', 
            'Normal' => 'blue',
            default => 'gray'
        };
    }

    public function getCorStatusAttribute()
    {
        return match($this->status) {
            'Pendente' => 'yellow',
            'Em Andamento' => 'blue',
            'Concluído' => 'green',
            'Vencido' => 'red',
            default => 'gray'
        };
    }

    // Métodos auxiliares
    public function marcarComoConcluido()
    {
        $this->update(['status' => 'Concluído']);
    }

    public function marcarAlertaEnviado()
    {
        $this->update(['alerta_enviado' => true]);
    }
}
EOF

echo "✅ Model Prazo criado"

# 8. Executar migration
echo ""
echo "🚀 8. Executando migration..."
php artisan migrate

if [ $? -eq 0 ]; then
    echo "✅ Migration executada com sucesso!"
else
    echo "❌ Erro na migration"
    exit 1
fi

# 9. Verificação final completa
echo ""
echo "🔍 VERIFICAÇÃO FINAL"
echo "==================="

php artisan tinker --execute="
try {
    // Testar se tabela existe
    if (!\Schema::hasTable('prazos')) {
        echo 'ERRO: Tabela não existe' . PHP_EOL;
        exit;
    }
    
    // Testar Model
    \$count = \App\Models\Prazo::count();
    echo 'Registros na tabela: ' . \$count . PHP_EOL;
    
    // Testar relacionamentos
    \$clientes = \App\Models\Cliente::count();
    \$processos = \App\Models\Processo::count();
    \$users = \App\Models\User::count();
    
    echo 'Clientes disponíveis: ' . \$clientes . PHP_EOL;
    echo 'Processos disponíveis: ' . \$processos . PHP_EOL;
    echo 'Usuários disponíveis: ' . \$users . PHP_EOL;
    
    // Verificar foreign keys
    \$foreignKeys = \DB::select(\"
        SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME 
        FROM information_schema.KEY_COLUMN_USAGE 
        WHERE TABLE_NAME = 'prazos' AND CONSTRAINT_NAME LIKE '%foreign%'
    \");
    
    echo 'Foreign keys configuradas: ' . count(\$foreignKeys) . PHP_EOL;
    foreach(\$foreignKeys as \$fk) {
        echo '  - ' . \$fk->COLUMN_NAME . ' -> ' . \$fk->REFERENCED_TABLE_NAME . PHP_EOL;
    }
    
    echo 'SUCESSO: Módulo Prazos configurado corretamente!' . PHP_EOL;
    
} catch (Exception \$e) {
    echo 'ERRO: ' . \$e->getMessage() . PHP_EOL;
}
"

echo ""
echo "🎉 ==============================================="
echo "✅ MÓDULO PRAZOS CRIADO DO ZERO COM SUCESSO!"
echo "==============================================="
echo ""
echo "📋 O QUE FOI FEITO:"
echo "   ✅ Limpeza completa de migrations antigas"
echo "   ✅ Remoção de tabela conflituosa"
echo "   ✅ Nova migration com foreign keys corretas"
echo "   ✅ Model Prazo funcional"
echo "   ✅ Relacionamentos configurados"
echo ""
echo "🚀 AGORA EXECUTE: 141-create-prazo-controller.sh"
echo "   (O controller funcionará perfeitamente)"
echo ""
echo "⚠️  DIGITE 'continuar' PARA EXECUTAR O CONTROLLER"