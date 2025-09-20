#!/bin/bash

# Script 204 - Sistema de Autenticação JWT Node.js
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔐 Script 204 - Criando Sistema de Autenticação JWT Node.js..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

# Verificar se Prisma schema existe
if [ ! -f "prisma/schema.prisma" ]; then
    echo "❌ Erro: Prisma schema não encontrado. Execute script 203 primeiro."
    exit 1
fi

echo "✅ Verificação de diretório OK"

# Fazer backup dos arquivos existentes
echo "📦 Criando backup dos arquivos existentes..."
mkdir -p backups/script-204
if [ -f "src/middleware/auth.ts" ]; then
    cp src/middleware/auth.ts backups/script-204/auth.ts.bak
fi
if [ -f "src/controllers/AuthController.ts" ]; then
    cp src/controllers/AuthController.ts backups/script-204/AuthController.ts.bak
fi

echo "✅ Backup criado"

# 1. Instalar dependências de autenticação JWT
echo "📦 Instalando dependências JWT..."
npm install --save jsonwebtoken bcryptjs
npm install --save-dev @types/jsonwebtoken @types/bcryptjs

# 2. Criar middleware de autenticação JWT
echo "🔧 Criando middleware de autenticação..."
cat > src/middleware/auth.ts << 'EOF'
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Estender interface Request para incluir user
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email: string;
        role: string;
        name: string;
      };
    }
  }
}

export interface JWTPayload {
  userId: string;
  email: string;
  role: string;
  iat?: number;
  exp?: number;
}

// Middleware de autenticação principal
export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.header('Authorization');
    const token = authHeader?.replace('Bearer ', '');

    if (!token) {
      res.status(401).json({
        success: false,
        message: 'Token de acesso não fornecido'
      });
      return;
    }

    // Verificar se JWT_SECRET existe
    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      console.error('JWT_SECRET não definido no .env');
      res.status(500).json({
        success: false,
        message: 'Erro de configuração do servidor'
      });
      return;
    }

    // Verificar e decodificar token
    const decoded = jwt.verify(token, jwtSecret) as JWTPayload;

    // Buscar usuário no banco
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        active: true
      }
    });

    if (!user) {
      res.status(401).json({
        success: false,
        message: 'Usuário não encontrado'
      });
      return;
    }

    if (!user.active) {
      res.status(401).json({
        success: false,
        message: 'Usuário inativo'
      });
      return;
    }

    // Adicionar usuário ao request
    req.user = {
      id: user.id,
      email: user.email,
      role: user.role,
      name: user.name
    };

    next();
  } catch (error) {
    console.error('Erro na autenticação:', error);
    
    if (error instanceof jwt.JsonWebTokenError) {
      res.status(401).json({
        success: false,
        message: 'Token inválido'
      });
      return;
    }

    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({
        success: false,
        message: 'Token expirado'
      });
      return;
    }

    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor'
    });
  }
};

// Middleware para verificar roles específicas
export const authorize = (allowedRoles: string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Usuário não autenticado'
      });
      return;
    }

    if (!allowedRoles.includes(req.user.role)) {
      res.status(403).json({
        success: false,
        message: 'Acesso negado - Role insuficiente'
      });
      return;
    }

    next();
  };
};

// Middleware opcional (não retorna erro se não autenticado)
export const optionalAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.header('Authorization');
    const token = authHeader?.replace('Bearer ', '');

    if (token && process.env.JWT_SECRET) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET) as JWTPayload;
      
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        select: {
          id: true,
          email: true,
          name: true,
          role: true,
          active: true
        }
      });

      if (user && user.active) {
        req.user = {
          id: user.id,
          email: user.email,
          role: user.role,
          name: user.name
        };
      }
    }

    next();
  } catch (error) {
    // Em caso de erro, continua sem usuário autenticado
    next();
  }
};
EOF

# 3. Criar controller de autenticação
echo "🎮 Criando AuthController..."
cat > src/controllers/AuthController.ts << 'EOF'
import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';

const prisma = new PrismaClient();

// Schemas de validação
const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(1, 'Senha é obrigatória')
});

const registerSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'Senha deve ter pelo menos 6 caracteres'),
  role: z.enum(['admin', 'lawyer', 'client']).optional()
});

const changePasswordSchema = z.object({
  currentPassword: z.string().min(1, 'Senha atual é obrigatória'),
  newPassword: z.string().min(6, 'Nova senha deve ter pelo menos 6 caracteres'),
  confirmPassword: z.string().min(1, 'Confirmação de senha é obrigatória')
}).refine((data) => data.newPassword === data.confirmPassword, {
  message: "Senhas não coincidem",
  path: ["confirmPassword"]
});

export class AuthController {
  // Login de usuário
  static async login(req: Request, res: Response): Promise<void> {
    try {
      // Validar dados de entrada
      const validatedData = loginSchema.parse(req.body);
      const { email, password } = validatedData;

      // Buscar usuário
      const user = await prisma.user.findUnique({
        where: { email: email.toLowerCase() },
        select: {
          id: true,
          email: true,
          name: true,
          password: true,
          role: true,
          active: true,
          createdAt: true
        }
      });

      if (!user) {
        res.status(401).json({
          success: false,
          message: 'Credenciais inválidas'
        });
        return;
      }

      if (!user.active) {
        res.status(401).json({
          success: false,
          message: 'Conta inativa. Entre em contato com o administrador.'
        });
        return;
      }

      // Verificar senha
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        res.status(401).json({
          success: false,
          message: 'Credenciais inválidas'
        });
        return;
      }

      // Gerar token JWT
      const jwtSecret = process.env.JWT_SECRET;
      if (!jwtSecret) {
        console.error('JWT_SECRET não definido');
        res.status(500).json({
          success: false,
          message: 'Erro de configuração do servidor'
        });
        return;
      }

      const token = jwt.sign(
        {
          userId: user.id,
          email: user.email,
          role: user.role
        },
        jwtSecret,
        { expiresIn: '24h' }
      );

      // Atualizar último login
      await prisma.user.update({
        where: { id: user.id },
        data: { updatedAt: new Date() }
      });

      res.status(200).json({
        success: true,
        message: 'Login realizado com sucesso',
        data: {
          access_token: token,
          token_type: 'Bearer',
          expires_in: 86400, // 24 horas em segundos
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            created_at: user.createdAt
          }
        }
      });
    } catch (error) {
      console.error('Erro no login:', error);
      
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: error.errors.map(err => ({
            field: err.path.join('.'),
            message: err.message
          }))
        });
        return;
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  }

  // Registro de novo usuário
  static async register(req: Request, res: Response): Promise<void> {
    try {
      const validatedData = registerSchema.parse(req.body);
      const { name, email, password, role = 'client' } = validatedData;

      // Verificar se email já existe
      const existingUser = await prisma.user.findUnique({
        where: { email: email.toLowerCase() }
      });

      if (existingUser) {
        res.status(400).json({
          success: false,
          message: 'Email já está em uso'
        });
        return;
      }

      // Hash da senha
      const saltRounds = 12;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Criar usuário
      const user = await prisma.user.create({
        data: {
          name,
          email: email.toLowerCase(),
          password: hashedPassword,
          role,
          active: true
        },
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
          createdAt: true
        }
      });

      res.status(201).json({
        success: true,
        message: 'Usuário criado com sucesso',
        data: { user }
      });
    } catch (error) {
      console.error('Erro no registro:', error);
      
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: error.errors.map(err => ({
            field: err.path.join('.'),
            message: err.message
          }))
        });
        return;
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  }

  // Logout (invalidar token)
  static async logout(req: Request, res: Response): Promise<void> {
    try {
      // Em JWT stateless, o logout é feito no frontend removendo o token
      // Aqui podemos registrar o logout para auditoria
      if (req.user) {
        console.log(`Usuário ${req.user.email} fez logout`);
      }

      res.status(200).json({
        success: true,
        message: 'Logout realizado com sucesso'
      });
    } catch (error) {
      console.error('Erro no logout:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  }

  // Obter dados do usuário autenticado
  static async me(req: Request, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Usuário não autenticado'
        });
        return;
      }

      const user = await prisma.user.findUnique({
        where: { id: req.user.id },
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
          active: true,
          createdAt: true,
          updatedAt: true
        }
      });

      if (!user) {
        res.status(404).json({
          success: false,
          message: 'Usuário não encontrado'
        });
        return;
      }

      res.status(200).json({
        success: true,
        data: { user }
      });
    } catch (error) {
      console.error('Erro ao buscar dados do usuário:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  }

  // Alterar senha
  static async changePassword(req: Request, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Usuário não autenticado'
        });
        return;
      }

      const validatedData = changePasswordSchema.parse(req.body);
      const { currentPassword, newPassword } = validatedData;

      // Buscar usuário atual
      const user = await prisma.user.findUnique({
        where: { id: req.user.id },
        select: { id: true, password: true }
      });

      if (!user) {
        res.status(404).json({
          success: false,
          message: 'Usuário não encontrado'
        });
        return;
      }

      // Verificar senha atual
      const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
      if (!isCurrentPasswordValid) {
        res.status(400).json({
          success: false,
          message: 'Senha atual incorreta'
        });
        return;
      }

      // Hash da nova senha
      const saltRounds = 12;
      const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

      // Atualizar senha
      await prisma.user.update({
        where: { id: user.id },
        data: { 
          password: hashedNewPassword,
          updatedAt: new Date()
        }
      });

      res.status(200).json({
        success: true,
        message: 'Senha alterada com sucesso'
      });
    } catch (error) {
      console.error('Erro ao alterar senha:', error);
      
      if (error instanceof z.ZodError) {
        res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: error.errors.map(err => ({
            field: err.path.join('.'),
            message: err.message
          }))
        });
        return;
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  }

  // Refresh token
  static async refreshToken(req: Request, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Usuário não autenticado'
        });
        return;
      }

      const jwtSecret = process.env.JWT_SECRET;
      if (!jwtSecret) {
        res.status(500).json({
          success: false,
          message: 'Erro de configuração do servidor'
        });
        return;
      }

      // Gerar novo token
      const newToken = jwt.sign(
        {
          userId: req.user.id,
          email: req.user.email,
          role: req.user.role
        },
        jwtSecret,
        { expiresIn: '24h' }
      );

      res.status(200).json({
        success: true,
        message: 'Token renovado com sucesso',
        data: {
          access_token: newToken,
          token_type: 'Bearer',
          expires_in: 86400
        }
      });
    } catch (error) {
      console.error('Erro ao renovar token:', error);
      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor'
      });
    }
  }
}
EOF

# 4. Criar rotas de autenticação
echo "🛤️ Criando rotas de autenticação..."
mkdir -p src/routes
cat > src/routes/auth.ts << 'EOF'
import { Router } from 'express';
import { AuthController } from '../controllers/AuthController';
import { authenticate, optionalAuth } from '../middleware/auth';

const router = Router();

// Rotas públicas
router.post('/login', AuthController.login);
router.post('/register', AuthController.register);

// Rotas protegidas
router.post('/logout', authenticate, AuthController.logout);
router.get('/me', authenticate, AuthController.me);
router.post('/change-password', authenticate, AuthController.changePassword);
router.post('/refresh-token', authenticate, AuthController.refreshToken);

// Health check para autenticação
router.get('/health', optionalAuth, (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Auth service is running',
    authenticated: !!req.user,
    timestamp: new Date().toISOString()
  });
});

export default router;
EOF

# 5. Atualizar arquivo principal de rotas
echo "🔄 Atualizando arquivo principal de rotas..."
cat > src/routes/index.ts << 'EOF'
import { Router } from 'express';
import authRoutes from './auth';

const router = Router();

// Registrar rotas de autenticação
router.use('/auth', authRoutes);

// Health check geral
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Sistema Erlene Advogados API - Node.js',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    services: {
      auth: 'active',
      database: 'connected'
    }
  });
});

// Rota de teste
router.get('/test', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API funcionando corretamente!',
    migration_status: 'Laravel → Node.js em progresso'
  });
});

export default router;
EOF

# 6. Atualizar variáveis de ambiente
echo "🔧 Atualizando variáveis de ambiente..."
if [ ! -f ".env" ]; then
    cp .env.example .env 2>/dev/null || touch .env
fi

# Adicionar JWT_SECRET se não existir
if ! grep -q "JWT_SECRET" .env; then
    echo "" >> .env
    echo "# JWT Authentication" >> .env
    echo "JWT_SECRET=erlene_advogados_jwt_secret_$(openssl rand -base64 32 | tr -d "=+/")" >> .env
fi

# 7. Criar utilitário para hash de senhas
echo "🔧 Criando utilitários de autenticação..."
cat > src/utils/password.ts << 'EOF'
import bcrypt from 'bcryptjs';

export class PasswordUtils {
  private static readonly SALT_ROUNDS = 12;

  /**
   * Gera hash da senha
   */
  static async hash(password: string): Promise<string> {
    return bcrypt.hash(password, this.SALT_ROUNDS);
  }

  /**
   * Compara senha com hash
   */
  static async compare(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  /**
   * Valida força da senha
   */
  static validateStrength(password: string): {
    isValid: boolean;
    errors: string[];
  } {
    const errors: string[] = [];

    if (password.length < 6) {
      errors.push('Senha deve ter pelo menos 6 caracteres');
    }

    if (password.length > 100) {
      errors.push('Senha muito longa (máximo 100 caracteres)');
    }

    if (!/[a-z]/.test(password)) {
      errors.push('Senha deve conter pelo menos uma letra minúscula');
    }

    if (!/[A-Z]/.test(password)) {
      errors.push('Senha deve conter pelo menos uma letra maiúscula');
    }

    if (!/\d/.test(password)) {
      errors.push('Senha deve conter pelo menos um número');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  /**
   * Gera senha aleatória
   */
  static generateRandom(length: number = 12): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%&*';
    let result = '';
    
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    
    return result;
  }
}
EOF

# 8. Criar tipos TypeScript para autenticação
echo "📝 Criando tipos TypeScript..."
cat > src/types/auth.ts << 'EOF'
export interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'lawyer' | 'client';
  active: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  success: boolean;
  message: string;
  data?: {
    access_token: string;
    token_type: string;
    expires_in: number;
    user: {
      id: string;
      name: string;
      email: string;
      role: string;
      created_at: Date;
    };
  };
}

export interface RegisterRequest {
  name: string;
  email: string;
  password: string;
  role?: 'admin' | 'lawyer' | 'client';
}

export interface ChangePasswordRequest {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

export interface JWTPayload {
  userId: string;
  email: string;
  role: string;
  iat?: number;
  exp?: number;
}

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
    name: string;
  };
}
EOF

# 9. Verificar se todas as dependências foram instaladas
echo "📦 Verificando dependências instaladas..."
npm list jsonwebtoken bcryptjs || {
    echo "⚠️ Reinstalando dependências..."
    npm install jsonwebtoken bcryptjs @types/jsonwebtoken @types/bcryptjs
}

echo "✅ Sistema de autenticação JWT criado com sucesso!"
echo ""
echo "📋 Arquivos criados:"
echo "   - src/middleware/auth.ts (middleware de autenticação)"
echo "   - src/controllers/AuthController.ts (controller de autenticação)"
echo "   - src/routes/auth.ts (rotas de autenticação)"
echo "   - src/routes/index.ts (rotas principais)"
echo "   - src/utils/password.ts (utilitários de senha)"
echo "   - src/types/auth.ts (tipos TypeScript)"
echo ""
echo "🔧 Variáveis de ambiente:"
echo "   - JWT_SECRET adicionado ao .env"
echo ""
echo "🎯 Rotas de autenticação disponíveis:"
echo "   POST /api/auth/login"
echo "   POST /api/auth/register"
echo "   POST /api/auth/logout"
echo "   GET  /api/auth/me"
echo "   POST /api/auth/change-password"
echo "   POST /api/auth/refresh-token"
echo "   GET  /api/auth/health"
echo ""
echo "📋 Próximo script: 205-nodejs-controllers-base.sh"
echo ""
echo "⚠️ IMPORTANTE: Testifique as rotas de autenticação antes de continuar!"