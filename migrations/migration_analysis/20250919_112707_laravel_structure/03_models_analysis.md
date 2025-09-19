# Análise dos Models Laravel
## Gerado em: 2025-09-19 11:27:08

## Lista de Models
- Admin/AdminUser
- Atendimento
- Audiencia
- Client/ClientAccess
- Cliente
- DocumentoGed
- Financeiro
- Financial/MercadoPagoPayment
- Financial/Payment
- Financial/StripePayment
- Integracao
- Integration
- Integration/DriveSync
- Integration/TribunalIntegration
- KanbanCard
- KanbanColuna
- LogSistema
- Mensagem
- Movement
- Movimentacao
- PagamentoMercadoPago
- PagamentoStripe
- Permission
- Prazo
- Processo
- Tarefa
- Tribunal
- Unidade
- Unit
- User

## Detalhes dos Models
### Tarefa
**Arquivo:** `app/Models/Tarefa.php`
**Campos fillable:**
- titulo
- descricao
- tipo
- status
- prazo
- responsavel_id
- cliente_id
- processo_id
- kanban_posicao
**Relacionamentos:**
-         return $this->hasMany(KanbanCard

### MercadoPagoPayment
**Arquivo:** `app/Models/Financial/MercadoPagoPayment.php`

### StripePayment
**Arquivo:** `app/Models/Financial/StripePayment.php`

### Payment
**Arquivo:** `app/Models/Financial/Payment.php`

### PagamentoMercadoPago
**Arquivo:** `app/Models/PagamentoMercadoPago.php`
**Campos fillable:**
- cliente_id
- processo_id
- atendimento_id
- financeiro_id
- valor
- tipo
- status
- mp_payment_id
- mp_preference_id
- mp_external_reference

### Audiencia
**Arquivo:** `app/Models/Audiencia.php`
**Campos fillable:**
- processo_id
- cliente_id
- advogado_id
- unidade_id
- tipo
- data
- hora
- local
- endereco
- sala

### Tribunal
**Arquivo:** `app/Models/Tribunal.php`
**Campos fillable:**
- nome
- codigo
- url_consulta
- tipo
- estado
- config_api
- ativo
- limite_consultas_dia
**Relacionamentos:**
-         return $this->hasMany(Processo

### KanbanColuna
**Arquivo:** `app/Models/KanbanColuna.php`
**Campos fillable:**
- nome
- ordem
- cor
- unidade_id
**Relacionamentos:**
-         return $this->hasMany(KanbanCard

### Unidade
**Arquivo:** `app/Models/Unidade.php`
**Campos fillable:**
- nome
- codigo
- endereco
- cidade
- estado
- cep
- telefone
- email
- cnpj
- status
**Relacionamentos:**
-         return $this->hasMany(User

### KanbanCard
**Arquivo:** `app/Models/KanbanCard.php`
**Campos fillable:**
- titulo
- descricao
- coluna_id
- processo_id
- tarefa_id
- posicao
- prioridade
- prazo
- responsavel_id

### PagamentoStripe
**Arquivo:** `app/Models/PagamentoStripe.php`
**Campos fillable:**
- cliente_id
- processo_id
- atendimento_id
- financeiro_id
- valor
- moeda
- status
- stripe_payment_intent_id
- stripe_customer_id
- stripe_charge_id

### DriveSync
**Arquivo:** `app/Models/Integration/DriveSync.php`

### TribunalIntegration
**Arquivo:** `app/Models/Integration/TribunalIntegration.php`

### Integracao
**Arquivo:** `app/Models/Integracao.php`
**Campos fillable:**
- nome
- ativo
- configuracoes
- ultima_sincronizacao
- status
- ultimo_erro
- total_requisicoes
- requisicoes_sucesso
- requisicoes_erro
- unidade_id

### DocumentoGed
**Arquivo:** `app/Models/DocumentoGed.php`
**Campos fillable:**
- cliente_id
- pasta
- nome_arquivo
- nome_original
- caminho
- tipo_arquivo
- mime_type
- tamanho
- data_upload
- usuario_id

### Integration
**Arquivo:** `app/Models/Integration.php`

### ClientAccess
**Arquivo:** `app/Models/Client/ClientAccess.php`

### Processo
**Arquivo:** `app/Models/Processo.php`
**Campos fillable:**
- numero
- tribunal
- vara
- cliente_id
- tipo_acao
- status
- valor_causa
- data_distribuicao
- advogado_id
- unidade_id
**Relacionamentos:**
-         return $this->hasMany(Movimentacao
-         return $this->hasMany(Atendimento
-         return $this->hasMany(Tarefa

### LogSistema
**Arquivo:** `app/Models/LogSistema.php`
**Campos fillable:**
- nivel
- categoria
- mensagem
- contexto
- usuario_id
- cliente_id
- ip
- user_agent
- request_id
- data_hora

### Cliente
**Arquivo:** `app/Models/Cliente.php`
**Campos fillable:**
- nome
- cpf_cnpj
- tipo_pessoa
- email
- telefone
- endereco
- cep
- cidade
- estado
- observacoes
**Relacionamentos:**
-         return $this->hasMany(Processo
-         return $this->hasMany(Atendimento
-         return $this->hasMany(DocumentoGed
-         return $this->hasMany(Financeiro
-         return $this->hasMany(AcessoPortal

### Atendimento
**Arquivo:** `app/Models/Atendimento.php`
**Campos fillable:**
- cliente_id
- advogado_id
- data_hora
- tipo
- assunto
- descricao
- status
- duracao
- valor
- proximos_passos
**Relacionamentos:**
-         return $this->belongsToMany(Processo
-         return $this->hasMany(Financeiro

### Prazo
**Arquivo:** `app/Models/Prazo.php`
**Campos fillable:**
- client_id
- process_id
- user_id
- descricao
- tipo_prazo
- data_vencimento
- hora_vencimento
- status
- prioridade
- observacoes

### AdminUser
**Arquivo:** `app/Models/Admin/AdminUser.php`

### Unit
**Arquivo:** `app/Models/Unit.php`

### Mensagem
**Arquivo:** `app/Models/Mensagem.php`
**Campos fillable:**
- remetente_id
- destinatario_id
- cliente_id
- processo_id
- conteudo
- tipo
- arquivo_url
- data_envio
- lida
- data_leitura

### Movement
**Arquivo:** `app/Models/Movement.php`

### User
**Arquivo:** `app/Models/User.php`
**Campos fillable:**
- nome
- email
- password
- cpf
- oab
- telefone
- perfil
- unidade_id
- status
- ultimo_acesso

### Permission
**Arquivo:** `app/Models/Permission.php`

### Movimentacao
**Arquivo:** `app/Models/Movimentacao.php`
**Campos fillable:**
- processo_id
- data
- descricao
- tipo
- documento_url
- metadata
- data=>datetime

### Financeiro
**Arquivo:** `app/Models/Financeiro.php`
**Campos fillable:**
- processo_id
- atendimento_id
- cliente_id
- tipo
- valor
- data_vencimento
- data_pagamento
- status
- descricao
- gateway
**Relacionamentos:**
-         return $this->hasMany(PagamentoStripe
-         return $this->hasMany(PagamentoMercadoPago

