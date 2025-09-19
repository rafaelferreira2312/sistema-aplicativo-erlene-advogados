#!/bin/bash

# Script 140.1 - Corrigir Foreign Keys da tabela Prazos
# Sistema Erlene Advogados - Correção de referências
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔧 Script 140.1 - Corrigindo Foreign Keys da tabela Prazos..."

# Verificar diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

# Verificar se a tabela prazos existe
echo "🔍 Verificando se tabela prazos existe..."
TABELA_EXISTE=$(php artisan tinker --execute="
try {
    \Schema::hasTable('prazos') ? 'true' : 'false';
} catch (Exception \$e) {
    echo 'false';
}
" 2>/dev/null | tail -n1)

if [ "$TABELA_EXISTE" != "true" ]; then
    echo "❌ Tabela prazos não encontrada!"
    exit 1
fi

echo "✅ Tabela prazos encontrada"

# 1. Criar migration para adicionar foreign keys corretas
echo "📊 Criando migration para corrigir foreign keys..."
php artisan make:migration fix_prazos_foreign_keys

# Aguardar criação e obter o nome do arquivo de migration
MIGRATION_FILE=$(ls -t database/migrations/*fix_prazos_foreign_keys.php | head -n1)

if [ -f "$MIGRATION_FILE" ]; then
    cp "$MIGRATION_FILE" "${MIGRATION_FILE}.bak.140.1"
    echo "✅ Backup da migration criado"
fi

# 2. Escrever conteúdo da migration de correção
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
        Schema::table('prazos', function (Blueprint $table) {
            // Adicionar foreign keys com nomes corretos das tabelas
            $table->foreign('client_id')
                  ->references('id')
                  ->on('clientes')
                  ->onDelete('cascade');
                  
            $table->foreign('process_id')
                  ->references('id')
                  ->on('processos')
                  ->onDelete('set null');
                  
            $table->foreign('user_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('prazos', function (Blueprint $table) {
            $table->dropForeign(['client_id']);
            $table->dropForeign(['process_id']);
            $table->dropForeign(['user_id']);
        });
    }
};
EOF

echo "✅ Migration de correção escrita!"

# 3. Executar a migration de correção
echo "🚀 Executando migration de correção..."
php artisan migrate

if [ $? -eq 0 ]; then
    echo "✅ Foreign keys adicionadas com sucesso!"
else
    echo "❌ Erro na execução da migration de correção"
    exit 1
fi

# 4. Atualizar o Model Prazo para usar os nomes corretos das tabelas
echo "📝 Atualizando Model Prazo..."

# Fazer backup do model atual
if [ -f "app/Models/Prazo.php" ]; then
    cp "app/Models/Prazo.php" "app/Models/Prazo.php.bak.140.1"
    echo "✅ Backup do model criado"
fi

cat > "app/Models/Prazo.php" << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Prazo extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     */
    protected $table = 'prazos';

    /**
     * The attributes that are mass assignable.
     */
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

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'data_vencimento' => 'date',
        'hora_vencimento' => 'datetime:H:i',
        'alerta_enviado' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];

    /**
     * Relacionamentos
     */

    /**
     * Prazo pertence a um cliente
     * CORRIGIDO: usa tabela 'clientes' ao invés de 'clients'
     */
    public function client()
    {
        return $this->belongsTo(Cliente::class, 'client_id');
    }

    /**
     * Prazo pode pertencer a um processo (opcional)
     * CORRIGIDO: usa tabela 'processos' ao invés de 'processes'
     */
    public function process()
    {
        return $this->belongsTo(Processo::class, 'process_id');
    }

    /**
     * Prazo pertence a um usuário (advogado responsável)
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Alias para manter compatibilidade
     */
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

    /**
     * Scopes para consultas específicas
     */

    /**
     * Scope para prazos pendentes
     */
    public function scopePendentes($query)
    {
        return $query->where('status', 'Pendente');
    }

    /**
     * Scope para prazos por prioridade
     */
    public function scopePorPrioridade($query, $prioridade)
    {
        return $query->where('prioridade', $prioridade);
    }

    /**
     * Scope para prazos vencendo hoje
     */
    public function scopeVencendoHoje($query)
    {
        return $query->whereDate('data_vencimento', Carbon::today());
    }

    /**
     * Scope para prazos vencendo em X dias
     */
    public function scopeVencendoEm($query, $dias)
    {
        $dataFutura = Carbon::today()->addDays($dias);
        return $query->whereDate('data_vencimento', '<=', $dataFutura)
                    ->whereDate('data_vencimento', '>=', Carbon::today());
    }

    /**
     * Scope para prazos vencidos
     */
    public function scopeVencidos($query)
    {
        return $query->whereDate('data_vencimento', '<', Carbon::today())
                    ->where('status', '!=', 'Concluído');
    }

    /**
     * Accessors e Mutators
     */

    /**
     * Calcular dias restantes até o vencimento
     */
    public function getDiasRestantesAttribute()
    {
        if ($this->status === 'Concluído') {
            return null;
        }

        $hoje = Carbon::today();
        $vencimento = Carbon::parse($this->data_vencimento);
        
        return $hoje->diffInDays($vencimento, false); // false = pode ser negativo
    }

    /**
     * Verificar se o prazo está vencido
     */
    public function getIsVencidoAttribute()
    {
        if ($this->status === 'Concluído') {
            return false;
        }
        
        return Carbon::parse($this->data_vencimento)->isPast();
    }

    /**
     * Verificar se precisa enviar alerta
     */
    public function getPrecisaAlertaAttribute()
    {
        if ($this->alerta_enviado || $this->status === 'Concluído') {
            return false;
        }

        $diasRestantes = $this->dias_restantes;
        return $diasRestantes <= $this->dias_antecedencia && $diasRestantes >= 0;
    }

    /**
     * Métodos auxiliares
     */

    /**
     * Marcar prazo como concluído
     */
    public function marcarComoConcluido()
    {
        $this->update([
            'status' => 'Concluído'
        ]);
    }

    /**
     * Marcar alerta como enviado
     */
    public function marcarAlertaEnviado()
    {
        $this->update([
            'alerta_enviado' => true
        ]);
    }

    /**
     * Obter cor da prioridade para o frontend
     */
    public function getCorPrioridadeAttribute()
    {
        return match($this->prioridade) {
            'Urgente' => 'red',
            'Alta' => 'yellow',
            'Normal' => 'blue',
            default => 'gray'
        };
    }

    /**
     * Obter cor do status para o frontend
     */
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
}
EOF

echo "✅ Model Prazo atualizado!"

# 5. Verificar se as foreign keys foram criadas corretamente
echo "🔍 Verificando foreign keys criadas..."
php artisan tinker --execute="
\$foreignKeys = \DB::select(\"
    SELECT 
        CONSTRAINT_NAME, 
        COLUMN_NAME, 
        REFERENCED_TABLE_NAME, 
        REFERENCED_COLUMN_NAME 
    FROM information_schema.KEY_COLUMN_USAGE 
    WHERE TABLE_NAME = 'prazos' 
    AND CONSTRAINT_NAME LIKE '%foreign%'
\");
foreach(\$foreignKeys as \$fk) {
    echo \$fk->CONSTRAINT_NAME . ' -> ' . \$fk->COLUMN_NAME . ' references ' . \$fk->REFERENCED_TABLE_NAME . '(' . \$fk->REFERENCED_COLUMN_NAME . ')' . PHP_EOL;
}
"

echo ""
echo "🎉 ==============================================="
echo "✅ Script 140.1 - FOREIGN KEYS CORRIGIDAS!"
echo "==============================================="
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • client_id -> clientes(id)"
echo "   • process_id -> processos(id)" 
echo "   • user_id -> users(id)"
echo ""
echo "📝 MODEL ATUALIZADO:"
echo "   • client() -> Cliente::class"
echo "   • process() -> Processo::class"
echo "   • Aliases: cliente(), processo(), advogado()"
echo ""
echo "✅ TABELA PRAZOS TOTALMENTE FUNCIONAL!"
echo ""
echo "🚀 PRÓXIMO SCRIPT: 141-create-prazo-controller.sh"
echo "   Objetivo: Criar PrazoController com CRUD completo"
echo ""
echo "⚠️  DIGITE 'continuar' PARA EXECUTAR O PRÓXIMO SCRIPT"