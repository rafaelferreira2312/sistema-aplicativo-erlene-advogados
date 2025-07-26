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
  ArrowUpIcon,
  ArrowDownIcon,
  ClockIcon
} from '@heroicons/react/24/outline';

const Documentos = () => {
  const [documentos, setDocumentos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterCategoria, setFilterCategoria] = useState('all');
  const [filterTipo, setFilterTipo] = useState('all');
  const [filterPessoa, setFilterPessoa] = useState('all');

  // Mock data REDUZIDO - apenas 4 documentos para funcionar
  const mockDocumentos = [
    {
      id: 1,
      nome: 'Contrato_Honorarios_Joao.pdf',
      categoria: 'Documentos de Clientes',
      subcategoria: 'Contratos',
      tipo: 'PDF',
      vinculadoTipo: 'Cliente',
      vinculadoNome: 'João Silva Santos',
      tamanho: '2.5 MB',
      extensao: 'pdf',
      tags: ['contrato', 'honorários'],
      dataUpload: '2024-07-25',
      uploadPor: 'Dr. Carlos Oliveira',
      status: 'Ativo',
      privacidade: 'Privado',
      totalDownloads: 3
    },
    {
      id: 2,
      nome: 'RG_Maria_Oliveira.jpg',
      categoria: 'Documentos de Clientes',
      subcategoria: 'Documentos Pessoais',
      tipo: 'IMG',
      vinculadoTipo: 'Cliente',
      vinculadoNome: 'Maria Oliveira Costa',
      tamanho: '1.2 MB',
      extensao: 'jpg',
      tags: ['rg', 'identidade'],
      dataUpload: '2024-07-20',
      uploadPor: 'Dra. Maria Santos',
      status: 'Ativo',
      privacidade: 'Privado',
      totalDownloads: 1
    },
    {
      id: 3,
      nome: 'Nota_Fiscal_Papelaria.pdf',
      categoria: 'Documentos Financeiros',
      subcategoria: 'Notas Fiscais',
      tipo: 'PDF',
      vinculadoTipo: 'Fornecedor',
      vinculadoNome: 'Papelaria Central',
      tamanho: '0.8 MB',
      extensao: 'pdf',
      tags: ['nota fiscal', 'material'],
      dataUpload: '2024-07-23',
      uploadPor: 'Administrativo',
      status: 'Ativo',
      privacidade: 'Público',
      totalDownloads: 2
    },
    {
      id: 4,
      nome: 'OAB_Carlos_Oliveira.pdf',
      categoria: 'Documentos de Funcionários',
      subcategoria: 'Carteira OAB',
      tipo: 'PDF',
      vinculadoTipo: 'Advogado',
      vinculadoNome: 'Dr. Carlos Oliveira',
      tamanho: '1.1 MB',
      extensao: 'pdf',
      tags: ['oab', 'carteira'],
      dataUpload: '2024-07-15',
      uploadPor: 'Dr. Carlos Oliveira',
      status: 'Ativo',
      privacidade: 'Público',
      totalDownloads: 5
    }
  ];

  useEffect(() => {
    setTimeout(() => {
      setDocumentos(mockDocumentos);
      setLoading(false);
    }, 1000);
  }, []);

  // Calcular estatísticas
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
      change: '+2',
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
      change: '60%',
      changeType: 'neutral',
      icon: FolderIcon,
      color: 'yellow',
      description: 'de 10 MB teste'
    },
    {
      name: 'Funcionando',
      value: '100%',
      change: '✓',
      changeType: 'increase',
      icon: ArrowUpIcon,
      color: 'purple',
      description: 'sistema ativo'
    }
  ];

  // Filtrar documentos
  const filteredDocumentos = documentos.filter(documento => {
    const matchesSearch = documento.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         documento.tags.some(tag => tag.toLowerCase().includes(searchTerm.toLowerCase())) ||
                         (documento.vinculadoNome && documento.vinculadoNome.toLowerCase().includes(searchTerm.toLowerCase()));
    
    const matchesCategoria = filterCategoria === 'all' || documento.categoria === filterCategoria;
    const matchesTipo = filterTipo === 'all' || documento.tipo === filterTipo;
    const matchesPessoa = filterPessoa === 'all' || documento.vinculadoTipo === filterPessoa;
    
    return matchesSearch && matchesCategoria && matchesTipo && matchesPessoa;
  });

  const handleDelete = (id) => {
    if (window.confirm('Tem certeza que deseja excluir este documento?')) {
      setDocumentos(prev => prev.filter(doc => doc.id !== id));
    }
  };

  const handleDownload = (documento) => {
    alert(`Download iniciado: ${documento.nome}`);
    setDocumentos(prev => prev.map(doc => 
      doc.id === documento.id ? { ...doc, totalDownloads: doc.totalDownloads + 1 } : doc
    ));
  };

  const handlePreview = (documento) => {
    alert(`Preview: ${documento.nome}\nTipo: ${documento.tipo}\nTamanho: ${documento.tamanho}`);
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
      case 'IMG': return <PhotoIcon className="w-4 h-4 text-yellow-600" />;
      default: return <DocumentTextIcon className="w-4 h-4 text-gray-600" />;
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

      {/* Filtros e Lista */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Lista de Documentos</h2>
          <Link
            to="/admin/documentos/novo"
            className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <PlusIcon className="w-5 h-5 mr-2" />
            Novo Documento
          </Link>
        </div>
        
        <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-6">
          {/* Busca */}
          <div className="relative flex-1">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar documento..."
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
                  Categoria
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo/Tamanho
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Upload
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
                      <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                        {getTipoIcon(documento.tipo)}
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{documento.nome}</div>
                        <div className="text-sm text-gray-500">{documento.subcategoria}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      {getCategoriaIcon(documento.categoria)}
                      <div className="ml-2">
                        <div className="text-sm text-gray-900">{documento.categoria.replace('Documentos de ', '')}</div>
                        {documento.vinculadoNome && (
                          <div className="text-sm text-gray-500">{documento.vinculadoNome}</div>
                        )}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{documento.tipo}</div>
                    <div className="text-sm text-gray-500">{documento.tamanho}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPrivacidadeColor(documento.privacidade)}`}>
                      {documento.privacidade}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{formatDate(documento.dataUpload)}</div>
                    <div className="text-sm text-gray-500">{documento.uploadPor}</div>
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
              {searchTerm || filterCategoria !== 'all' || filterTipo !== 'all'
                ? 'Tente ajustar os filtros de busca.'
                : 'Comece fazendo upload de um documento.'}
            </p>
            <div className="mt-6">
              <Link
                to="/admin/documentos/novo"
                className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <PlusIcon className="w-5 h-5 mr-2" />
                Novo Documento
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Documentos;
