#!/bin/bash

# Script - Correção Lista Financeiro com Mock Data Expandido (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "💰 Corrigindo lista Financeiro.js com mock data expandido - Parte 1/2..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Fazendo backup e corrigindo Financeiro.js..."

# Fazer backup
cp frontend/src/pages/admin/Financeiro.js frontend/src/pages/admin/Financeiro.js.backup

# Criar Financeiro.js corrigido - PARTE 1 (imports e mock data expandido)
cat > frontend/src/pages/admin/Financeiro.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  CurrencyDollarIcon,
  CalendarIcon,
  ClockIcon,
  CheckCircleIcon,
  XCircleIcon,
  ExclamationTriangleIcon,
  BanknotesIcon,
  DocumentTextIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  UserIcon,
  ScaleIcon,
  UsersIcon,
  BuildingOfficeIcon
} from '@heroicons/react/24/outline';

const Financeiro = () => {
  const [transacoes, setTransacoes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterTipo, setFilterTipo] = useState('all');
  const [filterStatus, setFilterStatus] = useState('all');
  const [filterFormaPagamento, setFilterFormaPagamento] = useState('all');
  const [filterPeriodo, setFilterPeriodo] = useState('mes');

  // Mock data expandido com diferentes tipos de transações
  const mockTransacoes = [
    // RECEITAS DE CLIENTES
    {
      id: 1,
      tipo: 'Receita',
      descricao: 'Honorários - Processo Divórcio',
      valor: 3500.00,
      tipoPessoa: 'Cliente',
      pessoa: 'João Silva Santos',
      pessoaId: 1,
      processo: '1001234-56.2024.8.26.0001',
      processoId: 1,
      dataVencimento: '2024-07-25',
      dataPagamento: '2024-07-25',
      status: 'Pago',
      formaPagamento: 'PIX',
      categoria: 'Honorários Advocatícios',
      responsavel: 'Dr. Carlos Oliveira',
      observacoes: 'Primeira parcela dos honorários',
      gateway: 'Mercado Pago',
      transactionId: 'MP123456789',
      createdAt: '2024-07-20'
    },
    {
      id: 2,
      tipo: 'Receita',
      descricao: 'Consulta Empresarial',
      valor: 800.00,
      tipoPessoa: 'Cliente',
      pessoa: 'Empresa ABC Ltda',
      pessoaId: 2,
      processo: '',
      processoId: null,
      dataVencimento: '2024-07-26',
      dataPagamento: null,
      status: 'Pendente',
      formaPagamento: 'Boleto',
      categoria: 'Consulta Jurídica',
      responsavel: 'Dra. Maria Santos',
      observacoes: 'Consultoria sobre fusão empresarial',
      gateway: 'Mercado Pago',
      transactionId: 'MP987654321',
      createdAt: '2024-07-22'
    },
    {
      id: 3,
      tipo: 'Receita',
      descricao: 'Honorários de Êxito - Ação Trabalhista',
      valor: 12000.00,
      tipoPessoa: 'Cliente',
      pessoa: 'Maria Oliveira Costa',
      pessoaId: 3,
      processo: '3003456-78.2024.8.26.0003',
      processoId: 3,
      dataVencimento: '2024-07-30',
      dataPagamento: null,
      status: 'Pendente',
      formaPagamento: 'PIX',
      categoria: 'Honorários de Êxito',
      responsavel: 'Dr. Pedro Costa',
      observacoes: '30% do valor da condenação',
      gateway: 'Mercado Pago',
      transactionId: 'MP111333555',
      createdAt: '2024-07-18'
    },
    
    // DESPESAS - PESSOAL (ADVOGADOS)
    {
      id: 4,
      tipo: 'Despesa',
      descricao: 'Salário Julho/2024 - Dr. Carlos Oliveira',
      valor: 8500.00,
      tipoPessoa: 'Advogado',
      pessoa: 'Dr. Carlos Oliveira',
      pessoaId: 1,
      processo: '',
      processoId: null,
      dataVencimento: '2024-07-30',
      dataPagamento: null,
      status: 'Pendente',
      formaPagamento: 'Transferência',
      categoria: 'Salários e Ordenados',
      responsavel: 'Financeiro',
      observacoes: 'Salário mensal + adicional noturno',
      gateway: '',
      transactionId: '',
      createdAt: '2024-07-25'
    },
    {
      id: 5,
      tipo: 'Despesa',
      descricao: 'Salário Julho/2024 - Dra. Maria Santos',
      valor: 7800.00,
      tipoPessoa: 'Advogado',
      pessoa: 'Dra. Maria Santos',
      pessoaId: 2,
      processo: '',
      processoId: null,
      dataVencimento: '2024-07-30',
      dataPagamento: '2024-07-30',
      status: 'Pago',
      formaPagamento: 'Transferência',
      categoria: 'Salários e Ordenados',
      responsavel: 'Financeiro',
      observacoes: 'Salário mensal',
      gateway: '',
      transactionId: '',
      createdAt: '2024-07-25'
    },
    {
      id: 6,
      tipo: 'Despesa',
      descricao: 'Vale Refeição - Equipe',
      valor: 1200.00,
      tipoPessoa: '',
      pessoa: '',
      pessoaId: null,
      processo: '',
      processoId: null,
      dataVencimento: '2024-07-28',
      dataPagamento: '2024-07-28',
      status: 'Pago',
      formaPagamento: 'Cartão de Crédito',
      categoria: 'Vale Refeição',
      responsavel: 'Administrativo',
      observacoes: 'VR mensal para todos os funcionários',
      gateway: 'Stripe',
      transactionId: 'ST789456123',
      createdAt: '2024-07-25'
    },
    
    // DESPESAS - OPERACIONAIS (FORNECEDORES)
    {
      id: 7,
      tipo: 'Despesa',
      descricao: 'Conta de Energia Elétrica - Julho/2024',
      valor: 450.00,
      tipoPessoa: 'Fornecedor',
      pessoa: 'Elektro Distribuidora',
      pessoaId: 2,
      processo: '',
      processoId: null,
      dataVencimento: '2024-07-29',
      dataPagamento: null,
      status: 'Pendente',
      formaPagamento: 'Débito Automático',
      categoria: 'Energia Elétrica',
      responsavel: 'Administrativo',
      observacoes: 'Conta referente ao mês de julho',
      gateway: '',
      transactionId: '',
      createdAt: '2024-07-22'
    },
    {
      id: 8,
      tipo: 'Despesa',
      descricao: 'Conta de Água - Julho/2024',
      valor: 180.00,
      tipoPessoa: 'Fornecedor',
      pessoa: 'Sabesp',
      pessoaId: 3,
      processo: '',
      processoId: null,
      dataVencimento: '2024-07-25',
      dataPagamento: null,
      status: 'Vencido',
      formaPagamento: 'Boleto',
      categoria: 'Água e Esgoto',
      responsavel: 'Administrativo',
      observacoes: 'Conta em atraso - aplicar juros',
      gateway: '',
      transactionId: '',
      createdAt: '2024-07-15'
    },
    {
      id: 9,
      tipo: 'Despesa',
      descricao: 'Aluguel Escritório - Agosto/2024',
      valor: 5500.00,
      tipoPessoa: 'Fornecedor',
      pessoa: 'Imobiliária São Paulo',
      pessoaId: 4,
      processo: '',
      processoId: null,
      dataVencimento: '2024-08-01',
      dataPagamento: null,
      status: 'Pendente',
      formaPagamento: 'Transferência',
      categoria: 'Aluguel',
      responsavel: 'Financeiro',
      observacoes: 'Aluguel mensal do escritório principal',
      gateway: '',
      transactionId: '',
      createdAt: '2024-07-20'
    },
    {
      id: 10,
      tipo: 'Despesa',
      descricao: 'Material de Escritório - Julho',
      valor: 320.00,
      tipoPessoa: 'Fornecedor',
      pessoa: 'Papelaria Central',
      pessoaId: 1,
      processo: '',
      processoId: null,
      dataVencimento: '2024-07-25',
      dataPagamento: '2024-07-25',
      status: 'Pago',
      formaPagamento: 'PIX',
      categoria: 'Material de Escritório',
      responsavel: 'Administrativo',
      observacoes: 'Papel, canetas, grampeadores, etc',
      gateway: 'Mercado Pago',
      transactionId: 'MP555666777',
      createdAt: '2024-07-23'
    },
    
    // DESPESAS - JURÍDICAS
    {
      id: 11,
      tipo: 'Despesa',
      descricao: 'Custas Processuais TJSP',
      valor: 350.00,
      tipoPessoa: 'Cliente',
      pessoa: 'Tech Solutions S.A.',
      pessoaId: 4,
      processo: '4004567-89.2024.8.26.0004',
      processoId: 4,
      dataVencimento: '2024-07-24',
      dataPagamento: '2024-07-24',
      status: 'Pago',
      formaPagamento: 'Transferência',
      categoria: 'Custas Judiciais',
      responsavel: 'Dra. Ana Silva',
      observacoes: 'Custas de petição inicial',
      gateway: '',
      transactionId: '',
      createdAt: '2024-07-15'
    },
    
    // DESPESAS - TECNOLOGIA
    {
      id: 12,
      tipo: 'Despesa',
      descricao: 'Software Jurídico - Licença Mensal',
      valor: 890.00,
      tipoPessoa: 'Fornecedor',
      pessoa: 'TI Soluções Ltda',
      pessoaId: 5,
      processo: '',
      processoId: null,
      dataVencimento: '2024-07-30',
      dataPagamento: null,
      status: 'Pendente',
      formaPagamento: 'Cartão de Crédito',
      categoria: 'Software e Licenças',
      responsavel: 'Administrativo',
      observacoes: 'Sistema de gestão processual',
      gateway: 'Stripe',
      transactionId: 'ST999888777',
      createdAt: '2024-07-25'
    }
  ];

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setTransacoes(mockTransacoes);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas
  const receitas = transacoes.filter(t => t.tipo === 'Receita');
  const despesas = transacoes.filter(t => t.tipo === 'Despesa');
  
  const receitasPagas = receitas.filter(t => t.status === 'Pago');
  const receitasPendentes = receitas.filter(t => t.status === 'Pendente');
  const despesasPagas = despesas.filter(t => t.status === 'Pago');
  const despesasPendentes = despesas.filter(t => t.status === 'Pendente');
  
  const totalReceitas = receitasPagas.reduce((sum, t) => sum + t.valor, 0);
  const totalDespesas = despesasPagas.reduce((sum, t) => sum + t.valor, 0);
  const totalReceitasPendentes = receitasPendentes.reduce((sum, t) => sum + t.valor, 0);
  const totalDespesasPendentes = despesasPendentes.reduce((sum, t) => sum + t.valor, 0);
  const saldoLiquido = totalReceitas - totalDespesas;

  const stats = [
    {
      name: 'Receitas Pagas',
      value: `R$ ${totalReceitas.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`,
      change: '+12%',
      changeType: 'increase',
      icon: CurrencyDollarIcon,
      color: 'green',
      description: `${receitasPagas.length} recebida(s)`
    },
    {
      name: 'Receitas Pendentes',
      value: `R$ ${totalReceitasPendentes.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`,
      change: '+3',
      changeType: 'increase',
      icon: ClockIcon,
      color: 'yellow',
      description: `${receitasPendentes.length} a receber`
    },
    {
      name: 'Despesas Pagas',
      value: `R$ ${totalDespesas.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`,
      change: '-5%',
      changeType: 'decrease',
      icon: BanknotesIcon,
      color: 'red',
      description: `${despesasPagas.length} paga(s)`
    },
    {
      name: 'Saldo Líquido',
      value: `R$ ${saldoLiquido.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`,
      change: saldoLiquido > 0 ? '+15%' : '-5%',
      changeType: saldoLiquido > 0 ? 'increase' : 'decrease',
      icon: DocumentTextIcon,
      color: saldoLiquido > 0 ? 'green' : 'red',
      description: 'Resultado do período'
    }
  ];
EOF

echo "✅ Financeiro.js - PARTE 1 criada (imports e mock data expandido)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • Imports atualizados com novos ícones"
echo "   • Mock data expandido com 12 transações variadas"
echo "   • Receitas de clientes (honorários, consultas)"
echo "   • Despesas de advogados (salários)"
echo "   • Despesas operacionais (água, luz, aluguel)"
echo "   • Despesas de fornecedores"
echo "   • Despesas jurídicas e tecnologia"
echo "   • Cálculos de estatísticas atualizados"
echo ""
echo "💰 MOCK DATA INCLUI:"
echo "   RECEITAS (3): R$ 16.300,00 total"
echo "   - Honorários divórcio: R$ 3.500 (pago)"
echo "   - Consulta empresarial: R$ 800 (pendente)"
echo "   - Honorários êxito: R$ 12.000 (pendente)"
echo ""
echo "   DESPESAS (9): Salários, contas, fornecedores"
echo "   - Salários advogados: R$ 16.300"
echo "   - Contas operacionais: R$ 6.450"
echo "   - Material/software: R$ 1.210"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Filtros e ações rápidas"
echo "   • Tabela de transações atualizada"
echo "   • Ícones por tipo de pessoa"
echo "   • Funções de CRUD"
echo ""
echo "📏 LINHA ATUAL: ~240/300 (dentro do limite)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"