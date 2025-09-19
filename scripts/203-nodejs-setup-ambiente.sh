#!/bin/bash

# Script 203 - Setup Node.js + TypeScript - Ambiente Base
# Sistema Erlene Advogados - Migração Laravel → Node.js Express
# Data: $(date +%Y-%m-%d)
# EXECUTE NA PASTA RAIZ: sistema-aplicativo-erlene-advogados/

echo "🟢 Script 203 - Setup Node.js + TypeScript - Ambiente Base"
echo "========================================================"
echo "📦 Verificando Node.js e criando estrutura inicial"
echo "🕒 Iniciado em: $(date '+%Y-%m-%d %H:%M:%S')"

# Verificar se estamos no diretório correto
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ ERRO: Execute na pasta raiz do projeto!"
    echo "Comando correto:"
    echo "   cd sistema-aplicativo-erlene-advogados"
    echo "   chmod +x 203-nodejs-setup-ambiente.sh && ./203-nodejs-setup-ambiente.sh"
    exit 1
fi

echo "✅ Diretório correto confirmado"

# Backup do backend Laravel se necessário
if [ -d "backend-nodejs" ]; then
    echo "🔄 Fazendo backup do backend-nodejs existente..."
    mv "backend-nodejs" "backend-nodejs.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Criar diretório para Node.js
echo "📁 Criando diretório: backend-nodejs"
mkdir -p "backend-nodejs"
cd "backend-nodejs"

echo ""
echo "🔍 1. VERIFICANDO NODE.JS"
echo "========================"

# Verificar Node.js
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js encontrado: $NODE_VERSION"
    
    # Verificar versão mínima (18+)
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR" -ge 18 ]; then
        echo "✅ Versão adequada (18+)"
    else
        echo "⚠️  Versão muito antiga. Recomendado: 18+"
    fi
else
    echo "❌ Node.js não encontrado!"
    echo "📥 Instale Node.js 22 LTS: https://nodejs.org/"
    exit 1
fi

# Verificar npm
if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm encontrado: v$NPM_VERSION"
else
    echo "❌ npm não encontrado!"
    exit 1
fi

echo ""
echo "📦 2. CRIANDO PACKAGE.JSON"
echo "=========================="

cat > package.json << 'EOF'
{
  "name": "erlene-advogados-api",
  "version": "1.0.0",
  "description": "API Node.js Express - Sistema Erlene Advogados",
  "main": "dist/server.js",
  "scripts": {
    "dev": "nodemon src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "start:prod": "NODE_ENV=production node dist/server.js",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts",
    "test": "jest",
    "prisma:generate": "prisma generate",
    "prisma:push": "prisma db push",
    "prisma:migrate": "prisma migrate dev",
    "prisma:studio": "prisma studio",
    "db:seed": "ts-node src/database/seeders/index.ts"
  },
  "keywords": ["nodejs", "express", "typescript", "prisma", "jwt", "mysql"],
  "author": "Rafael Ferreira <rafaelferreira2312@gmail.com>",
  "license": "MIT",
  "dependencies": {
    "@prisma/client": "^5.6.0",
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "joi": "^17.11.0",
    "multer": "^1.4.5-lts.1",
    "compression": "^1.7.4",
    "express-rate-limit": "^7.1.5",
    "winston": "^3.11.0",
    "express-validator": "^7.0.1",
    "stripe": "^14.7.0",
    "axios": "^1.6.2",
    "moment": "^2.29.4",
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "@types/node": "^20.9.0",
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/morgan": "^1.9.9",
    "@types/bcryptjs": "^2.4.6",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/multer": "^1.4.11",
    "@types/compression": "^1.7.5",
    "@types/uuid": "^9.0.7",
    "typescript": "^5.2.2",
    "ts-node": "^10.9.1",
    "nodemon": "^3.0.1",
    "prisma": "^5.6.0",
    "@typescript-eslint/eslint-plugin": "^6.12.0",
    "@typescript-eslint/parser": "^6.12.0",
    "eslint": "^8.54.0",
    "prettier": "^3.1.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.8",
    "ts-jest": "^29.1.1",
    "supertest": "^6.3.3",
    "@types/supertest": "^2.0.16"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
EOF

echo "✅ package.json criado"

echo ""
echo "🔧 3. CONFIGURANDO TYPESCRIPT"
echo "============================"

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "sourceMap": true,
    "incremental": true,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "baseUrl": "./src",
    "paths": {
      "@/*": ["./*"],
      "@controllers/*": ["./controllers/*"],
      "@models/*": ["./models/*"],
      "@middleware/*": ["./middleware/*"],
      "@routes/*": ["./routes/*"],
      "@services/*": ["./services/*"],
      "@utils/*": ["./utils/*"],
      "@config/*": ["./config/*"],
      "@types/*": ["./types/*"]
    }
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "tests"
  ]
}
EOF

echo "✅ tsconfig.json configurado"

echo ""
echo "📋 4. CONFIGURANDO ESLINT E PRETTIER"
echo "=================================="

cat > .eslintrc.json << 'EOF'
{
  "parser": "@typescript-eslint/parser",
  "extends": [
    "eslint:recommended",
    "@typescript-eslint/recommended"
  ],
  "plugins": ["@typescript-eslint"],
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "rules": {
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/explicit-module-boundary-types": "off",
    "@typescript-eslint/no-explicit-any": "warn",
    "prefer-const": "error",
    "no-var": "error"
  },
  "env": {
    "node": true,
    "es2022": true
  }
}
EOF

cat > .prettierrc.json << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid",
  "endOfLine": "lf"
}
EOF

cat > .eslintignore << 'EOF'
node_modules/
dist/
build/
coverage/
*.js
*.d.ts
prisma/migrations/
EOF

echo "✅ ESLint e Prettier configurados"

echo ""
echo "📁 5. CRIANDO ESTRUTURA DE PASTAS"
echo "================================"

# Estrutura principal
mkdir -p src/{config,controllers,middleware,models,routes,services,utils,types,database}

# Controllers (baseado na análise Laravel)
mkdir -p src/controllers/{auth,admin,portal}
mkdir -p src/controllers/admin/{clients,processes,appointments,financial,documents,users,dashboard,integrations}

# Services
mkdir -p src/services/{auth,payment,integration,email,storage}
mkdir -p src/services/integration/{cnj,stripe,mercadopago}

# Database
mkdir -p src/database/{seeders,factories}

# Middleware
mkdir -p src/middleware/{auth,validation,error}

# Routes
mkdir -p src/routes/{auth,admin,portal}

# Utils
mkdir -p src/utils/{logger,validators,helpers}

# Config
mkdir -p src/config/{database,jwt,cors}

# Logs e uploads
mkdir -p logs uploads/{documents,temp}

# Tests
mkdir -p tests/{unit,integration}

echo "✅ Estrutura de pastas criada"

echo ""
echo "📄 6. CRIANDO ARQUIVOS BASE"
echo "=========================="

# .env de exemplo
cat > .env.example << 'EOF'
# Database
DATABASE_URL="mysql://root:password@localhost:3306/erlene_advogados"

# JWT
JWT_SECRET="seu_jwt_secret_aqui"
JWT_EXPIRES_IN="7d"

# App
NODE_ENV="development"
PORT=3001
APP_URL="http://localhost:3001"

# CORS
FRONTEND_URL="http://localhost:3000"

# Uploads
MAX_FILE_SIZE="10mb"
UPLOAD_PATH="./uploads"
EOF

# .gitignore
cat > .gitignore << 'EOF'
node_modules/
dist/
build/
coverage/
*.log
.env
.env.local
.env.production
uploads/
logs/
*.tgz
*.tar.gz
.DS_Store
.vscode/
.idea/
EOF

echo "✅ Arquivos base criados"

echo ""
echo "✅ AMBIENTE NODE.JS CONFIGURADO!"
echo "=============================="
echo "📁 Estrutura criada em: backend-nodejs/"
echo "📦 package.json com todas as dependências"
echo "🔧 TypeScript configurado"
echo "📋 ESLint + Prettier configurados"
echo "📁 Estrutura de pastas criada"
echo ""
echo "📋 Próximo script: 203a-nodejs-install-dependencies.sh"
echo "💡 Para continuar, digite: 'continuar'"