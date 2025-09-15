#!/bin/bash

# Atualização Rápida para Locaweb
# Sistema Erlene Advogados - Update Frontend + Backend
# EXECUTE DENTRO DA PASTA: raiz do projeto

echo "⚡ Atualização Rápida - Sistema Erlene Advogados"

# Verificar se estamos na raiz do projeto
if [ ! -d "frontend" ] || [ ! -d "backend" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Configurações
PROD_FTP_HOST="ftp.erleneadvogados.com.br"
PROD_FTP_USER="erleneadvogados1"
PROD_FTP_PASS="Erlene@2025@#!"

echo "🔄 OPÇÕES DE ATUALIZAÇÃO:"
echo "1) 🎨 Apenas Frontend"
echo "2) ⚙️  Apenas Backend"  
echo "3) 🗄️  Apenas Banco de Dados"
echo "4) 🎯 Frontend + Backend"
echo "5) 🚀 Tudo (Frontend + Backend + Banco)"
echo ""
read -p "Escolha uma opção (1-5): " OPTION

case $OPTION in
    1) UPDATE_FRONTEND=true; UPDATE_BACKEND=false; UPDATE_DB=false ;;
    2) UPDATE_FRONTEND=false; UPDATE_BACKEND=true; UPDATE_DB=false ;;
    3) UPDATE_FRONTEND=false; UPDATE_BACKEND=false; UPDATE_DB=true ;;
    4) UPDATE_FRONTEND=true; UPDATE_BACKEND=true; UPDATE_DB=false ;;
    5) UPDATE_FRONTEND=true; UPDATE_BACKEND=true; UPDATE_DB=true ;;
    *) echo "❌ Opção inválida"; exit 1 ;;
esac

echo ""

# ATUALIZAR FRONTEND
if [ "$UPDATE_FRONTEND" = true ]; then
    echo "🎨 ATUALIZANDO FRONTEND"
    echo "======================"
    
    cd frontend
    
    # Verificar se precisa rebuildar
    if [ ! -d "build" ] || [ "$(find src -newer build -type f 2>/dev/null | wc -l)" -gt 0 ]; then
        echo "🏗️  Rebuilding frontend..."
        rm -rf build
        export NODE_OPTIONS="--max-old-space-size=4096"
        npm run build
    else
        echo "✅ Build já atualizado"
    fi
    
    # Upload
    echo "📤 Enviando frontend..."
    lftp -u $PROD_FTP_USER,$PROD_FTP_PASS $PROD_FTP_HOST << EOF
set ftp:ssl-allow no
cd /public_html/sistema
rm -rf *
lcd build
mirror -R --delete . .
quit
EOF
    
    echo "✅ Frontend atualizado!"
    cd ..
fi

# ATUALIZAR BACKEND  
if [ "$UPDATE_BACKEND" = true ]; then
    echo ""
    echo "⚙️  ATUALIZANDO BACKEND"
    echo "======================"
    
    cd backend
    
    # Re-otimizar se necessário
    echo "⚡ Re-otimizando Laravel..."
    php artisan config:cache
    php artisan route:cache
    
    # Upload arquivos modificados
    echo "📤 Enviando backend..."
    lftp -u $PROD_FTP_USER,$PROD_FTP_PASS $PROD_FTP_HOST << EOF
set ftp:ssl-allow no
cd /public_html/api

# Upload pastas principais
mirror -R --delete app
mirror -R --delete config
mirror -R --delete routes  
mirror -R --delete resources

quit
EOF
    
    echo "✅ Backend atualizado!"
    cd ..
fi

# ATUALIZAR BANCO
if [ "$UPDATE_DB" = true ]; then
    echo ""
    echo "🗄️  ATUALIZANDO BANCO DE DADOS"
    echo "=============================="
    
    cd backend
    
    # Verificar novas migrations
    if [ "$(find database/migrations -name '*.php' -newer ../last_update 2>/dev/null | wc -l)" -gt 0 ]; then
        echo "🆕 Novas migrations detectadas!"
        
        # Exportar banco
        if [ -f ".env" ]; then
            LOCAL_DB=$(grep "DB_DATABASE=" .env | cut -d'=' -f2)
            LOCAL_USER=$(grep "DB_USERNAME=" .env | cut -d'=' -f2)
            LOCAL_PASS=$(grep "DB_PASSWORD=" .env | cut -d'=' -f2)
            
            if [ -n "$LOCAL_DB" ]; then
                echo "📤 Exportando banco atualizado..."
                
                if [ -n "$LOCAL_PASS" ] && [ "$LOCAL_PASS" != "null" ]; then
                    mysqldump -u$LOCAL_USER -p$LOCAL_PASS --single-transaction $LOCAL_DB > update_database.sql
                else
                    mysqldump -u$LOCAL_USER --single-transaction $LOCAL_DB > update_database.sql
                fi
                
                # Upload
                lftp -u $PROD_FTP_USER,$PROD_FTP_PASS $PROD_FTP_HOST << EOF
set ftp:ssl-allow no
cd /public_html/api
put update_database.sql
quit
EOF
                
                echo "✅ Banco atualizado enviado!"
                rm update_database.sql
            fi
        fi
    else
        echo "ℹ️  Nenhuma nova migration encontrada"
    fi
    
    cd ..
fi

# Marcar timestamp da atualização
touch last_update

echo ""
echo "✅ ATUALIZAÇÃO CONCLUÍDA!"
echo "========================"

echo ""
echo "🌐 URLs para teste:"
echo "   Frontend: https://erleneadvogados.com.br/sistema"
echo "   Backend:  https://erleneadvogados.com.br/api"

if [ "$UPDATE_DB" = true ]; then
    echo ""
    echo "📋 AÇÃO MANUAL:"
    echo "   Importe o arquivo update_database.sql via phpMyAdmin"
fi

echo ""
echo "⏱️  Última atualização: $(date)"
echo "💡 Para deploy completo, use: ./deploy-locaweb.sh"