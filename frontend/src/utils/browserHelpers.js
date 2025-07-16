// Detectar tipo de dispositivo
export const getDeviceType = () => {
  const width = window.innerWidth;
  
  if (width < 768) return 'mobile';
  if (width < 1024) return 'tablet';
  return 'desktop';
};

// Verificar se é dispositivo móvel
export const isMobile = () => {
  return getDeviceType() === 'mobile';
};

// Verificar se é tablet
export const isTablet = () => {
  return getDeviceType() === 'tablet';
};

// Verificar se é desktop
export const isDesktop = () => {
  return getDeviceType() === 'desktop';
};

// Copiar texto para área de transferência
export const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch (err) {
    // Fallback para navegadores mais antigos
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    
    try {
      document.execCommand('copy');
      document.body.removeChild(textArea);
      return true;
    } catch (err) {
      document.body.removeChild(textArea);
      return false;
    }
  }
};

// Detectar navegador
export const getBrowser = () => {
  const userAgent = navigator.userAgent;
  
  if (userAgent.includes('Chrome')) return 'Chrome';
  if (userAgent.includes('Firefox')) return 'Firefox';
  if (userAgent.includes('Safari')) return 'Safari';
  if (userAgent.includes('Edge')) return 'Edge';
  if (userAgent.includes('Opera')) return 'Opera';
  
  return 'Unknown';
};

// Verificar se suporta notificações
export const supportsNotifications = () => {
  return 'Notification' in window;
};

// Solicitar permissão para notificações
export const requestNotificationPermission = async () => {
  if (!supportsNotifications()) return false;
  
  const permission = await Notification.requestPermission();
  return permission === 'granted';
};

// Enviar notificação do navegador
export const sendBrowserNotification = (title, options = {}) => {
  if (!supportsNotifications() || Notification.permission !== 'granted') {
    return null;
  }
  
  return new Notification(title, {
    icon: '/favicon.ico',
    badge: '/favicon.ico',
    ...options
  });
};

// Verificar se está online
export const isOnline = () => {
  return navigator.onLine;
};

// Escutar mudanças de conectividade
export const onConnectivityChange = (callback) => {
  const handleOnline = () => callback(true);
  const handleOffline = () => callback(false);
  
  window.addEventListener('online', handleOnline);
  window.addEventListener('offline', handleOffline);
  
  // Retornar função de cleanup
  return () => {
    window.removeEventListener('online', handleOnline);
    window.removeEventListener('offline', handleOffline);
  };
};

// Scroll suave para elemento
export const scrollToElement = (elementId, offset = 0) => {
  const element = document.getElementById(elementId);
  if (!element) return;
  
  const top = element.offsetTop - offset;
  window.scrollTo({ top, behavior: 'smooth' });
};

// Obter informações da bateria (se suportado)
export const getBatteryInfo = async () => {
  if (!('getBattery' in navigator)) return null;
  
  try {
    const battery = await navigator.getBattery();
    return {
      level: Math.round(battery.level * 100),
      charging: battery.charging,
      chargingTime: battery.chargingTime,
      dischargingTime: battery.dischargingTime
    };
  } catch (err) {
    return null;
  }
};

// Verificar se está em fullscreen
export const isFullscreen = () => {
  return !!(
    document.fullscreenElement ||
    document.webkitFullscreenElement ||
    document.mozFullScreenElement ||
    document.msFullscreenElement
  );
};

// Entrar em fullscreen
export const enterFullscreen = (element = document.documentElement) => {
  if (element.requestFullscreen) {
    element.requestFullscreen();
  } else if (element.webkitRequestFullscreen) {
    element.webkitRequestFullscreen();
  } else if (element.mozRequestFullScreen) {
    element.mozRequestFullScreen();
  } else if (element.msRequestFullscreen) {
    element.msRequestFullscreen();
  }
};

// Sair do fullscreen
export const exitFullscreen = () => {
  if (document.exitFullscreen) {
    document.exitFullscreen();
  } else if (document.webkitExitFullscreen) {
    document.webkitExitFullscreen();
  } else if (document.mozCancelFullScreen) {
    document.mozCancelFullScreen();
  } else if (document.msExitFullscreen) {
    document.msExitFullscreen();
  }
};
