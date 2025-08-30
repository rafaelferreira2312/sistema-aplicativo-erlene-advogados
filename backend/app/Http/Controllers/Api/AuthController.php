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
