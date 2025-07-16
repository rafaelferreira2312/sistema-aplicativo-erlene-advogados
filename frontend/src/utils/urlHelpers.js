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
