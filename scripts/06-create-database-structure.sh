#!/bin/bash

# Script 06 - Criação da Estrutura do Banco de Dados
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/06-create-database-structure.sh (executado da raiz do projeto)

echo "🚀 Criando estrutura completa do banco de dados..."

# Criar docker-compose.yml com portas altas
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # MySQL Database - Porta Alta
  mysql:
    image: mysql:8.0
    container_name: erlene_mysql
    restart: unless-stopped
    ports:
      - "33006:3306"  # Porta alta para MySQL
    environment:
      MYSQL_DATABASE: erlene_advogados
      MYSQL_ROOT_PASSWORD: erlene2024@root
      MYSQL_USER: erlene_user
      MYSQL_PASSWORD: erlene2024@user
    volumes:
      - mysql_data:/var/lib/mysql
      - ./docker/mysql/my.cnf:/etc/mysql/conf.d/my.cnf
      - ./docker/mysql/init.sql:/docker-entrypoint-initdb.d/01-init.sql
    networks:
      - erlene_network

  # PHP/Laravel Backend - Porta Alta
  backend:
    build:
      context: ./docker/php
      dockerfile: Dockerfile
    container_name: erlene_backend
    restart: unless-stopped
    ports:
      - "9001:9000"  # Porta alta para PHP-FPM
    volumes:
      - ./backend:/var/www/html
      - ./docker/php/php.ini:/usr/local/etc/php/php.ini
    depends_on:
      - mysql
    networks:
      - erlene_network
    environment:
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_DATABASE=erlene_advogados
      - DB_USERNAME=erlene_user
      - DB_PASSWORD=erlene2024@user

  # Nginx Web Server - Porta Alta
  nginx:
    build:
      context: ./docker/nginx
      dockerfile: Dockerfile
    container_name: erlene_nginx
    restart: unless-stopped
    ports:
      - "8080:80"   # Porta alta para HTTP
      - "8443:443"  # Porta alta para HTTPS
    volumes:
      - ./backend:/var/www/html
      - ./frontend/build:/var/www/frontend
      - ./docker/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf
      - ./ssl:/etc/ssl/certs
    depends_on:
      - backend
    networks:
      - erlene_network

  # React Frontend (Desenvolvimento)
  frontend:
    build:
      context: ./docker/node
      dockerfile: Dockerfile
    container_name: erlene_frontend
    restart: unless-stopped
    ports:
      - "3000:3000"  # Porta padrão React (dev)
    volumes:
      - ./frontend:/app
      - /app/node_modules
    networks:
      - erlene_network
    environment:
      - REACT_APP_API_URL=http://localhost:8080/api
      - CHOKIDAR_USEPOLLING=true

  # Redis Cache (Opcional)
  # redis:
  #   image: redis:7-alpine
  #   container_name: erlene_redis
  #   restart: unless-stopped
  #   ports:
  #     - "6379:6379"
  #   networks:
  #     - erlene_network

volumes:
  mysql_data:

networks:
  erlene_network:
    driver: bridge
EOF

# Criar configuração MySQL
mkdir -p docker/mysql
cat > docker/mysql/my.cnf << 'EOF'
[mysqld]
default-authentication-plugin=mysql_native_password
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
max_connections=200
innodb_buffer_pool_size=256M
innodb_log_file_size=64M
slow_query_log=1
long_query_time=2
EOF

# Criar script de inicialização do MySQL
cat > docker/mysql/init.sql << 'EOF'
-- Criar banco de dados principal
CREATE DATABASE IF NOT EXISTS `erlene_advogados` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criar banco de dados de teste
CREATE DATABASE IF NOT EXISTS `erlene_advogados_test` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Garantir permissões
GRANT ALL PRIVILEGES ON `erlene_advogados`.* TO 'erlene_user'@'%';
GRANT ALL PRIVILEGES ON `erlene_advogados_test`.* TO 'erlene_user'@'%';

FLUSH PRIVILEGES;
EOF

# Criar migrations do Laravel
mkdir -p backend/database/migrations

# Migration 01 - Unidades (Matriz e Filiais)
cat > backend/database/migrations/2024_01_01_000001_create_unidades_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('unidades', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cnpj', 18)->unique();
            $table->text('endereco');
            $table->string('cep', 9);
            $table->string('cidade');
            $table->string('estado', 2);
            $table->string('telefone', 15);
            $table->string('email');
            $table->unsignedBigInteger('matriz_id')->nullable();
            $table->boolean('is_matriz')->default(false);
            $table->enum('status', ['ativo', 'inativo'])->default('ativo');
            $table->timestamps();

            $table->foreign('matriz_id')->references('id')->on('unidades');
            $table->index(['status', 'is_matriz']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('unidades');
    }
};
EOF

# Migration 02 - Usuários do Sistema
cat > backend/database/migrations/2024_01_01_000002_create_users_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->string('cpf', 14)->unique();
            $table->string('oab')->nullable();
            $table->string('telefone', 15);
            $table->enum('perfil', [
                'admin_geral', 
                'admin_unidade', 
                'advogado', 
                'secretario', 
                'financeiro', 
                'consulta'
            ]);
            $table->unsignedBigInteger('unidade_id');
            $table->enum('status', ['ativo', 'inativo'])->default('ativo');
            $table->timestamp('ultimo_acesso')->nullable();
            $table->rememberToken();
            $table->timestamps();

            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['email', 'status']);
            $table->index(['perfil', 'unidade_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
EOF

# Migration 03 - Clientes
cat > backend/database/migrations/2024_01_01_000003_create_clientes_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('clientes', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cpf_cnpj', 18)->unique();
            $table->enum('tipo_pessoa', ['PF', 'PJ']);
            $table->string('email');
            $table->string('telefone', 15);
            $table->text('endereco');
            $table->string('cep', 9);
            $table->string('cidade');
            $table->string('estado', 2);
            $table->text('observacoes')->nullable();
            $table->boolean('acesso_portal')->default(false);
            $table->string('senha_portal')->nullable();
            $table->enum('tipo_armazenamento', ['local', 'google_drive', 'onedrive'])->default('local');
            $table->json('google_drive_config')->nullable();
            $table->json('onedrive_config')->nullable();
            $table->string('pasta_local')->nullable();
            $table->unsignedBigInteger('unidade_id');
            $table->unsignedBigInteger('responsavel_id');
            $table->enum('status', ['ativo', 'inativo'])->default('ativo');
            $table->timestamps();

            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->foreign('responsavel_id')->references('id')->on('users');
            $table->index(['cpf_cnpj', 'status']);
            $table->index(['unidade_id', 'responsavel_id']);
            $table->index(['tipo_pessoa', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('clientes');
    }
};
EOF

# Migration 04 - Atendimentos
cat > backend/database/migrations/2024_01_01_000004_create_atendimentos_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('atendimentos', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->unsignedBigInteger('advogado_id');
            $table->datetime('data_hora');
            $table->enum('tipo', ['presencial', 'online', 'telefone']);
            $table->string('assunto');
            $table->text('descricao');
            $table->enum('status', ['agendado', 'em_andamento', 'concluido', 'cancelado'])->default('agendado');
            $table->integer('duracao')->nullable(); // em minutos
            $table->decimal('valor', 10, 2)->nullable();
            $table->text('proximos_passos')->nullable();
            $table->json('anexos')->nullable();
            $table->unsignedBigInteger('unidade_id');
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('advogado_id')->references('id')->on('users');
            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['data_hora', 'status']);
            $table->index(['cliente_id', 'advogado_id']);
            $table->index(['status', 'unidade_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('atendimentos');
    }
};
EOF

# Migration 05 - Processos
cat > backend/database/migrations/2024_01_01_000005_create_processos_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('processos', function (Blueprint $table) {
            $table->id();
            $table->string('numero', 25)->unique();
            $table->string('tribunal');
            $table->string('vara')->nullable();
            $table->unsignedBigInteger('cliente_id');
            $table->string('tipo_acao');
            $table->enum('status', [
                'distribuido',
                'em_andamento', 
                'suspenso',
                'arquivado',
                'finalizado'
            ])->default('distribuido');
            $table->decimal('valor_causa', 15, 2)->nullable();
            $table->date('data_distribuicao');
            $table->unsignedBigInteger('advogado_id');
            $table->unsignedBigInteger('unidade_id');
            $table->date('proximo_prazo')->nullable();
            $table->text('observacoes')->nullable();
            $table->enum('prioridade', ['baixa', 'media', 'alta', 'urgente'])->default('media');
            $table->integer('kanban_posicao')->default(0);
            $table->unsignedBigInteger('kanban_coluna_id')->nullable();
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('advogado_id')->references('id')->on('users');
            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['numero']);
            $table->index(['status', 'prioridade']);
            $table->index(['cliente_id', 'advogado_id']);
            $table->index(['proximo_prazo']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('processos');
    }
};
EOF

# Migration 06 - Relacionamento Atendimento-Processo (N:N)
cat > backend/database/migrations/2024_01_01_000006_create_atendimento_processos_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('atendimento_processos', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('atendimento_id');
            $table->unsignedBigInteger('processo_id');
            $table->text('observacoes')->nullable();
            $table->timestamps();

            $table->foreign('atendimento_id')->references('id')->on('atendimentos')->onDelete('cascade');
            $table->foreign('processo_id')->references('id')->on('processos')->onDelete('cascade');
            $table->unique(['atendimento_id', 'processo_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('atendimento_processos');
    }
};
EOF

# Migration 07 - Kanban Colunas
cat > backend/database/migrations/2024_01_01_000007_create_kanban_colunas_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('kanban_colunas', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->integer('ordem');
            $table->string('cor', 7)->default('#6B7280'); // hex color
            $table->unsignedBigInteger('unidade_id');
            $table->timestamps();

            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['unidade_id', 'ordem']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('kanban_colunas');
    }
};
EOF

# Migration 08 - Kanban Cards
cat > backend/database/migrations/2024_01_01_000008_create_kanban_cards_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('kanban_cards', function (Blueprint $table) {
            $table->id();
            $table->string('titulo');
            $table->text('descricao')->nullable();
            $table->unsignedBigInteger('coluna_id');
            $table->unsignedBigInteger('processo_id')->nullable();
            $table->unsignedBigInteger('tarefa_id')->nullable();
            $table->integer('posicao');
            $table->enum('prioridade', ['baixa', 'media', 'alta', 'urgente'])->default('media');
            $table->date('prazo')->nullable();
            $table->unsignedBigInteger('responsavel_id');
            $table->timestamps();

            $table->foreign('coluna_id')->references('id')->on('kanban_colunas');
            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->foreign('responsavel_id')->references('id')->on('users');
            $table->index(['coluna_id', 'posicao']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('kanban_cards');
    }
};
EOF

# Migration 09 - Tarefas/Atividades
cat > backend/database/migrations/2024_01_01_000009_create_tarefas_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('tarefas', function (Blueprint $table) {
            $table->id();
            $table->string('titulo');
            $table->text('descricao')->nullable();
            $table->enum('tipo', ['geral', 'processo', 'cliente', 'administrativo']);
            $table->enum('status', ['pendente', 'em_andamento', 'concluida', 'cancelada'])->default('pendente');
            $table->datetime('prazo')->nullable();
            $table->unsignedBigInteger('responsavel_id');
            $table->unsignedBigInteger('cliente_id')->nullable();
            $table->unsignedBigInteger('processo_id')->nullable();
            $table->integer('kanban_posicao')->default(0);
            $table->timestamps();

            $table->foreign('responsavel_id')->references('id')->on('users');
            $table->foreign('cliente_id')->references('id')->on('clientes')->nullOnDelete();
            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->index(['status', 'prazo']);
            $table->index(['responsavel_id', 'tipo']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('tarefas');
    }
};
EOF

# Migration 10 - Movimentações de Processo
cat > backend/database/migrations/2024_01_01_000010_create_movimentacoes_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('movimentacoes', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('processo_id');
            $table->datetime('data');
            $table->text('descricao');
            $table->enum('tipo', ['automatica', 'manual', 'tribunal']);
            $table->string('documento_url')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->foreign('processo_id')->references('id')->on('processos')->onDelete('cascade');
            $table->index(['processo_id', 'data']);
            $table->index(['tipo', 'data']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('movimentacoes');
    }
};
EOF

echo "✅ Primeiras 10 migrations criadas!"
echo "📊 Progresso: 10/25 migrations do banco de dados"
echo ""
echo "⏭️  Continue executando para criar as próximas migrations..."