import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../hooks/auth/useAuth';

const PublicRoute = ({ children }) => {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (isAuthenticated) {
    if (user?.perfil === 'cliente') {
      return <Navigate to="/portal" replace />;
    } else {
      return <Navigate to="/admin" replace />;
    }
  }

  return children;
};

export default PublicRoute;
