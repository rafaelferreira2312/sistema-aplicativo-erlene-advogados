# Análise de Dados Existentes
## Gerado em: 2025-09-19 16:03:28

## Volume de Dados por Tabela
| Tabela | Registros |
|--------|-----------|
| users | 12 |
| clientes | 5 |
| processos | 2 |
| atendimentos | 0 |
| financeiro | 0 |
| documentos_ged | 0 |
| audiencias | 11 |

## Exemplos de Dados (Primeiros 3 registros)
### Tabela: users
```
id	name	email	cpf	telefone	oab	perfil	unidade_id	status	ultimo_acesso	email_verified_at	password	remember_token	created_at	updated_at
1	Dra. Erlene Chaves Silva	admin@erlene.com	11111111111	(11) 99999-1111	SP123456	admin_geral	2	ativo	NULL	2025-08-28 20:58:46	$2y$12$WUxB6Ta96r5G17DHjaHG6ufTebW90vebJdA0tvJXO3xGv5PbRm/Ke	NULL	2025-08-28 20:58:46	2025-08-28 20:58:46
2	Dr. João Silva Santos	admin.rj@erlene.com	22222222222	(21) 98888-2222	RJ654321	admin_unidade	3	ativo	NULL	2025-08-28 20:58:46	$2y$12$K23juvbQFRljaL.I.nXDy.OfyQrRHIu1/pcxe3zB1TnQ.TgXhuW1e	NULL	2025-08-28 20:58:46	2025-08-28 20:58:46
3	Dr. Carlos Mendes Lima	admin.bh@erlene.com	33333333333	(31) 97777-3333	MG789012	admin_unidade	4	ativo	NULL	2025-08-28 20:58:46	$2y$12$9kkMy27lMEZ35CO275xvKetjo9fi7dYGG5yd4zbTt94o4IkpLziv.	NULL	2025-08-28 20:58:46	2025-08-28 20:58:46
```

### Tabela: clientes
```
id	nome	cpf_cnpj	tipo_pessoa	email	telefone	endereco	cep	cidade	estado	observacoes	acesso_portal	senha_portal	tipo_armazenamento	google_drive_config	onedrive_config	pasta_local	unidade_id	responsavel_id	status	created_at	updated_at	deleted_at
1	João Silva Santos	12345678900	PF	joao.silva@email.com	11999999999	Av. Paulista, 1000, Apto 101	01310100	São Paulo	SP	Cliente VIP - atendimento prioritário. Empresário do ramo alimentício com 3 restaurantes na capital.	1	$2y$12$bFj2B4F9nBp0mhifwdCfv.3VAxKsppPDcaqYLCcZdECORs85W9HT2	google_drive	{"folder_id": "cliente_joao_silva", "sync_enabled": true}	NULL	joao-silva-santos	2	1	ativo	2025-08-30 22:00:29	2025-08-30 22:00:29	NULL
2	TechSolutions Desenvolvimento Ltda	12345678000190	PJ	juridico@techsolutions.com.br	1133333333	Rua Vergueiro, 2000, Sala 205	04038001	São Paulo	SP	Empresa de tecnologia especializada em desenvolvimento de software. Cliente desde 2020. Contratos de desenvolvimento e consultoria.	1	$2y$12$yu08j3ENwzd7TAhGnnGX2u7wf3bhmfWLAEUI3.eMX2T9NFHjUwJYa	onedrive	NULL	{"folder_path": "/clientes/techsolutions", "sync_enabled": true}	techsolutions-desenvolvimento-ltda	2	1	ativo	2025-08-30 22:00:29	2025-08-30 22:00:29	NULL
3	Maria Oliveira Costa	98765432100	PF	maria.costa@gmail.com	11888888888	Rua das Flores, 123, Apto 45B	12345678	Guarulhos	SP	Professora aposentada. Processo de revisão de aposentadoria em andamento. Viúva, 2 filhos.	0	NULL	local	NULL	NULL	maria-oliveira-costa	2	1	ativo	2025-08-30 22:00:29	2025-08-30 22:00:29	NULL
```

### Tabela: processos
```
id	numero	tribunal	vara	cliente_id	tipo_acao	status	valor_causa	data_distribuicao	advogado_id	unidade_id	proximo_prazo	observacoes	prioridade	kanban_posicao	kanban_coluna_id	created_at	updated_at	metadata_cnj	ultima_consulta_cnj	sincronizado_cnj	deleted_at
1	5001234-56.2024.8.26.0100	TJSP	1ª Vara Cível	1	Ação de Cobrança	em_andamento	8978.22	2025-09-01	1	2	NULL	Processo contra as casas bahia	media	0	NULL	2025-09-01 21:53:46	2025-09-05 12:48:00	NULL	NULL	0	NULL
2	0000335250184013202	TRT02	13ª Vara Federal - Seção Judiciária do DF h	2	Ação de Indenização	distribuido	25893.14	2025-06-04	4	2	2025-09-05	Processo de teste com número real da API CNJ DataJud para validação da integração	media	0	NULL	2025-09-02 15:07:13	2025-09-05 12:46:56	NULL	NULL	0	NULL
```

