#!/bin/bash

# Script 08 - Criação da Estrutura do Banco de Dados (Parte 3 - Final)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/08-create-database-structure-part3.sh (executado da raiz do projeto)

echo "🚀 Finalizando criação das migrations do banco de dados (Parte 3)..."

# Migration 21 - Integrações Externas
cat > backend/database/migrations/2024_01_01_000021_create_integracoes_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('integracoes', function (Blueprint $table) {
            $table->id();
            $table->enum('nome', [
                'cnj',
                'escavador', 
                'jurisbrasil',
                'google_drive',
                'onedrive',
                'google_calendar',
                'gmail',
                'stripe',
                'mercadopago',
                'chatgpt'
            ]);
            $table->boolean('ativo')->default(false);
            $table->json('configuracoes'); // chaves de API, tokens, etc
            $table->datetime('ultima_sincronizacao')->nullable();
            $table->enum('status', ['funcionando', 'erro', 'inativo'])->default('inativo');
            $table->text('ultimo_erro')->nullable();
            $table->integer('total_requisicoes')->default(0);
            $table->integer('requisicoes_sucesso')->default(0);
            $table->integer('requisicoes_erro')->default(0);
            $table->unsignedBigInteger('unidade_id');
            $table->timestamps();

            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->unique(['nome', 'unidade_id']);
            $table->index(['ativo', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('integracoes');
    }
};
EOF

# Migration 22 - Logs de Sistema
cat > backend/database/migrations/2024_01_01_000022_create_logs_sistema_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('logs_sistema', function (Blueprint $table) {
            $table->id();
            $table->enum('nivel', ['debug', 'info', 'warning', 'error', 'critical']);
            $table->string('categoria'); // auth, api, integration, etc
            $table->text('mensagem');
            $table->json('contexto')->nullable(); // dados adicionais
            $table->unsignedBigInteger('usuario_id')->nullable();
            $table->unsignedBigInteger('cliente_id')->nullable();
            $table->string('ip', 45)->nullable();
            $table->string('user_agent')->nullable();
            $table->string('request_id')->nullable(); // para rastrear requests
            $table->datetime('data_hora');
            $table->timestamps();

            $table->foreign('usuario_id')->references('id')->on('users')->nullOnDelete();
            $table->foreign('cliente_id')->references('id')->on('clientes')->nullOnDelete();
            $table->index(['nivel', 'categoria']);
            $table->index(['data_hora']);
            $table->index(['usuario_id', 'data_hora']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('logs_sistema');
    }
};
EOF

# Migration 23 - Notificações
cat > backend/database/migrations/2024_01_01_000023_create_notificacoes_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('notificacoes', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('usuario_id')->nullable();
            $table->unsignedBigInteger('cliente_id')->nullable();
            $table->string('titulo');
            $table->text('mensagem');
            $table->enum('tipo', [
                'prazo_vencendo',
                'novo_processo',
                'movimentacao',
                'pagamento',
                'documento',
                'mensagem',
                'sistema'
            ]);
            $table->enum('canal', ['sistema', 'email', 'sms', 'push', 'whatsapp']);
            $table->boolean('lida')->default(false);
            $table->datetime('data_leitura')->nullable();
            $table->boolean('enviada')->default(false);
            $table->datetime('data_envio')->nullable();
            $table->json('dados_extras')->nullable(); // IDs relacionados, URLs, etc
            $table->string('icone')->nullable();
            $table->string('cor', 7)->default('#3B82F6');
            $table->timestamps();

            $table->foreign('usuario_id')->references('id')->on('users')->nullOnDelete();
            $table->foreign('cliente_id')->references('id')->on('clientes')->nullOnDelete();
            $table->index(['usuario_id', 'lida']);
            $table->index(['cliente_id', 'lida']);
            $table->index(['tipo', 'canal']);
            $table->index(['enviada', 'created_at']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('notificacoes');
    }
};
EOF

# Migration 24 - Configurações do Sistema
cat > backend/database/migrations/2024_01_01_000024_create_configuracoes_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('configuracoes', function (Blueprint $table) {
            $table->id();
            $table->string('chave')->unique();
            $table->text('valor')->nullable();
            $table->enum('tipo', ['string', 'integer', 'boolean', 'json', 'text']);
            $table->string('categoria'); // sistema, email, integracao, etc
            $table->text('descricao')->nullable();
            $table->boolean('requer_reinicio')->default(false);
            $table->unsignedBigInteger('unidade_id')->nullable(); // null = global
            $table->timestamps();

            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['categoria']);
            $table->index(['unidade_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('configuracoes');
    }
};
EOF

# Migration 25 - Sessões de Usuários
cat > backend/database/migrations/2024_01_01_000025_create_user_sessions_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('user_sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->text('payload');
            $table->integer('last_activity');
            $table->enum('tipo_dispositivo', ['web', 'mobile'])->default('web');
            $table->string('device_name')->nullable();
            $table->boolean('ativo')->default(true);
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->index(['user_id']);
            $table->index(['last_activity']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('user_sessions');
    }
};
EOF

# Criar Seeders para dados iniciais
mkdir -p backend/database/seeders

# Seeder principal
cat > backend/database/seeders/DatabaseSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        $this->call([
            UnidadeSeeder::class,
            UserSeeder::class,
            TribunalSeeder::class,
            KanbanColunasSeeder::class,
            ConfiguracoesSeeder::class,
        ]);
    }
}
EOF

# Seeder de Unidades
cat > backend/database/seeders/UnidadeSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UnidadeSeeder extends Seeder
{
    public function run()
    {
        DB::table('unidades')->insert([
            [
                'id' => 1,
                'nome' => 'Erlene Chaves Silva Advogados - Matriz',
                'cnpj' => '12.345.678/0001-90',
                'endereco' => 'Rua Principal, 123, Centro',
                'cep' => '12345-678',
                'cidade' => 'São Paulo',
                'estado' => 'SP',
                'telefone' => '(11) 98765-4321',
                'email' => 'contato@erleneadvogados.com',
                'matriz_id' => null,
                'is_matriz' => true,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
EOF

# Seeder de Usuários
cat > backend/database/seeders/UserSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run()
    {
        DB::table('users')->insert([
            [
                'nome' => 'Dra. Erlene Chaves Silva',
                'email' => 'erlene@erleneadvogados.com',
                'password' => Hash::make('erlene2024@admin'),
                'cpf' => '123.456.789-00',
                'oab' => 'SP123456',
                'telefone' => '(11) 98765-4321',
                'perfil' => 'admin_geral',
                'unidade_id' => 1,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nome' => 'Administrador Sistema',
                'email' => 'admin@erleneadvogados.com',
                'password' => Hash::make('admin123@erlene'),
                'cpf' => '987.654.321-00',
                'telefone' => '(11) 98765-4322',
                'perfil' => 'admin_geral',
                'unidade_id' => 1,
                'status' => 'ativo',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
EOF

# Seeder de Tribunais
cat > backend/database/seeders/TribunalSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TribunalSeeder extends Seeder
{
    public function run()
    {
        $tribunais = [
            ['nome' => 'Tribunal de Justiça de São Paulo', 'codigo' => 'TJSP', 'tipo' => 'estadual', 'estado' => 'SP'],
            ['nome' => 'Tribunal de Justiça do Rio de Janeiro', 'codigo' => 'TJRJ', 'tipo' => 'estadual', 'estado' => 'RJ'],
            ['nome' => 'Tribunal Regional Federal da 3ª Região', 'codigo' => 'TRF3', 'tipo' => 'federal', 'estado' => 'SP'],
            ['nome' => 'Tribunal Superior do Trabalho', 'codigo' => 'TST', 'tipo' => 'superior', 'estado' => null],
            ['nome' => 'Superior Tribunal de Justiça', 'codigo' => 'STJ', 'tipo' => 'superior', 'estado' => null],
            ['nome' => 'Supremo Tribunal Federal', 'codigo' => 'STF', 'tipo' => 'superior', 'estado' => null],
        ];

        foreach ($tribunais as $tribunal) {
            DB::table('tribunais')->insert([
                'nome' => $tribunal['nome'],
                'codigo' => $tribunal['codigo'],
                'tipo' => $tribunal['tipo'],
                'estado' => $tribunal['estado'],
                'ativo' => true,
                'limite_consultas_dia' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
EOF

# Seeder de Colunas Kanban
cat > backend/database/seeders/KanbanColunasSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class KanbanColunasSeeder extends Seeder
{
    public function run()
    {
        $colunas = [
            ['nome' => 'A Fazer', 'ordem' => 1, 'cor' => '#6B7280'],
            ['nome' => 'Em Andamento', 'ordem' => 2, 'cor' => '#3B82F6'],
            ['nome' => 'Aguardando', 'ordem' => 3, 'cor' => '#F59E0B'],
            ['nome' => 'Concluído', 'ordem' => 4, 'cor' => '#10B981'],
        ];

        foreach ($colunas as $coluna) {
            DB::table('kanban_colunas')->insert([
                'nome' => $coluna['nome'],
                'ordem' => $coluna['ordem'],
                'cor' => $coluna['cor'],
                'unidade_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
EOF

# Seeder de Configurações
cat > backend/database/seeders/ConfiguracoesSeeder.php << 'EOF'
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
            ['chave' => 'email.usuario', 'valor' => '', 'tipo' => 'string', 'categoria' => 'email'],
            
            // Integrações
            ['chave' => 'stripe.public_key', 'valor' => '', 'tipo' => 'string', 'categoria' => 'integracao'],
            ['chave' => 'stripe.secret_key', 'valor' => '', 'tipo' => 'string', 'categoria' => 'integracao'],
            ['chave' => 'mercadopago.public_key', 'valor' => '', 'tipo' => 'string', 'categoria' => 'integracao'],
            ['chave' => 'mercadopago.access_token', 'valor' => '', 'tipo' => 'string', 'categoria' => 'integracao'],
            ['chave' => 'chatgpt.api_key', 'valor' => '', 'tipo' => 'string', 'categoria' => 'integracao'],
            
            // Backup
            ['chave' => 'backup.automatico', 'valor' => 'true', 'tipo' => 'boolean', 'categoria' => 'backup'],
            ['chave' => 'backup.retencao_dias', 'valor' => '30', 'tipo' => 'integer', 'categoria' => 'backup'],
        ];

        foreach ($configuracoes as $config) {
            DB::table('configuracoes')->insert([
                'chave' => $config['chave'],
                'valor' => $config['valor'],
                'tipo' => $config['tipo'],
                'categoria' => $config['categoria'],
                'unidade_id' => null, // global
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
EOF

# Criar arquivo .env para o backend
cat > backend/.env << 'EOF'
APP_NAME="Sistema Erlene Advogados"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8080

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=erlene_advogados
DB_USERNAME=erlene_user
DB_PASSWORD=erlene2024@user

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DRIVER=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=database
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@erleneadvogados.com"
MAIL_FROM_NAME="${APP_NAME}"

# JWT
JWT_SECRET=
JWT_TTL=60

# Stripe
STRIPE_PUBLIC_KEY=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=

# Mercado Pago
MERCADOPAGO_PUBLIC_KEY=
MERCADOPAGO_ACCESS_TOKEN=
MERCADOPAGO_WEBHOOK_SECRET=

# Google APIs
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=

# Microsoft APIs
MICROSOFT_CLIENT_ID=
MICROSOFT_CLIENT_SECRET=
MICROSOFT_REDIRECT_URI=

# OpenAI ChatGPT
OPENAI_API_KEY=

# CNJ API
CNJ_API_KEY=
CNJ_API_URL=

# Escavador API
ESCAVADOR_API_KEY=
ESCAVADOR_API_URL=

# Jurisbrasil API
JURISBRASIL_API_KEY=
JURISBRASIL_API_URL=
EOF

echo "✅ Estrutura completa do banco de dados criada!"
echo ""
echo "📊 RESUMO FINAL - 25 MIGRATIONS:"
echo "   1-10:  Core (Unidades, Users, Clientes, Processos, Kanban)"
echo "   11-20: Financeiro, GED, Tribunais, Pagamentos, Chat, Agenda"
echo "   21-25: Integrações, Logs, Notificações, Configurações, Sessões"
echo ""
echo "🌱 SEEDERS CRIADOS:"
echo "   • UnidadeSeeder - Matriz da Dra. Erlene"
echo "   • UserSeeder - Admin e Dra. Erlene"
echo "   • TribunalSeeder - 6 tribunais principais"
echo "   • KanbanColunasSeeder - Colunas padrão"
echo "   • ConfiguracoesSeeder - Configurações iniciais"
echo ""
echo "⚙️ ARQUIVOS DE CONFIGURAÇÃO:"
echo "   • docker-compose.yml - Portas altas configuradas"
echo "   • backend/.env - Todas as variáveis de ambiente"
echo "   • Configurações MySQL, Nginx e PHP"
echo ""
echo "🎉 BANCO DE DADOS COMPLETO!"
echo "⏭️  Próximo: Execute o script de criação dos arquivos do backend"