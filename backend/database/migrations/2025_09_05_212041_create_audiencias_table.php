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
        Schema::create('audiencias', function (Blueprint $table) {
            $table->id();
            
            // Relacionamentos obrigatórios
            $table->unsignedBigInteger('processo_id');
            $table->unsignedBigInteger('cliente_id'); 
            $table->unsignedBigInteger('advogado_id');
            $table->unsignedBigInteger('unidade_id');
            
            // Dados básicos obrigatórios
            $table->enum('tipo', [
                'conciliacao', 
                'instrucao', 
                'preliminar', 
                'julgamento', 
                'outras'
            ]);
            $table->date('data');
            $table->time('hora');
            $table->string('local');
            $table->string('advogado'); // Nome do advogado responsável
            
            // Dados opcionais
            $table->text('endereco')->nullable();
            $table->string('sala', 100)->nullable();
            $table->string('juiz')->nullable();
            $table->text('observacoes')->nullable();
            
            // Status e configurações
            $table->enum('status', [
                'agendada', 
                'confirmada', 
                'realizada', 
                'cancelada', 
                'adiada'
            ])->default('agendada');
            
            $table->boolean('lembrete')->default(true);
            $table->integer('horas_lembrete')->default(2);
            
            // Timestamps e soft deletes
            $table->timestamps();
            $table->softDeletes();
            
            // Foreign keys
            $table->foreign('processo_id')->references('id')->on('processos')->onDelete('cascade');
            $table->foreign('cliente_id')->references('id')->on('clientes')->onDelete('cascade');
            $table->foreign('advogado_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('unidade_id')->references('id')->on('unidades')->onDelete('cascade');
            
            // Índices para performance
            $table->index(['data', 'hora']);
            $table->index('status');
            $table->index('tipo');
            $table->index(['data', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('audiencias');
    }
};
