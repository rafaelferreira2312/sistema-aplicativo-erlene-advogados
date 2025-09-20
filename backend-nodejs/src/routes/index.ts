import { Router } from 'express';
import authRoutes from './auth';

const router = Router();

// Registrar rotas de autenticação
router.use('/auth', authRoutes);

// Health check geral
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Sistema Erlene Advogados API - Node.js',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    services: {
      auth: 'active',
      database: 'connected'
    }
  });
});

// Rota de teste
router.get('/test', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API funcionando corretamente!',
    migration_status: 'Laravel → Node.js em progresso'
  });
});

export default router;
