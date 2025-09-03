#!/bin/bash

# Script 115g - Atualizar CNJService para usar tabela tribunais
# Sistema Erlene Advogados - CNJService usando endpoints da tabela tribunais
# Execução: chmod +x 115g-update-cnj-service-tribunais.sh && ./115g-update-cnj-service-tribunais.sh
# EXECUTAR DENTRO DA PASTA: backend/

echo "🔄 Script 115g - Atualizando CNJService para usar tabela tribunais..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 115g-update-cnj-service-tribunais.sh && ./115g-update-cnj-service-tribunais.sh"
    exit 1
fi

echo "1️⃣ Fazendo backup do CNJService atual..."

cp app/Services/Integration/CNJService.php app/Services/Integration/CNJService.php.backup

echo "2️⃣ Atualizando CNJService para usar tabela tribunais..."

cat > app/Services/Integration/CNJService.php << 'EOF'
<?php

namespace App\Services\Integration;

use App\Models\Processo;
use App\Models\Tribunal;
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
     * Sincronizar processo com dados do CNJ DataJud usando tabela tribunais
     */
    public function sincronizarProcesso(Processo $processo)
    {
        try {
            Log::info("Iniciando sincronização CNJ", [
                'processo_id' => $processo->id,
                'numero_processo' => $processo->numero,
                'tribunal' => $processo->tribunal
            ]);

            // Buscar tribunal na tabela
            $tribunal = Tribunal::where('codigo', $processo->tribunal)
                               ->where('ativo', true)
                               ->first();

            if (!$tribunal) {
                throw new \Exception("Tribunal {$processo->tribunal} não encontrado ou inativo na base");
            }

            // Verificar se tribunal tem endpoint CNJ configurado
            $configApi = $tribunal->config_api ?? [];
            $endpointCNJ = $configApi['endpoint_cnj'] ?? null;
            
            if (!$endpointCNJ) {
                throw new \Exception("Endpoint CNJ não configurado para tribunal {$processo->tribunal}");
            }

            // Verificar limite de consultas diárias
            $consultasHoje = $this->getConsultasHoje($tribunal);
            if ($consultasHoje >= $tribunal->limite_consultas_dia) {
                throw new \Exception("Limite diário de consultas ({$tribunal->limite_consultas_dia}) atingido para tribunal {$processo->tribunal}");
            }

            // Consultar processo no CNJ
            $dadosCNJ = $this->consultarProcessoCNJ($processo->numero, $endpointCNJ, $tribunal);

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
                'tribunal_id' => $tribunal->id,
                'endpoint_usado' => $endpointCNJ,
                'total_resultados_cnj' => $dadosCNJ['total'] ?? 0,
                'api_version' => 'v2'
            ];

            $processo->marcarComoSincronizado($metadataCnj);

            // Atualizar estatísticas do tribunal (sucesso)
            $this->atualizarEstatisticasTribunal($tribunal, true);

            Log::info("Sincronização CNJ concluída com sucesso", [
                'processo_id' => $processo->id,
                'tribunal_id' => $tribunal->id,
                'novas_movimentacoes' => $novasMovimentacoes,
                'total_resultados' => $dadosCNJ['total'] ?? 0
            ]);

            return [
                'success' => true,
                'novas_movimentacoes' => $novasMovimentacoes,
                'total_resultados_cnj' => $dadosCNJ['total'] ?? 0,
                'tribunal_nome' => $tribunal->nome
            ];

        } catch (\Exception $e) {
            // Atualizar estatísticas de erro do tribunal se existir
            if (isset($tribunal)) {
                $this->atualizarEstatisticasTribunal($tribunal, false);
            }

            Log::error("Erro na sincronização CNJ", [
                'processo_id' => $processo->id,
                'tribunal' => $processo->tribunal,
                'erro' => $e->getMessage()
            ]);

            throw $e;
        }
    }

    /**
     * Consultar processo na API CNJ usando endpoint da tabela tribunais
     */
    protected function consultarProcessoCNJ(string $numeroProcesso, string $endpointCNJ, Tribunal $tribunal)
    {
        try {
            // Para desenvolvimento/teste sem API Key - usar mock
            if (config('app.env') !== 'production' || !$this->apiKey) {
                Log::info("Usando mock CNJ para desenvolvimento", [
                    'numero_processo' => $numeroProcesso,
                    'endpoint' => $endpointCNJ
                ]);
                return $this->mockConsultaCNJReal($numeroProcesso, $endpointCNJ, $tribunal);
            }

            // API Real CNJ DataJud - POST com Query DSL
            $url = $this->baseUrl . '/' . $endpointCNJ;

            $queryBody = [
                "query" => [
                    "match" => [
                        "numeroProcesso" => $numeroProcesso
                    ]
                ]
            ];

            Log::info("Fazendo requisição para CNJ", [
                'url' => $url,
                'numero_processo' => $numeroProcesso,
                'tribunal' => $tribunal->codigo
            ]);

            $response = Http::timeout($this->timeout)
                          ->withHeaders([
                              'Authorization' => 'APIKey ' . $this->apiKey,
                              'Content-Type' => 'application/json'
                          ])
                          ->post($url, $queryBody);

            if ($response->successful()) {
                $data = $response->json();
                
                Log::info("Resposta CNJ recebida", [
                    'total_hits' => $data['hits']['total']['value'] ?? 0,
                    'tribunal' => $tribunal->codigo
                ]);
                
                return [
                    'success' => true,
                    'hits' => $data['hits']['hits'] ?? [],
                    'total' => $data['hits']['total']['value'] ?? 0,
                    'endpoint_usado' => $endpointCNJ
                ];
            }

            Log::error("Erro HTTP na consulta CNJ", [
                'status' => $response->status(),
                'body' => $response->body(),
                'tribunal' => $tribunal->codigo
            ]);

            return [
                'success' => false,
                'message' => 'Erro na consulta CNJ: HTTP ' . $response->status(),
                'response_body' => $response->body()
            ];

        } catch (\Exception $e) {
            Log::error("Exceção ao consultar CNJ", [
                'numero_processo' => $numeroProcesso,
                'endpoint' => $endpointCNJ,
                'tribunal' => $tribunal->codigo,
                'erro' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'Erro de conexão com CNJ: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Mock de consulta CNJ para desenvolvimento com dados reais
     */
    protected function mockConsultaCNJReal(string $numeroProcesso, string $endpointCNJ, Tribunal $tribunal)
    {
        // Simular dados baseados no tribunal
        $hitsMock = [
            [
                '_source' => [
                    'numeroProcesso' => $numeroProcesso,
                    'dadosBasicos' => [
                        'numero' => $numeroProcesso,
                        'tribunal' => $tribunal->codigo,
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
                            'complementoTabelado' => [
                                [
                                    'codigo' => 2000,
                                    'nome' => 'Cite-se o requerido'
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ];

        return [
            'success' => true,
            'hits' => $hitsMock,
            'total' => 1,
            'endpoint_usado' => $endpointCNJ
        ];
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

    /**
     * Obter número de consultas hoje para um tribunal
     */
    protected function getConsultasHoje(Tribunal $tribunal): int
    {
        $configApi = $tribunal->config_api ?? [];
        $ultimaConsulta = $configApi['ultima_consulta'] ?? null;
        
        if (!$ultimaConsulta) {
            return 0;
        }
        
        $ultimaConsultaDate = Carbon::parse($ultimaConsulta);
        $hoje = Carbon::today();
        
        // Se última consulta foi hoje, retorna total do dia, senão 0
        if ($ultimaConsultaDate->isSameDay($hoje)) {
            return $configApi['consultas_dia_atual'] ?? 0;
        }
        
        return 0;
    }

    /**
     * Atualizar estatísticas do tribunal
     */
    protected function atualizarEstatisticasTribunal(Tribunal $tribunal, bool $sucesso)
    {
        $configApi = $tribunal->config_api ?? [];
        $hoje = Carbon::today();
        $ultimaConsulta = isset($configApi['ultima_consulta']) ? Carbon::parse($configApi['ultima_consulta']) : null;
        
        // Resetar contador diário se mudou o dia
        if (!$ultimaConsulta || !$ultimaConsulta->isSameDay($hoje)) {
            $configApi['consultas_dia_atual'] = 0;
        }
        
        // Incrementar contadores
        $configApi['total_consultas'] = ($configApi['total_consultas'] ?? 0) + 1;
        $configApi['consultas_dia_atual'] = ($configApi['consultas_dia_atual'] ?? 0) + 1;
        
        if ($sucesso) {
            $configApi['consultas_sucesso'] = ($configApi['consultas_sucesso'] ?? 0) + 1;
        } else {
            $configApi['consultas_erro'] = ($configApi['consultas_erro'] ?? 0) + 1;
        }
        
        $configApi['ultima_consulta'] = now()->toISOString();
        
        // Atualizar tribunal
        $tribunal->update(['config_api' => $configApi]);
        
        Log::info("Estatísticas do tribunal atualizadas", [
            'tribunal' => $tribunal->codigo,
            'sucesso' => $sucesso,
            'consultas_hoje' => $configApi['consultas_dia_atual'],
            'total_consultas' => $configApi['total_consultas']
        ]);
    }
}
EOF

echo "3️⃣ Testando integração com processo existente..."

# Verificar se existe processo de teste
php artisan tinker --execute="
\$processo = App\Models\Processo::where('numero', '0000335250184013202')->first();
if (\$processo) {
    echo 'Processo de teste encontrado: ID ' . \$processo->id;
    echo PHP_EOL . 'Tribunal: ' . \$processo->tribunal;
    
    \$tribunal = App\Models\Tribunal::where('codigo', \$processo->tribunal)->first();
    if (\$tribunal) {
        echo PHP_EOL . 'Tribunal configurado: ' . \$tribunal->nome;
        echo PHP_EOL . 'Endpoint CNJ: ' . (\$tribunal->config_api['endpoint_cnj'] ?? 'NÃO CONFIGURADO');
    } else {
        echo PHP_EOL . 'ATENÇÃO: Tribunal não encontrado na base!';
    }
} else {
    echo 'Processo de teste não encontrado. Execute o seeder primeiro.';
}
"

echo ""
echo "✅ CNJService atualizado com sucesso!"
echo ""
echo "📋 O que foi implementado:"
echo "   • CNJService usa tabela tribunais em vez de mapeamento hardcoded"
echo "   • Verificação de limites diários de consulta"
echo "   • Estatísticas por tribunal (sucesso/erro)"
echo "   • Logs detalhados para debug"
echo "   • Mock melhorado para desenvolvimento"
echo ""
echo "⏭️ Backend PROCESSOS completo! Próximo: Frontend React"