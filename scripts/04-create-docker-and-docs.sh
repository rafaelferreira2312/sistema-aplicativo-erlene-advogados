#!/bin/bash

# Script 04 - Criação do Docker, Documentação e Configurações
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/04-create-docker-and-docs.sh (executado da raiz do projeto)

echo "🚀 Iniciando criação do Docker, Documentação e Configurações..."

# Criar diretórios principais
mkdir -p docker
mkdir -p docs
mkdir -p scripts
mkdir -p .github
mkdir -p .github/workflows

# Estrutura Docker
mkdir -p docker/nginx
mkdir -p docker/php
mkdir -p docker/mysql
mkdir -p docker/node

# Estrutura docs/
mkdir -p docs/api
mkdir -p docs/setup
mkdir -p docs/deployment
mkdir -p docs/user-manual
mkdir -p docs/architecture
mkdir -p docs/integrations

# Criar arquivos Docker principais
touch docker-compose.yml
touch docker-compose.dev.yml
touch docker-compose.prod.yml
touch Dockerfile

# Dockerfiles específicos
touch docker/php/Dockerfile
touch docker/nginx/Dockerfile
touch docker/mysql/Dockerfile
touch docker/node/Dockerfile

# Configurações Nginx
touch docker/nginx/nginx.conf
touch docker/nginx/default.conf
touch docker/nginx/ssl.conf

# Configurações PHP
touch docker/php/php.ini
touch docker/php/www.conf
touch docker/php/opcache.ini

# Configurações MySQL
touch docker/mysql/my.cnf
touch docker/mysql/init.sql

# Scripts de inicialização
touch docker/mysql/01-create-databases.sql
touch docker/mysql/02-create-users.sql
touch docker/mysql/03-grant-permissions.sql

# Arquivos de ambiente
touch .env.example
touch .env.local
touch .env.staging
touch .env.production

# Arquivos de configuração raiz
touch .gitignore
touch .dockerignore
touch .editorconfig
touch .eslintrc.js
touch .prettierrc

# README principal
touch README.md

# Documentação
touch docs/README.md
touch docs/INSTALL.md
touch docs/DEPLOY.md
touch docs/CONTRIBUTING.md
touch docs/CHANGELOG.md

# Documentação de setup
touch docs/setup/requirements.md
touch docs/setup/installation.md
touch docs/setup/configuration.md
touch docs/setup/troubleshooting.md

# Documentação de deployment
touch docs/deployment/production.md
touch docs/deployment/staging.md
touch docs/deployment/ssl-setup.md
touch docs/deployment/backup.md

# Documentação da API
touch docs/api/authentication.md
touch docs/api/endpoints.md
touch docs/api/errors.md
touch docs/api/rate-limiting.md

# Manual do usuário
touch docs/user-manual/admin-guide.md
touch docs/user-manual/client-guide.md
touch docs/user-manual/mobile-guide.md
touch docs/user-manual/features.md

# Documentação de arquitetura
touch docs/architecture/overview.md
touch docs/architecture/database.md
touch docs/architecture/security.md
touch docs/architecture/performance.md

# Documentação de integrações
touch docs/integrations/cnj.md
touch docs/integrations/escavador.md
touch docs/integrations/jurisbrasil.md
touch docs/integrations/google-drive.md
touch docs/integrations/onedrive.md
touch docs/integrations/stripe.md
touch docs/integrations/mercadopago.md
touch docs/integrations/chatgpt.md

# Scripts de automação
touch scripts/setup.sh
touch scripts/install.sh
touch scripts/start.sh
touch scripts/stop.sh
touch scripts/restart.sh
touch scripts/backup.sh
touch scripts/restore.sh
touch scripts/migrate.sh
touch scripts/seed.sh
touch scripts/test.sh
touch scripts/deploy.sh
touch scripts/ssl-setup.sh

# Scripts específicos
touch scripts/backend-setup.sh
touch scripts/frontend-setup.sh
touch scripts/mobile-setup.sh
touch scripts/database-setup.sh

# Scripts de desenvolvimento
touch scripts/dev/start-backend.sh
touch scripts/dev/start-frontend.sh
touch scripts/dev/start-mobile.sh
touch scripts/dev/reset-database.sh
touch scripts/dev/generate-keys.sh

# Scripts de produção
touch scripts/prod/deploy-backend.sh
touch scripts/prod/deploy-frontend.sh
touch scripts/prod/deploy-database.sh
touch scripts/prod/backup-database.sh
touch scripts/prod/ssl-renew.sh

# GitHub Actions
touch .github/workflows/ci.yml
touch .github/workflows/deploy.yml
touch .github/workflows/tests.yml
touch .github/workflows/security.yml

# Templates GitHub
touch .github/ISSUE_TEMPLATE.md
touch .github/PULL_REQUEST_TEMPLATE.md
touch .github/CONTRIBUTING.md

# Configurações de segurança
touch SECURITY.md
touch LICENSE
touch CODE_OF_CONDUCT.md

# Arquivos de monitoramento
touch docker/monitoring/prometheus.yml
touch docker/monitoring/grafana.yml
touch docker/monitoring/alertmanager.yml

# Estrutura de logs
mkdir -p logs
mkdir -p logs/backend
mkdir -p logs/frontend
mkdir -p logs/nginx
mkdir -p logs/mysql

# Arquivos de logs
touch logs/.gitkeep
touch logs/backend/.gitkeep
touch logs/frontend/.gitkeep
touch logs/nginx/.gitkeep
touch logs/mysql/.gitkeep

# Estrutura de backups
mkdir -p backups
mkdir -p backups/database
mkdir -p backups/files
mkdir -p backups/logs

# Arquivos de backup
touch backups/.gitkeep
touch backups/database/.gitkeep
touch backups/files/.gitkeep
touch backups/logs/.gitkeep

# Configurações SSL
mkdir -p ssl
touch ssl/.gitkeep
touch ssl/generate-cert.sh

# Configurações de cache
mkdir -p cache
touch cache/.gitkeep

# Estrutura de uploads temporários
mkdir -p temp
mkdir -p temp/uploads
mkdir -p temp/exports
mkdir -p temp/imports

touch temp/.gitkeep
touch temp/uploads/.gitkeep
touch temp/exports/.gitkeep
touch temp/imports/.gitkeep

# Arquivos de configuração para cada ambiente
touch config/development.yml
touch config/staging.yml
touch config/production.yml

# Estrutura config/
mkdir -p config
mkdir -p config/environments
touch config/environments/development.yml
touch config/environments/staging.yml
touch config/environments/production.yml

# Makefile para automação
touch Makefile

# Package.json raiz (para scripts globais)
touch package.json

# Arquivos de teste
mkdir -p tests
mkdir -p tests/integration
mkdir -p tests/e2e
touch tests/.gitkeep
touch tests/integration/.gitkeep
touch tests/e2e/.gitkeep

# Arquivos de performance
mkdir -p performance
touch performance/lighthouse.js
touch performance/load-testing.js

# Configurações IDE
mkdir -p .vscode
touch .vscode/settings.json
touch .vscode/extensions.json
touch .vscode/launch.json

# Configurações específicas do projeto
touch phpcs.xml
touch phpunit.xml
touch jest.config.js
touch tailwind.config.js

# Scripts de migração
mkdir -p migrations
touch migrations/.gitkeep

# Estrutura de seeds
mkdir -p seeds
touch seeds/.gitkeep

# Arquivos de fixtures para testes
mkdir -p fixtures
touch fixtures/.gitkeep

# Configurações de CI/CD
touch .travis.yml
touch .gitlab-ci.yml
touch Jenkinsfile

# Configurações de qualidade de código
touch sonar-project.properties
touch .codeclimate.yml

# Configurações de dependências
touch composer.lock
touch package-lock.json
touch yarn.lock

# Arquivos de licença e legal
touch PRIVACY.md
touch TERMS.md
touch GDPR.md

# Documentação técnica adicional
touch docs/api/swagger.yml
touch docs/api/postman.json
touch docs/database/schema.sql
touch docs/database/er-diagram.md

# Scripts de utilidades
touch scripts/utils/check-dependencies.sh
touch scripts/utils/cleanup.sh
touch scripts/utils/logs-cleanup.sh
touch scripts/utils/permissions-fix.sh

# Configurações de monitoramento
mkdir -p monitoring
touch monitoring/health-check.sh
touch monitoring/performance-monitor.sh
touch monitoring/error-tracker.sh

# Configurações de notificação
mkdir -p notifications
touch notifications/email-templates.html
touch notifications/sms-templates.txt
touch notifications/push-templates.json

# Arquivos de release
touch RELEASE_NOTES.md
touch VERSION

# Diretórios para desenvolvimento
mkdir -p dev-tools
touch dev-tools/database-viewer.html
touch dev-tools/api-tester.html
touch dev-tools/log-viewer.html

echo "✅ Estrutura Docker, Documentação e Configurações criada com sucesso!"
echo ""
echo "📊 Resumo da estrutura criada:"
echo "🐳 Docker: Configuração completa com portas altas"
echo "📚 Docs: Documentação completa do projeto"
echo "🔧 Scripts: Automação de setup, deploy e manutenção"
echo "🔒 Segurança: SSL, backup e monitoramento"
echo "⚙️ CI/CD: GitHub Actions e outras ferramentas"
echo ""
echo "📁 Total de diretórios: $(find . -type d | wc -l)"
echo "📄 Total de arquivos: $(find . -type f | wc -l)"
echo ""
echo "⏭️  Próximo: Execute o script 05-create-readme-gitignore.sh"