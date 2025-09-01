<?php

namespace Database\Factories;

use App\Models\Cliente;
use App\Models\User;
use App\Models\Unidade;
use Illuminate\Database\Eloquent\Factories\Factory;

class ClienteFactory extends Factory
{
    protected $model = Cliente::class;

    public function definition()
    {
        $tipoPessoa = $this->faker->randomElement(['PF', 'PJ']);
        
        return [
            'nome' => $tipoPessoa === 'PF' 
                ? $this->faker->name() 
                : $this->faker->company() . ' Ltda',
            'cpf_cnpj' => $tipoPessoa === 'PF' 
                ? $this->generateCpf() 
                : $this->generateCnpj(),
            'tipo_pessoa' => $tipoPessoa,
            'email' => $this->faker->unique()->safeEmail(),
            'telefone' => $this->generatePhone(),
            'endereco' => $this->faker->streetAddress(),
            'cep' => $this->generateCep(),
            'cidade' => $this->faker->city(),
            'estado' => $this->faker->randomElement(['SP', 'RJ', 'MG', 'RS', 'PR', 'SC']),
            'observacoes' => $this->faker->optional()->sentence(),
            'acesso_portal' => $this->faker->boolean(30),
            'senha_portal' => bcrypt('123456'),
            'tipo_armazenamento' => $this->faker->randomElement(['local', 'google_drive', 'onedrive']),
            'pasta_local' => $this->faker->slug(),
            'unidade_id' => 1,
            'responsavel_id' => 1,
            'status' => $this->faker->randomElement(['ativo', 'inativo']),
        ];
    }

    private function generateCpf()
    {
        $cpf = '';
        for ($i = 0; $i < 9; $i++) {
            $cpf .= rand(0, 9);
        }
        
        // Calcular dígitos verificadores
        $soma = 0;
        for ($i = 0; $i < 9; $i++) {
            $soma += intval($cpf[$i]) * (10 - $i);
        }
        $resto = $soma % 11;
        $cpf .= ($resto < 2) ? 0 : (11 - $resto);
        
        $soma = 0;
        for ($i = 0; $i < 10; $i++) {
            $soma += intval($cpf[$i]) * (11 - $i);
        }
        $resto = $soma % 11;
        $cpf .= ($resto < 2) ? 0 : (11 - $resto);
        
        return $cpf;
    }

    private function generateCnpj()
    {
        $cnpj = '';
        for ($i = 0; $i < 12; $i++) {
            $cnpj .= rand(0, 9);
        }
        
        // Calcular dígitos verificadores
        $soma = 0;
        $pos = 5;
        for ($i = 0; $i < 12; $i++) {
            $soma += intval($cnpj[$i]) * $pos--;
            if ($pos < 2) $pos = 9;
        }
        $resto = $soma % 11;
        $cnpj .= ($resto < 2) ? 0 : (11 - $resto);
        
        $soma = 0;
        $pos = 6;
        for ($i = 0; $i < 13; $i++) {
            $soma += intval($cnpj[$i]) * $pos--;
            if ($pos < 2) $pos = 9;
        }
        $resto = $soma % 11;
        $cnpj .= ($resto < 2) ? 0 : (11 - $resto);
        
        return $cnpj;
    }

    private function generatePhone()
    {
        return '11' . rand(90000, 99999) . rand(1000, 9999);
    }

    private function generateCep()
    {
        return rand(10000, 99999) . rand(100, 999);
    }

    public function ativo()
    {
        return $this->state([
            'status' => 'ativo',
        ]);
    }

    public function inativo()
    {
        return $this->state([
            'status' => 'inativo',
        ]);
    }

    public function pessoaFisica()
    {
        return $this->state([
            'tipo_pessoa' => 'PF',
            'nome' => $this->faker->name(),
            'cpf_cnpj' => $this->generateCpf(),
        ]);
    }

    public function pessoaJuridica()
    {
        return $this->state([
            'tipo_pessoa' => 'PJ',
            'nome' => $this->faker->company() . ' Ltda',
            'cpf_cnpj' => $this->generateCnpj(),
        ]);
    }
}
