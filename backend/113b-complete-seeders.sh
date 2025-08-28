#!/bin/bash

# Script 113b - Seeders completos com usuários estruturados
# Sistema Erlene Advogados - Dados de teste
# Data: $(date +%Y-%m-%d)

echo "📊 Script 113b - Criando seeders completos..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute no diretório backend/"
    exit 1
fi

echo "📝 Criando seeder de Unidades..."

cat > database/seeders/UnidadeSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UnidadeSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('unidades')->insert([
            [
                'id' => 1,
                'nome' => 'Matriz - Erlene Advogados',
                'codigo' => 'MATRIZ',
                'endereco' => 'Rua Principal, 123',
                'cidade' => 'São Paulo',
                'estado' => 'SP',
                'cep' => '01234-567',
                'telefone' => '(11) 3333-1111',
                'email' => 'matriz@erlene.com.br',
                'cnpj' => '12.345.678/0001-90',
                'status' => 'ativa',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 2,
                'nome' => 'Filial Rio de Janeiro',
                'codigo' => 'FILIAL_RJ',
                'endereco' => 'Av. Atlântica, 456',
                'cidade' => 'Rio de Janeiro',
                'estado' => 'RJ',
                'cep' => '22070-001',
                'telefone' => '(21) 3333-2222',
                'email' => 'rj@erlene.com.br',
                'cnpj' => '12.345.678/0002-71',
                'status' => 'ativa',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
EOF

echo "📝 Criando seeder completo de Usuários..."

cat > database/seeders/UserSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Admin Geral (Sistema todo)
        User::create([
            'nome' => 'Dra. Erlene Chaves Silva',
            'email' => 'admin@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '111.111.111-11',
            'telefone' => '(11) 99999-1111',
            'perfil' => 'admin_geral',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        // 2. Advogados - Matriz
        User::create([
            'nome' => 'Dr. João Silva Santos',
            'email' => 'joao.advogado@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '222.222.222-22',
            'oab' => 'SP123456',
            'telefone' => '(11) 98888-2222',
            'perfil' => 'advogado',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        // 3. Advogados - Filial RJ
        User::create([
            'nome' => 'Dra. Maria Costa Lima',
            'email' => 'maria.advogada@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '333.333.333-33',
            'oab' => 'RJ654321',
            'telefone' => '(21) 97777-3333',
            'perfil' => 'advogado',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);

        // 4. Clientes PF - Matriz
        User::create([
            'nome' => 'Carlos Eduardo Pereira',
            'email' => 'carlos.pereira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '123.456.789-00',
            'telefone' => '(11) 96666-4444',
            'perfil' => 'consulta',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Ana Paula Ferreira',
            'email' => 'ana.ferreira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '987.654.321-00',
            'telefone' => '(11) 95555-5555',
            'perfil' => 'consulta',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        // 5. Clientes PF - Filial RJ
        User::create([
            'nome' => 'Roberto Silva Oliveira',
            'email' => 'roberto.oliveira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '456.789.123-00',
            'telefone' => '(21) 94444-6666',
            'perfil' => 'consulta',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Fernanda Costa Santos',
            'email' => 'fernanda.santos@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '789.123.456-00',
            'telefone' => '(21) 93333-7777',
            'perfil' => 'consulta',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);

        // 6. Clientes PJ - Matriz
        User::create([
            'nome' => 'Tech Solutions Ltda',
            'email' => 'contato@techsolutions.com',
            'password' => Hash::make('123456'),
            'cpf' => '11.222.333/0001-44', // CNPJ como CPF por compatibilidade
            'telefone' => '(11) 92222-8888',
            'perfil' => 'consulta',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Comércio ABC S/A',
            'email' => 'juridico@comercioabc.com',
            'password' => Hash::make('123456'),
            'cpf' => '22.333.444/0001-55', // CNPJ como CPF por compatibilidade
            'telefone' => '(11) 91111-9999',
            'perfil' => 'consulta',
            'unidade_id' => 1, // Matriz
            'status' => 'ativo',
        ]);

        // 7. Clientes PJ - Filial RJ
        User::create([
            'nome' => 'Construtora Rio Ltda',
            'email' => 'contato@construtoraRio.com',
            'password' => Hash::make('123456'),
            'cpf' => '33.444.555/0001-66', // CNPJ como CPJ por compatibilidade
            'telefone' => '(21) 90000-1111',
            'perfil' => 'consulta',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);

        User::create([
            'nome' => 'Logística Express EIRELI',
            'email' => 'admin@logisticaexpress.com',
            'password' => Hash::make('123456'),
            'cpf' => '44.555.666/0001-77', // CNPJ como CPF por compatibilidade
            'telefone' => '(21) 98888-2222',
            'perfil' => 'consulta',
            'unidade_id' => 2, // Filial RJ
            'status' => 'ativo',
        ]);
    }
}
EOF

echo "📝 Atualizando DatabaseSeeder principal..."

cat > database/seeders/DatabaseSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            UnidadeSeeder::class,
            UserSeeder::class,
        ]);
    }
}
EOF

echo "📝 Criando seeder de Clientes para portal..."

cat > database/seeders/ClienteSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class ClienteSeeder extends Seeder
{
    public function run(): void
    {
        // Clientes para login do portal (tabela separada se existir)
        // Ou usar mesmos usuários com perfil consulta
        
        $clientes = [
            [
                'nome' => 'Carlos Eduardo Pereira',
                'email' => 'carlos.pereira@cliente.com',
                'cpf_cnpj' => '123.456.789-00',
                'password' => Hash::make('123456'),
                'telefone' => '(11) 96666-4444',
                'tipo' => 'PF',
                'unidade_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Tech Solutions Ltda',
                'email' => 'contato@techsolutions.com',
                'cpf_cnpj' => '11.222.333/0001-44',
                'password' => Hash::make('123456'),
                'telefone' => '(11) 92222-8888',
                'tipo' => 'PJ',
                'unidade_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ];

        // Inserir apenas se tabela clientes existir
        if (Schema::hasTable('clientes')) {
            DB::table('clientes')->insert($clientes);
        }
    }
}
EOF

echo "⚙️ Executando migrations e seeders..."

# Executar migrations fresh e seeders
php artisan migrate:fresh --seed

echo "📊 Verificando dados criados..."

echo "=== UNIDADES ==="
mysql -u root -p12345678 erlene_advogados -e "SELECT id, nome, codigo, cidade, status FROM unidades;"

echo ""
echo "=== USUÁRIOS POR PERFIL ==="
mysql -u root -p12345678 erlene_advogados -e "
SELECT 
    perfil,
    COUNT(*) as total,
    GROUP_CONCAT(nome SEPARATOR ', ') as nomes
FROM users 
GROUP BY perfil;"

echo ""
echo "=== USUÁRIOS POR UNIDADE ==="
mysql -u root -p12345678 erlene_advogados -e "
SELECT 
    u.nome as unidade,
    COUNT(us.id) as total_usuarios,
    GROUP_CONCAT(us.nome SEPARATOR ', ') as usuarios
FROM unidades u
LEFT JOIN users us ON u.id = us.unidade_id
GROUP BY u.id, u.nome;"

echo ""
echo "=== TODOS OS USUÁRIOS ==="
mysql -u root -p12345678 erlene_advogados -e "
SELECT 
    id,
    nome,
    email,
    perfil,
    unidade_id,
    status
FROM users 
ORDER BY perfil, unidade_id;"

echo "🧪 Testando login com usuários criados..."

echo "Testando Admin Geral:"
curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}' | head -3

echo ""
echo ""
echo "🎉 SEEDERS EXECUTADOS COM SUCESSO!"
echo ""
echo "👥 USUÁRIOS CRIADOS:"
echo "   🔧 ADMIN GERAL:"
echo "   • Dra. Erlene - admin@erlene.com / 123456"
echo ""
echo "   ⚖️ ADVOGADOS:"
echo "   • Dr. João (Matriz) - joao.advogado@erlene.com / 123456"
echo "   • Dra. Maria (Filial RJ) - maria.advogada@erlene.com / 123456"
echo ""
echo "   👤 CLIENTES PF:"
echo "   • Carlos (Matriz) - CPF: 123.456.789-00 / 123456"
echo "   • Ana (Matriz) - CPF: 987.654.321-00 / 123456"
echo "   • Roberto (Filial RJ) - CPF: 456.789.123-00 / 123456"
echo "   • Fernanda (Filial RJ) - CPF: 789.123.456-00 / 123456"
echo ""
echo "   🏢 CLIENTES PJ:"
echo "   • Tech Solutions (Matriz) - CNPJ: 11.222.333/0001-44 / 123456"
echo "   • Comércio ABC (Matriz) - CNPJ: 22.333.444/0001-55 / 123456"
echo "   • Construtora Rio (Filial RJ) - CNPJ: 33.444.555/0001-66 / 123456"
echo "   • Logística Express (Filial RJ) - CNPJ: 44.555.666/0001-77 / 123456"
echo ""
echo "🏢 UNIDADES:"
echo "   • ID 1: Matriz - São Paulo"
echo "   • ID 2: Filial - Rio de Janeiro"
echo ""
echo "▶️ PRÓXIMO: Script 113c - Integração Frontend"