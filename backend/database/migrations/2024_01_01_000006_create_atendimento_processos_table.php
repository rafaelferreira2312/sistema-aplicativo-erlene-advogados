<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('atendimento_processos', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('atendimento_id');
            $table->unsignedBigInteger('processo_id');
            $table->text('observacoes')->nullable();
            $table->timestamps();

            $table->foreign('atendimento_id')->references('id')->on('atendimentos')->onDelete('cascade');
            $table->foreign('processo_id')->references('id')->on('processos')->onDelete('cascade');
            $table->unique(['atendimento_id', 'processo_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('atendimento_processos');
    }
};
