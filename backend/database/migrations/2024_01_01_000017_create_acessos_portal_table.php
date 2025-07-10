<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('acessos_portal', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->string('ip', 45); // suporte IPv6
            $table->string('user_agent')->nullable();
            $table->datetime('data_acesso');
            $table->enum('acao', [
                'login',
                'logout', 
                'visualizar_processo',
                'download_documento',
                'upload_documento',
                'pagamento',
                'mensagem'
            ]);
            $table->string('detalhes')->nullable();
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->index(['cliente_id', 'data_acesso']);
            $table->index(['acao', 'data_acesso']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('acessos_portal');
    }
};
