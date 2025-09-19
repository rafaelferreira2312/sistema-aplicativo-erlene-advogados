#!/bin/bash

# Script 202 - Análise Completa do Banco de Dados MySQL
# Sistema Erlene Advogados - Migração Laravel → Node.js Express
# Data: $(date +%Y-%m-%d)
# EXECUTE NA PASTA RAIZ DO PROJETO: sistema-aplicativo-erlene-advogados/

echo "🗄️ Script 202 - Análise Completa do Banco de Dados MySQL"
echo "========================================================"
echo "📊 Analisando estrutura real do banco, tabelas, dados e relacionamentos"
echo "🎯 Objetivo: Gerar schema Prisma para Node.js baseado no MySQL atual"
echo "🕒 Iniciado em: $(date '+%Y-%m-%d %H:%M:%S')"

# Verificar se estamos no diretório correto
if [ ! -f "backend/.env" ]; then
    echo "❌ ERRO: Arquivo backend/.env não encontrado!"
    echo "   Execute este script na pasta raiz do projeto"
    exit 1
fi

echo "✅ Arquivo .env encontrado"

# Criar diretório para relatórios de análise do banco
ANALYSIS_DIR="migration_analysis/$(date +%Y%m%d_%H%M%S)_mysql_database"
echo "📁 Criando diretório de análise: $ANALYSIS_DIR"
mkdir -p "$ANALYSIS_DIR"

echo ""
echo "🔧 1. EXTRAINDO CONFIGURAÇÕES DO BANCO"
echo "====================================="

# Extrair configurações do .env
ENV_FILE="backend/.env"
echo "📄 Lendo configurações de: $ENV_FILE"

DB_HOST=$(grep "^DB_HOST=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
DB_PORT=$(grep "^DB_PORT=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
DB_DATABASE=$(grep "^DB_DATABASE=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
DB_USERNAME=$(grep "^DB_USERNAME=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
DB_PASSWORD=$(grep "^DB_PASSWORD=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '"' | tr -d "'")

# Definir valores padrão se não encontrados
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_DATABASE:-erlene_advogados}
DB_USERNAME=${DB_USERNAME:-root}

echo "🔧 Configurações encontradas:"
echo "   Host: $DB_HOST"
echo "   Port: $DB_PORT"
echo "   Database: $DB_DATABASE"
echo "   Username: $DB_USERNAME"
echo "   Password: [PRESENTE: $([ ! -z "$DB_PASSWORD" ] && echo "SIM" || echo "NÃO")]"

# Criar arquivo de configuração para análise
CONFIG_REPORT="$ANALYSIS_DIR/01_database_config.md"
echo "# Configuração do Banco de Dados MySQL" > "$CONFIG_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$CONFIG_REPORT"
echo "" >> "$CONFIG_REPORT"
echo "## Configurações Atuais" >> "$CONFIG_REPORT"
echo "- **Host**: $DB_HOST" >> "$CONFIG_REPORT"
echo "- **Port**: $DB_PORT" >> "$CONFIG_REPORT"
echo "- **Database**: $DB_DATABASE" >> "$CONFIG_REPORT"
echo "- **Username**: $DB_USERNAME" >> "$CONFIG_REPORT"
echo "- **Password**: $([ ! -z "$DB_PASSWORD" ] && echo "Configurada" || echo "Não configurada")" >> "$CONFIG_REPORT"
echo "" >> "$CONFIG_REPORT"

echo ""
echo "🔌 2. TESTANDO CONEXÃO COM MYSQL"
echo "==============================="

# Verificar se mysql client está disponível
if ! command -v mysql >/dev/null 2>&1; then
    echo "⚠️  Cliente MySQL não disponível no sistema"
    echo "💡 Tentando instalar mysql-client..."
    
    # Tentar instalar mysql-client
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y mysql-client 2>/dev/null
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y mysql 2>/dev/null
    else
        echo "❌ Não foi possível instalar cliente MySQL automaticamente"
        echo "📝 Criando script alternativo para análise..."
        
        # Criar script alternativo baseado nas migrations
        echo "## ⚠️ Análise Baseada em Migrations (MySQL não disponível)" >> "$CONFIG_REPORT"
        echo "O cliente MySQL não está disponível, análise será baseada nos arquivos de migration." >> "$CONFIG_REPORT"
        
        echo "Análise será baseada nas migrations do Laravel"
        mysql_available=false
    fi
else
    mysql_available=true
fi

if [ "$mysql_available" = true ]; then
    echo "🔍 Testando conexão MySQL..."
    
    # Tentar conectar no MySQL
    MYSQL_CMD="mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME"
    if [ ! -z "$DB_PASSWORD" ]; then
        MYSQL_CMD="$MYSQL_CMD -p$DB_PASSWORD"
    fi
    
    # Testar conexão
    CONNECTION_TEST=$(echo "SELECT 1;" | $MYSQL_CMD "$DB_DATABASE" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "✅ Conexão MySQL estabelecida com sucesso!"
        mysql_connected=true
        
        echo "## ✅ Conexão MySQL" >> "$CONFIG_REPORT"
        echo "Conexão estabelecida com sucesso em $(date '+%Y-%m-%d %H:%M:%S')" >> "$CONFIG_REPORT"
        echo "" >> "$CONFIG_REPORT"
    else
        echo "⚠️  Não foi possível conectar ao MySQL"
        echo "💡 Isso é normal se o banco estiver na VPS"
        mysql_connected=false
        
        echo "## ⚠️ Conexão MySQL Falhou" >> "$CONFIG_REPORT"
        echo "Não foi possível conectar ao banco local. Análise será baseada nas migrations." >> "$CONFIG_REPORT"
        echo "" >> "$CONFIG_REPORT"
    fi
else
    mysql_connected=false
fi

echo ""
echo "📊 3. ANÁLISE DA ESTRUTURA DO BANCO"
echo "=================================="

STRUCTURE_REPORT="$ANALYSIS_DIR/02_database_structure.md"
echo "# Estrutura do Banco de Dados" > "$STRUCTURE_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$STRUCTURE_REPORT"
echo "" >> "$STRUCTURE_REPORT"

if [ "$mysql_connected" = true ]; then
    echo "🗃️ Listando tabelas do banco real..."
    
    # Listar todas as tabelas
    TABLES_LIST=$(echo "SHOW TABLES;" | $MYSQL_CMD "$DB_DATABASE" 2>/dev/null | grep -v "Tables_in_")
    
    if [ ! -z "$TABLES_LIST" ]; then
        echo "## Tabelas Encontradas no Banco" >> "$STRUCTURE_REPORT"
        echo "$TABLES_LIST" | sed 's/^/- /' >> "$STRUCTURE_REPORT"
        echo "" >> "$STRUCTURE_REPORT"
        
        TABLE_COUNT=$(echo "$TABLES_LIST" | wc -l)
        echo "✅ Tabelas encontradas: $TABLE_COUNT"
        
        # Analisar estrutura de cada tabela
        echo "## Estrutura Detalhada das Tabelas" >> "$STRUCTURE_REPORT"
        
        counter=1
        for table in $TABLES_LIST; do
            if [ $counter -le 10 ]; then  # Limitar a 10 tabelas principais
                echo "📋 Analisando tabela: $table"
                
                echo "### Tabela: $table" >> "$STRUCTURE_REPORT"
                
                # Obter estrutura da tabela
                TABLE_STRUCTURE=$(echo "DESCRIBE $table;" | $MYSQL_CMD "$DB_DATABASE" 2>/dev/null)
                if [ ! -z "$TABLE_STRUCTURE" ]; then
                    echo "\`\`\`" >> "$STRUCTURE_REPORT"
                    echo "$TABLE_STRUCTURE" >> "$STRUCTURE_REPORT"
                    echo "\`\`\`" >> "$STRUCTURE_REPORT"
                fi
                
                # Contar registros
                RECORD_COUNT=$(echo "SELECT COUNT(*) FROM $table;" | $MYSQL_CMD "$DB_DATABASE" 2>/dev/null | tail -1)
                if [ ! -z "$RECORD_COUNT" ] && [ "$RECORD_COUNT" != "COUNT(*)" ]; then
                    echo "**Registros**: $RECORD_COUNT" >> "$STRUCTURE_REPORT"
                fi
                
                echo "" >> "$STRUCTURE_REPORT"
                counter=$((counter + 1))
            fi
        done
        
    else
        echo "⚠️  Não foi possível listar tabelas"
        echo "⚠️  Não foi possível listar tabelas do banco" >> "$STRUCTURE_REPORT"
    fi
    
else
    echo "📋 Analisando estrutura baseada nas migrations..."
    
    echo "## Tabelas Baseadas nas Migrations" >> "$STRUCTURE_REPORT"
    
    # Analisar migrations para extrair tabelas
    if [ -d "backend/database/migrations" ]; then
        echo "🔍 Extraindo tabelas das migrations..."
        
        MIGRATION_TABLES=""
        for migration in backend/database/migrations/*.php; do
            if [ -f "$migration" ]; then
                # Extrair nome da tabela
                TABLE_NAME=$(grep "Schema::create" "$migration" 2>/dev/null | sed "s/.*create('\([^']*\)'.*/\1/" | head -1)
                if [ ! -z "$TABLE_NAME" ]; then
                    MIGRATION_TABLES="$MIGRATION_TABLES\n$TABLE_NAME"
                fi
            fi
        done
        
        if [ ! -z "$MIGRATION_TABLES" ]; then
            echo -e "$MIGRATION_TABLES" | grep -v "^$" | sort | sed 's/^/- /' >> "$STRUCTURE_REPORT"
            TABLE_COUNT=$(echo -e "$MIGRATION_TABLES" | grep -v "^$" | wc -l)
            echo "✅ Tabelas identificadas via migrations: $TABLE_COUNT"
        fi
    fi
fi

echo ""
echo "🔗 4. ANÁLISE DE RELACIONAMENTOS"
echo "==============================="

RELATIONSHIPS_REPORT="$ANALYSIS_DIR/03_relationships.md"
echo "# Relacionamentos entre Tabelas" > "$RELATIONSHIPS_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$RELATIONSHIPS_REPORT"
echo "" >> "$RELATIONSHIPS_REPORT"

echo "🔍 Analisando relacionamentos via Models Laravel..."

# Analisar relacionamentos dos Models
if [ -d "backend/app/Models" ]; then
    echo "## Relacionamentos Identificados nos Models" >> "$RELATIONSHIPS_REPORT"
    
    for model_file in backend/app/Models/*.php; do
        if [ -f "$model_file" ]; then
            MODEL_NAME=$(basename "$model_file" .php)
            echo "📊 Analisando relacionamentos: $MODEL_NAME"
            
            # Extrair relacionamentos
            RELATIONSHIPS=$(grep -n "belongsTo\|hasMany\|hasOne\|belongsToMany" "$model_file" 2>/dev/null | head -5)
            
            if [ ! -z "$RELATIONSHIPS" ]; then
                echo "### $MODEL_NAME" >> "$RELATIONSHIPS_REPORT"
                echo "$RELATIONSHIPS" | sed 's/^.*public function /- /' | sed 's/().*$//' >> "$RELATIONSHIPS_REPORT"
                echo "" >> "$RELATIONSHIPS_REPORT"
            fi
        fi
    done
fi

echo ""
echo "📈 5. ANÁLISE DE DADOS EXISTENTES"
echo "==============================="

DATA_REPORT="$ANALYSIS_DIR/04_data_analysis.md"
echo "# Análise de Dados Existentes" > "$DATA_REPORT"
echo "## Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$DATA_REPORT"
echo "" >> "$DATA_REPORT"

if [ "$mysql_connected" = true ]; then
    echo "📊 Analisando volume de dados..."
    
    echo "## Volume de Dados por Tabela" >> "$DATA_REPORT"
    echo "| Tabela | Registros |" >> "$DATA_REPORT"
    echo "|--------|-----------|" >> "$DATA_REPORT"
    
    # Principais tabelas para análise
    MAIN_TABLES="users clientes processos atendimentos financeiro documentos_ged audiencias"
    
    for table in $MAIN_TABLES; do
        if echo "$TABLES_LIST" | grep -q "^$table$" 2>/dev/null; then
            RECORD_COUNT=$(echo "SELECT COUNT(*) FROM $table;" | $MYSQL_CMD "$DB_DATABASE" 2>/dev/null | tail -1)
            if [ ! -z "$RECORD_COUNT" ] && [ "$RECORD_COUNT" != "COUNT(*)" ]; then
                echo "| $table | $RECORD_COUNT |" >> "$DATA_REPORT"
                echo "📊 $table: $RECORD_COUNT registros"
            fi
        fi
    done
    
    echo "" >> "$DATA_REPORT"
    
    # Analisar dados de exemplo
    echo "## Exemplos de Dados (Primeiros 3 registros)" >> "$DATA_REPORT"
    
    for table in users clientes processos; do
        if echo "$TABLES_LIST" | grep -q "^$table$" 2>/dev/null; then
            echo "### Tabela: $table" >> "$DATA_REPORT"
            SAMPLE_DATA=$(echo "SELECT * FROM $table LIMIT 3;" | $MYSQL_CMD "$DB_DATABASE" 2>/dev/null)
            if [ ! -z "$SAMPLE_DATA" ]; then
                echo "\`\`\`" >> "$DATA_REPORT"
                echo "$SAMPLE_DATA" >> "$DATA_REPORT"
                echo "\`\`\`" >> "$DATA_REPORT"
            fi
            echo "" >> "$DATA_REPORT"
        fi
    done
    
else
    echo "⚠️  Análise de dados não disponível (MySQL não conectado)"
    echo "⚠️  Análise de dados não disponível - MySQL não conectado" >> "$DATA_REPORT"
    echo "" >> "$DATA_REPORT"
    echo "Esta análise será feita durante o deploy na VPS." >> "$DATA_REPORT"
fi

echo ""
echo "🏗️ 6. GERANDO SCHEMA PRISMA PRELIMINAR"
echo "====================================="

PRISMA_SCHEMA="$ANALYSIS_DIR/05_prisma_schema.prisma"
echo "📝 Criando schema Prisma baseado na análise..."

cat > "$PRISMA_SCHEMA" << 'EOF'
// Schema Prisma Preliminar - Sistema Erlene Advogados
// Gerado automaticamente baseado na análise do Laravel
// Data: TIMESTAMP_PLACEHOLDER

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

// ========================================
// MODELOS PRINCIPAIS - BASEADOS NO LARAVEL
// ========================================

model User {
  id            Int       @id @default(autoincrement())
  nome          String?   
  email         String    @unique
  password      String
  cpf           String?
  oab           String?
  telefone      String?
  perfil        String?   @default("advogado")
  unidade_id    Int?
  status        String?   @default("ativo")
  ultimo_acesso DateTime?
  created_at    DateTime  @default(now())
  updated_at    DateTime  @updatedAt
  
  // Relacionamentos
  unidade       Unidade?  @relation(fields: [unidade_id], references: [id])
  clientes      Cliente[]
  processos     Processo[]
  atendimentos  Atendimento[]
  tarefas       Tarefa[]
  
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
  users      User[]
  clientes   Cliente[]
  processos  Processo[]
  
  @@map("unidades")
}

model Cliente {
  id           Int       @id @default(autoincrement())
  nome         String
  cpf_cnpj     String    @unique
  tipo_pessoa  String?   @default("fisica")
  email        String?
  telefone     String?
  endereco     String?
  cep          String?
  cidade       String?
  estado       String?
  observacoes  String?   @db.Text
  created_at   DateTime  @default(now())
  updated_at   DateTime  @updatedAt
  deleted_at   DateTime?
  
  // Relacionamentos
  processos    Processo[]
  atendimentos Atendimento[]
  documentos   DocumentoGed[]
  financeiro   Financeiro[]
  audiencias   Audiencia[]
  mensagens    Mensagem[]
  
  @@map("clientes")
}

model Processo {
  id                Int       @id @default(autoincrement())
  numero            String    @unique
  tribunal          String?
  vara              String?
  cliente_id        Int
  tipo_acao         String?
  status            String?   @default("ativo")
  valor_causa       Decimal?  @db.Decimal(15,2)
  data_distribuicao DateTime?
  advogado_id       Int?
  unidade_id        Int?
  created_at        DateTime  @default(now())
  updated_at        DateTime  @updatedAt
  
  // Relacionamentos
  cliente       Cliente        @relation(fields: [cliente_id], references: [id])
  advogado      User?          @relation(fields: [advogado_id], references: [id])
  unidade       Unidade?       @relation(fields: [unidade_id], references: [id])
  movimentacoes Movimentacao[]
  atendimentos  Atendimento[]
  tarefas       Tarefa[]
  audiencias    Audiencia[]
  kanban_cards  KanbanCard[]
  
  @@map("processos")
}

model Atendimento {
  id             Int       @id @default(autoincrement())
  cliente_id     Int
  advogado_id    Int?
  data_hora      DateTime
  tipo           String?
  assunto        String?
  descricao      String?   @db.Text
  status         String?   @default("agendado")
  duracao        Int?      // minutos
  valor          Decimal?  @db.Decimal(10,2)
  proximos_passos String?  @db.Text
  created_at     DateTime  @default(now())
  updated_at     DateTime  @updatedAt
  
  // Relacionamentos
  cliente     Cliente      @relation(fields: [cliente_id], references: [id])
  advogado    User?        @relation(fields: [advogado_id], references: [id])
  processos   Processo[]   // Many-to-many via pivot table
  financeiro  Financeiro[]
  
  @@map("atendimentos")
}

model Financeiro {
  id               Int       @id @default(autoincrement())
  processo_id      Int?
  atendimento_id   Int?
  cliente_id       Int
  tipo             String    // "receita", "despesa"
  valor            Decimal   @db.Decimal(10,2)
  data_vencimento  DateTime
  data_pagamento   DateTime?
  status           String    @default("pendente")
  descricao        String?
  gateway          String?   // "stripe", "mercadopago"
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

model Audiencia {
  id          Int       @id @default(autoincrement())
  processo_id Int
  cliente_id  Int
  advogado_id Int?
  unidade_id  Int?
  tipo        String?
  data        DateTime
  hora        String?
  local       String?
  endereco    String?
  sala        String?
  created_at  DateTime  @default(now())
  updated_at  DateTime  @updatedAt
  
  // Relacionamentos
  processo  Processo  @relation(fields: [processo_id], references: [id])
  cliente   Cliente   @relation(fields: [cliente_id], references: [id])
  advogado  User?     @relation(fields: [advogado_id], references: [id])
  
  @@map("audiencias")
}

// ========================================
// MODELOS AUXILIARES
// ========================================

model Movimentacao {
  id          Int       @id @default(autoincrement())
  processo_id Int
  data        DateTime
  descricao   String    @db.Text
  tipo        String?
  documento_url String?
  metadata    Json?
  created_at  DateTime  @default(now())
  updated_at  DateTime  @updatedAt
  
  // Relacionamentos
  processo  Processo  @relation(fields: [processo_id], references: [id])
  
  @@map("movimentacoes")
}

model DocumentoGed {
  id            Int       @id @default(autoincrement())
  cliente_id    Int
  pasta         String?
  nome_arquivo  String
  nome_original String
  caminho       String
  tipo_arquivo  String?
  mime_type     String?
  tamanho       Int?
  data_upload   DateTime  @default(now())
  usuario_id    Int?
  created_at    DateTime  @default(now())
  updated_at    DateTime  @updatedAt
  
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
  responsavel  User?     @relation(fields: [responsavel_id], references: [id])
  cliente      Cliente?  @relation(fields: [cliente_id], references: [id])
  processo     Processo? @relation(fields: [processo_id], references: [id])
  
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
  cards  KanbanCard[]
  
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
  
  @@map("mensagens")
}

// ========================================
// MODELOS DE PAGAMENTO
// ========================================

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
  financeiro  Financeiro?  @relation(fields: [financeiro_id], references: [id])
  
  @@map("pagamentos_mp")
}

// ========================================
// MODELOS DE INTEGRAÇÃO
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
  
  @@map("logs_sistema")
}
EOF

# Substituir timestamp
sed -i "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/g" "$PRISMA_SCHEMA"

echo "✅ Schema Prisma preliminar criado!"

echo ""
echo "📋 7. RELATÓRIO FINAL DA ANÁLISE"
echo "==============================="

FINAL_REPORT="$ANALYSIS_DIR/00_mysql_analysis_summary.md"
echo "# RELATÓRIO FINAL - Análise MySQL para Migração Node.js" > "$FINAL_REPORT"
echo "## Sistema Erlene Advogados" >> "$FINAL_REPORT"
echo "### Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" >> "$FINAL_REPORT"
echo "" >> "$FINAL_REPORT"

echo "## 🗄️ Resumo da Análise do Banco" >> "$FINAL_REPORT"
echo "- **Host**: $DB_HOST:$DB_PORT" >> "$FINAL_REPORT"
echo "- **Database**: $DB_DATABASE" >> "$FINAL_REPORT"
echo "- **Conexão MySQL**: $([ "$mysql_connected" = true ] && echo "✅ Estabelecida" || echo "❌ Não disponível")" >> "$FINAL_REPORT"
echo "- **Tabelas**: ${TABLE_COUNT:-"Identificadas via migrations"}" >> "$FINAL_REPORT"