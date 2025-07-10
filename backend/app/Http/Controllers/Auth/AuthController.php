<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Cliente;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    /**
     * @OA\Post(
     *     path="/auth/login",
     *     summary="Login do usuário administrativo",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"email","password"},
     *             @OA\Property(property="email", type="string", format="email"),
     *             @OA\Property(property="password", type="string", format="password")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Login realizado com sucesso"),
     *     @OA\Response(response=401, description="Credenciais inválidas")
     * )
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $credentials = $request->only('email', 'password');

        if (!$token = auth()->attempt($credentials)) {
            return $this->error('Credenciais inválidas', 401);
        }

        $user = auth()->user();
        
        // Atualizar último acesso
        $user->update(['ultimo_acesso' => now()]);

        return $this->success([
            'user' => [
                'id' => $user->id,
                'nome' => $user->nome,
                'email' => $user->email,
                'perfil' => $user->perfil,
                'unidade_id' => $user->unidade_id,
                'unidade' => $user->unidade->nome,
                'is_admin' => $user->is_admin
            ],
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60
        ], 'Login realizado com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/auth/login-client",
     *     summary="Login do cliente no portal",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"cpf_cnpj","password"},
     *             @OA\Property(property="cpf_cnpj", type="string"),
     *             @OA\Property(property="password", type="string", format="password")
     *         )
     *     ),
     *     @OA\Response(response=200, description="Login do cliente realizado com sucesso"),
     *     @OA\Response(response=401, description="Credenciais inválidas")
     * )
     */
    public function loginClient(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'cpf_cnpj' => 'required|string',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->error('Dados inválidos', 422, $validator->errors());
        }

        $cliente = Cliente::where('cpf_cnpj', $request->cpf_cnpj)
                         ->where('acesso_portal', true)
                         ->where('status', 'ativo')
                         ->first();

        if (!$cliente || !Hash::check($request->password, $cliente->senha_portal)) {
            return $this->error('Credenciais inválidas', 401);
        }

        // Registrar acesso
        $cliente->acessosPortal()->create([
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'data_acesso' => now(),
            'acao' => 'login'
        ]);

        $token = auth('cliente')->login($cliente);

        return $this->success([
            'cliente' => [
                'id' => $cliente->id,
                'nome' => $cliente->nome,
                'email' => $cliente->email,
                'tipo_pessoa' => $cliente->tipo_pessoa,
                'documento' => $cliente->documento,
                'unidade' => $cliente->unidade->nome
            ],
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth('cliente')->factory()->getTTL() * 60
        ], 'Login realizado com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/auth/logout",
     *     summary="Logout do usuário",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Logout realizado com sucesso")
     * )
     */
    public function logout()
    {
        auth()->logout();
        return $this->success(null, 'Logout realizado com sucesso');
    }

    /**
     * @OA\Post(
     *     path="/auth/refresh",
     *     summary="Renovar token",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Token renovado com sucesso")
     * )
     */
    public function refresh()
    {
        $token = auth()->refresh();
        
        return $this->success([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60
        ], 'Token renovado com sucesso');
    }

    /**
     * @OA\Get(
     *     path="/auth/me",
     *     summary="Obter dados do usuário autenticado",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=200, description="Dados do usuário")
     * )
     */
    public function me()
    {
        $user = auth()->user();
        
        return $this->success([
            'id' => $user->id,
            'nome' => $user->nome,
            'email' => $user->email,
            'perfil' => $user->perfil,
            'unidade_id' => $user->unidade_id,
            'unidade' => $user->unidade->nome,
            'is_admin' => $user->is_admin,
            'ultimo_acesso' => $user->ultimo_acesso
        ]);
    }
}
