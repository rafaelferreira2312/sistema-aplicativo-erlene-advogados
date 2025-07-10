<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('logs_sistema', function (Blueprint $table) {
            $table->id();
            $table->enum('nivel', ['debug', 'info', 'warning', 'error', 'critical']);
            $table->string('categoria'); // auth, api, integration, etc
            $table->text('mensagem');
            $table->json('contexto')->nullable(); // dados adicionais
            $table->unsignedBigInteger('usuario_id')->nullable();
            $table->unsignedBigInteger('cliente_id')->nullable();
            $table->string('ip', 45)->nullable();
            $table->string('user_agent')->nullable();
            $table->string('request_id')->nullable(); // para rastrear requests
            $table->datetime('data_hora');
            $table->timestamps();

            $table->foreign('usuario_id')->references('id')->on('users')->nullOnDelete();
            $table->foreign('cliente_id')->references('id')->on('clientes')->nullOnDelete();
            $table->index(['nivel', 'categoria']);
            $table->index(['data_hora']);
            $table->index(['usuario_id', 'data_hora']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('logs_sistema');
    }
};
