#!/bin/bash

# Script 41 - Helpers e Utilitários Gerais
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/41-create-helpers-utils.sh

echo "🛠️ Criando helpers e utilitários gerais..."

# src/utils/fileHelpers.js
cat > frontend/src/utils/fileHelpers.js << 'EOF'
// Converter bytes para formato legível
export const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// Obter extensão do arquivo
export const getFileExtension = (filename) => {
  if (!filename) return '';
  return filename.split('.').pop().toLowerCase();
};

// Verificar se é imagem
export const isImageFile = (filename) => {
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp'];
  return imageExtensions.includes(getFileExtension(filename));
};

// Verificar se é PDF
export const isPDFFile = (filename) => {
  return getFileExtension(filename) === 'pdf';
};

// Verificar se é documento
export const isDocumentFile = (filename) => {
  const docExtensions = ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf', 'txt', 'rtf'];
  return docExtensions.includes(getFileExtension(filename));
};

// Verificar se é áudio
export const isAudioFile = (filename) => {
  const audioExtensions = ['mp3', 'wav', 'm4a', 'ogg', 'flac', 'aac'];
  return audioExtensions.includes(getFileExtension(filename));
};

// Verificar se é vídeo
export const isVideoFile = (filename) => {
  const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'webm', 'mkv', 'flv'];
  return videoExtensions.includes(getFileExtension(filename));
};

// Download de arquivo
export const downloadFile = (blob, filename) => {
  const url = window.URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  window.URL.revokeObjectURL(url);
};

// Download de arquivo via URL
export const downloadFileFromUrl = (url, filename) => {
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.target = '_blank';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

// Converter arquivo para base64
export const fileToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result);
    reader.onerror = error => reject(error);
  });
};

// Redimensionar imagem
export const resizeImage = (file, maxWidth, maxHeight, quality = 0.8) => {
  return new Promise((resolve) => {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    const img = new Image();
    
    img.onload = () => {
      // Calcular novas dimensões
      let { width, height } = img;
      
      if (width > height) {
        if (width > maxWidth) {
          height = (height * maxWidth) / width;
          width = maxWidth;
        }
      } else {
        if (height > maxHeight) {
          width = (width * maxHeight) / height;
          height = maxHeight;
        }
      }
      
      canvas.width = width;
      canvas.height = height;
      
      // Desenhar imagem redimensionada
      ctx.drawImage(img, 0, 0, width, height);
      
      // Converter para blob
      canvas.toBlob(resolve, file.type, quality);
    };
    
    img.src = URL.createObjectURL(file);
  });
};

// Obter ícone para tipo de arquivo
export const getFileIcon = (filename) => {
  const extension = getFileExtension(filename);
  
  const iconMap = {
    // Imagens
    jpg: '🖼️', jpeg: '🖼️', png: '🖼️', gif: '🖼️', webp: '🖼️', svg: '🖼️',
    // Documentos
    pdf: '📄', doc: '📝', docx: '📝', txt: '📝', rtf: '📝',
    // Planilhas
    xls: '📊', xlsx: '📊', csv: '📊',
    // Apresentações
    ppt: '📽️', pptx: '📽️',
    // Áudio
    mp3: '🎵', wav: '🎵', m4a: '🎵', ogg: '🎵',
    // Vídeo
    mp4: '🎬', avi: '🎬', mov: '🎬', wmv: '🎬',
    // Arquivo genérico
    default: '📎'
  };
  
  return iconMap[extension] || iconMap.default;
};
EOF

# src/utils/dateHelpers.js
cat > frontend/src/utils/dateHelpers.js << 'EOF'
// Adicionar dias à data
export const addDays = (date, days) => {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
};

// Subtrair dias da data
export const subtractDays = (date, days) => {
  return addDays(date, -days);
};

// Verificar se é fim de semana
export const isWeekend = (date) => {
  const day = new Date(date).getDay();
  return day === 0 || day === 6; // Domingo ou Sábado
};

// Próximo dia útil
export const getNextBusinessDay = (date) => {
  let nextDay = addDays(date, 1);
  
  while (isWeekend(nextDay)) {
    nextDay = addDays(nextDay, 1);
  }
  
  return nextDay;
};

// Diferença em dias
export const getDaysUntil = (targetDate) => {
  const today = new Date();
  const target = new Date(targetDate);
  
  today.setHours(0, 0, 0, 0);
  target.setHours(0, 0, 0, 0);
  
  const diffTime = target - today;
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
};

// Verificar se a data é hoje
export const isToday = (date) => {
  const today = new Date();
  const checkDate = new Date(date);
  
  return today.toDateString() === checkDate.toDateString();
};

// Verificar se a data é ontem
export const isYesterday = (date) => {
  const yesterday = subtractDays(new Date(), 1);
  const checkDate = new Date(date);
  
  return yesterday.toDateString() === checkDate.toDateString();
};

// Verificar se a data é amanhã
export const isTomorrow = (date) => {
  const tomorrow = addDays(new Date(), 1);
  const checkDate = new Date(date);
  
  return tomorrow.toDateString() === checkDate.toDateString();
};

// Obter início do mês
export const getStartOfMonth = (date = new Date()) => {
  return new Date(date.getFullYear(), date.getMonth(), 1);
};

// Obter fim do mês
export const getEndOfMonth = (date = new Date()) => {
  return new Date(date.getFullYear(), date.getMonth() + 1, 0);
};

// Obter início da semana (domingo)
export const getStartOfWeek = (date = new Date()) => {
  const start = new Date(date);
  const day = start.getDay();
  const diff = start.getDate() - day;
  return new Date(start.setDate(diff));
};

// Obter fim da semana (sábado)
export const getEndOfWeek = (date = new Date()) => {
  const start = getStartOfWeek(date);
  return addDays(start, 6);
};

// Gerar array de datas entre duas datas
export const getDateRange = (startDate, endDate) => {
  const dates = [];
  let currentDate = new Date(startDate);
  const end = new Date(endDate);
  
  while (currentDate <= end) {
    dates.push(new Date(currentDate));
    currentDate = addDays(currentDate, 1);
  }
  
  return dates;
};

// Formatar duração em horas e minutos
export const formatDuration = (minutes) => {
  if (minutes < 60) {
    return `${minutes}min`;
  }
  
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  
  if (remainingMinutes === 0) {
    return `${hours}h`;
  }
  
  return `${hours}h ${remainingMinutes}min`;
};

// Verificar se o horário está no intervalo
export const isTimeInRange = (time, startTime, endTime) => {
  const timeMinutes = timeToMinutes(time);
  const startMinutes = timeToMinutes(startTime);
  const endMinutes = timeToMinutes(endTime);
  
  return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
};

// Converter horário para minutos
export const timeToMinutes = (time) => {
  const [hours, minutes] = time.split(':').map(Number);
  return hours * 60 + minutes;
};

// Converter minutos para horário
export const minutesToTime = (minutes) => {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
};
EOF

# src/utils/urlHelpers.js
cat > frontend/src/utils/urlHelpers.js << 'EOF'
// Construir URL com parâmetros
export const buildUrl = (baseUrl, params = {}) => {
  const url = new URL(baseUrl, window.location.origin);
  
  Object.entries(params).forEach(([key, value]) => {
    if (value !== null && value !== undefined && value !== '') {
      url.searchParams.append(key, value);
    }
  });
  
  return url.toString();
};

// Obter parâmetros da URL atual
export const getUrlParams = () => {
  const params = new URLSearchParams(window.location.search);
  const result = {};
  
  for (const [key, value] of params) {
    result[key] = value;
  }
  
  return result;
};

// Obter parâmetro específico da URL
export const getUrlParam = (param) => {
  const params = new URLSearchParams(window.location.search);
  return params.get(param);
};

// Atualizar parâmetros da URL sem recarregar
export const updateUrlParams = (params) => {
  const url = new URL(window.location);
  
  Object.entries(params).forEach(([key, value]) => {
    if (value === null || value === undefined || value === '') {
      url.searchParams.delete(key);
    } else {
      url.searchParams.set(key, value);
    }
  });
  
  window.history.replaceState({}, '', url);
};

// Verificar se é URL válida
export const isValidUrl = (string) => {
  try {
    new URL(string);
    return true;
  } catch (_) {
    return false;
  }
};

// Obter domínio da URL
export const getDomain = (url) => {
  try {
    return new URL(url).hostname;
  } catch (_) {
    return '';
  }
};

// Criar link de WhatsApp
export const createWhatsAppLink = (phone, message = '') => {
  const cleanPhone = phone.replace(/[^\d]/g, '');
  const encodedMessage = encodeURIComponent(message);
  return `https://wa.me/${cleanPhone}?text=${encodedMessage}`;
};

// Criar link de email
export const createEmailLink = (email, subject = '', body = '') => {
  const encodedSubject = encodeURIComponent(subject);
  const encodedBody = encodeURIComponent(body);
  return `mailto:${email}?subject=${encodedSubject}&body=${encodedBody}`;
};
EOF

# src/utils/browserHelpers.js
cat > frontend/src/utils/browserHelpers.js << 'EOF'
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
EOF

echo "✅ Helpers e utilitários gerais criados com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • fileHelpers.js - Utilitários para arquivos e upload"
echo "   • dateHelpers.js - Manipulação de datas e horários"
echo "   • urlHelpers.js - Construção e manipulação de URLs"
echo "   • browserHelpers.js - Detecção de dispositivo e navegador"
echo ""
echo "🛠️ RECURSOS INCLUÍDOS:"
echo "   • Upload/download de arquivos com preview"
echo "   • Redimensionamento de imagens"
echo "   • Manipulação avançada de datas"
echo "   • Detecção de dispositivo e navegador"
echo "   • Clipboard, notificações e fullscreen"
echo "   • Links WhatsApp e email automáticos"
echo "   • Verificação de conectividade"
echo ""
echo "⏭️  Próximo: Páginas específicas (Processos, Atendimentos, etc)!"