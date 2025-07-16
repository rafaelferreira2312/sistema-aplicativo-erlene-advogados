#!/bin/bash

# Script 58 - Criar Componentes Faltantes
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/58-corrigir-componentes-faltantes.sh

echo "🔧 Criando componentes faltantes..."

# 1. Criar ErrorBoundary que está faltando
cat > frontend/src/components/common/ErrorBoundary/index.js << 'EOF'
import React from 'react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-gray-900 mb-4">
              Algo deu errado
            </h1>
            <p className="text-gray-600 mb-4">
              Ocorreu um erro inesperado. Recarregue a página.
            </p>
            <button
              onClick={() => window.location.reload()}
              className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
            >
              Recarregar
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
EOF

# 2. Corrigir NotificationProvider definitivamente
cat > frontend/src/context/notification/NotificationProvider.js << 'EOF'
import React, { useState, useCallback } from 'react';
import { NotificationContext } from './NotificationContext';

export const NotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([]);

  // eslint-disable-next-line react-hooks/exhaustive-deps
  const removeNotification = useCallback((id) => {
    setNotifications(prev => prev.filter(notification => notification.id !== id));
  }, []);

  const addNotification = useCallback((notification) => {
    const id = Date.now() + Math.random();
    const newNotification = {
      id,
      type: 'info',
      duration: 5000,
      ...notification,
    };

    setNotifications(prev => [...prev, newNotification]);

    // Auto remove após duração especificada
    if (newNotification.duration > 0) {
      setTimeout(() => {
        removeNotification(id);
      }, newNotification.duration);
    }

    return id;
  }, [removeNotification]);

  const clearAllNotifications = useCallback(() => {
    setNotifications([]);
  }, []);

  const value = {
    notifications,
    addNotification,
    removeNotification,
    clearAllNotifications,
  };

  return (
    <NotificationContext.Provider value={value}>
      {children}
    </NotificationContext.Provider>
  );
};
EOF

# 3. Verificar se Modal existe, se não criar um simples
if [ ! -f "frontend/src/components/common/Modal/index.js" ]; then
cat > frontend/src/components/common/Modal/index.js << 'EOF'
import React from 'react';
import { XMarkIcon } from '@heroicons/react/24/outline';

const Modal = ({ 
  isOpen, 
  onClose, 
  title, 
  children, 
  size = 'medium',
  actions 
}) => {
  if (!isOpen) return null;

  const sizeClasses = {
    small: 'max-w-md',
    medium: 'max-w-lg',
    large: 'max-w-4xl',
    xl: 'max-w-6xl'
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-end justify-center px-4 pt-4 pb-20 text-center sm:block sm:p-0">
        {/* Overlay */}
        <div 
          className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
          onClick={onClose}
        />

        {/* Modal */}
        <div className={`inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:w-full ${sizeClasses[size]}`}>
          {/* Header */}
          {title && (
            <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium text-gray-900">
                  {title}
                </h3>
                <button
                  onClick={onClose}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <XMarkIcon className="h-6 w-6" />
                </button>
              </div>
            </div>
          )}

          {/* Content */}
          <div className="bg-white px-4 pt-5 pb-4 sm:p-6">
            {children}
          </div>

          {/* Actions */}
          {actions && (
            <div className="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
              {actions}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Modal;
EOF
fi

# 4. Verificar se Loading existe, se não criar um simples
if [ ! -f "frontend/src/components/common/Loading/index.js" ]; then
cat > frontend/src/components/common/Loading/index.js << 'EOF'
import React from 'react';

const Loading = ({ 
  size = 'medium', 
  text = 'Carregando...', 
  className = '' 
}) => {
  const sizeClasses = {
    small: 'h-4 w-4',
    medium: 'h-8 w-8',
    large: 'h-12 w-12'
  };

  return (
    <div className={`flex flex-col items-center justify-center ${className}`}>
      <div className={`animate-spin rounded-full border-b-2 border-red-600 ${sizeClasses[size]}`}></div>
      {text && (
        <p className="mt-2 text-sm text-gray-600">{text}</p>
      )}
    </div>
  );
};

export default Loading;
EOF
fi

# 5. Verificar se Table existe, se não criar um simples
if [ ! -f "frontend/src/components/common/Table/index.js" ]; then
cat > frontend/src/components/common/Table/index.js << 'EOF'
import React from 'react';

const Table = ({ 
  data = [], 
  columns = [], 
  onSort = () => {},
  sortBy = '',
  sortDirection = 'asc',
  emptyMessage = 'Nenhum dado encontrado'
}) => {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {columns.map((column) => (
              <th
                key={column.key}
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                onClick={() => column.sortable && onSort(column.key, sortDirection === 'asc' ? 'desc' : 'asc')}
              >
                {column.title}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {data.length === 0 ? (
            <tr>
              <td colSpan={columns.length} className="px-6 py-8 text-center text-gray-500">
                {emptyMessage}
              </td>
            </tr>
          ) : (
            data.map((item, index) => (
              <tr key={item.id || index} className="hover:bg-gray-50">
                {columns.map((column) => (
                  <td key={column.key} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {column.render ? column.render(item) : item[column.key]}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
};

export default Table;
EOF
fi

echo "✅ Componentes faltantes criados!"
echo ""
echo "📦 COMPONENTES CRIADOS:"
echo "   • ErrorBoundary - Captura erros React"
echo "   • Modal - Modal reutilizável"
echo "   • Loading - Componente de carregamento"
echo "   • Table - Tabela básica"
echo ""
echo "🔧 CORREÇÕES:"
echo "   • NotificationProvider: Hook useCallback corrigido definitivamente"
echo "   • Dependências ausentes resolvidas"
echo ""
echo "▶️ Execute 'npm start' - Deve compilar sem erros agora!"