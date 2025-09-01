#!/bin/bash

# Script 113a-fix - Corrigir conexão WSL com MySQL Windows
# Sistema Erlene Advogados - WSL Database Fix
# Data: $(date +%Y-%m-%d)

echo "Corrigindo conexão WSL com MySQL Windows..."

# Verificar se estamos no diretório correto
if [ ! -f "artisan" ]; then
    echo "Erro: Execute no diretório backend/"
    exit 1
fi

echo "1. Detectando IP do Windows host..."

# Obter IP do Windows a partir do WSL
WINDOWS_HOST=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
echo "IP do Windows detectado: $WINDOWS_HOST"

echo "2. Testando conexão MySQL..."

# Testar conexão com MySQL no Windows
nc -z $WINDOWS_HOST 3306
if [ $? -eq 0 ]; then
    echo "Conexão MySQL disponível no Windows"
else
    echo "ERRO: MySQL não acessível. Verifique:"
    echo "1. MySQL está rodando no Windows"
    echo "2. Firewall permite conexões na porta 3306"
    echo "3. MySQL configurado para aceitar conexões externas"
fi

echo "3. Atualizando .env para usar IP do Windows..."

# Fazer backup do .env
cp .env .env.backup

# Atualizar host do banco
sed -i "s/DB_HOST=localhost/DB_HOST=$WINDOWS_HOST/" .env
sed -i "s/DB_HOST=127.0.0.1/DB_HOST=$WINDOWS_HOST/" .env

echo "4. Configurações atualizadas:"
grep "DB_" .env

echo "5. Testando conexão Laravel..."

# Testar conexão do Laravel
php artisan migrate:status 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Conexão funcionando!"
    
    echo "6. Executando migrations..."
    php artisan migrate:fresh --seed
    
    echo "7. Testando usuários criados..."
    php artisan tinker --execute="echo 'Usuários: ' . App\Models\User::count();"
    
else
    echo "ERRO: Conexão ainda não funciona."
    echo ""
    echo "SOLUÇÕES ALTERNATIVAS:"
    echo ""
    echo "OPÇÃO 1 - Instalar MySQL no WSL:"
    echo "sudo apt update"
    echo "sudo apt install mysql-server"
    echo "sudo mysql_secure_installation"
    echo "sudo service mysql start"
    echo "mysql -u root -p"
    echo "CREATE DATABASE erlene_advogados;"
    echo ""
    echo "OPÇÃO 2 - Configurar MySQL Windows:"
    echo "1. Editar my.cnf/my.ini"
    echo "2. bind-address = 0.0.0.0"
    echo "3. Reiniciar MySQL"
    echo "4. GRANT ALL ON erlene_advogados.* TO 'root'@'%';"
    echo ""
    echo "OPÇÃO 3 - Usar SQLite (mais simples):"
    echo "Executar script 113a-sqlite"
fi

echo ""
echo "CONFIGURAÇÃO ATUAL:"
echo "Windows Host: $WINDOWS_HOST"
echo "Banco: erlene_advogados"
echo "Usuário: root"
echo "Porta: 3306"