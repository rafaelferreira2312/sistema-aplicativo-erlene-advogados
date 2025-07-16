#!/bin/bash

# Script 44 - Páginas do Módulo Financeiro (Completo)
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/44-create-financial-pages.sh

echo "💰 Criando páginas do módulo financeiro..."

# src/pages/admin/Financial/index.js
cat > frontend/src/pages/admin/Financial/index.js << 'EOF'
import React, { useState, useMemo } from 'react';
import { 
  PlusIcon,
  BanknotesIcon,
  ArrowTrendingUpIcon,
  ArrowTrendingDownIcon,
  CreditCardIcon,
  DocumentArrowDownIcon
} from '@heroicons/react/24/outline';
import { formatMoney, formatDate } from '../../../utils/formatters';

import Card from '../../../components/common/Card';
import Button from '../../../components/common/Button';
import Badge from '../../../components/common/Badge';
import Input from '../../../components/common/Input';

const Financial = () => {
  const [selectedPeriod, setSelectedPeriod] = useState('month');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [searchTerm, setSearchTerm] = useState('');

  // Mock data
  const financialData = {
    summary: {
      receitas: 125847.50,
      despesas: 45320.30,
      lucro: 80527.20,
      pendentes: 15600.00
    },
    transactions: [
      {
        id: 1,
        tipo: 'receita',
        categoria: 'honorarios',
        descricao: 'Honorários - Processo 1234567-89',
        valor: 5000.00,
        data: '2024-03-15',
        status: 'pago',
        cliente: 'Maria Silva',
        metodo_pagamento: 'stripe'
      },
      {
        id: 2,
        tipo: 'despesa',
        categoria: 'operacional',
        descricao: 'Aluguel do escritório',
        valor: 8500.00,
        data: '2024-03-10',
        status: 'pago',
        fornecedor: 'Imobiliária XYZ'
      },
      {
        id: 3,
        tipo: 'receita',
        categoria: 'consulta',
        descricao: 'Consulta jurídica - João Santos',
        valor: 350.00,
        data: '2024-03-12',
        status: 'pendente',
        cliente: 'João Santos',
        metodo_pagamento: 'mercado_pago'
      }
    ]
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'pago': return 'success';
      case 'pendente': return 'warning';
      case 'atrasado': return 'danger';
      default: return 'default';
    }
  };

  const filteredTransactions = useMemo(() => {
    return financialData.transactions.filter(transaction => {
      const matchesSearch = !searchTerm || 
        transaction.descricao.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesCategory = !selectedCategory || transaction.categoria === selectedCategory;
      return matchesSearch && matchesCategory;
    });
  }, [financialData.transactions, searchTerm, selectedCategory]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Financeiro</h1>
          <p className="mt-1 text-gray-600">Controle completo das finanças</p>
        </div>
        <Button variant="primary" icon={PlusIcon}>Nova Transação</Button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="bg-gradient-to-r from-green-500 to-green-600 text-white">
          <div className="p-6">
            <div className="flex items-center">
              <ArrowTrendingUpIcon className="h-8 w-8 text-green-100 mr-4" />
              <div>
                <p className="text-green-100 text-sm">Receitas</p>
                <p className="text-2xl font-bold">{formatMoney(financialData.summary.receitas)}</p>
              </div>
            </div>
          </div>
        </Card>
        
        <Card className="bg-gradient-to-r from-red-500 to-red-600 text-white">
          <div className="p-6">
            <div className="flex items-center">
              <ArrowTrendingDownIcon className="h-8 w-8 text-red-100 mr-4" />
              <div>
                <p className="text-red-100 text-sm">Despesas</p>
                <p className="text-2xl font-bold">{formatMoney(financialData.summary.despesas)}</p>
              </div>
            </div>
          </div>
        </Card>
        
        <Card className="bg-gradient-to-r from-blue-500 to-blue-600 text-white">
          <div className="p-6">
            <div className="flex items-center">
              <BanknotesIcon className="h-8 w-8 text-blue-100 mr-4" />
              <div>
                <p className="text-blue-100 text-sm">Lucro Líquido</p>
                <p className="text-2xl font-bold">{formatMoney(financialData.summary.lucro)}</p>
              </div>
            </div>
          </div>
        </Card>
        
        <Card className="bg-gradient-to-r from-yellow-500 to-yellow-600 text-white">
          <div className="p-6">
            <div className="flex items-center">
              <CreditCardIcon className="h-8 w-8 text-yellow-100 mr-4" />
              <div>
                <p className="text-yellow-100 text-sm">Pendentes</p>
                <p className="text-2xl font-bold">{formatMoney(financialData.summary.pendentes)}</p>
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* Transactions */}
      <Card title="Transações Recentes">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <Input
            placeholder="Buscar transação..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <select 
            className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
          >
            <option value="">Todas as categorias</option>
            <option value="honorarios">Honorários</option>
            <option value="consulta">Consultas</option>
            <option value="operacional">Operacional</option>
          </select>
        </div>

        <div className="space-y-4">
          {filteredTransactions.map((transaction) => (
            <div key={transaction.id} className="border border-gray-200 rounded-lg p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                  <div className={`p-2 rounded-full ${
                    transaction.tipo === 'receita' ? 'bg-green-100' : 'bg-red-100'
                  }`}>
                    {transaction.tipo === 'receita' ? (
                      <ArrowTrendingUpIcon className="h-5 w-5 text-green-600" />
                    ) : (
                      <ArrowTrendingDownIcon className="h-5 w-5 text-red-600" />
                    )}
                  </div>
                  <div>
                    <h4 className="font-medium text-gray-900">{transaction.descricao}</h4>
                    <p className="text-sm text-gray-500">{formatDate(transaction.data)}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className={`text-lg font-semibold ${
                    transaction.tipo === 'receita' ? 'text-green-600' : 'text-red-600'
                  }`}>
                    {transaction.tipo === 'receita' ? '+' : '-'}{formatMoney(transaction.valor)}
                  </p>
                  <Badge variant={getStatusColor(transaction.status)}>
                    {transaction.status}
                  </Badge>
                </div>
              </div>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
};

export default Financial;
EOF

# src/pages/portal/Payments/index.js
cat > frontend/src/pages/portal/Payments/index.js << 'EOF'
import React, { useState } from 'react';
import { 
  CreditCardIcon,
  CheckCircleIcon,
  ExclamationTriangleIcon,
  CalendarIcon
} from '@heroicons/react/24/outline';
import { formatMoney, formatDate } from '../../../utils/formatters';

import Card from '../../../components/common/Card';
import Button from '../../../components/common/Button';
import Badge from '../../../components/common/Badge';

const PortalPayments = () => {
  const [statusFilter, setStatusFilter] = useState('');

  const payments = [
    {
      id: 1,
      descricao: 'Honorários - Processo 1234567-89',
      valor: 5000.00,
      data_vencimento: '2024-03-20',
      status: 'pendente',
      processo_numero: '1234567-89.2024.8.02.0001'
    },
    {
      id: 2,
      descricao: 'Consulta jurídica - 15/03/2024',
      valor: 350.00,
      data_vencimento: '2024-03-15',
      data_pagamento: '2024-03-14',
      status: 'pago'
    }
  ];

  const getStatusColor = (status) => ({
    pago: 'success',
    pendente: 'warning',
    atrasado: 'danger'
  }[status] || 'default');

  const filteredPayments = payments.filter(payment => 
    !statusFilter || payment.status === statusFilter
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Pagamentos</h1>
        <p className="mt-1 text-gray-600">Acompanhe seus pagamentos</p>
      </div>

      {/* Summary */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="bg-gradient-to-r from-yellow-500 to-yellow-600 text-white">
          <div className="p-6 flex items-center">
            <CalendarIcon className="h-8 w-8 text-yellow-100 mr-4" />
            <div>
              <p className="text-yellow-100 text-sm">Pendentes</p>
              <p className="text-2xl font-bold">
                {formatMoney(payments.filter(p => p.status === 'pendente').reduce((s, p) => s + p.valor, 0))}
              </p>
            </div>
          </div>
        </Card>

        <Card className="bg-gradient-to-r from-green-500 to-green-600 text-white">
          <div className="p-6 flex items-center">
            <CheckCircleIcon className="h-8 w-8 text-green-100 mr-4" />
            <div>
              <p className="text-green-100 text-sm">Pagos</p>
              <p className="text-2xl font-bold">
                {formatMoney(payments.filter(p => p.status === 'pago').reduce((s, p) => s + p.valor, 0))}
              </p>
            </div>
          </div>
        </Card>

        <Card className="bg-gradient-to-r from-red-500 to-red-600 text-white">
          <div className="p-6 flex items-center">
            <ExclamationTriangleIcon className="h-8 w-8 text-red-100 mr-4" />
            <div>
              <p className="text-red-100 text-sm">Atrasados</p>
              <p className="text-2xl font-bold">R$ 0,00</p>
            </div>
          </div>
        </Card>
      </div>

      {/* Filter */}
      <Card>
        <select 
          className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
        >
          <option value="">Todos os status</option>
          <option value="pendente">Pendente</option>
          <option value="pago">Pago</option>
          <option value="atrasado">Atrasado</option>
        </select>
      </Card>

      {/* Payments List */}
      <div className="space-y-4">
        {filteredPayments.map((payment) => (
          <Card key={payment.id}>
            <div className="p-6">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    {payment.descricao}
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
                    <div>
                      <span className="font-medium">Valor:</span>
                      <div className="text-xl font-bold text-gray-900">
                        {formatMoney(payment.valor)}
                      </div>
                    </div>
                    <div>
                      <span className="font-medium">Vencimento:</span>
                      <div>{formatDate(payment.data_vencimento)}</div>
                    </div>
                  </div>
                  {payment.processo_numero && (
                    <div className="mt-2 text-sm text-gray-500">
                      <span className="font-medium">Processo:</span> {payment.processo_numero}
                    </div>
                  )}
                </div>
                <div className="ml-6 flex flex-col space-y-2">
                  <Badge variant={getStatusColor(payment.status)}>
                    {payment.status === 'pago' ? 'Pago' : 
                     payment.status === 'pendente' ? 'Pendente' : 'Atrasado'}
                  </Badge>
                  {payment.status === 'pendente' && (
                    <Button variant="primary" icon={CreditCardIcon}>
                      Pagar Agora
                    </Button>
                  )}
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>

      {filteredPayments.length === 0 && (
        <Card>
          <div className="text-center py-12">
            <CreditCardIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">
              Nenhum pagamento encontrado
            </h3>
          </div>
        </Card>
      )}
    </div>
  );
};

export default PortalPayments;
EOF

echo "✅ Módulo financeiro criado com sucesso!"
echo ""
echo "📊 PÁGINAS CRIADAS:"
echo "   • Financial (Admin) - Dashboard financeiro completo"
echo "   • Payments (Portal) - Pagamentos do cliente"
echo ""
echo "💰 RECURSOS INCLUÍDOS:"
echo "   • Cards de resumo financeiro coloridos"
echo "   • Lista de transações com filtros"
echo "   • Sistema de pagamentos para clientes"
echo "   • Badges de status e formatação monetária"
echo "   • Interface responsiva e intuitiva"
echo ""
echo "⏭️  Próximo: Documentos/GED e Kanban!"