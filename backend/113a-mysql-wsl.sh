#!/bin/bash

# Script 113a-mysql - Instalar e configurar MySQL no WSL
# Sistema Erlene Advogados - MySQL WSL Setup
# Data: $(date +%Y-%m-%d)

echo "Configurando MySQL no WSL com usuário root e senha 12345678..."

echo "1. Instalando MySQL Server..."
sudo apt update
sudo apt install -y mysql-server mysql-client

echo "2. Iniciando serviço MySQL..."
sudo systemctl start mysql
sudo systemctl enable mysql

echo "3. Verificando status do MySQL..."
sudo systemctl status mysql --no-pager

echo "4. Configurando usuário root com senha 12345678..."

# Conectar como root e configurar senha
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '12345678';
FLUSH PRIVILEGES;
EXIT;
EOF

echo "5. Testando conexão com nova senha..."
mysql -u root -p12345678 -e "SELECT 'Conexão funcionando!' as status;"

if [ $? -eq 0 ]; then
    echo "Conexão MySQL funcionando!"
    
    echo "6. Criando banco erlene_advogados..."
    mysql -u root -p12345678 <<EOF
DROP DATABASE IF EXISTS erlene_advogados;
CREATE DATABASE erlene_advogados CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SHOW DATABASES;
EXIT;
EOF

    echo "7. Atualizando .env para localhost..."
    if [ -f ".env" ]; then
        sed -i 's/DB_HOST=.*/DB_HOST=localhost/' .env
        echo ".env atualizado para localhost"
    fi

    echo "8. Testando Laravel com MySQL..."
    if [ -f "artisan" ]; then
        php artisan migrate:status
        if [ $? -eq 0 ]; then
            echo "Laravel conectado com sucesso!"
            
            echo "9. Executando migrations..."
            php artisan migrate:fresh --seed
            
            echo "10. Verificando usuários criados..."
            mysql -u root -p12345678 erlene_advogados -e "SELECT id, name, email, role FROM users;"
            
        else
            echo "Erro na conexão Laravel. Verifique .env"
        fi
    fi
    
else
    echo "ERRO: Não foi possível configurar senha do MySQL"
    echo "Tente configurar manualmente:"
    echo "sudo mysql"
    echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '12345678';"
    echo "FLUSH PRIVILEGES;"
    echo "EXIT;"
fi

echo ""
echo "CONFIGURAÇÃO MYSQL WSL:"
echo "Host: localhost"
echo "Usuário: root" 
echo "Senha: 12345678"
echo "Banco: erlene_advogados"
echo ""
echo "Para iniciar MySQL no futuro:"
echo "sudo systemctl start mysql"
echo ""
echo "Para parar MySQL:"
echo "sudo systemctl stop mysql"