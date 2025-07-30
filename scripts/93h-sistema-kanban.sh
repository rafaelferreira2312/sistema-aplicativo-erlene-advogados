#!/bin/bash

# Script 96a - Correção Problemas Kanban (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)
# Enumeração: 96a

echo "📋 Corrigindo problemas do Kanban - Botões, Edição e Funcionários (Parte 1/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "🔧 1. Criando EditTask.js para edição de tarefas..."

# Criar EditTask.js seguindo padrão EditAudiencia/EditPrazo
cat > frontend/src/components/kanban/EditTask.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
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

const EditTask = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(false);
  const [clients, setClients] = useState([]);
  const [processes, setProcesses] = useState([]);
  const [advogados, setAdvogados] = useState([]);
  const [funcionarios, setFuncionarios] = useState([]);
  const [colunas, setColunas] = useState([]);
  
  const [formData, setFormData] = useState({
    titulo: '',
    descricao: '',
    clienteId: '',
    processoId: '',
    responsavelTipo: 'Advogado', // Advogado ou Funcionario
    responsavelId: '',
    colunaId: '1',
    prioridade: 'Média',
    dataVencimento: '',
    estimativaHoras: '',
    tags: [],
    novaTag: ''
  });

  const [errors, setErrors] = useState({});

  // Mock data expandido
  const mockClients = [
    { id: 1, name: 'João Silva Santos', type: 'PF' },
    { id: 2, name: 'Empresa ABC Ltda', type: 'PJ' },
    { id: 3, name: 'Maria Oliveira Costa', type: 'PF' },
    { id: 4, name: 'Tech Solutions S.A.', type: 'PJ' },
    { id: 5, name: 'Carlos Pereira Lima', type: 'PF' }
  ];

  const mockProcesses = [
    { id: 1, number: '1001234-56.2024.8.26.0001', client: 'João Silva Santos', clientId: 1 },
    { id: 2, number: '2002345-67.2024.8.26.0002', client: 'Empresa ABC Ltda', clientId: 2 },
    { id: 3, number: '3003456-78.2024.8.26.0003', client: 'Maria Oliveira Costa', clientId: 3 },
    { id: 4, number: '4004567-89.2024.8.26.0004', client: 'Tech Solutions S.A.', clientId: 4 },
    { id: 5, number: '5005678-90.2024.8.26.0005', client: 'Carlos Pereira Lima', clientId: 5 }
  ];

  const mockAdvogados = [
    { id: 1, name: 'Dr. Carlos Oliveira', oab: 'OAB/SP 123456', tipo: 'Sócio' },
    { id: 2, name: 'Dra. Maria Santos', oab: 'OAB/SP 234567', tipo: 'Advogada' },
    { id: 3, name: 'Dr. Pedro Costa', oab: 'OAB/SP 345678', tipo: 'Advogado' },
    { id: 4, name: 'Dra. Ana Silva', oab: 'OAB/SP 456789', tipo: 'Advogada' },
    { id: 5, name: 'Dra. Erlene Chaves Silva', oab: 'OAB/SP 567890', tipo: 'Sócia Fundadora' }
  ];

  const mockFuncionarios = [
    { id: 1, name: 'Carla Secretária', cargo: 'Secretária Jurídica', setor: 'Atendimento' },
    { id: 2, name: 'Roberto Administrativo', cargo: 'Assistente Administrativo', setor: 'Financeiro' },
    { id: 3, name: 'Júlia Estagiária', cargo: 'Estagiária de Direito', setor: 'Processos' },
    { id: 4, name: 'Marcos TI', cargo: 'Analista de TI', setor: 'Tecnologia' },
    { id: 5, name: 'Fernanda RH', cargo: 'Analista de RH', setor: 'Recursos Humanos' }
  ];

  const mockColunas = [
    { id: 1, nome: 'A Fazer', cor: '#6B7280' },
    { id: 2, nome: 'Em Andamento', cor: '#3B82F6' },
    { id: 3, nome: 'Aguardando', cor: '#F59E0B' },
    { id: 4, nome: 'Concluído', cor: '#10B981' },
    { id: 5, nome: 'Cancelado', cor: '#EF4444' }
  ];

  // Mock data da tarefa baseado no ID
  const getTarefaMock = (taskId) => {
    const tarefas = {
      1: {
        titulo: 'Elaborar petição inicial',
        descricao: 'Redigir petição inicial do processo de divórcio com levantamento de bens',
        clienteId: '1',
        processoId: '1',
        responsavelTipo: 'Advogado',
        responsavelId: '1',
        colunaId: '1',
        prioridade: 'Alta',
        dataVencimento: '2024-07-30',
        estimativaHoras: '4',
        tags: ['petição', 'urgente', 'divórcio']
      },
      2: {
        titulo: 'Revisar contrato societário',
        descricao: 'Análise completa do contrato de constituição da empresa ABC Ltda',
        clienteId: '2',
        processoId: '',
        responsavelTipo: 'Advogado',
        responsavelId: '2',
        colunaId: '1',
        prioridade: 'Média',
        dataVencimento: '2024-08-05',
        estimativaHoras: '6',
        tags: ['contrato', 'societário', 'análise']
      },
      3: {
        titulo: 'Organizar documentos do processo',
        descricao: 'Separar e digitalizar documentos para o processo trabalhista',
        clienteId: '3',
        processoId: '3',
        responsavelTipo: 'Funcionario',
        responsavelId: '1',
        colunaId: '2',
        prioridade: 'Baixa',
        dataVencimento: '2024-08-15',
        estimativaHoras: '2',
        tags: ['documentos', 'organização', 'digitalização']
      }
    };
    
    return tarefas[taskId] || tarefas[1];
  };

  useEffect(() => {
    setTimeout(() => {
      setClients(mockClients);
      setProcesses(mockProcesses);
      setAdvogados(mockAdvogados);
      setFuncionarios(mockFuncionarios);
      setColunas(mockColunas);
      
      // Carregar dados da tarefa
      const tarefaData = getTarefaMock(id);
      setFormData(prev => ({ ...prev, ...tarefaData }));
    }, 500);
  }, [id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }

    // Limpar responsável quando tipo mudar
    if (name === 'responsavelTipo') {
      setFormData(prev => ({ ...prev, responsavelId: '' }));
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
    if (!formData.responsavelId) newErrors.responsavelId = 'Responsável é obrigatório';
    if (!formData.dataVencimento) newErrors.dataVencimento = 'Data de vencimento é obrigatória';
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;
    
    setLoading(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 1500));
      alert('Tarefa atualizada com sucesso!');
      navigate('/admin/kanban');
    } catch (error) {
      alert('Erro ao atualizar tarefa');
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

  const getResponsaveisOptions = () => {
    return formData.responsavelTipo === 'Advogado' ? mockAdvogados : mockFuncionarios;
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
  const responsaveisOptions = getResponsaveisOptions();

  return (
    <div className="space-y-8">
      {/* Header seguindo padrão EditAudiencia */}
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
              <h1 className="text-3xl font-bold text-gray-900">Editar Tarefa</h1>
              <p className="text-lg text-gray-600 mt-2">
                ID: #{id} - Atualizar informações da tarefa
              </p>
            </div>
          </div>
          <ClipboardDocumentListIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Informações Básicas */}
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
                Tipo de Responsável *
              </label>
              <select
                name="responsavelTipo"
                value={formData.responsavelTipo}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Advogado">Advogado</option>
                <option value="Funcionario">Funcionário</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Responsável *
              </label>
              <select
                name="responsavelId"
                value={formData.responsavelId}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.responsavelId ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o responsável...</option>
                {responsaveisOptions.map((pessoa) => (
                  <option key={pessoa.id} value={pessoa.id}>
                    {pessoa.name} {pessoa.oab ? `(${pessoa.oab})` : `- ${pessoa.cargo}`}
                  </option>
                ))}
              </select>
              {errors.responsavelId && <p className="text-red-500 text-sm mt-1">{errors.responsavelId}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Coluna</label>
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

echo "✅ EditTask.js - PARTE 1 criada (até linha 300)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • EditTask.js criado seguindo padrão EditAudiencia/EditPrazo"
echo "   • Sistema expandido para Advogados + Funcionários"
echo "   • Mock data com funcionários (secretária, administrativo, estagiário, TI, RH)"
echo "   • Seleção de tipo de responsável (Advogado ou Funcionário)"
echo "   • Formulário base com validações"
echo ""
echo "👥 FUNCIONÁRIOS ADICIONADOS:"
echo "   • Carla Secretária (Secretária Jurídica)"
echo "   • Roberto Administrativo (Assistente Administrativo)"
echo "   • Júlia Estagiária (Estagiária de Direito)"
echo "   • Marcos TI (Analista de TI)"
echo "   • Fernanda RH (Analista de RH)"
echo ""
echo "⚖️ ADVOGADOS EXPANDIDOS:"
echo "   • Dr. Carlos Oliveira (Sócio)"
echo "   • Dra. Maria Santos (Advogada)"
echo "   • Dr. Pedro Costa (Advogado)"
echo "   • Dra. Ana Silva (Advogada)"
echo "   • Dra. Erlene Chaves Silva (Sócia Fundadora)"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Completar formulários de EditTask.js"
echo "   • Corrigir botões da lista/kanban no Kanban.js"
echo "   • Adicionar rotas de edição"
echo "   • Atualizar NewTask.js com funcionários"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"