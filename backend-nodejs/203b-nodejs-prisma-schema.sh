#!/bin/bash

# Script 203b - Configuração Prisma Schema
# Sistema Erlene Advogados - Migração Laravel → Node.js Express
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: backend-nodejs/

echo "🗄️ Script 203b - Configuração Prisma Schema"
echo "==========================================="
echo "📊 Criando schema Prisma baseado na análise MySQL"
echo "🕒 Iniciado em: $(date '+%Y-%m-%d %H:%M:%S')"

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ] || [ ! -d "prisma" ]; then
    echo "❌ ERRO: Execute este script dentro da pasta backend-nodejs/"
    echo "Comando correto:"
    echo "   cd backend-nodejs"
    echo "   chmod +x 203b-nodejs-prisma-schema.sh && ./203b-nodejs-prisma-schema.sh"
    exit 1
fi

echo "✅ Diretório backend-nodejs/ confirmado"

echo ""
echo "📄 1. FAZENDO BACKUP DO SCHEMA EXISTENTE"
echo "======================================"

if [ -f "prisma/schema.prisma" ]; then
    echo "🔄 Fazendo backup do schema atual..."
    cp "prisma/schema.prisma" "prisma/schema.prisma.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✅ Backup criado"
fi

echo ""
echo "📝 2. CRIANDO SCHEMA PRISMA BASEADO NA ANÁLISE"
echo "============================================="

echo "🗃️ Gerando schema com models do Laravel..."

cat > prisma/schema.prisma << 'EOF'
// Schema Prisma - Sistema Erlene Advogados Node.js
// Baseado na análise completa do Laravel + MySQL
// Migração: Laravel → Node.js Express

generator client {
  provider = "prisma-client-js"
  binaryTargets = ["native", "linux-openssl-1.1.x"]
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
  logs          LogSistema[] @relation("UsuarioLog")
  
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
  integracoes  Integracao[]
  kanban_colunas KanbanColuna[]
  
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
  prazos        Prazo[]
  logs          LogSistema[]   @relation("ClienteLog")
  acessos_portal AcessoPortal[]
  pagamentos_stripe PagamentoStripe[]
  pagamentos_mp PagamentoMercadoPago[]
  
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
  kanban_cards  KanbanCard[]
  tarefas       Tarefa[]
  mensagens     Mensagem[]
  prazos        Prazo[]
  financeiro    Financeiro[]
  pagamentos_stripe PagamentoStripe[]
  pagamentos_mp PagamentoMercadoPago[]
  
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
  pagamentos_stripe PagamentoStripe[]
  pagamentos_mp PagamentoMercadoPago[]
  
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

model Prazo {
  id               Int       @id @default(autoincrement())
  client_id        Int
  process_id       Int
  user_id          Int
  descricao        String
  tipo_prazo       String?
  data_vencimento  DateTime
  hora_vencimento  String?
  status           String?   @default("pendente")
  prioridade       String?   @default("media")
  observacoes      String?   @db.Text
  created_at       DateTime  @default(now())
  updated_at       DateTime  @updatedAt
  
  // Relacionamentos
  cliente   Cliente  @relation(fields: [client_id], references: [id])
  processo  Processo @relation(fields: [process_id], references: [id])
  
  @@map("prazos")
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
  kanban_cards KanbanCard[]
  
  @@map("tarefas")
}

model KanbanColuna {
  id         Int          @id @default(autoincrement())
  nome       String
  ordem      Int
  cor        String?
  unidade_id Int?
  created_at DateTime     @default(now())
  updated_at DateTime     @updatedAt
  
  // Relacionamentos
  unidade Unidade?     @relation(fields: [unidade_id], references: [id])
  cards   KanbanCard[]
  
  @@map("kanban_colunas")
}

model KanbanCard {
  id             Int       @id @default(autoincrement())
  titulo         String
  descricao      String?   @db.Text
  coluna_id      Int
  processo_id    Int?
  tarefa_id      Int?
  posicao        Int?
  prioridade     String?   @default("media")
  prazo          DateTime?
  responsavel_id Int?
  created_at     DateTime  @default(now())
  updated_at     DateTime  @updatedAt
  
  // Relacionamentos
  coluna   KanbanColuna  @relation(fields: [coluna_id], references: [id])
  processo Processo?     @relation(fields: [processo_id], references: [id])
  tarefa   Tarefa?       @relation(fields: [tarefa_id], references: [id])
  
  @@map("kanban_cards")
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
  cliente           Cliente              @relation(fields: [cliente_id], references: [id])
  processo          Processo?            @relation(fields: [processo_id], references: [id])
  atendimento       Atendimento?         @relation(fields: [atendimento_id], references: [id])
  pagamentos_stripe PagamentoStripe[]
  pagamentos_mp     PagamentoMercadoPago[]
  
  @@map("financeiro")
}

model PagamentoStripe {
  id                      Int       @id @default(autoincrement())
  cliente_id              Int?
  processo_id             Int?
  atendimento_id          Int?
  financeiro_id           Int?
  valor                   Decimal   @db.Decimal(10,2)
  moeda                   String    @default("brl")
  status                  String    @default("pending")
  stripe_payment_intent_id String?
  stripe_customer_id      String?
  stripe_charge_id        String?
  created_at              DateTime  @default(now())
  updated_at              DateTime  @updatedAt
  
  // Relacionamentos
  cliente     Cliente?     @relation(fields: [cliente_id], references: [id])
  processo    Processo?    @relation(fields: [processo_id], references: [id])
  atendimento Atendimento? @relation(fields: [atendimento_id], references: [id])
  financeiro  Financeiro?  @relation(fields: [financeiro_id], references: [id])
  
  @@map("pagamentos_stripe")
}

model PagamentoMercadoPago {
  id                   Int       @id @default(autoincrement())
  cliente_id           Int?
  processo_id          Int?
  atendimento_id       Int?
  financeiro_id        Int?
  valor                Decimal   @db.Decimal(10,2)
  tipo                 String?
  status               String    @default("pending")
  mp_payment_id        String?
  mp_preference_id     String?
  mp_external_reference String?
  created_at           DateTime  @default(now())
  updated_at           DateTime  @updatedAt
  
  // Relacionamentos
  cliente     Cliente?     @relation(fields: [cliente_id], references: [id])
  processo    Processo?    @relation(fields: [processo_id], references: [id])
  atendimento Atendimento? @relation(fields: [atendimento_id], references: [id])
  financeiro  Financeiro?  @relation(fields: [financeiro_id], references: [id])
  
  @@map("pagamentos_mp")
}

// ========================================
// MODELOS DE SISTEMA
// ========================================

model Tribunal {
  id                   Int       @id @default(autoincrement())
  nome                 String
  codigo               String    @unique
  url_consulta         String?
  tipo                 String?
  estado               String?
  config_api           Json?
  ativo                Boolean   @default(true)
  limite_consultas_dia Int?      @default(100)
  created_at           DateTime  @default(now())
  updated_at           DateTime  @updatedAt
  
  @@map("tribunais")
}

model Integracao {
  id                    Int       @id @default(autoincrement())
  nome                  String
  ativo                 Boolean   @default(false)
  configuracoes         Json?
  ultima_sincronizacao  DateTime?
  status                String?   @default("inativo")
  ultimo_erro           String?
  total_requisicoes     Int       @default(0)
  requisicoes_sucesso   Int       @default(0)
  requisicoes_erro      Int       @default(0)
  unidade_id            Int?
  created_at            DateTime  @default(now())
  updated_at            DateTime  @updatedAt
  
  // Relacionamentos
  unidade Unidade? @relation(fields: [unidade_id], references: [id])
  
  @@map("integracoes")
}

model LogSistema {
  id         Int       @id @default(autoincrement())
  nivel      String    // "info", "warning", "error"
  categoria  String?
  mensagem   String    @db.Text
  contexto   Json?
  usuario_id Int?
  cliente_id Int?
  ip         String?
  user_agent String?
  request_id String?
  data_hora  DateTime  @default(now())
  created_at DateTime  @default(now())
  
  // Relacionamentos
  usuario User?    @relation("UsuarioLog", fields: [usuario_id], references: [id])
  cliente Cliente? @relation("ClienteLog", fields: [cliente_id], references: [id])
  
  @@map("logs_sistema")
}

model AcessoPortal {
  id             Int       @id @default(autoincrement())
  cliente_id     Int
  ip             String
  user_agent     String?
  data_acesso    DateTime
  acao           String
  detalhes       String?
  created_at     DateTime  @default(now())
  updated_at     DateTime  @updatedAt
  
  // Relacionamentos
  cliente Cliente @relation(fields: [cliente_id], references: [id])
  
  @@map("acessos_portal")
}
EOF

echo "✅ Schema Prisma criado com todos os models"

echo ""
echo "🔧 3. GERANDO CLIENTE PRISMA"
echo "=========================="

echo "📦 Gerando Prisma Client..."
npx prisma generate

if [ $? -eq 0 ]; then
    echo "✅ Prisma Client gerado com sucesso"
else
    echo "❌ Erro ao gerar Prisma Client"
    exit 1
fi

echo ""
echo "🔍 4. VALIDANDO SCHEMA"
echo "===================="

echo "📋 Validando sintaxe do schema..."
npx prisma validate

if [ $? -eq 0 ]; then
    echo "✅ Schema válido"
else
    echo "❌ Schema contém erros"
    exit 1
fi

echo ""
echo "📊 5. INFORMAÇÕES DO SCHEMA"
echo "========================="

echo "📋 Contando models no schema..."
MODELS_COUNT=$(grep -c "^model " prisma/schema.prisma)
echo "✅ Models criados: $MODELS_COUNT"

echo "🔗 Verificando relacionamentos..."
RELATIONS_COUNT=$(grep -c "@relation" prisma/schema.prisma)
echo "✅ Relacionamentos: $RELATIONS_COUNT"

echo "🗂️ Verificando tabelas mapeadas..."
TABLES_COUNT=$(grep -c "@@map" prisma/schema.prisma)
echo "✅ Tabelas mapeadas: $TABLES_COUNT"

echo ""
echo "✅ PRISMA SCHEMA CONFIGURADO!"
echo "============================"
echo "🗄️ Schema baseado na análise completa do Laravel"
echo "📊 $MODELS_COUNT models criados"
echo "🔗 $RELATIONS_COUNT relacionamentos definidos"
echo "✅ Prisma Client gerado e validado"
echo ""
echo "📋 Próximo script: 203c-nodejs-base-files.sh"
echo "💡 Para continuar, digite: 'continuar'"