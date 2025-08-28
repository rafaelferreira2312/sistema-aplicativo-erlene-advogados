<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Unidade;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class FrontendTestSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Criar unidades
        $matriz = Unidade::create([
            'nome' => 'Erlene Advogados - Matriz',
            'codigo' => 'MATRIZ',
            'endereco' => 'Rua Principal, 123 - Centro',
            'cidade' => 'São Paulo',
            'estado' => 'SP',
            'cep' => '01234-567',
            'telefone' => '(11) 3333-1111',
            'email' => 'matriz@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0001-90',
            'status' => 'ativa',
        ]);

        $filialRj = Unidade::create([
            'nome' => 'Erlene Advogados - Rio de Janeiro',
            'codigo' => 'FILIAL_RJ',
            'endereco' => 'Av. Atlântica, 456 - Copacabana',
            'cidade' => 'Rio de Janeiro',
            'estado' => 'RJ',
            'cep' => '22070-001',
            'telefone' => '(21) 3333-2222',
            'email' => 'rj@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0002-71',
            'status' => 'ativa',
        ]);

        // 2. USUÁRIOS COMPATÍVEIS COM FRONTEND

        // Admin principal (compatível com Login.js)
        User::create([
            'nome' => 'Dra. Erlene Chaves Silva',
            'email' => 'admin@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '11111111111',
            'telefone' => '(11) 99999-1111',
            'oab' => 'SP123456',
            'perfil' => 'admin_geral',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Admin RJ
        User::create([
            'nome' => 'Dr. João Silva Santos',
            'email' => 'admin.rj@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '22222222222',
            'telefone' => '(21) 98888-2222',
            'oab' => 'RJ654321',
            'perfil' => 'admin_unidade',
            'unidade_id' => $filialRj->id,
            'status' => 'ativo',
        ]);

        // Advogada
        User::create([
            'nome' => 'Dra. Maria Costa Lima',
            'email' => 'maria.advogada@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '33333333333',
            'telefone' => '(11) 97777-3333',
            'oab' => 'SP789012',
            'perfil' => 'advogado',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // CLIENTES PORTAL (compatíveis com PortalLogin.js)

        // Cliente teste do frontend (mantém compatibilidade)
        User::create([
            'nome' => 'Cliente Teste',
            'email' => 'cliente@teste.com',
            'password' => Hash::make('123456'),
            'cpf' => '12345678900', // Sem formatação no banco
            'telefone' => '(11) 96666-4444',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Outros clientes
        User::create([
            'nome' => 'Carlos Eduardo Pereira',
            'email' => 'carlos.pereira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '98765432100',
            'telefone' => '(11) 95555-5555',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Empresa (CNPJ)
        User::create([
            'nome' => 'Tech Solutions Ltda',
            'email' => 'contato@techsolutions.com',
            'password' => Hash::make('123456'),
            'cpf' => '11222333000144', // CNPJ sem formatação
            'telefone' => '(11) 92222-8888',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Cliente RJ
        User::create([
            'nome' => 'Fernanda Santos',
            'email' => 'fernanda.santos@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '78945612300',
            'telefone' => '(21) 94444-5555',
            'perfil' => 'consulta',
            'unidade_id' => $filialRj->id,
            'status' => 'ativo',
        ]);
    }
}
