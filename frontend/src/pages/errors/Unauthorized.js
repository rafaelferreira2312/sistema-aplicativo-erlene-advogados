import React from 'react';
import { Link } from 'react-router-dom';

const Unauthorized = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-9xl font-bold text-gray-200">403</h1>
        <h2 className="text-2xl font-bold text-gray-900 mt-4">Acesso Negado</h2>
        <p className="text-gray-600 mt-2">Você não tem permissão para acessar esta página.</p>
        <Link
          to="/admin"
          className="mt-4 inline-block bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        >
          Voltar ao Dashboard
        </Link>
      </div>
    </div>
  );
};

export default Unauthorized;
