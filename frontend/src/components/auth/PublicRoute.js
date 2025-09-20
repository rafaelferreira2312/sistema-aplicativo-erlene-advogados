import React from 'react';
import { useAuth } from '../../hooks/auth/useAuth';

const PublicRoute = ({ children }) => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  // Não redirecionar automaticamente - deixar o usuário decidir
  return children;
};

export default PublicRoute;
