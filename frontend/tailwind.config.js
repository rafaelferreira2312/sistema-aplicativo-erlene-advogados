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
