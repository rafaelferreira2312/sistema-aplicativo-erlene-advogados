#!/bin/bash

# Script 92c - Upload Multi-Categoria GED (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📋 Criando Upload Multi-Categoria GED (Parte 1/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 1. Criando NewDocumento.js seguindo padrão dos módulos..."

# Criar NewDocumento.js seguindo EXATO padrão NewAudiencia/NewPrazo/NewTransacao
cat > frontend/src/components/documentos/NewDocumento.js << 'EOF'
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
EOF

echo "✅ NewDocumento.js - PARTE 1 criada (até linha 300)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • Estrutura base e imports seguindo padrão NewAudiencia/NewPrazo"
echo "   • Mock data expandido com clientes, advogados, fornecedores"
echo "   • Auto-classificação inteligente baseada no nome do arquivo"
echo "   • FormData com relacionamentos OPCIONAIS"
echo "   • Drag-and-drop com validações de tipo e tamanho"
echo "   • Sistema de tags dinâmico"
echo "   • Preview para imagens"
echo "   • 5 categorias completas com subcategorias"
echo ""
echo "🤖 AUTO-CLASSIFICAÇÃO IMPLEMENTADA:"
echo "   • Contratos de honorários → Clientes/Contratos"
echo "   • RG, CPF → Clientes/Documentos Pessoais"
echo "   • Petições → Clientes/Documentos Processuais"
echo "   • Notas fiscais → Financeiros/Notas Fiscais"
echo "   • Boletos → Financeiros/Boletos"
echo "   • OAB → Funcionários/Carteira OAB"
echo "   • Manuais → Fornecedores/Manuais"
echo "   • Regulamentos → Administrativos/Documentos Internos"
echo ""
echo "📁 VALIDAÇÕES DE ARQUIVO:"
echo "   • Tipos: PDF, DOC, XLS, IMG, AUDIO, VIDEO, XML"
echo "   • Tamanho máximo: 50MB"
echo "   • Preview automático para imagens"
echo "   • Ícones específicos por tipo de arquivo"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Formulários HTML completos"
echo "   • Seções organizadas (Arquivo, Classificação, Relacionamentos)"
echo "   • Sistema de tags, configurações e botões"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"