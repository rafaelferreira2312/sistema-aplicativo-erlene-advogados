<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TribunalSeeder extends Seeder
{
    public function run()
    {
        $tribunais = [
            ['nome' => 'Tribunal de Justiça de São Paulo', 'codigo' => 'TJSP', 'tipo' => 'estadual', 'estado' => 'SP'],
            ['nome' => 'Tribunal de Justiça do Rio de Janeiro', 'codigo' => 'TJRJ', 'tipo' => 'estadual', 'estado' => 'RJ'],
            ['nome' => 'Tribunal Regional Federal da 3ª Região', 'codigo' => 'TRF3', 'tipo' => 'federal', 'estado' => 'SP'],
            ['nome' => 'Tribunal Superior do Trabalho', 'codigo' => 'TST', 'tipo' => 'superior', 'estado' => null],
            ['nome' => 'Superior Tribunal de Justiça', 'codigo' => 'STJ', 'tipo' => 'superior', 'estado' => null],
            ['nome' => 'Supremo Tribunal Federal', 'codigo' => 'STF', 'tipo' => 'superior', 'estado' => null],
        ];

        foreach ($tribunais as $tribunal) {
            DB::table('tribunais')->insert([
                'nome' => $tribunal['nome'],
                'codigo' => $tribunal['codigo'],
                'tipo' => $tribunal['tipo'],
                'estado' => $tribunal['estado'],
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
