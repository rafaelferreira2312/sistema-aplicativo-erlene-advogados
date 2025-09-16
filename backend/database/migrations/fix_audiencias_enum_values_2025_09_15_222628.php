<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Corrigir ENUM da coluna 'tipo' para incluir todos os valores necessários
        DB::statement("ALTER TABLE audiencias MODIFY COLUMN tipo ENUM(
            'conciliacao',
            'instrucao', 
            'preliminar',
            'julgamento',
            'outras'
        ) NOT NULL");

        // Corrigir ENUM da coluna 'status' para incluir 'em_andamento'
        DB::statement("ALTER TABLE audiencias MODIFY COLUMN status ENUM(
            'agendada',
            'confirmada',
            'em_andamento',
            'realizada', 
            'cancelada',
            'adiada'
        ) NOT NULL DEFAULT 'agendada'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Reverter para ENUM original (sem 'em_andamento')
        DB::statement("ALTER TABLE audiencias MODIFY COLUMN status ENUM(
            'agendada',
            'confirmada',
            'realizada',
            'cancelada',
            'adiada'
        ) NOT NULL DEFAULT 'agendada'");
    }
};
