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
