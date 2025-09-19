export interface JwtPayload {
  id: number;
  email: string;
  name: string;
  perfil: string;
  unidade_id?: number;
  iat?: number;
  exp?: number;
  iss?: string;
  aud?: string;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data: {
    user: AuthUser;
    token: string;
    expires_in: string;
  };
}

export interface AuthUser {
  id: number;
  name: string;
  email: string;
  perfil: string;
  unidade_id?: number;
  status: string;
  ultimo_acesso?: Date;
}

// Tipos para middleware de autenticação
declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}
