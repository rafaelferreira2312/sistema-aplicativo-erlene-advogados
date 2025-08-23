import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const PortalLogin = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    cpf_cnpj: '',
    senha: ''
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  // Mock de 3 clientes para demonstração
  const mockClientes = [
    { 
      id: 1, 
      nome: 'João Silva Santos', 
      cpf: '123.456.789-00', 
      senha: '123456',
      tipo: 'PF',
      processos: 3,
      documentos: 12,
      pagamentos_pendentes: 2,
      valor_pendente: 2500.00
    },
    { 
      id: 2, 
      nome: 'Empresa ABC Ltda', 
      cnpj: '12.345.678/0001-90', 
      senha: '654321',
      tipo: 'PJ',
      processos: 5,
      documentos: 18,
      pagamentos_pendentes: 1,
      valor_pendente: 5000.00
    },
    { 
      id: 3, 
      nome: 'Maria Oliveira Costa', 
      cpf: '987.654.321-00', 
      senha: 'senha123',
      tipo: 'PF',
      processos: 1,
      documentos: 8,
      pagamentos_pendentes: 0,
      valor_pendente: 0
    }
  ];

  const formatCpfCnpj = (value) => {
    const numbers = value.replace(/\D/g, '');
    
    if (numbers.length <= 11) {
      // CPF
      return numbers.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    } else {
      // CNPJ
      return numbers.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    
    if (name === 'cpf_cnpj') {
      setFormData(prev => ({
        ...prev,
        [name]: formatCpfCnpj(value)
      }));
    } else {
      setFormData(prev => ({
        ...prev,
        [name]: value
      }));
    }
    
    // Limpar erro do campo
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.cpf_cnpj.trim()) {
      newErrors.cpf_cnpj = 'CPF/CNPJ é obrigatório';
    }
    
    if (!formData.senha.trim()) {
      newErrors.senha = 'Senha é obrigatória';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setLoading(true);
    
    try {
      // Simular verificação de login
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      const cliente = mockClientes.find(c => 
        (c.cpf === formData.cpf_cnpj || c.cnpj === formData.cpf_cnpj) && 
        c.senha === formData.senha
      );
      
      if (cliente) {
        // Salvar dados do cliente logado
        localStorage.setItem('portalAuth', 'true');
        localStorage.setItem('clienteData', JSON.stringify(cliente));
        localStorage.setItem('userType', 'cliente');
        
        navigate('/portal/dashboard');
      } else {
        setErrors({
          submit: 'CPF/CNPJ ou senha incorretos'
        });
      }
    } catch (error) {
      setErrors({
        submit: 'Erro ao realizar login. Tente novamente.'
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="text-center">
          <div className="mx-auto h-16 w-16 bg-gradient-to-r from-red-700 to-red-800 rounded-lg flex items-center justify-center mb-6">
            <span className="text-white font-bold text-2xl">E</span>
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Portal do Cliente
          </h1>
          <p className="text-gray-600">
            Erlene Advogados - Acompanhe seus processos
          </p>
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow-lg shadow-red-100 sm:rounded-lg sm:px-10">
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="cpf_cnpj" className="block text-sm font-medium text-gray-700">
                CPF/CNPJ
              </label>
              <div className="mt-1">
                <input
                  id="cpf_cnpj"
                  name="cpf_cnpj"
                  type="text"
                  value={formData.cpf_cnpj}
                  onChange={handleChange}
                  className={`appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-red-500 focus:border-red-500 sm:text-sm ${
                    errors.cpf_cnpj ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="000.000.000-00 ou 00.000.000/0001-00"
                />
              </div>
              {errors.cpf_cnpj && (
                <p className="mt-2 text-sm text-red-600">{errors.cpf_cnpj}</p>
              )}
            </div>

            <div>
              <label htmlFor="senha" className="block text-sm font-medium text-gray-700">
                Senha
              </label>
              <div className="mt-1">
                <input
                  id="senha"
                  name="senha"
                  type="password"
                  value={formData.senha}
                  onChange={handleChange}
                  className={`appearance-none block w-full px-3 py-2 border rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-red-500 focus:border-red-500 sm:text-sm ${
                    errors.senha ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="Digite sua senha"
                />
              </div>
              {errors.senha && (
                <p className="mt-2 text-sm text-red-600">{errors.senha}</p>
              )}
            </div>

            {errors.submit && (
              <div className="rounded-md bg-red-50 p-4">
                <p className="text-sm text-red-700">{errors.submit}</p>
              </div>
            )}

            <div>
              <button
                type="submit"
                disabled={loading}
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-700 hover:bg-red-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? (
                  <div className="flex items-center">
                    <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent mr-2"></div>
                    Entrando...
                  </div>
                ) : (
                  'Entrar'
                )}
              </button>
            </div>
          </form>

          <div className="mt-6">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-300" />
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-white text-gray-500">Dados para teste</span>
              </div>
            </div>

            <div className="mt-4 space-y-2 text-sm text-gray-600">
              <div className="bg-gray-50 p-3 rounded">
                <strong>Cliente PF:</strong> 123.456.789-00 / senha: 123456
              </div>
              <div className="bg-gray-50 p-3 rounded">
                <strong>Cliente PJ:</strong> 12.345.678/0001-90 / senha: 654321
              </div>
              <div className="bg-gray-50 p-3 rounded">
                <strong>Cliente PF 2:</strong> 987.654.321-00 / senha: senha123
              </div>
            </div>
          </div>
        </div>
      </div>

      <footer className="mt-8 text-center text-sm text-gray-500">
        <p>© 2024 Erlene Advogados. Todos os direitos reservados.</p>
        <div className="mt-2">
          <a 
            href="/login" 
            className="text-red-600 hover:text-red-700 text-xs"
          >
            Acesso restrito para advogados
          </a>
        </div>
      </footer>
    </div>
  );
};

export default PortalLogin;
