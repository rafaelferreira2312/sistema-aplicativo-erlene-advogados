#!/bin/bash

# Script 32 - Sistema de Autenticação React
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/32-create-auth-system.sh

echo "🔐 Criando sistema de autenticação..."

# src/context/auth/AuthContext.js
cat > frontend/src/context/auth/AuthContext.js << 'EOF'
import { createContext } from 'react';

export const AuthContext = createContext({
  user: null,
  token: null,
  isAuthenticated: false,
  isLoading: true,
  login: () => {},
  logout: () => {},
  updateUser: () => {},
  hasPermission: () => false,
  hasRole: () => false,
});
EOF

# src/context/auth/AuthProvider.js
cat > frontend/src/context/auth/AuthProvider.js << 'EOF'
import React, { useState, useEffect, useCallback } from 'react';
import { AuthContext } from './AuthContext';
import { authService } from '../../services/auth/authService';
import { tokenService } from '../../services/auth/tokenService';
import { APP_CONFIG } from '../../config/constants';

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  // Inicializar auth state
  useEffect(() => {
    const initializeAuth = async () => {
      try {
        const storedToken = tokenService.getToken();
        const storedUser = tokenService.getUser();

        if (storedToken && storedUser) {
          // Verificar se o token ainda é válido
          const isValid = await authService.validateToken(storedToken);
          
          if (isValid) {
            setToken(storedToken);
            setUser(storedUser);
            authService.setAuthHeader(storedToken);
          } else {
            // Token inválido, limpar dados
            await logout();
          }
        }
      } catch (error) {
        console.error('Erro ao inicializar autenticação:', error);
        await logout();
      } finally {
        setIsLoading(false);
      }
    };

    initializeAuth();
  }, []);

  // Login
  const login = useCallback(async (credentials) => {
    setIsLoading(true);
    
    try {
      const response = await authService.login(credentials);
      const { user: userData, token: userToken } = response;

      // Salvar dados no storage
      tokenService.setToken(userToken);
      tokenService.setUser(userData);

      // Atualizar state
      setUser(userData);
      setToken(userToken);
      
      // Configurar header para próximas requisições
      authService.setAuthHeader(userToken);

      return { success: true, user: userData };
    } catch (error) {
      console.error('Erro no login:', error);
      return { 
        success: false, 
        error: error.response?.data?.message || 'Erro ao fazer login' 
      };
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Logout
  const logout = useCallback(async () => {
    try {
      // Chamar logout no backend (invalidar token)
      if (token) {
        await authService.logout();
      }
    } catch (error) {
      console.error('Erro no logout:', error);
    } finally {
      // Limpar dados locais
      tokenService.removeToken();
      tokenService.removeUser();
      
      setUser(null);
      setToken(null);
      
      // Remover header de autenticação
      authService.removeAuthHeader();
    }
  }, [token]);

  // Atualizar dados do usuário
  const updateUser = useCallback((userData) => {
    setUser(userData);
    tokenService.setUser(userData);
  }, []);

  // Verificar permissão
  const hasPermission = useCallback((permission) => {
    if (!user || !user.permissions) return false;
    return user.permissions.includes(permission);
  }, [user]);

  // Verificar role
  const hasRole = useCallback((role) => {
    if (!user || !user.perfil) return false;
    if (Array.isArray(role)) {
      return role.includes(user.perfil);
    }
    return user.perfil === role;
  }, [user]);

  const value = {
    user,
    token,
    isAuthenticated: !!user && !!token,
    isLoading,
    login,
    logout,
    updateUser,
    hasPermission,
    hasRole,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
EOF

# src/hooks/auth/useAuth.js
cat > frontend/src/hooks/auth/useAuth.js << 'EOF'
import { useContext } from 'react';
import { AuthContext } from '../../context/auth/AuthContext';

export const useAuth = () => {
  const context = useContext(AuthContext);
  
  if (!context) {
    throw new Error('useAuth deve ser usado dentro de um AuthProvider');
  }
  
  return context;
};
EOF

# src/services/auth/tokenService.js
cat > frontend/src/services/auth/tokenService.js << 'EOF'
import { APP_CONFIG } from '../../config/constants';

export const tokenService = {
  // Token de acesso
  getToken: () => {
    return localStorage.getItem(APP_CONFIG.STORAGE_KEYS.TOKEN);
  },

  setToken: (token) => {
    localStorage.setItem(APP_CONFIG.STORAGE_KEYS.TOKEN, token);
  },

  removeToken: () => {
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.TOKEN);
  },

  // Refresh token
  getRefreshToken: () => {
    return localStorage.getItem(APP_CONFIG.STORAGE_KEYS.REFRESH_TOKEN);
  },

  setRefreshToken: (refreshToken) => {
    localStorage.setItem(APP_CONFIG.STORAGE_KEYS.REFRESH_TOKEN, refreshToken);
  },

  removeRefreshToken: () => {
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.REFRESH_TOKEN);
  },

  // Dados do usuário
  getUser: () => {
    const userData = localStorage.getItem(APP_CONFIG.STORAGE_KEYS.USER);
    return userData ? JSON.parse(userData) : null;
  },

  setUser: (user) => {
    localStorage.setItem(APP_CONFIG.STORAGE_KEYS.USER, JSON.stringify(user));
  },

  removeUser: () => {
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.USER);
  },

  // Verificar se o token está expirado
  isTokenExpired: (token) => {
    if (!token) return true;

    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const currentTime = Date.now() / 1000;
      
      return payload.exp < currentTime;
    } catch (error) {
      return true;
    }
  },

  // Limpar todos os dados de autenticação
  clearAll: () => {
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.TOKEN);
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.REFRESH_TOKEN);
    localStorage.removeItem(APP_CONFIG.STORAGE_KEYS.USER);
  },
};
EOF

# src/services/auth/authService.js
cat > frontend/src/services/auth/authService.js << 'EOF'
import { apiClient } from '../api/apiClient';
import { tokenService } from './tokenService';

export const authService = {
  // Login
  async login(credentials) {
    const response = await apiClient.post('/auth/login', credentials);
    return response.data;
  },

  // Login do portal do cliente
  async portalLogin(credentials) {
    const response = await apiClient.post('/auth/portal/login', credentials);
    return response.data;
  },

  // Logout
  async logout() {
    try {
      await apiClient.post('/auth/logout');
    } catch (error) {
      console.error('Erro no logout:', error);
    }
  },

  // Refresh token
  async refreshToken() {
    const refreshToken = tokenService.getRefreshToken();
    
    if (!refreshToken) {
      throw new Error('Refresh token não encontrado');
    }

    const response = await apiClient.post('/auth/refresh', {
      refresh_token: refreshToken
    });

    return response.data;
  },

  // Validar token
  async validateToken(token) {
    try {
      const response = await apiClient.get('/auth/validate', {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      return response.data.valid;
    } catch (error) {
      return false;
    }
  },

  // Esqueci minha senha
  async forgotPassword(email) {
    const response = await apiClient.post('/auth/forgot-password', { email });
    return response.data;
  },

  // Resetar senha
  async resetPassword(token, password, passwordConfirmation) {
    const response = await apiClient.post('/auth/reset-password', {
      token,
      password,
      password_confirmation: passwordConfirmation
    });
    return response.data;
  },

  // Alterar senha
  async changePassword(currentPassword, newPassword, newPasswordConfirmation) {
    const response = await apiClient.post('/auth/change-password', {
      current_password: currentPassword,
      new_password: newPassword,
      new_password_confirmation: newPasswordConfirmation
    });
    return response.data;
  },

  // Verificar email
  async verifyEmail(token) {
    const response = await apiClient.post('/auth/verify-email', { token });
    return response.data;
  },

  // Reenviar verificação de email
  async resendEmailVerification() {
    const response = await apiClient.post('/auth/resend-email-verification');
    return response.data;
  },

  // Obter perfil do usuário
  async getProfile() {
    const response = await apiClient.get('/auth/profile');
    return response.data;
  },

  // Atualizar perfil
  async updateProfile(profileData) {
    const response = await apiClient.put('/auth/profile', profileData);
    return response.data;
  },

  // Configurar header de autenticação
  setAuthHeader(token) {
    if (token) {
      apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    }
  },

  // Remover header de autenticação
  removeAuthHeader() {
    delete apiClient.defaults.headers.common['Authorization'];
  },
};
EOF

# src/components/auth/PrivateRoute.js
cat > frontend/src/components/auth/PrivateRoute.js << 'EOF'
import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/auth/useAuth';
import Loading from '../common/Loading';

const PrivateRoute = ({ children, allowedRoles = [] }) => {
  const { isAuthenticated, isLoading, hasRole } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loading size="large" />
      </div>
    );
  }

  if (!isAuthenticated) {
    // Redirecionar para login mantendo a URL de destino
    return (
      <Navigate 
        to="/login" 
        state={{ from: location }} 
        replace 
      />
    );
  }

  // Verificar roles se especificados
  if (allowedRoles.length > 0 && !hasRole(allowedRoles)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return children;
};

export default PrivateRoute;
EOF

# src/components/auth/PublicRoute.js
cat > frontend/src/components/auth/PublicRoute.js << 'EOF'
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../hooks/auth/useAuth';
import Loading from '../common/Loading';

const PublicRoute = ({ children }) => {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loading size="large" />
      </div>
    );
  }

  if (isAuthenticated) {
    // Redirecionar usuários autenticados para dashboard apropriado
    if (user?.perfil === 'cliente') {
      return <Navigate to="/portal" replace />;
    } else {
      return <Navigate to="/admin" replace />;
    }
  }

  return children;
};

export default PublicRoute;
EOF

# src/pages/auth/Login/index.js
cat > frontend/src/pages/auth/Login/index.js << 'EOF'
import React, { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { toast } from 'react-hot-toast';
import { 
  EyeIcon, 
  EyeSlashIcon, 
  UserIcon, 
  LockClosedIcon 
} from '@heroicons/react/24/outline';

import { useAuth } from '../../../hooks/auth/useAuth';
import Button from '../../../components/common/Button';
import Input from '../../../components/common/Input';
import Loading from '../../../components/common/Loading';

const Login = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  
  const from = location.state?.from?.pathname || '/admin';

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm();

  const onSubmit = async (data) => {
    setIsLoading(true);

    try {
      const result = await login(data);

      if (result.success) {
        toast.success('Login realizado com sucesso!');
        
        // Redirecionar baseado no tipo de usuário
        if (result.user.perfil === 'cliente') {
          navigate('/portal', { replace: true });
        } else {
          navigate(from, { replace: true });
        }
      } else {
        toast.error(result.error || 'Erro ao fazer login');
      }
    } catch (error) {
      toast.error('Erro inesperado. Tente novamente.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex">
      {/* Painel esquerdo - Imagem/Branding */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-erlene relative">
        <div className="flex flex-col justify-center items-center w-full p-12 text-white">
          <div className="max-w-md text-center">
            <h1 className="text-4xl font-bold mb-6">
              Sistema Erlene Advogados
            </h1>
            <p className="text-xl mb-8 opacity-90">
              Gestão jurídica completa para seu escritório
            </p>
            <div className="space-y-4 text-left">
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-secondary-500 rounded-full"></div>
                <span>Gestão de clientes e processos</span>
              </div>
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-secondary-500 rounded-full"></div>
                <span>Sistema GED integrado</span>
              </div>
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-secondary-500 rounded-full"></div>
                <span>Integração com tribunais</span>
              </div>
              <div className="flex items-center space-x-3">
                <div className="w-2 h-2 bg-secondary-500 rounded-full"></div>
                <span>Portal do cliente</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Painel direito - Formulário */}
      <div className="flex-1 flex flex-col justify-center py-12 px-4 sm:px-6 lg:px-20 xl:px-24">
        <div className="mx-auto w-full max-w-sm lg:w-96">
          <div>
            <h2 className="text-3xl font-bold text-gray-900 mb-2">
              Fazer login
            </h2>
            <p className="text-gray-600">
              Entre com suas credenciais para acessar o sistema
            </p>
          </div>

          <div className="mt-8">
            <form className="space-y-6" onSubmit={handleSubmit(onSubmit)}>
              <Input
                label="E-mail"
                type="email"
                icon={UserIcon}
                {...register('email', {
                  required: 'E-mail é obrigatório',
                  pattern: {
                    value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                    message: 'E-mail inválido'
                  }
                })}
                error={errors.email?.message}
                placeholder="seu@email.com"
              />

              <div className="relative">
                <Input
                  label="Senha"
                  type={showPassword ? 'text' : 'password'}
                  icon={LockClosedIcon}
                  {...register('password', {
                    required: 'Senha é obrigatória',
                    minLength: {
                      value: 6,
                      message: 'Senha deve ter pelo menos 6 caracteres'
                    }
                  })}
                  error={errors.password?.message}
                  placeholder="Sua senha"
                />
                
                <button
                  type="button"
                  className="absolute right-3 top-9 text-gray-400 hover:text-gray-600"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeSlashIcon className="h-5 w-5" />
                  ) : (
                    <EyeIcon className="h-5 w-5" />
                  )}
                </button>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <input
                    id="remember-me"
                    name="remember-me"
                    type="checkbox"
                    className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                  />
                  <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-900">
                    Lembrar de mim
                  </label>
                </div>

                <div className="text-sm">
                  <Link
                    to="/forgot-password"
                    className="font-medium text-primary-600 hover:text-primary-500"
                  >
                    Esqueceu sua senha?
                  </Link>
                </div>
              </div>

              <Button
                type="submit"
                variant="primary"
                size="lg"
                className="w-full"
                disabled={isLoading}
              >
                {isLoading ? (
                  <Loading size="small" color="white" />
                ) : (
                  'Entrar'
                )}
              </Button>
            </form>

            <div className="mt-6">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-300" />
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-2 bg-white text-gray-500">
                    Ou acesse o
                  </span>
                </div>
              </div>

              <div className="mt-6">
                <Link
                  to="/portal/login"
                  className="w-full flex justify-center py-3 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                >
                  Portal do Cliente
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
EOF

echo "✅ Sistema de autenticação criado com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • AuthContext.js - Context de autenticação"
echo "   • AuthProvider.js - Provider com lógica completa"
echo "   • useAuth.js - Hook personalizado"
echo "   • tokenService.js - Gerenciamento de tokens"
echo "   • authService.js - Serviços de autenticação"
echo "   • PrivateRoute.js - Proteção de rotas"
echo "   • PublicRoute.js - Rotas públicas"
echo "   • Login/index.js - Página de login"
echo ""
echo "🔐 FUNCIONALIDADES INCLUÍDAS:"
echo "   • Login/Logout com JWT"
echo "   • Refresh token automático"
echo "   • Verificação de permissões e roles"
echo "   • Proteção de rotas por perfil"
echo "   • Persistência segura no localStorage"
echo "   • Validação de token expirado"
echo "   • Portal do cliente separado"
echo ""
echo "⏭️  Próximo: Componentes UI (Loading, Button, Input, etc)!"