<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run()
    {
        DB::table('users')->insert([
            [
                'nome' => 'Dra. Erlene Chaves Silva',
                'email' => 'erlene@erleneadvogados.com',
                'password' => Hash::make('erlene2024@admin'),
                'cpf' => '123.456.789-00',
                'oab' => 'SP123456',
                'telefone' => '(11) 98765-4321',
                'perfil' => 'admin_geral',
                'unidade_id' => 1,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Administrador Sistema',
                'email' => 'admin@erleneadvogados.com',
                'password' => Hash::make('admin123@erlene'),
                'cpf' => '987.654.321-00',
                'telefone' => '(11) 98765-4322',
                'perfil' => 'admin_geral',
                'unidade_id' => 1,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
