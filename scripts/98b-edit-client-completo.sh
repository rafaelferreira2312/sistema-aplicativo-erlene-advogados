#!/bin/bash

# Script 98b - EditClient Completo (Sistema Erlene Advogados)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)
# Enumeração: 98b

echo "✏️ Criando EditClient completo (Script 98b)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar estrutura frontend
if [ ! -d "frontend/src" ]; then
    echo "❌ Erro: Estrutura frontend não encontrada"
    exit 1
fi

echo "📝 Criando formulário de edição de cliente completo..."

# Criar estrutura se não existir
mkdir -p frontend/src/components/clients

# Fazer backup se existe
if [ -f "frontend/src/components/clients/EditClient.js" ]; then
    cp frontend/src/components/clients/EditClient.js frontend/src/components/clients/EditClient.js.backup.$(date +%Y%m%d_%H%M%S)
fi

# Criar EditClient.js seguindo padrão EXATO do projeto
cat > frontend/src/components/clients/EditClient.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  UserIcon,
  BuildingOfficeIcon,
  EnvelopeIcon,
  PhoneIcon,
  MapPinIcon,
  EyeIcon,
  EyeSlashIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon,
  TrashIcon
} from '@heroicons/react/24/outline';

const EditClient = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  
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
    state: 'SP',
    status: 'Ativo',
    portalAccess: false,
    password: '',
    storageType: 'local',
    observations: ''
  });

  const [errors, setErrors] = useState({});

  // Simular carregamento dos dados do cliente
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
            observations: 'Cliente VIP - atendimento prioritário'
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
          },
          3: {
            type: 'PF',
            name: 'Maria Oliveira Costa',
            document: '987.654.321-00',
            email: 'maria.oliveira@email.com',
            phone: '(11) 88888-8888',
            cep: '01234-567',
            street: 'Rua das Flores',
            number: '123',
            complement: '',
            neighborhood: 'Centro',
            city: 'São Paulo',
            state: 'SP',
            status: 'Inativo',
            portalAccess: false,
            password: '',
            storageType: 'onedrive',
            observations: 'Cliente com pendências'
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
      return numbers.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
    } else {
      return numbers.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5');
    }
  };

  const formatPhone = (value) => {
    const numbers = value.replace(/\D/g, '');
    return numbers.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
  };

  const formatCEP = (value) => {
    const numbers = value.replace(/\D/g, '');
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

  const handleCEPChange = async (e) => {
    const formatted = formatCEP(e.target.value);
    setFormData(prev => ({
      ...prev,
      cep: formatted
    }));
    
    // Buscar endereço por CEP
    if (formatted.length === 9) {
      try {
        const response = await fetch(`https://viacep.com.br/ws/${formatted.replace('-', '')}/json/`);
        const data = await response.json();
        
        if (!data.erro) {
          setFormData(prev => ({
            ...prev,
            street: data.logradouro,
            neighborhood: data.bairro,
            city: data.localidade,
            state: data.uf
          }));
        }
      } catch (error) {
        console.log('Erro ao buscar CEP:', error);
      }
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.name.trim()) newErrors.name = 'Nome é obrigatório';
    if (!formData.document.trim()) newErrors.document = 'Documento é obrigatório';
    if (!formData.email.trim()) newErrors.email = 'Email é obrigatório';
    if (!formData.phone.trim()) newErrors.phone = 'Telefone é obrigatório';
    
    // Validar email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (formData.email && !emailRegex.test(formData.email)) {
      newErrors.email = 'Email inválido';
    }
    
    if (formData.portalAccess && !formData.password && !id) {
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
      // Simular atualização
      await new Promise(resolve => setTimeout(resolve, 1500));
      alert('Cliente atualizado com sucesso!');
      navigate('/admin/clientes');
    } catch (error) {
      alert('Erro ao atualizar cliente');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      alert('Cliente excluído com sucesso!');
      navigate('/admin/clientes');
    } catch (error) {
      alert('Erro ao excluir cliente');
    }
  };

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
        <div className="space-y-4">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="bg-white rounded-xl p-6 animate-pulse">
              <div className="h-6 bg-gray-200 rounded mb-4 w-1/3"></div>
              <div className="grid grid-cols-2 gap-4">
                <div className="h-12 bg-gray-200 rounded"></div>
                <div className="h-12 bg-gray-200 rounded"></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="space-y-8">
        {/* Header */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Link
                to="/admin/clientes"
                className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <ArrowLeftIcon className="w-5 h-5" />
              </Link>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Editar Cliente</h1>
                <p className="text-lg text-gray-600 mt-2">Atualize as informações do cliente</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="text-right">
                <div className="text-sm text-gray-500">Tipo de pessoa</div>
                <div className="flex items-center space-x-2">
                  {formData.type === 'PF' ? (
                    <UserIcon className="w-6 h-6 text-primary-600" />
                  ) : (
                    <BuildingOfficeIcon className="w-6 h-6 text-primary-600" />
                  )}
                  <span className="text-lg font-medium text-gray-900">
                    {formData.type === 'PF' ? 'Pessoa Física' : 'Pessoa Jurídica'}
                  </span>
                </div>
              </div>
              <button
                onClick={() => setShowDeleteModal(true)}
                className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors flex items-center space-x-2"
              >
                <TrashIcon className="w-4 h-4" />
                <span>Excluir</span>
              </button>
            </div>
          </div>
        </div>
EOF

echo "✅ EditClient.js - PARTE 1 criada (até linha 300)!"

echo "📝 2. Atualizando App.js para incluir rota do EditClient..."

# Fazer backup do App.js
cp frontend/src/App.js frontend/src/App.js.backup.editclient.$(date +%Y%m%d_%H%M%S)

# Adicionar import do EditClient se não existir
if ! grep -q "import EditClient" frontend/src/App.js; then
    sed -i '/import NewClient/a import EditClient from '\''./components/clients/EditClient'\'';' frontend/src/App.js
fi

# Adicionar rota do EditClient se não existir
if ! grep -q 'path="clientes/:id"' frontend/src/App.js; then
    sed -i '/path="clientes\/novo"/a\                    <Route path="clientes/:id" element={<EditClient />} />' frontend/src/App.js
fi

echo "✅ Rota do EditClient adicionada ao App.js!"

echo ""
echo "📋 SCRIPT 98b - PARTE 1 CONCLUÍDA:"
echo "   • EditClient.js estrutura base criada"
echo "   • Header completo com botão excluir"
echo "   • Carregamento de dados simulado por ID"
echo "   • 3 clientes mock para teste (IDs 1, 2, 3)"
echo "   • Formatação automática de campos"
echo "   • Validação completa de formulário"
echo "   • Estados de loading e saving"
echo "   • Rota /admin/clientes/:id configurada"
echo ""
echo "🎯 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Carregamento de dados por ID"
echo "   • Formatação de CPF/CNPJ/telefone/CEP"
echo "   • Busca automática de endereço"
echo "   • Validação de email e campos obrigatórios"
echo "   • Interface visual para tipo de pessoa"
echo "   • Botão de exclusão no header"
echo ""
echo "📁 ARQUIVOS CRIADOS/ATUALIZADOS:"
echo "   • frontend/src/components/clients/EditClient.js (parcial)"
echo "   • App.js com nova rota"
echo ""
echo "🧪 TESTE A ROTA:"
echo "   • http://localhost:3000/admin/clientes/1"
echo "   • http://localhost:3000/admin/clientes/2"
echo "   • http://localhost:3000/admin/clientes/3"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Formulários de dados básicos, endereço, configurações"
echo "   • Modal de confirmação de exclusão"
echo "   • Botões de ação (cancelar/salvar)"
echo "   • Sistema completo de portal e observações"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2 completar o EditClient!"