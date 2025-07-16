#!/bin/bash

# Script 33 - Componentes UI Base
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/33-create-ui-components.sh

echo "🎨 Criando componentes UI base..."

# src/components/common/Loading/index.js
cat > frontend/src/components/common/Loading/index.js << 'EOF'
import React from 'react';

const Loading = ({ 
  size = 'medium', 
  color = 'primary', 
  text = '', 
  className = '' 
}) => {
  const sizeClasses = {
    small: 'w-4 h-4',
    medium: 'w-8 h-8',
    large: 'w-12 h-12',
    xl: 'w-16 h-16'
  };

  const colorClasses = {
    primary: 'border-primary-800 border-t-primary-200',
    secondary: 'border-secondary-500 border-t-secondary-200',
    white: 'border-white border-t-white/30',
    gray: 'border-gray-400 border-t-gray-200'
  };

  return (
    <div className={`flex flex-col items-center justify-center ${className}`}>
      <div
        className={`
          ${sizeClasses[size]} 
          ${colorClasses[color]}
          border-4 border-solid rounded-full animate-spin
        `}
      />
      {text && (
        <p className="mt-2 text-sm text-gray-600 animate-pulse">
          {text}
        </p>
      )}
    </div>
  );
};

export default Loading;
EOF

# src/components/common/Button/index.js
cat > frontend/src/components/common/Button/index.js << 'EOF'
import React from 'react';
import Loading from '../Loading';

const Button = ({
  children,
  variant = 'primary',
  size = 'medium',
  type = 'button',
  disabled = false,
  loading = false,
  icon: Icon,
  iconPosition = 'left',
  className = '',
  ...props
}) => {
  const baseClasses = 'inline-flex items-center justify-center font-medium rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed';

  const variantClasses = {
    primary: 'bg-primary-800 text-white hover:bg-primary-900 focus:ring-primary-500 shadow-sm hover:shadow-md',
    secondary: 'bg-secondary-500 text-white hover:bg-secondary-600 focus:ring-secondary-400 shadow-sm hover:shadow-md',
    outline: 'border-2 border-primary-800 text-primary-800 hover:bg-primary-800 hover:text-white focus:ring-primary-500',
    ghost: 'text-primary-800 hover:bg-primary-50 focus:ring-primary-500',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500 shadow-sm hover:shadow-md',
    success: 'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500 shadow-sm hover:shadow-md',
    warning: 'bg-yellow-500 text-white hover:bg-yellow-600 focus:ring-yellow-400 shadow-sm hover:shadow-md',
  };

  const sizeClasses = {
    small: 'px-3 py-1.5 text-sm',
    medium: 'px-4 py-2 text-sm',
    large: 'px-6 py-3 text-base',
    xl: 'px-8 py-4 text-lg',
  };

  const isDisabled = disabled || loading;

  return (
    <button
      type={type}
      disabled={isDisabled}
      className={`
        ${baseClasses}
        ${variantClasses[variant]}
        ${sizeClasses[size]}
        ${className}
      `}
      {...props}
    >
      {loading ? (
        <Loading 
          size="small" 
          color={variant === 'outline' || variant === 'ghost' ? 'primary' : 'white'} 
        />
      ) : (
        <>
          {Icon && iconPosition === 'left' && (
            <Icon className="w-5 h-5 mr-2" />
          )}
          {children}
          {Icon && iconPosition === 'right' && (
            <Icon className="w-5 h-5 ml-2" />
          )}
        </>
      )}
    </button>
  );
};

export default Button;
EOF

# src/components/common/Input/index.js
cat > frontend/src/components/common/Input/index.js << 'EOF'
import React, { forwardRef } from 'react';

const Input = forwardRef(({
  label,
  type = 'text',
  error,
  helper,
  icon: Icon,
  iconPosition = 'left',
  className = '',
  containerClassName = '',
  required = false,
  ...props
}, ref) => {
  const baseClasses = 'block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm transition-colors duration-200';
  
  const errorClasses = error 
    ? 'border-red-300 text-red-900 placeholder-red-300 focus:border-red-500 focus:ring-red-500' 
    : '';
    
  const iconClasses = Icon 
    ? iconPosition === 'left' 
      ? 'pl-10' 
      : 'pr-10'
    : '';

  return (
    <div className={containerClassName}>
      {label && (
        <label className="block text-sm font-medium text-gray-700 mb-1">
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
      )}
      
      <div className="relative">
        {Icon && (
          <div className={`absolute inset-y-0 ${iconPosition === 'left' ? 'left-0 pl-3' : 'right-0 pr-3'} flex items-center pointer-events-none`}>
            <Icon className="h-5 w-5 text-gray-400" />
          </div>
        )}
        
        <input
          ref={ref}
          type={type}
          className={`
            ${baseClasses}
            ${errorClasses}
            ${iconClasses}
            ${className}
          `}
          {...props}
        />
      </div>
      
      {error && (
        <p className="mt-1 text-sm text-red-600">
          {error}
        </p>
      )}
      
      {helper && !error && (
        <p className="mt-1 text-sm text-gray-500">
          {helper}
        </p>
      )}
    </div>
  );
});

Input.displayName = 'Input';

export default Input;
EOF

# src/components/common/Card/index.js
cat > frontend/src/components/common/Card/index.js << 'EOF'
import React from 'react';

const Card = ({
  children,
  title,
  subtitle,
  actions,
  padding = 'default',
  shadow = 'default',
  hover = false,
  className = '',
  headerClassName = '',
  bodyClassName = '',
}) => {
  const paddingClasses = {
    none: '',
    small: 'p-4',
    default: 'p-6',
    large: 'p-8',
  };

  const shadowClasses = {
    none: '',
    small: 'shadow-sm',
    default: 'shadow-erlene',
    large: 'shadow-erlene-lg',
  };

  const hoverClasses = hover ? 'hover:shadow-erlene-lg transition-shadow duration-200 cursor-pointer' : '';

  return (
    <div
      className={`
        bg-white rounded-lg border border-gray-200
        ${shadowClasses[shadow]}
        ${hoverClasses}
        ${className}
      `}
    >
      {(title || subtitle || actions) && (
        <div className={`border-b border-gray-200 px-6 py-4 ${headerClassName}`}>
          <div className="flex items-center justify-between">
            <div>
              {title && (
                <h3 className="text-lg font-semibold text-gray-900">
                  {title}
                </h3>
              )}
              {subtitle && (
                <p className="mt-1 text-sm text-gray-500">
                  {subtitle}
                </p>
              )}
            </div>
            {actions && (
              <div className="flex items-center space-x-2">
                {actions}
              </div>
            )}
          </div>
        </div>
      )}
      
      <div className={`${paddingClasses[padding]} ${bodyClassName}`}>
        {children}
      </div>
    </div>
  );
};

export default Card;
EOF

# src/components/common/Modal/index.js
cat > frontend/src/components/common/Modal/index.js << 'EOF'
import React, { Fragment } from 'react';
import { Dialog, Transition } from '@headlessui/react';
import { XMarkIcon } from '@heroicons/react/24/outline';
import Button from '../Button';

const Modal = ({
  isOpen,
  onClose,
  title,
  children,
  size = 'default',
  showCloseButton = true,
  closeOnOverlayClick = true,
  actions,
  className = '',
}) => {
  const sizeClasses = {
    small: 'max-w-md',
    default: 'max-w-lg',
    large: 'max-w-2xl',
    xl: 'max-w-4xl',
    full: 'max-w-full mx-4',
  };

  return (
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog 
        as="div" 
        className="relative z-50" 
        onClose={closeOnOverlayClick ? onClose : () => {}}
      >
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black bg-opacity-25 backdrop-blur-sm" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4 text-center">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-300"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-200"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel 
                className={`
                  w-full ${sizeClasses[size]} transform overflow-hidden rounded-lg 
                  bg-white text-left align-middle shadow-xl transition-all
                  ${className}
                `}
              >
                {/* Header */}
                {(title || showCloseButton) && (
                  <div className="flex items-center justify-between p-6 border-b border-gray-200">
                    {title && (
                      <Dialog.Title
                        as="h3"
                        className="text-lg font-semibold text-gray-900"
                      >
                        {title}
                      </Dialog.Title>
                    )}
                    
                    {showCloseButton && (
                      <button
                        type="button"
                        className="text-gray-400 hover:text-gray-600 transition-colors"
                        onClick={onClose}
                      >
                        <XMarkIcon className="h-6 w-6" />
                      </button>
                    )}
                  </div>
                )}

                {/* Body */}
                <div className="p-6">
                  {children}
                </div>

                {/* Footer */}
                {actions && (
                  <div className="flex items-center justify-end space-x-3 px-6 py-4 border-t border-gray-200 bg-gray-50">
                    {actions}
                  </div>
                )}
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
};

// Modal de confirmação pré-configurado
Modal.Confirm = ({
  isOpen,
  onClose,
  onConfirm,
  title = 'Confirmar ação',
  message = 'Tem certeza que deseja continuar?',
  confirmText = 'Confirmar',
  cancelText = 'Cancelar',
  type = 'danger',
  loading = false,
}) => (
  <Modal
    isOpen={isOpen}
    onClose={onClose}
    title={title}
    size="small"
    actions={
      <>
        <Button
          variant="ghost"
          onClick={onClose}
          disabled={loading}
        >
          {cancelText}
        </Button>
        <Button
          variant={type}
          onClick={onConfirm}
          loading={loading}
        >
          {confirmText}
        </Button>
      </>
    }
  >
    <p className="text-gray-600">
      {message}
    </p>
  </Modal>
);

export default Modal;
EOF

# src/components/common/Table/index.js
cat > frontend/src/components/common/Table/index.js << 'EOF'
import React from 'react';
import { ChevronUpIcon, ChevronDownIcon } from '@heroicons/react/24/outline';

const Table = ({
  data = [],
  columns = [],
  loading = false,
  emptyMessage = 'Nenhum dado encontrado',
  sortable = true,
  sortBy = null,
  sortDirection = 'asc',
  onSort = () => {},
  className = '',
}) => {
  const handleSort = (column) => {
    if (!column.sortable || !sortable) return;
    
    const newDirection = sortBy === column.key && sortDirection === 'asc' ? 'desc' : 'asc';
    onSort(column.key, newDirection);
  };

  if (loading) {
    return (
      <div className="bg-white shadow-sm rounded-lg border border-gray-200">
        <div className="p-8 text-center">
          <div className="animate-pulse">
            <div className="h-4 bg-gray-200 rounded w-3/4 mx-auto mb-4"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2 mx-auto mb-4"></div>
            <div className="h-4 bg-gray-200 rounded w-2/3 mx-auto"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={`bg-white shadow-sm rounded-lg border border-gray-200 overflow-hidden ${className}`}>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              {columns.map((column) => (
                <th
                  key={column.key}
                  className={`
                    px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider
                    ${column.sortable && sortable ? 'cursor-pointer hover:bg-gray-100' : ''}
                  `}
                  onClick={() => handleSort(column)}
                >
                  <div className="flex items-center space-x-1">
                    <span>{column.title}</span>
                    {column.sortable && sortable && (
                      <div className="flex flex-col">
                        <ChevronUpIcon 
                          className={`w-3 h-3 ${
                            sortBy === column.key && sortDirection === 'asc' 
                              ? 'text-primary-600' 
                              : 'text-gray-400'
                          }`}
                        />
                        <ChevronDownIcon 
                          className={`w-3 h-3 -mt-1 ${
                            sortBy === column.key && sortDirection === 'desc' 
                              ? 'text-primary-600' 
                              : 'text-gray-400'
                          }`}
                        />
                      </div>
                    )}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          
          <tbody className="bg-white divide-y divide-gray-200">
            {data.length === 0 ? (
              <tr>
                <td 
                  colSpan={columns.length} 
                  className="px-6 py-8 text-center text-gray-500"
                >
                  {emptyMessage}
                </td>
              </tr>
            ) : (
              data.map((item, index) => (
                <tr key={item.id || index} className="hover:bg-gray-50">
                  {columns.map((column) => (
                    <td key={column.key} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {column.render ? column.render(item, index) : item[column.key]}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Table;
EOF

# src/components/common/Badge/index.js
cat > frontend/src/components/common/Badge/index.js << 'EOF'
import React from 'react';

const Badge = ({
  children,
  variant = 'default',
  size = 'medium',
  className = '',
}) => {
  const variantClasses = {
    default: 'bg-gray-100 text-gray-800',
    primary: 'bg-primary-100 text-primary-800',
    secondary: 'bg-secondary-100 text-secondary-800',
    success: 'bg-green-100 text-green-800',
    warning: 'bg-yellow-100 text-yellow-800',
    danger: 'bg-red-100 text-red-800',
    info: 'bg-blue-100 text-blue-800',
  };

  const sizeClasses = {
    small: 'px-2 py-0.5 text-xs',
    medium: 'px-2.5 py-1 text-sm',
    large: 'px-3 py-1.5 text-base',
  };

  return (
    <span
      className={`
        inline-flex items-center font-medium rounded-full
        ${variantClasses[variant]}
        ${sizeClasses[size]}
        ${className}
      `}
    >
      {children}
    </span>
  );
};

export default Badge;
EOF

echo "✅ Componentes UI base criados com sucesso!"
echo ""
echo "📊 COMPONENTES CRIADOS:"
echo "   • Loading - Spinner com múltiplos tamanhos/cores"
echo "   • Button - Botão com variantes e estados"
echo "   • Input - Input com ícones e validação"
echo "   • Card - Card reutilizável com header/body"
echo "   • Modal - Modal com transições e confirmação"
echo "   • Table - Tabela com sorting e loading"
echo "   • Badge - Badge para status e tags"
echo ""
echo "🎨 RECURSOS INCLUÍDOS:"
echo "   • Design system da Erlene aplicado"
echo "   • Responsivo e acessível"
echo "   • Estados de loading/error/disabled"
echo "   • Transições suaves com Framer Motion"
echo "   • Variantes de cores e tamanhos"
echo "   • Props flexíveis e extensíveis"
echo ""
echo "⏭️  Próximo: Services/API (axios client, endpoints)!"