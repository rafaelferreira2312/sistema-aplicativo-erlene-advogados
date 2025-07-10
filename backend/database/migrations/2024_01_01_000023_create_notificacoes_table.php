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
