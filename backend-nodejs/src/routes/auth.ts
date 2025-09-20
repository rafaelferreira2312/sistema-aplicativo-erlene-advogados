import { Router } from 'express';
import { AuthController } from '../controllers/AuthController';
import { authenticate, optionalAuth } from '../middleware/auth';

const router = Router();

// Rotas públicas
router.post('/login', AuthController.login);
router.post('/register', AuthController.register);

// Rotas protegidas
router.post('/logout', authenticate, AuthController.logout);
router.get('/me', authenticate, AuthController.me);
router.post('/change-password', authenticate, AuthController.changePassword);
router.post('/refresh-token', authenticate, AuthController.refreshToken);

// Health check para autenticação
router.get('/health', optionalAuth, (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Auth service is running',
    authenticated: !!req.user,
    timestamp: new Date().toISOString()
  });
});

export default router;
