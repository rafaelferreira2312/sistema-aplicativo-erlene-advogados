const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
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

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
