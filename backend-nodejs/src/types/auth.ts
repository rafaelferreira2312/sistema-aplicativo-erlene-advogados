export interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'lawyer' | 'client';
  active: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  success: boolean;
  message: string;
  data?: {
    access_token: string;
    token_type: string;
    expires_in: number;
    user: {
      id: string;
      name: string;
      email: string;
      role: string;
      created_at: Date;
    };
  };
}

export interface RegisterRequest {
  name: string;
  email: string;
  password: string;
  role?: 'admin' | 'lawyer' | 'client';
}

export interface ChangePasswordRequest {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

export interface JWTPayload {
  userId: string;
  email: string;
  role: string;
  iat?: number;
  exp?: number;
}

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
    name: string;
  };
}
