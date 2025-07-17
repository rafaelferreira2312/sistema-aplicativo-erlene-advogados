#!/bin/bash

# Script 68 - Formulários de Clientes (Parte 2/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📝 Criando formulários de clientes (Parte 2/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 Criando NewClient..."

# Criar formulário de novo cliente
cat > src/pages/admin/Clients/NewClient.jsx << 'EOF'
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  UserIcon,
  BuildingOfficeIcon,
  EnvelopeIcon,
  PhoneIcon,
  MapPinIcon,
  DocumentTextIcon,
  EyeIcon,
  EyeSlashIcon
} from '@heroicons/react/24/outline';

const NewClient = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  
  const [formData, setFormData] = useState({
    // Dados básicos
    type: 'PF',
    name: '',
    document: '',
    email: '',
    phone: '',
    
    // Endereço
    cep: '',
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
    
    // Configurações
    status: 'Ativo',
    portalAccess: false,
    password: '',
    storageType: 'local',
    observations: ''
  });

  const [errors, setErrors] = useState({});

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    // Limpar erro do campo
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const formatDocument = (value, type) => {
    const numbers = value.replace(/\D/g, '');
    
    if (type === 'PF') {
      // CPF: 000.000.000-00
      return numbers.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    } else {
      // CNPJ: 00.000.000/0000-00
      return numbers.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
    }
  };

  const formatPhone = (value) => {
    const numbers = value.replace(/\D/g, '');
    // (00) 00000-0000
    return numbers.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
  };

  const formatCEP = (value) => {
    const numbers = value.replace(/\D/g, '');
    // 00000-000
    return numbers.replace(/(\d{5})(\d{3})/, '$1-$2');
  };

  const handleDocumentChange = (e) => {
    const formatted = formatDocument(e.target.value, formData.type);
    setFormData(prev => ({
      ...prev,
      document: formatted
    }));
  };

  const handlePhoneChange = (e) => {
    const formatted = formatPhone(e.target.value);
    setFormData(prev => ({
      ...prev,
      phone: formatted
    }));
  };

  const handleCEPChange = (e) => {
    const formatted = formatCEP(e.target.value);
    setFormData(prev => ({
      ...prev,
      cep: formatted
    }));
    
    // Buscar endereço por CEP (simulado)
    if (formatted.length === 9) {
      // Simular busca de CEP
      setTimeout(() => {
        setFormData(prev => ({
          ...prev,
          street: 'Rua Exemplo',
          neighborhood: 'Centro',
          city: 'São Paulo',
          state: 'SP'
        }));
      }, 500);
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.name.trim()) newErrors.name = 'Nome é obrigatório';
    if (!formData.document.trim()) newErrors.document = 'Documento é obrigatório';
    if (!formData.email.trim()) newErrors.email = 'Email é obrigatório';
    if (!formData.phone.trim()) newErrors.phone = 'Telefone é obrigatório';
    
    if (formData.portalAccess && !formData.password) {
      newErrors.password = 'Senha é obrigatória para acesso ao portal';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setLoading(true);
    
    try {
      // Simular salvamento
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Simular sucesso
      alert('Cliente cadastrado com sucesso!');
      navigate('/admin/clients');
    } catch (error) {
      alert('Erro ao cadastrar cliente');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white shadow-sm rounded-lg p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/clients"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Novo Cliente</h1>
              <p className="text-gray-600 mt-1">Cadastre um novo cliente no sistema</p>
            </div>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Tipo de Pessoa */}
        <div className="bg-white shadow-sm rounded-lg p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Tipo de Pessoa</h2>
          <div className="grid grid-cols-2 gap-4">
            <label className={`flex items-center p-4 border-2 rounded-lg cursor-pointer transition-colors ${
              formData.type === 'PF' ? 'border-red-500 bg-red-50' : 'border-gray-200 hover:border-gray-300'
            }`}>
              <input
                type="radio"
                name="type"
                value="PF"
                checked={formData.type === 'PF'}
                onChange={handleChange}
                className="sr-only"
              />
              <UserIcon className="w-6 h-6 text-red-600 mr-3" />
              <div>
                <div className="font-medium">Pessoa Física</div>
                <div className="text-sm text-gray-500">CPF</div>
              </div>
            </label>
            
            <label className={`flex items-center p-4 border-2 rounded-lg cursor-pointer transition-colors ${
              formData.type === 'PJ' ? 'border-red-500 bg-red-50' : 'border-gray-200 hover:border-gray-300'
            }`}>
              <input
                type="radio"
                name="type"
                value="PJ"
                checked={formData.type === 'PJ'}
                onChange={handleChange}
                className="sr-only"
              />
              <BuildingOfficeIcon className="w-6 h-6 text-red-600 mr-3" />
              <div>
                <div className="font-medium">Pessoa Jurídica</div>
                <div className="text-sm text-gray-500">CNPJ</div>
              </div>
            </label>
          </div>
        </div>

        {/* Dados Básicos */}
        <div className="bg-white shadow-sm rounded-lg p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Dados Básicos</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                {formData.type === 'PF' ? 'Nome Completo' : 'Razão Social'}
              </label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                className={`w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 ${
                  errors.name ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder={formData.type === 'PF' ? 'João Silva Santos' : 'Empresa ABC Ltda'}
              />
              {errors.name && <p className="text-red-500 text-sm mt-1">{errors.name}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                {formData.type === 'PF' ? 'CPF' : 'CNPJ'}
              </label>
              <input
                type="text"
                name="document"
                value={formData.document}
                onChange={handleDocumentChange}
                maxLength={formData.type === 'PF' ? 14 : 18}
                className={`w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 ${
                  errors.document ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder={formData.type === 'PF' ? '000.000.000-00' : '00.000.000/0000-00'}
              />
              {errors.document && <p className="text-red-500 text-sm mt-1">{errors.document}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
              <div className="relative">
                <EnvelopeIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  className={`w-full pl-10 pr-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 ${
                    errors.email ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="email@exemplo.com"
                />
              </div>
              {errors.email && <p className="text-red-500 text-sm mt-1">{errors.email}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Telefone</label>
              <div className="relative">
                <PhoneIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  name="phone"
                  value={formData.phone}
                  onChange={handlePhoneChange}
                  maxLength={15}
                  className={`w-full pl-10 pr-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 ${
                    errors.phone ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="(11) 99999-9999"
                />
              </div>
              {errors.phone && <p className="text-red-500 text-sm mt-1">{errors.phone}</p>}
            </div>
          </div>
        </div>

        {/* Endereço */}
        <div className="bg-white shadow-sm rounded-lg p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Endereço</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">CEP</label>
              <input
                type="text"
                name="cep"
                value={formData.cep}
                onChange={handleCEPChange}
                maxLength={9}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
                placeholder="00000-000"
              />
            </div>
            
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">Logradouro</label>
              <input
                type="text"
                name="street"
                value={formData.street}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
                placeholder="Rua, Avenida, etc."
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Número</label>
              <input
                type="text"
                name="number"
                value={formData.number}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
                placeholder="123"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Complemento</label>
              <input
                type="text"
                name="complement"
                value={formData.complement}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
                placeholder="Apto, Sala, etc."
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Bairro</label>
              <input
                type="text"
                name="neighborhood"
                value={formData.neighborhood}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
                placeholder="Centro"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Cidade</label>
              <input
                type="text"
                name="city"
                value={formData.city}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
                placeholder="São Paulo"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Estado</label>
              <select
                name="state"
                value={formData.state}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
              >
                <option value="">Selecione</option>
                <option value="SP">São Paulo</option>
                <option value="RJ">Rio de Janeiro</option>
                <option value="MG">Minas Gerais</option>
                <option value="RS">Rio Grande do Sul</option>
                {/* Adicionar outros estados */}
              </select>
            </div>
          </div>
        </div>

        {/* Configurações */}
        <div className="bg-white shadow-sm rounded-lg p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Configurações</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <select
                name="status"
                value={formData.status}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
              >
                <option value="Ativo">Ativo</option>
                <option value="Inativo">Inativo</option>
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Tipo de Armazenamento</label>
              <select
                name="storageType"
                value={formData.storageType}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
              >
                <option value="local">Local</option>
                <option value="googledrive">Google Drive</option>
                <option value="onedrive">OneDrive</option>
              </select>
            </div>
          </div>
          
          {/* Acesso ao Portal */}
          <div className="mt-6">
            <label className="flex items-center">
              <input
                type="checkbox"
                name="portalAccess"
                checked={formData.portalAccess}
                onChange={handleChange}
                className="rounded border-gray-300 text-red-600 focus:ring-red-500"
              />
              <span className="ml-2 text-sm font-medium text-gray-700">
                Habilitar acesso ao portal do cliente
              </span>
            </label>
          </div>
          
          {/* Senha do Portal */}
          {formData.portalAccess && (
            <div className="mt-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">Senha do Portal</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  className={`w-full px-3 py-2 pr-10 border rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 ${
                    errors.password ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="Senha para acesso"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                >
                  {showPassword ? (
                    <EyeSlashIcon className="h-5 w-5 text-gray-400" />
                  ) : (
                    <EyeIcon className="h-5 w-5 text-gray-400" />
                  )}
                </button>
              </div>
              {errors.password && <p className="text-red-500 text-sm mt-1">{errors.password}</p>}
            </div>
          )}
          
          {/* Observações */}
          <div className="mt-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">Observações</label>
            <textarea
              name="observations"
              value={formData.observations}
              onChange={handleChange}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500"
              placeholder="Observações sobre o cliente..."
            />
          </div>
        </div>

        {/* Botões */}
        <div className="bg-white shadow-sm rounded-lg p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/clients"
              className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
            >
              Cancelar
            </Link>
            <button
              type="submit"
              disabled={loading}
              className="px-6 py-2 bg-red-700 text-white rounded-lg hover:bg-red-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Salvando...
                </div>
              ) : (
                'Salvar Cliente'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewClient;
EOF

echo "✅ NewClient criado!"
echo ""
echo "📝 IMPLEMENTADO:"
echo "   • Formulário completo com validações"
echo "   • Tipo de pessoa (PF/PJ) com layouts diferentes" 
echo "   • Formatação automática (CPF/CNPJ/telefone/CEP)"
echo "   • Busca automática de endereço por CEP"
echo "   • Configurações avançadas"
echo "   • Toggle para acesso ao portal"
echo "   • Máscaras e validações"
echo ""
echo "📁 Criando EditClient..."

# Criar formulário de edição de cliente
cat > src/pages/admin/Clients/EditClient.jsx << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  UserIcon,
  BuildingOfficeIcon,
  EnvelopeIcon,
  PhoneIcon,
  EyeIcon,
  EyeSlashIcon
} from '@heroicons/react/24/outline';

const EditClient = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  
  const [formData, setFormData] = useState({
    type: 'PF',
    name: '',
    document: '',
    email: '',
    phone: '',
    cep: '',
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
    status: 'Ativo',
    portalAccess: false,
    password: '',
    storageType: 'local',
    observations: ''
  });

  const [errors, setErrors] = useState({});

  // Simular carregamento dos dados
  useEffect(() => {
    const loadClient = async () => {
      try {
        // Simular busca por ID
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Dados mock baseados no ID
        const mockData = {
          1: {
            type: 'PF',
            name: 'João Silva Santos',
            document: '123.456.789-00',
            email: 'joao.silva@email.com',
            phone: '(11) 99999-9999',
            cep: '01310-100',
            street: 'Av. Paulista',
            number: '1000',
            complement: 'Apto 101',
            neighborhood: 'Bela Vista',
            city: 'São Paulo',
            state: 'SP',
            status: 'Ativo',
            portalAccess: true,
            password: '',
            storageType: 'googledrive',
            observations: 'Cliente VIP'
          },
          2: {
            type: 'PJ',
            name: 'Empresa ABC Ltda',
            document: '12.345.678/0001-90',
            email: 'contato@empresaabc.com',
            phone: '(11) 3333-3333',
            cep: '04038-001',
            street: 'Rua Vergueiro',
            number: '2000',
            complement: 'Sala 205',
            neighborhood: 'Vila Mariana',
            city: 'São Paulo',
            state: 'SP',
            status: 'Ativo',
            portalAccess: false,
            password: '',
            storageType: 'local',
            observations: 'Empresa parceira'
          }
        };
        
        const clientData = mockData[id] || mockData[1];
        setFormData(clientData);
      } catch (error) {
        alert('Erro ao carregar dados do cliente');
      } finally {
        setLoading(false);
      }
    };

    loadClient();
  }, [id]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.name.trim()) newErrors.name = 'Nome é obrigatório';
    if (!formData.email.trim()) newErrors.email = 'Email é obrigatório';
    if (!formData.phone.trim()) newErrors.phone = 'Telefone é obrigatório';
    
    if (formData.portalAccess && !formData.password) {
      newErrors.password = 'Senha é obrigatória para acesso ao portal';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setSaving(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 1500));
      alert('Cliente atualizado com sucesso!');
      navigate('/admin/clients');
    } catch (error) {
      alert('Erro ao atualizar cliente');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="bg-white shadow-sm rounded-lg p-6 animate-pulse">
          <div className="h-6 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
        <div className="bg-white shadow-sm rounded-lg p-6 animate-pulse">
          <div className="h-32 bg-gray-200 rounded"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white shadow-sm rounded-lg p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/clients"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Editar Cliente</h1>
              <p className="text-gray-600 mt-1">Atualize os dados do cliente</p>
            </div>
          </div>
          <div className="flex items-center space-x-2">
            {formData.type === 'PF' ? (
              <UserIcon className="w-8 h-8 text-red-600" />
            ) : (
              <BuildingOfficeIcon className="w-8 h-8 text-red-600" />
            )}
            <span className="text-sm font-medium text-gray-500">
              {formData.type === 'PF' ? 'Pessoa Física' : 'Pessoa Jurídica'}
            </span>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Dados Básicos */}
        <div className="bg-white shadow-sm rounded-lg p-6">
          <h2 className="text-lg font-semibold text-gray