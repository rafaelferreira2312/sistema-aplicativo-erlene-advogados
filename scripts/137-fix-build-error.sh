#!/bin/bash

# Script 137 - Corrigir Erro de Build do Frontend
# Sistema Erlene Advogados - Fix package.json corruption
# Data: $(date +%Y-%m-%d)
# EXECUTE DENTRO DA PASTA: raiz do projeto

echo "🎯 Script 137 - Corrigindo erro de build do frontend..."

# Verificar se estamos na raiz do projeto
if [ ! -d "frontend" ] || [ ! -d "backend" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto (onde estão as pastas frontend/ e backend/)"
    exit 1
fi

# Fazer backup do package.json da raiz se existir
if [ -f "package.json" ]; then
    echo "📁 Backup do package.json da raiz..."
    cp package.json package.json.bak.137
    echo "✅ Backup criado: package.json.bak.137"
fi

# Verificar se o package.json da raiz está corrompido
echo "🔍 Verificando integridade do package.json da raiz..."
if [ -f "package.json" ]; then
    if ! python3 -m json.tool package.json > /dev/null 2>&1; then
        echo "⚠️  package.json da raiz está corrompido. Removendo..."
        rm package.json
        echo "✅ package.json corrompido removido"
    else
        echo "✅ package.json da raiz está válido"
    fi
fi

# Verificar se existe package-lock.json na raiz
if [ -f "package-lock.json" ]; then
    echo "🔍 Verificando package-lock.json da raiz..."
    if ! python3 -m json.tool package-lock.json > /dev/null 2>&1; then
        echo "⚠️  package-lock.json da raiz está corrompido. Removendo..."
        rm package-lock.json
        echo "✅ package-lock.json corrompido removido"
    fi
fi

# Entrar na pasta frontend
cd frontend

echo "🔍 Verificando estrutura do frontend..."

# Verificar se o package.json do frontend existe e está válido
if [ ! -f "package.json" ]; then
    echo "❌ Erro: package.json não encontrado no frontend"
    echo "📋 Execute primeiro o script de setup do frontend"
    exit 1
fi

# Validar JSON do frontend
echo "🔍 Validando package.json do frontend..."
if ! python3 -m json.tool package.json > /dev/null 2>&1; then
    echo "❌ Erro: package.json do frontend está corrompido"
    echo "🔧 Recriando package.json do frontend..."
    
    # Recriar package.json válido
    cat > package.json << 'EOF'
{
  "name": "sistema-erlene-advogados-frontend",
  "version": "1.0.0",
  "description": "Sistema de Gestão Jurídica - Erlene Advogados - Frontend React",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^14.4.3",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.1",
    "react-scripts": "5.0.1",
    "axios": "^1.3.4",
    "tailwindcss": "^3.2.7",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.21",
    "@headlessui/react": "^1.7.13",
    "@heroicons/react": "^2.0.16",
    "framer-motion": "^10.2.4",
    "react-hook-form": "^7.43.5",
    "react-query": "^3.39.3",
    "react-hot-toast": "^2.4.0",
    "date-fns": "^2.29.3",
    "recharts": "^2.5.0",
    "react-beautiful-dnd": "^13.1.1",
    "react-dropzone": "^14.2.3",
    "react-pdf": "^6.2.2",
    "socket.io-client": "^4.6.1",
    "js-cookie": "^3.0.1",
    "react-input-mask": "^2.0.4",
    "react-select": "^5.7.0",
    "react-datepicker": "^4.10.0",
    "react-calendar": "^4.0.0",
    "react-table": "^7.8.0"
  },
  "devDependencies": {
    "@types/js-cookie": "^3.0.3",
    "@types/react-beautiful-dnd": "^13.1.4",
    "@types/react-input-mask": "^3.0.2",
    "@types/react-table": "^7.7.14",
    "eslint": "^8.36.0",
    "eslint-config-prettier": "^8.7.0",
    "eslint-plugin-prettier": "^4.2.1",
    "prettier": "^2.8.4",
    "husky": "^8.0.3",
    "lint-staged": "^13.2.0",
    "@craco/craco": "^7.1.0"
  },
  "scripts": {
    "start": "craco start",
    "build": "craco build",
    "test": "craco test",
    "eject": "react-scripts eject",
    "lint": "eslint src --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint src --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write src/**/*.{js,jsx,ts,tsx,json,css,md}",
    "prepare": "husky install"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest",
      "prettier"
    ],
    "rules": {
      "no-console": "warn",
      "no-unused-vars": "warn",
      "prefer-const": "error"
    }
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "src/**/*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "src/**/*.{json,css,md}": [
      "prettier --write"
    ]
  }
}
EOF
    echo "✅ package.json do frontend recriado"
fi

# Limpar cache e node_modules se necessário
echo "🧹 Limpando cache e dependências..."
if [ -d "node_modules" ]; then
    echo "🗑️  Removendo node_modules antigo..."
    rm -rf node_modules
fi

if [ -f "package-lock.json" ]; then
    echo "🗑️  Removendo package-lock.json..."
    rm package-lock.json
fi

# Verificar se craco.config.js existe
if [ ! -f "craco.config.js" ]; then
    echo "🔧 Criando craco.config.js..."
    cat > craco.config.js << 'EOF'
const path = require('path');

module.exports = {
  webpack: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
      '@components': path.resolve(__dirname, 'src/components'),
      '@pages': path.resolve(__dirname, 'src/pages'),
      '@services': path.resolve(__dirname, 'src/services'),
      '@utils': path.resolve(__dirname, 'src/utils'),
      '@hooks': path.resolve(__dirname, 'src/hooks'),
      '@context': path.resolve(__dirname, 'src/context'),
      '@config': path.resolve(__dirname, 'src/config'),
      '@styles': path.resolve(__dirname, 'src/styles'),
      '@assets': path.resolve(__dirname, 'src/assets')
    }
  },
  style: {
    postcss: {
      plugins: [
        require('tailwindcss'),
        require('autoprefixer')
      ]
    }
  },
  devServer: {
    port: 3000,
    open: true,
    hot: true,
    historyApiFallback: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        secure: false
      }
    }
  }
};
EOF
    echo "✅ craco.config.js criado"
fi

# Reinstalar dependências
echo "📦 Reinstalando dependências..."
npm cache clean --force
npm install

echo "🧪 Testando build..."
echo "⏳ Executando build de teste (isso pode demorar alguns minutos)..."

# Tentar fazer o build
if npm run build; then
    echo "✅ Build executado com sucesso!"
    echo "📁 Arquivos de build gerados na pasta: frontend/build/"
    echo ""
    echo "📊 ESTATÍSTICAS DO BUILD:"
    if [ -d "build/static" ]; then
        echo "   📁 Pasta build/: $(du -sh build/ | cut -f1)"
        echo "   📦 Arquivos JS: $(find build/static/js -name '*.js' | wc -l) arquivos"
        echo "   🎨 Arquivos CSS: $(find build/static/css -name '*.css' | wc -l) arquivos"
        echo "   🖼️  Arquivos de mídia: $(find build/static/media -type f 2>/dev/null | wc -l) arquivos"
    fi
else
    echo "❌ Build ainda apresenta erros"
    echo "🔧 Tentativas adicionais de correção..."
    
    # Verificar se há problemas com CSS
    if [ -d "src" ]; then
        echo "🎨 Verificando arquivos CSS..."
        find src -name "*.css" -exec echo "📄 {}" \;
        
        # Verificar se há imports problemáticos
        echo "🔍 Verificando imports problemáticos..."
        if grep -r "import.*\.css" src/ --include="*.js" --include="*.jsx" 2>/dev/null; then
            echo "⚠️  Encontrados imports CSS. Verificando..."
        fi
    fi
    
    echo ""
    echo "💡 PRÓXIMOS PASSOS PARA DEBUG:"
    echo "   1. Execute: npm run build --verbose"
    echo "   2. Verifique os logs detalhados"
    echo "   3. Se necessário, execute o script 138-debug-build.sh"
fi

echo ""
echo "✅ Script 137 concluído!"
echo "📋 Próximo script: 138-debug-build-issues.sh (se ainda houver problemas)"