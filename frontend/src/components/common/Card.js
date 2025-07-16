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
    default: 'shadow',
    large: 'shadow-lg',
  };

  const hoverClasses = hover ? 'hover:shadow-lg transition-shadow duration-200 cursor-pointer' : '';

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
