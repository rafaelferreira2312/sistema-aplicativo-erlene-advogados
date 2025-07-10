<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('pagamentos_mp', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->unsignedBigInteger('processo_id')->nullable();
            $table->unsignedBigInteger('atendimento_id')->nullable();
            $table->unsignedBigInteger('financeiro_id');
            $table->decimal('valor', 10, 2);
            $table->enum('tipo', ['pix', 'boleto', 'cartao_credito', 'cartao_debito']);
            $table->enum('status', [
                'pending',
                'approved', 
                'authorized',
                'in_process',
                'in_mediation',
                'rejected',
                'cancelled',
                'refunded',
                'charged_back'
            ]);
            $table->string('mp_payment_id')->nullable();
            $table->string('mp_preference_id')->nullable();
            $table->string('mp_external_reference')->nullable();
            $table->json('mp_metadata')->nullable();
            $table->datetime('data_criacao');
            $table->datetime('data_pagamento')->nullable();
            $table->datetime('data_vencimento')->nullable(); // para boleto
            $table->decimal('taxa_mp', 8, 2)->nullable();
            $table->string('linha_digitavel')->nullable(); // para boleto
            $table->string('qr_code')->nullable(); // para PIX
            $table->text('observacoes')->nullable();
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('processo_id')->references('id')->on('processos')->nullOnDelete();
            $table->foreign('atendimento_id')->references('id')->on('atendimentos')->nullOnDelete();
            $table->foreign('financeiro_id')->references('id')->on('financeiro');
            $table->index(['mp_payment_id']);
            $table->index(['status', 'tipo']);
            $table->index(['cliente_id', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('pagamentos_mp');
    }
};
