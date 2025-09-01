#!/bin/bash

# Script 114u-fix - Correção Sistema de Logs para registrar ações dos usuários
# Sistema Erlene Advogados - Backend Laravel
# EXECUTE DENTRO DA PASTA: backend/
# Comando: chmod +x 114u-fix-sistema-logs.sh && ./114u-fix-sistema-logs.sh

echo "🔧 Script 114u-fix - Corrigindo Sistema de Logs..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    echo "📍 Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 114u-fix-sistema-logs.sh && ./114u-fix-sistema-logs.sh"
    exit 1
fi

echo "✅ 1. Verificando estrutura da tabela logs_sistema..."

# Verificar se a tabela existe e tem a estrutura correta
php artisan tinker --execute="
if (Schema::hasTable('logs_sistema')) {
    echo 'Tabela logs_sistema existe\n';
    \$columns = Schema::getColumnListing('logs_sistema');
    echo 'Colunas: ' . implode(', ', \$columns) . '\n';
} else {
    echo 'Tabela logs_sistema NÃO existe\n';
}
" 2>/dev/null || echo "⚠️  Erro ao verificar tabela"

echo "🔧 2. Criando Model LogSistema se não existir..."

# Criar Model LogSistema
cat > app/Models/LogSistema.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Carbon\Carbon;

class LogSistema extends Model
{
    protected $table = 'logs_sistema';
    
    protected $fillable = [
        'nivel',
        'categoria',
        'mensagem', 
        'contexto',
        'usuario_id',
        'cliente_id',
        'ip',
        'user_agent',
        'request_id',
        'data_hora'
    ];

    protected $casts = [
        'contexto' => 'array',
        'data_hora' => 'datetime'
    ];

    // Relacionamentos
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    public function cliente(): BelongsTo
    {
        return $this->belongsTo(Cliente::class, 'cliente_id');
    }

    // Métodos estáticos para facilitar uso
    public static function info($categoria, $mensagem, $contexto = [], $usuarioId = null, $clienteId = null)
    {
        return self::criarLog('info', $categoria, $mensagem, $contexto, $usuarioId, $clienteId);
    }

    public static function warning($categoria, $mensagem, $contexto = [], $usuarioId = null, $clienteId = null)
    {
        return self::criarLog('warning', $categoria, $mensagem, $contexto, $usuarioId, $clienteId);
    }

    public static function error($categoria, $mensagem, $contexto = [], $usuarioId = null, $clienteId = null)
    {
        return self::criarLog('error', $categoria, $mensagem, $contexto, $usuarioId, $clienteId);
    }

    public static function debug($categoria, $mensagem, $contexto = [], $usuarioId = null, $clienteId = null)
    {
        return self::criarLog('debug', $categoria, $mensagem, $contexto, $usuarioId, $clienteId);
    }

    private static function criarLog($nivel, $categoria, $mensagem, $contexto, $usuarioId, $clienteId)
    {
        try {
            $request = request();
            
            return self::create([
                'nivel' => $nivel,
                'categoria' => $categoria,
                'mensagem' => $mensagem,
                'contexto' => $contexto,
                'usuario_id' => $usuarioId ?: (auth()->check() ? auth()->id() : null),
                'cliente_id' => $clienteId,
                'ip' => $request ? $request->ip() : null,
                'user_agent' => $request ? $request->userAgent() : null,
                'request_id' => $request ? $request->header('X-Request-ID', uniqid()) : null,
                'data_hora' => now()
            ]);
        } catch (\Exception $e) {
            // Log no arquivo se falhar no banco
            \Log::error('Erro ao criar log no banco', [
                'error' => $e->getMessage(),
                'nivel' => $nivel,
                'categoria' => $categoria,
                'mensagem' => $mensagem
            ]);
            return null;
        }
    }

    // Scopes úteis
    public function scopeUsuario($query, $usuarioId)
    {
        return $query->where('usuario_id', $usuarioId);
    }

    public function scopeCategoria($query, $categoria)
    {
        return $query->where('categoria', $categoria);
    }

    public function scopeNivel($query, $nivel)
    {
        return $query->where('nivel', $nivel);
    }

    public function scopePeriodo($query, $inicio, $fim)
    {
        return $query->whereBetween('data_hora', [$inicio, $fim]);
    }

    public function scopeHoje($query)
    {
        return $query->whereDate('data_hora', today());
    }
}
EOF

echo "✅ Model LogSistema criado"

echo "🔧 3. Criando Service para gerenciar logs..."

# Criar diretório Services se não existir
mkdir -p app/Services

# Criar LogService
cat > app/Services/LogService.php << 'EOF'
<?php

namespace App\Services;

use App\Models\LogSistema;
use Illuminate\Http\Request;

class LogService
{
    /**
     * Registrar login de usuário
     */
    public static function logLogin($user, $tipo = 'admin', Request $request = null)
    {
        $request = $request ?: request();
        
        LogSistema::info('auth', 'Login realizado com sucesso', [
            'user_id' => $user->id,
            'user_name' => $user->nome ?? $user->name,
            'user_email' => $user->email,
            'tipo_login' => $tipo,
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent()
        ], $user->id);
    }

    /**
     * Registrar login no portal
     */
    public static function logPortalLogin($cliente, Request $request = null)
    {
        $request = $request ?: request();
        
        LogSistema::info('auth', 'Login no portal realizado com sucesso', [
            'cliente_id' => $cliente->id,
            'cliente_nome' => $cliente->nome,
            'cliente_email' => $cliente->email,
            'tipo_login' => 'portal',
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent()
        ], null, $cliente->id);
    }

    /**
     * Registrar logout
     */
    public static function logLogout($user = null, $tipo = 'admin')
    {
        $user = $user ?: auth()->user();
        
        if ($user) {
            LogSistema::info('auth', 'Logout realizado', [
                'user_id' => $user->id,
                'user_name' => $user->nome ?? $user->name,
                'tipo_logout' => $tipo
            ], $user->id);
        }
    }

    /**
     * Registrar tentativa de login inválida
     */
    public static function logLoginFailed($email, $tipo = 'admin', Request $request = null)
    {
        $request = $request ?: request();
        
        LogSistema::warning('auth', 'Tentativa de login com credenciais inválidas', [
            'email' => $email,
            'tipo_login' => $tipo,
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent()
        ]);
    }

    /**
     * Registrar ações CRUD
     */
    public static function logCrud($acao, $modelo, $modeloId, $dados = [], $user = null)
    {
        $user = $user ?: auth()->user();
        
        $categoria = 'crud_' . strtolower(class_basename($modelo));
        $mensagem = ucfirst($acao) . ' ' . class_basename($modelo) . ' ID: ' . $modeloId;
        
        LogSistema::info($categoria, $mensagem, [
            'acao' => $acao,
            'modelo' => class_basename($modelo),
            'modelo_id' => $modeloId,
            'dados' => $dados,
            'user_id' => $user ? $user->id : null,
            'user_name' => $user ? ($user->nome ?? $user->name) : null
        ], $user ? $user->id : null);
    }

    /**
     * Registrar acesso a páginas/endpoints
     */
    public static function logAccess($endpoint, $metodo = 'GET', $parametros = [], $user = null)
    {
        $user = $user ?: auth()->user();
        
        LogSistema::debug('acesso', "Acesso ao endpoint: {$metodo} {$endpoint}", [
            'endpoint' => $endpoint,
            'metodo' => $metodo,
            'parametros' => $parametros,
            'user_id' => $user ? $user->id : null,
            'user_name' => $user ? ($user->nome ?? $user->name) : null
        ], $user ? $user->id : null);
    }

    /**
     * Registrar erros de aplicação
     */
    public static function logError($mensagem, $exception = null, $contexto = [], $user = null)
    {
        $user = $user ?: auth()->user();
        
        $contextoCompleto = array_merge([
            'error_message' => $mensagem,
            'exception' => $exception ? [
                'message' => $exception->getMessage(),
                'file' => $exception->getFile(),
                'line' => $exception->getLine(),
                'trace' => $exception->getTraceAsString()
            ] : null,
            'user_id' => $user ? $user->id : null,
            'user_name' => $user ? ($user->nome ?? $user->name) : null
        ], $contexto);

        LogSistema::error('sistema', $mensagem, $contextoCompleto, $user ? $user->id : null);
    }

    /**
     * Registrar ações específicas do sistema jurídico
     */
    public static function logJuridico($acao, $entidade, $entidadeId, $dados = [], $user = null)
    {
        $user = $user ?: auth()->user();
        
        LogSistema::info('juridico', "Ação jurídica: {$acao} - {$entidade} ID: {$entidadeId}", [
            'acao' => $acao,
            'entidade' => $entidade,
            'entidade_id' => $entidadeId,
            'dados' => $dados,
            'user_id' => $user ? $user->id : null,
            'user_name' => $user ? ($user->nome ?? $user->name) : null
        ], $user ? $user->id : null);
    }
}
EOF

echo "✅ LogService criado"

echo "🔧 4. Atualizando AuthController para registrar logs..."

# Atualizar AuthController para usar o sistema de logs
cat > app/Http/Controllers/Api/AuthController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Cliente;
use App\Services\LogService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    /**
     * Login Admin
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        $email = $request->email;

        // Buscar usuário admin (não cliente)
        $user = User::where('email', $email)
                   ->whereNotIn('perfil', ['consulta'])
                   ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            // Log tentativa de login falhada
            LogService::logLoginFailed($email, 'admin', $request);
            
            return response()->json([
                'success' => false,
                'message' => 'Credenciais inválidas',
                'errors' => [
                    'email' => ['Email ou senha incorretos']
                ]
            ], 401);
        }

        if ($user->status !== 'ativo') {
            // Log tentativa de login com usuário inativo
            LogService::logLoginFailed($email, 'admin_inativo', $request);
            
            return response()->json([
                'success' => false,
                'message' => 'Usuário inativo',
                'errors' => [
                    'email' => ['Usuário desabilitado. Contate o administrador.']
                ]
            ], 401);
        }

        // Criar token JWT
        if (!$token = JWTAuth::fromUser($user)) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao gerar token'
            ], 500);
        }

        // LOG: Registrar login bem-sucedido
        LogService::logLogin($user, 'admin', $request);

        return response()->json([
            'success' => true,
            'message' => 'Login realizado com sucesso',
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
            'user' => [
                'id' => $user->id,
                'nome' => $user->nome,
                'email' => $user->email,
                'perfil' => $user->perfil,
                'unidade_id' => $user->unidade_id
            ]
        ]);
    }

    /**
     * Login Portal Cliente
     */
    public function portalLogin(Request $request)
    {
        $request->validate([
            'cpf_cnpj' => 'required|string',
            'password' => 'required|string|min:6',
        ]);

        $cpfCnpj = $request->cpf_cnpj;

        // Buscar cliente
        $cliente = Cliente::where('cpf_cnpj', $cpfCnpj)
                         ->where('status', 'ativo')
                         ->first();

        if (!$cliente || !Hash::check($request->password, $cliente->senha)) {
            // Log tentativa de login falhada no portal
            LogService::logLoginFailed($cpfCnpj, 'portal', $request);
            
            return response()->json([
                'success' => false,
                'message' => 'Credenciais inválidas',
                'errors' => [
                    'cpf_cnpj' => ['CPF/CNPJ ou senha incorretos']
                ]
            ], 401);
        }

        // Criar token para cliente (usando guard específico se configurado)
        $token = JWTAuth::fromUser($cliente);

        // LOG: Registrar login bem-sucedido no portal
        LogService::logPortalLogin($cliente, $request);

        return response()->json([
            'success' => true,
            'message' => 'Login no portal realizado com sucesso',
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
            'user' => [
                'id' => $cliente->id,
                'nome' => $cliente->nome,
                'email' => $cliente->email,
                'cpf_cnpj' => $cliente->cpf_cnpj,
                'tipo' => 'cliente'
            ]
        ]);
    }

    /**
     * Logout
     */
    public function logout()
    {
        $user = auth()->user();
        
        // LOG: Registrar logout
        if ($user) {
            $tipo = isset($user->cpf_cnpj) ? 'portal' : 'admin';
            LogService::logLogout($user, $tipo);
        }
        
        JWTAuth::logout();
        
        return response()->json([
            'success' => true,
            'message' => 'Logout realizado com sucesso'
        ]);
    }

    /**
     * Get user info
     */
    public function me()
    {
        $user = auth()->user();
        
        // LOG: Registrar acesso aos dados do usuário
        LogService::logAccess('/auth/me', 'GET', [], $user);
        
        $userData = [
            'id' => $user->id,
            'nome' => $user->nome,
            'email' => $user->email
        ];

        // Adicionar campos específicos dependendo do tipo
        if (isset($user->perfil)) {
            // É um User (admin)
            $userData['perfil'] = $user->perfil;
            $userData['unidade_id'] = $user->unidade_id;
            $userData['tipo'] = 'admin';
        } else {
            // É um Cliente
            $userData['cpf_cnpj'] = $user->cpf_cnpj;
            $userData['tipo'] = 'cliente';
        }
        
        return response()->json([
            'success' => true,
            'data' => $userData
        ]);
    }
}
EOF

echo "✅ AuthController atualizado com sistema de logs"