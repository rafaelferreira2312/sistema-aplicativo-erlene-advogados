import { useState, useCallback } from 'react';

export const useForm = (initialValues = {}, validationSchema = {}) => {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Atualizar um campo
  const setValue = useCallback((name, value) => {
    setValues(prev => ({
      ...prev,
      [name]: value
    }));

    // Limpar erro quando o campo é modificado
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: undefined
      }));
    }
  }, [errors]);

  // Atualizar múltiplos campos
  const setValues = useCallback((newValues) => {
    setValues(prev => ({
      ...prev,
      ...newValues
    }));
  }, []);

  // Marcar campo como tocado
  const setFieldTouched = useCallback((name, touched = true) => {
    setTouched(prev => ({
      ...prev,
      [name]: touched
    }));
  }, []);

  // Validar um campo específico
  const validateField = useCallback((name, value) => {
    const fieldValidation = validationSchema[name];
    if (!fieldValidation) return '';

    if (typeof fieldValidation === 'function') {
      return fieldValidation(value, values);
    }

    return '';
  }, [validationSchema, values]);

  // Validar todo o formulário
  const validateForm = useCallback(() => {
    const newErrors = {};
    let isValid = true;

    Object.keys(validationSchema).forEach(name => {
      const error = validateField(name, values[name]);
      if (error) {
        newErrors[name] = error;
        isValid = false;
      }
    });

    setErrors(newErrors);
    return isValid;
  }, [validationSchema, values, validateField]);

  // Handler para mudança de campo
  const handleChange = useCallback((event) => {
    const { name, value, type, checked } = event.target;
    const fieldValue = type === 'checkbox' ? checked : value;
    
    setValue(name, fieldValue);
  }, [setValue]);

  // Handler para blur
  const handleBlur = useCallback((event) => {
    const { name } = event.target;
    setFieldTouched(name, true);
    
    const error = validateField(name, values[name]);
    if (error) {
      setErrors(prev => ({
        ...prev,
        [name]: error
      }));
    }
  }, [setFieldTouched, validateField, values]);

  // Handler para submit
  const handleSubmit = useCallback((onSubmit) => {
    return async (event) => {
      if (event) {
        event.preventDefault();
      }

      // Marcar todos os campos como tocados
      const allTouched = Object.keys(values).reduce((acc, key) => {
        acc[key] = true;
        return acc;
      }, {});
      setTouched(allTouched);

      // Validar formulário
      const isValid = validateForm();
      
      if (isValid) {
        setIsSubmitting(true);
        try {
          await onSubmit(values);
        } catch (error) {
          console.error('Erro no submit:', error);
        } finally {
          setIsSubmitting(false);
        }
      }
    };
  }, [values, validateForm]);

  // Reset do formulário
  const reset = useCallback((newValues = initialValues) => {
    setValues(newValues);
    setErrors({});
    setTouched({});
    setIsSubmitting(false);
  }, [initialValues]);

  // Verificar se o formulário é válido
  const isValid = Object.keys(errors).length === 0;

  return {
    values,
    errors,
    touched,
    isSubmitting,
    isValid,
    setValue,
    setValues,
    setFieldTouched,
    handleChange,
    handleBlur,
    handleSubmit,
    validateField,
    validateForm,
    reset,
  };
};
