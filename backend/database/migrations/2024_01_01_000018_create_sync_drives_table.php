<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sync_drives', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->enum('tipo_drive', ['google_drive', 'onedrive']);
            $table->datetime('ultimo_sync');
            $table->enum('status', ['sucesso', 'erro', 'em_andamento']);
            $table->text('erro')->nullable();
            $table->integer('arquivos_sincronizados')->default(0);
            $table->json('arquivos_detalhes')->nullable();
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->index(['cliente_id', 'tipo_drive']);
            $table->index(['status', 'ultimo_sync']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('sync_drives');
    }
};
