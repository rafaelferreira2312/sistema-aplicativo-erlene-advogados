import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';
import routes from './routes';

// Carregar variáveis de ambiente
dotenv.config();

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3008;

// Middlewares de segurança
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// CORS configurado para desenvolvimento
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'https://erleneadvogados.vancouvertec.com'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Middlewares de parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
}

// Testar conexão com banco
app.use(async (req, res, next) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    next();
  } catch (error) {
    console.error('Erro de conexão com banco:', error);
    if (!res.headersSent) {
      res.status(500).json({
        success: false,
        message: 'Erro de conexão com banco de dados'
      });
    }
  }
});

// Rotas principais
app.use('/api', routes);

// Rota de health check
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Sistema Erlene Advogados - Backend Node.js',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    database: 'connected'
  });
});

// Rota raiz
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API Sistema Erlene Advogados',
    docs: '/api/health',
    auth: '/api/auth/health'
  });
});

// Middleware de erro global
app.use((error: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Erro não tratado:', error);
  
  if (!res.headersSent) {
    res.status(500).json({
      success: false,
      message: 'Erro interno do servidor',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Middleware para rotas não encontradas
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Rota não encontrada',
    path: req.originalUrl
  });
});

// Iniciar servidor
const server = app.listen(PORT, () => {
  console.log(`
🚀 Servidor Node.js rodando!
📍 URL: http://localhost:${PORT}
🔗 Health: http://localhost:${PORT}/health
🔐 Auth: http://localhost:${PORT}/api/auth/health
🌍 Environment: ${process.env.NODE_ENV || 'development'}
📅 Timestamp: ${new Date().toISOString()}
  `);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('Recebido SIGTERM, fechando servidor...');
  server.close(() => {
    console.log('Servidor fechado');
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  console.log('Recebido SIGINT, fechando servidor...');
  await prisma.$disconnect();
  server.close(() => {
    console.log('Servidor fechado');
    process.exit(0);
  });
});

export default app;
