#!/bin/bash

# Script 92e - Edição e Preview GED (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📋 Criando Edição e Preview GED (Parte 1/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 1. Criando EditDocumento.js seguindo padrão EditAudiencia/EditPrazo..."

# Criar EditDocumento.js - PARTE 1 (imports, state, mock data e funções base)
cat > frontend/src/components/documentos/EditDocumento.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  DocumentTextIcon,
  UserIcon,
  UsersIcon,
  BuildingOfficeIcon,
  ScaleIcon,
  TagIcon,
  CalendarIcon,
  EyeIcon,
  EyeSlashIcon,
  ExclamationTriangleIcon,
  TrashIcon,
  ArrowDownTrayIcon,
  PhotoIcon,
  DocumentIcon,
  SpeakerWaveIcon,
  VideoCameraIcon,
  TableCellsIcon,
  CodeBracketIcon,
  FolderIcon
} from '@heroicons/react/24/outline';

const EditDocumento = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(false);
  const [clients, setClients] = useState([]);
  const [processes, setProcesses] = useState([]);
  const [advogados, setAdvogados] = useState([]);
  const [fornecedores, setFornecedores] = useState([]);
  const [previewMode, setPreviewMode] = useState(false);
  
  const [formData, setFormData] = useState({
    // Dados básicos
    nome: '',
    categoria: '',
    subcategoria: '',
    
    // Relacionamentos (OPCIONAL)
    vinculadoTipo: '',
    vinculadoId: '',
    processoId: '',
    
    // Metadados
    tags: [],
    novaTag: '',
    observacoes: '',
    
    // Configurações
    privacidade: 'Privado',
    dataExpiracao: '',
    
    // Info do arquivo (read-only)
    extensao: '',
    tamanho: '',
    dataUpload: '',
    uploadPor: '',
    versao: 1,
    totalDownloads: 0,
    ultimaVisualizacao: ''
  });

  const [errors, setErrors] = useState({});

  // Mock data
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
    { id: 5, name: 'TI Soluções Ltda', cnpj: '55.555.555/0001-55', tipo: 'Tecnologia' }
  ];

  // Mock data do documento existente baseado no ID
  const getDocumentoMock = (docId) => {
    const documentos = {
      1: {
        id: 1,
        nome: 'Contrato_Honorarios_Joao_Silva.pdf',
        categoria: 'Documentos de Clientes',
        subcategoria: 'Contratos',
        vinculadoTipo: 'Cliente',
        vinculadoId: '1',
        processoId: '1',
        tags: ['contrato', 'honorários', 'assinado'],
        observacoes: 'Contrato assinado pelas duas partes',
        privacidade: 'Privado',
        dataExpiracao: '',
        extensao: 'pdf',
        tamanho: '2.5 MB',
        dataUpload: '2024-07-25',
        uploadPor: 'Dr. Carlos Oliveira',
        versao: 1,
        totalDownloads: 3,
        ultimaVisualizacao: '2024-07-26'
      },
      2: {
        id: 2,
        nome: 'RG_Maria_Oliveira.jpg',
        categoria: 'Documentos de Clientes',
        subcategoria: 'Documentos Pessoais',
        vinculadoTipo: 'Cliente',
        vinculadoId: '3',
        processoId: '',
        tags: ['rg', 'identidade', 'documentos'],
        observacoes: 'RG digitalizado em alta qualidade',
        privacidade: 'Privado',
        dataExpiracao: '',
        extensao: 'jpg',
        tamanho: '1.2 MB',
        dataUpload: '2024-07-20',
        uploadPor: 'Dra. Maria Santos',
        versao: 1,
        totalDownloads: 1,
        ultimaVisualizacao: '2024-07-25'
      },
      7: {
        id: 7,
        nome: 'OAB_Carlos_Oliveira.pdf',
        categoria: 'Documentos de Funcionários',
        subcategoria: 'Carteira OAB',
        vinculadoTipo: 'Advogado',
        vinculadoId: '1',
        processoId: '',
        tags: ['oab', 'carteira', 'advogado'],
        observacoes: 'Carteira OAB/SP atualizada',
        privacidade: 'Público',
        dataExpiracao: '2025-12-31',
        extensao: 'pdf',
        tamanho: '1.1 MB',
        dataUpload: '2024-07-15',
        uploadPor: 'Dr. Carlos Oliveira',
        versao: 2,
        totalDownloads: 5,
        ultimaVisualizacao: '2024-07-20'
      },
      10: {
        id: 10,
        nome: 'Manual_Sistema_Juridico.pdf',
        categoria: 'Documentos de Fornecedores',
        subcategoria: 'Manuais',
        vinculadoTipo: 'Fornecedor',
        vinculadoId: '5',
        processoId: '',
        tags: ['manual', 'sistema', 'software'],
        observacoes: 'Manual do sistema jurídico v2.0',
        privacidade: 'Público',
        dataExpiracao: '',
        extensao: 'pdf',
        tamanho: '12.5 MB',
        dataUpload: '2024-07-14',
        uploadPor: 'Administrativo',
        versao: 1,
        totalDownloads: 15,
        ultimaVisualizacao: '2024-07-26'
      },
      13: {
        id: 13,
        nome: 'Regulamento_Interno_2024.pdf',
        categoria: 'Documentos Administrativos',
        subcategoria: 'Documentos Internos',
        vinculadoTipo: '',
        vinculadoId: '',
        processoId: '',
        tags: ['regulamento', 'interno', 'escritório'],
        observacoes: 'Regulamento interno atualizado 2024',
        privacidade: 'Público',
        dataExpiracao: '2024-12-31',
        extensao: 'pdf',
        tamanho: '4.2 MB',
        dataUpload: '2024-07-01',
        uploadPor: 'Dra. Erlene Chaves Silva',
        versao: 4,
        totalDownloads: 25,
        ultimaVisualizacao: '2024-07-26'
      }
    };
    
    return documentos[docId] || documentos[1]; // Default para documento 1
  };

  useEffect(() => {
    // Simular carregamento
    setTimeout(() => {
      setClients(mockClients);
      setProcesses(mockProcesses);
      setAdvogados(mockAdvogados);
      setFornecedores(mockFornecedores);
      
      // Carregar dados do documento existente
      const docData = getDocumentoMock(id);
      setFormData(docData);
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
      setErrors(prev => ({ ...prev, [name]: '' }));
    }

    // Limpar relacionamentos quando tipo de pessoa mudar
    if (name === 'vinculadoTipo') {
      setFormData(prev => ({ 
        ...prev, 
        vinculadoId: '', 
        processoId: '' 
      }));
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
      await new Promise(resolve => setTimeout(resolve, 1500));
      alert('Documento atualizado com sucesso!');
      navigate('/admin/documentos');
    } catch (error) {
      alert('Erro ao atualizar documento');
    } finally {
      setLoading(false);
    }
  };

  const handleDownload = () => {
    alert(`Download iniciado: ${formData.nome}`);
    setFormData(prev => ({ 
      ...prev, 
      totalDownloads: prev.totalDownloads + 1,
      ultimaVisualizacao: new Date().toISOString().split('T')[0]
    }));
  };

  const handleDelete = () => {
    if (window.confirm('Tem certeza que deseja excluir este documento? Esta ação não pode ser desfeita.')) {
      alert('Documento excluído com sucesso!');
      navigate('/admin/documentos');
    }
  };

  const handlePreview = () => {
    setPreviewMode(!previewMode);
    setFormData(prev => ({ 
      ...prev, 
      ultimaVisualizacao: new Date().toISOString().split('T')[0]
    }));
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
EOF

echo "✅ EditDocumento.js - PARTE 1 criada (até linha 300)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • Estrutura base e imports seguindo padrão EditAudiencia/EditPrazo"
echo "   • Mock data completo com clientes, advogados, fornecedores"
echo "   • 5 documentos pré-definidos para edição (IDs: 1, 2, 7, 10, 13)"
echo "   • FormData com todos os campos necessários"
echo "   • Funções de manipulação (handleChange, addTag, removeTag)"
echo "   • Validações e funções de ação (download, delete, preview)"
echo "   • Relacionamentos opcionais com pessoas"
echo ""
echo "🔧 DOCUMENTOS DISPONÍVEIS PARA EDIÇÃO:"
echo "   ID 1: Contrato Honorários João Silva (Cliente - PDF)"
echo "   ID 2: RG Maria Oliveira (Cliente - JPG com preview)"
echo "   ID 7: OAB Carlos Oliveira (Advogado - PDF v2)"
echo "   ID 10: Manual Sistema Jurídico (Fornecedor - PDF)"
echo "   ID 13: Regulamento Interno (Administrativo - PDF v4)"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Header do formulário com informações e ações"
echo "   • Formulários HTML completos organizados em seções"
echo "   • Preview por tipo de arquivo"
echo "   • Configurações e botões finais"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"