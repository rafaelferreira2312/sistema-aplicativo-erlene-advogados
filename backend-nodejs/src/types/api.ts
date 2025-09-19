// Tipos para respostas da API
export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  details?: any;
}

export interface PaginationResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

// Tipos para request
export interface AuthRequest {
  email: string;
  password: string;
}

export interface ClientPortalRequest {
  cpf_cnpj: string;
  password: string;
}

// Tipos para usuário autenticado
export interface AuthUser {
  id: number;
  name: string;
  email: string;
  perfil: string;
  unidade_id?: number;
}

// Tipos para filtros
export interface BaseFilter {
  page?: number;
  limit?: number;
  search?: string;
  sort?: string;
  order?: 'asc' | 'desc';
}

export interface ClientFilter extends BaseFilter {
  unidade_id?: number;
  status?: string;
  tipo_pessoa?: string;
}

export interface ProcessFilter extends BaseFilter {
  cliente_id?: number;
  advogado_id?: number;
  unidade_id?: number;
  status?: string;
  tribunal?: string;
}
