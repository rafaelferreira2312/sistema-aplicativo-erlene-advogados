<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('processos', function (Blueprint $table) {
            // Campos para integração CNJ DataJud
            $table->json('metadata_cnj')->nullable();
            $table->timestamp('ultima_consulta_cnj')->nullable();
            $table->boolean('sincronizado_cnj')->default(false);
            
            // SoftDeletes se não existir
            if (!Schema::hasColumn('processos', 'deleted_at')) {
                $table->softDeletes();
            }
            
            // Índices para otimizar consultas CNJ
            $table->index(['sincronizado_cnj', 'ultima_consulta_cnj']);
        });
    }

    public function down()
    {
        Schema::table('processos', function (Blueprint $table) {
            $table->dropColumn(['metadata_cnj', 'ultima_consulta_cnj', 'sincronizado_cnj']);
            $table->dropIndex(['sincronizado_cnj', 'ultima_consulta_cnj']);
            
            if (Schema::hasColumn('processos', 'deleted_at')) {
                $table->dropSoftDeletes();
            }
        });
    }
};
