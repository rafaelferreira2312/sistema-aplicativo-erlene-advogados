#!/bin/bash

# Script 56 - Correção Completa do Tailwind CSS
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/56-corrigir-tailwind-completo.sh

echo "🎨 Corrigindo Tailwind CSS completamente..."

# 1. Criar postcss.config.js correto
cat > frontend/postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# 2. Corrigir tailwind.config.js
cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
    "./public/index.html"
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#fef2f2',
          100: '#fee2e2',
          200: '#fecaca',
          300: '#fca5a5',
          400: '#f87171',
          500: '#8B1538',
          600: '#7a1230',
          700: '#691028',
          800: '#580e20',
          900: '#470c18',
        },
        secondary: {
          50: '#fffbeb',
          100: '#fef3c7',
          200: '#fde68a',
          300: '#fcd34d',
          400: '#fbbf24',
          500: '#f5b041',
          600: '#e09f2d',
          700: '#d97706',
          800: '#92400e',
          900: '#78350f',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        'erlene': '0 4px 6px -1px rgba(139, 21, 56, 0.1), 0 2px 4px -1px rgba(139, 21, 56, 0.06)',
        'erlene-lg': '0 10px 15px -3px rgba(139, 21, 56, 0.1), 0 4px 6px -2px rgba(139, 21, 56, 0.05)',
      }
    },
  },
  plugins: [],
}
EOF

# 3. Corrigir craco.config.js para processar Tailwind corretamente
cat > frontend/craco.config.js << 'EOF'
const path = require('path');

module.exports = {
  webpack: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
      '@components': path.resolve(__dirname, 'src/components'),
      '@pages': path.resolve(__dirname, 'src/pages'),
      '@services': path.resolve(__dirname, 'src/services'),
      '@utils': path.resolve(__dirname, 'src/utils'),
      '@hooks': path.resolve(__dirname, 'src/hooks'),
      '@context': path.resolve(__dirname, 'src/context'),
      '@config': path.resolve(__dirname, 'src/config'),
      '@styles': path.resolve(__dirname, 'src/styles'),
      '@assets': path.resolve(__dirname, 'src/assets')
    }
  },
  style: {
    postcss: {
      mode: 'extends',
      loaderOptions: {
        postcssOptions: {
          ident: 'postcss',
          plugins: [
            require('tailwindcss'),
            require('autoprefixer'),
          ],
        },
      },
    },
  },
  devServer: {
    port: 3000,
    open: false,
    hot: true,
    historyApiFallback: true
  }
};
EOF

# 4. Sobrescrever index.css com importações corretas do Tailwind
cat > frontend/src/index.css << 'EOF'
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

/* Reset básico */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html, body {
  height: 100%;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#root {
  height: 100%;
}

/* Correção para ícones */
svg {
  width: 1.25rem;
  height: 1.25rem;
  flex-shrink: 0;
}

/* Componentes customizados */
@layer components {
  .btn {
    @apply inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 transition-all duration-200;
  }

  .btn-primary {
    @apply bg-red-600 text-white hover:bg-red-700 focus:ring-red-500;
  }

  .btn-secondary {
    @apply bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500;
  }

  .btn-outline {
    @apply bg-white text-red-600 border-red-600 hover:bg-red-50 focus:ring-red-500;
  }

  .card {
    @apply bg-white rounded-lg shadow border border-gray-200;
  }

  .input {
    @apply block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-red-500 focus:border-red-500 sm:text-sm;
  }
}

/* Utilities customizados */
@layer utilities {
  .bg-gradient-erlene {
    background: linear-gradient(135deg, #8B1538 0%, #A91E47 100%);
  }

  .shadow-erlene {
    box-shadow: 0 4px 6px -1px rgba(139, 21, 56, 0.1), 0 2px 4px -1px rgba(139, 21, 56, 0.06);
  }

  .text-primary {
    color: #8B1538;
  }

  .border-primary {
    border-color: #8B1538;
  }

  .bg-primary {
    background-color: #8B1538;
  }
}
EOF

# 5. Criar arquivo de teste para verificar se Tailwind está funcionando
cat > frontend/src/TestTailwind.js << 'EOF'
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
EOF

# 6. Modificar App.js temporariamente para testar
cat > frontend/src/App.js << 'EOF'
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/auth/AuthProvider';
import TestTailwind from './TestTailwind';
import Login from './pages/auth/Login';
import Dashboard from './pages/admin/Dashboard';

// Componente temporário para testar Tailwind
const TestPage = () => (
  <div className="min-h-screen bg-gray-50">
    <div className="bg-red-600 text-white p-4">
      <h1 className="text-2xl font-bold">Sistema Erlene Advogados</h1>
      <p>Teste do Tailwind CSS</p>
    </div>
    <div className="container mx-auto p-8">
      <div className="bg-white rounded-lg shadow-lg p-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Tailwind Funcionando!</h2>
        <p className="text-gray-600 mb-4">Se você está vendo este layout, o Tailwind está carregado corretamente.</p>
        <button className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition-colors">
          Botão de Teste
        </button>
      </div>
    </div>
  </div>
);

function App() {
  // Mostrar página de teste primeiro
  const showTest = window.location.search.includes('test');
  
  if (showTest) {
    return <TestTailwind />;
  }

  return (
    <AuthProvider>
      <Router>
        <div className="App">
          <Routes>
            <Route path="/" element={<Navigate to="/login" replace />} />
            <Route path="/login" element={<Login />} />
            <Route path="/admin" element={<Dashboard />} />
            <Route path="/test" element={<TestPage />} />
            <Route path="*" element={<Navigate to="/login" replace />} />
          </Routes>
        </div>
      </Router>
    </AuthProvider>
  );
}

export default App;
EOF

echo "✅ Tailwind CSS corrigido completamente!"
echo ""
echo "🔧 CORREÇÕES APLICADAS:"
echo "   • postcss.config.js criado corretamente"
echo "   • tailwind.config.js otimizado"
echo "   • craco.config.js configurado para processar Tailwind"
echo "   • index.css com importações @import corretas"
echo "   • Página de teste criada"
echo ""
echo "🧪 COMO TESTAR:"
echo "   1. Execute: npm start"
echo "   2. Acesse: http://localhost:3000?test"
echo "   3. Se ver layout estilizado = Tailwind funcionando"
echo "   4. Depois acesse: http://localhost:3000 (login normal)"
echo ""
echo "⚠️  Se ainda não funcionar, execute: npm install --force"