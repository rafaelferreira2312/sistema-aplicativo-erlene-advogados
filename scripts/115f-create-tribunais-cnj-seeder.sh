#!/bin/bash

# Script 115f - Criar Seeder Tribunais CNJ com todos os endpoints
# Sistema Erlene Advogados - Popular tabela tribunais com endpoints CNJ DataJud
# Execução: chmod +x 115f-create-tribunais-cnj-seeder.sh && ./115f-create-tribunais-cnj-seeder.sh
# EXECUTAR DENTRO DA PASTA: backend/

echo "🏛️ Script 115f - Criando seeder de tribunais CNJ..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 115f-create-tribunais-cnj-seeder.sh && ./115f-create-tribunais-cnj-seeder.sh"
    exit 1
fi

echo "1️⃣ Criando seeder para popular tabela tribunais..."

cat > database/seeders/TribunaisCNJSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Tribunal;
use Illuminate\Support\Facades\DB;

class TribunaisCNJSeeder extends Seeder
{
    public function run()
    {
        // Limpar tabela antes de popular
        DB::table('tribunais')->truncate();

        $tribunais = [
            // Tribunais Superiores
            [
                'nome' => 'Tribunal Superior do Trabalho',
                'codigo' => 'TST',
                'tipo' => 'superior',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_tst/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_tst/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],
            [
                'nome' => 'Tribunal Superior Eleitoral',
                'codigo' => 'TSE',
                'tipo' => 'superior',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_tse/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_tse/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],
            [
                'nome' => 'Tribunal Superior de Justiça',
                'codigo' => 'STJ',
                'tipo' => 'superior',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_stj/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_stj/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],
            [
                'nome' => 'Tribunal Superior Militar',
                'codigo' => 'STM',
                'tipo' => 'superior',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_stm/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_stm/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],

            // Justiça Federal
            [
                'nome' => 'Tribunal Regional Federal da 1ª Região',
                'codigo' => 'TRF1',
                'tipo' => 'federal',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_trf1/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_trf1/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],
            [
                'nome' => 'Tribunal Regional Federal da 2ª Região',
                'codigo' => 'TRF2',
                'tipo' => 'federal',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_trf2/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_trf2/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],
            [
                'nome' => 'Tribunal Regional Federal da 3ª Região',
                'codigo' => 'TRF3',
                'tipo' => 'federal',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_trf3/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_trf3/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],
            [
                'nome' => 'Tribunal Regional Federal da 4ª Região',
                'codigo' => 'TRF4',
                'tipo' => 'federal',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_trf4/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_trf4/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],
            [
                'nome' => 'Tribunal Regional Federal da 5ª Região',
                'codigo' => 'TRF5',
                'tipo' => 'federal',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_trf5/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_trf5/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],
            [
                'nome' => 'Tribunal Regional Federal da 6ª Região',
                'codigo' => 'TRF6',
                'tipo' => 'federal',
                'estado' => null,
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_trf6/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_trf6/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ],

            // Justiça Estadual - Principais
            [
                'nome' => 'Tribunal de Justiça de São Paulo',
                'codigo' => 'TJSP',
                'tipo' => 'estadual',
                'estado' => 'SP',
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_tjsp/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_tjsp/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 200
            ],
            [
                'nome' => 'Tribunal de Justiça do Rio de Janeiro',
                'codigo' => 'TJRJ',
                'tipo' => 'estadual',
                'estado' => 'RJ',
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_tjrj/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_tjrj/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 150
            ],
            [
                'nome' => 'Tribunal de Justiça de Minas Gerais',
                'codigo' => 'TJMG',
                'tipo' => 'estadual',
                'estado' => 'MG',
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_tjmg/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_tjmg/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 150
            ],
            [
                'nome' => 'Tribunal de Justiça do Rio Grande do Sul',
                'codigo' => 'TJRS',
                'tipo' => 'estadual',
                'estado' => 'RS',
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_tjrs/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_tjrs/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 120
            ],
            [
                'nome' => 'Tribunal de Justiça do Paraná',
                'codigo' => 'TJPR',
                'tipo' => 'estadual',
                'estado' => 'PR',
                'url_consulta' => 'https://api-publica.datajud.cnj.jus.br/api_publica_tjpr/_search',
                'config_api' => json_encode([
                    'endpoint_cnj' => 'api_publica_tjpr/_search',
                    'total_consultas' => 0,
                    'consultas_sucesso' => 0,
                    'consultas_erro' => 0
                ]),
                'ativo' => true,
                'limite_consultas_dia' => 100
            ]
        ];

        foreach ($tribunais as $tribunal) {
            $tribunal['created_at'] = now();
            $tribunal['updated_at'] = now();
            
            DB::table('tribunais')->insert($tribunal);
        }

        $this->command->info("✅ " . count($tribunais) . " tribunais inseridos com sucesso!");
        $this->command->info("📊 Tribunais por tipo:");
        $this->command->info("   • Superiores: 4");
        $this->command->info("   • Federais: 6");
        $this->command->info("   • Estaduais: 5 (principais)");
        $this->command->info("");
        $this->command->info("🔧 Para adicionar mais tribunais estaduais, execute:");
        $this->command->info("   php artisan db:seed --class=TribunaisEstadualCompletaSeeder");
    }
}
EOF

echo "2️⃣ Executando seeder para popular tabela tribunais..."

php artisan db:seed --class=TribunaisCNJSeeder

echo "3️⃣ Verificando dados inseridos..."

echo "Tribunais inseridos na base:"
php artisan tinker --execute="echo App\Models\Tribunal::count() . ' tribunais cadastrados';"

echo "Tribunais por tipo:"
php artisan tinker --execute="
\$tipos = App\Models\Tribunal::selectRaw('tipo, count(*) as total')
    ->groupBy('tipo')
    ->pluck('total', 'tipo');
foreach(\$tipos as \$tipo => \$total) {
    echo \$tipo . ': ' . \$total . PHP_EOL;
}
"

echo "✅ Tribunais CNJ configurados com sucesso!"
echo ""
echo "📋 O que foi implementado:"
echo "   • Seeder com 15 tribunais principais"
echo "   • Endpoints CNJ configurados no config_api"
echo "   • Limites de consulta por tribunal"
echo "   • Estatísticas de uso inicializadas"
echo ""
echo "⏭️ Próximo: Script para atualizar CNJService usar tabela tribunais"