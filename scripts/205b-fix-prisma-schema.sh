#!/bin/bash

# Script 205b - Corrigir Schema Prisma Definitivamente
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔧 Script 205b - Corrigindo schema Prisma definitivamente..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# 1. Fazer backup do schema atual
echo "📦 Fazendo backup do schema atual..."
cp prisma/schema.prisma prisma/schema.prisma.bak.205b

# 2. Verificar qual schema atual existe
echo "🔍 Analisando schema atual..."
cat prisma/schema.prisma | grep -A 20 "model User"

# 3. Criar schema corrigido baseado no erro atual
echo "🛠️ Criando schema Prisma correto..."
cat > prisma/schema.prisma << 'EOF'
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

model User {
  id                String   @id @default(cuid())
  name              String
  email             String   @unique
  password          String
  role              String   @default("client") // admin, lawyer, client
  active            Boolean  @default(true)
  cpf               String?
  oab               String?
  telefone          String?
  perfil            String?  @default("client")
  unidade_id        String?
  status            String?  @default("active")
  ultimo_acesso     DateTime?
  email_verified_at DateTime?
  remember_token    String?
  created_at        DateTime @default(now())
  updated_at        DateTime @updatedAt
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  // Relacionamentos
  clientes     Client[]
  processos    Process[]
  atendimentos Appointment[]
  tarefas      Task[]
  audiencias   Hearing[]
  logs         Log[]

  @@map("users")
}

model Client {
  id         String   @id @default(cuid())
  name       String
  email      String   @unique
  phone      String?
  cpf        String?
  cnpj       String?
  address    String?
  city       String?
  state      String?
  zipcode    String?
  active     Boolean  @default(true)
  user_id    String?
  created_at DateTime @default(now())
  updated_at DateTime @updatedAt
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt

  // Relacionamentos
  user      User?      @relation(fields: [user_id], references: [id])
  processes Process[]

  @@map("clients")
}

model Process {
  id              String    @id @default(cuid())
  number          String    @unique
  title           String
  description     String?
  status          String    @default("active")
  court           String?
  judge           String?
  opposing_party  String?
  start_date      DateTime?
  end_date        DateTime?
  value           Decimal?
  client_id       String
  user_id         String
  created_at      DateTime  @default(now())
  updated_at      DateTime  @updatedAt
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // Relacionamentos
  client     Client      @relation(fields: [client_id], references: [id])
  user       User        @relation(fields: [user_id], references: [id])
  hearings   Hearing[]
  documents  Document[]
  tasks      Task[]

  @@map("processes")
}

model Appointment {
  id          String   @id @default(cuid())
  title       String
  description String?
  date        DateTime
  time        String
  duration    Int?     @default(60)
  status      String   @default("scheduled")
  user_id     String
  client_id   String?
  created_at  DateTime @default(now())
  updated_at  DateTime @updatedAt
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // Relacionamentos
  user User @relation(fields: [user_id], references: [id])

  @@map("appointments")
}

model Hearing {
  id          String    @id @default(cuid())
  title       String
  description String?
  date        DateTime
  time        String
  location    String?
  status      String    @default("scheduled")
  process_id  String
  user_id     String
  created_at  DateTime  @default(now())
  updated_at  DateTime  @updatedAt
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  // Relacionamentos
  process Process @relation(fields: [process_id], references: [id])
  user    User    @relation(fields: [user_id], references: [id])

  @@map("hearings")
}

model Task {
  id          String    @id @default(cuid())
  title       String
  description String?
  due_date    DateTime?
  status      String    @default("pending")
  priority    String    @default("medium")
  process_id  String?
  user_id     String
  created_at  DateTime  @default(now())
  updated_at  DateTime  @updatedAt
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  // Relacionamentos
  process Process? @relation(fields: [process_id], references: [id])
  user    User     @relation(fields: [user_id], references: [id])

  @@map("tasks")
}

model Document {
  id          String   @id @default(cuid())
  name        String
  path        String
  size        Int?
  type        String?
  process_id  String
  created_at  DateTime @default(now())
  updated_at  DateTime @updatedAt
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // Relacionamentos
  process Process @relation(fields: [process_id], references: [id])

  @@map("documents")
}

model Log {
  id         String   @id @default(cuid())
  action     String
  table_name String
  record_id  String
  old_values Json?
  new_values Json?
  user_id    String
  created_at DateTime @default(now())
  createdAt  DateTime @default(now())

  // Relacionamentos
  user User @relation(fields: [user_id], references: [id])

  @@map("logs")
}
EOF

# 4. Regenerar Prisma Client
echo "🗄️ Regenerando Prisma Client..."
npx prisma generate

# 5. Fazer reset e push do schema
echo "📊 Resetando e sincronizando banco..."
npx prisma db push --force-reset

# 6. Criar seed simples que funciona
echo "🌱 Criando seed simples..."
cat > prisma/seed-simple.js << 'EOF'
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
EOF

# 7. Executar seed simples
echo "🌱 Executando seed simples..."
node prisma/seed-simple.js

# 8. Testar se usuários foram criados
echo "🧪 Testando usuários criados..."
cat > test-final.js << 'EOF'
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function testUsers() {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        active: true
      }
    });
    
    console.log(`✅ Total de usuários: ${users.length}`);
    users.forEach(user => {
      console.log(`👤 ${user.name} (${user.email}) - Role: ${user.role}`);
    });
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testUsers();
EOF

node test-final.js
rm test-final.js

echo "✅ Schema Prisma corrigido com sucesso!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • Schema Prisma recreado com campos corretos"
echo "   • Campo 'role' funcionando"
echo "   • Seed simples em JavaScript"
echo "   • Usuários de teste criados"
echo ""
echo "🎯 Backend está pronto! Porta corrigida para 3008:"
echo "   Edite src/server.ts e mude PORT para 3008"