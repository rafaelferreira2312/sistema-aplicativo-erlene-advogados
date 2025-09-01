#!/bin/bash

# Script 114y - ViaCEP Service e Model Cliente (Parte 2)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: chmod +x 114y-clientes-service.sh && ./114y-clientes-service.sh
# EXECUTE NA PASTA: backend/

echo "🚀 Criando ViaCEP Service e atualizando Model Cliente - Parte 2..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo "📝 1. Criando Service ViaCEP..."

# Criar Service para integração com ViaCEP
cat > app/Services/ViaCepService.php << 'EOF'
<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class ViaCepService
{
    private $baseUrl = 'https://viacep.com.br/ws/';
    private $timeout = 10;

    /**
     * Buscar endereço por CEP
     */
    public function buscarCep(string $cep): array
    {
        // Limpar CEP
        $cep = preg_replace('/\D/', '', $cep);
        
        if (strlen($cep) !== 8) {
            throw new \InvalidArgumentException('CEP deve ter 8 dígitos');
        }

        // Cache por 24 horas
        $cacheKey = "viacep_{$cep}";
        
        return Cache::remember($cacheKey, 86400, function() use ($cep) {
            $response = Http::timeout($this->timeout)
                          ->get($this->baseUrl . $cep . '/json/');

            if (!$response->successful()) {
                throw new \Exception('Erro ao consultar ViaCEP');
            }

            $data = $response->json();

            if (isset($data['erro'])) {
                throw new \Exception('CEP não encontrado');
            }

            return [
                'cep' => $data['cep'] ?? '',
                'logradouro' => $data['logradouro'] ?? '',
                'complemento' => $data['complemento'] ?? '',
                'bairro' => $data['bairro'] ?? '',
                'localidade' => $data['localidade'] ?? '',
                'uf' => $data['uf'] ?? '',
                'ibge' => $data['ibge'] ?? '',
                'gia' => $data['gia'] ?? '',
                'ddd' => $data['ddd'] ?? '',
                'siafi' => $data['siafi'] ?? ''
            ];
        });
    }

    /**
     * Buscar endereços por cidade e logradouro
     */
    public function buscarEndereco(string $uf, string $cidade, string $logradouro): array
    {
        $uf = strtoupper($uf);
        $cidade = urlencode($cidade);
        $logradouro = urlencode($logradouro);

        if (strlen($uf) !== 2) {
            throw new \InvalidArgumentException('UF deve ter 2 caracteres');
        }

        $cacheKey = "viacep_endereco_{$uf}_{$cidade}_{$logradouro}";
        
        return Cache::remember($cacheKey, 3600, function() use ($uf, $cidade, $logradouro) {
            $response = Http::timeout($this->timeout)
                          ->get($this->baseUrl . "{$uf}/{$cidade}/{$logradouro}/json/");

            if (!$response->successful()) {
                throw new \Exception('Erro ao consultar ViaCEP');
            }

            $data = $response->json();

            if (empty($data)) {
                throw new \Exception('Endereço não encontrado');
            }

            return $data;
        });
    }
}
EOF

echo "📝 2. Atualizando Model Cliente..."

# Atualizar Model Cliente com relacionamentos e métodos
cat > app/Models/Cliente.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\SoftDeletes;

class Cliente extends Authenticatable
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'nome',
        'cpf_cnpj',
        'tipo_pessoa',
        'email',
        'telefone',
        'endereco',
        'cep',
        'cidade',
        'estado',
        'observacoes',
        'acesso_portal',
        'senha_portal',
        'tipo_armazenamento',
        'google_drive_config',
        'onedrive_config',
        'pasta_local',
        'unidade_id',
        'responsavel_id',
        'status'
    ];

    protected $hidden = [
        'senha_portal',
    ];

    protected $casts = [
        'acesso_portal' => 'boolean',
        'google_drive_config' => 'array',
        'onedrive_config' => 'array',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    protected $dates = ['deleted_at'];

    // Relationships
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    public function responsavel()
    {
        return $this->belongsTo(User::class, 'responsavel_id');
    }

    public function processos()
    {
        return $this->hasMany(Processo::class);
    }

    public function atendimentos()
    {
        return $this->hasMany(Atendimento::class);
    }

    public function documentos()
    {
        return $this->hasMany(DocumentoGed::class);
    }

    public function financeiro()
    {
        return $this->hasMany(Financeiro::class);
    }

    public function acessosPortal()
    {
        return $this->hasMany(AcessoPortal::class);
    }

    public function mensagens()
    {
        return $this->hasMany(Mensagem::class);
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->where('status', 'ativo');
    }

    public function scopePorTipo($query, $tipo)
    {
        return $query->where('tipo_pessoa', $tipo);
    }

    public function scopeComAcessoPortal($query)
    {
        return $query->where('acesso_portal', true);
    }

    // Accessors
    public function getDocumentoAttribute()
    {
        return $this->cpf_cnpj;
    }

    public function getEnderecoCompletoAttribute()
    {
        $partes = array_filter([
            $this->endereco,
            $this->cidade,
            $this->estado,
            $this->cep
        ]);
        
        return implode(', ', $partes);
    }

    public function getNomePastaAttribute()
    {
        return $this->pasta_local ?: \Str::slug($this->nome);
    }

    public function getAvatarAttribute()
    {
        return 'https://ui-avatars.com/api/?name=' . urlencode($this->nome) . '&color=8B1538&background=F8F9FA';
    }

    // Mutators
    public function setCpfCnpjAttribute($value)
    {
        $this->attributes['cpf_cnpj'] = preg_replace('/\D/', '', $value);
    }

    public function getTelefoneFormatadoAttribute()
    {
        $telefone = preg_replace('/\D/', '', $this->telefone);
        
        if (strlen($telefone) === 11) {
            return preg_replace('/(\d{2})(\d{5})(\d{4})/', '($1) $2-$3', $telefone);
        } elseif (strlen($telefone) === 10) {
            return preg_replace('/(\d{2})(\d{4})(\d{4})/', '($1) $2-$3', $telefone);
        }
        
        return $this->telefone;
    }

    public function getCpfCnpjFormatadoAttribute()
    {
        $documento = preg_replace('/\D/', '', $this->cpf_cnpj);
        
        if (strlen($documento) === 11) {
            // CPF
            return preg_replace('/(\d{3})(\d{3})(\d{3})(\d{2})/', '$1.$2.$3-$4', $documento);
        } elseif (strlen($documento) === 14) {
            // CNPJ  
            return preg_replace('/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/', '$1.$2.$3/$4-$5', $documento);
        }
        
        return $this->cpf_cnpj;
    }

    // Métodos auxiliares
    public function isPessoaFisica()
    {
        return $this->tipo_pessoa === 'PF';
    }

    public function isPessoaJuridica()
    {
        return $this->tipo_pessoa === 'PJ';
    }

    public function isAtivo()
    {
        return $this->status === 'ativo';
    }

    public function temAcessoPortal()
    {
        return $this->acesso_portal;
    }
}
EOF

echo "📝 3. Adicionando rotas para Clientes..."

# Verificar se as rotas já existem
if ! grep -q "ClientController" routes/api.php; then
    # Adicionar rotas para clientes
    cat >> routes/api.php << 'EOF'

// Rotas de Clientes
Route::middleware('auth:api')->prefix('admin')->group(function () {
    Route::prefix('clients')->group(function () {
        Route::get('/', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'index']);
        Route::post('/', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'store']);
        Route::get('/stats', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'stats']);
        Route::get('/responsaveis', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'responsaveis']);
        Route::get('/buscar-cep/{cep}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'buscarCep']);
        Route::get('/{id}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\Api\Admin\Clients\ClientController::class, 'destroy']);
    });
});
EOF
    echo "✅ Rotas de clientes adicionadas"
else
    echo "⚠️ Rotas de clientes já existem"
fi

echo "📝 4. Registrando Service no Provider..."

# Registrar ViaCepService no AppServiceProvider se não existir
if ! grep -q "ViaCepService" app/Providers/AppServiceProvider.php; then
    # Adicionar no método register
    sed -i '/public function register()/a\        $this->app->singleton(\\App\\Services\\ViaCepService::class);' app/Providers/AppServiceProvider.php
    echo "✅ ViaCepService registrado no ServiceProvider"
else
    echo "⚠️ ViaCepService já registrado"
fi

echo "📝 5. Criando pasta para documentos de clientes..."

# Criar diretório para documentos dos clientes
mkdir -p storage/app/clients
chmod 755 storage/app/clients

echo "✅ Script 114y Parte 2 concluído!"
echo "📝 ViaCepService criado com cache e validações"
echo "📝 Model Cliente atualizado com relacionamentos"
echo "📝 Rotas API configuradas"
echo ""
echo "Digite 'continuar' para prosseguir com a Parte 3 (Factory e Seeder)..."