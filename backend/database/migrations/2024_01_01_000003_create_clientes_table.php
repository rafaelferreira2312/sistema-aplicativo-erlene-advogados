<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('clientes', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cpf_cnpj', 18)->unique();
            $table->enum('tipo_pessoa', ['PF', 'PJ']);
            $table->string('email');
            $table->string('telefone', 15);
            $table->text('endereco');
            $table->string('cep', 9);
            $table->string('cidade');
            $table->string('estado', 2);
            $table->text('observacoes')->nullable();
            $table->boolean('acesso_portal')->default(false);
            $table->string('senha_portal')->nullable();
            $table->enum('tipo_armazenamento', ['local', 'google_drive', 'onedrive'])->default('local');
            $table->json('google_drive_config')->nullable();
            $table->json('onedrive_config')->nullable();
            $table->string('pasta_local')->nullable();
            $table->unsignedBigInteger('unidade_id');
            $table->unsignedBigInteger('responsavel_id');
            $table->enum('status', ['ativo', 'inativo'])->default('ativo');
            $table->timestamps();

            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->foreign('responsavel_id')->references('id')->on('users');
            $table->index(['cpf_cnpj', 'status']);
            $table->index(['unidade_id', 'responsavel_id']);
            $table->index(['tipo_pessoa', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('clientes');
    }
};
