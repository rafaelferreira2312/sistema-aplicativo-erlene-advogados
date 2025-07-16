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
  const baseClasses = 'block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm transition-colors duration-200';
  
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
