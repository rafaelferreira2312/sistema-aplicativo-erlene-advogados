<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class KanbanColunasSeeder extends Seeder
{
    public function run()
    {
        $colunas = [
            ['nome' => 'A Fazer', 'ordem' => 1, 'cor' => '#6B7280'],
            ['nome' => 'Em Andamento', 'ordem' => 2, 'cor' => '#3B82F6'],
            ['nome' => 'Aguardando', 'ordem' => 3, 'cor' => '#F59E0B'],
            ['nome' => 'Concluído', 'ordem' => 4, 'cor' => '#10B981'],
        ];

        foreach ($colunas as $coluna) {
            DB::table('kanban_colunas')->insert([
                'nome' => $coluna['nome'],
                'ordem' => $coluna['ordem'],
                'cor' => $coluna['cor'],
                'unidade_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
