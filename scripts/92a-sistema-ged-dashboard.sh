#!/bin/bash

# Script 92a - Sistema GED Completo Dashboard (Parte 1/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📋 Criando Sistema GED Completo Dashboard (Parte 1/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 1. Criando estrutura para documentos GED..."

# Criar estrutura se não existir
mkdir -p frontend/src/components/documentos
mkdir -p frontend/src/pages/admin

echo "📝 2. Criando página principal de Documentos seguindo padrão Erlene..."

# Criar página de Documentos seguindo EXATO padrão dos módulos anteriores
cat > frontend/src/pages/admin/Documentos.js << 'EOF'
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
EOF

echo "✅ Primeira parte da página Documentos.js criada (até 300 linhas)!"

echo ""
echo "📋 PARTE 1/2 CONCLUÍDA:"
echo "   • Header e estrutura base seguindo padrão Erlene"
echo "   • Mock data GED completo com 15 documentos em 5 categorias"
echo "   • Categorias: Clientes, Financeiros, Funcionários, Fornecedores, Administrativos"
echo "   • Cards de estatísticas GED em tempo real"
echo "   • Estrutura escalável e relacionamentos opcionais"
echo ""
echo "📂 CATEGORIAS IMPLEMENTADAS:"
echo "   👥 Documentos de Clientes (3): Contratos, Pessoais, Processuais"
echo "   💰 Documentos Financeiros (3): Notas Fiscais, Boletos, Comprovantes"
echo "   👨‍💼 Documentos de Funcionários (3): OAB, Currículos, Contratos"
echo "   🏢 Documentos de Fornecedores (3): Manuais, Contratos, Certificados"
echo "   📋 Documentos Administrativos (3): Internos, Imobiliários, Seguros"
echo ""
echo "🔗 RELACIONAMENTOS OPCIONAIS:"
echo "   • vinculadoTipo: Cliente, Advogado, Fornecedor ou vazio"
echo "   • processoId: Opcional para vincular a processos específicos"
echo "   • Tags, observações e metadados completos"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • Filtros avançados por categoria, tipo, pessoa, período"
echo "   • Lista/tabela com preview e ações CRUD"
echo "   • Estados de loading e vazio"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"