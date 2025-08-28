<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UnidadeSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('unidades')->insert([
            [
                'id' => 1,
                'nome' => 'Matriz - Erlene Advogados',
                'codigo' => 'MATRIZ',
                'endereco' => 'Rua Principal, 123',
                'cidade' => 'São Paulo',
                'estado' => 'SP',
                'cep' => '01234-567',
                'telefone' => '(11) 3333-1111',
                'email' => 'matriz@erlene.com.br',
                'cnpj' => '12.345.678/0001-90',
                'status' => 'ativa',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'nome' => 'Filial Rio de Janeiro',
                'codigo' => 'FILIAL_RJ',
                'endereco' => 'Av. Atlântica, 456',
                'cidade' => 'Rio de Janeiro',
                'estado' => 'RJ',
                'cep' => '22070-001',
                'telefone' => '(21) 3333-2222',
                'email' => 'rj@erlene.com.br',
                'cnpj' => '12.345.678/0002-71',
                'status' => 'ativa',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
