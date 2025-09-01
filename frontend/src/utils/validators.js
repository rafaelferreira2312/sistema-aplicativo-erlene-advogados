import { validateCPF, validateCNPJ, validateEmail } from './formatters';

export const clientValidators = {
  // Validar campos obrigatórios
  validateRequired: (value, fieldName) => {
    if (!value || !value.toString().trim()) {
      return `${fieldName} é obrigatório`;
    }
    return null;
  },

  // Validar nome
  validateName: (name) => {
    if (!name || !name.trim()) {
      return 'Nome é obrigatório';
    }
    if (name.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    if (name.length > 255) {
      return 'Nome deve ter no máximo 255 caracteres';
    }
    return null;
  },

  // Validar documento (CPF/CNPJ)
  validateDocument: (document, type) => {
    if (!document || !document.trim()) {
      return `${type === 'PF' ? 'CPF' : 'CNPJ'} é obrigatório`;
    }

    const numbers = document.replace(/\D/g, '');
    
    if (type === 'PF') {
      if (numbers.length !== 11) {
        return 'CPF deve ter 11 dígitos';
      }
      if (!validateCPF(document)) {
        return 'CPF inválido';
      }
    } else {
      if (numbers.length !== 14) {
        return 'CNPJ deve ter 14 dígitos';
      }
      if (!validateCNPJ(document)) {
        return 'CNPJ inválido';
      }
    }
    
    return null;
  },

  // Validar email
  validateEmail: (email) => {
    if (!email || !email.trim()) {
      return 'Email é obrigatório';
    }
    if (!validateEmail(email)) {
      return 'Email inválido';
    }
    return null;
  },

  // Validar telefone
  validatePhone: (phone) => {
    if (!phone || !phone.trim()) {
      return 'Telefone é obrigatório';
    }
    
    const numbers = phone.replace(/\D/g, '');
    if (numbers.length < 10 || numbers.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    
    return null;
  },

  // Validar CEP
  validateCEP: (cep) => {
    if (!cep) return null; // CEP é opcional
    
    const numbers = cep.replace(/\D/g, '');
    if (numbers.length !== 8) {
      return 'CEP deve ter 8 dígitos';
    }
    
    return null;
  },

  // Validar senha do portal
  validatePortalPassword: (password, isRequired = true) => {
    if (isRequired && (!password || !password.trim())) {
      return 'Senha é obrigatória para acesso ao portal';
    }
    
    if (password && password.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  },

  // Validar formulário completo
  validateClientForm: (formData, isEdit = false) => {
    const errors = {};

    // Validações obrigatórias
    const nameError = clientValidators.validateName(formData.nome);
    if (nameError) errors.nome = nameError;

    const documentError = clientValidators.validateDocument(formData.cpf_cnpj, formData.tipo_pessoa);
    if (documentError) errors.cpf_cnpj = documentError;

    const emailError = clientValidators.validateEmail(formData.email);
    if (emailError) errors.email = emailError;

    const phoneError = clientValidators.validatePhone(formData.telefone);
    if (phoneError) errors.telefone = phoneError;

    // Validações opcionais
    if (formData.cep) {
      const cepError = clientValidators.validateCEP(formData.cep);
      if (cepError) errors.cep = cepError;
    }

    // Validar senha do portal se acesso habilitado
    if (formData.acesso_portal) {
      const passwordRequired = !isEdit; // Senha obrigatória apenas na criação
      const passwordError = clientValidators.validatePortalPassword(formData.senha_portal, passwordRequired);
      if (passwordError) errors.senha_portal = passwordError;
    }

    return {
      isValid: Object.keys(errors).length === 0,
      errors
    };
  }
};
