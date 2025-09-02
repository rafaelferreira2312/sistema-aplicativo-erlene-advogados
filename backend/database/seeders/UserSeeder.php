<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run()
    {
        // Admin Geral - Dra. Erlene  
        User::firstOrCreate([
            'email' => 'admin@erlene.com'
        ], [
            'name' => 'Dra. Erlene Chaves Silva',  // CORRIGIDO: 'name' em vez de 'nome'
            'password' => Hash::make('123456'),
            'cpf' => '111.111.111-11',
            'telefone' => '(11) 99999-1111', 
            'perfil' => 'admin_geral', 
            'unidade_id' => 1,
            'status' => 'ativo',
            'oab' => 'SP123456'
        ]);
        
        // Advogado
        User::firstOrCreate([
            'email' => 'advogado@erlene.com'
        ], [
            'name' => 'Dr. João Silva Advogado',  // CORRIGIDO: 'name' em vez de 'nome'
            'password' => Hash::make('123456'),
            'cpf' => '222.222.222-22',
            'telefone' => '(11) 88888-8888',
            'perfil' => 'advogado',
            'unidade_id' => 1,
            'status' => 'ativo', 
            'oab' => 'SP654321'
        ]);
        
        // Admin Unidade
        User::firstOrCreate([
            'email' => 'admin.unidade@erlene.com'
        ], [
            'name' => 'Maria Admin Unidade',  // CORRIGIDO: 'name' em vez de 'nome'
            'password' => Hash::make('123456'),
            'cpf' => '333.333.333-33',
            'telefone' => '(21) 77777-7777',
            'perfil' => 'admin_unidade',
            'unidade_id' => 1,
            'status' => 'ativo',
            'oab' => 'RJ789123'
        ]);
        
        echo "UserSeeder executado com sucesso!\n";
    }
}
