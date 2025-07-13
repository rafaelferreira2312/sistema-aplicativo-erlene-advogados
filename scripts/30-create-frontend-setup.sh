#!/bin/bash

# Script 30 - Setup do Frontend React (Parte 1)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/30-create-frontend-setup.sh (executado da raiz do projeto)

echo "🎨 Criando setup do Frontend React..."

# Package.json principal do frontend
cat > frontend/package.json << 'EOF'
{
  "name": "sistema-erlene-advogados-frontend",
  "version": "1.0.0",
  "description": "Sistema de Gestão Jurídica - Erlene Advogados - Frontend React",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^14.4.3",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.1",
    "react-scripts": "5.0.1",
    "axios": "^1.3.4",
    "tailwindcss": "^3.2.7",
    "autoprefixer": "^10.4.14",
    "postcss": "^8.4.21",
    "@headlessui/react": "^1.7.13",
    "@heroicons/react": "^2.0.16",
    "framer-motion": "^10.2.4",
    "react-hook-form": "^7.43.5",
    "react-query": "^3.39.3",
    "react-hot-toast": "^2.4.0",
    "date-fns": "^2.29.3",
    "recharts": "^2.5.0",
    "react-beautiful-dnd": "^13.1.1",
    "react-dropzone": "^14.2.3",
    "react-pdf": "^6.2.2",
    "socket.io-client": "^4.6.1",
    "js-cookie": "^3.0.1",
    "react-input-mask": "^2.0.4",
    "react-select": "^5.7.0",
    "react-datepicker": "^4.10.0",
    "react-calendar": "^4.0.0",
    "react-table": "^7.8.0"
  },
  "devDependencies": {
    "@types/js-cookie": "^3.0.3",
    "@types/react-beautiful-dnd": "^13.1.4",
    "@types/react-input-mask": "^3.0.2",
    "@types/react-table": "^7.7.14",
    "eslint": "^8.36.0",
    "eslint-config-prettier": "^8.7.0",
    "eslint-plugin-prettier": "^4.2.1",
    "prettier": "^2.8.4",
    "husky": "^8.0.3",
    "lint-staged": "^13.2.0",
    "@craco/craco": "^7.1.0"
  },
  "scripts": {
    "start": "craco start",
    "build": "craco build",
    "test": "craco test",
    "eject": "react-scripts eject",
    "lint": "eslint src --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint src --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write src/**/*.{js,jsx,ts,tsx,json,css,md}",
    "prepare": "husky install"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest",
      "prettier"
    ],
    "rules": {
      "no-console": "warn",
      "no-unused-vars": "warn",
      "prefer-const": "error"
    }
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "src/**/*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "src/**/*.{json,css,md}": [
      "prettier --write"
    ]
  },
  "proxy": "https://localhost:8443"
}
EOF

# Craco.config.js para configurações customizadas
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
      plugins: [
        require('tailwindcss'),
        require('autoprefixer')
      ]
    }
  },
  devServer: {
    port: 3000,
    open: true,
    hot: true,
    historyApiFallback: true,
    proxy: {
      '/api': {
        target: 'https://localhost:8443',
        changeOrigin: true,
        secure: false
      }
    }
  },
  jest: {
    configure: {
      moduleNameMapping: {
        '^@/(.*)$': '<rootDir>/src/$1',
        '^@components/(.*)$': '<rootDir>/src/components/$1',
        '^@pages/(.*)$': '<rootDir>/src/pages/$1',
        '^@services/(.*)$': '<rootDir>/src/services/$1',
        '^@utils/(.*)$': '<rootDir>/src/utils/$1',
        '^@hooks/(.*)$': '<rootDir>/src/hooks/$1',
        '^@context/(.*)$': '<rootDir>/src/context/$1'
      }
    }
  }
};
EOF

# Tailwind.config.js com tema da Erlene
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
        // Cores da identidade visual da Dra. Erlene
        primary: {
          50: '#fdf2f4',
          100: '#fce7ea',
          200: '#f9d0d9',
          300: '#f5a8ba',
          400: '#ee7395',
          500: '#e1456f',
          600: '#d02757',
          700: '#b01e47',
          800: '#8b1538', // Cor principal bordô
          900: '#7a1532',
          950: '#440a1a'
        },
        secondary: {
          50: '#fffdf0',
          100: '#fffbe1',
          200: '#fff7c2',
          300: '#ffee9e',
          400: '#ffe06e',
          500: '#f5b041', // Cor principal dourada
          600: '#e09c24',
          700: '#c7851c',
          800: '#a4691b',
          900: '#86561b',
          950: '#4a2c0a'
        },
        gray: {
          50: '#f8f9fa',
          100: '#e9ecef',
          200: '#dee2e6',
          300: '#ced4da',
          400: '#6c757d',
          500: '#495057',
          600: '#343a40',
          700: '#212529',
          800: '#1a1d20',
          900: '#151719'
        },
        success: {
          50: '#f0fdf4',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d'
        },
        warning: {
          50: '#fffbeb',
          500: '#f59e0b',
          600: '#d97706',
          700: '#b45309'
        },
        danger: {
          50: '#fef2f2',
          500: '#ef4444',
          600: '#dc2626',
          700: '#b91c1c'
        },
        info: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8'
        }
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        serif: ['ui-serif', 'Georgia', 'serif'],
        mono: ['ui-monospace', 'SFMono-Regular', 'monospace']
      },
      fontSize: {
        '2xs': '0.625rem',
        'xs': '0.75rem',
        'sm': '0.875rem',
        'base': '1rem',
        'lg': '1.125rem',
        'xl': '1.25rem',
        '2xl': '1.5rem',
        '3xl': '1.875rem',
        '4xl': '2.25rem',
        '5xl': '3rem',
        '6xl': '3.75rem'
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '100': '25rem',
        '120': '30rem'
      },
      maxWidth: {
        '8xl': '88rem',
        '9xl': '96rem'
      },
      minHeight: {
        'screen-75': '75vh',
        'screen-80': '80vh',
        'screen-90': '90vh'
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-in': 'slideIn 0.3s ease-out',
        'bounce-subtle': 'bounceSubtle 0.6s ease-in-out',
        'pulse-slow': 'pulse 3s ease-in-out infinite'
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' }
        },
        slideIn: {
          '0%': { transform: 'translateY(-10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' }
        },
        bounceSubtle: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-5px)' }
        }
      },
      boxShadow: {
        'erlene': '0 4px 20px rgba(139, 21, 56, 0.1)',
        'erlene-lg': '0 10px 40px rgba(139, 21, 56, 0.15)',
        'gold': '0 4px 20px rgba(245, 176, 65, 0.2)',
        'inner-erlene': 'inset 0 2px 4px rgba(139, 21, 56, 0.1)'
      },
      backdropBlur: {
        'xs': '2px'
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
    function({ addUtilities }) {
      addUtilities({
        '.text-gradient-erlene': {
          'background': 'linear-gradient(135deg, #8b1538 0%, #f5b041 100%)',
          '-webkit-background-clip': 'text',
          '-webkit-text-fill-color': 'transparent',
          'background-clip': 'text'
        },
        '.bg-gradient-erlene': {
          'background': 'linear-gradient(135deg, #8b1538 0%, #f5b041 100%)'
        },
        '.bg-gradient-erlene-reverse': {
          'background': 'linear-gradient(135deg, #f5b041 0%, #8b1538 100%)'
        }
      })
    }
  ]
}
EOF

# public/index.html
cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#8b1538" />
    <meta name="description" content="Sistema de Gestão Jurídica - Erlene Advogados" />
    
    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website" />
    <meta property="og:url" content="https://sistema.erleneadvogados.com.br/" />
    <meta property="og:title" content="Sistema Erlene Advogados" />
    <meta property="og:description" content="Sistema completo de gestão jurídica para escritórios de advocacia" />
    <meta property="og:image" content="%PUBLIC_URL%/og-image.png" />

    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image" />
    <meta property="twitter:url" content="https://sistema.erleneadvogados.com.br/" />
    <meta property="twitter:title" content="Sistema Erlene Advogados" />
    <meta property="twitter:description" content="Sistema completo de gestão jurídica para escritórios de advocacia" />
    <meta property="twitter:image" content="%PUBLIC_URL%/og-image.png" />

    <!-- Favicon -->
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    
    <!-- Preconnect para melhor performance -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    
    <!-- Inter Font -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- CSS Reset e base styles -->
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      
      html {
        font-family: 'Inter', ui-sans-serif, system-ui, -apple-system, sans-serif;
        line-height: 1.6;
        color: #212529;
      }
      
      body {
        background-color: #f8f9fa;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
      }
      
      #root {
        min-height: 100vh;
      }
      
      /* Loading spinner */
      .loading-spinner {
        display: inline-block;
        width: 20px;
        height: 20px;
        border: 3px solid rgba(139, 21, 56, 0.3);
        border-radius: 50%;
        border-top-color: #8b1538;
        animation: spin 1s ease-in-out infinite;
      }
      
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
      
      /* Scrollbar customizada */
      ::-webkit-scrollbar {
        width: 8px;
      }
      
      ::-webkit-scrollbar-track {
        background: #f1f1f1;
      }
      
      ::-webkit-scrollbar-thumb {
        background: #8b1538;
        border-radius: 4px;
      }
      
      ::-webkit-scrollbar-thumb:hover {
        background: #6d1129;
      }
    </style>
    
    <title>Sistema Erlene Advogados</title>
  </head>
  <body>
    <noscript>
      <div style="padding: 40px; text-align: center; background: #fff; margin: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
        <h2 style="color: #8b1538; margin-bottom: 16px;">JavaScript Required</h2>
        <p>Este sistema requer JavaScript para funcionar corretamente.</p>
        <p>Por favor, habilite o JavaScript em seu navegador e recarregue a página.</p>
      </div>
    </noscript>
    
    <div id="root">
      <!-- Loading inicial -->
      <div id="initial-loading" style="
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, #8b1538 0%, #f5b041 100%);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        color: white;
        font-family: 'Inter', sans-serif;
      ">
        <div style="text-align: center;">
          <div style="
            width: 60px;
            height: 60px;
            border: 4px solid rgba(255,255,255,0.3);
            border-radius: 50%;
            border-top-color: white;
            animation: spin 1s ease-in-out infinite;
            margin-bottom: 24px;
          "></div>
          <h2 style="font-size: 24px; font-weight: 600; margin-bottom: 8px;">
            Sistema Erlene Advogados
          </h2>
          <p style="font-size: 16px; opacity: 0.9;">
            Carregando sistema...
          </p>
        </div>
      </div>
    </div>
    
    <script>
      // Remover loading inicial quando React carregar
      window.addEventListener('load', function() {
        setTimeout(function() {
          const loading = document.getElementById('initial-loading');
          if (loading) {
            loading.style.opacity = '0';
            loading.style.transition = 'opacity 0.5s ease-out';
            setTimeout(() => loading.remove(), 500);
          }
        }, 1000);
      });
    </script>
  </body>
</html>
EOF

# Manifest.json para PWA
cat > frontend/public/manifest.json << 'EOF'
{
  "short_name": "Erlene Advogados",
  "name": "Sistema Erlene Advogados",
  "description": "Sistema de Gestão Jurídica para Escritórios de Advocacia",
  "icons": [
    {
      "src": "favicon.ico",
      "sizes": "64x64 32x32 24x24 16x16",
      "type": "image/x-icon"
    },
    {
      "src": "logo192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "logo512.png",
      "type": "image/png",
      "sizes": "512x512"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#8b1538",
  "background_color": "#ffffff",
  "orientation": "portrait-primary",
  "categories": ["business", "productivity", "legal"],
  "lang": "pt-BR",
  "dir": "ltr"
}
EOF

# robots.txt
cat > frontend/public/robots.txt << 'EOF'
User-agent: *
Disallow: /admin/
Disallow: /portal/
Disallow: /api/

Allow: /

Sitemap: https://sistema.erleneadvogados.com.br/sitemap.xml
EOF

# .gitignore para frontend
cat > frontend/.gitignore << 'EOF'
# Dependencies
/node_modules
/.pnp
.pnp.js

# Testing
/coverage

# Production
/build
/dist

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Temporary files
*.tmp
*.temp

# ESLint cache
.eslintcache

# Storybook
.storybook/
storybook-static/

# Bundle analysis
bundle-analyzer-report.html
EOF

echo "✅ Setup do Frontend React criado com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • frontend/package.json - Dependencies React 18 + libs"
echo "   • frontend/craco.config.js - Configurações personalizadas"
echo "   • frontend/tailwind.config.js - Tema da Erlene completo"
echo "   • frontend/public/index.html - HTML base otimizado"
echo "   • frontend/public/manifest.json - PWA configurado"
echo "   • frontend/public/robots.txt - SEO básico"
echo "   • frontend/.gitignore - Arquivos ignorados"
echo ""
echo "🎨 TEMA ERLENE CONFIGURADO:"
echo "   • Cores: primary-800 (#8b1538), secondary-500 (#f5b041)"
echo "   • Typography: Inter font"
echo "   • Gradientes: .text-gradient-erlene, .bg-gradient-erlene"
echo "   • Shadows: .shadow-erlene, .shadow-gold"
echo "   • Animations: fade-in, slide-in, bounce-subtle"
echo ""
echo "📦 DEPENDÊNCIAS INCLUÍDAS:"
echo "   • React 18 + Router + Hooks"
echo "   • Tailwind CSS + HeadlessUI + Heroicons"
echo "   • Axios + React Query"
echo "   • Framer Motion (animações)"
echo "   • React Hook Form (formulários)"
echo "   • Recharts (gráficos)"
echo "   • React Beautiful DND (kanban)"
echo "   • React Hot Toast (notificações)"
echo ""
echo "⏭️  Próximo: Scripts de criação dos componentes principais!"