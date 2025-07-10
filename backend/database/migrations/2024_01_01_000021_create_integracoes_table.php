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
