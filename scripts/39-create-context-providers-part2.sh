#!/bin/bash

# Script 39 - Context Providers (Parte 2)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/39-create-context-providers-part2.sh

echo "🎭 Criando context providers (Parte 2)..."

# src/hooks/notification/useNotification.js
cat > frontend/src/hooks/notification/useNotification.js << 'EOF'
import { useContext } from 'react';
import { NotificationContext } from '../../context/notification/NotificationContext';

export const useNotification = () => {
  const context = useContext(NotificationContext);
  
  if (!context) {
    throw new Error('useNotification deve ser usado dentro de um NotificationProvider');
  }
  
  return context;
};

// Hook com métodos de conveniência
export const useNotificationHelpers = () => {
  const { addNotification } = useNotification();

  const notifySuccess = (message, options = {}) => {
    return addNotification({
      type: 'success',
      title: 'Sucesso',
      message,
      ...options,
    });
  };

  const notifyError = (message, options = {}) => {
    return addNotification({
      type: 'error',
      title: 'Erro',
      message,
      autoRemove: false,
      ...options,
    });
  };

  const notifyWarning = (message, options = {}) => {
    return addNotification({
      type: 'warning',
      title: 'Atenção',
      message,
      ...options,
    });
  };

  const notifyInfo = (message, options = {}) => {
    return addNotification({
      type: 'info',
      title: 'Informação',
      message,
      ...options,
    });
  };

  return {
    notifySuccess,
    notifyError,
    notifyWarning,
    notifyInfo,
  };
};
EOF

# src/context/sidebar/SidebarContext.js
cat > frontend/src/context/sidebar/SidebarContext.js << 'EOF'
import { createContext } from 'react';

export const SidebarContext = createContext({
  isOpen: false,
  isCollapsed: false,
  toggleSidebar: () => {},
  closeSidebar: () => {},
  openSidebar: () => {},
  toggleCollapsed: () => {},
});
EOF

# src/context/sidebar/SidebarProvider.js
cat > frontend/src/context/sidebar/SidebarProvider.js << 'EOF'
import React, { useState, useEffect, useCallback } from 'react';
import { SidebarContext } from './SidebarContext';
import { APP_CONFIG } from '../../config/constants';

export const SidebarProvider = ({ children }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [isCollapsed, setIsCollapsed] = useState(() => {
    const saved = localStorage.getItem(APP_CONFIG.STORAGE_KEYS.SIDEBAR_COLLAPSED);
    return saved ? JSON.parse(saved) : false;
  });

  // Salvar estado do collapsed no localStorage
  useEffect(() => {
    localStorage.setItem(APP_CONFIG.STORAGE_KEYS.SIDEBAR_COLLAPSED, JSON.stringify(isCollapsed));
  }, [isCollapsed]);

  // Fechar sidebar em telas pequenas quando redimensiona
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 1024) {
        setIsOpen(false);
      }
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const toggleSidebar = useCallback(() => {
    setIsOpen(prev => !prev);
  }, []);

  const closeSidebar = useCallback(() => {
    setIsOpen(false);
  }, []);

  const openSidebar = useCallback(() => {
    setIsOpen(true);
  }, []);

  const toggleCollapsed = useCallback(() => {
    setIsCollapsed(prev => !prev);
  }, []);

  const value = {
    isOpen,
    isCollapsed,
    toggleSidebar,
    closeSidebar,
    openSidebar,
    toggleCollapsed,
  };

  return (
    <SidebarContext.Provider value={value}>
      {children}
    </SidebarContext.Provider>
  );
};
EOF

# src/hooks/sidebar/useSidebar.js
cat > frontend/src/hooks/sidebar/useSidebar.js << 'EOF'
import { useContext } from 'react';
import { SidebarContext } from '../../context/sidebar/SidebarContext';

export const useSidebar = () => {
  const context = useContext(SidebarContext);
  
  if (!context) {
    throw new Error('useSidebar deve ser usado dentro de um SidebarProvider');
  }
  
  return context;
};
EOF

# src/context/modal/ModalContext.js
cat > frontend/src/context/modal/ModalContext.js << 'EOF'
import { createContext } from 'react';

export const ModalContext = createContext({
  modals: [],
  openModal: () => {},
  closeModal: () => {},
  closeAllModals: () => {},
  isModalOpen: () => false,
});
EOF

# src/context/modal/ModalProvider.js
cat > frontend/src/context/modal/ModalProvider.js << 'EOF'
import React, { useState, useCallback } from 'react';
import { ModalContext } from './ModalContext';

let modalId = 0;

export const ModalProvider = ({ children }) => {
  const [modals, setModals] = useState([]);

  const openModal = useCallback((modalComponent, props = {}) => {
    const id = ++modalId;
    const modal = {
      id,
      component: modalComponent,
      props,
    };

    setModals(prev => [...prev, modal]);
    return id;
  }, []);

  const closeModal = useCallback((id) => {
    setModals(prev => prev.filter(modal => modal.id !== id));
  }, []);

  const closeAllModals = useCallback(() => {
    setModals([]);
  }, []);

  const isModalOpen = useCallback((id) => {
    return modals.some(modal => modal.id === id);
  }, [modals]);

  const value = {
    modals,
    openModal,
    closeModal,
    closeAllModals,
    isModalOpen,
  };

  return (
    <ModalContext.Provider value={value}>
      {children}
      {/* Renderizar modais */}
      {modals.map(modal => {
        const ModalComponent = modal.component;
        return (
          <ModalComponent
            key={modal.id}
            modalId={modal.id}
            onClose={() => closeModal(modal.id)}
            {...modal.props}
          />
        );
      })}
    </ModalContext.Provider>
  );
};
EOF

# src/hooks/modal/useModal.js
cat > frontend/src/hooks/modal/useModal.js << 'EOF'
import { useContext } from 'react';
import { ModalContext } from '../../context/modal/ModalContext';

export const useModal = () => {
  const context = useContext(ModalContext);
  
  if (!context) {
    throw new Error('useModal deve ser usado dentro de um ModalProvider');
  }
  
  return context;
};

// Hook para controlar um modal específico
export const useModalController = (modalComponent) => {
  const { openModal, closeModal, isModalOpen } = useModal();

  const open = (props = {}) => {
    return openModal(modalComponent, props);
  };

  const close = (id) => {
    closeModal(id);
  };

  const isOpen = (id) => {
    return isModalOpen(id);
  };

  return {
    open,
    close,
    isOpen,
  };
};
EOF

# src/context/search/SearchContext.js
cat > frontend/src/context/search/SearchContext.js << 'EOF'
import { createContext } from 'react';

export const SearchContext = createContext({
  searchTerm: '',
  setSearchTerm: () => {},
  searchHistory: [],
  addToHistory: () => {},
  clearHistory: () => {},
  suggestions: [],
  isSearching: false,
  searchResults: [],
  performSearch: () => {},
  clearResults: () => {},
});
EOF

# src/context/search/SearchProvider.js
cat > frontend/src/context/search/SearchProvider.js << 'EOF'
import React, { useState, useCallback, useEffect } from 'react';
import { SearchContext } from './SearchContext';
import { useDebounce } from '../../hooks/common/useDebounce';

const SEARCH_HISTORY_KEY = 'erlene_search_history';
const MAX_HISTORY_ITEMS = 10;

export const SearchProvider = ({ children, searchFunction }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [searchHistory, setSearchHistory] = useState(() => {
    const saved = localStorage.getItem(SEARCH_HISTORY_KEY);
    return saved ? JSON.parse(saved) : [];
  });
  const [suggestions, setSuggestions] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  const [searchResults, setSearchResults] = useState([]);

  const debouncedSearchTerm = useDebounce(searchTerm, 300);

  // Salvar histórico no localStorage
  useEffect(() => {
    localStorage.setItem(SEARCH_HISTORY_KEY, JSON.stringify(searchHistory));
  }, [searchHistory]);

  // Adicionar ao histórico
  const addToHistory = useCallback((term) => {
    if (!term || term.length < 2) return;

    setSearchHistory(prev => {
      const filtered = prev.filter(item => item !== term);
      const newHistory = [term, ...filtered].slice(0, MAX_HISTORY_ITEMS);
      return newHistory;
    });
  }, []);

  // Limpar histórico
  const clearHistory = useCallback(() => {
    setSearchHistory([]);
  }, []);

  // Realizar busca
  const performSearch = useCallback(async (term = searchTerm) => {
    if (!term || !searchFunction) return;

    setIsSearching(true);
    try {
      const results = await searchFunction(term);
      setSearchResults(results);
      addToHistory(term);
    } catch (error) {
      console.error('Erro na busca:', error);
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  }, [searchTerm, searchFunction, addToHistory]);

  // Busca automática com debounce
  useEffect(() => {
    if (debouncedSearchTerm && debouncedSearchTerm.length >= 2) {
      performSearch(debouncedSearchTerm);
    } else {
      setSearchResults([]);
    }
  }, [debouncedSearchTerm, performSearch]);

  // Limpar resultados
  const clearResults = useCallback(() => {
    setSearchResults([]);
    setSearchTerm('');
  }, []);

  const value = {
    searchTerm,
    setSearchTerm,
    searchHistory,
    addToHistory,
    clearHistory,
    suggestions,
    isSearching,
    searchResults,
    performSearch,
    clearResults,
  };

  return (
    <SearchContext.Provider value={value}>
      {children}
    </SearchContext.Provider>
  );
};
EOF

# src/hooks/search/useSearch.js
cat > frontend/src/hooks/search/useSearch.js << 'EOF'
import { useContext } from 'react';
import { SearchContext } from '../../context/search/SearchContext';

export const useSearch = () => {
  const context = useContext(SearchContext);
  
  if (!context) {
    throw new Error('useSearch deve ser usado dentro de um SearchProvider');
  }
  
  return context;
};
EOF

echo "✅ Context Providers (Parte 2) criados com sucesso!"
echo ""
echo "📊 PROVIDERS CRIADOS:"
echo "   • NotificationProvider hooks - useNotification + helpers"
echo "   • SidebarProvider - Controle de sidebar responsiva"
echo "   • ModalProvider - Sistema de modais centralizado"
echo "   • SearchProvider - Sistema de busca global"
echo ""
echo "🎭 RECURSOS INCLUÍDOS:"
echo "   • Notificações com helpers (success, error, warning, info)"
echo "   • Sidebar com estado persistente e responsividade"
echo "   • Sistema de modais com stack e controle individual"
echo "   • Busca global com histórico e debounce"
echo "   • Persistência de preferências no localStorage"
echo "   • Hooks específicos para cada funcionalidade"
echo ""
echo "⏭️  Próximo: Utilitários e helpers!"