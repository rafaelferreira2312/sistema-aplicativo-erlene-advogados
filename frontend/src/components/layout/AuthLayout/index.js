import React from 'react';

const AuthLayout = ({ children }) => {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center">
          <div className="mx-auto h-12 w-12 bg-gradient-erlene rounded-lg flex items-center justify-center mb-6">
            <span className="text-white font-bold text-xl">E</span>
          </div>
          <h1 className="text-2xl font-bold text-gray-900">
            Sistema Erlene Advogados
          </h1>
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow-erlene sm:rounded-lg sm:px-10">
          {children}
        </div>
      </div>

      <footer className="mt-8 text-center text-sm text-gray-500">
        <p>© 2024 Erlene Advogados. Todos os direitos reservados.</p>
        <p className="mt-1">Desenvolvido por Vancouver Tec</p>
      </footer>
    </div>
  );
};

export default AuthLayout;
