<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UnidadeSeeder extends Seeder
{
    public function run()
    {
        DB::table('unidades')->insert([
            [
                'id' => 1,
                'nome' => 'Erlene Chaves Silva Advogados - Matriz',
                'cnpj' => '12.345.678/0001-90',
                'endereco' => 'Rua Principal, 123, Centro',
                'cep' => '12345-678',
                'cidade' => 'São Paulo',
                'estado' => 'SP',
                'telefone' => '(11) 98765-4321',
                'email' => 'contato@erleneadvogados.com',
                'matriz_id' => null,
                'is_matriz' => true,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
