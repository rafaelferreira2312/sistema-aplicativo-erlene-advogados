import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  DocumentTextIcon,
  CloudArrowUpIcon,
  UserIcon,
  UsersIcon,
  BuildingOfficeIcon,
  ScaleIcon,
  FolderIcon,
  TagIcon,
  CalendarIcon,
  EyeIcon,
  EyeSlashIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  PhotoIcon,
  DocumentIcon,
  SpeakerWaveIcon,
  VideoCameraIcon,
  TableCellsIcon,
  CodeBracketIcon
} from '@heroicons/react/24/outline';

const NewDocumento = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [clients, setClients] = useState([]);
  const [processes, setProcesses] = useState([]);
  const [advogados, setAdvogados] = useState([]);
  const [fornecedores, setFornecedores] = useState([]);
  
  const [formData, setFormData] = useState({
    // Arquivo
    arquivo: null,
    nome: '',
    
    // Classificação
    categoria: '',
    subcategoria: '',
    
    // Relacionamentos (OPCIONAL)
    vinculadoTipo: '', // Cliente, Advogado, Fornecedor, Nenhum
    vinculadoId: '',
    processoId: '',
    
    // Metadados
    tags: [],
    novaTag: '',
    observacoes: '',
    
    // Configurações
    privacidade: 'Privado',
    dataExpiracao: '',
    notificarPessoa: false,
    criarPasta: true
  });

  const [errors, setErrors] = useState({});
  const [dragActive, setDragActive] = useState(false);
  const [previewUrl, setPreviewUrl] = useState(null);

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
    { id: 3, name: 'Dr. Pedro Costa', oab: 'OAB/SP 345678' },
    { id: 4, name: 'Dra. Ana Silva', oab: 'OAB/SP 456789' },
    { id: 5, name: 'Dra. Erlene Chaves Silva', oab: 'OAB/SP 567890' }
  ];

  const mockFornecedores = [
    { id: 1, name: 'Papelaria Central', cnpj: '11.111.111/0001-11', tipo: 'Material' },
    { id: 2, name: 'Elektro Distribuidora', cnpj: '22.222.222/0001-22', tipo: 'Energia' },
    { id: 3, name: 'Sabesp', cnpj: '33.333.333/0001-33', tipo: 'Água' },
    { id: 4, name: 'Imobiliária São Paulo', cnpj: '44.444.444/0001-44', tipo: 'Imóveis' },
    { id: 5, name: 'TI Soluções Ltda', cnpj: '55.555.555/0001-55', tipo: 'Tecnologia' },
    { id: 6, name: 'Limpeza Total Ltda', cnpj: '66.666.666/0001-66', tipo: 'Limpeza' },
    { id: 7, name: 'Tech Hardware SP', cnpj: '77.777.777/0001-77', tipo: 'Hardware' }
  ];

  useEffect(() => {
    // Simular carregamento
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
    
    // Limpar erro do campo
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }

    // Auto-sugerir categoria baseada no nome do arquivo
    if (name === 'nome' && value) {
      autoClassificarDocumento(value);
    }

    // Limpar relacionamentos quando tipo de pessoa mudar
    if (name === 'vinculadoTipo') {
      setFormData(prev => ({ 
        ...prev, 
        vinculadoId: '', 
        processoId: '' 
      }));
    }

    // Auto-sugerir subcategoria baseada na categoria
    if (name === 'categoria') {
      const subcategorias = getSubcategorias(value);
      if (subcategorias.length > 0) {
        setFormData(prev => ({ 
          ...prev, 
          subcategoria: subcategorias[0] 
        }));
      }
    }
  };

  const autoClassificarDocumento = (nomeArquivo) => {
    const nome = nomeArquivo.toLowerCase();
    
    // Documentos de Clientes
    if (nome.includes('contrato') || nome.includes('honorario')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos de Clientes',
        subcategoria: 'Contratos'
      }));
    } else if (nome.includes('rg') || nome.includes('cpf') || nome.includes('identidade')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos de Clientes',
        subcategoria: 'Documentos Pessoais'
      }));
    } else if (nome.includes('peticao') || nome.includes('contestacao') || nome.includes('recurso')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos de Clientes',
        subcategoria: 'Documentos Processuais'
      }));
    }
    // Documentos Financeiros
    else if (nome.includes('nota') && nome.includes('fiscal')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos Financeiros',
        subcategoria: 'Notas Fiscais'
      }));
    } else if (nome.includes('boleto')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos Financeiros',
        subcategoria: 'Boletos'
      }));
    } else if (nome.includes('comprovante') || nome.includes('pix')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos Financeiros',
        subcategoria: 'Comprovantes'
      }));
    }
    // Documentos de Funcionários
    else if (nome.includes('oab') || nome.includes('carteira')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos de Funcionários',
        subcategoria: 'Carteira OAB'
      }));
    } else if (nome.includes('curriculo') || nome.includes('cv')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos de Funcionários',
        subcategoria: 'Currículos'
      }));
    }
    // Documentos de Fornecedores
    else if (nome.includes('manual')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos de Fornecedores',
        subcategoria: 'Manuais'
      }));
    } else if (nome.includes('garantia') || nome.includes('certificado')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos de Fornecedores',
        subcategoria: 'Certificados'
      }));
    }
    // Documentos Administrativos
    else if (nome.includes('regulamento') || nome.includes('ata')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos Administrativos',
        subcategoria: 'Documentos Internos'
      }));
    } else if (nome.includes('locacao') || nome.includes('aluguel')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos Administrativos',
        subcategoria: 'Documentos Imobiliários'
      }));
    } else if (nome.includes('seguro') || nome.includes('apolice')) {
      setFormData(prev => ({ 
        ...prev, 
        categoria: 'Documentos Administrativos',
        subcategoria: 'Seguros'
      }));
    }
  };

  const handleFileSelect = (file) => {
    if (!file) return;

    // Validar tipo de arquivo
    const allowedTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'image/jpeg',
      'image/png',
      'image/gif',
      'audio/mpeg',
      'audio/wav',
      'video/mp4',
      'video/avi',
      'text/xml',
      'application/xml'
    ];

    if (!allowedTypes.includes(file.type)) {
      setErrors({ arquivo: 'Tipo de arquivo não suportado' });
      return;
    }

    // Validar tamanho (máximo 50MB)
    const maxSize = 50 * 1024 * 1024; // 50MB
    if (file.size > maxSize) {
      setErrors({ arquivo: 'Arquivo muito grande. Máximo 50MB.' });
      return;
    }

    setFormData(prev => ({
      ...prev,
      arquivo: file,
      nome: file.name
    }));

    // Auto-classificar baseado no nome do arquivo
    autoClassificarDocumento(file.name);

    // Criar preview para imagens
    if (file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onload = (e) => setPreviewUrl(e.target.result);
      reader.readAsDataURL(file);
    } else {
      setPreviewUrl(null);
    }

    // Limpar erro
    if (errors.arquivo) {
      setErrors(prev => ({ ...prev, arquivo: '' }));
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    
    const files = [...e.dataTransfer.files];
    if (files.length > 0) {
      handleFileSelect(files[0]);
    }
  };

  const handleDrag = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === 'dragenter' || e.type === 'dragover') {
      setDragActive(true);
    } else if (e.type === 'dragleave') {
      setDragActive(false);
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
    
    if (!formData.arquivo) newErrors.arquivo = 'Arquivo é obrigatório';
    if (!formData.nome.trim()) newErrors.nome = 'Nome do documento é obrigatório';
    if (!formData.categoria.trim()) newErrors.categoria = 'Categoria é obrigatória';
    if (!formData.subcategoria.trim()) newErrors.subcategoria = 'Subcategoria é obrigatória';
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;
    
    setLoading(true);
    try {
      // Simular upload
      await new Promise(resolve => setTimeout(resolve, 2000));
      alert('Documento enviado com sucesso!');
      navigate('/admin/documentos');
    } catch (error) {
      alert('Erro ao enviar documento');
    } finally {
      setLoading(false);
    }
  };

  // Obter pessoa selecionada baseada no tipo
  const getSelectedPerson = () => {
    if (!formData.vinculadoTipo || !formData.vinculadoId) return null;
    
    switch (formData.vinculadoTipo) {
      case 'Cliente': return mockClients.find(c => c.id.toString() === formData.vinculadoId);
      case 'Advogado': return mockAdvogados.find(a => a.id.toString() === formData.vinculadoId);
      case 'Fornecedor': return mockFornecedores.find(f => f.id.toString() === formData.vinculadoId);
      default: return null;
    }
  };

  const getAvailableProcesses = () => {
    if (formData.vinculadoTipo === 'Cliente' && formData.vinculadoId) {
      return mockProcesses.filter(p => p.clientId.toString() === formData.vinculadoId);
    }
    return [];
  };

  const selectedPerson = getSelectedPerson();
  const availableProcesses = getAvailableProcesses();

  // Categorias e subcategorias
  const categorias = [
    'Documentos de Clientes',
    'Documentos Financeiros', 
    'Documentos de Funcionários',
    'Documentos de Fornecedores',
    'Documentos Administrativos'
  ];

  const getSubcategorias = (categoria) => {
    switch (categoria) {
      case 'Documentos de Clientes':
        return ['Contratos', 'Documentos Pessoais', 'Documentos Processuais', 'Procurações', 'Certidões', 'Comprovantes'];
      case 'Documentos Financeiros':
        return ['Notas Fiscais', 'Boletos', 'Comprovantes', 'Extratos', 'Contratos', 'Recibos', 'Impostos'];
      case 'Documentos de Funcionários':
        return ['Documentos Pessoais', 'Carteira OAB', 'Currículos', 'Contratos', 'Documentos Trabalhistas', 'Certificados', 'Folhas de Pagamento'];
      case 'Documentos de Fornecedores':
        return ['Contratos', 'Manuais', 'Notas Fiscais', 'Certificados', 'Documentos Societários', 'Propostas'];
      case 'Documentos Administrativos':
        return ['Documentos Internos', 'Correspondências', 'Licenças', 'Seguros', 'Documentos Imobiliários', 'Manuais'];
      default:
        return [];
    }
  };

  const tiposPessoa = [
    { value: '', label: 'Nenhuma pessoa vinculada' },
    { value: 'Cliente', label: 'Cliente' },
    { value: 'Advogado', label: 'Advogado/Funcionário' },
    { value: 'Fornecedor', label: 'Fornecedor' }
  ];

  const privacidadeOptions = [
    { value: 'Público', label: 'Público - Visível para todos', icon: EyeIcon },
    { value: 'Privado', label: 'Privado - Apenas responsáveis', icon: EyeSlashIcon },
    { value: 'Restrito', label: 'Restrito - Acesso limitado', icon: ExclamationTriangleIcon }
  ];

  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'Cliente': return <UserIcon className="w-4 h-4 text-primary-600" />;
      case 'Advogado': return <UsersIcon className="w-4 h-4 text-blue-600" />;
      case 'Fornecedor': return <BuildingOfficeIcon className="w-4 h-4 text-orange-600" />;
      default: return <UserIcon className="w-4 h-4 text-gray-600" />;
    }
  };

  const getFileIcon = (file) => {
    if (!file) return <DocumentTextIcon className="w-12 h-12 text-gray-400" />;
    
    const type = file.type;
    if (type.includes('pdf')) return <DocumentIcon className="w-12 h-12 text-red-500" />;
    if (type.includes('image')) return <PhotoIcon className="w-12 h-12 text-yellow-500" />;
    if (type.includes('audio')) return <SpeakerWaveIcon className="w-12 h-12 text-purple-500" />;
    if (type.includes('video')) return <VideoCameraIcon className="w-12 h-12 text-pink-500" />;
    if (type.includes('excel') || type.includes('spreadsheet')) return <TableCellsIcon className="w-12 h-12 text-green-500" />;
    if (type.includes('xml')) return <CodeBracketIcon className="w-12 h-12 text-gray-500" />;
    return <DocumentTextIcon className="w-12 h-12 text-blue-500" />;
  };

  const formatFileSize = (bytes) => {
    if (!bytes) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/documentos"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Upload de Documento</h1>
              <p className="text-lg text-gray-600 mt-2">
                Faça upload de documentos com classificação automática
              </p>
            </div>
          </div>
          <DocumentTextIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Upload de Arquivo */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Arquivo</h2>
          
          {/* Área de Drop */}
          <div
            className={`relative border-2 border-dashed rounded-xl p-8 text-center transition-colors ${
              dragActive 
                ? 'border-primary-500 bg-primary-50' 
                : errors.arquivo 
                  ? 'border-red-300 bg-red-50' 
                  : 'border-gray-300 hover:border-gray-400'
            }`}
            onDragEnter={handleDrag}
            onDragLeave={handleDrag}
            onDragOver={handleDrag}
            onDrop={handleDrop}
          >
            <input
              type="file"
              onChange={(e) => handleFileSelect(e.target.files[0])}
              className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
              accept=".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png,.gif,.mp3,.wav,.mp4,.avi,.xml"
            />
            
            {formData.arquivo ? (
              <div className="space-y-4">
                <div className="flex items-center justify-center">
                  {previewUrl ? (
                    <img src={previewUrl} alt="Preview" className="w-24 h-24 object-cover rounded-lg" />
                  ) : (
                    getFileIcon(formData.arquivo)
                  )}
                </div>
                <div>
                  <p className="text-lg font-medium text-gray-900">{formData.arquivo.name}</p>
                  <p className="text-sm text-gray-500">{formatFileSize(formData.arquivo.size)}</p>
                  <div className="flex items-center justify-center mt-2">
                    <CheckCircleIcon className="w-5 h-5 text-green-500 mr-2" />
                    <span className="text-sm text-green-600">Arquivo carregado com sucesso</span>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => {
                    setFormData(prev => ({ ...prev, arquivo: null, nome: '' }));
                    setPreviewUrl(null);
                  }}
                  className="text-sm text-red-600 hover:text-red-800"
                >
                  Remover arquivo
                </button>
              </div>
            ) : (
              <div className="space-y-4">
                <CloudArrowUpIcon className="mx-auto h-12 w-12 text-gray-400" />
                <div>
                  <p className="text-lg font-medium text-gray-900">
                    Arraste e solte seu arquivo aqui
                  </p>
                  <p className="text-sm text-gray-500">
                    ou clique para selecionar
                  </p>
                </div>
                <div className="text-xs text-gray-400">
                  Tipos aceitos: PDF, DOC, XLS, IMG, AUDIO, VIDEO, XML (máx. 50MB)
                </div>
              </div>
            )}
          </div>
          {errors.arquivo && <p className="text-red-500 text-sm mt-2">{errors.arquivo}</p>}
          
          {/* Nome do Documento */}
          <div className="mt-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Nome do Documento *
            </label>
            <input
              type="text"
              name="nome"
              value={formData.nome}
              onChange={handleChange}
              className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                errors.nome ? 'border-red-300' : 'border-gray-300'
              }`}
              placeholder="Ex: Contrato_Honorarios_Joao_Silva.pdf"
            />
            {errors.nome && <p className="text-red-500 text-sm mt-1">{errors.nome}</p>}
            <p className="text-xs text-gray-500 mt-1">
              O sistema tentará classificar automaticamente com base no nome
            </p>
          </div>
        </div>

        {/* Classificação */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Classificação</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Categoria *
              </label>
              <select
                name="categoria"
                value={formData.categoria}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.categoria ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione a categoria...</option>
                {categorias.map((categoria) => (
                  <option key={categoria} value={categoria}>{categoria}</option>
                ))}
              </select>
              {errors.categoria && <p className="text-red-500 text-sm mt-1">{errors.categoria}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Subcategoria *
              </label>
              <select
                name="subcategoria"
                value={formData.subcategoria}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.subcategoria ? 'border-red-300' : 'border-gray-300'
                }`}
                disabled={!formData.categoria}
              >
                <option value="">Selecione a subcategoria...</option>
                {getSubcategorias(formData.categoria).map((sub) => (
                  <option key={sub} value={sub}>{sub}</option>
                ))}
              </select>
              {errors.subcategoria && <p className="text-red-500 text-sm mt-1">{errors.subcategoria}</p>}
            </div>
          </div>

          {formData.categoria && (
            <div className="mt-4 p-4 bg-blue-50 rounded-lg">
              <div className="flex items-center">
                <FolderIcon className="w-5 h-5 text-blue-600 mr-2" />
                <span className="text-sm font-medium text-blue-900">
                  Pasta: /documentos/{formData.categoria.toLowerCase().replace(/\s+/g, '_')}/
                  {formData.subcategoria.toLowerCase().replace(/\s+/g, '_')}/
                </span>
              </div>
            </div>
          )}
        </div>

        {/* Relacionamentos (Opcional) */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Relacionamentos (Opcional)</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Tipo de Pessoa</label>
              <select
                name="vinculadoTipo"
                value={formData.vinculadoTipo}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                {tiposPessoa.map((tipo) => (
                  <option key={tipo.value} value={tipo.value}>{tipo.label}</option>
                ))}
              </select>
              <p className="text-xs text-gray-500 mt-1">
                Para documentos gerais pode deixar sem pessoa vinculada
              </p>
            </div>

            {formData.vinculadoTipo && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Selecionar {formData.vinculadoTipo}
                </label>
                <select
                  name="vinculadoId"
                  value={formData.vinculadoId}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="">Selecione...</option>
                  {formData.vinculadoTipo === 'Cliente' && mockClients.map((client) => (
                    <option key={client.id} value={client.id}>
                      {client.name} ({client.document})
                    </option>
                  ))}
                  {formData.vinculadoTipo === 'Advogado' && mockAdvogados.map((advogado) => (
                    <option key={advogado.id} value={advogado.id}>
                      {advogado.name} ({advogado.oab})
                    </option>
                  ))}
                  {formData.vinculadoTipo === 'Fornecedor' && mockFornecedores.map((fornecedor) => (
                    <option key={fornecedor.id} value={fornecedor.id}>
                      {fornecedor.name} - {fornecedor.tipo}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Processo (só para Cliente) */}
            {formData.vinculadoTipo === 'Cliente' && availableProcesses.length > 0 && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">Processo (opcional)</label>
                <select
                  name="processoId"
                  value={formData.processoId}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="">Selecione o processo...</option>
                  {availableProcesses.map((process) => (
                    <option key={process.id} value={process.id}>
                      {process.number}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Preview da Pessoa Selecionada */}
            {selectedPerson && (
              <div className="md:col-span-2 bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-3">Relacionamento:</h3>
                <div className="flex items-center">
                  {getTipoIcon(formData.vinculadoTipo)}
                  <div className="ml-3">
                    <div className="font-medium text-gray-900">{selectedPerson.name}</div>
                    <div className="text-sm text-gray-500">
                      {selectedPerson.document || selectedPerson.oab || selectedPerson.cnpj || ''}
                      {selectedPerson.tipo && ` - ${selectedPerson.tipo}`}
                    </div>
                  </div>
                </div>
                {formData.processoId && (
                  <div className="mt-2 flex items-center">
                    <ScaleIcon className="w-4 h-4 text-primary-600 mr-2" />
                    <div className="text-sm text-gray-700">
                      Processo: {availableProcesses.find(p => p.id.toString() === formData.processoId)?.number}
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        {/* Tags e Metadados */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Tags e Metadados</h2>
          
          {/* Tags */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">Tags</label>
            <div className="flex space-x-2 mb-3">
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
            
            {/* Tags Adicionadas */}
            {formData.tags.length > 0 && (
              <div className="flex flex-wrap gap-2">
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
            <p className="text-xs text-gray-500 mt-1">
              Tags ajudam na busca e organização dos documentos
            </p>
          </div>
          
          {/* Observações */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Observações</label>
            <textarea
              name="observacoes"
              value={formData.observacoes}
              onChange={handleChange}
              rows={4}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="Observações sobre o documento..."
            />
          </div>
        </div>

        {/* Configurações */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Configurações</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Privacidade */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-3">Privacidade</label>
              <div className="space-y-3">
                {privacidadeOptions.map((option) => (
                  <label key={option.value} className="flex items-center">
                    <input
                      type="radio"
                      name="privacidade"
                      value={option.value}
                      checked={formData.privacidade === option.value}
                      onChange={handleChange}
                      className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                    />
                    <div className="ml-3 flex items-center">
                      <option.icon className="w-4 h-4 text-gray-600 mr-2" />
                      <div>
                        <div className="text-sm font-medium text-gray-900">{option.value}</div>
                        <div className="text-xs text-gray-500">{option.label.split(' - ')[1]}</div>
                      </div>
                    </div>
                  </label>
                ))}
              </div>
            </div>
            
            {/* Data de Expiração */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Data de Expiração (opcional)
              </label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="dataExpiracao"
                  value={formData.dataExpiracao}
                  onChange={handleChange}
                  min={new Date().toISOString().split('T')[0]}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">
                Para documentos temporários ou com validade
              </p>
            </div>
          </div>
          
          {/* Configurações Adicionais */}
          <div className="mt-6 space-y-4">
            <label className="flex items-center">
              <input
                type="checkbox"
                name="notificarPessoa"
                checked={formData.notificarPessoa}
                onChange={handleChange}
                className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
              />
              <span className="ml-3 text-sm font-medium text-gray-700">
                Notificar pessoa vinculada sobre o documento
              </span>
            </label>
            
            <label className="flex items-center">
              <input
                type="checkbox"
                name="criarPasta"
                checked={formData.criarPasta}
                onChange={handleChange}
                className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
              />
              <span className="ml-3 text-sm font-medium text-gray-700">
                Criar pasta automaticamente se não existir
              </span>
            </label>
          </div>
        </div>

        {/* Botões */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/documentos"
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              Cancelar
            </Link>
            <button
              type="submit"
              disabled={loading || !formData.arquivo}
              className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Enviando...
                </div>
              ) : (
                'Enviar Documento'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewDocumento;
