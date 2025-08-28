<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class ClienteSeeder extends Seeder
{
    public function run(): void
    {
        // Clientes para login do portal (tabela separada se existir)
        // Ou usar mesmos usuários com perfil consulta
        
        $clientes = [
            [
                'nome' => 'Carlos Eduardo Pereira',
                'email' => 'carlos.pereira@cliente.com',
                'cpf_cnpj' => '123.456.789-00',
                'password' => Hash::make('123456'),
                'telefone' => '(11) 96666-4444',
                'tipo' => 'PF',
                'unidade_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tech Solutions Ltda',
                'email' => 'contato@techsolutions.com',
                'cpf_cnpj' => '11.222.333/0001-44',
                'password' => Hash::make('123456'),
                'telefone' => '(11) 92222-8888',
                'tipo' => 'PJ',
                'unidade_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ];

        // Inserir apenas se tabela clientes existir
        if (Schema::hasTable('clientes')) {
            DB::table('clientes')->insert($clientes);
        }
    }
}
