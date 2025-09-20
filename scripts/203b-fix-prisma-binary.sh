#!/bin/bash

# Script 203b-fix - Correção Prisma Binary Target
# Sistema Erlene Advogados - Fix do erro binary target
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend-nodejs/

echo "🔧 Script 203b-fix - Correção Prisma Binary Target"
echo "================================================"
echo "🛠️ Corrigindo erro do binary target do Prisma"
echo "🕒 Iniciado em: $(date '+%Y-%m-%d %H:%M:%S')"

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ] || [ ! -f "prisma/schema.prisma" ]; then
    echo "❌ ERRO: Execute este script dentro da pasta backend-nodejs/"
    echo "Comando correto:"
    echo "   cd backend-nodejs"
    echo "   chmod +x 203b-fix-prisma-binary.sh && ./203b-fix-prisma-binary.sh"
    exit 1
fi

echo "✅ Diretório backend-nodejs/ confirmado"

echo ""
echo "🔍 1. DETECTANDO SISTEMA OPERACIONAL"
echo "=================================="

# Detectar OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Sistema: Linux detectado"
    
    # Verificar distribuição
    if [ -f /etc/debian_version ]; then
        echo "📦 Distribuição: Debian/Ubuntu"
        BINARY_TARGET="debian-openssl-1.1.x"
    elif [ -f /etc/redhat-release ]; then
        echo "📦 Distribuição: RHEL/CentOS"
        BINARY_TARGET="rhel-openssl-1.1.x"
    else
        echo "📦 Distribuição: Linux genérico"
        BINARY_TARGET="debian-openssl-1.1.x"
    fi
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Sistema: macOS detectado"
    
    # Verificar arquitetura
    if [[ $(uname -m) == "arm64" ]]; then
        BINARY_TARGET="darwin-arm64"
    else
        BINARY_TARGET="darwin"
    fi
    
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "🪟 Sistema: Windows detectado"
    BINARY_TARGET="windows"
    
else
    echo "❓ Sistema desconhecido, usando native"
    BINARY_TARGET="native"
fi

echo "✅ Binary target selecionado: $BINARY_TARGET"

echo ""
echo "📝 2. CORRIGINDO SCHEMA PRISMA"
echo "============================"

echo "🔄 Fazendo backup do schema atual..."
cp "prisma/schema.prisma" "prisma/schema.prisma.error.backup"

echo "🛠️ Corrigindo binary targets no schema..."

# Substituir a linha problemática
sed -i.bak 's/binaryTargets = \["native", "linux-openssl-1.1.x"\]/binaryTargets = ["native", "'$BINARY_TARGET'"]/g' prisma/schema.prisma

# Verificar se a correção foi aplicada
if grep -q "binaryTargets.*$BINARY_TARGET" prisma/schema.prisma; then
    echo "✅ Binary target corrigido no schema"
else
    echo "⚠️ Correção automática falhou, aplicando manualmente..."
    
    # Criar novo schema com correção manual
    cat > prisma/schema.prisma << EOF
// Schema Prisma - Sistema Erlene Advogados Node.js
// Corrigido para binary target compatível

generator client {
  provider = "prisma-client-js"
  binaryTargets = ["native", "$BINARY_TARGET"]
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

// ========================================
// MODELOS PRINCIPAIS - BASEADOS NO LARAVEL
// ========================================

model User {
  id             Int       @id @default(autoincrement())
  name           String?   
  email          String    @unique
  password       String
  cpf            String?
  oab            String?
  telefone       String?
  perfil         String?   @default("advogado")
  unidade_id     Int?
  status         String?   @default("ativo")
  ultimo_acesso  DateTime?
  email_verified_at DateTime?
  remember_token String?
  created_at     DateTime  @default(now())
  updated_at     DateTime  @updatedAt
  
  // Relacionamentos
  unidade       Unidade?     @relation(fields: [unidade_id], references: [id])
  clientes      Cliente[]    @relation("ResponsavelCliente")
  processos     Processo[]   @relation("AdvogadoProcesso")
  atendimentos  Atendimento[] @relation("AdvogadoAtendimento")
  tarefas       Tarefa[]     @relation("ResponsavelTarefa")
  audiencias    Audiencia[]  @relation("AdvogadoAudiencia")
  
  @@map("users")
}

model Unidade {
  id         Int      @id @default(autoincrement())
  nome       String
  codigo     String?
  endereco   String?
  cidade     String?
  estado     String?
  cep        String?
  telefone   String?
  email      String?
  cnpj       String?
  status     String?  @default("ativo")
  created_at DateTime @default(now())
  updated_at DateTime @updatedAt
  
  // Relacionamentos
  users        User[]
  clientes     Cliente[]
  processos    Processo[]
  atendimentos Atendimento[]
  audiencias   Audiencia[]
  
  @@map("unidades")
}

model Cliente {
  id                  Int       @id @default(autoincrement())
  nome                String
  cpf_cnpj            String    @unique
  tipo_pessoa         String?   @default("PF")
  email               String
  telefone            String
  endereco            String    @db.Text
  cep                 String
  cidade              String
  estado              String
  observacoes         String?   @db.Text
  acesso_portal       Boolean   @default(false)
  senha_portal        String?
  tipo_armazenamento  String?   @default("local")
  google_drive_config Json?
  onedrive_config     Json?
  pasta_local         String?
  unidade_id          Int
  responsavel_id      Int
  status              String?   @default("ativo")
  created_at          DateTime  @default(now())
  updated_at          DateTime  @updatedAt
  deleted_at          DateTime?
  
  // Relacionamentos
  unidade       Unidade        @relation(fields: [unidade_id], references: [id])
  responsavel   User           @relation("ResponsavelCliente", fields: [responsavel_id], references: [id])
  processos     Processo[]
  atendimentos  Atendimento[]
  documentos    DocumentoGed[]
  financeiro    Financeiro[]
  audiencias    Audiencia[]
  mensagens     Mensagem[]
  tarefas       Tarefa[]
  
  @@map("clientes")
}

model Processo {
  id                  Int       @id @default(autoincrement())
  numero              String    @unique
  tribunal            String?
  vara                String?
  cliente_id          Int
  tipo_acao           String?
  status              String?   @default("ativo")
  valor_causa         Decimal?  @db.Decimal(15,2)
  data_distribuicao   DateTime?
  advogado_id         Int?
  unidade_id          Int?
  proximo_prazo       DateTime?
  observacoes         String?   @db.Text
  prioridade          String?   @default("media")
  kanban_posicao      Int?      @default(0)
  kanban_coluna_id    Int?
  metadata_cnj        Json?
  ultima_consulta_cnj DateTime?
  sincronizado_cnj    Boolean   @default(false)
  created_at          DateTime  @default(now())
  updated_at          DateTime  @updatedAt
  deleted_at          DateTime?
  
  // Relacionamentos
  cliente       Cliente        @relation(fields: [cliente_id], references: [id])
  advogado      User?          @relation("AdvogadoProcesso", fields: [advogado_id], references: [id])
  unidade       Unidade?       @relation(fields: [unidade_id], references: [id])
  movimentacoes Movimentacao[]
  audiencias    Audiencia[]
  tarefas       Tarefa[]
  mensagens     Mensagem[]
  financeiro    Financeiro[]
  
  // Many-to-many com Atendimento
  atendimentos  AtendimentoProcesso[]
  
  @@map("processos")
}

model Atendimento {
  id              Int       @id @default(autoincrement())
  cliente_id      Int
  advogado_id     Int
  data_hora       DateTime
  tipo            String?   @default("presencial")
  assunto         String
  descricao       String    @db.Text
  status          String?   @default("agendado")
  duracao         Int?
  valor           Decimal?  @db.Decimal(10,2)
  proximos_passos String?   @db.Text
  anexos          Json?
  unidade_id      Int
  created_at      DateTime  @default(now())
  updated_at      DateTime  @updatedAt
  
  // Relacionamentos
  cliente     Cliente @relation(fields: [cliente_id], references: [id])
  advogado    User    @relation("AdvogadoAtendimento", fields: [advogado_id], references: [id])
  unidade     Unidade @relation(fields: [unidade_id], references: [id])
  financeiro  Financeiro[]
  
  // Many-to-many com Processo
  processos   AtendimentoProcesso[]
  
  @@map("atendimentos")
}

// Tabela pivot para Many-to-Many
model AtendimentoProcesso {
  id             Int      @id @default(autoincrement())
  atendimento_id Int
  processo_id    Int
  observacoes    String?  @db.Text
  created_at     DateTime @default(now())
  updated_at     DateTime @updatedAt
  
  atendimento Atendimento @relation(fields: [atendimento_id], references: [id])
  processo    Processo    @relation(fields: [processo_id], references: [id])
  
  @@unique([atendimento_id, processo_id])
  @@map("atendimento_processos")
}

model Audiencia {
  id               Int       @id @default(autoincrement())
  processo_id      Int?
  cliente_id       Int?
  advogado_id      Int?
  unidade_id       Int?
  tipo             String
  data             DateTime
  hora             String
  local            String
  advogado         String    // Nome do advogado como string
  endereco         String?   @db.Text
  sala             String?
  juiz             String?
  observacoes      String?   @db.Text
  status           String?   @default("agendada")
  lembrete         Boolean   @default(true)
  horas_lembrete   Int       @default(2)
  created_at       DateTime  @default(now())
  updated_at       DateTime  @updatedAt
  deleted_at       DateTime?
  
  // Relacionamentos
  processo  Processo? @relation(fields: [processo_id], references: [id])
  cliente   Cliente?  @relation(fields: [cliente_id], references: [id])
  user      User?     @relation("AdvogadoAudiencia", fields: [advogado_id], references: [id])
  unidade   Unidade?  @relation(fields: [unidade_id], references: [id])
  
  @@map("audiencias")
}

// ========================================
// MODELOS AUXILIARES
// ========================================

model Movimentacao {
  id            Int       @id @default(autoincrement())
  processo_id   Int
  data          DateTime
  descricao     String    @db.Text
  tipo          String?
  documento_url String?
  metadata      Json?
  created_at    DateTime  @default(now())
  updated_at    DateTime  @updatedAt
  
  // Relacionamentos
  processo  Processo  @relation(fields: [processo_id], references: [id])
  
  @@map("movimentacoes")
}

model DocumentoGed {
  id             Int       @id @default(autoincrement())
  cliente_id     Int
  pasta          String
  nome_arquivo   String
  nome_original  String
  caminho        String
  tipo_arquivo   String
  mime_type      String
  tamanho        BigInt
  data_upload    DateTime
  usuario_id     Int
  versao         Int       @default(1)
  storage_type   String
  google_drive_id String?
  onedrive_id    String?
  tags           Json?
  descricao      String?   @db.Text
  publico        Boolean   @default(false)
  hash_arquivo   String?
  created_at     DateTime  @default(now())
  updated_at     DateTime  @updatedAt
  
  // Relacionamentos
  cliente  Cliente  @relation(fields: [cliente_id], references: [id])
  
  @@map("documentos_ged")
}

model Tarefa {
  id               Int       @id @default(autoincrement())
  titulo           String
  descricao        String?   @db.Text
  tipo             String?
  status           String?   @default("pendente")
  prazo            DateTime?
  responsavel_id   Int?
  cliente_id       Int?
  processo_id      Int?
  kanban_posicao   Int?
  created_at       DateTime  @default(now())
  updated_at       DateTime  @updatedAt
  
  // Relacionamentos
  responsavel  User?     @relation("ResponsavelTarefa", fields: [responsavel_id], references: [id])
  cliente      Cliente?  @relation(fields: [cliente_id], references: [id])
  processo     Processo? @relation(fields: [processo_id], references: [id])
  
  @@map("tarefas")
}

model Mensagem {
  id               Int       @id @default(autoincrement())
  remetente_id     Int?
  destinatario_id  Int?
  cliente_id       Int?
  processo_id      Int?
  conteudo         String    @db.Text
  tipo             String?   @default("texto")
  arquivo_url      String?
  data_envio       DateTime  @default(now())
  lida             Boolean   @default(false)
  data_leitura     DateTime?
  created_at       DateTime  @default(now())
  updated_at       DateTime  @updatedAt
  
  // Relacionamentos
  cliente  Cliente?  @relation(fields: [cliente_id], references: [id])
  processo Processo? @relation(fields: [processo_id], references: [id])
  
  @@map("mensagens")
}

// ========================================
// MODELOS FINANCEIROS
// ========================================

model Financeiro {
  id               Int       @id @default(autoincrement())
  processo_id      Int?
  atendimento_id   Int?
  cliente_id       Int
  tipo             String
  valor            Decimal   @db.Decimal(10,2)
  data_vencimento  DateTime
  data_pagamento   DateTime?
  status           String    @default("pendente")
  descricao        String?
  gateway          String?
  created_at       DateTime  @default(now())
  updated_at       DateTime  @updatedAt
  
  // Relacionamentos
  cliente         Cliente      @relation(fields: [cliente_id], references: [id])
  processo        Processo?    @relation(fields: [processo_id], references: [id])
  atendimento     Atendimento? @relation(fields: [atendimento_id], references: [id])
  
  @@map("financeiro")
}
EOF
    
    echo "✅ Schema corrigido manualmente"
fi

echo ""
echo "🔧 3. GERANDO PRISMA CLIENT CORRIGIDO"
echo "=================================="

echo "📦 Tentando gerar Prisma Client novamente..."
npx prisma generate

if [ $? -eq 0 ]; then
    echo "✅ Prisma Client gerado com sucesso!"
else
    echo "❌ Ainda há erro. Tentando com binary target 'native' apenas..."
    
    # Fallback para apenas native
    sed -i.bak2 's/binaryTargets = \["native", "[^"]*"\]/binaryTargets = ["native"]/g' prisma/schema.prisma
    
    npx prisma generate
    
    if [ $? -eq 0 ]; then
        echo "✅ Prisma Client gerado com 'native' apenas"
    else
        echo "❌ Erro persistente no Prisma"
        exit 1
    fi
fi

echo ""
echo "🔍 4. VALIDANDO SCHEMA CORRIGIDO"
echo "=============================="

echo "📋 Validando sintaxe..."
npx prisma validate

if [ $? -eq 0 ]; then
    echo "✅ Schema válido"
else
    echo "❌ Schema ainda contém erros"
    exit 1
fi

echo ""
echo "📊 5. INFORMAÇÕES DO SCHEMA CORRIGIDO"
echo "=================================="

MODELS_COUNT=$(grep -c "^model " prisma/schema.prisma)
RELATIONS_COUNT=$(grep -c "@relation" prisma/schema.prisma)
TABLES_COUNT=$(grep -c "@@map" prisma/schema.prisma)

echo "📋 Models criados: $MODELS_COUNT"
echo "🔗 Relacionamentos: $RELATIONS_COUNT"
echo "🗂️ Tabelas mapeadas: $TABLES_COUNT"
echo "🎯 Binary target: $BINARY_TARGET"

echo ""
echo "✅ PRISMA CORRIGIDO COM SUCESSO!"
echo "=============================="
echo "🛠️ Binary target corrigido para seu sistema"
echo "📦 Prisma Client gerado sem erros"
echo "✅ Schema validado e funcional"
echo ""
echo "📋 Próximo script: 203c-nodejs-base-files.sh"
echo "💡 Para continuar, digite: 'continuar'"