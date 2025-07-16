#!/bin/bash

# Script 54 - Correção do index.css principal
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/54-corrigir-index-css.sh

echo "🎨 Corrigindo arquivo index.css principal..."

# Sobrescrever o index.css com estilos completos
cat > frontend/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Importar estilos globais */
@import './styles/globals.css';
@import './styles/components.css';

/* Reset e base styles */
*,
*::before,
*::after {
  box-sizing: border-box;
}

html {
  line-height: 1.15;
  -webkit-text-size-adjust: 100%;
}

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f9fafb;
  color: #374151;
  font-size: 14px;
  line-height: 1.5;
}

/* Correção para ícones Heroicons */
svg {
  width: 1.25rem !important;
  height: 1.25rem !important;
  flex-shrink: 0;
}

/* Tamanhos específicos para ícones */
.icon-xs svg { width: 0.75rem !important; height: 0.75rem !important; }
.icon-sm svg { width: 1rem !important; height: 1rem !important; }
.icon-md svg { width: 1.25rem !important; height: 1.25rem !important; }
.icon-lg svg { width: 1.5rem !important; height: 1.5rem !important; }
.icon-xl svg { width: 2rem !important; height: 2rem !important; }

/* Cores da identidade Erlene */
:root {
  --color-primary-50: #fef2f2;
  --color-primary-100: #fee2e2;
  --color-primary-500: #8B1538;
  --color-primary-600: #7a1230;
  --color-primary-700: #691028;
  --color-primary-800: #580e20;
  --color-primary-900: #470c18;
  
  --color-secondary-100: #fef3c7;
  --color-secondary-500: #f5b041;
  --color-secondary-600: #e09f2d;
  
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-300: #d1d5db;
  --color-gray-400: #9ca3af;
  --color-gray-500: #6b7280;
  --color-gray-600: #4b5563;
  --color-gray-700: #374151;
  --color-gray-800: #1f2937;
  --color-gray-900: #111827;
}

/* Layout base */
#root {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-container {
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* Botões base */
.btn {
  @apply inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 transition-all duration-200;
}

.btn-primary {
  @apply bg-red-600 text-white hover:bg-red-700 focus:ring-red-500;
  background-color: var(--color-primary-500);
}

.btn-primary:hover {
  background-color: var(--color-primary-600);
}

.btn-secondary {
  @apply bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500;
}

.btn-outline {
  @apply bg-white text-red-600 border-red-600 hover:bg-red-50 focus:ring-red-500;
  border-color: var(--color-primary-500);
  color: var(--color-primary-500);
}

.btn-ghost {
  @apply bg-transparent text-red-600 hover:bg-red-50 focus:ring-red-500;
  color: var(--color-primary-500);
}

/* Cards */
.card {
  @apply bg-white rounded-lg shadow border border-gray-200;
}

.card-hover {
  @apply hover:shadow-md transition-shadow duration-200 cursor-pointer;
}

/* Inputs */
.input {
  @apply block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-red-500 focus:border-red-500 sm:text-sm;
}

.input:focus {
  border-color: var(--color-primary-500);
  box-shadow: 0 0 0 1px var(--color-primary-500);
}

/* Modal overlay */
.modal-overlay {
  @apply fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50;
}

.modal-content {
  @apply relative top-20 mx-auto p-5 border w-11/12 max-w-md shadow-lg rounded-md bg-white;
}

/* Loading spinner */
.spinner {
  @apply animate-spin rounded-full border-b-2;
  border-color: var(--color-primary-500);
}

/* Badge */
.badge {
  @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium;
}

.badge-primary {
  @apply bg-red-100 text-red-800;
  background-color: var(--color-primary-100);
  color: var(--color-primary-800);
}

.badge-success {
  @apply bg-green-100 text-green-800;
}

.badge-warning {
  @apply bg-yellow-100 text-yellow-800;
}

.badge-danger {
  @apply bg-red-100 text-red-800;
}

/* Table */
.table {
  @apply min-w-full divide-y divide-gray-200;
}

.table-header {
  @apply px-6 py-3 bg-gray-50 text-left text-xs font-medium text-gray-500 uppercase tracking-wider;
}

.table-cell {
  @apply px-6 py-4 whitespace-nowrap text-sm text-gray-900;
}

/* Sidebar */
.sidebar {
  @apply h-full flex flex-col bg-white border-r border-gray-200;
}

.sidebar-nav {
  @apply flex-1 px-2 py-4 space-y-1;
}

.sidebar-nav-item {
  @apply group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-colors duration-150;
}

.sidebar-nav-item.active {
  @apply bg-red-100 text-red-900;
  background-color: var(--color-primary-100);
  color: var(--color-primary-900);
}

.sidebar-nav-item:hover {
  @apply bg-gray-50;
}

/* Header */
.header {
  @apply bg-white shadow-sm border-b border-gray-200;
}

/* Animations */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideIn {
  from { transform: translateX(-100%); }
  to { transform: translateX(0); }
}

.fade-in {
  animation: fadeIn 0.3s ease-out;
}

.slide-in {
  animation: slideIn 0.3s ease-out;
}

/* Responsive */
@media (max-width: 640px) {
  .sidebar {
    @apply fixed inset-y-0 left-0 z-50 w-64 transform -translate-x-full transition-transform duration-300 ease-in-out;
  }
  
  .sidebar.open {
    @apply translate-x-0;
  }
  
  .sidebar-overlay {
    @apply fixed inset-0 bg-gray-600 bg-opacity-75 z-40;
  }
}

/* Utilities */
.text-ellipsis {
  @apply truncate;
}

.shadow-erlene {
  box-shadow: 0 4px 6px -1px rgba(139, 21, 56, 0.1), 0 2px 4px -1px rgba(139, 21, 56, 0.06);
}

.shadow-erlene-lg {
  box-shadow: 0 10px 15px -3px rgba(139, 21, 56, 0.1), 0 4px 6px -2px rgba(139, 21, 56, 0.05);
}

.bg-gradient-erlene {
  background: linear-gradient(135deg, #8B1538 0%, #A91E47 100%);
}

/* Focus states */
.focus-visible:focus {
  outline: 2px solid var(--color-primary-500);
  outline-offset: 2px;
}

/* Print styles */
@media print {
  .no-print {
    display: none !important;
  }
}

/* High contrast mode */
@media (prefers-contrast: high) {
  .border-gray-200 {
    border-color: #000;
  }
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
EOF

echo "✅ index.css corrigido!"
echo ""
echo "🎯 PRINCIPAIS CORREÇÕES:"
echo "   • Importação correta do Tailwind CSS"
echo "   • Estilos base para HTML/body"
echo "   • Correção de tamanhos dos ícones Heroicons"
echo "   • Classes utilitárias para componentes"
echo "   • Cores da identidade Erlene como CSS variables"
echo "   • Reset de estilos e normalizações"
echo "   • Media queries responsivas"
echo ""
echo "⏭️  Execute 'npm start' para testar. Se ainda houver problemas visuais, digite 'continuar'."