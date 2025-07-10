<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->string('cpf', 14)->unique();
            $table->string('oab')->nullable();
            $table->string('telefone', 15);
            $table->enum('perfil', [
                'admin_geral', 
                'admin_unidade', 
                'advogado', 
                'secretario', 
                'financeiro', 
                'consulta'
            ]);
            $table->unsignedBigInteger('unidade_id');
            $table->enum('status', ['ativo', 'inativo'])->default('ativo');
            $table->timestamp('ultimo_acesso')->nullable();
            $table->rememberToken();
            $table->timestamps();

            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['email', 'status']);
            $table->index(['perfil', 'unidade_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
