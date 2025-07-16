#!/bin/bash

# Script 45 - Sistema GED (Parte 1) - Páginas e Upload
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/45-create-ged-system-part1.sh

echo "📁 Criando sistema GED (Parte 1)..."

# src/pages/admin/Documents/index.js
cat > frontend/src/pages/admin/Documents/index.js << 'EOF'
import React, { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { 
  DocumentIcon,
  CloudArrowUpIcon,
  FolderIcon,
  MagnifyingGlassIcon,
  FunnelIcon
} from '@heroicons/react/24/outline';
import { formatFileSize, getFileIcon } from '../../../utils/fileHelpers';
import { formatDate } from '../../../utils/formatters';

import Card from '../../../components/common/Card';
import Button from '../../../components/common/Button';
import Input from '../../../components/common/Input';
import Badge from '../../../components/common/Badge';
import Loading from '../../../components/common/Loading';

const Documents = () => {
  const [selectedClient, setSelectedClient] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [uploadingFiles, setUploadingFiles] = useState([]);
  const [view, setView] = useState('grid'); // 'grid' or 'list'

  // Mock data - substituir por dados reais da API
  const clients = [
    { id: 1, nome: 'Maria Silva Santos' },
    { id: 2, nome: 'João Carlos Oliveira' },
    { id: 3, nome: 'Empresa ABC Ltda' }
  ];

  const documents = [
    {
      id: 1,
      nome: 'Contrato_Social.pdf',
      cliente_id: 1,
      cliente_nome: 'Maria Silva Santos',
      tamanho: 2048576,
      tipo: 'pdf',
      data_upload: '2024-03-15',
      pasta: 'contratos',
      tags: ['contrato', 'social']
    },
    {
      id: 2,
      nome: 'RG_Frente.jpg',
      cliente_id: 1,
      cliente_nome: 'Maria Silva Santos',
      tamanho: 1024000,
      tipo: 'image',
      data_upload: '2024-03-14',
      pasta: 'documentos_pessoais',
      tags: ['rg', 'documento']
    },
    {
      id: 3,
      nome: 'Peticao_Inicial.docx',
      cliente_id: 2,
      cliente_nome: 'João Carlos Oliveira',
      tamanho: 512000,
      tipo: 'document',
      data_upload: '2024-03-13',
      pasta: 'peticoes',
      tags: ['petição', 'inicial']
    }
  ];

  const folders = [
    { name: 'contratos', count: 5, icon: '📄' },
    { name: 'documentos_pessoais', count: 12, icon: '🆔' },
    { name: 'peticoes', count: 8, icon: '⚖️' },
    { name: 'comprovantes', count: 3, icon: '🧾' }
  ];

  // Upload de arquivos
  const onDrop = useCallback((acceptedFiles) => {
    if (!selectedClient) {
      alert('Selecione um cliente primeiro');
      return;
    }

    setUploadingFiles(prev => [
      ...prev,
      ...acceptedFiles.map(file => ({
        id: Math.random(),
        file,
        progress: 0,
        status: 'uploading'
      }))
    ]);

    // Simular upload
    acceptedFiles.forEach((file, index) => {
      const interval = setInterval(() => {
        setUploadingFiles(prev => prev.map(uploadFile => {
          if (uploadFile.file === file) {
            const newProgress = Math.min(uploadFile.progress + 10, 100);
            return {
              ...uploadFile,
              progress: newProgress,
              status: newProgress === 100 ? 'completed' : 'uploading'
            };
          }
          return uploadFile;
        }));
      }, 200);

      setTimeout(() => {
        clearInterval(interval);
        setUploadingFiles(prev => prev.filter(f => f.file !== file));
      }, 2500);
    });
  }, [selectedClient]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    multiple: true,
    maxSize: 50 * 1024 * 1024 // 50MB
  });

  const filteredDocuments = documents.filter(doc => {
    const matchesClient = !selectedClient || doc.cliente_id.toString() === selectedClient;
    const matchesSearch = !searchTerm || doc.nome.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesClient && matchesSearch;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Documentos (GED)</h1>
          <p className="mt-1 text-gray-600">
            Gestão eletrônica de documentos por cliente
          </p>
        </div>
        <div className="flex space-x-2 mt-4 sm:mt-0">
          <Button 
            variant={view === 'grid' ? 'primary' : 'outline'}
            size="small"
            onClick={() => setView('grid')}
          >
            Grid
          </Button>
          <Button 
            variant={view === 'list' ? 'primary' : 'outline'}
            size="small"
            onClick={() => setView('list')}
          >
            Lista
          </Button>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <select 
              className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
              value={selectedClient}
              onChange={(e) => setSelectedClient(e.target.value)}
            >
              <option value="">Todos os clientes</option>
              {clients.map(client => (
                <option key={client.id} value={client.id}>{client.nome}</option>
              ))}
            </select>
          </div>
          <div>
            <Input
              placeholder="Buscar documentos..."
              icon={MagnifyingGlassIcon}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <div>
            <Button variant="outline" icon={FunnelIcon} className="w-full">
              Mais Filtros
            </Button>
          </div>
        </div>
      </Card>

      {/* Upload Area */}
      <Card title="Upload de Documentos">
        <div
          {...getRootProps()}
          className={`border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors ${
            isDragActive 
              ? 'border-primary-500 bg-primary-50' 
              : 'border-gray-300 hover:border-primary-400'
          }`}
        >
          <input {...getInputProps()} />
          <CloudArrowUpIcon className="mx-auto h-12 w-12 text-gray-400" />
          <div className="mt-4">
            <p className="text-lg font-medium text-gray-900">
              {isDragActive ? 'Solte os arquivos aqui' : 'Arraste arquivos ou clique para selecionar'}
            </p>
            <p className="text-sm text-gray-500 mt-2">
              Suporte para PDF, DOC, XLS, imagens, áudio e vídeo (máx. 50MB)
            </p>
          </div>
        </div>

        {/* Upload Progress */}
        {uploadingFiles.length > 0 && (
          <div className="mt-4 space-y-2">
            {uploadingFiles.map(uploadFile => (
              <div key={uploadFile.id} className="bg-gray-50 rounded-lg p-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">{uploadFile.file.name}</span>
                  <span className="text-sm text-gray-500">{uploadFile.progress}%</span>
                </div>
                <div className="mt-2 bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-primary-600 h-2 rounded-full transition-all"
                    style={{ width: `${uploadFile.progress}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        )}
      </Card>

      {/* Folders */}
      <Card title="Pastas do Cliente">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {folders.map(folder => (
            <div 
              key={folder.name}
              className="flex flex-col items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 cursor-pointer"
            >
              <div className="text-3xl mb-2">{folder.icon}</div>
              <h3 className="font-medium text-gray-900">{folder.name}</h3>
              <p className="text-sm text-gray-500">{folder.count} arquivos</p>
            </div>
          ))}
        </div>
      </Card>

      {/* Documents Grid/List */}
      <Card title={`Documentos (${filteredDocuments.length})`}>
        {view === 'grid' ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filteredDocuments.map(doc => (
              <div key={doc.id} className="border border-gray-200 rounded-lg p-4 hover:bg-gray-50">
                <div className="flex items-start space-x-3">
                  <div className="text-2xl">{getFileIcon(doc.nome)}</div>
                  <div className="flex-1 min-w-0">
                    <h4 className="font-medium text-gray-900 truncate">{doc.nome}</h4>
                    <p className="text-sm text-gray-500">{doc.cliente_nome}</p>
                    <p className="text-xs text-gray-400">
                      {formatFileSize(doc.tamanho)} • {formatDate(doc.data_upload)}
                    </p>
                    <div className="flex flex-wrap gap-1 mt-2">
                      {doc.tags.map(tag => (
                        <Badge key={tag} variant="outline" size="small">{tag}</Badge>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="space-y-2">
            {filteredDocuments.map(doc => (
              <div key={doc.id} className="flex items-center justify-between p-3 border border-gray-200 rounded">
                <div className="flex items-center space-x-3">
                  <div className="text-xl">{getFileIcon(doc.nome)}</div>
                  <div>
                    <h4 className="font-medium text-gray-900">{doc.nome}</h4>
                    <p className="text-sm text-gray-500">{doc.cliente_nome}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-sm text-gray-900">{formatFileSize(doc.tamanho)}</p>
                  <p className="text-xs text-gray-500">{formatDate(doc.data_upload)}</p>
                </div>
              </div>
            ))}
          </div>
        )}

        {filteredDocuments.length === 0 && (
          <div className="text-center py-12">
            <DocumentIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">
              Nenhum documento encontrado
            </h3>
          </div>
        )}
      </Card>
    </div>
  );
};

export default Documents;
EOF

echo "✅ Sistema GED (Parte 1) criado com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • Documents/index.js - Página principal do GED"
echo ""
echo "📁 RECURSOS INCLUÍDOS:"
echo "   • Upload drag-and-drop com react-dropzone"
echo "   • Progresso de upload visual"
echo "   • Visualização grid/lista alternável"
echo "   • Filtros por cliente e busca"
echo "   • Sistema de pastas organizado"
echo "   • Preview de arquivos com ícones"
echo "   • Tags e metadados dos documentos"
echo ""
echo "⏭️  Aguardando comando para continuar com Parte 2!"