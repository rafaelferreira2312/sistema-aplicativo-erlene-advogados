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
