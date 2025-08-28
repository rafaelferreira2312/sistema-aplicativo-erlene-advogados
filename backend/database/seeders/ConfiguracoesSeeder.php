<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ConfiguracoesSeeder extends Seeder
{
    public function run()
    {
        $configuracoes = [
            // Sistema
            ['chave' => 'sistema.nome', 'valor' => 'Sistema Erlene Advogados', 'tipo' => 'string', 'categoria' => 'sistema'],
            ['chave' => 'sistema.versao', 'valor' => '1.0.0', 'tipo' => 'string', 'categoria' => 'sistema'],
            ['chave' => 'sistema.manutencao', 'valor' => 'false', 'tipo' => 'boolean', 'categoria' => 'sistema'],
            
            // Email
            ['chave' => 'email.host', 'valor' => 'smtp.gmail.com', 'tipo' => 'string', 'categoria' => 'email'],
            ['chave' => 'email.porta', 'valor' => '587', 'tipo' => 'integer', 'categoria' => 'email'],
            
            // Integrações
            ['chave' => 'stripe.public_key', 'valor' => '', 'tipo' => 'string', 'categoria' => 'integracao'],
            ['chave' => 'mercadopago.public_key', 'valor' => '', 'tipo' => 'string', 'categoria' => 'integracao'],
            ['chave' => 'chatgpt.api_key', 'valor' => '', 'tipo' => 'string', 'categoria' => 'integracao'],
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
