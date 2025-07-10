<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('kanban_colunas', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->integer('ordem');
            $table->string('cor', 7)->default('#6B7280'); // hex color
            $table->unsignedBigInteger('unidade_id');
            $table->timestamps();

            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['unidade_id', 'ordem']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('kanban_colunas');
    }
};
