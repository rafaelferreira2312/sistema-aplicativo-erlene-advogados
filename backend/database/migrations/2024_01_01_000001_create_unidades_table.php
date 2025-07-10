<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('unidades', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cnpj', 18)->unique();
            $table->text('endereco');
            $table->string('cep', 9);
            $table->string('cidade');
            $table->string('estado', 2);
            $table->string('telefone', 15);
            $table->string('email');
            $table->unsignedBigInteger('matriz_id')->nullable();
            $table->boolean('is_matriz')->default(false);
            $table->enum('status', ['ativo', 'inativo'])->default('ativo');
            $table->timestamps();

            $table->foreign('matriz_id')->references('id')->on('unidades');
            $table->index(['status', 'is_matriz']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('unidades');
    }
};
