#!/bin/bash

# Script 07 - Criação da Estrutura do Banco de Dados (Parte 2)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/07-create-database-structure-part2.sh (executado da raiz do projeto)

echo "🚀 Continuando criação das migrations do banco de dados (Parte 2)..."

# Migration 11 - Sistema Financeiro
cat > backend/database/migrations/2024_01_01_000011_create_financeiro_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('financeiro', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('processo_id')->nullable();
            $table->unsignedBigInteger('atendimento_id')->nullable();
            $table->unsignedBigInteger('cliente_id');
            $table->enum('tipo', [
                'honorario', 
                'consulta', 
                'custas', 
                'despesa', 
                'receita_extra'
            ]);
            $table->decimal('valor', 10, 2);
            $table->date('data_vencimento');
            $table->date('data_pagamento')->nullable();
            $table->enum('status', [
                'pendente', 
                'pago', 
                'atrasado', 
                'cancelado', 
                'parcial'
            ])->default('pendente');
            $table->text('descricao');
            $table->enum('gateway', ['stripe', 'mercadopago', 'manual'])->nullable();
            $table->string('transaction_id')->nullable();
            $table->json('gateway_response')->nullable();
            $table->unsignedBigInteger('unidade_id');
            $table->timestamps();

            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->foreign('atendimento_id')->references('id')->on('atendimentos')->nullOnDelete();
            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['status', 'data_vencimento']);
            $table->index(['cliente_id', 'tipo']);
            $table->index(['gateway', 'transaction_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('financeiro');
    }
};
EOF

# Migration 12 - Documentos GED
cat > backend/database/migrations/2024_01_01_000012_create_documentos_ged_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('documentos_ged', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->string('pasta'); // nome da pasta do cliente
            $table->string('nome_arquivo');
            $table->string('nome_original');
            $table->string('caminho');
            $table->string('tipo_arquivo', 10); // pdf, doc, jpg, etc
            $table->string('mime_type');
            $table->bigInteger('tamanho'); // em bytes
            $table->datetime('data_upload');
            $table->unsignedBigInteger('usuario_id'); // quem fez upload
            $table->integer('versao')->default(1);
            $table->enum('storage_type', ['local', 'google_drive', 'onedrive']);
            $table->string('google_drive_id')->nullable();
            $table->string('onedrive_id')->nullable();
            $table->json('tags')->nullable();
            $table->text('descricao')->nullable();
            $table->boolean('publico')->default(false);
            $table->string('hash_arquivo')->nullable(); // para verificar integridade
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('usuario_id')->references('id')->on('users');
            $table->index(['cliente_id', 'storage_type']);
            $table->index(['tipo_arquivo', 'data_upload']);
            $table->index(['pasta', 'nome_arquivo']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('documentos_ged');
    }
};
EOF

# Migration 13 - Permissões GED
cat > backend/database/migrations/2024_01_01_000013_create_permissoes_ged_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('permissoes_ged', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->unsignedBigInteger('usuario_id');
            $table->enum('permissao', ['leitura', 'escrita', 'admin']);
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('usuario_id')->references('id')->on('users');
            $table->unique(['cliente_id', 'usuario_id']);
            $table->index(['usuario_id', 'permissao']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('permissoes_ged');
    }
};
EOF

# Migration 14 - Tribunais
cat > backend/database/migrations/2024_01_01_000014_create_tribunais_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('tribunais', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('codigo', 10)->unique(); // ex: TJSP, TRF3, etc
            $table->string('url_consulta')->nullable();
            $table->enum('tipo', ['estadual', 'federal', 'trabalhista', 'superior']);
            $table->string('estado', 2)->nullable();
            $table->json('config_api')->nullable(); // configurações específicas da API
            $table->boolean('ativo')->default(true);
            $table->integer('limite_consultas_dia')->default(100);
            $table->timestamps();

            $table->index(['codigo', 'ativo']);
            $table->index(['tipo', 'estado']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('tribunais');
    }
};
EOF

# Migration 15 - Pagamentos Stripe
cat > backend/database/migrations/2024_01_01_000015_create_pagamentos_stripe_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('pagamentos_stripe', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->unsignedBigInteger('processo_id')->nullable();
            $table->unsignedBigInteger('atendimento_id')->nullable();
            $table->unsignedBigInteger('financeiro_id');
            $table->decimal('valor', 10, 2);
            $table->string('moeda', 3)->default('BRL'); // BRL, USD, EUR
            $table->enum('status', [
                'pending',
                'processing', 
                'succeeded', 
                'failed', 
                'canceled',
                'refunded'
            ]);
            $table->string('stripe_payment_intent_id');
            $table->string('stripe_customer_id')->nullable();
            $table->string('stripe_charge_id')->nullable();
            $table->json('stripe_metadata')->nullable();
            $table->datetime('data_criacao');
            $table->datetime('data_pagamento')->nullable();
            $table->decimal('taxa_stripe', 8, 2)->nullable();
            $table->text('observacoes')->nullable();
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->foreign('atendimento_id')->references('id')->on('atendimentos')->nullOnDelete();
            $table->foreign('financeiro_id')->references('id')->on('financeiro');
            $table->index(['stripe_payment_intent_id']);
            $table->index(['status', 'data_criacao']);
            $table->index(['cliente_id', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('pagamentos_stripe');
    }
};
EOF

# Migration 16 - Pagamentos Mercado Pago
cat > backend/database/migrations/2024_01_01_000016_create_pagamentos_mp_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('pagamentos_mp', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->unsignedBigInteger('processo_id')->nullable();
            $table->unsignedBigInteger('atendimento_id')->nullable();
            $table->unsignedBigInteger('financeiro_id');
            $table->decimal('valor', 10, 2);
            $table->enum('tipo', ['pix', 'boleto', 'cartao_credito', 'cartao_debito']);
            $table->enum('status', [
                'pending',
                'approved', 
                'authorized',
                'in_process',
                'in_mediation',
                'rejected',
                'cancelled',
                'refunded',
                'charged_back'
            ]);
            $table->string('mp_payment_id')->nullable();
            $table->string('mp_preference_id')->nullable();
            $table->string('mp_external_reference')->nullable();
            $table->json('mp_metadata')->nullable();
            $table->datetime('data_criacao');
            $table->datetime('data_pagamento')->nullable();
            $table->datetime('data_vencimento')->nullable(); // para boleto
            $table->decimal('taxa_mp', 8, 2)->nullable();
            $table->string('linha_digitavel')->nullable(); // para boleto
            $table->string('qr_code')->nullable(); // para PIX
            $table->text('observacoes')->nullable();
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->foreign('atendimento_id')->references('id')->on('atendimentos')->nullOnDelete();
            $table->foreign('financeiro_id')->references('id')->on('financeiro');
            $table->index(['mp_payment_id']);
            $table->index(['status', 'tipo']);
            $table->index(['cliente_id', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('pagamentos_mp');
    }
};
EOF

# Migration 17 - Acesso Portal Cliente
cat > backend/database/migrations/2024_01_01_000017_create_acessos_portal_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('acessos_portal', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->string('ip', 45); // suporte IPv6
            $table->string('user_agent')->nullable();
            $table->datetime('data_acesso');
            $table->enum('acao', [
                'login',
                'logout', 
                'visualizar_processo',
                'download_documento',
                'upload_documento',
                'pagamento',
                'mensagem'
            ]);
            $table->string('detalhes')->nullable();
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->index(['cliente_id', 'data_acesso']);
            $table->index(['acao', 'data_acesso']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('acessos_portal');
    }
};
EOF

# Migration 18 - Sincronização Drives
cat > backend/database/migrations/2024_01_01_000018_create_sync_drives_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sync_drives', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->enum('tipo_drive', ['google_drive', 'onedrive']);
            $table->datetime('ultimo_sync');
            $table->enum('status', ['sucesso', 'erro', 'em_andamento']);
            $table->text('erro')->nullable();
            $table->integer('arquivos_sincronizados')->default(0);
            $table->json('arquivos_detalhes')->nullable();
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->index(['cliente_id', 'tipo_drive']);
            $table->index(['status', 'ultimo_sync']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('sync_drives');
    }
};
EOF

# Migration 19 - Chat/Mensagens
cat > backend/database/migrations/2024_01_01_000019_create_mensagens_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('mensagens', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('remetente_id')->nullable(); // null para sistema
            $table->unsignedBigInteger('destinatario_id')->nullable(); // null para broadcast
            $table->unsignedBigInteger('cliente_id')->nullable(); // contexto do cliente
            $table->unsignedBigInteger('processo_id')->nullable(); // contexto do processo
            $table->text('conteudo');
            $table->enum('tipo', [
                'texto',
                'arquivo', 
                'imagem',
                'audio',
                'video',
                'sistema'
            ])->default('texto');
            $table->string('arquivo_url')->nullable();
            $table->datetime('data_envio');
            $table->boolean('lida')->default(false);
            $table->datetime('data_leitura')->nullable();
            $table->boolean('importante')->default(false);
            $table->timestamps();

            $table->foreign('remetente_id')->references('id')->on('users')->nullOnDelete();
            $table->foreign('destinatario_id')->references('id')->on('users')->nullOnDelete();
            $table->foreign('cliente_id')->references('id')->on('clientes')->nullOnDelete();
            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->index(['destinatario_id', 'lida']);
            $table->index(['cliente_id', 'data_envio']);
            $table->index(['processo_id', 'data_envio']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('mensagens');
    }
};
EOF

# Migration 20 - Agenda/Calendário
cat > backend/database/migrations/2024_01_01_000020_create_agenda_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('agenda', function (Blueprint $table) {
            $table->id();
            $table->string('titulo');
            $table->text('descricao')->nullable();
            $table->datetime('data_inicio');
            $table->datetime('data_fim');
            $table->enum('tipo', [
                'audiencia',
                'reuniao', 
                'consulta',
                'prazo',
                'lembrete',
                'evento'
            ]);
            $table->unsignedBigInteger('cliente_id')->nullable();
            $table->unsignedBigInteger('processo_id')->nullable();
            $table->unsignedBigInteger('atendimento_id')->nullable();
            $table->unsignedBigInteger('usuario_id'); // responsável
            $table->boolean('dia_inteiro')->default(false);
            $table->integer('lembrete')->nullable(); // minutos antes
            $table->boolean('lembrete_enviado')->default(false);
            $table->string('google_event_id')->nullable();
            $table->string('cor', 7)->default('#3B82F6'); // hex color
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes')->nullOnDelete();
            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->foreign('atendimento_id')->references('id')->on('atendimentos')->nullOnDelete();
            $table->foreign('usuario_id')->references('id')->on('users');
            $table->index(['usuario_id', 'data_inicio']);
            $table->index(['tipo', 'data_inicio']);
            $table->index(['data_inicio', 'data_fim']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('agenda');
    }
};
EOF

echo "✅ Migrations 11-20 criadas com sucesso!"
echo "📊 Progresso: 20/25 migrations do banco de dados"
echo ""
echo "⏭️  Continue executando para criar as últimas 5 migrations..."