<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'nome')) {
                $table->string('nome')->after('id');
            }
            if (!Schema::hasColumn('users', 'cpf')) {
                $table->string('cpf')->nullable()->after('email');
            }
            if (!Schema::hasColumn('users', 'telefone')) {
                $table->string('telefone')->nullable()->after('cpf');
            }
            if (!Schema::hasColumn('users', 'oab')) {
                $table->string('oab')->nullable()->after('telefone');
            }
            if (!Schema::hasColumn('users', 'perfil')) {
                $table->enum('perfil', ['admin_geral', 'admin_unidade', 'advogado', 'secretario', 'consulta'])->default('consulta')->after('oab');
            }
            if (!Schema::hasColumn('users', 'unidade_id')) {
                $table->unsignedBigInteger('unidade_id')->nullable()->after('perfil');
            }
            if (!Schema::hasColumn('users', 'status')) {
                $table->enum('status', ['ativo', 'inativo'])->default('ativo')->after('unidade_id');
            }
            if (!Schema::hasColumn('users', 'ultimo_acesso')) {
                $table->timestamp('ultimo_acesso')->nullable()->after('status');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['nome', 'cpf', 'telefone', 'oab', 'perfil', 'unidade_id', 'status', 'ultimo_acesso']);
        });
    }
};
