#!/bin/bash

# Script 94a - NewTask Padrão Erlene (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)
# Enumeração: 94a

echo "📋 Criando NewTask seguindo padrão Erlene (Parte 1/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 1. Criando estrutura para NewTask..."

# Criar estrutura se não existir
mkdir -p frontend/src/components/kanban

echo "📝 2. Corrigindo NewTask.js seguindo EXATO padrão NewAudiencia.js..."

# Fazer backup se existe
if [ -f "frontend/src/components/kanban/NewTask.js" ]; then
    cp frontend/src/components/kanban/NewTask.js frontend/src/components/kanban/NewTask.js.backup.$(date +%Y%m%d_%H%M%S)
fi

# Criar NewTask.js seguindo EXATO padrão NewAudiencia/NewPrazo/NewTransacao
cat > frontend/src/components/kanban/NewTask.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  ClipboardDocumentListIcon,
  UserIcon,
  UsersIcon,
  ScaleIcon,
  CalendarIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  TagIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline';

const NewTask = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [clients, setClients] = useState([]);
  const [processes, setProcesses] = useState([]);
  const [advogados, setAdvogados] = useState([]);
  const [colunas, setColunas] = useState([]);
  
  const [formData, setFormData] = useState({
    titulo: '',
    descricao: '',
    clienteId: '',
    processoId: '',
    advogadoId: '',
    colunaId: '1', // A Fazer por padrão
    prioridade: 'Média',
    dataVencimento: '',
    estimativaHoras: '',
    tags: [],
    novaTag: ''
  });

  const [errors, setErrors] = useState({});

  // Mock data seguindo padrão dos outros módulos
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
    { id: 3, name: 'Dr. Pedro Costa', oab: 'OAB/SP 345678' },
    { id: 4, name: 'Dra. Ana Silva', oab: 'OAB/SP 456789' },
    { id: 5, name: 'Dra. Erlene Chaves Silva', oab: 'OAB/SP 567890' }
  ];

  const mockColunas = [
    { id: 1, nome: 'A Fazer', cor: '#6B7280' },
    { id: 2, nome: 'Em Andamento', cor: '#3B82F6' },
    { id: 3, nome: 'Aguardando', cor: '#F59E0B' },
    { id: 4, nome: 'Concluído', cor: '#10B981' },
    { id: 5, nome: 'Cancelado', cor: '#EF4444' }
  ];

  useEffect(() => {
    // Simular carregamento seguindo padrão
    setTimeout(() => {
      setClients(mockClients);
      setProcesses(mockProcesses);
      setAdvogados(mockAdvogados);
      setColunas(mockColunas);
    }, 500);
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    
    // Limpar erro do campo
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }

    // Filtrar processos quando cliente mudar
    if (name === 'clienteId') {
      setFormData(prev => ({ ...prev, processoId: '' }));
    }
  };

  const addTag = () => {
    if (formData.novaTag.trim() && !formData.tags.includes(formData.novaTag.trim())) {
      setFormData(prev => ({
        ...prev,
        tags: [...prev.tags, prev.novaTag.trim().toLowerCase()],
        novaTag: ''
      }));
    }
  };

  const removeTag = (tagToRemove) => {
    setFormData(prev => ({
      ...prev,
      tags: prev.tags.filter(tag => tag !== tagToRemove)
    }));
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      addTag();
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.titulo.trim()) newErrors.titulo = 'Título é obrigatório';
    if (!formData.descricao.trim()) newErrors.descricao = 'Descrição é obrigatória';
    if (!formData.advogadoId) newErrors.advogadoId = 'Advogado responsável é obrigatório';
    if (!formData.dataVencimento) newErrors.dataVencimento = 'Data de vencimento é obrigatória';
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;
    
    setLoading(true);
    try {
      // Simular criação
      await new Promise(resolve => setTimeout(resolve, 2000));
      alert('Tarefa criada com sucesso!');
      navigate('/admin/kanban');
    } catch (error) {
      alert('Erro ao criar tarefa');
    } finally {
      setLoading(false);
    }
  };

  const getAvailableProcesses = () => {
    if (formData.clienteId) {
      return mockProcesses.filter(p => p.clientId.toString() === formData.clienteId);
    }
    return [];
  };

  const getPrioridadeColor = (prioridade) => {
    switch (prioridade) {
      case 'Alta': return 'text-red-600';
      case 'Média': return 'text-yellow-600';
      case 'Baixa': return 'text-green-600';
      default: return 'text-gray-600';
    }
  };

  const getPrioridadeIcon = (prioridade) => {
    switch (prioridade) {
      case 'Alta': return <ExclamationTriangleIcon className="w-4 h-4" />;
      case 'Média': return <ClockIcon className="w-4 h-4" />;
      case 'Baixa': return <CheckCircleIcon className="w-4 h-4" />;
      default: return <ClockIcon className="w-4 h-4" />;
    }
  };

  const availableProcesses = getAvailableProcesses();

  return (
    <div className="space-y-8">
      {/* Header seguindo EXATO padrão NewAudiencia */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/kanban"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Nova Tarefa</h1>
              <p className="text-lg text-gray-600 mt-2">
                Criar nova tarefa no quadro Kanban
              </p>
            </div>
          </div>
          <ClipboardDocumentListIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Informações Básicas seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Informações Básicas</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Título da Tarefa *
              </label>
              <input
                type="text"
                name="titulo"
                value={formData.titulo}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.titulo ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="Ex: Elaborar petição inicial"
              />
              {errors.titulo && <p className="text-red-500 text-sm mt-1">{errors.titulo}</p>}
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Descrição *
              </label>
              <textarea
                name="descricao"
                value={formData.descricao}
                onChange={handleChange}
                rows={4}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.descricao ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="Descreva detalhadamente a tarefa..."
              />
              {errors.descricao && <p className="text-red-500 text-sm mt-1">{errors.descricao}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Advogado Responsável *
              </label>
              <select
                name="advogadoId"
                value={formData.advogadoId}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.advogadoId ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o advogado...</option>
                {advogados.map((advogado) => (
                  <option key={advogado.id} value={advogado.id}>
                    {advogado.name} ({advogado.oab})
                  </option>
                ))}
              </select>
              {errors.advogadoId && <p className="text-red-500 text-sm mt-1">{errors.advogadoId}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Coluna Inicial</label>
              <select
                name="colunaId"
                value={formData.colunaId}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                {colunas.map((coluna) => (
                  <option key={coluna.id} value={coluna.id}>
                    {coluna.nome}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>
EOF

echo "✅ NewTask.js - PARTE 1 criada (até linha 300)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • Estrutura base seguindo EXATO padrão NewAudiencia.js"
echo "   • Header idêntico aos outros formulários do projeto"
echo "   • Mock data completo com clientes, processos, advogados, colunas"
echo "   • FormData com campos necessários para tarefas Kanban"
echo "   • Validações seguindo padrão do projeto"
echo "   • Funções de manipulação (handleChange, tags, etc.)"
echo ""
echo "🎯 CAMPOS IMPLEMENTADOS (PARTE 1):"
echo "   • Título da tarefa (obrigatório)"
echo "   • Descrição detalhada (obrigatória)"
echo "   • Advogado responsável (obrigatório)"
echo "   • Coluna inicial (A Fazer por padrão)"
echo "   • Sistema de validação com mensagens de erro"
echo ""
echo "📝 PADRÃO MANTIDO:"
echo "   • Header com botão voltar e ícone"
echo "   • Seções em cards brancos com sombra Erlene"
echo "   • Grid responsivo (1 coluna mobile, 2 desktop)"
echo "   • Campos com foco ring primary-500"
echo "   • Validação visual (border-red-300 em erros)"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Cliente e Processo (relacionamentos opcionais)"
echo "   • Configurações (prioridade, data, horas)"
echo "   • Sistema de tags dinâmico"
echo "   • Botões de ação (cancelar/criar)"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"