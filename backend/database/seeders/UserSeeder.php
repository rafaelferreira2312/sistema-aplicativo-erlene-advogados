<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Admin Geral (Sistema todo)
        User::create([
            'nome' => 'Dra. Erlene Chaves Silva',
            'email' => 'admin@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '111.111.111-11',
            'telefone' => '(11) 99999-1111',
            'perfil' => 'admin_geral',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        // 2. Advogados - Matriz
        User::create([
            'nome' => 'Dr. João Silva Santos',
            'email' => 'joao.advogado@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '222.222.222-22',
            'oab' => 'SP123456',
            'telefone' => '(11) 98888-2222',
            'perfil' => 'advogado',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        // 3. Advogados - Filial RJ
        User::create([
            'nome' => 'Dra. Maria Costa Lima',
            'email' => 'maria.advogada@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '333.333.333-33',
            'oab' => 'RJ654321',
            'telefone' => '(21) 97777-3333',
            'perfil' => 'advogado',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);

        // 4. Clientes PF - Matriz
        User::create([
            'nome' => 'Carlos Eduardo Pereira',
            'email' => 'carlos.pereira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '123.456.789-00',
            'telefone' => '(11) 96666-4444',
            'perfil' => 'consulta',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Ana Paula Ferreira',
            'email' => 'ana.ferreira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '987.654.321-00',
            'telefone' => '(11) 95555-5555',
            'perfil' => 'consulta',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        // 5. Clientes PF - Filial RJ
        User::create([
            'nome' => 'Roberto Silva Oliveira',
            'email' => 'roberto.oliveira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '456.789.123-00',
            'telefone' => '(21) 94444-6666',
            'perfil' => 'consulta',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Fernanda Costa Santos',
            'email' => 'fernanda.santos@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '789.123.456-00',
            'telefone' => '(21) 93333-7777',
            'perfil' => 'consulta',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);

        // 6. Clientes PJ - Matriz
        User::create([
            'nome' => 'Tech Solutions Ltda',
            'email' => 'contato@techsolutions.com',
            'password' => Hash::make('123456'),
            'cpf' => '11.222.333/0001-44', // CNPJ como CPF por compatibilidade
            'telefone' => '(11) 92222-8888',
            'perfil' => 'consulta',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Comércio ABC S/A',
            'email' => 'juridico@comercioabc.com',
            'password' => Hash::make('123456'),
            'cpf' => '22.333.444/0001-55', // CNPJ como CPF por compatibilidade
            'telefone' => '(11) 91111-9999',
            'perfil' => 'consulta',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        // 7. Clientes PJ - Filial RJ
        User::create([
            'nome' => 'Construtora Rio Ltda',
            'email' => 'contato@construtoraRio.com',
            'password' => Hash::make('123456'),
            'cpf' => '33.444.555/0001-66', // CNPJ como CPJ por compatibilidade
            'telefone' => '(21) 90000-1111',
            'perfil' => 'consulta',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Logística Express EIRELI',
            'email' => 'admin@logisticaexpress.com',
            'password' => Hash::make('123456'),
            'cpf' => '44.555.666/0001-77', // CNPJ como CPF por compatibilidade
            'telefone' => '(21) 98888-2222',
            'perfil' => 'consulta',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);
    }
}
