<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('tribunais', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('codigo', 10)->unique(); // ex: TJSP, TRF3, etc
            $table->string('url_consulta')->nullable();
            $table->enum('tipo', ['estadual', 'federal', 'trabalhista', 'superior']);
            $table->string('estado', 2)->nullable();
            $table->json('config_api')->nullable(); // configurações específicas da API
            $table->boolean('ativo')->default(true);
            $table->integer('limite_consultas_dia')->default(100);
            $table->timestamps();

            $table->index(['codigo', 'ativo']);
            $table->index(['tipo', 'estado']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('tribunais');
    }
};
