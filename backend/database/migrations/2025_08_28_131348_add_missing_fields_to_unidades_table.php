<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('unidades', function (Blueprint $table) {
            if (!Schema::hasColumn('unidades', 'codigo')) {
                $table->string('codigo')->unique()->after('nome');
            }
            if (!Schema::hasColumn('unidades', 'endereco')) {
                $table->text('endereco')->nullable()->after('codigo');
            }
            if (!Schema::hasColumn('unidades', 'cidade')) {
                $table->string('cidade')->after('endereco');
            }
            if (!Schema::hasColumn('unidades', 'estado')) {
                $table->string('estado', 2)->after('cidade');
            }
            if (!Schema::hasColumn('unidades', 'cep')) {
                $table->string('cep')->nullable()->after('estado');
            }
            if (!Schema::hasColumn('unidades', 'telefone')) {
                $table->string('telefone')->nullable()->after('cep');
            }
            if (!Schema::hasColumn('unidades', 'email')) {
                $table->string('email')->nullable()->after('telefone');
            }
            if (!Schema::hasColumn('unidades', 'cnpj')) {
                $table->string('cnpj')->nullable()->after('email');
            }
            if (!Schema::hasColumn('unidades', 'status')) {
                $table->enum('status', ['ativa', 'inativa'])->default('ativa')->after('cnpj');
            }
        });
    }

    public function down(): void
    {
        Schema::table('unidades', function (Blueprint $table) {
            $table->dropColumn(['codigo', 'endereco', 'cidade', 'estado', 'cep', 'telefone', 'email', 'cnpj', 'status']);
        });
    }
};
