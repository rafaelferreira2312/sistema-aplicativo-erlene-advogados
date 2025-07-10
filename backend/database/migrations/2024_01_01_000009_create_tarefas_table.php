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
