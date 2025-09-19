# Estrutura do Banco de Dados
## Gerado em: 2025-09-19 16:03:27

## Tabelas Encontradas no Banco
- acessos_portal
- agenda
- atendimento_processos
- atendimentos
- audiencias
- cache
- cache_locks
- clientes
- configuracoes
- documentos_ged
- failed_jobs
- financeiro
- integracoes
- job_batches
- jobs
- kanban_cards
- kanban_colunas
- logs_sistema
- mensagens
- migrations
- movimentacoes
- notificacoes
- pagamentos_mp
- pagamentos_stripe
- password_reset_tokens
- permissoes_ged
- prazos
- processos
- sync_drives
- tarefas
- tribunais
- unidades
- user_sessions
- users

## Estrutura Detalhada das Tabelas
### Tabela: acessos_portal
```
Field	Type	Null	Key	Default	Extra
id	bigint unsigned	NO	PRI	NULL	auto_increment
cliente_id	bigint unsigned	NO	MUL	NULL	
ip	varchar(45)	NO		NULL	
user_agent	varchar(255)	YES		NULL	
data_acesso	datetime	NO		NULL	
acao	enum('login','logout','visualizar_processo','download_documento','upload_documento','pagamento','mensagem')	NO	MUL	NULL	
detalhes	varchar(255)	YES		NULL	
created_at	timestamp	YES		NULL	
updated_at	timestamp	YES		NULL	
```
**Registros**: 0

### Tabela: agenda
```
Field	Type	Null	Key	Default	Extra
id	bigint unsigned	NO	PRI	NULL	auto_increment
titulo	varchar(255)	NO		NULL	
descricao	text	YES		NULL	
data_inicio	datetime	NO	MUL	NULL	
data_fim	datetime	NO		NULL	
tipo	enum('audiencia','reuniao','consulta','prazo','lembrete','evento')	NO	MUL	NULL	
cliente_id	bigint unsigned	YES	MUL	NULL	
processo_id	bigint unsigned	YES	MUL	NULL	
atendimento_id	bigint unsigned	YES	MUL	NULL	
usuario_id	bigint unsigned	NO	MUL	NULL	
dia_inteiro	tinyint(1)	NO		0	
lembrete	int	YES		NULL	
lembrete_enviado	tinyint(1)	NO		0	
google_event_id	varchar(255)	YES		NULL	
cor	varchar(7)	NO		#3B82F6	
created_at	timestamp	YES		NULL	
updated_at	timestamp	YES		NULL	
```
**Registros**: 0

### Tabela: atendimento_processos
```
Field	Type	Null	Key	Default	Extra
id	bigint unsigned	NO	PRI	NULL	auto_increment
atendimento_id	bigint unsigned	NO	MUL	NULL	
processo_id	bigint unsigned	NO	MUL	NULL	
observacoes	text	YES		NULL	
created_at	timestamp	YES		NULL	
updated_at	timestamp	YES		NULL	
```
**Registros**: 0

### Tabela: atendimentos
```
Field	Type	Null	Key	Default	Extra
id	bigint unsigned	NO	PRI	NULL	auto_increment
cliente_id	bigint unsigned	NO	MUL	NULL	
advogado_id	bigint unsigned	NO	MUL	NULL	
data_hora	datetime	NO	MUL	NULL	
tipo	enum('presencial','online','telefone')	NO		NULL	
assunto	varchar(255)	NO		NULL	
descricao	text	NO		NULL	
status	enum('agendado','em_andamento','concluido','cancelado')	NO	MUL	agendado	
duracao	int	YES		NULL	
valor	decimal(10,2)	YES		NULL	
proximos_passos	text	YES		NULL	
anexos	json	YES		NULL	
unidade_id	bigint unsigned	NO	MUL	NULL	
created_at	timestamp	YES		NULL	
updated_at	timestamp	YES		NULL	
```
**Registros**: 0

### Tabela: audiencias
```
Field	Type	Null	Key	Default	Extra
id	bigint unsigned	NO	PRI	NULL	auto_increment
processo_id	bigint unsigned	YES	MUL	NULL	
cliente_id	bigint unsigned	YES	MUL	NULL	
advogado_id	bigint unsigned	YES	MUL	NULL	
unidade_id	bigint unsigned	YES	MUL	NULL	
tipo	enum('conciliacao','instrucao','preliminar','julgamento','outras')	NO	MUL	NULL	
data	date	NO	MUL	NULL	
hora	time	NO		NULL	
local	varchar(255)	NO		NULL	
advogado	varchar(255)	NO		NULL	
endereco	text	YES		NULL	
sala	varchar(100)	YES		NULL	
juiz	varchar(255)	YES		NULL	
observacoes	text	YES		NULL	
status	enum('agendada','confirmada','em_andamento','realizada','cancelada','adiada')	NO	MUL	agendada	
lembrete	tinyint(1)	NO		1	
horas_lembrete	int	NO		2	
created_at	timestamp	YES		NULL	
updated_at	timestamp	YES		NULL	
deleted_at	timestamp	YES		NULL	
```
**Registros**: 11

### Tabela: cache
```
Field	Type	Null	Key	Default	Extra
key	varchar(255)	NO	PRI	NULL	
value	mediumtext	NO		NULL	
expiration	int	NO		NULL	
```
**Registros**: 0

### Tabela: cache_locks
```
Field	Type	Null	Key	Default	Extra
key	varchar(255)	NO	PRI	NULL	
owner	varchar(255)	NO		NULL	
expiration	int	NO		NULL	
```
**Registros**: 0

### Tabela: clientes
```
Field	Type	Null	Key	Default	Extra
id	bigint unsigned	NO	PRI	NULL	auto_increment
nome	varchar(255)	NO		NULL	
cpf_cnpj	varchar(18)	NO	UNI	NULL	
tipo_pessoa	enum('PF','PJ')	NO	MUL	NULL	
email	varchar(255)	NO		NULL	
telefone	varchar(15)	NO		NULL	
endereco	text	NO		NULL	
cep	varchar(9)	NO		NULL	
cidade	varchar(255)	NO		NULL	
estado	varchar(2)	NO		NULL	
observacoes	text	YES		NULL	
acesso_portal	tinyint(1)	NO		0	
senha_portal	varchar(255)	YES		NULL	
tipo_armazenamento	enum('local','google_drive','onedrive')	NO		local	
google_drive_config	json	YES		NULL	
onedrive_config	json	YES		NULL	
pasta_local	varchar(255)	YES		NULL	
unidade_id	bigint unsigned	NO	MUL	NULL	
responsavel_id	bigint unsigned	NO	MUL	NULL	
status	enum('ativo','inativo')	NO		ativo	
created_at	timestamp	YES		NULL	
updated_at	timestamp	YES		NULL	
deleted_at	timestamp	YES		NULL	
```
**Registros**: 5

### Tabela: configuracoes
```
Field	Type	Null	Key	Default	Extra
id	bigint unsigned	NO	PRI	NULL	auto_increment
chave	varchar(255)	NO	UNI	NULL	
valor	text	YES		NULL	
tipo	enum('string','integer','boolean','json','text')	NO		NULL	
categoria	varchar(255)	NO	MUL	NULL	
descricao	text	YES		NULL	
requer_reinicio	tinyint(1)	NO		0	
unidade_id	bigint unsigned	YES	MUL	NULL	
created_at	timestamp	YES		NULL	
updated_at	timestamp	YES		NULL	
```
**Registros**: 8

### Tabela: documentos_ged
```
Field	Type	Null	Key	Default	Extra
id	bigint unsigned	NO	PRI	NULL	auto_increment
cliente_id	bigint unsigned	NO	MUL	NULL	
pasta	varchar(255)	NO	MUL	NULL	
nome_arquivo	varchar(255)	NO		NULL	
nome_original	varchar(255)	NO		NULL	
caminho	varchar(255)	NO		NULL	
tipo_arquivo	varchar(10)	NO	MUL	NULL	
mime_type	varchar(255)	NO		NULL	
tamanho	bigint	NO		NULL	
data_upload	datetime	NO		NULL	
usuario_id	bigint unsigned	NO	MUL	NULL	
versao	int	NO		1	
storage_type	enum('local','google_drive','onedrive')	NO		NULL	
google_drive_id	varchar(255)	YES		NULL	
onedrive_id	varchar(255)	YES		NULL	
tags	json	YES		NULL	
descricao	text	YES		NULL	
publico	tinyint(1)	NO		0	
hash_arquivo	varchar(255)	YES		NULL	
created_at	timestamp	YES		NULL	
updated_at	timestamp	YES		NULL	
```
**Registros**: 0

