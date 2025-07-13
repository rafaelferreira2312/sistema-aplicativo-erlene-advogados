.PHONY: help setup start stop restart backup test health logs clean

# Mostrar ajuda
help:
	@echo "🏛️  Sistema Erlene Advogados - Comandos disponíveis:"
	@echo ""
	@echo "  setup     - Setup inicial completo"
	@echo "  start     - Iniciar todos os serviços"
	@echo "  stop      - Parar todos os serviços"
	@echo "  restart   - Reiniciar todos os serviços"
	@echo "  backup    - Fazer backup completo"
	@echo "  test      - Executar todos os testes"
	@echo "  health    - Verificar saúde dos serviços"
	@echo "  logs      - Mostrar logs em tempo real"
	@echo "  clean     - Limpar containers e volumes"
	@echo "  shell     - Acessar shell do container PHP"
	@echo "  mysql     - Acessar MySQL"
	@echo ""

# Setup inicial
setup:
	@chmod +x scripts/*.sh
	@./scripts/setup.sh

# Iniciar serviços
start:
	@./scripts/start.sh

# Parar serviços
stop:
	@./scripts/stop.sh

# Reiniciar serviços
restart:
	@./scripts/restart.sh

# Backup
backup:
	@./scripts/backup.sh

# Testes
test:
	@./scripts/test.sh

# Health check
health:
	@./scripts/health-check.sh

# Logs em tempo real
logs:
	@docker-compose logs -f

# Logs específicos
logs-php:
	@docker-compose logs -f php

logs-nginx:
	@docker-compose logs -f nginx

logs-mysql:
	@docker-compose logs -f mysql

# Limpar tudo
clean:
	@docker-compose down -v --remove-orphans
	@docker system prune -f

# Acessar shell do PHP
shell:
	@docker-compose exec php bash

# Acessar MySQL
mysql:
	@docker-compose exec mysql mysql -u erlene_user -p erlene_advogados

# Laravel Artisan
artisan:
	@docker-compose exec php php artisan $(cmd)

# Composer
composer:
	@docker-compose exec php composer $(cmd)

# NPM Frontend
npm:
	@docker-compose exec node npm $(cmd)
