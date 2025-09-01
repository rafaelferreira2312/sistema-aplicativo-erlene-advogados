#!/bin/bash

# Script 114k - Popular tabela UNIDADES apenas
# EXECUTE DENTRO DA PASTA: backend/

echo "Script 114k - Populando apenas tabela UNIDADES..."

if [ ! -f "artisan" ]; then
    echo "Erro: Execute dentro da pasta backend/"
    exit 1
fi

echo "1. Verificando estrutura da tabela unidades..."

php artisan tinker --execute="
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

if (Schema::hasTable('unidades')) {
    echo 'Tabela unidades existe\n';
    \$columns = DB::select('DESCRIBE unidades');
    echo 'Colunas:\n';
    foreach(\$columns as \$col) {
        echo '- ' . \$col->Field . ' (' . \$col->Type . ')\n';
    }
} else {
    echo 'Tabela unidades NAO existe\n';
}
"

echo "2. Criando seeder específico para UNIDADES..."

cat > database/seeders/UnidadesSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UnidadesSeeder extends Seeder
{
    public function run(): void
    {
        // Limpar apenas tabela unidades
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        DB::table('unidades')->delete();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // Dados das unidades
        $unidades = [
            [
                'nome' => 'Erlene Advogados - Matriz',
                'codigo' => 'MATRIZ',
                'endereco' => 'Rua Principal, 123 - Centro',
                'cidade' => 'São Paulo',
                'estado' => 'SP',
                'cep' => '01234-567',
                'telefone' => '(11) 3333-1111',
                'email' => 'matriz@erleneadvogados.com.br',
                'cnpj' => '12.345.678/0001-90',
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Erlene Advogados - Rio de Janeiro',
                'codigo' => 'FILIAL_RJ',
                'endereco' => 'Av. Atlântica, 456 - Copacabana',
                'cidade' => 'Rio de Janeiro',
                'estado' => 'RJ',
                'cep' => '22070-001',
                'telefone' => '(21) 3333-2222',
                'email' => 'rj@erleneadvogados.com.br',
                'cnpj' => '12.345.678/0002-71',
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Erlene Advogados - Belo Horizonte',
                'codigo' => 'FILIAL_BH',
                'endereco' => 'Rua da Liberdade, 789 - Centro',
                'cidade' => 'Belo Horizonte',
                'estado' => 'MG',
                'cep' => '30112-001',
                'telefone' => '(31) 3333-3333',
                'email' => 'bh@erleneadvogados.com.br',
                'cnpj' => '12.345.678/0003-52',
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Erlene Advogados - Salvador',
                'codigo' => 'FILIAL_BA',
                'endereco' => 'Rua da Alegria, 456 - Pelourinho',
                'cidade' => 'Salvador',
                'estado' => 'BA',
                'cep' => '40026-010',
                'telefone' => '(71) 3333-4444',
                'email' => 'ba@erleneadvogados.com.br',
                'cnpj' => '12.345.678/0004-33',
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Erlene Advogados - Brasília',
                'codigo' => 'FILIAL_DF',
                'endereco' => 'SCS Quadra 02, Bloco C - Asa Sul',
                'cidade' => 'Brasília',
                'estado' => 'DF',
                'cep' => '70302-000',
                'telefone' => '(61) 3333-5555',
                'email' => 'df@erleneadvogados.com.br',
                'cnpj' => '12.345.678/0005-14',
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        // Inserir unidades
        foreach ($unidades as $unidade) {
            DB::table('unidades')->insert($unidade);
        }

        $this->command->info('Unidades criadas com sucesso!');
    }
}
EOF

echo "3. Atualizando DatabaseSeeder temporário..."

cat > database/seeders/DatabaseSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            UnidadesSeeder::class,
        ]);
    }
}
EOF

echo "4. Executando seeder das unidades..."

php artisan db:seed --force

echo "5. Verificando unidades criadas..."

php artisan tinker --execute="
use Illuminate\Support\Facades\DB;

echo 'UNIDADES CRIADAS:\n';
\$unidades = DB::table('unidades')->select('id', 'nome', 'codigo', 'cidade', 'status')->get();

foreach(\$unidades as \$unidade) {
    echo 'ID: ' . \$unidade->id . ' | ' . \$unidade->nome . ' [' . \$unidade->codigo . '] - ' . \$unidade->cidade . ' (' . \$unidade->status . ')\n';
}

echo '\nTOTAL DE UNIDADES: ' . DB::table('unidades')->count() . '\n';
"

echo ""
echo "SCRIPT 114K CONCLUÍDO!"
echo ""
echo "UNIDADES CRIADAS:"
echo "- Matriz: São Paulo"
echo "- Filial RJ: Rio de Janeiro"
echo "- Filial BH: Belo Horizonte"
echo "- Filial BA: Salvador"
echo "- Filial DF: Brasília"
echo ""
echo "PRÓXIMO: Script 114l - Popular USUÁRIOS"