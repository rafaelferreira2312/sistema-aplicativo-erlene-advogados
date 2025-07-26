import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  DocumentTextIcon,
  FolderIcon,
  ArrowDownTrayIcon,
  UserIcon,
  UsersIcon,
  BuildingOfficeIcon,
  DocumentIcon,
  PhotoIcon,
  SpeakerWaveIcon,
  VideoCameraIcon,
  TableCellsIcon,
  CodeBracketIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  ClockIcon,
  CalendarIcon
} from '@heroicons/react/24/outline';

const Documentos = () => {
  const [documentos, setDocumentos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterCategoria, setFilterCategoria] = useState('all');
  const [filterTipo, setFilterTipo] = useState('all');
  const [filterPessoa, setFilterPessoa] = useState('all');
  const [filterPeriodo, setFilterPeriodo] = useState('mes');

  // Mock data expandido com 5 categorias de documentos
  const mockDocumentos = [
    // DOCUMENTOS DE CLIENTES
    {
      id: 1,
      nome: 'Contrato_Honorarios_Joao_Silva.pdf',
      categoria: 'Documentos de Clientes',
      subcategoria: 'Contratos',
      tipo: 'PDF',
      vinculadoTipo: 'Cliente',
      vinculadoId: 1,
      vinculadoNome: 'João Silva Santos',
      processoId: 1,
      processoNumero: '1001234-56.2024.8.26.0001',
      tamanho: '2.5 MB',
      extensao: 'pdf',
      tags: ['contrato', 'honorários', 'assinado'],
      dataUpload: '2024-07-25',
      uploadPor: 'Dr. Carlos Oliveira',
      observacoes: 'Contrato assinado pelas duas partes',
      pasta: '/documentos/clientes/joao_silva/contratos/',
      caminho: 'Contrato_Honorarios_Joao_Silva.pdf',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Privado',
      dataExpiracao: null,
      ultimaVisualizacao: '2024-07-26',
      totalDownloads: 3
    },
    {
      id: 2,
      nome: 'RG_Maria_Oliveira.jpg',
      categoria: 'Documentos de Clientes',
      subcategoria: 'Documentos Pessoais',
      tipo: 'IMG',
      vinculadoTipo: 'Cliente',
      vinculadoId: 3,
      vinculadoNome: 'Maria Oliveira Costa',
      processoId: null,
      processoNumero: '',
      tamanho: '1.2 MB',
      extensao: 'jpg',
      tags: ['rg', 'identidade', 'documentos'],
      dataUpload: '2024-07-20',
      uploadPor: 'Dra. Maria Santos',
      observacoes: 'RG digitalizado em alta qualidade',
      pasta: '/documentos/clientes/maria_oliveira/pessoais/',
      caminho: 'RG_Maria_Oliveira.jpg',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Privado',
      dataExpiracao: null,
      ultimaVisualizacao: '2024-07-25',
      totalDownloads: 1
    },
    {
      id: 3,
      nome: 'Peticao_Inicial_Divorcio.pdf',
      categoria: 'Documentos de Clientes',
      subcategoria: 'Documentos Processuais',
      tipo: 'PDF',
      vinculadoTipo: 'Cliente',
      vinculadoId: 1,
      vinculadoNome: 'João Silva Santos',
      processoId: 1,
      processoNumero: '1001234-56.2024.8.26.0001',
      tamanho: '5.8 MB',
      extensao: 'pdf',
      tags: ['petição', 'divórcio', 'inicial'],
      dataUpload: '2024-07-18',
      uploadPor: 'Dr. Carlos Oliveira',
      observacoes: 'Petição inicial protocolada no TJSP',
      pasta: '/documentos/clientes/joao_silva/processuais/',
      caminho: 'Peticao_Inicial_Divorcio.pdf',
      versao: 2,
      status: 'Ativo',
      privacidade: 'Restrito',
      dataExpiracao: null,
      ultimaVisualizacao: '2024-07-26',
      totalDownloads: 8
    },

    // DOCUMENTOS FINANCEIROS
    {
      id: 4,
      nome: 'NF_Papelaria_Julho2024.pdf',
      categoria: 'Documentos Financeiros',
      subcategoria: 'Notas Fiscais',
      tipo: 'PDF',
      vinculadoTipo: 'Fornecedor',
      vinculadoId: 1,
      vinculadoNome: 'Papelaria Central',
      processoId: null,
      processoNumero: '',
      tamanho: '0.8 MB',
      extensao: 'pdf',
      tags: ['nota fiscal', 'material', 'escritório'],
      dataUpload: '2024-07-23',
      uploadPor: 'Administrativo',
      observacoes: 'Material de escritório - julho/2024',
      pasta: '/documentos/financeiro/notas_fiscais/',
      caminho: 'NF_Papelaria_Julho2024.pdf',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Público',
      dataExpiracao: null,
      ultimaVisualizacao: '2024-07-24',
      totalDownloads: 2
    },
    {
      id: 5,
      nome: 'Boleto_Aluguel_Agosto.pdf',
      categoria: 'Documentos Financeiros',
      subcategoria: 'Boletos',
      tipo: 'PDF',
      vinculadoTipo: 'Fornecedor',
      vinculadoId: 4,
      vinculadoNome: 'Imobiliária São Paulo',
      processoId: null,
      processoNumero: '',
      tamanho: '0.3 MB',
      extensao: 'pdf',
      tags: ['boleto', 'aluguel', 'agosto'],
      dataUpload: '2024-07-26',
      uploadPor: 'Financeiro',
      observacoes: 'Boleto do aluguel - agosto/2024',
      pasta: '/documentos/financeiro/boletos/',
      caminho: 'Boleto_Aluguel_Agosto.pdf',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Privado',
      dataExpiracao: '2024-08-10',
      ultimaVisualizacao: '2024-07-26',
      totalDownloads: 0
    },
    {
      id: 6,
      nome: 'Comprovante_PIX_Honorarios.jpg',
      categoria: 'Documentos Financeiros',
      subcategoria: 'Comprovantes',
      tipo: 'IMG',
      vinculadoTipo: 'Cliente',
      vinculadoId: 2,
      vinculadoNome: 'Empresa ABC Ltda',
      processoId: 2,
      processoNumero: '2002345-67.2024.8.26.0002',
      tamanho: '0.5 MB',
      extensao: 'jpg',
      tags: ['pix', 'comprovante', 'honorários'],
      dataUpload: '2024-07-25',
      uploadPor: 'Dra. Maria Santos',
      observacoes: 'Comprovante de pagamento via PIX',
      pasta: '/documentos/financeiro/comprovantes/',
      caminho: 'Comprovante_PIX_Honorarios.jpg',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Privado',
      dataExpiracao: null,
      ultimaVisualizacao: '2024-07-25',
      totalDownloads: 1
    },

    // DOCUMENTOS DE FUNCIONÁRIOS
    {
      id: 7,
      nome: 'OAB_Carlos_Oliveira.pdf',
      categoria: 'Documentos de Funcionários',
      subcategoria: 'Carteira OAB',
      tipo: 'PDF',
      vinculadoTipo: 'Advogado',
      vinculadoId: 1,
      vinculadoNome: 'Dr. Carlos Oliveira',
      processoId: null,
      processoNumero: '',
      tamanho: '1.1 MB',
      extensao: 'pdf',
      tags: ['oab', 'carteira', 'advogado'],
      dataUpload: '2024-07-15',
      uploadPor: 'Dr. Carlos Oliveira',
      observacoes: 'Carteira OAB/SP atualizada',
      pasta: '/documentos/funcionarios/carlos_oliveira/oab/',
      caminho: 'OAB_Carlos_Oliveira.pdf',
      versao: 2,
      status: 'Ativo',
      privacidade: 'Público',
      dataExpiracao: '2025-12-31',
      ultimaVisualizacao: '2024-07-20',
      totalDownloads: 5
    },
    {
      id: 8,
      nome: 'Curriculum_Maria_Santos.pdf',
      categoria: 'Documentos de Funcionários',
      subcategoria: 'Currículos',
      tipo: 'PDF',
      vinculadoTipo: 'Advogado',
      vinculadoId: 2,
      vinculadoNome: 'Dra. Maria Santos',
      processoId: null,
      processoNumero: '',
      tamanho: '1.8 MB',
      extensao: 'pdf',
      tags: ['currículo', 'advocacia', 'experiência'],
      dataUpload: '2024-07-10',
      uploadPor: 'Dra. Maria Santos',
      observacoes: 'Currículo atualizado 2024',
      pasta: '/documentos/funcionarios/maria_santos/curriculos/',
      caminho: 'Curriculum_Maria_Santos.pdf',
      versao: 3,
      status: 'Ativo',
      privacidade: 'Restrito',
      dataExpiracao: null,
      ultimaVisualizacao: '2024-07-15',
      totalDownloads: 2
    },
    {
      id: 9,
      nome: 'Contrato_Trabalho_Pedro.pdf',
      categoria: 'Documentos de Funcionários',
      subcategoria: 'Contratos',
      tipo: 'PDF',
      vinculadoTipo: 'Advogado',
      vinculadoId: 3,
      vinculadoNome: 'Dr. Pedro Costa',
      processoId: null,
      processoNumero: '',
      tamanho: '2.2 MB',
      extensao: 'pdf',
      tags: ['contrato', 'trabalho', 'clt'],
      dataUpload: '2024-07-12',
      uploadPor: 'Administrativo',
      observacoes: 'Contrato de trabalho assinado',
      pasta: '/documentos/funcionarios/pedro_costa/contratos/',
      caminho: 'Contrato_Trabalho_Pedro.pdf',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Privado',
      dataExpiracao: null,
      ultimaVisualizacao: '2024-07-12',
      totalDownloads: 1
    },

    // DOCUMENTOS DE FORNECEDORES
    {
      id: 10,
      nome: 'Manual_Sistema_Juridico.pdf',
      categoria: 'Documentos de Fornecedores',
      subcategoria: 'Manuais',
      tipo: 'PDF',
      vinculadoTipo: 'Fornecedor',
      vinculadoId: 5,
      vinculadoNome: 'TI Soluções Ltda',
      processoId: null,
      processoNumero: '',
      tamanho: '12.5 MB',
      extensao: 'pdf',
      tags: ['manual', 'sistema', 'software'],
      dataUpload: '2024-07-14',
      uploadPor: 'Administrativo',
      observacoes: 'Manual do sistema jurídico v2.0',
      pasta: '/documentos/fornecedores/ti_solucoes/manuais/',
      caminho: 'Manual_Sistema_Juridico.pdf',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Público',
      dataExpiracao: null,
      ultimaVisualizacao: '2024-07-26',
      totalDownloads: 15
    },
    {
      id: 11,
      nome: 'Contrato_Limpeza_Predial.pdf',
      categoria: 'Documentos de Fornecedores',
      subcategoria: 'Contratos',
      tipo: 'PDF',
      vinculadoTipo: 'Fornecedor',
      vinculadoId: 6,
      vinculadoNome: 'Limpeza Total Ltda',
      processoId: null,
      processoNumero: '',
      tamanho: '3.1 MB',
      extensao: 'pdf',
      tags: ['contrato', 'limpeza', 'prestação'],
      dataUpload: '2024-07-16',
      uploadPor: 'Administrativo',
      observacoes: 'Contrato de prestação de serviços',
      pasta: '/documentos/fornecedores/limpeza_total/contratos/',
      caminho: 'Contrato_Limpeza_Predial.pdf',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Privado',
      dataExpiracao: '2025-07-16',
      ultimaVisualizacao: '2024-07-20',
      totalDownloads: 3
    },
    {
      id: 12,
      nome: 'Garantia_Impressora_HP.pdf',
      categoria: 'Documentos de Fornecedores',
      subcategoria: 'Certificados',
      tipo: 'PDF',
      vinculadoTipo: 'Fornecedor',
      vinculadoId: 7,
      vinculadoNome: 'Tech Hardware SP',
      processoId: null,
      processoNumero: '',
      tamanho: '0.7 MB',
      extensao: 'pdf',
      tags: ['garantia', 'impressora', 'equipamento'],
      dataUpload: '2024-07-22',
      uploadPor: 'Administrativo',
      observacoes: 'Garantia de 2 anos - Impressora HP',
      pasta: '/documentos/fornecedores/tech_hardware/certificados/',
      caminho: 'Garantia_Impressora_HP.pdf',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Público',
      dataExpiracao: '2026-07-22',
      ultimaVisualizacao: '2024-07-22',
      totalDownloads: 0
    },

    // DOCUMENTOS ADMINISTRATIVOS
    {
      id: 13,
      nome: 'Regulamento_Interno_2024.pdf',
      categoria: 'Documentos Administrativos',
      subcategoria: 'Documentos Internos',
      tipo: 'PDF',
      vinculadoTipo: '',
      vinculadoId: null,
      vinculadoNome: '',
      processoId: null,
      processoNumero: '',
      tamanho: '4.2 MB',
      extensao: 'pdf',
      tags: ['regulamento', 'interno', 'escritório'],
      dataUpload: '2024-07-01',
      uploadPor: 'Dra. Erlene Chaves Silva',
      observacoes: 'Regulamento interno atualizado 2024',
      pasta: '/documentos/administrativos/internos/',
      caminho: 'Regulamento_Interno_2024.pdf',
      versao: 4,
      status: 'Ativo',
      privacidade: 'Público',
      dataExpiracao: '2024-12-31',
      ultimaVisualizacao: '2024-07-26',
      totalDownloads: 25
    },
    {
      id: 14,
      nome: 'Contrato_Locacao_Escritorio.pdf',
      categoria: 'Documentos Administrativos',
      subcategoria: 'Documentos Imobiliários',
      tipo: 'PDF',
      vinculadoTipo: '',
      vinculadoId: null,
      vinculadoNome: '',
      processoId: null,
      processoNumero: '',
      tamanho: '6.3 MB',
      extensao: 'pdf',
      tags: ['contrato', 'locação', 'escritório'],
      dataUpload: '2024-07-05',
      uploadPor: 'Administrativo',
      observacoes: 'Contrato de locação vigente',
      pasta: '/documentos/administrativos/imobiliarios/',
      caminho: 'Contrato_Locacao_Escritorio.pdf',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Privado',
      dataExpiracao: '2027-07-05',
      ultimaVisualizacao: '2024-07-10',
      totalDownloads: 4
    },
    {
      id: 15,
      nome: 'Apolice_Seguro_Predial.pdf',
      categoria: 'Documentos Administrativos',
      subcategoria: 'Seguros',
      tipo: 'PDF',
      vinculadoTipo: '',
      vinculadoId: null,
      vinculadoNome: '',
      processoId: null,
      processoNumero: '',
      tamanho: '2.8 MB',
      extensao: 'pdf',
      tags: ['apólice', 'seguro', 'predial'],
      dataUpload: '2024-07-08',
      uploadPor: 'Financeiro',
      observacoes: 'Apólice de seguro predial 2024',
      pasta: '/documentos/administrativos/seguros/',
      caminho: 'Apolice_Seguro_Predial.pdf',
      versao: 1,
      status: 'Ativo',
      privacidade: 'Privado',
      dataExpiracao: '2025-07-08',
      ultimaVisualizacao: '2024-07-15',
      totalDownloads: 2
    }
  ];

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setDocumentos(mockDocumentos);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas por categoria
  const clientes = documentos.filter(d => d.categoria === 'Documentos de Clientes');
  const financeiros = documentos.filter(d => d.categoria === 'Documentos Financeiros');
  const funcionarios = documentos.filter(d => d.categoria === 'Documentos de Funcionários');
  const fornecedores = documentos.filter(d => d.categoria === 'Documentos de Fornecedores');
  const administrativos = documentos.filter(d => d.categoria === 'Documentos Administrativos');
  
  const totalTamanho = documentos.reduce((sum, doc) => {
    const tamanhoNum = parseFloat(doc.tamanho.replace(' MB', ''));
    return sum + tamanhoNum;
  }, 0);

  const uploadHoje = documentos.filter(d => d.dataUpload === '2024-07-26').length;

  const stats = [
    {
      name: 'Total de Documentos',
      value: documentos.length.toString(),
      change: '+5',
      changeType: 'increase',
      icon: DocumentTextIcon,
      color: 'blue',
      description: `${uploadHoje} upload(s) hoje`
    },
    {
      name: 'Por Categoria',
      value: clientes.length.toString(),
      change: 'Clientes',
      changeType: 'neutral',
      icon: UserIcon,
      color: 'green',
      description: 'Maior categoria'
    },
    {
      name: 'Tamanho Total',
      value: `${totalTamanho.toFixed(1)} MB`,
      change: '85%',
      changeType: 'neutral',
      icon: FolderIcon,
      color: 'yellow',
      description: 'de 100 MB limite'
    },
    {
      name: 'Hoje',
      value: uploadHoje.toString(),
      change: '+2',
      changeType: 'increase',
      icon: ArrowUpIcon,
      color: 'purple',
      description: 'novos uploads'
    }
  ];

  // Filtrar documentos
  const filteredDocumentos = documentos.filter(documento => {
    const matchesSearch = documento.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         documento.tags.some(tag => tag.toLowerCase().includes(searchTerm.toLowerCase())) ||
                         (documento.vinculadoNome && documento.vinculadoNome.toLowerCase().includes(searchTerm.toLowerCase())) ||
                         documento.uploadPor.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesCategoria = filterCategoria === 'all' || documento.categoria === filterCategoria;
    const matchesTipo = filterTipo === 'all' || documento.tipo === filterTipo;
    const matchesPessoa = filterPessoa === 'all' || documento.vinculadoTipo === filterPessoa;
    
    // Filtro por período
    let matchesPeriodo = true;
    const dataUpload = new Date(documento.dataUpload);
    const hoje = new Date();
    
    if (filterPeriodo === 'hoje') {
      const hojeStr = hoje.toISOString().split('T')[0];
      matchesPeriodo = documento.dataUpload === hojeStr;
    } else if (filterPeriodo === 'semana') {
      const inicioSemana = new Date();
      inicioSemana.setDate(inicioSemana.getDate() - 7);
      matchesPeriodo = dataUpload >= inicioSemana;
    } else if (filterPeriodo === 'mes') {
      const inicioMes = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
      matchesPeriodo = dataUpload >= inicioMes;
    }
    
    return matchesSearch && matchesCategoria && matchesTipo && matchesPessoa && matchesPeriodo;
  });

  const handleDelete = (id) => {
    if (window.confirm('Tem certeza que deseja excluir este documento?')) {
      setDocumentos(prev => prev.filter(doc => doc.id !== id));
    }
  };

  const handleDownload = (documento) => {
    // Simular download
    alert(`Download iniciado: ${documento.nome}`);
    
    // Atualizar contador de downloads
    setDocumentos(prev => prev.map(doc => 
      doc.id === documento.id ? { ...doc, totalDownloads: doc.totalDownloads + 1 } : doc
    ));
  };

  const handlePreview = (documento) => {
    // Simular preview
    alert(`Preview: ${documento.nome}\nTipo: ${documento.tipo}\nTamanho: ${documento.tamanho}`);
    
    // Atualizar última visualização
    setDocumentos(prev => prev.map(doc => 
      doc.id === documento.id ? { ...doc, ultimaVisualizacao: new Date().toISOString().split('T')[0] } : doc
    ));
  };

  // Ícones por categoria
  const getCategoriaIcon = (categoria) => {
    switch (categoria) {
      case 'Documentos de Clientes': return <UserIcon className="w-5 h-5 text-blue-600" />;
      case 'Documentos Financeiros': return <DocumentTextIcon className="w-5 h-5 text-green-600" />;
      case 'Documentos de Funcionários': return <UsersIcon className="w-5 h-5 text-purple-600" />;
      case 'Documentos de Fornecedores': return <BuildingOfficeIcon className="w-5 h-5 text-orange-600" />;
      case 'Documentos Administrativos': return <DocumentIcon className="w-5 h-5 text-gray-600" />;
      default: return <DocumentTextIcon className="w-5 h-5 text-gray-600" />;
    }
  };

  // Ícones por tipo de arquivo
  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'PDF': return <DocumentIcon className="w-4 h-4 text-red-600" />;
      case 'DOC':
      case 'DOCX': return <DocumentTextIcon className="w-4 h-4 text-blue-600" />;
      case 'XLS':
      case 'XLSX': return <TableCellsIcon className="w-4 h-4 text-green-600" />;
      case 'IMG':
      case 'JPG':
      case 'PNG': return <PhotoIcon className="w-4 h-4 text-yellow-600" />;
      case 'AUDIO':
      case 'MP3': return <SpeakerWaveIcon className="w-4 h-4 text-purple-600" />;
      case 'VIDEO':
      case 'MP4': return <VideoCameraIcon className="w-4 h-4 text-pink-600" />;
      case 'XML': return <CodeBracketIcon className="w-4 h-4 text-gray-600" />;
      default: return <DocumentTextIcon className="w-4 h-4 text-gray-600" />;
    }
  };

  // Ícones por tipo de pessoa vinculada
  const getTipoPessoaIcon = (tipo) => {
    switch (tipo) {
      case 'Cliente': return <UserIcon className="w-3 h-3 text-blue-600" />;
      case 'Advogado': return <UsersIcon className="w-3 h-3 text-purple-600" />;
      case 'Fornecedor': return <BuildingOfficeIcon className="w-3 h-3 text-orange-600" />;
      default: return null;
    }
  };

  const getPrivacidadeColor = (privacidade) => {
    switch (privacidade) {
      case 'Público': return 'bg-green-100 text-green-800';
      case 'Privado': return 'bg-red-100 text-red-800';
      case 'Restrito': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  // Ações rápidas
  const quickActions = [
    { title: 'Upload por Categoria', icon: '📁', color: 'blue' },
    { title: 'Clientes', icon: '👥', color: 'blue', count: clientes.length },
    { title: 'Financeiros', icon: '💰', color: 'green', count: financeiros.length },
    { title: 'Funcionários', icon: '👨‍💼', color: 'purple', count: funcionarios.length },
    { title: 'Fornecedores', icon: '🏢', color: 'orange', count: fornecedores.length },
    { title: 'Administrativos', icon: '📋', color: 'gray', count: administrativos.length }
  ];

  // Categorias e tipos únicos para filtros
  const categorias = [...new Set(documentos.map(d => d.categoria))];
  const tipos = [...new Set(documentos.map(d => d.tipo))];
  const tiposPessoa = [...new Set(documentos.map(d => d.vinculadoTipo).filter(Boolean))];

  if (loading) {
    return (
      <div className="space-y-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100 p-6 animate-pulse">
              <div className="h-12 bg-gray-200 rounded mb-4"></div>
              <div className="h-6 bg-gray-200 rounded mb-2"></div>
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Sistema GED</h1>
        <p className="mt-2 text-lg text-gray-600">
          Gestão Eletrônica de Documentos - Organize todos os documentos do escritório
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((item) => (
          <div key={item.name} className="bg-white overflow-hidden shadow-erlene rounded-xl border border-gray-100">
            <div className="p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className={`p-3 rounded-lg bg-${item.color}-100`}>
                    <item.icon className={`h-6 w-6 text-${item.color}-600`} />
                  </div>
                </div>
                <div className={`flex items-center text-sm font-semibold ${
                  item.changeType === 'increase' ? 'text-green-600' : 
                  item.changeType === 'decrease' ? 'text-red-600' : 'text-gray-600'
                }`}>
                  {item.changeType === 'increase' && <ArrowUpIcon className="h-4 w-4 mr-1" />}
                  {item.changeType === 'decrease' && <ArrowDownIcon className="h-4 w-4 mr-1" />}
                  {item.change}
                </div>
              </div>
              <div className="mt-4">
                <h3 className="text-sm font-medium text-gray-500">{item.name}</h3>
                <p className="text-3xl font-bold text-gray-900 mt-1">{item.value}</p>
                <p className="text-sm text-gray-500 mt-1">{item.description}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Ações Rápidas */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Upload por Categoria</h2>
          <FolderIcon className="h-5 w-5 text-gray-400" />
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
          {quickActions.map((action, index) => (
            <div
              key={action.title}
              className="group flex flex-col items-center p-4 border-2 border-dashed border-gray-300 rounded-xl hover:border-primary-500 hover:bg-primary-50 transition-all duration-200 cursor-pointer"
              onClick={() => action.href && (window.location.href = action.href)}
            >
              <span className="text-2xl mb-2 group-hover:scale-110 transition-transform duration-200">
                {action.icon}
              </span>
              <span className="text-xs font-medium text-gray-900 group-hover:text-primary-700 text-center">
                {action.title}
              </span>
              {action.count !== undefined && (
                <span className="text-xs text-gray-500 mt-1">{action.count} docs</span>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Filtros Rápidos */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <div className="lg:col-span-3">
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Documentos</h2>
              <Link
                to="/admin/documentos/novo"
                className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <PlusIcon className="w-5 h-5 mr-2" />
                Upload Documento
              </Link>
            </div>
            
            <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-6">
              {/* Busca */}
              <div className="relative flex-1">
                <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  placeholder="Buscar nome, tags, pessoa..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>
              
              {/* Filtros */}
              <select
                value={filterCategoria}
                onChange={(e) => setFilterCategoria(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="all">Todas as categorias</option>
                {categorias.map((categoria) => (
                  <option key={categoria} value={categoria}>{categoria}</option>
                ))}
              </select>
              
              <select
                value={filterTipo}
                onChange={(e) => setFilterTipo(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="all">Todos os tipos</option>
                {tipos.map((tipo) => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
              
              <select
                value={filterPessoa}
                onChange={(e) => setFilterPessoa(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="all">Todas as pessoas</option>
                {tiposPessoa.map((tipo) => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
            </div>

            {/* Tabela de Documentos */}
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Documento
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Categoria/Pessoa
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Tamanho/Tipo
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Upload/Por
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Ações
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredDocumentos.map((documento) => (
                    <tr key={documento.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="w-10 h-10 rounded-lg bg-gray-100 flex items-center justify-center">
                            {getTipoIcon(documento.tipo)}
                          </div>
                          <div className="ml-4">
                            <div className="text-sm font-medium text-gray-900">
                              {documento.nome}
                            </div>
                            <div className="text-sm text-gray-500">
                              {documento.subcategoria}
                            </div>
                            {documento.tags.length > 0 && (
                              <div className="flex flex-wrap gap-1 mt-1">
                                {documento.tags.slice(0, 2).map((tag, index) => (
                                  <span key={index} className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800">
                                    {tag}
                                  </span>
                                ))}
                                {documento.tags.length > 2 && (
                                  <span className="text-xs text-gray-500">+{documento.tags.length - 2}</span>
                                )}
                              </div>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          {getCategoriaIcon(documento.categoria)}
                          <div className="ml-2">
                            <div className="text-sm text-gray-900">{documento.categoria.replace('Documentos de ', '')}</div>
                            {documento.vinculadoNome && (
                              <div className="text-sm text-gray-500 flex items-center">
                                {getTipoPessoaIcon(documento.vinculadoTipo)}
                                <span className="ml-1">{documento.vinculadoNome}</span>
                              </div>
                            )}
                            {documento.processoNumero && (
                              <div className="text-xs text-blue-600">{documento.processoNumero}</div>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{documento.tamanho}</div>
                        <div className="text-sm text-gray-500">{documento.tipo}</div>
                        {documento.versao > 1 && (
                          <div className="text-xs text-purple-600">v{documento.versao}</div>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{formatDate(documento.dataUpload)}</div>
                        <div className="text-sm text-gray-500">{documento.uploadPor}</div>
                        <div className="text-xs text-gray-400">{documento.totalDownloads} downloads</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex items-center px-2 py-1 text-xs font-semibold rounded-full ${getPrivacidadeColor(documento.privacidade)}`}>
                          {documento.privacidade}
                        </span>
                        {documento.dataExpiracao && (
                          <div className="text-xs text-orange-600 mt-1">
                            Exp: {formatDate(documento.dataExpiracao)}
                          </div>
                        )}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex justify-end space-x-2">
                          <button 
                            onClick={() => handlePreview(documento)}
                            className="text-blue-600 hover:text-blue-900"
                            title="Preview"
                          >
                            <EyeIcon className="w-5 h-5" />
                          </button>
                          <button
                            onClick={() => handleDownload(documento)}
                            className="text-green-600 hover:text-green-900"
                            title="Download"
                          >
                            <ArrowDownTrayIcon className="w-5 h-5" />
                          </button>
                          <Link
                            to={`/admin/documentos/${documento.id}/editar`}
                            className="text-primary-600 hover:text-primary-900"
                            title="Editar"
                          >
                            <PencilIcon className="w-5 h-5" />
                          </Link>
                          <button
                            onClick={() => handleDelete(documento.id)}
                            className="text-red-600 hover:text-red-900"
                            title="Excluir"
                          >
                            <TrashIcon className="w-5 h-5" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            
            {/* Estado vazio */}
            {filteredDocumentos.length === 0 && (
              <div className="text-center py-12">
                <DocumentTextIcon className="mx-auto h-12 w-12 text-gray-400" />
                <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum documento encontrado</h3>
                <p className="mt-1 text-sm text-gray-500">
                  {searchTerm || filterCategoria !== 'all' || filterTipo !== 'all' || filterPessoa !== 'all'
                    ? 'Tente ajustar os filtros de busca.'
                    : 'Comece fazendo upload de um documento.'}
                </p>
                <div className="mt-6">
                  <Link
                    to="/admin/documentos/novo"
                    className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
                  >
                    <PlusIcon className="w-5 h-5 mr-2" />
                    Upload Documento
                  </Link>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Filtros Laterais */}
        <div>
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Filtros Rápidos</h2>
              <ClockIcon className="h-5 w-5 text-gray-400" />
            </div>
            <div className="space-y-4">
              <button 
                onClick={() => setFilterCategoria('Documentos de Clientes')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterCategoria === 'Documentos de Clientes' ? 'bg-blue-50 border border-blue-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Clientes</span>
                  <span className="text-blue-600 font-semibold">{clientes.length}</span>
                </div>
              </button>
              <button 
                onClick={() => setFilterCategoria('Documentos Financeiros')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterCategoria === 'Documentos Financeiros' ? 'bg-green-50 border border-green-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Financeiros</span>
                  <span className="text-green-600 font-semibold">{financeiros.length}</span>
                </div>
              </button>
              <button 
                onClick={() => setFilterCategoria('Documentos de Funcionários')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterCategoria === 'Documentos de Funcionários' ? 'bg-purple-50 border border-purple-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Funcionários</span>
                  <span className="text-purple-600 font-semibold">{funcionarios.length}</span>
                </div>
              </button>
              <button 
                onClick={() => setFilterCategoria('Documentos de Fornecedores')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterCategoria === 'Documentos de Fornecedores' ? 'bg-orange-50 border border-orange-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Fornecedores</span>
                  <span className="text-orange-600 font-semibold">{fornecedores.length}</span>
                </div>
              </button>
              <button 
                onClick={() => setFilterCategoria('Documentos Administrativos')}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterCategoria === 'Documentos Administrativos' ? 'bg-gray-50 border border-gray-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Administrativos</span>
                  <span className="text-gray-600 font-semibold">{administrativos.length}</span>
                </div>
              </button>
              <button 
                onClick={() => { setFilterCategoria('all'); setFilterTipo('all'); setFilterPessoa('all'); }}
                className={`w-full text-left p-3 rounded-lg transition-colors ${
                  filterCategoria === 'all' && filterTipo === 'all' && filterPessoa === 'all' ? 'bg-primary-50 border border-primary-200' : 'hover:bg-gray-50'
                }`}
              >
                <div className="flex justify-between items-center">
                  <span className="font-medium text-gray-900">Todos</span>
                  <span className="text-gray-600 font-semibold">{documentos.length}</span>
                </div>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Documentos;
