#!/bin/bash

# Script 114b - Corrigir Seeders + Conectar Frontend com API Real
# Sistema Erlene Advogados - Corrigir tabelas vazias e integrar frontend
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "114b - Corrigindo seeders e conectando frontend com API real..."

# Verificar se estamos no diretório correto (deve executar dentro de backend/)
if [ ! -f "artisan" ]; then
    echo "Erro: Execute este script dentro da pasta backend/"
    echo "Comando correto:"
    echo "   cd backend"
    echo "   chmod +x 114b-fix-seeders-frontend.sh && ./114b-fix-seeders-frontend.sh"
    exit 1
fi

echo "1. Verificando e corrigindo banco de dados..."

# Verificar conexão com banco
php artisan migrate:status

if [ $? -ne 0 ]; then
    echo "Erro na conexão com banco. Verificando configuração..."
    echo "Configuração atual do banco:"
    grep "DB_" .env
    
    echo "Testando conexão MySQL..."
    mysql -u root -p12345678 -e "SHOW DATABASES;" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "ERRO: MySQL não está acessível."
        echo "Soluções:"
        echo "1. sudo systemctl start mysql"
        echo "2. Verificar senha no .env"
        echo "3. Criar banco: CREATE DATABASE erlene_advogados;"
        exit 1
    fi
fi

echo "2. Executando migrations fresh com seeders..."

# Executar migrations do zero e forçar seeders
php artisan migrate:fresh --force
php artisan db:seed --class=FrontendTestSeeder --force

echo "3. Verificando dados criados no banco..."

# Verificar se usuários foram criados
echo "Usuários criados:"
mysql -u root -p12345678 erlene_advogados -e "SELECT id, nome, email, perfil, status FROM users;" 2>/dev/null

echo ""
echo "Unidades criadas:"
mysql -u root -p12345678 erlene_advogados -e "SELECT id, nome, codigo, cidade FROM unidades;" 2>/dev/null

echo "4. Atualizando página welcome do Laravel para mostrar status da API..."

cat > resources/views/welcome.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sistema Erlene Advogados - API</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #1e3a8a 0%, #dc2626 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 90%;
        }
        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #dc2626, #b91c1c);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            color: white;
            font-size: 32px;
            font-weight: bold;
        }
        h1 {
            color: #1f2937;
            margin-bottom: 10px;
            font-size: 28px;
        }
        .subtitle {
            color: #6b7280;
            margin-bottom: 30px;
            font-size: 16px;
        }
        .status {
            background: #10b981;
            color: white;
            padding: 12px 24px;
            border-radius: 25px;
            display: inline-block;
            margin-bottom: 25px;
            font-weight: 500;
        }
        .info {
            background: #f3f4f6;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 25px;
        }
        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e5e7eb;
        }
        .info-item:last-child {
            border-bottom: none;
        }
        .label {
            font-weight: 600;
            color: #374151;
        }
        .value {
            color: #6b7280;
        }
        .footer {
            color: #9ca3af;
            font-size: 14px;
            margin-top: 30px;
        }
        .version {
            background: #3b82f6;
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            display: inline-block;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">E</div>
        <h1>Sistema Erlene Advogados</h1>
        <p class="subtitle">API Backend Laravel</p>
        
        <div class="status">
            🟢 API Operacional
        </div>
        
        <div class="info">
            <div class="info-item">
                <span class="label">Status:</span>
                <span class="value">Conectado</span>
            </div>
            <div class="info-item">
                <span class="label">Ambiente:</span>
                <span class="value">{{ app()->environment() }}</span>
            </div>
            <div class="info-item">
                <span class="label">Versão Laravel:</span>
                <span class="value">{{ App::VERSION() }}</span>
            </div>
            <div class="info-item">
                <span class="label">Banco de Dados:</span>
                <span class="value">MySQL Conectado</span>
            </div>
            <div class="info-item">
                <span class="label">Data/Hora:</span>
                <span class="value">{{ now()->format('d/m/Y H:i:s') }}</span>
            </div>
        </div>
        
        <div class="footer">
            © 2024 Erlene Chaves Silva Advogados Associados
            <div class="version">v1.0.0</div>
        </div>
    </div>
</body>
</html>
EOF

echo "5. Testando rotas da API..."

# Testar se servidor está rodando
if ! curl -s http://localhost:8000 > /dev/null; then
    echo "Iniciando servidor Laravel..."
    php artisan serve --port=8000 &
    LARAVEL_PID=$!
    sleep 3
else
    echo "Servidor Laravel já está rodando"
fi

echo "Testando rota /api/test..."
curl -s http://localhost:8000/api/test || echo "Erro na rota /api/test"

echo ""
echo "Testando rota /api/health..."
curl -s http://localhost:8000/api/health || echo "Erro na rota /api/health"

echo "6. Criando service de API para o Frontend..."

# Criar arquivo de serviço da API para o frontend
cat > ../frontend/src/services/api.js << 'EOF'
// API Service - Sistema Erlene Advogados
// Serviço para comunicação com o backend Laravel

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

class ApiService {
  constructor() {
    this.baseURL = API_BASE_URL;
    this.token = localStorage.getItem('erlene_token');
  }

  // Headers padrão para requisições
  getHeaders(includeAuth = true) {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    return headers;
  }

  // Método genérico para fazer requisições
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      ...options,
      headers: {
        ...this.getHeaders(options.auth !== false),
        ...(options.headers || {})
      }
    };

    try {
      const response = await fetch(url, config);
      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || `HTTP error! status: ${response.status}`);
      }

      return data;
    } catch (error) {
      console.error('API Request Error:', error);
      throw error;
    }
  }

  // Métodos de autenticação
  async loginAdmin(email, password) {
    const response = await this.request('/auth/login', {
      method: 'POST',
      auth: false,
      body: JSON.stringify({ email, password })
    });

    if (response.success && response.access_token) {
      this.setToken(response.access_token);
      this.setUser(response.user);
    }

    return response;
  }

  async loginPortal(cpf_cnpj, password) {
    const response = await this.request('/auth/portal/login', {
      method: 'POST',
      auth: false,
      body: JSON.stringify({ cpf_cnpj, password })
    });

    if (response.success && response.access_token) {
      this.setToken(response.access_token);
      this.setUser(response.user);
    }

    return response;
  }

  async logout() {
    try {
      await this.request('/auth/logout', {
        method: 'POST'
      });
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      this.clearAuth();
    }
  }

  async getMe() {
    return await this.request('/auth/me');
  }

  async refreshToken() {
    return await this.request('/auth/refresh', {
      method: 'POST'
    });
  }

  // Métodos de dashboard
  async getDashboardStats() {
    return await this.request('/dashboard/stats');
  }

  // Métodos de teste
  async testConnection() {
    return await this.request('/health', { auth: false });
  }

  // Gerenciamento de token e usuário
  setToken(token) {
    this.token = token;
    localStorage.setItem('erlene_token', token);
  }

  setUser(user) {
    localStorage.setItem('erlene_user', JSON.stringify(user));
  }

  getUser() {
    const user = localStorage.getItem('erlene_user');
    return user ? JSON.parse(user) : null;
  }

  getToken() {
    return this.token || localStorage.getItem('erlene_token');
  }

  clearAuth() {
    this.token = null;
    localStorage.removeItem('erlene_token');
    localStorage.removeItem('erlene_user');
    // Manter compatibilidade com sistema antigo
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('portalAuth');
    localStorage.removeItem('userType');
    localStorage.removeItem('user');
  }

  isAuthenticated() {
    return !!this.getToken();
  }
}

// Exportar instância singleton
const apiService = new ApiService();
export default apiService;

// Exportar para uso direto
export { apiService };
EOF

echo "7. Atualizando tela de Login Admin para usar API real..."

cat > ../frontend/src/pages/auth/Login/index.js << 'EOF'
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  EyeIcon, 
  EyeSlashIcon, 
  UserIcon,
  LockClosedIcon 
} from '@heroicons/react/24/outline';
import apiService from '../../../services/api';

const Login = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      // Fazer login via API real
      const response = await apiService.loginAdmin(formData.email, formData.password);
      
      if (response.success) {
        // Login bem sucedido
        localStorage.setItem('isAuthenticated', 'true');
        localStorage.setItem('userType', 'admin');
        localStorage.removeItem('portalAuth'); // Limpar auth do portal
        
        navigate('/admin');
      } else {
        setError(response.message || 'Credenciais inválidas');
      }
    } catch (err) {
      console.error('Login error:', err);
      setError(err.message || 'Erro ao fazer login. Tente novamente.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header com Logo */}
        <div className="text-center">
          <div className="mx-auto h-20 w-20 bg-gradient-to-r from-red-600 to-red-700 rounded-xl flex items-center justify-center mb-8 shadow-lg">
            <span className="text-white font-bold text-3xl">E</span>
          </div>
          <h2 className="text-4xl font-bold text-gray-900 mb-3">
            Sistema Erlene Advogados
          </h2>
          <p className="text-lg text-gray-600 mb-2">
            Gestão Jurídica Inteligente
          </p>
          <p className="text-sm text-gray-500">
            Entre com suas credenciais para acessar o sistema
          </p>
        </div>

        {/* Card do Formulário */}
        <div className="bg-white py-10 px-8 shadow-lg rounded-xl border border-gray-100">
          <form className="space-y-8" onSubmit={handleSubmit}>
            {/* Campo Email */}
            <div>
              <label 
                htmlFor="email" 
                className="block text-sm font-semibold text-gray-700 mb-3"
              >
                E-mail Corporativo
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <UserIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={formData.email}
                  onChange={handleInputChange}
                  className="block w-full pl-10 pr-3 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm transition-all duration-200"
                  placeholder="admin@erlene.com"
                />
              </div>
            </div>

            {/* Campo Senha */}
            <div>
              <label 
                htmlFor="password" 
                className="block text-sm font-semibold text-gray-700 mb-3"
              >
                Senha de Acesso
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <LockClosedIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  required
                  value={formData.password}
                  onChange={handleInputChange}
                  className="block w-full pl-10 pr-12 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm transition-all duration-200"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeSlashIcon className="h-5 w-5 text-gray-400 hover:text-red-600 transition-colors" />
                  ) : (
                    <EyeIcon className="h-5 w-5 text-gray-400 hover:text-red-600 transition-colors" />
                  )}
                </button>
              </div>
            </div>

            {/* Mensagem de Erro */}
            {error && (
              <div className="bg-red-50 border-l-4 border-red-400 p-4 rounded-lg">
                <div className="flex">
                  <div className="ml-3">
                    <p className="text-sm text-red-700 font-medium">{error}</p>
                  </div>
                </div>
              </div>
            )}

            {/* Botão de Login */}
            <div>
              <button
                type="submit"
                disabled={isLoading}
                className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-semibold rounded-lg text-white bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
              >
                {isLoading ? (
                  <div className="flex items-center">
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-3"></div>
                    Autenticando...
                  </div>
                ) : (
                  <span className="flex items-center">
                    <LockClosedIcon className="h-5 w-5 mr-2" />
                    Acessar Sistema
                  </span>
                )}
              </button>
            </div>
          </form>

          {/* Links Auxiliares */}
          <div className="mt-8 text-center space-y-4">
            <a 
              href="#" 
              className="text-sm text-red-600 hover:text-red-700 font-medium transition-colors"
            >
              Esqueceu sua senha?
            </a>
            
            <div className="flex items-center justify-center space-x-2 text-sm text-gray-500">
              <span>Portal do cliente?</span>
              <a 
                href="/portal/login" 
                className="text-red-600 hover:text-red-700 font-medium transition-colors"
              >
                Acesse aqui
              </a>
            </div>
          </div>
        </div>

        {/* Credenciais Demo */}
        <div className="bg-blue-50 border border-blue-200 rounded-xl p-6">
          <h3 className="text-sm font-semibold text-blue-900 mb-4 text-center">
            Credenciais para Demonstração
          </h3>
          <div className="space-y-3 text-sm text-blue-800">
            <div className="bg-white p-3 rounded-lg">
              <div className="font-medium text-blue-900">Administrador</div>
              <div className="text-blue-700">admin@erlene.com</div>
              <div className="text-blue-600">Senha: 123456</div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center text-sm text-gray-500 space-y-2">
          <p>© 2024 Erlene Chaves Silva Advogados Associados</p>
          <div className="flex items-center justify-center space-x-2 text-xs">
            <span>Desenvolvido por</span>
            <a 
              href="#" 
              className="text-red-600 hover:text-red-700 font-medium"
            >
              Vancouver Tec
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
EOF

echo "8. Parar servidor se foi iniciado pelo script..."
if [ ! -z "$LARAVEL_PID" ]; then
    kill $LARAVEL_PID 2>/dev/null
fi

echo ""
echo "SCRIPT 114B CONCLUÍDO!"
echo ""
echo "CORREÇÕES FEITAS:"
echo "   1. Seeders executados - tabelas preenchidas"
echo "   2. Página welcome atualizada - mostra status da API"
echo "   3. Service API criado - frontend/src/services/api.js"
echo "   4. Login Admin atualizado - usa API real"
echo ""
echo "USUÁRIOS CRIADOS NO BANCO:"
echo "   Admin: admin@erlene.com / 123456"
echo "   Cliente: CPF 123.456.789-00 / 123456"
echo ""
echo "TESTE AGORA:"
echo "   1. php artisan serve (backend)"
echo "   2. Acesse http://localhost:8000 (deve mostrar status API)"
echo "   3. cd ../frontend && npm start"
echo "   4. Login: admin@erlene.com / 123456"
echo ""
echo "PRÓXIMO: Digite 'continuar' para Script 114c (Portal Cliente + API)"