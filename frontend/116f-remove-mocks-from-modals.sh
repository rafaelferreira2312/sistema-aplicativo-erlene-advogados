#!/bin/bash

# Script 116f - Remover Dados Mockados dos Modais
# Sistema Erlene Advogados - Integrar modais com dados reais do backend
# Execução: chmod +x 116f-remove-mocks-from-modals.sh && ./116f-remove-mocks-from-modals.sh
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 116f - Removendo dados mockados dos modais de processos..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 116f-remove-mocks-from-modals.sh && ./116f-remove-mocks-from-modals.sh"
    exit 1
fi

echo "1️⃣ Verificando estrutura anterior..."

# Verificar se ProcessDetails.js existe
if [ ! -f "src/components/processes/ProcessDetails.js" ]; then
    echo "❌ Erro: ProcessDetails.js não encontrado. Execute script 116e primeiro"
    exit 1
fi

echo "2️⃣ Fazendo backup dos modais originais..."

# Backup dos modais existentes
if [ -f "src/components/processes/ProcessClientModal.js" ]; then
    cp src/components/processes/ProcessClientModal.js src/components/processes/ProcessClientModal.js.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup ProcessClientModal.js criado"
fi

if [ -f "src/components/processes/ProcessDocumentsModal.js" ]; then
    cp src/components/processes/ProcessDocumentsModal.js src/components/processes/ProcessDocumentsModal.js.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup ProcessDocumentsModal.js criado"
fi

echo "3️⃣ Atualizando ProcessClientModal.js com dados reais..."

cat > src/components/processes/ProcessClientModal.js << 'EOF'
import React from 'react';
import {
  XMarkIcon,
  UserCircleIcon,
  EnvelopeIcon,
  PhoneIcon,
  MapPinIcon
} from '@heroicons/react/24/outline';

const ProcessClientModal = ({ isOpen, onClose, process }) => {
  if (!isOpen || !process || !process.cliente) return null;

  const client = process.cliente;

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-10 mx-auto p-0 border w-4/5 max-w-2xl shadow-lg rounded-xl bg-white">
        {/* Header */}
        <div className="bg-primary-600 text-white px-6 py-4 rounded-t-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <UserCircleIcon className="w-8 h-8" />
              <div>
                <h3 className="text-xl font-semibold">{client.nome}</h3>
                <span className="text-primary-100 text-sm">{client.cpf_cnpj}</span>
              </div>
            </div>
            <button onClick={onClose} className="text-white hover:text-primary-200">
              <XMarkIcon className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          <div className="space-y-4">
            {client.email && (
              <div className="flex items-center space-x-3">
                <EnvelopeIcon className="w-5 h-5 text-gray-400" />
                <div>
                  <div className="text-sm font-medium text-gray-900">E-mail</div>
                  <div className="text-sm text-gray-600">{client.email}</div>
                </div>
              </div>
            )}

            {client.telefone && (
              <div className="flex items-center space-x-3">
                <PhoneIcon className="w-5 h-5 text-gray-400" />
                <div>
                  <div className="text-sm font-medium text-gray-900">Telefone</div>
                  <div className="text-sm text-gray-600">{client.telefone}</div>
                </div>
              </div>
            )}

            {client.endereco && (
              <div className="flex items-start space-x-3">
                <MapPinIcon className="w-5 h-5 text-gray-400 mt-0.5" />
                <div>
                  <div className="text-sm font-medium text-gray-900">Endereço</div>
                  <div className="text-sm text-gray-600">{client.endereco}</div>
                </div>
              </div>
            )}

            <div className="flex items-center space-x-3">
              <UserCircleIcon className="w-5 h-5 text-gray-400" />
              <div>
                <div className="text-sm font-medium text-gray-900">Tipo</div>
                <div className="text-sm text-gray-600">
                  {client.tipo_pessoa === 'PF' ? 'Pessoa Física' : 'Pessoa Jurídica'}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 rounded-b-xl">
          <div className="flex justify-between items-center">
            <div className="text-sm text-gray-600">
              Cliente vinculado ao processo: <span className="font-medium">{process.numero}</span>
            </div>
            <button onClick={onClose} className="px-4 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400">
              Fechar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProcessClientModal;
EOF

echo "4️⃣ Atualizando ProcessDocumentsModal.js com dados reais..."

cat > src/components/processes/ProcessDocumentsModal.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { processesService } from '../../services/processesService';
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
  const [error, setError] = useState(null);

  useEffect(() => {
    if (isOpen && processId) {
      loadDocuments();
    }
  }, [isOpen, processId]);

  const loadDocuments = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await processesService.getDocuments(processId);
      
      if (response.success) {
        setDocuments(response.data.data || []);
      } else {
        setError('Erro ao carregar documentos');
      }
    } catch (err) {
      console.error('Erro ao carregar documentos:', err);
      setError('Erro de conexão ao carregar documentos');
    } finally {
      setLoading(false);
    }
  };

  const getFileIcon = (mimeType) => {
    if (!mimeType) return '📄';
    
    if (mimeType.includes('pdf')) return '📕';
    if (mimeType.includes('word') || mimeType.includes('document')) return '📘';
    if (mimeType.includes('excel') || mimeType.includes('spreadsheet')) return '📗';
    if (mimeType.includes('image')) return '🖼️';
    
    return '📄';
  };

  const formatFileSize = (bytes) => {
    if (!bytes) return 'N/A';
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('pt-BR');
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
          ) : error ? (
            <div className="text-center py-8">
              <DocumentIcon className="mx-auto h-12 w-12 text-red-400" />
              <h3 className="mt-2 text-sm font-medium text-red-900">{error}</h3>
              <button 
                onClick={loadDocuments}
                className="mt-2 text-sm text-red-600 hover:text-red-800 underline"
              >
                Tentar novamente
              </button>
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
                      <div className="text-2xl">{getFileIcon(doc.mime_type)}</div>
                      <div>
                        <div className="text-sm font-medium text-gray-900">{doc.nome || doc.name}</div>
                        <div className="text-xs text-gray-500">
                          {doc.categoria || 'Documento'} • {formatFileSize(doc.tamanho || doc.size)} • {formatDate(doc.created_at)}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <button 
                        className="p-2 text-blue-600 hover:text-blue-800 rounded-lg" 
                        title="Visualizar"
                        onClick={() => window.open(doc.url || doc.caminho, '_blank')}
                      >
                        <EyeIcon className="w-4 h-4" />
                      </button>
                      <button 
                        className="p-2 text-green-600 hover:text-green-800 rounded-lg" 
                        title="Download"
                        onClick={() => {
                          const link = document.createElement('a');
                          link.href = doc.download_url || doc.url || doc.caminho;
                          link.download = doc.nome || doc.name;
                          document.body.appendChild(link);
                          link.click();
                          document.body.removeChild(link);
                        }}
                      >
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
EOF

echo "5️⃣ Verificando se arquivos foram atualizados corretamente..."

if [ -f "src/components/processes/ProcessClientModal.js" ]; then
    echo "✅ ProcessClientModal.js atualizado com dados reais"
    echo "📊 Linhas do arquivo: $(wc -l < src/components/processes/ProcessClientModal.js)"
else
    echo "❌ Erro ao atualizar ProcessClientModal.js"
    exit 1
fi

if [ -f "src/components/processes/ProcessDocumentsModal.js" ]; then
    echo "✅ ProcessDocumentsModal.js atualizado com dados reais"
    echo "📊 Linhas do arquivo: $(wc -l < src/components/processes/ProcessDocumentsModal.js)"
else
    echo "❌ Erro ao atualizar ProcessDocumentsModal.js"
    exit 1
fi

echo ""
echo "📋 Modais Integrados com Backend:"
echo "   • ProcessClientModal.js - Usa dados reais de process.cliente"
echo "   • ProcessDocumentsModal.js - Usa processesService.getDocuments()"
echo ""
echo "❌ Removido dos Modais:"
echo "   • Dados mockados hardcoded"
echo "   • Simulação de loading fake"
echo "   • Arrays estáticos de dados"
echo ""
echo "✅ Adicionado aos Modais:"
echo "   • Integração com processesService"
echo "   • Estados de loading e error reais"
echo "   • Tratamento de erros de conexão"
echo "   • Funcionalidades de download/preview"
echo ""
echo "✅ Script 116f concluído!"
echo "⭐ Próximo: Script para atualizar EditProcess.js com dados reais"
echo ""
echo "Digite 'continuar' para integrar EditProcess.js com backend"