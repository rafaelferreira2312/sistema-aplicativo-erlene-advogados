# Relacionamentos entre Tabelas
## Gerado em: 2025-09-19 16:03:27

## Relacionamentos Identificados nos Models
### Atendimento
36:        return $this->belongsTo(Cliente::class);
41:        return $this->belongsTo(User::class, 'advogado_id');
46:        return $this->belongsTo(Unidade::class);
51:        return $this->belongsToMany(Processo::class, 'atendimento_processos');
56:        return $this->hasMany(Financeiro::class);

### Audiencia
97:        return $this->belongsTo(Processo::class);
105:        return $this->belongsTo(Cliente::class);
113:        return $this->belongsTo(User::class, 'advogado_id');
121:        return $this->belongsTo(Unidade::class);

### Cliente
54:        return $this->belongsTo(Unidade::class);
59:        return $this->belongsTo(User::class, 'responsavel_id');
64:        return $this->hasMany(Processo::class);
69:        return $this->hasMany(Atendimento::class);
74:        return $this->hasMany(DocumentoGed::class);

### DocumentoGed
44:        return $this->belongsTo(Cliente::class);
49:        return $this->belongsTo(User::class);

### Financeiro
40:        return $this->belongsTo(Processo::class);
45:        return $this->belongsTo(Atendimento::class);
50:        return $this->belongsTo(Cliente::class);
55:        return $this->belongsTo(Unidade::class);
60:        return $this->hasMany(PagamentoStripe::class);

### Integracao
36:        return $this->belongsTo(Unidade::class);

### KanbanCard
33:        return $this->belongsTo(KanbanColuna::class, 'coluna_id');
38:        return $this->belongsTo(Processo::class);
43:        return $this->belongsTo(Tarefa::class);
48:        return $this->belongsTo(User::class, 'responsavel_id');

### KanbanColuna
24:        return $this->belongsTo(Unidade::class);
29:        return $this->hasMany(KanbanCard::class, 'coluna_id');

### LogSistema
34:        return $this->belongsTo(User::class, 'usuario_id');
39:        return $this->belongsTo(Cliente::class, 'cliente_id');

### Mensagem
38:        return $this->belongsTo(User::class, 'remetente_id');
43:        return $this->belongsTo(User::class, 'destinatario_id');
48:        return $this->belongsTo(Cliente::class);
53:        return $this->belongsTo(Processo::class);

### Movimentacao
31:        return $this->belongsTo(Processo::class);

### PagamentoMercadoPago
47:        return $this->belongsTo(Cliente::class);
52:        return $this->belongsTo(Processo::class);
57:        return $this->belongsTo(Atendimento::class);
62:        return $this->belongsTo(Financeiro::class);

### PagamentoStripe
43:        return $this->belongsTo(Cliente::class);
48:        return $this->belongsTo(Processo::class);
53:        return $this->belongsTo(Atendimento::class);
58:        return $this->belongsTo(Financeiro::class);

### Prazo
41:        return $this->belongsTo(\App\Models\Cliente::class, 'client_id');
46:        return $this->belongsTo(\App\Models\Processo::class, 'process_id');
51:        return $this->belongsTo(\App\Models\User::class, 'user_id');

### Processo
59:        return $this->belongsTo(Cliente::class, 'cliente_id');
64:        return $this->belongsTo(User::class, 'advogado_id');
69:        return $this->belongsTo(Unidade::class, 'unidade_id');
74:        return $this->hasMany(Movimentacao::class, 'processo_id')->orderBy('data', 'desc');
82:        return $this->hasMany(Atendimento::class, 'processo_id');

### Tarefa
31:        return $this->belongsTo(User::class, 'responsavel_id');
36:        return $this->belongsTo(Cliente::class);
41:        return $this->belongsTo(Processo::class);
46:        return $this->hasMany(KanbanCard::class);

### Tribunal
33:        return $this->hasMany(Processo::class, 'tribunal', 'codigo');

### Unidade
29:        return $this->hasMany(User::class);

### User
55:        return $this->belongsTo(Unidade::class);

