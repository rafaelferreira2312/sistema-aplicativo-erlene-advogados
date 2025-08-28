#!/bin/bash

# Script 114k - Popular todas as tabelas com dados de exemplo
# EXECUTE DENTRO DA PASTA: backend/

echo "Script 114k - Populando banco com dados completos..."

if [ ! -f "artisan" ]; then
    echo "Erro: Execute dentro da pasta backend/"
    exit 1
fi

echo "1. Excluindo tabela sessions..."

php artisan tinker --execute="
use Illuminate\Support\Facades\Schema;
if (Schema::hasTable('sessions')) {
    Schema::drop('sessions');
    echo 'Tabela sessions removida\n';
}"

echo "2. Criando seeder completo..."

cat > database/seeders/CompleteSystemSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Unidade;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class CompleteSystemSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        
        // Limpar tabelas
        DB::table('users')->truncate();
        DB::table('unidades')->truncate();

        // 1. UNIDADES
        $matriz = Unidade::create([
            'nome' => 'Erlene Advogados - Matriz',
            'codigo' => 'MATRIZ',
            'endereco' => 'Rua Principal, 123 - Centro',
            'cidade' => 'São Paulo',
            'estado' => 'SP',
            'cep' => '01234-567',
            'telefone' => '(11) 3333-1111',
            'email' => 'matriz@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0001-90',
            'status' => 'ativo',
        ]);

        $filialRj = Unidade::create([
            'nome' => 'Erlene Advogados - Rio de Janeiro',
            'codigo' => 'FILIAL_RJ',
            'endereco' => 'Av. Atlântica, 456 - Copacabana',
            'cidade' => 'Rio de Janeiro',
            'estado' => 'RJ',
            'cep' => '22070-001',
            'telefone' => '(21) 3333-2222',
            'email' => 'rj@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0002-71',
            'status' => 'ativa',
        ]);

        $filialBh = Unidade::create([
            'nome' => 'Erlene Advogados - Belo Horizonte',
            'codigo' => 'FILIAL_BH',
            'endereco' => 'Rua da Liberdade, 789',
            'cidade' => 'Belo Horizonte',
            'estado' => 'MG',
            'cep' => '30112-001',
            'telefone' => '(31) 3333-3333',
            'email' => 'bh@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0003-52',
            'status' => 'ativa',
        ]);

        // 2. USUÁRIOS
        // Admin Principal
        User::create([
            'nome' => 'Dra. Erlene Chaves Silva',
            'email' => 'admin@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '11111111111',
            'telefone' => '(11) 99999-1111',
            'oab' => 'SP123456',
            'perfil' => 'admin_geral',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Admins das Filiais
        User::create([
            'nome' => 'Dr. João Silva Santos',
            'email' => 'admin.rj@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '22222222222',
            'telefone' => '(21) 98888-2222',
            'oab' => 'RJ654321',
            'perfil' => 'admin_unidade',
            'unidade_id' => $filialRj->id,
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Dr. Carlos Mendes',
            'email' => 'admin.bh@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '33333333333',
            'telefone' => '(31) 97777-3333',
            'oab' => 'MG789012',
            'perfil' => 'admin_unidade',
            'unidade_id' => $filialBh->id,
            'status' => 'ativo',
        ]);

        // Advogados
        User::create([
            'nome' => 'Dra. Maria Costa Lima',
            'email' => 'maria.advogada@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '44444444444',
            'telefone' => '(11) 97777-4444',
            'oab' => 'SP456789',
            'perfil' => 'advogado',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Dr. Roberto Oliveira',
            'email' => 'roberto.advogado@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '55555555555',
            'telefone' => '(21) 96666-5555',
            'oab' => 'RJ987654',
            'perfil' => 'advogado',
            'unidade_id' => $filialRj->id,
            'status' => 'ativo',
        ]);

        // Clientes Portal
        User::create([
            'nome' => 'Cliente Teste',
            'email' => 'cliente@teste.com',
            'password' => Hash::make('123456'),
            'cpf' => '12345678900',
            'telefone' => '(11) 96666-4444',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Carlos Eduardo Pereira',
            'email' => 'carlos.pereira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '98765432100',
            'telefone' => '(11) 95555-5555',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Tech Solutions Ltda',
            'email' => 'contato@techsolutions.com',
            'password' => Hash::make('123456'),
            'cpf' => '11222333000144',
            'telefone' => '(11) 92222-8888',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Fernanda Santos',
            'email' => 'fernanda.santos@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '78945612300',
            'telefone' => '(21) 94444-5555',
            'perfil' => 'consulta',
            'unidade_id' => $filialRj->id,
            'status' => 'ativo',
        ]);

        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        $this->command->info('Seeder completo executado com sucesso!');
    }
}
EOF

echo "3. Criando seeders específicos para outras tabelas..."

cat > database/seeders/TribunaisSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TribunaisSeeder extends Seeder
{
    public function run()
    {
        $tribunais = [
            [
                'nome' => 'Tribunal de Justiça de São Paulo',
                'codigo' => 'TJSP',
                'tipo' => 'estadual',
                'estado' => 'SP',
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tribunal de Justiça do Rio de Janeiro',
                'codigo' => 'TJRJ',
                'tipo' => 'estadual',
                'estado' => 'RJ',
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Superior Tribunal de Justiça',
                'codigo' => 'STJ',
                'tipo' => 'superior',
                'estado' => null,
                'ativo' => true,
                'limite_consultas_dia' => 50,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('tribunais')->insert($tribunais);
    }
}
EOF

cat > database/seeders/KanbanSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class KanbanSeeder extends Seeder
{
    public function run()
    {
        $colunas = [
            ['nome' => 'A Fazer', 'ordem' => 1, 'cor' => '#6B7280', 'unidade_id' => 1],
            ['nome' => 'Em Andamento', 'ordem' => 2, 'cor' => '#3B82F6', 'unidade_id' => 1],
            ['nome' => 'Aguardando', 'ordem' => 3, 'cor' => '#F59E0B', 'unidade_id' => 1],
            ['nome' => 'Concluído', 'ordem' => 4, 'cor' => '#10B981', 'unidade_id' => 1],
            ['nome' => 'A Fazer', 'ordem' => 1, 'cor' => '#6B7280', 'unidade_id' => 2],
            ['nome' => 'Em Andamento', 'ordem' => 2, 'cor' => '#3B82F6', 'unidade_id' => 2],
            ['nome' => 'Concluído', 'ordem' => 3, 'cor' => '#10B981', 'unidade_id' => 2],
        ];

        foreach ($colunas as $coluna) {
            DB::table('kanban_colunas')->insert([
                'nome' => $coluna['nome'],
                'ordem' => $coluna['ordem'],
                'cor' => $coluna['cor'],
                'unidade_id' => $coluna['unidade_id'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
EOF

cat > database/seeders/ConfiguracoesSeeder.php << 'EOF'
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
EOF

echo "4. Atualizando DatabaseSeeder principal..."

cat > database/seeders/DatabaseSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            CompleteSystemSeeder::class,
            TribunaisSeeder::class,
            KanbanSeeder::class,
            ConfiguracoesSeeder::class,
        ]);
    }
}
EOF

echo "5. Executando seeders..."

php artisan db:seed --force

echo "6. Testando dados criados..."

php artisan tinker --execute="
echo 'Unidades: ' . \App\Models\Unidade::count() . \"\n\";
echo 'Usuários: ' . \App\Models\User::count() . \"\n\";
echo 'Admins: ' . \App\Models\User::where('perfil', 'LIKE', 'admin%')->count() . \"\n\";
echo 'Clientes: ' . \App\Models\User::where('perfil', 'consulta')->count() . \"\n\";
"

echo ""
echo "SCRIPT 114K CONCLUÍDO!"
echo ""
echo "DADOS CRIADOS:"
echo "- 3 Unidades (Matriz SP, Filial RJ, Filial BH)"
echo "- 10 Usuários (1 admin geral, 2 admin unidades, 2 advogados, 4 clientes)"
echo "- Tribunais básicos (TJSP, TJRJ, STJ)"
echo "- Colunas Kanban para cada unidade"
echo "- Configurações do sistema"
echo ""
echo "USUÁRIOS PARA TESTE:"
echo "Admin: admin@erlene.com / 123456"
echo "Cliente: cliente@teste.com / 123456"
echo ""
echo "PRÓXIMO: Script 114l - Conectar frontend"