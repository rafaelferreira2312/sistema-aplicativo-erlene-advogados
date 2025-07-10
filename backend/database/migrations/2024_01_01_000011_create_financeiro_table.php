<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('financeiro', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('processo_id')->nullable();
            $table->unsignedBigInteger('atendimento_id')->nullable();
            $table->unsignedBigInteger('cliente_id');
            $table->enum('tipo', [
                'honorario', 
                'consulta', 
                'custas', 
                'despesa', 
                'receita_extra'
            ]);
            $table->decimal('valor', 10, 2);
            $table->date('data_vencimento');
            $table->date('data_pagamento')->nullable();
            $table->enum('status', [
                'pendente', 
                'pago', 
                'atrasado', 
                'cancelado', 
                'parcial'
            ])->default('pendente');
            $table->text('descricao');
            $table->enum('gateway', ['stripe', 'mercadopago', 'manual'])->nullable();
            $table->string('transaction_id')->nullable();
            $table->json('gateway_response')->nullable();
            $table->unsignedBigInteger('unidade_id');
            $table->timestamps();

            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->foreign('atendimento_id')->references('id')->on('atendimentos')->nullOnDelete();
            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('unidade_id')->references('id')->on('unidades');
            $table->index(['status', 'data_vencimento']);
            $table->index(['cliente_id', 'tipo']);
            $table->index(['gateway', 'transaction_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('financeiro');
    }
};
