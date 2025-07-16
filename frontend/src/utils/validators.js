// Validação de CPF
export const isValidCPF = (cpf) => {
  if (!cpf) return false;
  
  // Remove pontos e traços
  const cleanCPF = cpf.replace(/[^\d]/g, '');
  
  // Verifica se tem 11 dígitos
  if (cleanCPF.length !== 11) return false;
  
  // Verifica se não são todos iguais
  if (/^(\d)\1{10}$/.test(cleanCPF)) return false;
  
  // Validação do primeiro dígito verificador
  let sum = 0;
  for (let i = 0; i < 9; i++) {
    sum += parseInt(cleanCPF.charAt(i)) * (10 - i);
  }
  let firstDigit = 11 - (sum % 11);
  if (firstDigit >= 10) firstDigit = 0;
  
  // Validação do segundo dígito verificador
  sum = 0;
  for (let i = 0; i < 10; i++) {
    sum += parseInt(cleanCPF.charAt(i)) * (11 - i);
  }
  let secondDigit = 11 - (sum % 11);
  if (secondDigit >= 10) secondDigit = 0;
  
  return firstDigit === parseInt(cleanCPF.charAt(9)) && 
         secondDigit === parseInt(cleanCPF.charAt(10));
};

// Validação de CNPJ
export const isValidCNPJ = (cnpj) => {
  if (!cnpj) return false;
  
  // Remove pontos, traços e barras
  const cleanCNPJ = cnpj.replace(/[^\d]/g, '');
  
  // Verifica se tem 14 dígitos
  if (cleanCNPJ.length !== 14) return false;
  
  // Verifica se não são todos iguais
  if (/^(\d)\1{13}$/.test(cleanCNPJ)) return false;
  
  // Validação do primeiro dígito verificador
  let sum = 0;
  let weight = 2;
  for (let i = 11; i >= 0; i--) {
    sum += parseInt(cleanCNPJ.charAt(i)) * weight;
    weight = weight === 9 ? 2 : weight + 1;
  }
  let firstDigit = sum % 11 < 2 ? 0 : 11 - (sum % 11);
  
  // Validação do segundo dígito verificador
  sum = 0;
  weight = 2;
  for (let i = 12; i >= 0; i--) {
    sum += parseInt(cleanCNPJ.charAt(i)) * weight;
    weight = weight === 9 ? 2 : weight + 1;
  }
  let secondDigit = sum % 11 < 2 ? 0 : 11 - (sum % 11);
  
  return firstDigit === parseInt(cleanCNPJ.charAt(12)) && 
         secondDigit === parseInt(cleanCNPJ.charAt(13));
};

// Validação de email
export const isValidEmail = (email) => {
  if (!email) return false;
  
  const emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i;
  return emailRegex.test(email);
};

// Validação de telefone brasileiro
export const isValidPhone = (phone) => {
  if (!phone) return false;
  
  const cleanPhone = phone.replace(/[^\d]/g, '');
  
  // Aceita formatos: (11) 99999-9999, (11) 9999-9999, 11999999999, 1199999999
  return /^(\d{2})(\d{4,5})(\d{4})$/.test(cleanPhone);
};

// Validação de CEP
export const isValidCEP = (cep) => {
  if (!cep) return false;
  
  const cleanCEP = cep.replace(/[^\d]/g, '');
  return /^\d{8}$/.test(cleanCEP);
};

// Validação de número de processo judicial
export const isValidProcessNumber = (processNumber) => {
  if (!processNumber) return false;
  
  const cleanNumber = processNumber.replace(/[^\d]/g, '');
  
  // Formato: NNNNNNN-DD.AAAA.J.TR.OOOO
  // 20 dígitos no total
  if (cleanNumber.length !== 20) return false;
  
  // Validação do dígito verificador
  const sequence = cleanNumber.substring(0, 7);
  const year = cleanNumber.substring(9, 13);
  const segment = cleanNumber.substring(13, 14);
  const court = cleanNumber.substring(14, 16);
  const origin = cleanNumber.substring(16, 20);
  
  const verificationNumber = sequence + year + segment + court + origin;
  const rest = parseInt(verificationNumber) % 97;
  const calculatedDigit = 98 - rest;
  const providedDigit = parseInt(cleanNumber.substring(7, 9));
  
  return calculatedDigit === providedDigit;
};

// Validação de senha forte
export const isStrongPassword = (password) => {
  if (!password) return false;
  
  // Pelo menos 8 caracteres, 1 maiúscula, 1 minúscula, 1 número
  const strongRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
  return strongRegex.test(password);
};

// Validação de data
export const isValidDate = (date) => {
  if (!date) return false;
  
  const dateObj = new Date(date);
  return dateObj instanceof Date && !isNaN(dateObj);
};

// Validação de data não futura
export const isNotFutureDate = (date) => {
  if (!isValidDate(date)) return false;
  
  const dateObj = new Date(date);
  const today = new Date();
  today.setHours(23, 59, 59, 999);
  
  return dateObj <= today;
};

// Validação de data não passada
export const isNotPastDate = (date) => {
  if (!isValidDate(date)) return false;
  
  const dateObj = new Date(date);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  return dateObj >= today;
};

// Validação de valor monetário
export const isValidMoney = (value) => {
  if (value === '' || value === null || value === undefined) return false;
  
  const numValue = typeof value === 'string' ? parseFloat(value.replace(/[^\d.-]/g, '')) : value;
  return !isNaN(numValue) && numValue >= 0;
};

// Validação de arquivo
export const isValidFile = (file, allowedTypes = [], maxSize = 50 * 1024 * 1024) => {
  if (!file) return { valid: false, error: 'Nenhum arquivo selecionado' };
  
  // Verificar tipo
  if (allowedTypes.length > 0) {
    const isValidType = allowedTypes.some(type => {
      if (type.startsWith('.')) {
        return file.name.toLowerCase().endsWith(type.toLowerCase());
      }
      return file.type === type;
    });
    
    if (!isValidType) {
      return { 
        valid: false, 
        error: `Tipo de arquivo não permitido. Tipos aceitos: ${allowedTypes.join(', ')}` 
      };
    }
  }
  
  // Verificar tamanho
  if (file.size > maxSize) {
    const maxSizeMB = Math.round(maxSize / (1024 * 1024));
    return { 
      valid: false, 
      error: `Arquivo muito grande. Tamanho máximo: ${maxSizeMB}MB` 
    };
  }
  
  return { valid: true };
};

// Função helper para validar múltiplos campos
export const validateFields = (data, rules) => {
  const errors = {};
  
  Object.entries(rules).forEach(([field, rule]) => {
    const value = data[field];
    
    if (rule.required && (!value || value.toString().trim() === '')) {
      errors[field] = rule.required === true ? 'Campo obrigatório' : rule.required;
      return;
    }
    
    if (value && rule.validator && !rule.validator(value)) {
      errors[field] = rule.message || 'Valor inválido';
      return;
    }
    
    if (value && rule.minLength && value.length < rule.minLength) {
      errors[field] = `Mínimo de ${rule.minLength} caracteres`;
      return;
    }
    
    if (value && rule.maxLength && value.length > rule.maxLength) {
      errors[field] = `Máximo de ${rule.maxLength} caracteres`;
      return;
    }
  });
  
  return {
    isValid: Object.keys(errors).length === 0,
    errors
  };
};
