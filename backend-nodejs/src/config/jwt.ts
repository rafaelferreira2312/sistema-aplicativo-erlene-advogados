export const jwtConfig = {
  secret: process.env.JWT_SECRET || 'erlene_jwt_secret_default',
  expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  issuer: 'erlene-advogados-api',
  audience: 'erlene-advogados-frontend',
};

// Validar configuração JWT
if (!process.env.JWT_SECRET && process.env.NODE_ENV === 'production') {
  throw new Error('JWT_SECRET deve ser definido em produção');
}
