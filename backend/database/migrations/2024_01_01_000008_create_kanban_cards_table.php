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
