<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;

class UsuariosCompleteSeeder extends Seeder
{
    public function run(): void
    {
        // Pegar IDs das unidades
        $matriz = DB::table('unidades')->where('codigo', 'MATRIZ')->first();
        $filialRj = DB::table('unidades')->where('codigo', 'FILIAL_RJ')->first();
        $filialBh = DB::table('unidades')->where('codigo', 'FILIAL_BH')->first();
        $filialBa = DB::table('unidades')->where('codigo', 'FILIAL_BA')->first();
        $filialDf = DB::table('unidades')->where('codigo', 'FILIAL_DF')->first();

        if (!$matriz) {
            $this->command->error('Unidades não encontradas. Execute primeiro o script 114k');
            return;
        }

        // Limpar tabela users
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        DB::table('users')->delete();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // Preparar dados baseados na estrutura real da tabela
        $baseUser = [
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ];

        // Adicionar campos opcionais se existirem
        $hasNome = Schema::hasColumn('users', 'nome');
        $hasCpf = Schema::hasColumn('users', 'cpf');
        $hasOab = Schema::hasColumn('users', 'oab');
        $hasTelefone = Schema::hasColumn('users', 'telefone');
        $hasPerfil = Schema::hasColumn('users', 'perfil');
        $hasUnidadeId = Schema::hasColumn('users', 'unidade_id');
        $hasStatus = Schema::hasColumn('users', 'status');

        $usuarios = [];

        // ADMIN GERAL - MATRIZ
        $user = array_merge($baseUser, [
            'name' => 'Dra. Erlene Chaves Silva',
            'email' => 'admin@erlene.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Dra. Erlene Chaves Silva';
        if ($hasCpf) $user['cpf'] = '11111111111';
        if ($hasOab) $user['oab'] = 'SP123456';
        if ($hasTelefone) $user['telefone'] = '(11) 99999-1111';
        if ($hasPerfil) $user['perfil'] = 'admin_geral';
        if ($hasUnidadeId) $user['unidade_id'] = $matriz->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // ADMIN FILIAL RJ
        $user = array_merge($baseUser, [
            'name' => 'Dr. João Silva Santos',
            'email' => 'admin.rj@erlene.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Dr. João Silva Santos';
        if ($hasCpf) $user['cpf'] = '22222222222';
        if ($hasOab) $user['oab'] = 'RJ654321';
        if ($hasTelefone) $user['telefone'] = '(21) 98888-2222';
        if ($hasPerfil) $user['perfil'] = 'admin_unidade';
        if ($hasUnidadeId) $user['unidade_id'] = $filialRj->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // ADMIN FILIAL BH
        $user = array_merge($baseUser, [
            'name' => 'Dr. Carlos Mendes Lima',
            'email' => 'admin.bh@erlene.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Dr. Carlos Mendes Lima';
        if ($hasCpf) $user['cpf'] = '33333333333';
        if ($hasOab) $user['oab'] = 'MG789012';
        if ($hasTelefone) $user['telefone'] = '(31) 97777-3333';
        if ($hasPerfil) $user['perfil'] = 'admin_unidade';
        if ($hasUnidadeId) $user['unidade_id'] = $filialBh->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // ADVOGADA MATRIZ SP
        $user = array_merge($baseUser, [
            'name' => 'Dra. Maria Costa Lima',
            'email' => 'maria.advogada@erlene.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Dra. Maria Costa Lima';
        if ($hasCpf) $user['cpf'] = '44444444444';
        if ($hasOab) $user['oab'] = 'SP456789';
        if ($hasTelefone) $user['telefone'] = '(11) 97777-4444';
        if ($hasPerfil) $user['perfil'] = 'advogado';
        if ($hasUnidadeId) $user['unidade_id'] = $matriz->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // ADVOGADO FILIAL RJ
        $user = array_merge($baseUser, [
            'name' => 'Dr. Roberto Oliveira Santos',
            'email' => 'roberto.advogado@erlene.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Dr. Roberto Oliveira Santos';
        if ($hasCpf) $user['cpf'] = '55555555555';
        if ($hasOab) $user['oab'] = 'RJ987654';
        if ($hasTelefone) $user['telefone'] = '(21) 96666-5555';
        if ($hasPerfil) $user['perfil'] = 'advogado';
        if ($hasUnidadeId) $user['unidade_id'] = $filialRj->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // CLIENTE TESTE - MATRIZ (para frontend)
        $user = array_merge($baseUser, [
            'name' => 'Cliente Teste',
            'email' => 'cliente@teste.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Cliente Teste';
        if ($hasCpf) $user['cpf'] = '12345678900';
        if ($hasTelefone) $user['telefone'] = '(11) 96666-4444';
        if ($hasPerfil) $user['perfil'] = 'consulta';
        if ($hasUnidadeId) $user['unidade_id'] = $matriz->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // CLIENTE PF - MATRIZ
        $user = array_merge($baseUser, [
            'name' => 'Carlos Eduardo Pereira',
            'email' => 'carlos.pereira@cliente.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Carlos Eduardo Pereira';
        if ($hasCpf) $user['cpf'] = '98765432100';
        if ($hasTelefone) $user['telefone'] = '(11) 95555-5555';
        if ($hasPerfil) $user['perfil'] = 'consulta';
        if ($hasUnidadeId) $user['unidade_id'] = $matriz->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // CLIENTE PJ - MATRIZ
        $user = array_merge($baseUser, [
            'name' => 'Tech Solutions Ltda',
            'email' => 'contato@techsolutions.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Tech Solutions Ltda';
        if ($hasCpf) $user['cpf'] = '11222333000144';
        if ($hasTelefone) $user['telefone'] = '(11) 92222-8888';
        if ($hasPerfil) $user['perfil'] = 'consulta';
        if ($hasUnidadeId) $user['unidade_id'] = $matriz->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // CLIENTE - FILIAL RJ
        $user = array_merge($baseUser, [
            'name' => 'Fernanda Santos Costa',
            'email' => 'fernanda.santos@cliente.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Fernanda Santos Costa';
        if ($hasCpf) $user['cpf'] = '78945612300';
        if ($hasTelefone) $user['telefone'] = '(21) 94444-5555';
        if ($hasPerfil) $user['perfil'] = 'consulta';
        if ($hasUnidadeId) $user['unidade_id'] = $filialRj->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // CLIENTE - FILIAL BH
        $user = array_merge($baseUser, [
            'name' => 'Pedro Henrique Alves',
            'email' => 'pedro.alves@cliente.com',
            'password' => Hash::make('123456'),
        ]);
        if ($hasNome) $user['nome'] = 'Pedro Henrique Alves';
        if ($hasCpf) $user['cpf'] = '65478932100';
        if ($hasTelefone) $user['telefone'] = '(31) 93333-6666';
        if ($hasPerfil) $user['perfil'] = 'consulta';
        if ($hasUnidadeId) $user['unidade_id'] = $filialBh->id;
        if ($hasStatus) $user['status'] = 'ativo';
        $usuarios[] = $user;

        // Inserir todos os usuários
        foreach ($usuarios as $usuario) {
            DB::table('users')->insert($usuario);
        }

        $this->command->info('Usuários criados com sucesso!');
    }
}
