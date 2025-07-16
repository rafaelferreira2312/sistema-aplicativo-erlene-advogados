#!/bin/bash

# Script de Correção - Criar Arquivos Faltantes
# Sistema de Gestão Jurídica - Erlene Advogados

echo "🔧 Criando arquivos faltantes para corrigir erros..."

# Criar diretórios necessários
mkdir -p frontend/src/components/auth
mkdir -p frontend/src/components/common
mkdir -p frontend/src/pages/admin
mkdir -p frontend/src/pages/portal
mkdir -p frontend/src/pages/errors
mkdir -p frontend/src/styles

# 1. Criar PrivateRoute.js
cat > frontend/src/components/auth/PrivateRoute.js << 'EOF'
import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/auth/useAuth';

const PrivateRoute = ({ children, allowedRoles = [] }) => {
  const { isAuthenticated, isLoading, hasRole } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <Navigate 
        to="/login" 
        state={{ from: location }} 
        replace 
      />
    );
  }

  if (allowedRoles.length > 0 && !hasRole(allowedRoles)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return children;
};

export default PrivateRoute;
EOF

# 2. Criar PublicRoute.js
cat > frontend/src/components/auth/PublicRoute.js << 'EOF'
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../hooks/auth/useAuth';

const PublicRoute = ({ children }) => {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (isAuthenticated) {
    if (user?.perfil === 'cliente') {
      return <Navigate to="/portal" replace />;
    } else {
      return <Navigate to="/admin" replace />;
    }
  }

  return children;
};

export default PublicRoute;
EOF

# 3. Criar Card.js
cat > frontend/src/components/common/Card.js << 'EOF'
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
EOF

# 4. Criar Badge.js
cat > frontend/src/components/common/Badge.js << 'EOF'
import React from 'react';

const Badge = ({
  children,
  variant = 'default',
  size = 'medium',
  className = '',
}) => {
  const variantClasses = {
    default: 'bg-gray-100 text-gray-800',
    primary: 'bg-blue-100 text-blue-800',
    secondary: 'bg-purple-100 text-purple-800',
    success: 'bg-green-100 text-green-800',
    warning: 'bg-yellow-100 text-yellow-800',
    danger: 'bg-red-100 text-red-800',
    info: 'bg-blue-100 text-blue-800',
    outline: 'border border-gray-300 text-gray-700',
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

# 5. Criar Button.js
cat > frontend/src/components/common/Button.js << 'EOF'
import React from 'react';

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
    primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
    secondary: 'bg-gray-600 text-white hover:bg-gray-700 focus:ring-gray-500',
    outline: 'border-2 border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white focus:ring-blue-500',
    ghost: 'text-blue-600 hover:bg-blue-50 focus:ring-blue-500',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500',
    success: 'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500',
    warning: 'bg-yellow-500 text-white hover:bg-yellow-600 focus:ring-yellow-400',
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
        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
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

# 6. Criar Input.js
cat > frontend/src/components/common/Input.js << 'EOF'
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
EOF

# 7. Criar páginas simples
cat > frontend/src/pages/admin/Clients.js << 'EOF'
import React from 'react';

const Clients = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Clientes</h1>
      <p className="mt-2 text-gray-600">Página de clientes em desenvolvimento...</p>
    </div>
  );
};

export default Clients;
EOF

cat > frontend/src/pages/admin/Processes.js << 'EOF'
import React from 'react';

const Processes = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Processos</h1>
      <p className="mt-2 text-gray-600">Página de processos em desenvolvimento...</p>
    </div>
  );
};

export default Processes;
EOF

cat > frontend/src/pages/admin/Appointments.js << 'EOF'
import React from 'react';

const Appointments = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Atendimentos</h1>
      <p className="mt-2 text-gray-600">Página de atendimentos em desenvolvimento...</p>
    </div>
  );
};

export default Appointments;
EOF

cat > frontend/src/pages/admin/Financial.js << 'EOF'
import React from 'react';

const Financial = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Financeiro</h1>
      <p className="mt-2 text-gray-600">Página financeira em desenvolvimento...</p>
    </div>
  );
};

export default Financial;
EOF

cat > frontend/src/pages/admin/Documents.js << 'EOF'
import React from 'react';

const Documents = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Documentos</h1>
      <p className="mt-2 text-gray-600">Sistema GED em desenvolvimento...</p>
    </div>
  );
};

export default Documents;
EOF

cat > frontend/src/pages/admin/Kanban.js << 'EOF'
import React from 'react';

const Kanban = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Kanban</h1>
      <p className="mt-2 text-gray-600">Sistema Kanban em desenvolvimento...</p>
    </div>
  );
};

export default Kanban;
EOF

cat > frontend/src/pages/admin/Reports.js << 'EOF'
import React from 'react';

const Reports = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Relatórios</h1>
      <p className="mt-2 text-gray-600">Página de relatórios em desenvolvimento...</p>
    </div>
  );
};

export default Reports;
EOF

cat > frontend/src/pages/admin/Users.js << 'EOF'
import React from 'react';

const Users = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Usuários</h1>
      <p className="mt-2 text-gray-600">Página de usuários em desenvolvimento...</p>
    </div>
  );
};

export default Users;
EOF

cat > frontend/src/pages/admin/Settings.js << 'EOF'
import React from 'react';

const Settings = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Configurações</h1>
      <p className="mt-2 text-gray-600">Página de configurações em desenvolvimento...</p>
    </div>
  );
};

export default Settings;
EOF

# 8. Criar páginas do portal
cat > frontend/src/pages/portal/Login.js << 'EOF'
import React from 'react';

const PortalLogin = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="text-3xl font-bold text-center text-gray-900">
            Portal do Cliente
          </h2>
          <p className="mt-2 text-center text-gray-600">
            Faça login para acessar seus processos
          </p>
        </div>
      </div>
    </div>
  );
};

export default PortalLogin;
EOF

cat > frontend/src/pages/portal/Processes.js << 'EOF'
import React from 'react';

const PortalProcesses = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Meus Processos</h1>
      <p className="mt-2 text-gray-600">Página de processos do cliente...</p>
    </div>
  );
};

export default PortalProcesses;
EOF

cat > frontend/src/pages/portal/Documents.js << 'EOF'
import React from 'react';

const PortalDocuments = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Meus Documentos</h1>
      <p className="mt-2 text-gray-600">Página de documentos do cliente...</p>
    </div>
  );
};

export default PortalDocuments;
EOF

cat > frontend/src/pages/portal/Payments.js << 'EOF'
import React from 'react';

const PortalPayments = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Pagamentos</h1>
      <p className="mt-2 text-gray-600">Página de pagamentos do cliente...</p>
    </div>
  );
};

export default PortalPayments;
EOF

cat > frontend/src/pages/portal/Messages.js << 'EOF'
import React from 'react';

const PortalMessages = () => {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-900">Mensagens</h1>
      <p className="mt-2 text-gray-600">Página de mensagens do cliente...</p>
    </div>
  );
};

export default PortalMessages;
EOF

# 9. Criar páginas de erro
cat > frontend/src/pages/errors/NotFound.js << 'EOF'
import React from 'react';
import { Link } from 'react-router-dom';

const NotFound = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-9xl font-bold text-gray-200">404</h1>
        <h2 className="text-2xl font-bold text-gray-900 mt-4">Página não encontrada</h2>
        <p className="text-gray-600 mt-2">A página que você procura não existe.</p>
        <Link
          to="/admin"
          className="mt-4 inline-block bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        >
          Voltar ao Dashboard
        </Link>
      </div>
    </div>
  );
};

export default NotFound;
EOF

cat > frontend/src/pages/errors/Unauthorized.js << 'EOF'
import React from 'react';
import { Link } from 'react-router-dom';

const Unauthorized = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-9xl font-bold text-gray-200">403</h1>
        <h2 className="text-2xl font-bold text-gray-900 mt-4">Acesso Negado</h2>
        <p className="text-gray-600 mt-2">Você não tem permissão para acessar esta página.</p>
        <Link
          to="/admin"
          className="mt-4 inline-block bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        >
          Voltar ao Dashboard
        </Link>
      </div>
    </div>
  );
};

export default Unauthorized;
EOF

# 10. Ajustar Dashboard para usar ícones corretos
cat > frontend/src/pages/admin/Dashboard/index.js << 'EOF'
import React from 'react';
import { 
  UsersIcon, 
  ScaleIcon, 
  CurrencyDollarIcon,
  CalendarIcon,
  ChartBarIcon,
  ArrowUpIcon,
  ArrowDownIcon
} from '@heroicons/react/24/outline';
import Card from '../../../components/common/Card';
import Badge from '../../../components/common/Badge';

const Dashboard = () => {
  const stats = [
    {
      name: 'Total de Clientes',
      value: '1,247',
      change: '+12%',
      changeType: 'increase',
      icon: UsersIcon,
    },
    {
      name: 'Processos Ativos',
      value: '891',
      change: '+8%',
      changeType: 'increase',
      icon: ScaleIcon,
    },
    {
      name: 'Receita Mensal',
      value: 'R$ 125.847',
      change: '+23%',
      changeType: 'increase',
      icon: CurrencyDollarIcon,
    },
    {
      name: 'Atendimentos Hoje',
      value: '14',
      change: '-2%',
      changeType: 'decrease',
      icon: CalendarIcon,
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-gray-900">
          Bem-vindo ao Sistema Erlene Advogados
        </h2>
        <p className="mt-1 text-gray-600">
          Aqui está um resumo das atividades do seu escritório hoje.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((item) => (
          <Card key={item.name} className="overflow-hidden">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <item.icon className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">
                      {item.name}
                    </dt>
                    <dd className="flex items-baseline">
                      <div className="text-2xl font-semibold text-gray-900">
                        {item.value}
                      </div>
                      <div className={`ml-2 flex items-baseline text-sm font-semibold ${
                        item.changeType === 'increase' ? 'text-green-600' : 'text-red-600'
                      }`}>
                        {item.changeType === 'increase' ? (
                          <ArrowUpIcon className="h-3 w-3 flex-shrink-0 self-center" />
                        ) : (
                          <ArrowDownIcon className="h-3 w-3 flex-shrink-0 self-center" />
                        )}
                        <span className="sr-only">
                          {item.changeType === 'increase' ? 'Increased' : 'Decreased'} by
                        </span>
                        {item.change}
                      </div>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>

      <Card title="Ações Rápidas">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors">
            <UsersIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Novo Cliente</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors">
            <ScaleIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Novo Processo</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors">
            <CalendarIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Agendar Atendimento</span>
          </button>
          
          <button className="flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors">
            <ChartBarIcon className="h-8 w-8 text-gray-400 mb-2" />
            <span className="text-sm font-medium text-gray-900">Ver Relatórios</span>
          </button>
        </div>
      </Card>
    </div>
  );
};

export default Dashboard;
EOF

echo "✅ Arquivos básicos criados!"
echo "🔧 Execute npm install para instalar as dependências:"
echo ""
echo "cd frontend"
echo "npm install"
echo ""
echo "📦 Dependências principais que serão instaladas:"
echo "   • react react-dom"
echo "   • react-router-dom"
echo "   • @heroicons/react"
echo "   • tailwindcss"
echo ""
echo "Após instalar as dependências, execute npm start novamente!"