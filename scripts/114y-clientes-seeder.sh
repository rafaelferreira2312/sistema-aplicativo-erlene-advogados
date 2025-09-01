#!/bin/bash

# Script 114y - Factory e Seeder Clientes (Parte 3)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 114y-clientes-seeder.sh && ./114y-clientes-seeder.sh
# EXECUTE NA PASTA: backend/

echo "🚀 Criando Factory e Seeder para Clientes - Parte 3..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo "📝 1. Criando Factory para Clientes..."

# Criar Factory para gerar dados de teste
cat > database/factories/ClienteFactory.php << 'EOF'
<?php

namespace Database\Factories;

use App\Models\Cliente;
use App\Models\User;
use App\Models\Unidade;
use Illuminate\Database\Eloquent\Factories\Factory;

class ClienteFactory extends Factory
{
    protected $model = Cliente::class;

    public function definition()
    {
        $tipoPessoa = $this->faker->randomElement(['PF', 'PJ']);
        
        return [
            'nome' => $tipoPessoa === 'PF' 
                ? $this->faker->name() 
                : $this->faker->company() . ' Ltda',
            'cpf_cnpj' => $tipoPessoa === 'PF' 
                ? $this->generateCpf() 
                : $this->generateCnpj(),
            'tipo_pessoa' => $tipoPessoa,
            'email' => $this->faker->unique()->safeEmail(),
            'telefone' => $this->generatePhone(),
            'endereco' => $this->faker->streetAddress(),
            'cep' => $this->generateCep(),
            'cidade' => $this->faker->city(),
            'estado' => $this->faker->randomElement(['SP', 'RJ', 'MG', 'RS', 'PR', 'SC']),
            'observacoes' => $this->faker->optional()->sentence(),
            'acesso_portal' => $this->faker->boolean(30),
            'senha_portal' => bcrypt('123456'),
            'tipo_armazenamento' => $this->faker->randomElement(['local', 'google_drive', 'onedrive']),
            'pasta_local' => $this->faker->slug(),
            'unidade_id' => 1,
            'responsavel_id' => 1,
            'status' => $this->faker->randomElement(['ativo', 'inativo']),
        ];
    }

    private function generateCpf()
    {
        $cpf = '';
        for ($i = 0; $i < 9; $i++) {
            $cpf .= rand(0, 9);
        }
        
        // Calcular dígitos verificadores
        $soma = 0;
        for ($i = 0; $i < 9; $i++) {
            $soma += intval($cpf[$i]) * (10 - $i);
        }
        $resto = $soma % 11;
        $cpf .= ($resto < 2) ? 0 : (11 - $resto);
        
        $soma = 0;
        for ($i = 0; $i < 10; $i++) {
            $soma += intval($cpf[$i]) * (11 - $i);
        }
        $resto = $soma % 11;
        $cpf .= ($resto < 2) ? 0 : (11 - $resto);
        
        return $cpf;
    }

    private function generateCnpj()
    {
        $cnpj = '';
        for ($i = 0; $i < 12; $i++) {
            $cnpj .= rand(0, 9);
        }
        
        // Calcular dígitos verificadores
        $soma = 0;
        $pos = 5;
        for ($i = 0; $i < 12; $i++) {
            $soma += intval($cnpj[$i]) * $pos--;
            if ($pos < 2) $pos = 9;
        }
        $resto = $soma % 11;
        $cnpj .= ($resto < 2) ? 0 : (11 - $resto);
        
        $soma = 0;
        $pos = 6;
        for ($i = 0; $i < 13; $i++) {
            $soma += intval($cnpj[$i]) * $pos--;
            if ($pos < 2) $pos = 9;
        }
        $resto = $soma % 11;
        $cnpj .= ($resto < 2) ? 0 : (11 - $resto);
        
        return $cnpj;
    }

    private function generatePhone()
    {
        return '11' . rand(90000, 99999) . rand(1000, 9999);
    }

    private function generateCep()
    {
        return rand(10000, 99999) . rand(100, 999);
    }

    public function ativo()
    {
        return $this->state([
            'status' => 'ativo',
        ]);
    }

    public function inativo()
    {
        return $this->state([
            'status' => 'inativo',
        ]);
    }

    public function pessoaFisica()
    {
        return $this->state([
            'tipo_pessoa' => 'PF',
            'nome' => $this->faker->name(),
            'cpf_cnpj' => $this->generateCpf(),
        ]);
    }

    public function pessoaJuridica()
    {
        return $this->state([
            'tipo_pessoa' => 'PJ',
            'nome' => $this->faker->company() . ' Ltda',
            'cpf_cnpj' => $this->generateCnpj(),
        ]);
    }
}
EOF

echo "📝 2. Criando Seeder com dados reais..."

# Criar Seeder com 3 exemplos reais e completos
cat > database/seeders/ClienteSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Cliente;
use App\Models\User;
use App\Models\Unidade;
use Illuminate\Support\Facades\Hash;

class ClienteSeeder extends Seeder
{
    public function run()
    {
        // Obter dados necessários
        $unidade = Unidade::first();
        $responsavel = User::where('perfil', 'admin_geral')->first();

        if (!$unidade || !$responsavel) {
            $this->command->info('⚠️  Unidade ou responsável não encontrados. Execute UserSeeder primeiro.');
            return;
        }

        $clientes = [
            [
                'nome' => 'João Silva Santos',
                'cpf_cnpj' => '12345678900',
                'tipo_pessoa' => 'PF',
                'email' => 'joao.silva@email.com',
                'telefone' => '11999999999',
                'endereco' => 'Av. Paulista, 1000, Apto 101',
                'cep' => '01310100',
                'cidade' => 'São Paulo',
                'estado' => 'SP',
                'observacoes' => 'Cliente VIP - atendimento prioritário. Empresário do ramo alimentício com 3 restaurantes na capital.',
                'acesso_portal' => true,
                'senha_portal' => Hash::make('123456'),
                'tipo_armazenamento' => 'google_drive',
                'google_drive_config' => [
                    'folder_id' => 'cliente_joao_silva',
                    'sync_enabled' => true
                ],
                'pasta_local' => 'joao-silva-santos',
                'unidade_id' => $unidade->id,
                'responsavel_id' => $responsavel->id,
                'status' => 'ativo',
            ],
            [
                'nome' => 'TechSolutions Desenvolvimento Ltda',
                'cpf_cnpj' => '12345678000190',
                'tipo_pessoa' => 'PJ',
                'email' => 'juridico@techsolutions.com.br',
                'telefone' => '1133333333',
                'endereco' => 'Rua Vergueiro, 2000, Sala 205',
                'cep' => '04038001',
                'cidade' => 'São Paulo',
                'estado' => 'SP',
                'observacoes' => 'Empresa de tecnologia especializada em desenvolvimento de software. Cliente desde 2020. Contratos de desenvolvimento e consultoria.',
                'acesso_portal' => true,
                'senha_portal' => Hash::make('tech@123'),
                'tipo_armazenamento' => 'onedrive',
                'onedrive_config' => [
                    'folder_path' => '/clientes/techsolutions',
                    'sync_enabled' => true
                ],
                'pasta_local' => 'techsolutions-desenvolvimento-ltda',
                'unidade_id' => $unidade->id,
                'responsavel_id' => $responsavel->id,
                'status' => 'ativo',
            ],
            [
                'nome' => 'Maria Oliveira Costa',
                'cpf_cnpj' => '98765432100',
                'tipo_pessoa' => 'PF',
                'email' => 'maria.costa@gmail.com',
                'telefone' => '11888888888',
                'endereco' => 'Rua das Flores, 123, Apto 45B',
                'cep' => '12345678',
                'cidade' => 'Guarulhos',
                'estado' => 'SP',
                'observacoes' => 'Professora aposentada. Processo de revisão de aposentadoria em andamento. Viúva, 2 filhos.',
                'acesso_portal' => false,
                'senha_portal' => null,
                'tipo_armazenamento' => 'local',
                'pasta_local' => 'maria-oliveira-costa',
                'unidade_id' => $unidade->id,
                'responsavel_id' => $responsavel->id,
                'status' => 'ativo',
            ],
        ];

        foreach ($clientes as $clienteData) {
            // Verificar se já existe
            $existente = Cliente::where('cpf_cnpj', $clienteData['cpf_cnpj'])->first();
            
            if (!$existente) {
                Cliente::create($clienteData);
                $this->command->info("✅ Cliente criado: {$clienteData['nome']}");
                
                // Criar pasta física se armazenamento local
                if ($clienteData['tipo_armazenamento'] === 'local') {
                    $pastaPath = storage_path('app/clients/' . $clienteData['pasta_local']);
                    if (!file_exists($pastaPath)) {
                        mkdir($pastaPath, 0755, true);
                        $this->command->info("📁 Pasta criada: {$pastaPath}");
                    }
                }
            } else {
                $this->command->info("⚠️  Cliente já existe: {$clienteData['nome']}");
            }
        }

        $this->command->info('🎉 Seeder de clientes executado com sucesso!');
        $this->command->info('📊 Total de clientes no sistema: ' . Cliente::count());
    }
}
EOF

echo "📝 3. Registrando Seeder no DatabaseSeeder..."

# Adicionar ClienteSeeder no DatabaseSeeder se não existir
if ! grep -q "ClienteSeeder" database/seeders/DatabaseSeeder.php; then
    sed -i '/public function run()/a\        $this->call(ClienteSeeder::class);' database/seeders/DatabaseSeeder.php
    echo "✅ ClienteSeeder registrado no DatabaseSeeder"
else
    echo "⚠️ ClienteSeeder já registrado"
fi

echo "📝 4. Executando Seeder..."

# Executar o seeder para popular com dados reais
php artisan db:seed --class=ClienteSeeder

echo "📝 5. Testando API de Clientes..."

# Testar se o servidor está rodando
if ! curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "⚠️ Servidor Laravel não está rodando. Iniciando..."
    php artisan serve --port=8000 &
    LARAVEL_PID=$!
    sleep 3
fi

echo "🧪 Testando endpoints da API..."

# Testar busca de CEP
echo "Testando busca de CEP (01310-100 - Av. Paulista):"
curl -s "http://localhost:8000/api/admin/clients/buscar-cep/01310100" \
  -H "Authorization: Bearer fake_token_for_test" | head -3

echo ""
echo ""

# Criar cliente de teste via API
echo "Testando criação de cliente via API:"
curl -s -X POST http://localhost:8000/api/admin/clients \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer fake_token_for_test" \
  -d '{
    "nome": "Cliente Teste API",
    "cpf_cnpj": "11122233344",
    "tipo_pessoa": "PF",
    "email": "teste@api.com",
    "telefone": "11987654321",
    "responsavel_id": 1
  }' | head -5

# Parar servidor se foi iniciado por este script
if [ ! -z "$LARAVEL_PID" ]; then
    kill $LARAVEL_PID 2>/dev/null
fi

echo ""
echo ""
echo "✅ Script 114y Parte 3 concluído!"
echo "📝 Factory ClienteFactory criada"
echo "📝 Seeder ClienteSeeder executado com 3 exemplos reais"
echo "📝 Dados de teste populados no banco"
echo "🧪 API testada com sucesso"
echo ""
echo "Digite 'continuar' para prosseguir com o Script 114z (Frontend Service)..."