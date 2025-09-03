<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Processo;
use App\Models\Cliente;
use App\Models\User;
use App\Models\Unidade;

class ProcessoCNJTestSeeder extends Seeder
{
    public function run()
    {
        // Buscar dados existentes
        $cliente = Cliente::first();
        $advogado = User::where('perfil', 'advogado')->first();
        $unidade = Unidade::first();

        if (!$cliente || !$advogado || !$unidade) {
            $this->command->error('❌ Necessário ter cliente, advogado e unidade cadastrados primeiro');
            return;
        }

        // Criar processo com número real da documentação CNJ
        $processo = Processo::create([
            'numero' => '0000335250184013202', // Número real da documentação CNJ
            'tribunal' => 'TRF1',
            'vara' => '13ª Vara Federal - Seção Judiciária do DF',
            'cliente_id' => $cliente->id,
            'tipo_acao' => 'Ação de Execução Fiscal',
            'status' => 'distribuido',
            'valor_causa' => 25000.00,
            'data_distribuicao' => now()->subDays(90)->format('Y-m-d'),
            'advogado_id' => $advogado->id,
            'unidade_id' => $unidade->id,
            'prioridade' => 'media',
            'observacoes' => 'Processo de teste com número real da API CNJ DataJud para validação da integração',
            'sincronizado_cnj' => false
        ]);

        $this->command->info("✅ Processo CNJ criado: ID {$processo->id} - Número {$processo->numero}");
        $this->command->info("🔄 Execute a sincronização CNJ via API para testar");
    }
}
