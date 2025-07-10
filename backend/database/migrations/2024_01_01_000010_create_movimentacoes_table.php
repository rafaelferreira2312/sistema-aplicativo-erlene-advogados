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
