#!/bin/bash

# Script - Correção Sistema Financeiro NewTransacao (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "💰 Corrigindo NewTransacao - Parte 1/2 (até 300 linhas)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Fazendo backup e corrigindo NewTransacao.js..."

# Fazer backup
cp frontend/src/components/financeiro/NewTransacao.js frontend/src/components/financeiro/NewTransacao.js.backup

# Criar NewTransacao.js corrigido - PARTE 1 (até linha 200)
cat > frontend/src/components/financeiro/NewTransacao.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  CurrencyDollarIcon,
  CalendarIcon,
  UserIcon,
  ScaleIcon,
  BuildingOfficeIcon,
  DocumentTextIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  UsersIcon
} from '@heroicons/react/24/outline';

const NewTransacao = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [clients, setClients] = useState([]);
  const [processes, setProcesses] = useState([]);
  const [advogados, setAdvogados] = useState([]);
  const [fornecedores, setFornecedores] = useState([]);
  
  const [formData, setFormData] = useState({
    // Dados básicos
    tipo: '',
    descricao: '',
    valor: '',
    
    // Pessoa envolvida (OPCIONAL)
    tipoPessoa: '', // Cliente, Advogado, Fornecedor, Nenhum
    pessoaId: '',
    processoId: '',
    
    // Datas
    dataVencimento: '',
    dataPagamento: '',
    
    // Pagamento
    status: 'Pendente',
    formaPagamento: '',
    gateway: '',
    categoria: '',
    
    // Responsável
    responsavel: '',
    observacoes: '',
    
    // Configurações
    recorrente: false,
    notificar: false
  });

  const [errors, setErrors] = useState({});

  // Mock data expandido
  const mockClients = [
    { id: 1, name: 'João Silva Santos', type: 'PF', document: '123.456.789-00' },
    { id: 2, name: 'Empresa ABC Ltda', type: 'PJ', document: '12.345.678/0001-90' },
    { id: 3, name: 'Maria Oliveira Costa', type: 'PF', document: '987.654.321-00' }
  ];

  const mockProcesses = [
    { id: 1, number: '1001234-56.2024.8.26.0001', client: 'João Silva Santos', clientId: 1 },
    { id: 2, number: '2002345-67.2024.8.26.0002', client: 'Empresa ABC Ltda', clientId: 2 },
    { id: 3, number: '3003456-78.2024.8.26.0003', client: 'Maria Oliveira Costa', clientId: 3 }
  ];

  const mockAdvogados = [
    { id: 1, name: 'Dr. Carlos Oliveira', oab: 'OAB/SP 123456' },
    { id: 2, name: 'Dra. Maria Santos', oab: 'OAB/SP 234567' },
    { id: 3, name: 'Dra. Erlene Chaves Silva', oab: 'OAB/SP 567890' }
  ];

  const mockFornecedores = [
    { id: 1, name: 'Papelaria Central', cnpj: '11.111.111/0001-11', tipo: 'Material' },
    { id: 2, name: 'Elektro Distribuidora', cnpj: '22.222.222/0001-22', tipo: 'Energia' },
    { id: 3, name: 'Sabesp', cnpj: '33.333.333/0001-33', tipo: 'Água' },
    { id: 4, name: 'Imobiliária São Paulo', cnpj: '44.444.444/0001-44', tipo: 'Imóveis' }
  ];

  useEffect(() => {
    setTimeout(() => {
      setClients(mockClients);
      setProcesses(mockProcesses);
      setAdvogados(mockAdvogados);
      setFornecedores(mockFornecedores);
    }, 500);
  }, []);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }

    // Limpar pessoaId quando tipo de pessoa mudar
    if (name === 'tipoPessoa') {
      setFormData(prev => ({ ...prev, pessoaId: '', processoId: '' }));
    }

    // Auto-selecionar gateway baseado na forma de pagamento
    if (name === 'formaPagamento') {
      let gateway = '';
      if (value === 'PIX' || value === 'Boleto') {
        gateway = 'Mercado Pago';
      } else if (value === 'Cartão de Crédito' || value === 'Cartão de Débito') {
        gateway = 'Stripe';
      }
      setFormData(prev => ({ ...prev, gateway: gateway }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.tipo.trim()) newErrors.tipo = 'Tipo é obrigatório';
    if (!formData.descricao.trim()) newErrors.descricao = 'Descrição é obrigatória';
    if (!formData.valor || parseFloat(formData.valor) <= 0) newErrors.valor = 'Valor deve ser maior que zero';
    if (!formData.dataVencimento) newErrors.dataVencimento = 'Data de vencimento é obrigatória';
    if (!formData.formaPagamento.trim()) newErrors.formaPagamento = 'Forma de pagamento é obrigatória';
    if (!formData.categoria.trim()) newErrors.categoria = 'Categoria é obrigatória';
    if (!formData.responsavel.trim()) newErrors.responsavel = 'Responsável é obrigatório';
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;
    
    setLoading(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 1500));
      alert('Transação cadastrada com sucesso!');
      navigate('/admin/financeiro');
    } catch (error) {
      alert('Erro ao cadastrar transação');
    } finally {
      setLoading(false);
    }
  };

  // Obter pessoa selecionada baseada no tipo
  const getSelectedPerson = () => {
    if (!formData.tipoPessoa || !formData.pessoaId) return null;
    
    switch (formData.tipoPessoa) {
      case 'Cliente': return clients.find(c => c.id.toString() === formData.pessoaId);
      case 'Advogado': return advogados.find(a => a.id.toString() === formData.pessoaId);
      case 'Fornecedor': return fornecedores.find(f => f.id.toString() === formData.pessoaId);
      default: return null;
    }
  };

  const getAvailableProcesses = () => {
    if (formData.tipoPessoa === 'Cliente' && formData.pessoaId) {
      return processes.filter(p => p.clientId.toString() === formData.pessoaId);
    }
    return [];
  };

  const selectedPerson = getSelectedPerson();
  const availableProcesses = getAvailableProcesses();

  const tiposTransacao = ['Receita', 'Despesa'];
  const tiposPessoa = [
    { value: '', label: 'Nenhuma pessoa vinculada' },
    { value: 'Cliente', label: 'Cliente' },
    { value: 'Advogado', label: 'Advogado/Funcionário' },
    { value: 'Fornecedor', label: 'Fornecedor' }
  ];

  const formasPagamento = [
    'PIX', 'Cartão de Crédito', 'Cartão de Débito', 'Boleto', 
    'Transferência', 'Dinheiro', 'Cheque', 'Débito Automático'
  ];

  const categoriasReceita = [
    'Honorários Advocatícios', 'Honorários de Êxito', 'Consulta Jurídica',
    'Parecer Jurídico', 'Assessoria Jurídica', 'Comissões', 'Outros'
  ];

  const categoriasDespesa = [
    // Pessoal
    'Salários e Ordenados', 'Férias e 13º Salário', 'FGTS e INSS',
    'Vale Transporte', 'Vale Refeição', 'Plano de Saúde',
    // Operacionais  
    'Aluguel', 'Condomínio', 'Energia Elétrica', 'Água e Esgoto',
    'Telefone e Internet', 'Material de Escritório', 'Serviços de Limpeza',
    // Jurídicas
    'Custas Judiciais', 'Taxas Cartório', 'Despesas Processuais',
    // Tecnologia
    'Software e Licenças', 'Hardware e Equipamentos',
    // Outras
    'Impostos e Taxas', 'Viagens', 'Marketing', 'Outros'
  ];

  const responsaveis = [
    'Dr. Carlos Oliveira', 'Dra. Maria Santos', 'Dr. Pedro Costa',
    'Dra. Ana Silva', 'Dra. Erlene Chaves Silva', 'Administrativo', 'Financeiro'
  ];

  const gateways = ['Mercado Pago', 'Stripe', 'PagSeguro', 'PayPal', ''];

  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'Receita': return <ArrowUpIcon className="w-5 h-5 text-green-600" />;
      case 'Despesa': return <ArrowDownIcon className="w-5 h-5 text-red-600" />;
      default: return <CurrencyDollarIcon className="w-5 h-5" />;
    }
  };

  const getTipoPessoaIcon = (tipo) => {
    switch (tipo) {
      case 'Cliente': return <UserIcon className="w-4 h-4 text-primary-600" />;
      case 'Advogado': return <UsersIcon className="w-4 h-4 text-blue-600" />;
      case 'Fornecedor': return <BuildingOfficeIcon className="w-4 h-4 text-orange-600" />;
      default: return <UserIcon className="w-4 h-4 text-gray-600" />;
    }
  };

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/financeiro"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Nova Transação</h1>
              <p className="text-lg text-gray-600 mt-2">Receitas, despesas, salários, contas do escritório</p>
            </div>
          </div>
          <CurrencyDollarIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>
EOF

echo "✅ NewTransacao.js - PARTE 1 criada (até linha 200)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • Estrutura base e imports"
echo "   • Mock data expandido (clientes, advogados, fornecedores)"
echo "   • FormData com novos campos (tipoPessoa OPCIONAL)"
echo "   • Validações (CLIENTE NÃO É MAIS OBRIGATÓRIO)"
echo "   • Categorias expandidas (pessoal, operacionais, jurídicas)"
echo "   • Funções base e handleChange"
echo "   • Header do formulário"
echo ""
echo "🔧 MUDANÇAS PRINCIPAIS:"
echo "   ❌ REMOVIDO: Campo cliente obrigatório"
echo "   ✅ ADICIONADO: tipoPessoa opcional (Cliente, Advogado, Fornecedor, Nenhum)"
echo "   ✅ ADICIONADO: Mock de advogados e fornecedores"
echo "   ✅ EXPANDIDO: Categorias de despesas (salários, contas, etc)"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Formulários HTML completos"
echo "   • Seções de pessoa envolvida (opcional)"
echo "   • Categoria, datas e botões"
echo ""
echo "📏 LINHA ATUAL: ~200/300 (dentro do limite)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"