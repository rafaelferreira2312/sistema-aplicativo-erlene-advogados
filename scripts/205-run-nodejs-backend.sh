#!/bin/bash

# Script 205 - Executar Backend Node.js
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🚀 Script 205 - Executando Backend Node.js..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

# Verificar se sistema de auth foi criado
if [ ! -f "src/controllers/AuthController.ts" ]; then
    echo "❌ Erro: Execute o script 204 primeiro (sistema de autenticação)"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# 1. Atualizar server.ts para incluir todas as rotas
echo "🔧 Atualizando server.ts principal..."
cat > src/server.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';
import routes from './routes';

// Carregar variáveis de ambiente
dotenv.config();

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3008;

// Middlewares de segurança
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// CORS configurado para desenvolvimento
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'https://erleneadvogados.vancouvertec.com'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Middlewares de parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
}

// Testar conexão com banco
app.use(async (req, res, next) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    next();
  } catch (error) {
    console.error('Erro de conexão com banco:', error);
    if (!res.headersSent) {
      res.status(500).json({
        success: false,
        message: 'Erro de conexão com banco de dados'
      });
    }
  }
});

// Rotas principais
app.use('/api', routes);

// Rota de health check
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Sistema Erlene Advogados - Backend Node.js',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    database: 'connected'
  });
});

// Rota raiz
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API Sistema Erlene Advogados',
    docs: '/api/health',
    auth: '/api/auth/health'
  });
});

// Middleware de erro global
app.use((error: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Erro não tratado:', error);
  
  if (!res.headersSent) {
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Middleware para rotas não encontradas
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Rota não encontrada',
    path: req.originalUrl
  });
});

// Iniciar servidor
const server = app.listen(PORT, () => {
  console.log(`
🚀 Servidor Node.js rodando!
📍 URL: http://localhost:${PORT}
🔗 Health: http://localhost:${PORT}/health
🔐 Auth: http://localhost:${PORT}/api/auth/health
🌍 Environment: ${process.env.NODE_ENV || 'development'}
📅 Timestamp: ${new Date().toISOString()}
  `);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('Recebido SIGTERM, fechando servidor...');
  server.close(() => {
    console.log('Servidor fechado');
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  console.log('Recebido SIGINT, fechando servidor...');
  await prisma.$disconnect();
  server.close(() => {
    console.log('Servidor fechado');
    process.exit(0);
  });
});

export default app;
EOF

# 2. Criar script de inicialização com seed de usuário teste
echo "🌱 Criando seed de usuário para testes..."
mkdir -p prisma/seeds
cat > prisma/seeds/users.ts << 'EOF'
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

export async function seedUsers() {
  console.log('🌱 Criando usuários de teste...');

  // Hash para senha '123456'
  const passwordHash = await bcrypt.hash('123456', 12);

  // Usuário admin
  const admin = await prisma.user.upsert({
    where: { email: 'admin@erlene.com' },
    update: {},
    create: {
      name: 'Administrador',
      email: 'admin@erlene.com',
      password: passwordHash,
      role: 'admin',
      active: true
    }
  });

  // Usuário advogado
  const lawyer = await prisma.user.upsert({
    where: { email: 'advogado@erlene.com' },
    update: {},
    create: {
      name: 'Dr. João Silva',
      email: 'advogado@erlene.com',
      password: passwordHash,
      role: 'lawyer',
      active: true
    }
  });

  // Usuário cliente
  const client = await prisma.user.upsert({
    where: { email: 'cliente@teste.com' },
    update: {},
    create: {
      name: 'Maria Santos',
      email: 'cliente@teste.com',
      password: passwordHash,
      role: 'client',
      active: true
    }
  });

  console.log('✅ Usuários criados:');
  console.log(`   Admin: ${admin.email}`);
  console.log(`   Lawyer: ${lawyer.email}`);
  console.log(`   Client: ${client.email}`);
  console.log('   Senha para todos: 123456');
}
EOF

# 3. Criar script principal de seed
cat > prisma/seed.ts << 'EOF'
import { PrismaClient } from '@prisma/client';
import { seedUsers } from './seeds/users';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando seed do banco de dados...');
  
  try {
    await seedUsers();
    console.log('✅ Seed concluído com sucesso!');
  } catch (error) {
    console.error('❌ Erro no seed:', error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
EOF

# 4. Verificar e instalar dependências que faltam
echo "📦 Verificando dependências..."
npm install --save helmet morgan dotenv
npm install --save-dev ts-node-dev

# 5. Atualizar package.json com scripts
echo "🔧 Atualizando scripts do package.json..."
npm pkg set scripts.dev="ts-node-dev --respawn --transpile-only src/server.ts"
npm pkg set scripts.start="node dist/server.js"
npm pkg set scripts.build="tsc"
npm pkg set scripts.seed="ts-node prisma/seed.ts"
npm pkg set scripts.db:generate="prisma generate"
npm pkg set scripts.db:push="prisma db push"
npm pkg set scripts.db:reset="prisma migrate reset --force"

# 6. Gerar cliente Prisma
echo "🗄️ Gerando cliente Prisma..."
npx prisma generate

# 7. Fazer push do schema para o banco
echo "📊 Sincronizando schema com banco..."
npx prisma db push --force-reset

# 8. Executar seed
echo "🌱 Executando seed..."
npm run seed

# 9. Testar se tudo está funcionando
echo "🧪 Testando conexão com banco..."
cat > test-connection.js << 'EOF'
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function testConnection() {
  try {
    const users = await prisma.user.findMany();
    console.log('✅ Conexão OK! Usuários encontrados:', users.length);
    console.log('👥 Usuários:', users.map(u => `${u.name} (${u.email})`));
  } catch (error) {
    console.error('❌ Erro na conexão:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testConnection();
EOF

node test-connection.js
rm test-connection.js

echo "✅ Backend Node.js configurado com sucesso!"
echo ""
echo "🎯 Para iniciar o servidor:"
echo "   npm run dev"
echo ""
echo "🧪 Usuários de teste criados:"
echo "   Admin: admin@erlene.com / 123456"
echo "   Advogado: advogado@erlene.com / 123456"
echo "   Cliente: cliente@teste.com / 123456"
echo ""
echo "🔗 URLs disponíveis:"
echo "   http://localhost:3008/health"
echo "   http://localhost:3008/api/auth/health"
echo "   http://localhost:3008/api/auth/login"
echo ""
echo "📋 Próximo script: 206-integrate-login-frontend.sh"
echo ""
echo "⚠️ IMPORTANTE: Execute 'npm run dev' e teste as URLs antes de continuar!"