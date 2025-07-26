#!/bin/bash

# Script 91e - EditTransacao Sistema Financeiro (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "💰 Criando EditTransacao - Parte 1/2 (até 300 linhas)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 1. Criando EditTransacao.js seguindo padrão EditAudiencia/EditPrazo..."

# Criar EditTransacao.js - PARTE 1 (imports, state, mock data e funções base)
cat > frontend/src/components/financeiro/EditTransacao.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
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
  TrashIcon,
  CheckCircleIcon,
  UsersIcon
} from '@heroicons/react/24/outline';

const EditTransacao = () => {
  const navigate = useNavigate();
  const { id } = useParams();
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
    tipoPessoa: '',
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
    { id: 3, name: 'Maria Oliveira Costa', type: 'PF', document: '987.654.321-00' },
    { id: 4, name: 'Tech Solutions S.A.', type: 'PJ', document: '11.222.333/0001-44' },
    { id: 5, name: 'Carlos Pereira Lima', type: 'PF', document: '555.666.777-88' }
  ];

  const mockProcesses = [
    { id: 1, number: '1001234-56.2024.8.26.0001', client: 'João Silva Santos', clientId: 1 },
    { id: 2, number: '2002345-67.2024.8.26.0002', client: 'Empresa ABC Ltda', clientId: 2 },
    { id: 3, number: '3003456-78.2024.8.26.0003', client: 'Maria Oliveira Costa', clientId: 3 },
    { id: 4, number: '4004567-89.2024.8.26.0004', client: 'Tech Solutions S.A.', clientId: 4 },
    { id: 5, number: '5005678-90.2024.8.26.0005', client: 'Carlos Pereira Lima', clientId: 5 }
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
    { id: 4, name: 'Imobiliária São Paulo', cnpj: '44.444.444/0001-44', tipo: 'Imóveis' },
    { id: 5, name: 'TI Soluções Ltda', cnpj: '55.555.555/0001-55', tipo: 'Tecnologia' }
  ];

  // Mock data da transação existente baseado no ID
  const getTransacaoMock = (transacaoId) => {
    const transacoes = {
      1: {
        id: 1,
        tipo: 'Receita',
        descricao: 'Honorários - Processo Divórcio',
        valor: '3500.00',
        tipoPessoa: 'Cliente',
        pessoaId: '1',
        processoId: '1',
        dataVencimento: '2024-07-25',
        dataPagamento: '2024-07-25',
        status: 'Pago',
        formaPagamento: 'PIX',
        categoria: 'Honorários Advocatícios',
        responsavel: 'Dr. Carlos Oliveira',
        observacoes: 'Primeira parcela dos honorários',
        gateway: 'Mercado Pago',
        recorrente: false,
        notificar: true
      },
      2: {
        id: 2,
        tipo: 'Receita',
        descricao: 'Consulta Empresarial',
        valor: '800.00',
        tipoPessoa: 'Cliente',
        pessoaId: '2',
        processoId: '',
        dataVencimento: '2024-07-26',
        dataPagamento: '',
        status: 'Pendente',
        formaPagamento: 'Boleto',
        categoria: 'Consulta Jurídica',
        responsavel: 'Dra. Maria Santos',
        observacoes: 'Consultoria sobre fusão empresarial',
        gateway: 'Mercado Pago',
        recorrente: false,
        notificar: true
      },
      4: {
        id: 4,
        tipo: 'Despesa',
        descricao: 'Salário Julho/2024 - Dr. Carlos Oliveira',
        valor: '8500.00',
        tipoPessoa: 'Advogado',
        pessoaId: '1',
        processoId: '',
        dataVencimento: '2024-07-30',
        dataPagamento: '',
        status: 'Pendente',
        formaPagamento: 'Transferência',
        categoria: 'Salários e Ordenados',
        responsavel: 'Financeiro',
        observacoes: 'Salário mensal + adicional noturno',
        gateway: '',
        recorrente: true,
        notificar: false
      },
      8: {
        id: 8,
        tipo: 'Despesa',
        descricao: 'Conta de Água - Julho/2024',
        valor: '180.00',
        tipoPessoa: 'Fornecedor',
        pessoaId: '3',
        processoId: '',
        dataVencimento: '2024-07-25',
        dataPagamento: '',
        status: 'Vencido',
        formaPagamento: 'Boleto',
        categoria: 'Água e Esgoto',
        responsavel: 'Administrativo',
        observacoes: 'Conta em atraso - aplicar juros',
        gateway: '',
        recorrente: true,
        notificar: false
      },
      9: {
        id: 9,
        tipo: 'Despesa',
        descricao: 'Aluguel Escritório - Agosto/2024',
        valor: '5500.00',
        tipoPessoa: 'Fornecedor',
        pessoaId: '4',
        processoId: '',
        dataVencimento: '2024-08-01',
        dataPagamento: '',
        status: 'Pendente',
        formaPagamento: 'Transferência',
        categoria: 'Aluguel',
        responsavel: 'Financeiro',
        observacoes: 'Aluguel mensal do escritório principal',
        gateway: '',
        recorrente: true,
        notificar: true
      }
    };
    
    return transacoes[transacaoId] || transacoes[1]; // Default para transação 1
  };

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setClients(mockClients);
      setProcesses(mockProcesses);
      setAdvogados(mockAdvogados);
      setFornecedores(mockFornecedores);
      
      // Carregar dados da transação existente
      const transacaoData = getTransacaoMock(id);
      setFormData(transacaoData);
    }, 500);
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
      alert('Transação atualizada com sucesso!');
      navigate('/admin/financeiro');
    } catch (error) {
      alert('Erro ao atualizar transação');
    } finally {
      setLoading(false);
    }
  };

  const handleMarkPago = () => {
    if (window.confirm('Marcar esta transação como paga?')) {
      setFormData(prev => ({
        ...prev,
        status: 'Pago',
        dataPagamento: new Date().toISOString().split('T')[0]
      }));
      alert('Status atualizado para Pago!');
    }
  };

  const handleDelete = () => {
    if (window.confirm('Tem certeza que deseja excluir esta transação? Esta ação não pode ser desfeita.')) {
      alert('Transação excluída com sucesso!');
      navigate('/admin/financeiro');
    }
  };

  // Obter pessoa selecionada baseada no tipo
  const getSelectedPerson = () => {
    if (!formData.tipoPessoa || !formData.pessoaId) return null;
    
    switch (formData.tipoPessoa) {
      case 'Cliente': return mockClients.find(c => c.id.toString() === formData.pessoaId);
      case 'Advogado': return mockAdvogados.find(a => a.id.toString() === formData.pessoaId);
      case 'Fornecedor': return mockFornecedores.find(f => f.id.toString() === formData.pessoaId);
      default: return null;
    }
  };

  const getAvailableProcesses = () => {
    if (formData.tipoPessoa === 'Cliente' && formData.pessoaId) {
      return mockProcesses.filter(p => p.clientId.toString() === formData.pessoaId);
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

  const getStatusColor = (status) => {
    switch (status) {
      case 'Pago': return 'bg-green-100 text-green-800';
      case 'Pendente': return 'bg-yellow-100 text-yellow-800';
      case 'Vencido': return 'bg-red-100 text-red-800';
      case 'Cancelado': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };
EOF

echo "✅ EditTransacao.js - PARTE 1 criada (até linha 300)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • Estrutura base e imports seguindo padrão EditAudiencia/EditPrazo"
echo "   • Mock data expandido com clientes, advogados, fornecedores"
echo "   • 5 transações pré-definidas para edição (IDs: 1, 2, 4, 8, 9)"
echo "   • FormData com campos OPCIONAL para tipoPessoa"
echo "   • Validações ajustadas"
echo "   • Funções de manipulação (handleChange, validateForm)"
echo "   • Ações rápidas (marcar como pago, excluir)"
echo "   • Categorias expandidas para despesas operacionais"
echo ""
echo "🔧 TRANSAÇÕES DISPONÍVEIS PARA EDIÇÃO:"
echo "   ID 1: Receita - Honorários João Silva (Cliente - PAGO)"
echo "   ID 2: Receita - Consulta Empresa ABC (Cliente - PENDENTE)"
echo "   ID 4: Despesa - Salário Dr. Carlos (Advogado - PENDENTE)"
echo "   ID 8: Despesa - Conta de Água (Fornecedor - VENCIDO)"
echo "   ID 9: Despesa - Aluguel Escritório (Fornecedor - PENDENTE)"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Header do formulário com informações da transação"
echo "   • Formulários HTML completos"
echo "   • Seções organizadas (Dados Básicos, Pessoa, Categoria, Pagamento)"
echo "   • Botões de ação (Salvar, Cancelar, Marcar como Pago, Excluir)"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"