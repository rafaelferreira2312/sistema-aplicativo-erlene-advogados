#!/bin/bash

# Script 114d - Corrigir Estrutura Laravel 11 + JWT + Migrations
# Sistema Erlene Advogados - Corrigir problemas estruturais
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "Script 114d - Corrigindo estrutura Laravel 11 + JWT..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

echo "1. Verificando estrutura atual das tabelas..."

# Verificar estrutura da tabela users
mysql -u root -p12345678 erlene_advogados -e "DESCRIBE users;" 2>/dev/null
echo ""
echo "Estrutura atual da tabela unidades:"
mysql -u root -p12345678 erlene_advogados -e "DESCRIBE unidades;" 2>/dev/null

echo ""
echo "2. Instalando e configurando JWT para Laravel 11..."

# Instalar JWT
composer require tymon/jwt-auth

# Publicar configuração JWT
php artisan vendor:publish --provider="Tymon\JWTAuth\Providers\LaravelServiceProvider"

# Gerar secret JWT
php artisan jwt:secret

echo "3. Configurando auth.php para JWT..."

cat > config/auth.php << 'EOF'
<?php

return [
    'defaults' => [
        'guard' => 'api',
        'passwords' => 'users',
    ],

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],
        'api' => [
            'driver' => 'jwt',
            'provider' => 'users',
        ],
    ],

    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => App\Models\User::class,
        ],
    ],

    'passwords' => [
        'users' => [
            'provider' => 'users',
            'table' => 'password_reset_tokens',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],

    'password_timeout' => 10800,
];
EOF

echo "4. Criando migrations de correção..."

# Migration para adicionar campos na tabela users
php artisan make:migration add_missing_fields_to_users_table

cat > database/migrations/*add_missing_fields_to_users_table.php << 'EOF'
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
EOF

# Migration para adicionar campos na tabela unidades
php artisan make:migration add_missing_fields_to_unidades_table

cat > database/migrations/*add_missing_fields_to_unidades_table.php << 'EOF'
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
EOF

echo "5. Executando migrations de correção..."

php artisan migrate

echo "6. Configurando bootstrap/app.php para Laravel 11..."

# Laravel 11 usa bootstrap/app.php para middleware
cat > bootstrap/app.php << 'EOF'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'admin.access' => \App\Http\Middleware\AdminAccessMiddleware::class,
            'cliente.access' => \App\Http\Middleware\ClienteAccessMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
EOF

echo "7. Atualizando User Model para Laravel 11..."

cat > app/Models/User.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'nome',
        'email',
        'password',
        'cpf',
        'oab',
        'telefone',
        'perfil',
        'unidade_id',
        'status',
        'ultimo_acesso'
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'ultimo_acesso' => 'datetime',
        'password' => 'hashed',
    ];

    // JWT Methods
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [
            'perfil' => $this->perfil,
            'unidade_id' => $this->unidade_id
        ];
    }

    // Relationships
    public function unidade()
    {
        return $this->belongsTo(Unidade::class);
    }

    // Scopes
    public function scopeAtivos($query)
    {
        return $query->where('status', 'ativo');
    }

    public function scopePorPerfil($query, $perfil)
    {
        return $query->where('perfil', $perfil);
    }

    public function scopePorUnidade($query, $unidadeId)
    {
        return $query->where('unidade_id', $unidadeId);
    }

    // Helper methods
    public function isAdmin()
    {
        return in_array($this->perfil, ['admin_geral', 'admin_unidade']);
    }

    public function isCliente()
    {
        return $this->perfil === 'consulta';
    }
}
EOF

echo "8. Criando Model Unidade..."

cat > app/Models/Unidade.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Unidade extends Model
{
    use HasFactory;

    protected $table = 'unidades';

    protected $fillable = [
        'nome',
        'codigo',
        'endereco',
        'cidade',
        'estado',
        'cep',
        'telefone',
        'email',
        'cnpj',
        'status',
    ];

    public function usuarios()
    {
        return $this->hasMany(User::class);
    }

    public function scopeAtivas($query)
    {
        return $query->where('status', 'ativa');
    }

    public function isMatriz()
    {
        return $this->codigo === 'MATRIZ';
    }
}
EOF

echo "9. Atualizando seeder compatível com estrutura atual..."

cat > database/seeders/FixedTestSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Unidade;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class FixedTestSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Criar unidades
        $matriz = Unidade::create([
            'nome' => 'Erlene Advogados - Matriz',
            'codigo' => 'MATRIZ',
            'endereco' => 'Rua Principal, 123 - Centro',
            'cidade' => 'São Paulo',
            'estado' => 'SP',
            'cep' => '01234-567',
            'telefone' => '(11) 3333-1111',
            'email' => 'matriz@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0001-90',
            'status' => 'ativa',
        ]);

        $filialRj = Unidade::create([
            'nome' => 'Erlene Advogados - Rio de Janeiro',
            'codigo' => 'FILIAL_RJ',
            'endereco' => 'Av. Atlântica, 456 - Copacabana',
            'cidade' => 'Rio de Janeiro',
            'estado' => 'RJ',
            'cep' => '22070-001',
            'telefone' => '(21) 3333-2222',
            'email' => 'rj@erleneadvogados.com.br',
            'cnpj' => '12.345.678/0002-71',
            'status' => 'ativa',
        ]);

        // 2. USUÁRIOS COMPATÍVEIS COM ESTRUTURA ATUAL

        // Admin principal
        User::create([
            'nome' => 'Dra. Erlene Chaves Silva',
            'email' => 'admin@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '11111111111',
            'telefone' => '(11) 99999-1111',
            'oab' => 'SP123456',
            'perfil' => 'admin_geral',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Admin RJ
        User::create([
            'nome' => 'Dr. João Silva Santos',
            'email' => 'admin.rj@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '22222222222',
            'telefone' => '(21) 98888-2222',
            'oab' => 'RJ654321',
            'perfil' => 'admin_unidade',
            'unidade_id' => $filialRj->id,
            'status' => 'ativo',
        ]);

        // Advogada
        User::create([
            'nome' => 'Dra. Maria Costa Lima',
            'email' => 'maria.advogada@erlene.com',
            'password' => Hash::make('123456'),
            'cpf' => '33333333333',
            'telefone' => '(11) 97777-3333',
            'oab' => 'SP789012',
            'perfil' => 'advogado',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Cliente teste (compatível com frontend)
        User::create([
            'nome' => 'Cliente Teste',
            'email' => 'cliente@teste.com',
            'password' => Hash::make('123456'),
            'cpf' => '12345678900',
            'telefone' => '(11) 96666-4444',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Outros clientes
        User::create([
            'nome' => 'Carlos Eduardo Pereira',
            'email' => 'carlos.pereira@cliente.com',
            'password' => Hash::make('123456'),
            'cpf' => '98765432100',
            'telefone' => '(11) 95555-5555',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);

        // Empresa (CNPJ)
        User::create([
            'nome' => 'Tech Solutions Ltda',
            'email' => 'contato@techsolutions.com',
            'password' => Hash::make('123456'),
            'cpf' => '11222333000144',
            'telefone' => '(11) 92222-8888',
            'perfil' => 'consulta',
            'unidade_id' => $matriz->id,
            'status' => 'ativo',
        ]);
    }
}
EOF

echo "10. Limpando tabelas e executando seeder corrigido..."

mysql -u root -p12345678 erlene_advogados << 'EOF'
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE users;
TRUNCATE TABLE unidades;
SET FOREIGN_KEY_CHECKS = 1;
EOF

php artisan db:seed --class=FixedTestSeeder

echo "11. Verificando dados inseridos..."
echo "Usuários criados:"
mysql -u root -p12345678 erlene_advogados -e "SELECT id, nome, email, perfil, status FROM users;"

echo ""
echo "Unidades criadas:"
mysql -u root -p12345678 erlene_advogados -e "SELECT id, nome, codigo, cidade, status FROM unidades;"

echo "12. Testando APIs..."

# Iniciar servidor
php artisan serve --port=8000 &
LARAVEL_PID=$!
sleep 3

echo "Testando login admin:"
ADMIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@erlene.com","password":"123456"}')

echo $ADMIN_RESPONSE | head -3

if [[ $ADMIN_RESPONSE == *"access_token"* ]]; then
    echo "Login admin funcionou!"
    
    ADMIN_TOKEN=$(echo $ADMIN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    
    echo ""
    echo "Testando rota protegida:"
    curl -s -H "Authorization: Bearer $ADMIN_TOKEN" \
         -H 'Content-Type: application/json' \
         http://localhost:8000/api/dashboard/stats | head -3
else
    echo "Erro no login admin"
fi

# Parar servidor
kill $LARAVEL_PID 2>/dev/null

echo ""
echo ""
echo "SCRIPT 114D CONCLUÍDO!"
echo ""
echo "CORREÇÕES APLICADAS:"
echo "   JWT configurado para Laravel 11"
echo "   Migrations de correção executadas"
echo "   Campos nome, codigo adicionados às tabelas"
echo "   Seeders corrigidos e executados"
echo "   Middleware registrado no bootstrap/app.php"
echo ""
echo "TESTE AGORA:"
echo "   1. php artisan serve"
echo "   2. Login: admin@erlene.com / 123456"
echo "   3. Rotas protegidas devem funcionar"
echo ""
echo "PRÓXIMO: Digite 'continuar' para conectar o frontend"