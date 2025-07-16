#!/bin/bash

# Script 40 - Utilitários e Validadores
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/40-create-utils-validators.sh

echo "🔧 Criando utilitários e validadores..."

# src/utils/validators.js
cat > frontend/src/utils/validators.js << 'EOF'
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
EOF

# src/utils/formatters.js
cat > frontend/src/utils/formatters.js << 'EOF'
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
EOF

echo "✅ Utilitários e validadores criados com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • validators.js - Validações completas (CPF, CNPJ, email, etc)"
echo "   • formatters.js - Formatadores brasileiros (dinheiro, telefone, etc)"
echo ""
echo "🔧 RECURSOS INCLUÍDOS:"
echo "   • Validação de CPF/CNPJ com dígito verificador"
echo "   • Validação de processo judicial brasileiro"
echo "   • Formatadores com padrões brasileiros"
echo "   • Validação de arquivos com tipos e tamanho"
echo "   • Formatação de datas relativas e absolutas"
echo "   • Utilitários para texto (capitalize, truncate, slug)"
echo "   • Função helper validateFields para formulários"
echo ""
echo "⏭️  Próximo: Helpers gerais e utilitários de arquivo!"