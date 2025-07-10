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
