#!/bin/bash

# Script 38 - Context Providers (Parte 1)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/38-create-context-providers.sh

echo "🎭 Criando context providers..."

# src/context/theme/ThemeContext.js
cat > frontend/src/context/theme/ThemeContext.js << 'EOF'
import { createContext } from 'react';

export const ThemeContext = createContext({
  theme: 'light',
  toggleTheme: () => {},
  isDark: false,
  colors: {},
});
EOF

# src/context/theme/ThemeProvider.js
cat > frontend/src/context/theme/ThemeProvider.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { ThemeContext } from './ThemeContext';
import { APP_CONFIG } from '../../config/constants';

const THEME_COLORS = {
  light: {
    primary: {
      50: '#fef2f2',
      100: '#fee2e2',
      500: '#8b1538',
      600: '#7a1230',
      700: '#691028',
      800: '#580e20',
      900: '#470c18',
    },
    secondary: {
      100: '#fef3c7',
      500: '#f5b041',
      600: '#e09f2d',
    },
    gray: {
      50: '#f9fafb',
      100: '#f3f4f6',
      200: '#e5e7eb',
      300: '#d1d5db',
      400: '#9ca3af',
      500: '#6b7280',
      600: '#4b5563',
      700: '#374151',
      800: '#1f2937',
      900: '#111827',
    },
    background: '#ffffff',
    foreground: '#374151',
    card: '#ffffff',
    border: '#e5e7eb',
  },
  dark: {
    primary: {
      50: '#fef2f2',
      100: '#fee2e2',
      500: '#8b1538',
      600: '#7a1230',
      700: '#691028',
      800: '#580e20',
      900: '#470c18',
    },
    secondary: {
      100: '#fef3c7',
      500: '#f5b041',
      600: '#e09f2d',
    },
    gray: {
      50: '#1f2937',
      100: '#374151',
      200: '#4b5563',
      300: '#6b7280',
      400: '#9ca3af',
      500: '#d1d5db',
      600: '#e5e7eb',
      700: '#f3f4f6',
      800: '#f9fafb',
      900: '#ffffff',
    },
    background: '#0f172a',
    foreground: '#f1f5f9',
    card: '#1e293b',
    border: '#334155',
  },
};

export const ThemeProvider = ({ children }) => {
  const [theme, setTheme] = useState(() => {
    const savedTheme = localStorage.getItem(APP_CONFIG.STORAGE_KEYS.THEME);
    if (savedTheme && ['light', 'dark'].includes(savedTheme)) {
      return savedTheme;
    }
    
    // Verificar preferência do sistema
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    
    return 'light';
  });

  const isDark = theme === 'dark';
  const colors = THEME_COLORS[theme];

  // Aplicar tema ao HTML
  useEffect(() => {
    const root = document.documentElement;
    
    if (isDark) {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }

    // Aplicar variáveis CSS customizadas
    Object.entries(colors).forEach(([colorName, colorValue]) => {
      if (typeof colorValue === 'object') {
        Object.entries(colorValue).forEach(([shade, value]) => {
          root.style.setProperty(`--color-${colorName}-${shade}`, value);
        });
      } else {
        root.style.setProperty(`--color-${colorName}`, colorValue);
      }
    });

    // Salvar preferência
    localStorage.setItem(APP_CONFIG.STORAGE_KEYS.THEME, theme);
  }, [theme, isDark, colors]);

  // Escutar mudanças na preferência do sistema
  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    const handleChange = (e) => {
      const savedTheme = localStorage.getItem(APP_CONFIG.STORAGE_KEYS.THEME);
      if (!savedTheme) {
        setTheme(e.matches ? 'dark' : 'light');
      }
    };

    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, []);

  const toggleTheme = () => {
    setTheme(prevTheme => prevTheme === 'light' ? 'dark' : 'light');
  };

  const value = {
    theme,
    toggleTheme,
    isDark,
    colors,
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};
EOF

# src/hooks/theme/useTheme.js
cat > frontend/src/hooks/theme/useTheme.js << 'EOF'
import { useContext } from 'react';
import { ThemeContext } from '../../context/theme/ThemeContext';

export const useTheme = () => {
  const context = useContext(ThemeContext);
  
  if (!context) {
    throw new Error('useTheme deve ser usado dentro de um ThemeProvider');
  }
  
  return context;
};
EOF

# src/context/notification/NotificationContext.js
cat > frontend/src/context/notification/NotificationContext.js << 'EOF'
import { createContext } from 'react';

export const NotificationContext = createContext({
  notifications: [],
  addNotification: () => {},
  removeNotification: () => {},
  clearNotifications: () => {},
  markAsRead: () => {},
  markAllAsRead: () => {},
  unreadCount: 0,
});
EOF

# src/context/notification/NotificationProvider.js
cat > frontend/src/context/notification/NotificationProvider.js << 'EOF'
import React, { useState, useCallback, useMemo } from 'react';
import { NotificationContext } from './NotificationContext';

let notificationId = 0;

export const NotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([]);

  // Adicionar nova notificação
  const addNotification = useCallback((notification) => {
    const id = ++notificationId;
    const newNotification = {
      id,
      timestamp: new Date(),
      read: false,
      ...notification,
    };

    setNotifications(prev => [newNotification, ...prev]);

    // Auto remover notificação após tempo especificado
    if (notification.autoRemove !== false) {
      const timeout = notification.timeout || 5000;
      setTimeout(() => {
        removeNotification(id);
      }, timeout);
    }

    return id;
  }, []);

  // Remover notificação
  const removeNotification = useCallback((id) => {
    setNotifications(prev => prev.filter(notification => notification.id !== id));
  }, []);

  // Limpar todas as notificações
  const clearNotifications = useCallback(() => {
    setNotifications([]);
  }, []);

  // Marcar como lida
  const markAsRead = useCallback((id) => {
    setNotifications(prev =>
      prev.map(notification =>
        notification.id === id
          ? { ...notification, read: true }
          : notification
      )
    );
  }, []);

  // Marcar todas como lidas
  const markAllAsRead = useCallback(() => {
    setNotifications(prev =>
      prev.map(notification => ({ ...notification, read: true }))
    );
  }, []);

  // Contar não lidas
  const unreadCount = useMemo(() => {
    return notifications.filter(notification => !notification.read).length;
  }, [notifications]);

  const value = {
    notifications,
    addNotification,
    removeNotification,
    clearNotifications,
    markAsRead,
    markAllAsRead,
    unreadCount,
  };

  return (
    <NotificationContext.Provider value={value}>
      {children}
    </NotificationContext.Provider>
  );
};
EOF

echo "✅ Context Providers (Parte 1) criados com sucesso!"
echo ""
echo "📊 PROVIDERS CRIADOS:"
echo "   • ThemeContext + ThemeProvider - Tema claro/escuro"
echo "   • NotificationContext + NotificationProvider - Notificações"
echo "   • useTheme hook - Hook para tema"
echo ""
echo "🎭 RECURSOS INCLUÍDOS:"
echo "   • Sistema de tema com cores da Erlene"
echo "   • Preferência do sistema detectada automaticamente"
echo "   • Variáveis CSS aplicadas dinamicamente"
echo "   • Sistema de notificações completo"
echo "   • Auto-remoção de notificações"
echo "   • Contador de não lidas"
echo ""
echo "⏭️  Próximo: Aguardando continuar para criar a Parte 2!"