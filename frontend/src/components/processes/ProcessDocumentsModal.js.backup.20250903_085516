import React, { useState, useEffect } from 'react';
import {
  XMarkIcon,
  DocumentIcon,
  EyeIcon,
  ArrowDownTrayIcon,
  FolderIcon
} from '@heroicons/react/24/outline';

const ProcessDocumentsModal = ({ isOpen, onClose, processId, processNumber }) => {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);

  // Mock data dos documentos
  const mockDocuments = {
    1: [
      { id: 1, name: 'Petição Inicial.pdf', category: 'Petições', size: '2.5 MB', date: '2024-01-15', type: 'pdf' },
      { id: 2, name: 'Comprovante Residência.pdf', category: 'Documentos', size: '1.2 MB', date: '2024-01-16', type: 'pdf' },
      { id: 3, name: 'Contrato Social.pdf', category: 'Documentos', size: '3.8 MB', date: '2024-01-20', type: 'pdf' }
    ],
    2: [
      { id: 4, name: 'CTPS Digital.pdf', category: 'Documentos', size: '1.5 MB', date: '2024-01-20', type: 'pdf' },
      { id: 5, name: 'Reclamatória Trabalhista.docx', category: 'Petições', size: '2.2 MB', date: '2024-01-22', type: 'docx' }
    ],
    3: [
      { id: 6, name: 'Certidão Casamento.pdf', category: 'Documentos', size: '1.0 MB', date: '2024-02-01', type: 'pdf' },
      { id: 7, name: 'Petição Divórcio.pdf', category: 'Petições', size: '2.1 MB', date: '2024-02-02', type: 'pdf' }
    ]
  };

  useEffect(() => {
    if (isOpen && processId) {
      setLoading(true);
      setTimeout(() => {
        setDocuments(mockDocuments[processId] || []);
        setLoading(false);
      }, 800);
    }
  }, [isOpen, processId]);

  const getFileIcon = (type) => {
    switch (type) {
      case 'pdf': return '🔴';
      case 'docx': return '🔵';
      default: return '📄';
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-10 mx-auto p-0 border w-4/5 max-w-4xl shadow-lg rounded-xl bg-white">
        {/* Header */}
        <div className="bg-primary-600 text-white px-6 py-4 rounded-t-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <FolderIcon className="w-6 h-6" />
              <div>
                <h3 className="text-lg font-semibold">Documentos do Processo</h3>
                <p className="text-primary-100 text-sm">{processNumber}</p>
              </div>
            </div>
            <button onClick={onClose} className="text-white hover:text-primary-200">
              <XMarkIcon className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {loading ? (
            <div className="flex justify-center items-center py-12">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
              <span className="ml-3 text-gray-600">Carregando documentos...</span>
            </div>
          ) : (
            <div className="space-y-3 max-h-96 overflow-y-auto">
              {documents.length === 0 ? (
                <div className="text-center py-8">
                  <DocumentIcon className="mx-auto h-12 w-12 text-gray-400" />
                  <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum documento encontrado</h3>
                  <p className="mt-1 text-sm text-gray-500">Este processo não possui documentos anexados.</p>
                </div>
              ) : (
                documents.map((doc) => (
                  <div key={doc.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
                    <div className="flex items-center space-x-4">
                      <div className="text-2xl">{getFileIcon(doc.type)}</div>
                      <div>
                        <div className="text-sm font-medium text-gray-900">{doc.name}</div>
                        <div className="text-xs text-gray-500">{doc.category} • {doc.size}</div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <button className="p-2 text-blue-600 hover:text-blue-800 rounded-lg" title="Visualizar">
                        <EyeIcon className="w-4 h-4" />
                      </button>
                      <button className="p-2 text-green-600 hover:text-green-800 rounded-lg" title="Download">
                        <ArrowDownTrayIcon className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 rounded-b-xl">
          <div className="flex justify-between items-center">
            <div className="text-sm text-gray-600">Total: {documents.length} documento(s)</div>
            <button onClick={onClose} className="px-4 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400">
              Fechar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProcessDocumentsModal;
