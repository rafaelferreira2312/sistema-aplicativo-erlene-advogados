import React from 'react';

const TestTailwind = () => {
  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-red-600 mb-8">Teste Tailwind CSS</h1>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-white p-6 rounded-lg shadow-lg border">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">Card 1</h2>
            <p className="text-gray-600">Este é um teste do Tailwind CSS</p>
            <button className="mt-4 bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">
              Botão Teste
            </button>
          </div>
          
          <div className="bg-gradient-to-r from-red-500 to-red-600 p-6 rounded-lg shadow-lg text-white">
            <h2 className="text-xl font-semibold mb-4">Card 2</h2>
            <p>Gradiente funciona?</p>
          </div>
          
          <div className="bg-yellow-100 border-l-4 border-yellow-500 p-6 rounded">
            <h2 className="text-xl font-semibold text-yellow-800 mb-4">Card 3</h2>
            <p className="text-yellow-700">Cores e bordas</p>
          </div>
        </div>

        <div className="mt-8 p-4 bg-blue-50 border border-blue-200 rounded">
          <h3 className="text-lg font-medium text-blue-900">Status do Tailwind:</h3>
          <p className="text-blue-700">Se você está vendo este layout estilizado, o Tailwind está funcionando!</p>
        </div>
      </div>
    </div>
  );
};

export default TestTailwind;
