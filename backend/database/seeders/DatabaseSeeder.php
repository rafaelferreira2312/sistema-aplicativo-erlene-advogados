<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        $this->call([
            UnidadeSeeder::class,
            UserSeeder::class,
            TribunalSeeder::class,
            KanbanColunasSeeder::class,
            ConfiguracoesSeeder::class,
        ]);
    }
}
