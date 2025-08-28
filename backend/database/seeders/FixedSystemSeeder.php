<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Unidade;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class FixedSystemSeeder extends Seeder
{
    public function run(): void
    {
        // Verificar e criar tabela unidades se não existir
        if (!Schema::hasTable('unidades')) {
            Schema::create('unidades', function ($table) {
                $table->id();
                $table->string('nome');
                $table->string('codigo')->unique();
                $table->text('endereco');
                $table->string('cidade');
                $table->string('estado', 2);
                $table->string('cep', 9);
                $table->string('telefone', 15);
                $table->string('email');
                $table->string('cnpj', 18)->unique();
                $table->enum('status', ['ativo', 'inativo'])->default('ativo');
                $table->timestamps();
            });
        }

        // Limpar dados existentes
        DB::table('users')->truncate();
        if (Schema::hasTable('unidades')) {
            DB::table('unidades')->truncate();
        }

        // 1. UNIDADES (usando DB::table para evitar problemas de Model)
        $matrizId = DB::table('unidades')->insertGetId([
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
        ]);

        $filialRjId = DB::table('unidades')->insertGetId([
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
        ]);

        $filialBhId = DB::table('unidades')->insertGetId([
            'nome' => 'Erlene Advogados - Belo Horizonte',
            'codigo' => 'FILIAL_BH',
            'endereco' => 'Rua da Liberdade, 789',
            'cidade' => 'Belo Horizonte',
            'estado' => 'MG',
            'cep' => '30112-001',
            'telefone' => '(31) 3333-3333',
            'email' => 'bh@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0003-52',
            'status' => 'ativo',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // 2. USUÁRIOS (usando DB::table para garantir compatibilidade)
        $usuarios = [
            [
                'nome' => 'Dra. Erlene Chaves Silva',
                'name' => 'Dra. Erlene Chaves Silva',
                'email' => 'admin@erlene.com',
                'password' => Hash::make('123456'),
                'cpf' => '11111111111',
                'telefone' => '(11) 99999-1111',
                'oab' => 'SP123456',
                'perfil' => 'admin_geral',
                'unidade_id' => $matrizId,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Dr. João Silva Santos',
                'name' => 'Dr. João Silva Santos',
                'email' => 'admin.rj@erlene.com',
                'password' => Hash::make('123456'),
                'cpf' => '22222222222',
                'telefone' => '(21) 98888-2222',
                'oab' => 'RJ654321',
                'perfil' => 'admin_unidade',
                'unidade_id' => $filialRjId,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Dra. Maria Costa Lima',
                'name' => 'Dra. Maria Costa Lima',
                'email' => 'maria.advogada@erlene.com',
                'password' => Hash::make('123456'),
                'cpf' => '44444444444',
                'telefone' => '(11) 97777-4444',
                'oab' => 'SP456789',
                'perfil' => 'advogado',
                'unidade_id' => $matrizId,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Cliente Teste',
                'name' => 'Cliente Teste',
                'email' => 'cliente@teste.com',
                'password' => Hash::make('123456'),
                'cpf' => '12345678900',
                'telefone' => '(11) 96666-4444',
                'perfil' => 'consulta',
                'unidade_id' => $matrizId,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Carlos Eduardo Pereira',
                'name' => 'Carlos Eduardo Pereira',
                'email' => 'carlos.pereira@cliente.com',
                'password' => Hash::make('123456'),
                'cpf' => '98765432100',
                'telefone' => '(11) 95555-5555',
                'perfil' => 'consulta',
                'unidade_id' => $matrizId,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        foreach ($usuarios as $usuario) {
            DB::table('users')->insert($usuario);
        }

        $this->command->info('Seeder executado com sucesso!');
    }
}
