#!/bin/bash

# Script 140 - Criar Model e Migration para Prazos
# Sistema Erlene Advogados - Módulo de Gestão de Prazos
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🎯 Script 140 - Criando Model e Migration para Prazos..."

# Verificar diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

# Fazer backup do arquivo de migrations se existir
echo "🔒 Verificando backups necessários..."

# 1. Criar Migration para Prazos
echo "📊 Criando migration para tabela prazos..."
php artisan make:migration create_prazos_table

# Aguardar criação e obter o nome do arquivo de migration
MIGRATION_FILE=$(ls -t database/migrations/*create_prazos_table.php | head -n1)

if [ -f "$MIGRATION_FILE" ]; then
    cp "$MIGRATION_FILE" "${MIGRATION_FILE}.bak.140"
    echo "✅ Backup da migration criado: ${MIGRATION_FILE}.bak.140"
fi

# 2. Escrever conteúdo da migration seguindo padrão do sistema
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
            
            // Relacionamentos obrigatórios
            $table->foreignId('client_id')
                  ->constrained('clients')
                  ->onDelete('cascade');
            $table->foreignId('process_id')
                  ->nullable()
                  ->constrained('processes')
                  ->onDelete('set null');
            $table->foreignId('user_id') // Advogado responsável
                  ->constrained('users')
                  ->onDelete('cascade');
            
            // Dados principais do prazo
            $table->string('descricao'); // Ex: "Petição Inicial", "Contestação"
            $table->string('tipo_prazo'); // Ex: "Petição Inicial", "Contestação", "Recurso"
            $table->date('data_vencimento');
            $table->time('hora_vencimento')->default('17:00');
            
            // Status e prioridade
            $table->enum('status', ['Pendente', 'Em Andamento', 'Concluído', 'Vencido'])
                  ->default('Pendente');
            $table->enum('prioridade', ['Normal', 'Alta', 'Urgente'])
                  ->default('Normal');
            
            // Informações adicionais
            $table->text('observacoes')->nullable();
            $table->integer('dias_antecedencia')->default(5); // Para alertas
            $table->boolean('alerta_enviado')->default(false);
            
            // Auditoria
            $table->timestamps();
            
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

echo "✅ Migration escrita com sucesso!"

# 3. Criar Model para Prazos
echo "📝 Criando Model Prazo..."

# Fazer backup do model se já existir
if [ -f "app/Models/Prazo.php" ]; then
    cp "app/Models/Prazo.php" "app/Models/Prazo.php.bak.140"
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
     */
    public function client()
    {
        return $this->belongsTo(Client::class, 'client_id');
    }

    /**
     * Prazo pode pertencer a um processo (opcional)
     */
    public function process()
    {
        return $this->belongsTo(Process::class, 'process_id');
    }

    /**
     * Prazo pertence a um usuário (advogado responsável)
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
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

echo "✅ Model Prazo criado com sucesso!"

# 4. Executar a migration
echo "🚀 Executando migration..."
php artisan migrate

# Verificar se a migration foi executada com sucesso
if [ $? -eq 0 ]; then
    echo "✅ Migration executada com sucesso!"
    echo "📊 Tabela 'prazos' criada no banco de dados"
else
    echo "❌ Erro na execução da migration"
    exit 1
fi

# 5. Verificar estrutura da tabela criada
echo "🔍 Verificando estrutura da tabela criada..."
php artisan tinker --execute="
\$table = Schema::getConnection()->select('DESCRIBE prazos');
foreach(\$table as \$column) {
    echo \$column->Field . ' - ' . \$column->Type . PHP_EOL;
}
"

echo ""
echo "🎉 ==============================================="
echo "✅ Script 140 - CONCLUÍDO COM SUCESSO!"
echo "==============================================="
echo ""
echo "📋 RESUMO DO QUE FOI CRIADO:"
echo "   • Migration: $MIGRATION_FILE"
echo "   • Model: app/Models/Prazo.php"
echo "   • Tabela: prazos (no banco de dados)"
echo ""
echo "🔗 RELACIONAMENTOS CONFIGURADOS:"
echo "   • Prazo -> Client (obrigatório)"
echo "   • Prazo -> Process (opcional)"  
echo "   • Prazo -> User (advogado responsável)"
echo ""
echo "📊 CAMPOS PRINCIPAIS:"
echo "   • descricao, tipo_prazo"
echo "   • data_vencimento, hora_vencimento"
echo "   • status (Pendente/Em Andamento/Concluído/Vencido)"
echo "   • prioridade (Normal/Alta/Urgente)"
echo "   • observacoes, dias_antecedencia"
echo ""
echo "🚀 PRÓXIMO SCRIPT: 141-create-prazo-controller.sh"
echo "   Objetivo: Criar PrazoController com CRUD completo"
echo ""
echo "⚠️  AGUARDE CONFIRMAÇÃO 'continuar' ANTES DE EXECUTAR O PRÓXIMO SCRIPT"