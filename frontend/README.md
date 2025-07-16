# Frontend - Sistema Erlene Advogados

Sistema de gestão jurídica completo desenvolvido em React com design system personalizado.

## 🚀 Tecnologias Utilizadas

- **React 18** com TypeScript
- **Tailwind CSS** para estilização
- **React Query** para gerenciamento de estado e cache
- **React Hook Form** para formulários
- **React Router** para navegação
- **Headless UI** para componentes acessíveis
- **React Beautiful DnD** para drag & drop
- **Recharts** para gráficos
- **Axios** para requisições HTTP
- **React Hot Toast** para notificações

## 📁 Estrutura do Projeto

```
frontend/
├── src/
│   ├── components/          # Componentes reutilizáveis
│   │   ├── common/         # Componentes básicos (Button, Input, Modal, etc)
│   │   ├── charts/         # Componentes de gráficos
│   │   ├── calendar/       # Componentes de calendário
│   │   ├── kanban/         # Componentes do Kanban
│   │   ├── documents/      # Componentes do GED
│   │   └── layout/         # Layouts da aplicação
│   ├── pages/              # Páginas da aplicação
│   │   ├── admin/          # Páginas do sistema administrativo
│   │   ├── portal/         # Páginas do portal do cliente
│   │   ├── auth/           # Páginas de autenticação
│   │   └── errors/         # Páginas de erro
│   ├── hooks/              # Hooks customizados
│   │   ├── api/            # Hooks para APIs
│   │   ├── auth/           # Hooks de autenticação
│   │   └── common/         # Hooks utilitários
│   ├── context/            # Context providers
│   ├── services/           # Serviços e API clients
│   ├── utils/              # Utilitários e helpers
│   ├── config/             # Configurações
│   └── styles/             # Estilos globais
├── public/                 # Arquivos públicos
└── package.json           # Dependências e scripts
```

## 🎨 Design System

O sistema utiliza a identidade visual da Dra. Erlene Chaves Silva:

### Cores Principais
- **Vermelho/Bordô**: #8B1538
- **Dourado**: #F5B041
- **Branco**: #FFFFFF
- **Cinzas**: Escala de cinza padrão

### Componentes Base
- **Button**: Botão com múltiplas variantes
- **Input**: Campo de entrada com validação
- **Card**: Container reutilizável
- **Modal**: Modal com transições suaves
- **Table**: Tabela com sorting e paginação
- **Badge**: Badge para status e tags

## 🔧 Funcionalidades Principais

### Sistema Administrativo
- **Dashboard**: Visão geral com estatísticas
- **Clientes**: CRUD completo com filtros
- **Processos**: Gestão com sincronização tribunais
- **Atendimentos**: Agenda e calendário
- **Financeiro**: Controle receitas/despesas
- **Documentos (GED)**: Upload e organização
- **Kanban**: Organização visual de tarefas
- **Usuários**: Gerenciamento de acesso
- **Relatórios**: Analytics e exportação

### Portal do Cliente
- **Dashboard**: Visão simplificada
- **Processos**: Acompanhamento de andamentos
- **Documentos**: Acesso aos arquivos
- **Pagamentos**: Histórico e pagamento online
- **Mensagens**: Comunicação com escritório

### Recursos Avançados
- **Autenticação JWT** com refresh automático
- **Sistema multi-tenant** (matriz/filiais)
- **Upload drag & drop** com preview
- **Gráficos interativos** com Recharts
- **Calendário** com eventos e navegação
- **Kanban** com drag & drop
- **Tema claro/escuro**
- **Notificações** em tempo real
- **Offline support** (service workers)

## 📱 Responsividade

O sistema é totalmente responsivo com:
- **Mobile first** design
- **Breakpoints** customizados
- **Sidebar** colapsível
- **Modais** adaptáveis
- **Tabelas** com scroll horizontal

## 🔒 Segurança

- **JWT tokens** com refresh automático
- **Proteção de rotas** por perfil
- **Validação** client-side e server-side
- **HTTPS** obrigatório
- **Headers** de segurança configurados

## 🚀 Scripts Disponíveis

```bash
# Instalar dependências
npm install

# Desenvolvimento
npm start

# Build de produção
npm run build

# Testes
npm test

# Análise de bundle
npm run analyze
```

## 📦 Dependências Principais

```json
{
  "react": "^18.2.0",
  "react-router-dom": "^6.8.0",
  "react-query": "^3.39.0",
  "react-hook-form": "^7.43.0",
  "axios": "^1.3.0",
  "tailwindcss": "^3.2.0",
  "@headlessui/react": "^1.7.0",
  "@heroicons/react": "^2.0.0",
  "react-beautiful-dnd": "^13.1.0",
  "recharts": "^2.5.0",
  "react-hot-toast": "^2.4.0"
}
```

## 🌐 Variáveis de Ambiente

```env
REACT_APP_API_URL=https://localhost:8443/api
REACT_APP_URL=https://localhost:3000
REACT_APP_STRIPE_PUBLISHABLE_KEY=pk_test_...
REACT_APP_MERCADO_PAGO_PUBLIC_KEY=TEST-...
```

## 📋 Checklist de Funcionalidades

### ✅ Concluído
- [x] Sistema de autenticação completo
- [x] Layouts responsivos (Admin/Portal/Auth)
- [x] Componentes UI base (Button, Input, Modal, etc)
- [x] Páginas principais (Dashboard, Clientes, Processos)
- [x] Sistema GED completo
- [x] Kanban com drag & drop
- [x] Gráficos e calendário
- [x] Hooks customizados
- [x] Context providers
- [x] Utilitários e validadores
- [x] Páginas de erro
- [x] Design system Erlene

### 🎯 Frontend 100% Completo!

O frontend está totalmente implementado e pronto para integração com o backend Laravel.

## 👨‍💻 Desenvolvido por

**Vancouver Tec** - Sistema de Gestão Jurídica Erlene Advogados
