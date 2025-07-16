// Formatação de CPF
export const formatCPF = (cpf) => {
  if (!cpf) return '';
  
  const cleanCPF = cpf.replace(/[^\d]/g, '');
  
  if (cleanCPF.length <= 11) {
    return cleanCPF
      .replace(/(\d{3})(\d)/, '$1.$2')
      .replace(/(\d{3})(\d)/, '$1.$2')
      .replace(/(\d{3})(\d{1,2})/, '$1-$2');
  }
  
  return cpf;
};

// Formatação de CNPJ
export const formatCNPJ = (cnpj) => {
  if (!cnpj) return '';
  
  const cleanCNPJ = cnpj.replace(/[^\d]/g, '');
  
  if (cleanCNPJ.length <= 14) {
    return cleanCNPJ
      .replace(/(\d{2})(\d)/, '$1.$2')
      .replace(/(\d{3})(\d)/, '$1.$2')
      .replace(/(\d{3})(\d)/, '$1/$2')
      .replace(/(\d{4})(\d{1,2})/, '$1-$2');
  }
  
  return cnpj;
};

// Formatação de telefone
export const formatPhone = (phone) => {
  if (!phone) return '';
  
  const cleanPhone = phone.replace(/[^\d]/g, '');
  
  if (cleanPhone.length <= 11) {
    if (cleanPhone.length <= 10) {
      return cleanPhone
        .replace(/(\d{2})(\d)/, '($1) $2')
        .replace(/(\d{4})(\d)/, '$1-$2');
    } else {
      return cleanPhone
        .replace(/(\d{2})(\d)/, '($1) $2')
        .replace(/(\d{5})(\d)/, '$1-$2');
    }
  }
  
  return phone;
};

// Formatação de CEP
export const formatCEP = (cep) => {
  if (!cep) return '';
  
  const cleanCEP = cep.replace(/[^\d]/g, '');
  
  if (cleanCEP.length <= 8) {
    return cleanCEP.replace(/(\d{5})(\d)/, '$1-$2');
  }
  
  return cep;
};

// Formatação de dinheiro
export const formatMoney = (value, options = {}) => {
  const {
    currency = 'BRL',
    locale = 'pt-BR',
    minimumFractionDigits = 2,
    maximumFractionDigits = 2
  } = options;
  
  if (value === null || value === undefined || value === '') return '';
  
  const numValue = typeof value === 'string' ? parseFloat(value) : value;
  
  if (isNaN(numValue)) return '';
  
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
    minimumFractionDigits,
    maximumFractionDigits
  }).format(numValue);
};

// Formatação de número
export const formatNumber = (value, options = {}) => {
  const {
    locale = 'pt-BR',
    minimumFractionDigits = 0,
    maximumFractionDigits = 2
  } = options;
  
  if (value === null || value === undefined || value === '') return '';
  
  const numValue = typeof value === 'string' ? parseFloat(value) : value;
  
  if (isNaN(numValue)) return '';
  
  return new Intl.NumberFormat(locale, {
    minimumFractionDigits,
    maximumFractionDigits
  }).format(numValue);
};

// Formatação de data
export const formatDate = (date, format = 'dd/MM/yyyy') => {
  if (!date) return '';
  
  const dateObj = new Date(date);
  
  if (isNaN(dateObj)) return '';
  
  const day = dateObj.getDate().toString().padStart(2, '0');
  const month = (dateObj.getMonth() + 1).toString().padStart(2, '0');
  const year = dateObj.getFullYear();
  const hours = dateObj.getHours().toString().padStart(2, '0');
  const minutes = dateObj.getMinutes().toString().padStart(2, '0');
  
  return format
    .replace('dd', day)
    .replace('MM', month)
    .replace('yyyy', year)
    .replace('HH', hours)
    .replace('mm', minutes);
};

// Formatação de data relativa
export const formatRelativeDate = (date) => {
  if (!date) return '';
  
  const dateObj = new Date(date);
  const now = new Date();
  const diffInSeconds = Math.floor((now - dateObj) / 1000);
  
  if (diffInSeconds < 60) return 'agora mesmo';
  if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)} minutos atrás`;
  if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)} horas atrás`;
  if (diffInSeconds < 2592000) return `${Math.floor(diffInSeconds / 86400)} dias atrás`;
  if (diffInSeconds < 31536000) return `${Math.floor(diffInSeconds / 2592000)} meses atrás`;
  
  return `${Math.floor(diffInSeconds / 31536000)} anos atrás`;
};

// Formatação de processo judicial
export const formatProcessNumber = (processNumber) => {
  if (!processNumber) return '';
  
  const cleanNumber = processNumber.replace(/[^\d]/g, '');
  
  if (cleanNumber.length === 20) {
    return cleanNumber.replace(
      /(\d{7})(\d{2})(\d{4})(\d{1})(\d{2})(\d{4})/,
      '$1-$2.$3.$4.$5.$6'
    );
  }
  
  return processNumber;
};

// Remover formatação de string
export const removeFormatting = (value) => {
  if (!value) return '';
  return value.replace(/[^\d]/g, '');
};

// Capitalizar primeira letra
export const capitalize = (str) => {
  if (!str) return '';
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
};

// Capitalizar nome próprio
export const capitalizeFullName = (name) => {
  if (!name) return '';
  
  const prepositions = ['de', 'da', 'do', 'das', 'dos', 'e'];
  
  return name
    .toLowerCase()
    .split(' ')
    .map(word => {
      if (prepositions.includes(word)) return word;
      return capitalize(word);
    })
    .join(' ');
};

// Truncar texto
export const truncateText = (text, maxLength = 50, suffix = '...') => {
  if (!text) return '';
  
  if (text.length <= maxLength) return text;
  
  return text.substring(0, maxLength) + suffix;
};

// Slug de URL
export const createSlug = (text) => {
  if (!text) return '';
  
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');
};
