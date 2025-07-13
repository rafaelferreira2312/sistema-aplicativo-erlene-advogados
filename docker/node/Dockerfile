FROM node:18-alpine

# Instalar dependências
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++

# Configurar usuário
RUN addgroup -g 1001 -S nodejs \
    && adduser -S react -u 1001

# Definir diretório de trabalho
WORKDIR /app

# Copiar package files
COPY frontend/package*.json ./

# Instalar dependências
RUN npm ci --only=production

# Copiar código da aplicação
COPY --chown=react:nodejs frontend/ ./

# Mudar para usuário react
USER react

# Build da aplicação
RUN npm run build

# Expor porta
EXPOSE 3000

# Comando de inicialização
CMD ["npm", "start"]
