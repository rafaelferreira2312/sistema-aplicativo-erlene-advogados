<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('documentos_ged', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('cliente_id');
            $table->string('pasta'); // nome da pasta do cliente
            $table->string('nome_arquivo');
            $table->string('nome_original');
            $table->string('caminho');
            $table->string('tipo_arquivo', 10); // pdf, doc, jpg, etc
            $table->string('mime_type');
            $table->bigInteger('tamanho'); // em bytes
            $table->datetime('data_upload');
            $table->unsignedBigInteger('usuario_id'); // quem fez upload
            $table->integer('versao')->default(1);
            $table->enum('storage_type', ['local', 'google_drive', 'onedrive']);
            $table->string('google_drive_id')->nullable();
            $table->string('onedrive_id')->nullable();
            $table->json('tags')->nullable();
            $table->text('descricao')->nullable();
            $table->boolean('publico')->default(false);
            $table->string('hash_arquivo')->nullable(); // para verificar integridade
            $table->timestamps();

            $table->foreign('cliente_id')->references('id')->on('clientes');
            $table->foreign('usuario_id')->references('id')->on('users');
            $table->index(['cliente_id', 'storage_type']);
            $table->index(['tipo_arquivo', 'data_upload']);
            $table->index(['pasta', 'nome_arquivo']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('documentos_ged');
    }
};
