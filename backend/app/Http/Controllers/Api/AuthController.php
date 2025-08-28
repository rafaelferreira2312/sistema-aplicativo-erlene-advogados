<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Credenciais inválidas',
                'errors' => ['email' => ['Email ou senha incorretos']]
            ], 401);
        }

        try {
            $token = JWTAuth::fromUser($user);
            
            return response()->json([
                'success' => true,
                'message' => 'Login realizado com sucesso',
                'access_token' => $token,
                'token_type' => 'bearer',
                'user' => [
                    'id' => $user->id,
                    'nome' => $user->nome ?? $user->name,
                    'email' => $user->email,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao gerar token: ' . $e->getMessage()
            ], 500);
        }
    }

    public function portalLogin(Request $request)
    {
        $request->validate([
            'cpf_cnpj' => 'required|string',
            'password' => 'required|string',
        ]);

        // Para teste, aceitar qualquer CPF com senha 123456
        if ($request->password === '123456') {
            // Buscar ou criar cliente teste
            $user = User::where('email', 'cliente@teste.com')->first();
            
            if (!$user) {
                $user = User::create([
                    'nome' => 'Cliente Teste',
                    'name' => 'Cliente Teste',
                    'email' => 'cliente@teste.com',
                    'password' => Hash::make('123456')
                ]);
            }

            $token = JWTAuth::fromUser($user);

            return response()->json([
                'success' => true,
                'access_token' => $token,
                'user' => [
                    'id' => $user->id,
                    'nome' => $user->nome ?? $user->name,
                    'email' => $user->email,
                ]
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'CPF/CNPJ ou senha incorretos'
        ], 401);
    }

    public function me()
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();
            return response()->json([
                'success' => true,
                'user' => $user
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token inválido'
            ], 401);
        }
    }

    public function logout()
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
            return response()->json([
                'success' => true,
                'message' => 'Logout realizado'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro no logout'
            ], 500);
        }
    }
}
