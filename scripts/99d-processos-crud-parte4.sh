#!/bin/bash

# Script 99c - EditProcess Completo (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)
# Enumeração: 99c

echo "⚖️ Criando EditProcess completo (Parte 1/2 - Script 99c)..."

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

echo "📝 Criando formulário de edição de processo (estrutura base)..."

# Criar estrutura se não existir
mkdir -p frontend/src/components/processes

# Fazer backup se existe
if [ -f "frontend/src/components/processes/EditProcess.js" ]; then
    cp frontend/src/components/processes/EditProcess.js frontend/src/components/processes/EditProcess.js.backup.$(date +%Y%m%d_%H%M%S)
fi

# Criar EditProcess.js seguindo padrão EXATO do EditClient.js (Parte 1)
cat > frontend/src/components/processes/EditProcess.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  ScaleIcon,
  UserIcon,
  DocumentTextIcon,
  CurrencyDollarIcon,
  BuildingLibraryIcon,
  CalendarIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  TrashIcon
} from '@heroicons/react/24/outline';

const EditProcess = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [clients, setClients] = useState([]);
  const [advogados, setAdvogados] = useState([]);
  
  const [formData, setFormData] = useState({
    number: '',
    clienteId: '',
    subject: '',
    type: '',
    status: 'Em Andamento',
    advogadoId: '',
    court: '',
    judge: '',
    value: '',
    priority: 'Média',
    confidential: false,
    startDate: '',
    expectedEndDate: '',
    observations: '',
    strategy: ''
  });

  const [errors, setErrors] = useState({});

  // Mock data
  const mockClients = [
    { id: 1, name: 'João Silva Santos', type: 'PF', document: '123.456.789-00' },
    { id: 2, name: 'Empresa ABC Ltda', type: 'PJ', document: '12.345.678/0001-90' },
    { id: 3, name: 'Maria Oliveira Costa', type: 'PF', document: '987.654.321-00' },
    { id: 4, name: 'Tech Solutions S.A.', type: 'PJ', document: '11.222.333/0001-44' },
    { id: 5, name: 'Carlos Pereira Lima', type: 'PF', document: '555.666.777-88' }
  ];

  const mockAdvogados = [
    { id: 1, name: 'Dr. Carlos Oliveira', oab: 'OAB/SP 123456', specialty: 'Cível' },
    { id: 2, name: 'Dra. Maria Santos', oab: 'OAB/SP 234567', specialty: 'Trabalhista' },
    { id: 3, name: 'Dr. Pedro Costa', oab: 'OAB/SP 345678', specialty: 'Família' },
    { id: 4, name: 'Dra. Ana Silva', oab: 'OAB/SP 456789', specialty: 'Cível' },
    { id: 5, name: 'Dra. Erlene Chaves Silva', oab: 'OAB/SP 567890', specialty: 'Sucessões' }
  ];

  // Simular carregamento dos dados do processo
  useEffect(() => {
    const loadProcess = async () => {
      try {
        // Simular busca por ID
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Dados mock baseados no ID
        const mockData = {
          1: {
            number: '1001234-56.2024.8.26.0001',
            clienteId: '1',
            subject: 'Ação de Cobrança',
            type: 'Cível',
            status: 'Em Andamento',
            advogadoId: '1',
            court: '1ª Vara Cível - SP',
            judge: 'Dr. João da Silva',
            value: 'R$ 50.000,00',
            priority: 'Média',
            confidential: false,
            startDate: '2024-01-15',
            expectedEndDate: '2024-12-15',
            observations: 'Cliente VIP - priorizar andamentos',
            strategy: 'Utilizar jurisprudência do STJ sobre prescrição'
          },
          2: {
            number: '2002345-67.2024.8.26.0002',
            clienteId: '2',
            subject: 'Ação Trabalhista',
            type: 'Trabalhista',
            status: 'Aguardando',
            advogadoId: '2',
            court: '2ª Vara do Trabalho - SP',
            judge: 'Dra. Maria Fernanda',
            value: 'R$ 120.000,00',
            priority: 'Alta',
            confidential: true,
            startDate: '2024-01-20',
            expectedEndDate: '2024-10-20',
            observations: 'Processo complexo com múltiplas testemunhas',
            strategy: 'Foco na comprovação de vínculo empregatício'
          },
          3: {
            number: '3003456-78.2024.8.26.0003',
            clienteId: '3',
            subject: 'Divórcio Consensual',
            type: 'Família',
            status: 'Concluído',
            advogadoId: '3',
            court: '1ª Vara de Família - SP',
            judge: 'Dr. Roberto Santos',
            value: 'R$ 15.000,00',
            priority: 'Baixa',
            confidential: false,
            startDate: '2024-02-01',
            expectedEndDate: '2024-06-01',
            observations: 'Processo finalizado com acordo',
            strategy: 'Divórcio consensual sem filhos menores'
          }
        };
        
        const processData = mockData[id] || mockData[1];
        setFormData(processData);
        setClients(mockClients);
        setAdvogados(mockAdvogados);
      } catch (error) {
        alert('Erro ao carregar dados do processo');
      } finally {
        setLoading(false);
      }
    };

    loadProcess();
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

  const formatCurrency = (value) => {
    const cleanValue = value.replace(/[^\d,.-]/g, '');
    const numbers = cleanValue.replace(/\D/g, '');
    
    if (!numbers) return '';
    
    const amount = parseInt(numbers) / 100;
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(amount);
  };

  const handleValueChange = (e) => {
    const formatted = formatCurrency(e.target.value);
    setFormData(prev => ({
      ...prev,
      value: formatted
    }));
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.number.trim()) newErrors.number = 'Número do processo é obrigatório';
    if (!formData.clienteId) newErrors.clienteId = 'Cliente é obrigatório';
    if (!formData.subject.trim()) newErrors.subject = 'Assunto é obrigatório';
    if (!formData.type) newErrors.type = 'Tipo do processo é obrigatório';
    if (!formData.advogadoId) newErrors.advogadoId = 'Advogado responsável é obrigatório';
    if (!formData.startDate) newErrors.startDate = 'Data de início é obrigatória';
    
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
      alert('Processo atualizado com sucesso!');
      navigate('/admin/processos');
    } catch (error) {
      alert('Erro ao atualizar processo');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    try {
      await new Promise(resolve => setTimeout(resolve, 1000));
      alert('Processo excluído com sucesso!');
      navigate('/admin/processos');
    } catch (error) {
      alert('Erro ao excluir processo');
    }
  };

  const getSelectedClient = () => {
    return clients.find(c => c.id.toString() === formData.clienteId);
  };

  const getSelectedAdvogado = () => {
    return advogados.find(a => a.id.toString() === formData.advogadoId);
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Em Andamento': return 'text-blue-600 bg-blue-100';
      case 'Aguardando': return 'text-yellow-600 bg-yellow-100';
      case 'Concluído': return 'text-green-600 bg-green-100';
      case 'Suspenso': return 'text-red-600 bg-red-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'Urgente': return 'text-red-600 bg-red-100';
      case 'Alta': return 'text-orange-600 bg-orange-100';
      case 'Média': return 'text-yellow-600 bg-yellow-100';
      case 'Baixa': return 'text-green-600 bg-green-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const selectedClient = getSelectedClient();
  const selectedAdvogado = getSelectedAdvogado();

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
                to="/admin/processos"
                className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <ArrowLeftIcon className="w-5 h-5" />
              </Link>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Editar Processo</h1>
                <p className="text-lg text-gray-600 mt-2">Atualize as informações do processo</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="text-right">
                <div className="text-sm text-gray-500">Status atual</div>
                <div className="flex items-center space-x-2">
                  <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getStatusColor(formData.status)}`}>
                    {formData.status}
                  </span>
                  <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getPriorityColor(formData.priority)}`}>
                    {formData.priority}
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

echo "✅ EditProcess.js - PARTE 1 criada (até linha 300)!"

echo "📝 2. Atualizando App.js para incluir rota do EditProcess..."

# Fazer backup do App.js
cp frontend/src/App.js frontend/src/App.js.backup.editprocess.$(date +%Y%m%d_%H%M%S)

# Adicionar import do EditProcess se não existir
if ! grep -q "import EditProcess" frontend/src/App.js; then
    sed -i '/import NewProcess/a import EditProcess from '\''./components/processes/EditProcess'\'';' frontend/src/App.js
fi

# Adicionar rota do EditProcess se não existir
if ! grep -q 'path="processos/:id"' frontend/src/App.js; then
    sed -i '/path="processos\/novo"/a\                    <Route path="processos/:id" element={<EditProcess />} />' frontend/src/App.js
fi

echo "✅ Rota do EditProcess adicionada ao App.js!"

echo ""
echo "📋 SCRIPT 99c - PARTE 1 CONCLUÍDA:"
echo "   • EditProcess.js estrutura base criada"
echo "   • Header completo com status e prioridade visual"
echo "   • Carregamento de dados simulado por ID (3 processos)"
echo "   • Funções de validação e formatação"
echo "   • Estados de loading, saving e showDeleteModal"
echo "   • Mock data completo (clientes e advogados)"
echo "   • Rota /admin/processos/:id configurada"
echo ""
echo "🎯 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Carregamento de dados por ID (1, 2, 3)"
echo "   • Formatação automática de valores monetários"
echo "   • Preview de cliente e advogado selecionados"
echo "   • Status e prioridade coloridos no header"
echo "   • Validação de campos obrigatórios"
echo "   • Funções de submit e delete preparadas"
echo ""
echo "📊 DADOS MOCK POR ID:"
echo "   • ID 1: Ação de Cobrança (Em Andamento, Média)"
echo "   • ID 2: Ação Trabalhista (Aguardando, Alta, Confidencial)"
echo "   • ID 3: Divórcio Consensual (Concluído, Baixa)"
echo ""
echo "🧪 TESTE AS ROTAS:"
echo "   • http://localhost:3000/admin/processos/1"
echo "   • http://localhost:3000/admin/processos/2"
echo "   • http://localhost:3000/admin/processos/3"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Formulários completos (dados básicos, jurídicos, cronograma)"
echo "   • Modal de confirmação de exclusão"
echo "   • Botões de ação (cancelar/salvar)"
echo "   • Seções de observações e estratégia"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2 completar o EditProcess!"