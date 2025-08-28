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
