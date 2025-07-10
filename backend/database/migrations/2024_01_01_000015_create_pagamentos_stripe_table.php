<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('pagamentos_stripe', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->unsignedBigInteger('processo_id')->nullable();
            $table->unsignedBigInteger('atendimento_id')->nullable();
            $table->unsignedBigInteger('financeiro_id');
            $table->decimal('valor', 10, 2);
            $table->string('moeda', 3)->default('BRL'); // BRL, USD, EUR
            $table->enum('status', [
                'pending',
                'processing', 
                'succeeded', 
                'failed', 
                'canceled',
                'refunded'
            ]);
            $table->string('stripe_payment_intent_id');
            $table->string('stripe_customer_id')->nullable();
            $table->string('stripe_charge_id')->nullable();
            $table->json('stripe_metadata')->nullable();
            $table->datetime('data_criacao');
            $table->datetime('data_pagamento')->nullable();
            $table->decimal('taxa_stripe', 8, 2)->nullable();
            $table->text('observacoes')->nullable();
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->foreign('atendimento_id')->references('id')->on('atendimentos')->nullOnDelete();
            $table->foreign('financeiro_id')->references('id')->on('financeiro');
            $table->index(['stripe_payment_intent_id']);
            $table->index(['status', 'data_criacao']);
            $table->index(['cliente_id', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('pagamentos_stripe');
    }
};
