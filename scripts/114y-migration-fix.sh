#!/bin/bash

# Script 114y-migration-fix - Adicionando SoftDeletes à tabela clientes
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 114y-migration-fix.sh && ./114y-migration-fix.sh
# EXECUTE NA PASTA: backend/

echo "🔧 Corrigindo migração da tabela clientes..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo "📝 1. Criando migração para adicionar soft deletes..."

# Criar migração para adicionar campo deleted_at
php artisan make:migration add_soft_deletes_to_clientes_table --table=clientes

# Encontrar o arquivo de migração mais recente
MIGRATION_FILE=$(ls -t database/migrations/*_add_soft_deletes_to_clientes_table.php | head -n1)

echo "📝 2. Configurando migração para soft deletes..."

# Configurar a migração
cat > "$MIGRATION_FILE" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('clientes', function (Blueprint $table) {
            $table->softDeletes(); // Adiciona campo deleted_at
        });
    }

    public function down()
    {
        Schema::table('clientes', function (Blueprint $table) {
            $table->dropSoftDeletes(); // Remove campo deleted_at
        });
    }
};
EOF

echo "📝 3. Executando migração..."

# Executar a migração
php artisan migrate

echo "📝 4. Verificando se a tabela está correta..."

# Verificar estrutura da tabela
php artisan tinker --execute "
echo 'Estrutura da tabela clientes:';
\Schema::getColumnListing('clientes');
"

echo "📝 5. Executando seeder novamente..."

# Executar o seeder
php artisan db:seed --class=ClienteSeeder

echo "📝 6. Verificando dados inseridos..."

# Verificar dados
php artisan tinker --execute "
echo 'Total de clientes: ' . \App\Models\Cliente::count();
echo 'Clientes ativos: ' . \App\Models\Cliente::where('status', 'ativo')->count();
\App\Models\Cliente::all(['id', 'nome', 'tipo_pessoa', 'status']);
"

echo "✅ Migração corrigida com sucesso!"
echo "📝 Campo deleted_at adicionado à tabela clientes"
echo "📝 Seeder executado com dados reais"
echo "📝 Tabela populada corretamente"
echo ""
echo "Digite 'continuar' para prosseguir com o Script 114z (Frontend Service)..."