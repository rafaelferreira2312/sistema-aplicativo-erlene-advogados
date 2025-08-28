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
