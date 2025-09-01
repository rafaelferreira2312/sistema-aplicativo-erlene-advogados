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
