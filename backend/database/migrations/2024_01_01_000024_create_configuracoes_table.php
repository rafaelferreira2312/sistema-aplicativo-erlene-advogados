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
