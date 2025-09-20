#!/bin/bash

# Script 205a - Corrigir Erros Backend Node.js
# Sistema Erlene Advogados - Migração Laravel → Node.js
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend/

echo "🔧 Script 205a - Corrigindo erros do backend..."

# Verificar diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta backend/"
    exit 1
fi

echo "✅ Verificação de diretório OK"

# 1. Instalar dependência zod que está faltando
echo "📦 Instalando dependência zod..."
npm install zod

# 2. Verificar se o schema Prisma tem o campo role
echo "🔍 Verificando schema Prisma..."
if ! grep -q "role.*String" prisma/schema.prisma; then
    echo "⚠️ Campo 'role' não encontrado no User model. Adicionando..."
    
    # Fazer backup do schema
    cp prisma/schema.prisma prisma/schema.prisma.bak.205a
    
    # Adicionar campo role ao User model
    sed -i '/model User {/,/}/ {
        s/active.*Boolean.*/&\n  role     String  @default("client")/
    }' prisma/schema.prisma
    
    echo "✅ Campo 'role' adicionado ao User model"
else
    echo "✅ Campo 'role' já existe no User model"
fi

# 3. Corrigir seed para usar campos corretos
echo "🌱 Corrigindo seed de usuários..."
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

# 4. Regenerar Prisma Client
echo "🗄️ Regenerando Prisma Client..."
npx prisma generate

# 5. Fazer push do schema atualizado
echo "📊 Atualizando banco com novo schema..."
npx prisma db push

# 6. Executar seed novamente
echo "🌱 Executando seed com correções..."
npm run seed

# 7. Testar se tudo está funcionando
echo "🧪 Testando conexão e usuários..."
cat > test-users.js << 'EOF'
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
    
    console.log('✅ Usuários no banco:', users.length);
    users.forEach(user => {
      console.log(`👤 ${user.name} (${user.email}) - Role: ${user.role}`);
    });
    
    if (users.length === 0) {
      console.log('⚠️ Nenhum usuário encontrado. Execute o seed novamente.');
    }
  } catch (error) {
    console.error('❌ Erro ao buscar usuários:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testUsers();
EOF

node test-users.js
rm test-users.js

# 8. Testar se servidor inicia sem erros
echo "🚀 Testando inicialização do servidor..."
timeout 10s npm run dev > server-test.log 2>&1 &
SERVER_PID=$!

sleep 5

# Verificar se processo ainda está rodando
if kill -0 $SERVER_PID 2>/dev/null; then
    echo "✅ Servidor iniciou com sucesso!"
    kill $SERVER_PID
else
    echo "❌ Servidor não iniciou. Verificando logs..."
    cat server-test.log
fi

rm -f server-test.log

echo "✅ Correções do backend aplicadas!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • Dependência zod instalada"
echo "   • Campo 'role' adicionado ao User model"
echo "   • Seed corrigido para usar campos corretos"
echo "   • Prisma Client regenerado"
echo "   • Schema sincronizado com banco"
echo ""
echo "🎯 Para iniciar o servidor:"
echo "   npm run dev"
echo ""
echo "📋 Próximo script: 206a-fix-frontend-services.sh"