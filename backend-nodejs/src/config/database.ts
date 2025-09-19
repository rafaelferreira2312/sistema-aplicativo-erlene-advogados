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
