<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('permissoes_ged', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->unsignedBigInteger('usuario_id');
            $table->enum('permissao', ['leitura', 'escrita', 'admin']);
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('usuario_id')->references('id')->on('users');
            $table->unique(['cliente_id', 'usuario_id']);
            $table->index(['usuario_id', 'permissao']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('permissoes_ged');
    }
};
