<div align="center">
  <img src="./docs/assets/logo-erlene.png" alt="Logo Erlene Advogados" width="200"/>
  
  # 🏛️ Sistema de Gestão Jurídica - Erlene Advogados
  
  [![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
  [![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](./docker-compose.yml)
  [![PHP](https://img.shields.io/badge/PHP-8.2+-777BB4.svg?logo=php)](./backend)
  [![React](https://img.shields.io/badge/React-18+-61DAFB.svg?logo=react)](./frontend)
  [![React Native](https://img.shields.io/badge/React_Native-Latest-20232A.svg?logo=react)](./mobile)
  
  **Sistema web e mobile completo para escritório de advocacia com múltiplas unidades**
  
  [📚 Documentação](./docs) • [🚀 Instalação](#instalação) • [📱 Apps](./mobile) • [🔗 API](./docs/api)
</div>

---

## 📋 Sobre o Projeto

Sistema completo de gestão jurídica desenvolvido especificamente para o escritório de advocacia da **Dra. Erlene Chaves Silva**, incluindo:

- 🏢 **Gestão Multi-unidade** (Matriz e Filiais)
- 👥 **Gestão de Clientes** com portal personalizado
- ⚖️ **Gestão de Processos** com integração aos tribunais
- 📅 **Sistema de Atendimentos** com calendário
- 📁 **GED Avançado** (Google Drive, OneDrive, Local)
- 💰 **Sistema Financeiro** (Stripe, Mercado Pago)
- 📱 **Aplicativo Mobile** para advogados e clientes
- 🔗 **Integrações** com CNJ, Escavador, Jurisbrasil

## 🎨 Identidade Visual

O sistema segue exatamente a identidade visual do site da Dra. Erlene:
- **Cores**: Vermelho/bordô (#8B1538), Dourado (#F5B041), Branco
- **Tipografia**: Moderna e clean
- **Estilo**: Profissional, elegante e minimalista

## 🏗️ Arquitetura

```
📦 sistema-aplicativo-erlene-advogados/
├── 🔧 backend/          # API Laravel 10 + PHP 8.2
├── 🎨 frontend/         # React 18 + Tailwind CSS
├── 📱 mobile/           # React Native + Expo
├── 🐳 docker/           # Configurações Docker
├── 📚 docs/             # Documentação completa
├── 🔧 scripts/          # Scripts de automação
└── ⚙️ config/           # Configurações por ambiente
```

## 🛠️ Stack Tecnológica

### Backend
- **PHP 8.2+** com **Laravel 10**
- **MySQL 8.0** para banco de dados
- **Apache** como servidor web
- **JWT** para autenticação
- **Swagger** para documentação da API

### Frontend
- **React 18** com JavaScript
- **Tailwind CSS** para estilização
- **Axios** para requisições HTTP
- **React Router** para navegação
- **Context API** para estado global

### Mobile
- **React Native** com **Expo**
- **Expo Router** para navegação
- **AsyncStorage** para persistência
- **Expo Camera** para captura de documentos
- **Expo Notifications** para push notifications

### DevOps
- **Docker & Docker Compose**
- **GitHub Actions** para CI/CD
- **Nginx** como proxy reverso
- **Let's Encrypt** para SSL

## 🚀 Instalação

### Pré-requisitos
- Docker & Docker Compose
- Node.js 18+
- PHP 8.2+
- Composer

### Instalação Rápida

```bash
# 1. Clone o repositório
git clone https://github.com/rafaelferreira2312/sistema-aplicativo-erlene-advogados.git
cd sistema-aplicativo-erlene-advogados

# 2. Execute o script de setup
chmod +x scripts/*.sh
./scripts/setup.sh

# 3. Configure as variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env com suas configurações

# 4. Inicie os containers
docker-compose up -d

# 5. Execute as migrações
./scripts/migrate.sh

# 6. Acesse o sistema
# Frontend: http://localhost:8080
# Backend API: http://localhost:8000
# Documentação: http://localhost:8080/docs
```

### Configuração Manual

<details>
<summary>👆 Clique para ver a configuração manual</summary>

#### Backend (Laravel)
```bash
cd backend
composer install
php artisan key:generate
php artisan migrate --seed
php artisan serve --port=8000
```

#### Frontend (React)
```bash
cd frontend
npm install
npm start
# Acesse: http://localhost:3000
```

#### Mobile (React Native)
```bash
cd mobile
npm install
npx expo start
# Escaneie o QR Code com o Expo Go
```

</details>

## 🔧 Configuração das Integrações

### 📊 APIs Externas Integradas

| Integração | Descrição | Status |
|------------|-----------|--------|
| 🏛️ **CNJ** | Consulta processos nos tribunais | ✅ Configurado |
| 🔍 **Escavador** | Pesquisa jurisprudencial | ✅ Configurado |
| ⚖️ **Jurisbrasil** | Acompanhamento processual | ✅ Configurado |
| 💳 **Stripe** | Pagamentos internacionais | ✅ Configurado |
| 💰 **Mercado Pago** | Pagamentos nacionais (PIX, Boleto) | ✅ Configurado |
| 📁 **Google Drive** | Armazenamento de documentos | ✅ Configurado |
| 📁 **OneDrive** | Armazenamento alternativo | ✅ Configurado |
| 🤖 **ChatGPT** | Assistente jurídico IA | ✅ Configurado |

### ⚙️ Configurar APIs

1. **Acesse as configurações** em `/admin/configuracoes/integracoes`
2. **Adicione suas chaves** para cada API
3. **Teste as conexões** usando os botões de teste
4. **Ative as integrações** desejadas

## 📱 Aplicativos Mobile

### 👨‍💼 App para Advogados
- Dashboard com métricas
- Kanban de processos
- Agenda de compromissos
- Upload de documentos
- Chat da equipe
- Modo offline

### 👤 App para Clientes
- Acompanhamento de processos
- Documentos compartilhados
- Pagamentos via app
- Chat com advogado
- Agendamento de consultas

## 🔒 Segurança

- ✅ **Autenticação JWT** com refresh tokens
- ✅ **Autorização baseada em perfis** e unidades
- ✅ **Criptografia** de dados sensíveis
- ✅ **SSL/TLS** obrigatório em produção
- ✅ **Backup automático** diário
- ✅ **Logs de auditoria** completos
- ✅ **Conformidade LGPD**

## 🌐 Ambientes

| Ambiente | URL | Status | Descrição |
|----------|-----|---------|-----------|
| **Desenvolvimento** | http://localhost:8080 | 🟢 Ativo | Ambiente local |
| **Staging** | https://staging.erlene.dev | 🟡 Deploy | Testes pré-produção |
| **Produção** | https://sistema.erleneadvogados.com | 🔴 Aguardando | Sistema principal |

## 📊 Monitoramento

- **Health Checks** automáticos
- **Logs centralizados** com ELK Stack
- **Métricas de performance** com Prometheus
- **Alertas** via email e Slack
- **Backup automático** com retenção de 30 dias

## 🤝 Contribuição

1. **Fork** o projeto
2. **Crie uma branch** para sua feature (`git checkout -b feature/nova-feature`)
3. **Commit** suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. **Push** para a branch (`git push origin feature/nova-feature`)
5. **Abra um Pull Request**

### 📋 Padrões de Desenvolvimento

- **Backend**: PSR-12, Laravel Best Practices
- **Frontend**: ESLint + Prettier
- **Mobile**: Expo + React Native guidelines
- **Git**: Conventional Commits
- **Documentação**: Markdown com exemplos

## 📚 Documentação

| Documento | Descrição |
|-----------|-----------|
| [📖 Manual do Usuário](./docs/user-manual/) | Guia completo para usuários |
| [🔧 Manual Técnico](./docs/setup/) | Instalação e configuração |
| [🔗 API Reference](./docs/api/) | Documentação da API |
| [🏗️ Arquitetura](./docs/architecture/) | Visão técnica do sistema |
| [🔌 Integrações](./docs/integrations/) | Configuração das APIs |

## 📈 Roadmap

### ✅ Versão 1.0 (Atual)
- [x] Sistema base multi-unidade
- [x] Gestão de clientes e processos
- [x] Portal do cliente
- [x] Aplicativo mobile
- [x] Integrações principais

### 🚧 Versão 1.1 (Em Desenvolvimento)
- [ ] Relatórios avançados com BI
- [ ] Integração com WhatsApp Business
- [ ] Assinatura digital de documentos
- [ ] Dashboard executivo

### 🔮 Versão 2.0 (Planejado)
- [ ] IA para análise de contratos
- [ ] Automação de petições
- [ ] Integração com Office 365
- [ ] Multi-idioma

## 🆘 Suporte

### 📞 Canais de Suporte

- **📧 Email**: rafaelferreira2312@gmail.com
- **💬 Chat**: Disponível no sistema
- **📱 WhatsApp**: +55 (21) 97160-4248
- **🐛 Issues**: [GitHub Issues](https://github.com/rafaelferreira2312/sistema-aplicativo-erlene-advogados/issues)

### ⚡ Solução Rápida de Problemas

<details>
<summary>🐳 Problemas com Docker</summary>

```bash
# Reiniciar containers
docker-compose down && docker-compose up -d

# Verificar logs
docker-compose logs -f

# Limpar cache
docker system prune -a
```

</details>

<details>
<summary>🔑 Problemas de Autenticação</summary>

```bash
# Regenerar chave JWT
cd backend
php artisan jwt:secret

# Limpar cache de autenticação
php artisan cache:clear
```

</details>

## 📄 Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](./LICENSE) para detalhes.

## 👨‍💻 Desenvolvido por

**Vancouver Tec** - Soluções em Tecnologia Jurídica

- 🌐 **Site**: [vancouvertec.com](https://vancouvertec.com)
- 📧 **Email**: contato@vancouvertec.com
- 💼 **LinkedIn**: [Vancouver Tec](https://linkedin.com/company/vancouver-tec)

---

<div align="center">
  <sub>Desenvolvido com ❤️ para modernizar a advocacia brasileira</sub>
  
  **⭐ Se este projeto foi útil, deixe uma estrela!**
</div>
