import Joi from 'joi';

// Validação de CPF/CNPJ
export const cpfCnpjSchema = Joi.string()
  .pattern(/^(\d{11}|\d{14})$/)
  .messages({
    'string.pattern.base': 'CPF deve ter 11 dígitos ou CNPJ deve ter 14 dígitos',
  });

// Validação de email
export const emailSchema = Joi.string()
  .email()
  .required()
  .messages({
    'string.email': 'Email deve ter formato válido',
    'any.required': 'Email é obrigatório',
  });

// Validação de senha
export const passwordSchema = Joi.string()
  .min(6)
  .required()
  .messages({
    'string.min': 'Senha deve ter pelo menos 6 caracteres',
    'any.required': 'Senha é obrigatória',
  });

// Validação de data
export const dateSchema = Joi.date()
  .iso()
  .messages({
    'date.format': 'Data deve estar no formato ISO (YYYY-MM-DD)',
  });

// Validação de ID
export const idSchema = Joi.number()
  .integer()
  .positive()
  .required()
  .messages({
    'number.base': 'ID deve ser um número',
    'number.integer': 'ID deve ser um número inteiro',
    'number.positive': 'ID deve ser positivo',
    'any.required': 'ID é obrigatório',
  });

// Função helper para validar esquemas
export const validate = (schema: Joi.Schema, data: any) => {
  const { error, value } = schema.validate(data, {
    abortEarly: false,
    stripUnknown: true,
  });
  
  if (error) {
    const details = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message,
    }));
    
    throw {
      status: 400,
      message: 'Dados inválidos',
      details,
    };
  }
  
  return value;
};
