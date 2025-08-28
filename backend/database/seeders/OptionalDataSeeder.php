<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class OptionalDataSeeder extends Seeder
{
    public function run(): void
    {
        // Tribunais (se tabela existir)
        if (Schema::hasTable('tribunais')) {
            DB::table('tribunais')->insert([
                [
                    'nome' => 'Tribunal de Justiça de São Paulo',
                    'codigo' => 'TJSP',
                    'tipo' => 'estadual',
                    'estado' => 'SP',
                    'ativo' => true,
                    'limite_consultas_dia' => 100,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'nome' => 'Superior Tribunal de Justiça',
                    'codigo' => 'STJ',
                    'tipo' => 'superior',
                    'estado' => null,
                    'ativo' => true,
                    'limite_consultas_dia' => 50,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);
        }

        // Kanban Colunas (se tabela existir)
        if (Schema::hasTable('kanban_colunas')) {
            $colunas = [
                ['nome' => 'A Fazer', 'ordem' => 1, 'cor' => '#6B7280', 'unidade_id' => 1],
                ['nome' => 'Em Andamento', 'ordem' => 2, 'cor' => '#3B82F6', 'unidade_id' => 1],
                ['nome' => 'Concluído', 'ordem' => 3, 'cor' => '#10B981', 'unidade_id' => 1],
            ];

            foreach ($colunas as $coluna) {
                DB::table('kanban_colunas')->insert([
                    'nome' => $coluna['nome'],
                    'ordem' => $coluna['ordem'],
                    'cor' => $coluna['cor'],
                    'unidade_id' => $coluna['unidade_id'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // Configurações (se tabela existir)
        if (Schema::hasTable('configuracoes')) {
            $configuracoes = [
                ['chave' => 'sistema.nome', 'valor' => 'Sistema Erlene Advogados', 'tipo' => 'string', 'categoria' => 'sistema'],
                ['chave' => 'sistema.versao', 'valor' => '1.0.0', 'tipo' => 'string', 'categoria' => 'sistema'],
                ['chave' => 'email.host', 'valor' => 'smtp.gmail.com', 'tipo' => 'string', 'categoria' => 'email'],
            ];

            foreach ($configuracoes as $config) {
                DB::table('configuracoes')->insert([
                    'chave' => $config['chave'],
                    'valor' => $config['valor'],
                    'tipo' => $config['tipo'],
                    'categoria' => $config['categoria'],
                    'unidade_id' => null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}
