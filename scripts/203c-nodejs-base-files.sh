#!/bin/bash

# Script 203c - Criação de Arquivos Base Node.js
# Sistema Erlene Advogados - Migração Laravel → Node.js Express
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend-nodejs/

echo "📄 Script 203c - Criação de Arquivos Base Node.js"
echo "================================================"
echo "🛠️ Criando arquivos fundamentais da aplicação"
echo "🕒 Iniciado em: $(date '+%Y-%m-%d %H:%M:%S')"

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ] || [ ! -d "src" ]; then
    echo "❌ ERRO: Execute este script dentro da pasta backend-nodejs/"
    echo "Comando correto:"
    echo "   cd backend-nodejs"
    echo "   chmod +x 203c-nodejs-base-files.sh && ./203c-nodejs-base-files.sh"
    exit 1
fi

echo "✅ Diretório backend-nodejs/ confirmado"

echo ""
echo "🌐 1. CRIANDO SERVIDOR PRINCIPAL (src/server.ts)"
echo "==============================================="

cat > src/server.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';

// Carregar variáveis de ambiente
dotenv.config();

// Inicializar Prisma
export const prisma = new PrismaClient();

// Criar aplicação Express
const app = express();

// Configurar rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutos
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // máximo 100 requests por IP
  message: {
    error: 'Muitas requisições feitas. Tente novamente em 15 minutos.',
  },
});

// Middleware de segurança
app.use(helmet());
app.use(compression());
app.use(limiter);

// CORS configurado para o frontend React
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Middleware de parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined'));
}

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'API Erlene Advogados funcionando',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    version: '1.0.0',
  });
});

// Rota de teste da conexão com banco
app.get('/api/test', async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    
    const userCount = await prisma.user.count();
    const clienteCount = await prisma.cliente.count();
    
    res.json({
      success: true,
      message: 'Conexão com banco funcionando',
      data: {
        users: userCount,
        clientes: clienteCount,
        database: 'MySQL conectado',
      },
    });
  } catch (error) {
    console.error('Erro ao testar banco:', error);
    res.status(500).json({
      success: false,
      message: 'Erro na conexão com banco',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Erro interno',
    });
  }
});

// Importar rotas (serão criadas nos próximos scripts)
// app.use('/api/auth', authRoutes);
// app.use('/api/admin', adminRoutes);
// app.use('/api/portal', portalRoutes);

// Rota não encontrada
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Rota não encontrada',
    path: req.originalUrl,
  });
});

// Middleware de tratamento de erros
app.use((error: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Erro na aplicação:', error);
  
  res.status(error.status || 500).json({
    success: false,
    message: error.message || 'Erro interno do servidor',
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack }),
  });
});

// Porta e inicialização
const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`🌐 Health check: http://localhost:${PORT}/health`);
  console.log(`🔧 Test endpoint: http://localhost:${PORT}/api/test`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('🛑 Recebido SIGTERM, encerrando servidor...');
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 Recebido SIGINT, encerrando servidor...');
  await prisma.$disconnect();
  process.exit(0);
});

export default app;
EOF

echo "✅ Servidor principal criado (src/server.ts)"

echo ""
echo "🔧 2. CRIANDO CONFIGURAÇÕES (src/config/)"
echo "========================================"

# Configuração do banco
cat > src/config/database.ts << 'EOF'
import { PrismaClient } from '@prisma/client';

// Configuração do Prisma Client
const prismaConfig = {
  log: process.env.NODE_ENV === 'development' 
    ? ['query', 'info', 'warn', 'error'] as const
    : ['error'] as const,
  
  errorFormat: 'pretty' as const,
};

// Singleton do Prisma Client
let prisma: PrismaClient;

declare global {
  var __prisma: PrismaClient | undefined;
}

if (process.env.NODE_ENV === 'production') {
  prisma = new PrismaClient(prismaConfig);
} else {
  if (!global.__prisma) {
    global.__prisma = new PrismaClient(prismaConfig);
  }
  prisma = global.__prisma;
}

export { prisma };

// Função para testar conexão
export async function testConnection() {
  try {
    await prisma.$queryRaw`SELECT 1`;
    console.log('✅ Conexão com MySQL estabelecida');
    return true;
  } catch (error) {
    console.error('❌ Erro na conexão com MySQL:', error);
    return false;
  }
}

// Função para desconectar
export async function disconnect() {
  await prisma.$disconnect();
}
EOF

# Configuração JWT
cat > src/config/jwt.ts << 'EOF'
export const jwtConfig = {
  secret: process.env.JWT_SECRET || 'erlene_jwt_secret_default',
  expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  issuer: 'erlene-advogados-api',
  audience: 'erlene-advogados-frontend',
};

// Validar configuração JWT
if (!process.env.JWT_SECRET && process.env.NODE_ENV === 'production') {
  throw new Error('JWT_SECRET deve ser definido em produção');
}
EOF

# Configuração CORS
cat > src/config/cors.ts << 'EOF'
import { CorsOptions } from 'cors';

const allowedOrigins = (process.env.ALLOWED_ORIGINS || 'http://localhost:3000').split(',');

export const corsConfig: CorsOptions = {
  origin: (origin, callback) => {
    // Permitir requests sem origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Não permitido pelo CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization',
  ],
  exposedHeaders: ['Authorization'],
  maxAge: 86400, // 24 horas
};
EOF

echo "✅ Configurações criadas (database.ts, jwt.ts, cors.ts)"

echo ""
echo "📁 3. CRIANDO UTILITÁRIOS (src/utils/)"
echo "====================================="

# Logger
cat > src/utils/logger.ts << 'EOF'
import winston from 'winston';

// Configuração do logger
const loggerConfig = {
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'erlene-advogados-api' },
  transports: [
    // Console sempre
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      ),
    }),
  ],
};

// Adicionar arquivo de log em produção
if (process.env.NODE_ENV === 'production') {
  loggerConfig.transports.push(
    new winston.transports.File({
      filename: process.env.LOG_FILE || './logs/error.log',
      level: 'error',
    }),
    new winston.transports.File({
      filename: process.env.LOG_FILE || './logs/combined.log',
    })
  );
}

export const logger = winston.createLogger(loggerConfig);

// Função helper para logs estruturados
export const logError = (message: string, error: any, context?: any) => {
  logger.error(message, {
    error: error.message,
    stack: error.stack,
    context,
  });
};

export const logInfo = (message: string, data?: any) => {
  logger.info(message, data);
};

export const logWarn = (message: string, data?: any) => {
  logger.warn(message, data);
};
EOF

# Validadores
cat > src/utils/validators.ts << 'EOF'
import Joi from 'joi';

// Validação de CPF/CNPJ
export const cpfCnpjSchema = Joi.string()
  .pattern(/^(\d{11}|\d{14})$/)
  .messages({
    'string.pattern.base': 'CPF deve ter 11 dígitos ou CNPJ deve ter 14 dígitos',
  });

// Validação de email
export const emailSchema = Joi.string()
  .email()
  .required()
  .messages({
    'string.email': 'Email deve ter formato válido',
    'any.required': 'Email é obrigatório',
  });

// Validação de senha
export const passwordSchema = Joi.string()
  .min(6)
  .required()
  .messages({
    'string.min': 'Senha deve ter pelo menos 6 caracteres',
    'any.required': 'Senha é obrigatória',
  });

// Validação de data
export const dateSchema = Joi.date()
  .iso()
  .messages({
    'date.format': 'Data deve estar no formato ISO (YYYY-MM-DD)',
  });

// Validação de ID
export const idSchema = Joi.number()
  .integer()
  .positive()
  .required()
  .messages({
    'number.base': 'ID deve ser um número',
    'number.integer': 'ID deve ser um número inteiro',
    'number.positive': 'ID deve ser positivo',
    'any.required': 'ID é obrigatório',
  });

// Função helper para validar esquemas
export const validate = (schema: Joi.Schema, data: any) => {
  const { error, value } = schema.validate(data, {
    abortEarly: false,
    stripUnknown: true,
  });
  
  if (error) {
    const details = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message,
    }));
    
    throw {
      status: 400,
      message: 'Dados inválidos',
      details,
    };
  }
  
  return value;
};
EOF

# Helpers gerais
cat > src/utils/helpers.ts << 'EOF'
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { jwtConfig } from '../config/jwt';

// Hash de senha
export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, 12);
};

// Verificar senha
export const verifyPassword = async (password: string, hashedPassword: string): Promise<boolean> => {
  return bcrypt.compare(password, hashedPassword);
};

// Gerar JWT token
export const generateToken = (payload: any): string => {
  return jwt.sign(payload, jwtConfig.secret, {
    expiresIn: jwtConfig.expiresIn,
    issuer: jwtConfig.issuer,
    audience: jwtConfig.audience,
  });
};

// Verificar JWT token
export const verifyToken = (token: string): any => {
  return jwt.verify(token, jwtConfig.secret, {
    issuer: jwtConfig.issuer,
    audience: jwtConfig.audience,
  });
};

// Formatar CPF/CNPJ
export const formatCpfCnpj = (cpfCnpj: string): string => {
  const cleaned = cpfCnpj.replace(/\D/g, '');
  
  if (cleaned.length === 11) {
    // CPF
    return cleaned.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
  } else if (cleaned.length === 14) {
    // CNPJ
    return cleaned.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
  }
  
  return cpfCnpj;
};

// Limpar CPF/CNPJ
export const cleanCpfCnpj = (cpfCnpj: string): string => {
  return cpfCnpj.replace(/\D/g, '');
};

// Formatar telefone
export const formatPhone = (phone: string): string => {
  const cleaned = phone.replace(/\D/g, '');
  
  if (cleaned.length === 10) {
    return cleaned.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
  } else if (cleaned.length === 11) {
    return cleaned.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
  }
  
  return phone;
};

// Gerar slug
export const generateSlug = (text: string): string => {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9 -]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
};

// Paginação helper
export const paginate = (page: number = 1, limit: number = 10) => {
  const skip = (page - 1) * limit;
  return { skip, take: limit };
};

// Response helper
export const successResponse = (data: any, message: string = 'Sucesso') => {
  return {
    success: true,
    message,
    data,
  };
};

export const errorResponse = (message: string, details?: any) => {
  return {
    success: false,
    message,
    ...(details && { details }),
  };
};
EOF

echo "✅ Utilitários criados (logger.ts, validators.ts, helpers.ts)"

echo ""
echo "📋 4. CRIANDO TYPES (src/types/)"
echo "==============================="

# Types de API
cat > src/types/api.ts << 'EOF'
// Tipos para respostas da API
export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  details?: any;
}

export interface PaginationResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

// Tipos para request
export interface AuthRequest {
  email: string;
  password: string;
}

export interface ClientPortalRequest {
  cpf_cnpj: string;
  password: string;
}

// Tipos para usuário autenticado
export interface AuthUser {
  id: number;
  name: string;
  email: string;
  perfil: string;
  unidade_id?: number;
}

// Tipos para filtros
export interface BaseFilter {
  page?: number;
  limit?: number;
  search?: string;
  sort?: string;
  order?: 'asc' | 'desc';
}

export interface ClientFilter extends BaseFilter {
  unidade_id?: number;
  status?: string;
  tipo_pessoa?: string;
}

export interface ProcessFilter extends BaseFilter {
  cliente_id?: number;
  advogado_id?: number;
  unidade_id?: number;
  status?: string;
  tribunal?: string;
}
EOF

# Types de autenticação
cat > src/types/auth.ts << 'EOF'
export interface JwtPayload {
  id: number;
  email: string;
  name: string;
  perfil: string;
  unidade_id?: number;
  iat?: number;
  exp?: number;
  iss?: string;
  aud?: string;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data: {
    user: AuthUser;
    token: string;
    expires_in: string;
  };
}

export interface AuthUser {
  id: number;
  name: string;
  email: string;
  perfil: string;
  unidade_id?: number;
  status: string;
  ultimo_acesso?: Date;
}

// Tipos para middleware de autenticação
declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}
EOF

echo "✅ Types criados (api.ts, auth.ts)"

echo ""
echo "📊 5. VERIFICANDO ESTRUTURA CRIADA"
echo "================================="

echo "📁 Verificando arquivos criados..."

FILES_CREATED=0

if [ -f "src/server.ts" ]; then
    echo "✅ src/server.ts"
    FILES_CREATED=$((FILES_CREATED + 1))
fi

if [ -f "src/config/database.ts" ]; then
    echo "✅ src/config/database.ts"
    FILES_CREATED=$((FILES_CREATED + 1))
fi

if [ -f "src/config/jwt.ts" ]; then
    echo "✅ src/config/jwt.ts"
    FILES_CREATED=$((FILES_CREATED + 1))
fi

if [ -f "src/config/cors.ts" ]; then
    echo "✅ src/config/cors.ts"
    FILES_CREATED=$((FILES_CREATED + 1))
fi

if [ -f "src/utils/logger.ts" ]; then
    echo "✅ src/utils/logger.ts"
    FILES_CREATED=$((FILES_CREATED + 1))
fi

if [ -f "src/utils/validators.ts" ]; then
    echo "✅ src/utils/validators.ts"
    FILES_CREATED=$((FILES_CREATED + 1))
fi

if [ -f "src/utils/helpers.ts" ]; then
    echo "✅ src/utils/helpers.ts"
    FILES_CREATED=$((FILES_CREATED + 1))
fi

if [ -f "src/types/api.ts" ]; then
    echo "✅ src/types/api.ts"
    FILES_CREATED=$((FILES_CREATED + 1))
fi

if [ -f "src/types/auth.ts" ]; then
    echo "✅ src/types/auth.ts"
    FILES_CREATED=$((FILES_CREATED + 1))
fi

echo ""
echo "📊 Total de arquivos criados: $FILES_CREATED/9"

echo ""
echo "🧪 6. TESTANDO COMPILAÇÃO TYPESCRIPT"
echo "=================================="

echo "🔧 Testando compilação..."
if npx tsc --noEmit; then
    echo "✅ Código TypeScript válido"
else
    echo "❌ Erro de compilação TypeScript"
fi

echo ""
echo "✅ ARQUIVOS BASE CRIADOS COM SUCESSO!"
echo "===================================="
echo "🌐 Servidor principal: src/server.ts"
echo "🔧 Configurações: src/config/ (3 arquivos)"
echo "🛠️ Utilitários: src/utils/ (3 arquivos)"
echo "📋 Types: src/types/ (2 arquivos)"
echo "✅ Total: $FILES_CREATED arquivos base"
echo ""
echo "📋 Próximo script: 204-nodejs-auth-system.sh"
echo "💡 Para continuar, digite: 'continuar'"