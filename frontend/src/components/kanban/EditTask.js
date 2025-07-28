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
  CheckCircleIcon,
  BuildingOfficeIcon
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
    horasGastas: '',
    tags: [],
    novaTag: '',
    observacoes: ''
  });

  const [errors, setErrors] = useState({});

  // Mock data expandido com funcionários e advogados
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
    { id: 1, name: 'Dr. Carlos Oliveira', oab: 'OAB/SP 123456', cargo: 'Sócio' },
    { id: 2, name: 'Dra. Maria Santos', oab: 'OAB/SP 234567', cargo: 'Advogada' },
    { id: 3, name: 'Dr. Pedro Costa', oab: 'OAB/SP 345678', cargo: 'Advogado' },
    { id: 4, name: 'Dra. Ana Silva', oab: 'OAB/SP 456789', cargo: 'Advogada' },
    { id: 5, name: 'Dra. Erlene Chaves Silva', oab: 'OAB/SP 567890', cargo: 'Sócia Fundadora' }
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

  // Mock data da tarefa baseado no ID da URL
  const getTarefaMock = (taskId) => {
    const tarefas = {
      1: {
        titulo: 'Elaborar petição inicial',
        descricao: 'Redigir petição inicial do processo de divórcio com levantamento de bens e partilha',
        clienteId: '1',
        processoId: '1',
        responsavelTipo: 'Advogado',
        responsavelId: '1',
        colunaId: '1',
        prioridade: 'Alta',
        dataVencimento: '2024-07-30',
        estimativaHoras: '4',
        horasGastas: '1.5',
        tags: ['petição', 'urgente', 'divórcio'],
        observacoes: 'Cliente solicitou urgência devido a viagem internacional'
      },
      2: {
        titulo: 'Revisar contrato societário',
        descricao: 'Análise completa do contrato de constituição da empresa ABC Ltda com alterações societárias',
        clienteId: '2',
        processoId: '',
        responsavelTipo: 'Advogado',
        responsavelId: '2',
        colunaId: '1',
        prioridade: 'Média',
        dataVencimento: '2024-08-05',
        estimativaHoras: '6',
        horasGastas: '0',
        tags: ['contrato', 'societário', 'análise'],
        observacoes: 'Verificar cláusulas de exclusão de sócios'
      },
      3: {
        titulo: 'Organizar documentos do processo',
        descricao: 'Separar, digitalizar e organizar documentos para o processo trabalhista',
        clienteId: '3',
        processoId: '3',
        responsavelTipo: 'Funcionario',
        responsavelId: '1',
        colunaId: '2',
        prioridade: 'Baixa',
        dataVencimento: '2024-08-15',
        estimativaHoras: '2',
        horasGastas: '0.5',
        tags: ['documentos', 'organização', 'digitalização'],
        observacoes: 'Priorizar documentos de identificação e comprovantes de renda'
      },
      4: {
        titulo: 'Redigir contestação',
        descricao: 'Elaboração de contestação para processo de cobrança da Tech Solutions',
        clienteId: '4',
        processoId: '4',
        responsavelTipo: 'Advogado',
        responsavelId: '1',
        colunaId: '2',
        prioridade: 'Alta',
        dataVencimento: '2024-07-28',
        estimativaHoras: '8',
        horasGastas: '3',
        tags: ['contestação', 'cobrança', 'prazo'],
        observacoes: 'Prazo fatal - vence em 3 dias'
      }
    };
    
    return tarefas[taskId] || tarefas[1];
  };

  useEffect(() => {
    // Simular carregamento dos dados
    setTimeout(() => {
      setClients(mockClients);
      setProcesses(mockProcesses);
      setAdvogados(mockAdvogados);
      setFuncionarios(mockFuncionarios);
      setColunas(mockColunas);
      
      // Carregar dados da tarefa baseado no ID da URL
      const tarefaData = getTarefaMock(id);
      setFormData(prev => ({ ...prev, ...tarefaData }));
    }, 500);
  }, [id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    
    // Limpar erro do campo
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
    
    // Validar horas gastas não pode ser maior que estimativa
    if (formData.estimativaHoras && formData.horasGastas) {
      const estimativa = parseFloat(formData.estimativaHoras);
      const gastas = parseFloat(formData.horasGastas);
      if (gastas > estimativa) {
        newErrors.horasGastas = 'Horas gastas não pode ser maior que estimativa';
      }
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;
    
    setLoading(true);
    try {
      // Simular atualização
      await new Promise(resolve => setTimeout(resolve, 1500));
      alert(`Tarefa "${formData.titulo}" atualizada com sucesso!`);
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

  const getColunaInfo = (colunaId) => {
    const coluna = mockColunas.find(c => c.id.toString() === colunaId);
    return coluna || mockColunas[0];
  };

  const availableProcesses = getAvailableProcesses();
  const responsaveisOptions = getResponsaveisOptions();
  const colunaAtual = getColunaInfo(formData.colunaId);

  return (
    <div className="space-y-8">
      {/* Header seguindo EXATO padrão EditAudiencia */}
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
                ID: #{id} - Atualizar informações da tarefa no Kanban
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
          </div>
        </div>

        {/* Cliente e Processo (Opcional) seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Cliente e Processo (Opcional)</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Cliente</label>
              <select
                name="clienteId"
                value={formData.clienteId}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Selecione o cliente...</option>
                {clients.map((client) => (
                  <option key={client.id} value={client.id}>
                    {client.name} ({client.type}) - {client.document}
                  </option>
                ))}
              </select>
              <p className="text-xs text-gray-500 mt-1">
                Para tarefas gerais pode deixar sem cliente
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Processo</label>
              <select
                name="processoId"
                value={formData.processoId}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                disabled={!formData.clienteId}
              >
                <option value="">Selecione o processo...</option>
                {availableProcesses.map((process) => (
                  <option key={process.id} value={process.id}>
                    {process.number}
                  </option>
                ))}
              </select>
              {formData.clienteId && availableProcesses.length === 0 && (
                <p className="text-sm text-gray-500 mt-1">Nenhum processo encontrado para este cliente</p>
              )}
              {!formData.clienteId && (
                <p className="text-xs text-gray-500 mt-1">Selecione um cliente primeiro</p>
              )}
            </div>

            {/* Preview do relacionamento */}
            {formData.clienteId && (
              <div className="md:col-span-2 bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-2">Relacionamento:</h3>
                <div className="flex items-center">
                  <UserIcon className="w-4 h-4 text-primary-600 mr-2" />
                  <span className="text-sm text-gray-900">
                    {clients.find(c => c.id.toString() === formData.clienteId)?.name}
                  </span>
                  {formData.processoId && (
                    <>
                      <ScaleIcon className="w-4 h-4 text-blue-600 mx-2" />
                      <span className="text-sm text-blue-600">
                        {availableProcesses.find(p => p.id.toString() === formData.processoId)?.number}
                      </span>
                    </>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Configurações e Prazos seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Configurações e Prazos</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Coluna Atual</label>
              <div className="relative">
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
                <div className="absolute right-3 top-3 flex items-center">
                  <div 
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: colunaAtual.cor }}
                  ></div>
                </div>
              </div>
              <p className="text-xs text-gray-500 mt-1">
                Coluna atual: {colunaAtual.nome}
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Prioridade</label>
              <select
                name="prioridade"
                value={formData.prioridade}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Baixa">Baixa</option>
                <option value="Média">Média</option>
                <option value="Alta">Alta</option>
              </select>
              <div className={`text-sm mt-2 flex items-center ${getPrioridadeColor(formData.prioridade)}`}>
                {getPrioridadeIcon(formData.prioridade)}
                <span className="ml-1">Prioridade: {formData.prioridade}</span>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Data de Vencimento *
              </label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="dataVencimento"
                  value={formData.dataVencimento}
                  onChange={handleChange}
                  min={new Date().toISOString().split('T')[0]}
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.dataVencimento ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
              </div>
              {errors.dataVencimento && <p className="text-red-500 text-sm mt-1">{errors.dataVencimento}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Estimativa (horas)
              </label>
              <div className="relative">
                <ClockIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="number"
                  name="estimativaHoras"
                  value={formData.estimativaHoras}
                  onChange={handleChange}
                  min="0"
                  step="0.5"
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Ex: 4.5"
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">
                Tempo estimado para conclusão
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Horas Gastas
              </label>
              <div className="relative">
                <ClockIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="number"
                  name="horasGastas"
                  value={formData.horasGastas}
                  onChange={handleChange}
                  min="0"
                  step="0.5"
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.horasGastas ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="Ex: 2.5"
                />
              </div>
              {errors.horasGastas && <p className="text-red-500 text-sm mt-1">{errors.horasGastas}</p>}
              <p className="text-xs text-gray-500 mt-1">
                Tempo já trabalhado na tarefa
              </p>
            </div>

            {/* Progresso de Horas */}
            {formData.estimativaHoras && formData.horasGastas && (
              <div className="md:col-span-2 bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-2">Progresso de Horas:</h3>
                <div className="flex items-center justify-between text-sm text-gray-600 mb-2">
                  <span>{formData.horasGastas}h trabalhadas</span>
                  <span>{formData.estimativaHoras}h estimadas</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className={`h-2 rounded-full ${
                      (parseFloat(formData.horasGastas) / parseFloat(formData.estimativaHoras)) > 1 
                        ? 'bg-red-500' 
                        : (parseFloat(formData.horasGastas) / parseFloat(formData.estimativaHoras)) > 0.8 
                          ? 'bg-yellow-500' 
                          : 'bg-blue-500'
                    }`}
                    style={{ 
                      width: `${Math.min((parseFloat(formData.horasGastas) / parseFloat(formData.estimativaHoras)) * 100, 100)}%` 
                    }}
                  ></div>
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  {((parseFloat(formData.horasGastas) / parseFloat(formData.estimativaHoras)) * 100).toFixed(0)}% concluído
                </p>
              </div>
            )}
          </div>
        </div>

        {/* Tags seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Tags e Classificação</h2>
          
          <div className="mb-4">
            <div className="flex space-x-2">
              <input
                type="text"
                name="novaTag"
                value={formData.novaTag}
                onChange={handleChange}
                onKeyPress={handleKeyPress}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Digite uma tag e pressione Enter"
              />
              <button
                type="button"
                onClick={addTag}
                className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <TagIcon className="w-5 h-5" />
              </button>
            </div>
            <p className="text-xs text-gray-500 mt-1">
              Tags ajudam na organização e busca das tarefas
            </p>
          </div>
          
          {/* Tags adicionadas */}
          {formData.tags.length > 0 && (
            <div className="flex flex-wrap gap-2 mb-4">
              {formData.tags.map((tag, index) => (
                <span key={index} className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-primary-100 text-primary-800">
                  {tag}
                  <button
                    type="button"
                    onClick={() => removeTag(tag)}
                    className="ml-2 text-primary-600 hover:text-primary-800"
                  >
                    ×
                  </button>
                </span>
              ))}
            </div>
          )}

          {/* Sugestões de tags */}
          <div>
            <p className="text-sm font-medium text-gray-700 mb-2">Sugestões:</p>
            <div className="flex flex-wrap gap-2">
              {['urgente', 'petição', 'contrato', 'audiência', 'prazo', 'análise', 'revisão', 'protocolo'].map((suggestedTag) => (
                <button
                  key={suggestedTag}
                  type="button"
                  onClick={() => {
                    if (!formData.tags.includes(suggestedTag)) {
                      setFormData(prev => ({
                        ...prev,
                        tags: [...prev.tags, suggestedTag]
                      }));
                    }
                  }}
                  className="px-3 py-1 text-xs bg-gray-100 text-gray-700 rounded-full hover:bg-gray-200 transition-colors"
                  disabled={formData.tags.includes(suggestedTag)}
                >
                  + {suggestedTag}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Observações seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Observações</h2>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Observações Adicionais
            </label>
            <textarea
              name="observacoes"
              value={formData.observacoes}
              onChange={handleChange}
              rows={4}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="Observações importantes sobre a tarefa, instruções especiais, etc..."
            />
            <p className="text-xs text-gray-500 mt-1">
              Campo opcional para observações importantes sobre a tarefa
            </p>
          </div>
        </div>

        {/* Botões seguindo EXATO padrão EditAudiencia */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/kanban"
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              Cancelar
            </Link>
            <button
              type="submit"
              disabled={loading}
              className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Salvando...
                </div>
              ) : (
                'Salvar Alterações'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default EditTask;
