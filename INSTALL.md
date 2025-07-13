# 🚀 Instalação - Sistema Erlene Advogados

## Pré-requisitos

- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM mínimo
- 10GB espaço em disco

## Instalação Rápida

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/sistema-aplicativo-erlene-advogados.git
cd sistema-aplicativo-erlene-advogados

# 2. Execute o setup
make setup

# 3. Acesse o sistema
# API: https://localhost:8443
# Frontend: http://localhost:3000
```

## Comandos Disponíveis

```bash
make help      # Ver todos os comandos
make start     # Iniciar sistema
make stop      # Parar sistema  
make restart   # Reiniciar sistema
make backup    # Fazer backup
make test      # Executar testes
make health    # Verificar saúde
make logs      # Ver logs
make clean     # Limpar tudo
```

## Configuração das APIs

1. Edite o arquivo `.env`
2. Configure suas chaves de API:
   - Stripe (pagamentos)
   - Mercado Pago (PIX/Boleto)
   - Google Drive (documentos)
   - CNJ (tribunais)

## Usuário Padrão

- **Email**: admin@erleneadvogados.com.br
- **Senha**: admin123

## Troubleshooting

### Porta ocupada
```bash
# Alterar portas no docker-compose.yml
ports:
  - "8081:80"  # Mudar 8080 para 8081
```

### Erro de permissão
```bash
sudo chown -R $USER:$USER .
chmod -R 755 storage/
```

### Container não inicia
```bash
make logs      # Ver logs
make clean     # Limpar e tentar novamente
make setup
```
