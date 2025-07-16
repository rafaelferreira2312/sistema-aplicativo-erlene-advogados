#!/bin/bash

# Script 45 - Sistema GED (Parte 2) - Portal Cliente e Preview
# Sistema de Gestão Jurídica - Erlene Advogados
# Execução: ./scripts/45-create-ged-system-part2.sh

echo "📁 Criando sistema GED (Parte 2)..."

# src/pages/portal/Documents/index.js
cat > frontend/src/pages/portal/Documents/index.js << 'EOF'
import React, { useState } from 'react';
import { 
  DocumentIcon,
  EyeIcon,
  ArrowDownTrayIcon,
  MagnifyingGlassIcon,
  FolderIcon
} from '@heroicons/react/24/outline';
import { formatFileSize, getFileIcon, isImageFile, isPDFFile } from '../../../utils/fileHelpers';
import { formatDate } from '../../../utils/formatters';

import Card from '../../../components/common/Card';
import Button from '../../../components/common/Button';
import Input from '../../../components/common/Input';
import Badge from '../../../components/common/Badge';
import Modal from '../../../components/common/Modal';

const PortalDocuments = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedFolder, setSelectedFolder] = useState('');
  const [previewDocument, setPreviewDocument] = useState(null);
  const [showPreviewModal, setShowPreviewModal] = useState(false);

  // Mock data
  const documents = [
    {
      id: 1,
      nome: 'Contrato_Servicos.pdf',
      tamanho: 2048576,
      tipo: 'pdf',
      data_upload: '2024-03-15',
      pasta: 'contratos',
      url: '/documents/preview/1',
      download_url: '/documents/download/1',
      compartilhado_por: 'Dr. João Silva'
    },
    {
      id: 2,
      nome: 'Comprovante_Residencia.jpg',
      tamanho: 1024000,
      tipo: 'image',
      data_upload: '2024-03-14',
      pasta: 'documentos_pessoais',
      url: '/documents/preview/2',
      download_url: '/documents/download/2',
      compartilhado_por: 'Dra. Maria Santos'
    },
    {
      id: 3,
      nome: 'Peticao_Inicial.docx',
      tamanho: 512000,
      tipo: 'document',
      data_upload: '2024-03-13',
      pasta: 'peticoes',
      url: '/documents/preview/3',
      download_url: '/documents/download/3',
      compartilhado_por: 'Dr. João Silva'
    }
  ];

  const folders = [
    { name: '', label: 'Todos os documentos', count: documents.length },
    { name: 'contratos', label: 'Contratos', count: 1 },
    { name: 'documentos_pessoais', label: 'Documentos Pessoais', count: 1 },
    { name: 'peticoes', label: 'Petições', count: 1 }
  ];

  const filteredDocuments = documents.filter(doc => {
    const matchesFolder = !selectedFolder || doc.pasta === selectedFolder;
    const matchesSearch = !searchTerm || doc.nome.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesFolder && matchesSearch;
  });

  const handlePreview = (document) => {
    setPreviewDocument(document);
    setShowPreviewModal(true);
  };

  const handleDownload = (document) => {
    // Simular download
    const link = document.createElement('a');
    link.href = document.download_url;
    link.download = document.nome;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Meus Documentos</h1>
        <p className="mt-1 text-gray-600">
          Acesse todos os documentos compartilhados com você
        </p>
      </div>

      {/* Filters */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <Input
              placeholder="Buscar documentos..."
              icon={MagnifyingGlassIcon}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <div>
            <select 
              className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
              value={selectedFolder}
              onChange={(e) => setSelectedFolder(e.target.value)}
            >
              {folders.map(folder => (
                <option key={folder.name} value={folder.name}>
                  {folder.label} ({folder.count})
                </option>
              ))}
            </select>
          </div>
        </div>
      </Card>

      {/* Documents Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredDocuments.map(doc => (
          <Card key={doc.id} hover className="cursor-pointer">
            <div className="p-6">
              <div className="flex items-start space-x-4">
                <div className="text-3xl">{getFileIcon(doc.nome)}</div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-medium text-gray-900 truncate">
                    {doc.nome}
                  </h3>
                  <p className="text-sm text-gray-500 mt-1">
                    {formatFileSize(doc.tamanho)}
                  </p>
                  <p className="text-xs text-gray-400 mt-1">
                    Enviado em {formatDate(doc.data_upload)}
                  </p>
                  <p className="text-xs text-gray-500 mt-1">
                    Por: {doc.compartilhado_por}
                  </p>
                </div>
              </div>
              
              <div className="flex space-x-2 mt-4">
                <Button 
                  variant="outline" 
                  size="small" 
                  icon={EyeIcon}
                  onClick={() => handlePreview(doc)}
                  className="flex-1"
                >
                  Visualizar
                </Button>
                <Button 
                  variant="outline" 
                  size="small" 
                  icon={ArrowDownTrayIcon}
                  onClick={() => handleDownload(doc)}
                  className="flex-1"
                >
                  Baixar
                </Button>
              </div>
            </div>
          </Card>
        ))}
      </div>

      {filteredDocuments.length === 0 && (
        <Card>
          <div className="text-center py-12">
            <DocumentIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">
              Nenhum documento encontrado
            </h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm 
                ? 'Tente ajustar os termos de busca'
                : 'Ainda não há documentos compartilhados com você'
              }
            </p>
          </div>
        </Card>
      )}

      {/* Preview Modal */}
      <Modal
        isOpen={showPreviewModal}
        onClose={() => setShowPreviewModal(false)}
        title={previewDocument?.nome}
        size="xl"
      >
        {previewDocument && (
          <div className="space-y-4">
            <div className="text-center">
              {isImageFile(previewDocument.nome) ? (
                <img 
                  src={previewDocument.url} 
                  alt={previewDocument.nome}
                  className="max-w-full h-auto rounded-lg"
                />
              ) : isPDFFile(previewDocument.nome) ? (
                <iframe
                  src={previewDocument.url}
                  className="w-full h-96 border rounded-lg"
                  title={previewDocument.nome}
                />
              ) : (
                <div className="flex flex-col items-center py-12">
                  <div className="text-6xl mb-4">{getFileIcon(previewDocument.nome)}</div>
                  <h3 className="text-lg font-medium text-gray-900">
                    {previewDocument.nome}
                  </h3>
                  <p className="text-sm text-gray-500 mt-2">
                    Preview não disponível para este tipo de arquivo
                  </p>
                  <Button 
                    variant="primary" 
                    className="mt-4"
                    onClick={() => handleDownload(previewDocument)}
                  >
                    Baixar para visualizar
                  </Button>
                </div>
              )}
            </div>
            
            <div className="bg-gray-50 rounded-lg p-4">
              <h4 className="font-medium text-gray-900 mb-2">Informações do arquivo</h4>
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span className="text-gray-500">Tamanho:</span>
                  <div>{formatFileSize(previewDocument.tamanho)}</div>
                </div>
                <div>
                  <span className="text-gray-500">Data de upload:</span>
                  <div>{formatDate(previewDocument.data_upload)}</div>
                </div>
                <div>
                  <span className="text-gray-500">Compartilhado por:</span>
                  <div>{previewDocument.compartilhado_por}</div>
                </div>
                <div>
                  <span className="text-gray-500">Pasta:</span>
                  <div>{previewDocument.pasta}</div>
                </div>
              </div>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default PortalDocuments;
EOF

# src/components/documents/DocumentPreview/index.js
cat > frontend/src/components/documents/DocumentPreview/index.js << 'EOF'
import React, { useState } from 'react';
import { 
  XMarkIcon,
  ArrowDownTrayIcon,
  ShareIcon,
  PrinterIcon
} from '@heroicons/react/24/outline';
import { isImageFile, isPDFFile, isVideoFile, isAudioFile, getFileIcon } from '../../../utils/fileHelpers';
import Button from '../../common/Button';

const DocumentPreview = ({ document, onClose, onDownload }) => {
  const [loading, setLoading] = useState(true);

  if (!document) return null;

  const renderPreview = () => {
    if (isImageFile(document.nome)) {
      return (
        <img 
          src={document.url} 
          alt={document.nome}
          className="max-w-full h-auto rounded-lg"
          onLoad={() => setLoading(false)}
          onError={() => setLoading(false)}
        />
      );
    }

    if (isPDFFile(document.nome)) {
      return (
        <iframe
          src={document.url}
          className="w-full h-full min-h-96 border rounded-lg"
          title={document.nome}
          onLoad={() => setLoading(false)}
        />
      );
    }

    if (isVideoFile(document.nome)) {
      return (
        <video 
          controls 
          className="w-full h-auto rounded-lg"
          onLoadedData={() => setLoading(false)}
        >
          <source src={document.url} />
          Seu navegador não suporta o elemento de vídeo.
        </video>
      );
    }

    if (isAudioFile(document.nome)) {
      return (
        <div className="flex flex-col items-center py-8">
          <div className="text-6xl mb-4">🎵</div>
          <audio 
            controls 
            className="w-full max-w-md"
            onLoadedData={() => setLoading(false)}
          >
            <source src={document.url} />
            Seu navegador não suporta o elemento de áudio.
          </audio>
        </div>
      );
    }

    // Arquivo não suportado para preview
    return (
      <div className="flex flex-col items-center py-12">
        <div className="text-6xl mb-4">{getFileIcon(document.nome)}</div>
        <h3 className="text-lg font-medium text-gray-900">
          {document.nome}
        </h3>
        <p className="text-sm text-gray-500 mt-2">
          Preview não disponível para este tipo de arquivo
        </p>
        <Button 
          variant="primary" 
          className="mt-4"
          onClick={() => onDownload && onDownload(document)}
        >
          Baixar para visualizar
        </Button>
      </div>
    );
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-end justify-center px-4 pt-4 pb-20 text-center sm:block sm:p-0">
        {/* Overlay */}
        <div 
          className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
          onClick={onClose}
        />

        {/* Modal */}
        <div className="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
          {/* Header */}
          <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4 border-b border-gray-200">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-medium text-gray-900 truncate">
                {document.nome}
              </h3>
              <div className="flex items-center space-x-2">
                <Button variant="ghost" size="small" icon={ShareIcon}>
                  Compartilhar
                </Button>
                <Button variant="ghost" size="small" icon={PrinterIcon}>
                  Imprimir
                </Button>
                <Button 
                  variant="ghost" 
                  size="small" 
                  icon={ArrowDownTrayIcon}
                  onClick={() => onDownload && onDownload(document)}
                >
                  Baixar
                </Button>
                <Button 
                  variant="ghost" 
                  size="small" 
                  icon={XMarkIcon}
                  onClick={onClose}
                >
                </Button>
              </div>
            </div>
          </div>

          {/* Content */}
          <div className="bg-white px-4 pt-5 pb-4 sm:p-6">
            {loading && (
              <div className="flex justify-center py-12">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
              </div>
            )}
            {renderPreview()}
          </div>
        </div>
      </div>
    </div>
  );
};

export default DocumentPreview;
EOF

# src/hooks/documents/useDocuments.js
cat > frontend/src/hooks/documents/useDocuments.js << 'EOF'
import { useQuery, useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';

// Mock service - substituir por service real
const documentService = {
  getDocuments: async (params) => {
    // Simular API call
    return new Promise(resolve => {
      setTimeout(() => resolve({ data: [], pagination: {} }), 1000);
    });
  },
  
  uploadDocument: async (formData) => {
    // Simular upload
    return new Promise(resolve => {
      setTimeout(() => resolve({ success: true }), 2000);
    });
  },
  
  deleteDocument: async (id) => {
    return new Promise(resolve => {
      setTimeout(() => resolve({ success: true }), 500);
    });
  }
};

// Hook para listar documentos
export const useDocuments = (params = {}) => {
  return useQuery(
    ['documents', params],
    () => documentService.getDocuments(params),
    {
      keepPreviousData: true,
      staleTime: 2 * 60 * 1000, // 2 minutos
    }
  );
};

// Hook para upload de documentos
export const useUploadDocument = () => {
  const queryClient = useQueryClient();

  return useMutation(documentService.uploadDocument, {
    onSuccess: () => {
      queryClient.invalidateQueries(['documents']);
      toast.success('Documento enviado com sucesso!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.message || 'Erro ao enviar documento');
    },
  });
};

// Hook para deletar documento
export const useDeleteDocument = () => {
  const queryClient = useQueryClient();

  return useMutation(documentService.deleteDocument, {
    onSuccess: () => {
      queryClient.invalidateQueries(['documents']);
      toast.success('Documento removido com sucesso!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.message || 'Erro ao remover documento');
    },
  });
};

// Hook para download de documento
export const useDownloadDocument = () => {
  return useMutation(
    async ({ documentId, filename }) => {
      const response = await fetch(`/api/documents/${documentId}/download`);
      
      if (!response.ok) {
        throw new Error('Erro ao baixar documento');
      }
      
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = filename;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
    },
    {
      onSuccess: () => {
        toast.success('Download iniciado!');
      },
      onError: (error) => {
        toast.error('Erro ao baixar documento');
      },
    }
  );
};
EOF

echo "✅ Sistema GED (Parte 2) criado com sucesso!"
echo ""
echo "📊 ARQUIVOS CRIADOS:"
echo "   • Portal Documents - Interface para clientes"
echo "   • DocumentPreview - Componente de preview universal"
echo "   • useDocuments - Hooks para gerenciamento de documentos"
echo ""
echo "📁 RECURSOS INCLUÍDOS:"
echo "   • Portal do cliente simplificado e intuitivo"
echo "   • Preview modal para imagens, PDFs, vídeos e áudios"
echo "   • Sistema de download com link direto"
echo "   • Informações detalhadas dos arquivos"
echo "   • Filtros por pasta e busca"
echo "   • Hooks para upload, download e gerenciamento"
echo "   • Interface responsiva e acessível"
echo ""
echo "⏭️  Sistema GED completo! Próximo: Sistema Kanban!"