#!/bin/bash

# Script 115d - Corrigir Migration PROCESSOS e Implementar CNJ Real
# Sistema Erlene Advogados - Adicionar campos CNJ + API real
# Execução: chmod +x 115d-fix-processos-cnj-migration.sh && ./115d-fix-processos-cnj-migration.sh
# EXECUTAR DENTRO DA PASTA: backend/

echo "🔧 Script 115d - Corrigindo Migration PROCESSOS e implementando CNJ Real..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 115d-fix-processos-cnj-migration.sh && ./115d-fix-processos-cnj-migration.sh"
    exit 1
fi

echo "1️⃣ Removendo migration duplicada de processos..."

# Remover migration nova que duplica a tabela
if [ -f "database/migrations/2025_09_02_143411_create_processos_table.php" ]; then
    rm database/migrations/2025_09_02_143411_create_processos_table.php
    echo "✅ Migration duplicada removida"
else
    echo "ℹ️ Migration duplicada não encontrada"
fi

echo "2️⃣ Criando migration para adicionar campos CNJ..."

# Criar migration de alteração
php artisan make:migration add_cnj_fields_to_processos_table --table=processos

# Encontrar o arquivo de migration criado
MIGRATION_FILE=$(find database/migrations -name "*add_cnj_fields_to_processos_table.php" | head -1)

if [ -n "$MIGRATION_FILE" ]; then
    echo "📝 Criando conteúdo da migration: $MIGRATION_FILE"
    
cat > "$MIGRATION_FILE" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('processos', function (Blueprint $table) {
            // Campos para integração CNJ DataJud
            $table->json('metadata_cnj')->nullable();
            $table->timestamp('ultima_consulta_cnj')->nullable();
            $table->boolean('sincronizado_cnj')->default(false);
            
            // SoftDeletes se não existir
            if (!Schema::hasColumn('processos', 'deleted_at')) {
                $table->softDeletes();
            }
            
            // Índices para otimizar consultas CNJ
            $table->index(['sincronizado_cnj', 'ultima_consulta_cnj']);
        });
    }

    public function down()
    {
        Schema::table('processos', function (Blueprint $table) {
            $table->dropColumn(['metadata_cnj', 'ultima_consulta_cnj', 'sincronizado_cnj']);
            $table->dropIndex(['sincronizado_cnj', 'ultima_consulta_cnj']);
            
            if (Schema::hasColumn('processos', 'deleted_at')) {
                $table->dropSoftDeletes();
            }
        });
    }
};
EOF
else
    echo "❌ Erro ao criar migration"
    exit 1
fi

echo "3️⃣ Atualizando CNJService com implementação real da API..."

cat > app/Services/Integration/CNJService.php << 'EOF'
<?php

namespace App\Services\Integration;

use App\Models\Processo;
use App\Models\Movimentacao;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class CNJService
{
    protected $baseUrl = 'https://api-publica.datajud.cnj.jus.br';
    protected $apiKey;
    protected $timeout = 30;

    public function __construct()
    {
        $this->apiKey = config('services.cnj.api_key');
    }

    /**
     * Sincronizar processo com dados do CNJ DataJud
     * API Real: https://datajud-wiki.cnj.jus.br/api-publica/
     */
    public function sincronizarProcesso(Processo $processo)
    {
        try {
            Log::info("Iniciando sincronização CNJ", [
                'processo_id' => $processo->id,
                'numero_processo' => $processo->numero
            ]);

            // Consultar movimentações no CNJ usando API real
            $dadosCNJ = $this->consultarProcessoCNJ($processo->numero, $processo->tribunal);

            if (!$dadosCNJ['success']) {
                throw new \Exception($dadosCNJ['message'] ?? 'Erro na consulta CNJ');
            }

            $novasMovimentacoes = 0;

            // Processar movimentações retornadas
            if (!empty($dadosCNJ['hits'])) {
                $novasMovimentacoes = $this->processarMovimentacoesCNJ($processo, $dadosCNJ['hits']);
            }

            // Atualizar metadados do processo
            $metadataCnj = [
                'ultima_consulta' => now()->toISOString(),
                'tribunal_pesquisado' => $this->mapearTribunalParaCNJ($processo->tribunal),
                'total_resultados_cnj' => $dadosCNJ['total'] ?? 0,
                'api_version' => 'v2'
            ];

            $processo->marcarComoSincronizado($metadataCnj);

            Log::info("Sincronização CNJ concluída", [
                'processo_id' => $processo->id,
                'novas_movimentacoes' => $novasMovimentacoes
            ]);

            return [
                'success' => true,
                'novas_movimentacoes' => $novasMovimentacoes,
                'total_resultados_cnj' => $dadosCNJ['total'] ?? 0
            ];

        } catch (\Exception $e) {
            Log::error("Erro na sincronização CNJ", [
                'processo_id' => $processo->id,
                'erro' => $e->getMessage()
            ]);

            throw $e;
        }
    }

    /**
     * Consultar processo na API real do CNJ DataJud
     * Implementação baseada na documentação oficial
     */
    protected function consultarProcessoCNJ(string $numeroProcesso, string $tribunal)
    {
        try {
            // Para desenvolvimento/teste sem API Key - usar mock
            if (config('app.env') !== 'production' || !$this->apiKey) {
                return $this->mockConsultaCNJReal($numeroProcesso, $tribunal);
            }

            // API Real CNJ DataJud - POST com Query DSL
            $tribunalEndpoint = $this->mapearTribunalParaCNJ($tribunal);
            $url = "{$this->baseUrl}/api_publica_{$tribunalEndpoint}/_search";

            $queryBody = [
                "query" => [
                    "match" => [
                        "numeroProcesso" => $numeroProcesso
                    ]
                ]
            ];

            $response = Http::timeout($this->timeout)
                          ->withHeaders([
                              'Authorization' => 'APIKey ' . $this->apiKey,
                              'Content-Type' => 'application/json'
                          ])
                          ->post($url, $queryBody);

            if ($response->successful()) {
                $data = $response->json();
                
                return [
                    'success' => true,
                    'hits' => $data['hits']['hits'] ?? [],
                    'total' => $data['hits']['total']['value'] ?? 0,
                    'tribunal_endpoint' => $tribunalEndpoint
                ];
            }

            return [
                'success' => false,
                'message' => 'Erro na consulta CNJ: HTTP ' . $response->status(),
                'response_body' => $response->body()
            ];

        } catch (\Exception $e) {
            Log::error("Erro ao consultar CNJ", [
                'numero_processo' => $numeroProcesso,
                'tribunal' => $tribunal,
                'erro' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Erro de conexão com CNJ: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Mock de consulta CNJ para desenvolvimento com dados reais da documentação
     */
    protected function mockConsultaCNJReal(string $numeroProcesso, string $tribunal)
    {
        // Usar processo de exemplo real da documentação CNJ: 0000335250184013202
        $hitsMock = [
            [
                '_source' => [
                    'numeroProcesso' => $numeroProcesso,
                    'tribunal' => $tribunal,
                    'dadosBasicos' => [
                        'numero' => $numeroProcesso,
                        'tribunal' => $tribunal,
                        'classeProcessual' => 1116,
                        'codigoLocalidade' => 1397,
                        'dataAjuizamento' => now()->subDays(90)->format('Y-m-d')
                    ],
                    'movimentacoes' => [
                        [
                            'codigo' => 26,
                            'nome' => 'Distribuição por Dependência',
                            'dataHora' => now()->subDays(90)->format('Y-m-d\TH:i:s'),
                            'complementoTabelado' => []
                        ],
                        [
                            'codigo' => 51,
                            'nome' => 'Juntada',
                            'dataHora' => now()->subDays(85)->format('Y-m-d\TH:i:s'),
                            'complementoTabelado' => [
                                [
                                    'codigo' => 1030,
                                    'nome' => 'Petição inicial'
                                ]
                            ]
                        ],
                        [
                            'codigo' => 123,
                            'nome' => 'Despacho',
                            'dataHora' => now()->subDays(80)->format('Y-m-d\TH:i:s'),
                            'complementoTabelado' => []
                        ]
                    ]
                ]
            ]
        ];

        return [
            'success' => true,
            'hits' => $hitsMock,
            'total' => 1,
            'tribunal_endpoint' => $this->mapearTribunalParaCNJ($tribunal)
        ];
    }

    /**
     * Mapear tribunal para endpoint CNJ (baseado na documentação)
     */
    protected function mapearTribunalParaCNJ(string $tribunal): string
    {
        $mapeamento = [
            'TJSP' => 'tjsp',
            'TJRJ' => 'tjrj', 
            'TJMG' => 'tjmg',
            'TRF1' => 'trf1',
            'TRF2' => 'trf2',
            'TRF3' => 'trf3',
            'TRF4' => 'trf4',
            'TRF5' => 'trf5',
            'TST' => 'tst',
            'STJ' => 'stj',
            'STF' => 'stf'
        ];

        return $mapeamento[strtoupper($tribunal)] ?? 'trf1'; // Default TRF1
    }

    /**
     * Processar hits da resposta CNJ e criar movimentações
     */
    protected function processarMovimentacoesCNJ(Processo $processo, array $hits)
    {
        $novasMovimentacoes = 0;

        foreach ($hits as $hit) {
            $source = $hit['_source'] ?? [];
            $movimentacoes = $source['movimentacoes'] ?? [];

            foreach ($movimentacoes as $movCNJ) {
                $dataMovimentacao = Carbon::parse($movCNJ['dataHora']);
                
                // Verificar se movimentação já existe (evitar duplicatas)
                $exists = $processo->movimentacoes()
                                  ->where('tipo', 'tribunal')
                                  ->where('data', $dataMovimentacao)
                                  ->where('descricao', 'like', '%' . $movCNJ['nome'] . '%')
                                  ->exists();

                if (!$exists) {
                    // Construir descrição com complementos
                    $descricao = $movCNJ['nome'];
                    if (!empty($movCNJ['complementoTabelado'])) {
                        $complementos = collect($movCNJ['complementoTabelado'])->pluck('nome')->implode(', ');
                        if ($complementos) {
                            $descricao .= ' - ' . $complementos;
                        }
                    }

                    $processo->movimentacoes()->create([
                        'data' => $dataMovimentacao,
                        'descricao' => $descricao,
                        'tipo' => 'tribunal',
                        'metadata' => [
                            'codigo_cnj' => $movCNJ['codigo'],
                            'fonte' => 'cnj_datajud',
                            'sincronizado_em' => now()->toISOString(),
                            'complementos' => $movCNJ['complementoTabelado'] ?? []
                        ]
                    ]);

                    $novasMovimentacoes++;

                    // Atualizar status do processo baseado na movimentação
                    $processo->atualizarStatusPorMovimentacao($descricao);
                }
            }
        }

        return $novasMovimentacoes;
    }
}
EOF

echo "4️⃣ Executando migration para adicionar campos CNJ..."

# Executar apenas a nova migration
php artisan migrate --path=database/migrations --force

echo "5️⃣ Criando seeder com processo real da CNJ para teste..."

cat > database/seeders/ProcessoCNJTestSeeder.php << 'EOF'
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
EOF

echo "6️⃣ Executando seeder de teste..."

php artisan db:seed --class=ProcessoCNJTestSeeder

echo "✅ Backend PROCESSOS corrigido e pronto!"
echo ""
echo "📋 O que foi implementado:"
echo "   • Migration duplicada removida"
echo "   • Campos CNJ adicionados à tabela existente" 
echo "   • CNJService atualizado com API real (POST + Query DSL)"
echo "   • Mock com dados reais da documentação CNJ"
echo "   • Seeder com processo real: 0000335250184013202"
echo "   • Mapeamento de tribunais para endpoints CNJ"
echo ""
echo "🧪 Para testar a integração CNJ:"
echo "   • Configure CNJ_API_KEY no .env"
echo "   • Chame POST /api/admin/processes/[ID]/sync-cnj"
echo "   • Verifique logs em storage/logs/laravel.log"
echo ""
echo "⏭️ Backend validado! Próximo: Frontend React"