#!/bin/bash

# Script 128 - Criar Backend Completo para Audiências
# Sistema Erlene Advogados - Módulo de Audiências
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🎯 Script 128 - Criando backend completo para audiências..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📁 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 128-create-audiencias-backend.sh && ./128-create-audiencias-backend.sh"
    exit 1
fi

echo "1️⃣ Criando Migration para tabela audiencias..."

# Criar migration da tabela audiencias
php artisan make:migration create_audiencias_table --create=audiencias

# Buscar o arquivo de migration criado
MIGRATION_FILE=$(find database/migrations -name "*_create_audiencias_table.php" | head -1)

if [ -z "$MIGRATION_FILE" ]; then
    echo "❌ Erro: Migration não foi criada"
    exit 1
fi

echo "📄 Atualizando migration: $MIGRATION_FILE"

# Criar conteúdo da migration
cat > "$MIGRATION_FILE" << 'EOF'
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
EOF

echo "2️⃣ Criando Model Audiencia com relacionamentos..."

# Criar Model Audiencia
php artisan make:model Audiencia

# Atualizar Model com relacionamentos e configurações
cat > app/Models/Audiencia.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Carbon\Carbon;

class Audiencia extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'audiencias';

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'processo_id',
        'cliente_id', 
        'advogado_id',
        'unidade_id',
        'tipo',
        'data',
        'hora',
        'local',
        'endereco',
        'sala',
        'advogado',
        'juiz',
        'status',
        'observacoes',
        'lembrete',
        'horas_lembrete'
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'data' => 'date',
        'hora' => 'datetime:H:i',
        'lembrete' => 'boolean',
        'horas_lembrete' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime'
    ];

    /**
     * Relacionamento com Processo
     */
    public function processo()
    {
        return $this->belongsTo(Processo::class);
    }

    /**
     * Relacionamento com Cliente  
     */
    public function cliente()
    {
        return $this->belongsTo(Cliente::class);
    }

    /**
     * Relacionamento com Advogado Responsável
     */
    public function advogadoResponsavel()
    {
        return $this->belongsTo(User::class, 'advogado_id');
    }

    /**
     * Relacionamento com Unidade
     */
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    /**
     * Scope para audiências de hoje
     */
    public function scopeHoje($query)
    {
        return $query->whereDate('data', Carbon::today());
    }

    /**
     * Scope para próximas audiências (próximas 2 horas)
     */
    public function scopeProximas($query, $horas = 2)
    {
        $agora = Carbon::now();
        $limite = $agora->copy()->addHours($horas);
        
        return $query->whereDate('data', Carbon::today())
                    ->whereTime('hora', '>=', $agora->format('H:i:s'))
                    ->whereTime('hora', '<=', $limite->format('H:i:s'));
    }

    /**
     * Scope para audiências em andamento
     */
    public function scopeEmAndamento($query)
    {
        return $query->where('status', 'confirmada')
                    ->whereDate('data', Carbon::today());
    }

    /**
     * Scope para audiências agendadas
     */
    public function scopeAgendadas($query)
    {
        return $query->where('status', 'agendada');
    }

    /**
     * Scope para filtrar por período
     */
    public function scopePorPeriodo($query, $dataInicio, $dataFim)
    {
        return $query->whereBetween('data', [$dataInicio, $dataFim]);
    }

    /**
     * Scope para filtrar por tipo
     */
    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo', $tipo);
    }

    /**
     * Scope para filtrar por status
     */
    public function scopePorStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Accessor para data formatada
     */
    public function getDataFormatadaAttribute()
    {
        return $this->data ? $this->data->format('d/m/Y') : null;
    }

    /**
     * Accessor para hora formatada
     */
    public function getHoraFormatadaAttribute()
    {
        return $this->hora ? Carbon::parse($this->hora)->format('H:i') : null;
    }

    /**
     * Accessor para status formatado
     */
    public function getStatusFormatadoAttribute()
    {
        $status = [
            'agendada' => 'Agendada',
            'confirmada' => 'Confirmada', 
            'realizada' => 'Realizada',
            'cancelada' => 'Cancelada',
            'adiada' => 'Adiada'
        ];

        return $status[$this->status] ?? $this->status;
    }

    /**
     * Accessor para tipo formatado
     */
    public function getTipoFormatadoAttribute()
    {
        $tipos = [
            'conciliacao' => 'Audiência de Conciliação',
            'instrucao' => 'Audiência de Instrução',
            'preliminar' => 'Audiência Preliminar',
            'julgamento' => 'Audiência de Julgamento',
            'outras' => 'Outras'
        ];

        return $tipos[$this->tipo] ?? $this->tipo;
    }

    /**
     * Verificar se a audiência está próxima (nas próximas X horas)
     */
    public function isProxima($horas = 2)
    {
        if ($this->data->isToday()) {
            $agora = Carbon::now();
            $horaAudiencia = Carbon::parse($this->data->format('Y-m-d') . ' ' . $this->hora);
            
            return $horaAudiencia->diffInHours($agora, false) <= $horas && $horaAudiencia->isFuture();
        }
        
        return false;
    }

    /**
     * Verificar se a audiência é hoje
     */
    public function isHoje()
    {
        return $this->data->isToday();
    }
}
EOF

echo "✅ Model Audiencia criado com relacionamentos e scopes!"
echo ""
echo "📋 Próximo passo: Execute o script 129 para criar o Controller"
echo "   chmod +x 129-create-audiencias-controller.sh && ./129-create-audiencias-controller.sh"