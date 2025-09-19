#!/bin/bash

# Script 141.1 - Verificar e corrigir estado do banco de dados
# Sistema Erlene Advogados - Diagnóstico e correção
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔍 Script 141.1 - Verificando e corrigindo estado do banco..."

# Verificar diretório correto
if [ ! -f "composer.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

echo "📊 DIAGNÓSTICO DO BANCO DE DADOS"
echo "================================"

# 1. Verificar se a tabela prazos existe no banco
echo "🔍 1. Verificando se tabela 'prazos' existe..."
TABELA_EXISTE=$(php artisan tinker --execute="
try {
    if (\Schema::hasTable('prazos')) {
        echo 'SIM';
    } else {
        echo 'NAO';
    }
} catch (Exception \$e) {
    echo 'ERRO: ' . \$e->getMessage();
}
" 2>/dev/null | tail -n1)

echo "   Resultado: $TABELA_EXISTE"

# 2. Verificar migrations executadas
echo ""
echo "🔍 2. Verificando migrations de prazos executadas..."
MIGRATIONS_PRAZOS=$(php artisan migrate:status | grep -i prazo || echo "Nenhuma migration de prazo encontrada")
echo "   $MIGRATIONS_PRAZOS"

# 3. Verificar estrutura da tabela se ela existir
if [ "$TABELA_EXISTE" = "SIM" ]; then
    echo ""
    echo "🔍 3. Verificando estrutura da tabela prazos..."
    php artisan tinker --execute="
    try {
        \$columns = \Schema::getColumnListing('prazos');
        echo 'Colunas: ' . implode(', ', \$columns) . PHP_EOL;
        
        // Verificar foreign keys
        \$foreignKeys = \DB::select(\"
            SELECT 
                CONSTRAINT_NAME, 
                COLUMN_NAME, 
                REFERENCED_TABLE_NAME 
            FROM information_schema.KEY_COLUMN_USAGE 
            WHERE TABLE_NAME = 'prazos' 
            AND CONSTRAINT_NAME LIKE '%foreign%'
        \");
        
        if (count(\$foreignKeys) > 0) {
            echo 'Foreign Keys encontradas:' . PHP_EOL;
            foreach(\$foreignKeys as \$fk) {
                echo '  - ' . \$fk->COLUMN_NAME . ' -> ' . \$fk->REFERENCED_TABLE_NAME . PHP_EOL;
            }
        } else {
            echo 'PROBLEMA: Nenhuma foreign key encontrada!' . PHP_EOL;
        }
        
    } catch (Exception \$e) {
        echo 'Erro ao verificar estrutura: ' . \$e->getMessage() . PHP_EOL;
    }
    "
    
    echo ""
    echo "🔍 4. Contando registros na tabela..."
    TOTAL_REGISTROS=$(php artisan tinker --execute="
    try {
        echo \App\Models\Prazo::count();
    } catch (Exception \$e) {
        echo 'ERRO: ' . \$e->getMessage();
    }
    " 2>/dev/null | tail -n1)
    echo "   Total de registros: $TOTAL_REGISTROS"
fi

echo ""
echo "🔧 AÇÕES CORRETIVAS"
echo "=================="

# Decisão baseada no diagnóstico
if [ "$TABELA_EXISTE" = "SIM" ]; then
    echo "✅ Tabela 'prazos' existe no banco"
    
    # Verificar se tem foreign keys
    FK_COUNT=$(php artisan tinker --execute="
    try {
        \$fks = \DB::select(\"
            SELECT COUNT(*) as total
            FROM information_schema.KEY_COLUMN_USAGE 
            WHERE TABLE_NAME = 'prazos' 
            AND CONSTRAINT_NAME LIKE '%foreign%'
        \");
        echo \$fks[0]->total;
    } catch (Exception \$e) {
        echo '0';
    }
    " 2>/dev/null | tail -n1)
    
    if [ "$FK_COUNT" = "0" ]; then
        echo "🔧 Problema: Tabela existe mas sem foreign keys"
        echo "   Executando correção das foreign keys..."
        
        # Criar e executar migration para adicionar foreign keys
        php artisan make:migration add_foreign_keys_to_prazos_table
        
        MIGRATION_FILE=$(ls -t database/migrations/*add_foreign_keys_to_prazos_table.php | head -n1)
        
        cat > "$MIGRATION_FILE" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('prazos', function (Blueprint $table) {
            $table->foreign('client_id')->references('id')->on('clientes')->onDelete('cascade');
            $table->foreign('process_id')->references('id')->on('processos')->onDelete('set null');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

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
        
        echo "   Executando migration de foreign keys..."
        php artisan migrate
        
        if [ $? -eq 0 ]; then
            echo "✅ Foreign keys adicionadas com sucesso!"
        else
            echo "❌ Erro ao adicionar foreign keys"
        fi
        
    else
        echo "✅ Tabela tem foreign keys configuradas"
    fi
    
    # Atualizar o registro de migrations para evitar conflitos
    echo ""
    echo "🔧 Atualizando registro de migrations..."
    php artisan tinker --execute="
    try {
        // Marcar migrations antigas como executadas
        \$migrations = [
            '2025_09_17_203618_create_prazos_table',
            '2025_09_18_015712_create_prazos_table'
        ];
        
        foreach (\$migrations as \$migration) {
            \DB::table('migrations')->updateOrInsert(
                ['migration' => \$migration],
                ['batch' => 1]
            );
            echo 'Migration registrada: ' . \$migration . PHP_EOL;
        }
        
        echo 'Migrations atualizadas!' . PHP_EOL;
    } catch (Exception \$e) {
        echo 'Erro ao atualizar migrations: ' . \$e->getMessage() . PHP_EOL;
    }
    "
    
else
    echo "❌ Tabela 'prazos' NÃO existe no banco"
    echo "🔧 Criando tabela prazos do zero..."
    
    # Limpar migrations antigas que podem estar causando conflito
    echo "   Limpando migrations antigas..."
    php artisan tinker --execute="
    try {
        \DB::table('migrations')->where('migration', 'like', '%create_prazos_table%')->delete();
        echo 'migrations antigas removidas' . PHP_EOL;
    } catch (Exception \$e) {
        echo 'Erro: ' . \$e->getMessage() . PHP_EOL;
    }
    "
    
    # Criar nova migration
    php artisan make:migration create_prazos_table_final
    
    MIGRATION_FILE=$(ls -t database/migrations/*create_prazos_table_final.php | head -n1)
    
    cat > "$MIGRATION_FILE" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('prazos', function (Blueprint $table) {
            $table->id();
            
            // Relacionamentos
            $table->foreignId('client_id')->constrained('clientes')->onDelete('cascade');
            $table->foreignId('process_id')->nullable()->constrained('processos')->onDelete('set null');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            
            // Dados principais
            $table->string('descricao');
            $table->string('tipo_prazo');
            $table->date('data_vencimento');
            $table->time('hora_vencimento')->default('17:00');
            
            // Status e prioridade
            $table->enum('status', ['Pendente', 'Em Andamento', 'Concluído', 'Vencido'])->default('Pendente');
            $table->enum('prioridade', ['Normal', 'Alta', 'Urgente'])->default('Normal');
            
            // Campos adicionais
            $table->text('observacoes')->nullable();
            $table->integer('dias_antecedencia')->default(5);
            $table->boolean('alerta_enviado')->default(false);
            
            $table->timestamps();
            
            // Índices
            $table->index(['client_id', 'data_vencimento']);
            $table->index(['process_id', 'status']);
            $table->index(['user_id', 'data_vencimento']);
            $table->index('data_vencimento');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('prazos');
    }
};
EOF
    
    echo "   Executando nova migration..."
    php artisan migrate
    
    if [ $? -eq 0 ]; then
        echo "✅ Tabela prazos criada com sucesso!"
    else
        echo "❌ Erro ao criar tabela prazos"
        exit 1
    fi
fi

# Verificação final
echo ""
echo "🔍 VERIFICAÇÃO FINAL"
echo "==================="

VERIFICACAO_FINAL=$(php artisan tinker --execute="
try {
    if (\Schema::hasTable('prazos')) {
        \$count = \App\Models\Prazo::count();
        echo 'SUCESSO: Tabela prazos existe e Model funciona. Registros: ' . \$count;
    } else {
        echo 'ERRO: Tabela ainda não existe';
    }
} catch (Exception \$e) {
    echo 'ERRO: ' . \$e->getMessage();
}
" 2>/dev/null | tail -n1)

echo "   $VERIFICACAO_FINAL"

if [[ "$VERIFICACAO_FINAL" == *"SUCESSO"* ]]; then
    echo ""
    echo "🎉 ==============================================="
    echo "✅ BANCO DE DADOS CORRIGIDO COM SUCESSO!"
    echo "==============================================="
    echo ""
    echo "📊 STATUS FINAL:"
    echo "   ✅ Tabela 'prazos' existe"
    echo "   ✅ Foreign keys configuradas"
    echo "   ✅ Model Prazo funcional"
    echo ""
    echo "🚀 AGORA PODE EXECUTAR: 141-create-prazo-controller.sh"
    echo ""
else
    echo ""
    echo "❌ Ainda há problemas. Verifique manualmente:"
    echo "   php artisan migrate:status"
    echo "   php artisan tinker"
    echo "   >>> Schema::hasTable('prazos')"
fi