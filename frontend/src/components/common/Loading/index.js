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
