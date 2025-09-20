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
