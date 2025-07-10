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
