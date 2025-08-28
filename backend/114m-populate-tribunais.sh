#!/bin/bash

# Script 114m - Popular tabela TRIBUNAIS apenas
# EXECUTE DENTRO DA PASTA: backend/

echo "Script 114m - Populando apenas tabela TRIBUNAIS..."

if [ ! -f "artisan" ]; then
    echo "Erro: Execute dentro da pasta backend/"
    exit 1
fi

echo "1. Verificando estrutura da tabela tribunais..."

php artisan tinker --execute="
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

if (Schema::hasTable('tribunais')) {
    echo 'Tabela tribunais existe\n';
    \$columns = DB::select('DESCRIBE tribunais');
    echo 'Colunas:\n';
    foreach(\$columns as \$col) {
        echo '- ' . \$col->Field . ' (' . \$col->Type . ')\n';
    }
} else {
    echo 'Tabela tribunais NAO existe\n';
}
"

echo "2. Criando seeder específico para TRIBUNAIS..."

cat > database/seeders/TribunaisSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class TribunaisSeeder extends Seeder
{
    public function run(): void
    {
        // Verificar se tabela existe
        if (!Schema::hasTable('tribunais')) {
            $this->command->error('Tabela tribunais não existe');
            return;
        }

        // Limpar apenas tabela tribunais
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        DB::table('tribunais')->delete();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // Dados dos tribunais
        $tribunais = [
            // TRIBUNAIS SUPERIORES
            [
                'nome' => 'Supremo Tribunal Federal',
                'codigo' => 'STF',
                'tipo' => 'superior',
                'estado' => null,
                'ativo' => true,
                'limite_consultas_dia' => 50,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Superior Tribunal de Justiça',
                'codigo' => 'STJ',
                'tipo' => 'superior',
                'estado' => null,
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tribunal Superior do Trabalho',
                'codigo' => 'TST',
                'tipo' => 'superior',
                'estado' => null,
                'ativo' => true,
                'limite_consultas_dia' => 75,
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // TRIBUNAIS ESTADUAIS
            [
                'nome' => 'Tribunal de Justiça de São Paulo',
                'codigo' => 'TJSP',
                'tipo' => 'estadual',
                'estado' => 'SP',
                'ativo' => true,
                'limite_consultas_dia' => 200,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tribunal de Justiça do Rio de Janeiro',
                'codigo' => 'TJRJ',
                'tipo' => 'estadual',
                'estado' => 'RJ',
                'ativo' => true,
                'limite_consultas_dia' => 150,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tribunal de Justiça de Minas Gerais',
                'codigo' => 'TJMG',
                'tipo' => 'estadual',
                'estado' => 'MG',
                'ativo' => true,
                'limite_consultas_dia' => 150,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tribunal de Justiça da Bahia',
                'codigo' => 'TJBA',
                'tipo' => 'estadual',
                'estado' => 'BA',
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // TRIBUNAIS FEDERAIS
            [
                'nome' => 'Tribunal Regional Federal da 1ª Região',
                'codigo' => 'TRF1',
                'tipo' => 'federal',
                'estado' => 'DF',
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tribunal Regional Federal da 2ª Região',
                'codigo' => 'TRF2',
                'tipo' => 'federal',
                'estado' => 'RJ',
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tribunal Regional Federal da 3ª Região',
                'codigo' => 'TRF3',
                'tipo' => 'federal',
                'estado' => 'SP',
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // TRIBUNAIS DO TRABALHO
            [
                'nome' => 'Tribunal Regional do Trabalho da 2ª Região',
                'codigo' => 'TRT2',
                'tipo' => 'trabalho',
                'estado' => 'SP',
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tribunal Regional do Trabalho da 1ª Região',
                'codigo' => 'TRT1',
                'tipo' => 'trabalho',
                'estado' => 'RJ',
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // TRIBUNAIS ELEITORAIS
            [
                'nome' => 'Tribunal Regional Eleitoral de São Paulo',
                'codigo' => 'TRE-SP',
                'tipo' => 'eleitoral',
                'estado' => 'SP',
                'ativo' => true,
                'limite_consultas_dia' => 50,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        // Inserir tribunais
        foreach ($tribunais as $tribunal) {
            DB::table('tribunais')->insert($tribunal);
        }

        $this->command->info('Tribunais criados com sucesso!');
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
            TribunaisSeeder::class,
        ]);
    }
}
EOF

echo "4. Executando seeder dos tribunais..."

php artisan db:seed --force

echo "5. Verificando tribunais criados..."

php artisan tinker --execute="
use Illuminate\Support\Facades\DB;

echo 'TRIBUNAIS CRIADOS:\n';
\$tribunais = DB::table('tribunais')->select('id', 'nome', 'codigo', 'tipo', 'estado')->orderBy('tipo')->get();

foreach(\$tribunais as \$tribunal) {
    \$estado_info = \$tribunal->estado ? ' (' . \$tribunal->estado . ')' : ' (Nacional)';
    echo 'ID: ' . \$tribunal->id . ' | ' . \$tribunal->nome . ' [' . \$tribunal->codigo . '] - ' . \$tribunal->tipo . \$estado_info . '\n';
}

echo '\nTOTAL DE TRIBUNAIS: ' . DB::table('tribunais')->count() . '\n';

echo '\nPOR TIPO:\n';
\$tipos = DB::table('tribunais')->select('tipo', DB::raw('COUNT(*) as total'))->groupBy('tipo')->get();
foreach(\$tipos as \$tipo) {
    echo '- ' . \$tipo->tipo . ': ' . \$tipo->total . '\n';
}
"

echo ""
echo "SCRIPT 114M CONCLUÍDO!"
echo ""
echo "TRIBUNAIS CRIADOS:"
echo "- 3 Tribunais Superiores (STF, STJ, TST)"
echo "- 4 Tribunais Estaduais (SP, RJ, MG, BA)"
echo "- 3 Tribunais Federais (TRF1, TRF2, TRF3)"
echo "- 2 Tribunais do Trabalho (TRT1, TRT2)"
echo "- 1 Tribunal Eleitoral (TRE-SP)"
echo ""
echo "PRÓXIMO: Script 114n - Popular CONFIGURACOES"