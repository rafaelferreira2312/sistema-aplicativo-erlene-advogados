<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('prazos', function (Blueprint $table) {
            $table->id();
            
            // Relacionamentos com nomes CORRETOS das tabelas
            $table->unsignedBigInteger('client_id');
            $table->unsignedBigInteger('process_id')->nullable();
            $table->unsignedBigInteger('user_id');
            
            // Dados principais do prazo
            $table->string('descricao');
            $table->string('tipo_prazo');
            $table->date('data_vencimento');
            $table->time('hora_vencimento')->default('17:00');
            
            // Status e prioridade
            $table->enum('status', ['Pendente', 'Em Andamento', 'Concluído', 'Vencido'])
                  ->default('Pendente');
            $table->enum('prioridade', ['Normal', 'Alta', 'Urgente'])
                  ->default('Normal');
            
            // Informações adicionais
            $table->text('observacoes')->nullable();
            $table->integer('dias_antecedencia')->default(5);
            $table->boolean('alerta_enviado')->default(false);
            
            // Auditoria
            $table->timestamps();
            
            // Foreign keys CORRETAS
            $table->foreign('client_id')->references('id')->on('clientes')->onDelete('cascade');
            $table->foreign('process_id')->references('id')->on('processos')->onDelete('set null');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            
            // Índices para performance
            $table->index(['client_id', 'data_vencimento']);
            $table->index(['process_id', 'status']);
            $table->index(['user_id', 'data_vencimento']);
            $table->index(['status', 'prioridade']);
            $table->index('data_vencimento');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('prazos');
    }
};
