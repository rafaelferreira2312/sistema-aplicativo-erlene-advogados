<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Audiencia;
use App\Models\Processo;
use App\Models\Cliente;
use App\Models\User;
use App\Models\Unidade;
use Carbon\Carbon;

class AudienciasSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Buscar dados necessários para os relacionamentos
        $processos = Processo::all();
        $clientes = Cliente::all();
        $users = User::where('perfil', 'advogado')->get();
        $unidades = Unidade::all();

        // Se não houver dados suficientes, criar dados mínimos
        if ($processos->isEmpty()) {
            echo "⚠️ Nenhum processo encontrado. Execute o seeder de processos primeiro.\n";
            return;
        }

        if ($clientes->isEmpty()) {
            echo "⚠️ Nenhum cliente encontrado. Execute o seeder de clientes primeiro.\n";
            return;
        }

        if ($users->isEmpty()) {
            $users = User::all(); // Pegar qualquer usuário se não houver advogados
        }

        if ($unidades->isEmpty()) {
            echo "⚠️ Nenhuma unidade encontrada. Execute o seeder de unidades primeiro.\n";
            return;
        }

        // Limpar audiências existentes
        Audiencia::truncate();

        echo "📋 Criando audiências de teste...\n";

        // Audiência 1 - HOJE, Confirmada (aparece no dashboard como "Hoje")
        Audiencia::create([
            'processo_id' => $processos->first()->id,
            'cliente_id' => $clientes->first()->id,
            'advogado_id' => $users->first()->id,
            'unidade_id' => $unidades->first()->id,
            'tipo' => 'conciliacao',
            'data' => Carbon::today(), // HOJE
            'hora' => '09:00',
            'local' => 'TJSP - 1ª Vara Cível',
            'endereco' => 'Rua da Consolação, 1234 - Centro, São Paulo - SP',
            'sala' => 'Sala 101',
            'advogado' => 'Dr. Carlos Oliveira',
            'juiz' => 'Dr. José Silva',
            'status' => 'confirmada',
            'observacoes' => 'Levar documentos originais. Cliente confirmou presença.',
            'lembrete' => true,
            'horas_lembrete' => 2
        ]);

        // Audiência 2 - HOJE, mais tarde (aparece como "Próximas 2h" se for dentro de 2h)
        Audiencia::create([
            'processo_id' => $processos->count() > 1 ? $processos->skip(1)->first()->id : $processos->first()->id,
            'cliente_id' => $clientes->count() > 1 ? $clientes->skip(1)->first()->id : $clientes->first()->id,
            'advogado_id' => $users->count() > 1 ? $users->skip(1)->first()->id : $users->first()->id,
            'unidade_id' => $unidades->first()->id,
            'tipo' => 'instrucao',
            'data' => Carbon::today(), // HOJE
            'hora' => '14:30',
            'local' => 'TJSP - 2ª Vara Empresarial',
            'endereco' => 'Rua Líbero Badaró, 567 - Centro, São Paulo - SP',
            'sala' => 'Sala 205',
            'advogado' => 'Dra. Maria Santos',
            'juiz' => 'Dra. Ana Costa',
            'status' => 'agendada',
            'observacoes' => 'Primeira audiência de instrução. Preparar testemunhas.',
            'lembrete' => true,
            'horas_lembrete' => 1
        ]);

        // Audiência 3 - AMANHÃ, Agendada
        Audiencia::create([
            'processo_id' => $processos->count() > 2 ? $processos->skip(2)->first()->id : $processos->first()->id,
            'cliente_id' => $clientes->count() > 2 ? $clientes->skip(2)->first()->id : $clientes->first()->id,
            'advogado_id' => $users->first()->id,
            'unidade_id' => $unidades->first()->id,
            'tipo' => 'preliminar',
            'data' => Carbon::tomorrow(), // AMANHÃ
            'hora' => '10:00',
            'local' => 'TJSP - 3ª Vara Família',
            'endereco' => 'Av. Paulista, 1000 - Bela Vista, São Paulo - SP',
            'sala' => 'Sala 302',
            'advogado' => 'Dr. Pedro Costa',
            'juiz' => 'Dr. Roberto Lima',
            'status' => 'agendada',
            'observacoes' => 'Audiência preliminar. Tentar acordo.',
            'lembrete' => true,
            'horas_lembrete' => 2
        ]);

        // Audiência 4 - PRÓXIMA SEMANA, Agendada
        Audiencia::create([
            'processo_id' => $processos->last()->id,
            'cliente_id' => $clientes->last()->id,
            'advogado_id' => $users->last()->id,
            'unidade_id' => $unidades->first()->id,
            'tipo' => 'julgamento',
            'data' => Carbon::today()->addDays(7), // PRÓXIMA SEMANA
            'hora' => '15:00',
            'local' => 'TJSP - 4ª Vara Empresarial',
            'endereco' => 'Rua São Bento, 500 - Centro, São Paulo - SP',
            'sala' => 'Sala 401',
            'advogado' => 'Dra. Ana Silva',
            'juiz' => 'Dr. Carlos Pereira',
            'status' => 'agendada',
            'observacoes' => 'Audiência de julgamento final. Preparar alegações finais.',
            'lembrete' => true,
            'horas_lembrete' => 4
        ]);

        // Audiência 5 - MÊS PASSADO, Realizada (para estatísticas)
        Audiencia::create([
            'processo_id' => $processos->first()->id,
            'cliente_id' => $clientes->first()->id,
            'advogado_id' => $users->first()->id,
            'unidade_id' => $unidades->first()->id,
            'tipo' => 'conciliacao',
            'data' => Carbon::today()->subDays(15), // 15 DIAS ATRÁS
            'hora' => '11:00',
            'local' => 'TJSP - 1ª Vara Cível',
            'endereco' => 'Rua da Consolação, 1234 - Centro, São Paulo - SP',
            'sala' => 'Sala 101',
            'advogado' => 'Dr. Carlos Oliveira',
            'juiz' => 'Dr. José Silva',
            'status' => 'realizada',
            'observacoes' => 'Acordo celebrado com sucesso. Processo arquivado.',
            'lembrete' => true,
            'horas_lembrete' => 2
        ]);

        // Audiência 6 - CANCELADA (para testes)
        Audiencia::create([
            'processo_id' => $processos->count() > 1 ? $processos->skip(1)->first()->id : $processos->first()->id,
            'cliente_id' => $clientes->count() > 1 ? $clientes->skip(1)->first()->id : $clientes->first()->id,
            'advogado_id' => $users->first()->id,
            'unidade_id' => $unidades->first()->id,
            'tipo' => 'instrucao',
            'data' => Carbon::today()->addDays(3),
            'hora' => '16:30',
            'local' => 'TJSP - 2ª Vara Cível',
            'endereco' => 'Rua Líbero Badaró, 567 - Centro, São Paulo - SP',
            'sala' => 'Sala 201',
            'advogado' => 'Dra. Maria Santos',
            'juiz' => 'Dra. Ana Costa',
            'status' => 'cancelada',
            'observacoes' => 'Cancelada a pedido do cliente. Reagendar.',
            'lembrete' => false,
            'horas_lembrete' => 2
        ]);

        echo "✅ Audiências criadas com sucesso!\n";
        echo "📊 Total de audiências: " . Audiencia::count() . "\n";
        echo "📅 Audiências hoje: " . Audiencia::whereDate('data', Carbon::today())->count() . "\n";
        echo "⏰ Audiências agendadas: " . Audiencia::where('status', 'agendada')->count() . "\n";
        echo "✅ Audiências realizadas: " . Audiencia::where('status', 'realizada')->count() . "\n";
    }
}
