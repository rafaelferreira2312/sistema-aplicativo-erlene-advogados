#!/bin/bash

# Script 99j - Criar Componentes Modais em Falta
# Autor: Sistema Erlene Advogados  
# Data: $(date +%Y-%m-%d)
# Enumeração: 99j

echo "🔧 Criando componentes modais em falta (Script 99j)..."

# Verificar diretório
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📁 1. Criando estrutura de pastas..."

# Criar estrutura se não existir
mkdir -p frontend/src/components/processes

echo "📝 2. Criando ProcessDocumentsModal.js..."

# Criar ProcessDocumentsModal.js
cat > frontend/src/components/processes/ProcessDocumentsModal.js << 'EOF'
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
EOF

echo "📝 3. Criando ProcessClientModal.js..."

# Criar ProcessClientModal.js
cat > frontend/src/components/processes/ProcessClientModal.js << 'EOF'
import React from 'react';
import {
  XMarkIcon,
  UserCircleIcon,
  EnvelopeIcon,
  PhoneIcon,
  MapPinIcon
} from '@heroicons/react/24/outline';

const ProcessClientModal = ({ isOpen, onClose, process }) => {
  if (!isOpen || !process) return null;

  // Mock data do cliente
  const getClientDetails = (processId) => {
    const clients = {
      1: {
        name: 'João Silva Santos',
        type: 'PF',
        document: '123.456.789-00',
        email: 'joao.silva@email.com',
        phone: '(11) 99999-1234',
        address: 'Rua das Flores, 123 - Centro - São Paulo/SP'
      },
      2: {
        name: 'Empresa ABC Ltda',
        type: 'PJ',
        document: '12.345.678/0001-90',
        email: 'contato@empresaabc.com.br',
        phone: '(11) 3333-4444',
        address: 'Av. Paulista, 1000 - Bela Vista - São Paulo/SP'
      },
      3: {
        name: 'Maria Oliveira Costa',
        type: 'PF',
        document: '987.654.321-00',
        email: 'maria.costa@email.com',
        phone: '(11) 88888-9999',
        address: 'Rua dos Jardins, 456 - Jardins - São Paulo/SP'
      }
    };
    return clients[processId] || clients[1];
  };

  const client = getClientDetails(process.id);

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-10 mx-auto p-0 border w-4/5 max-w-2xl shadow-lg rounded-xl bg-white">
        {/* Header */}
        <div className="bg-green-600 text-white px-6 py-4 rounded-t-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <UserCircleIcon className="w-8 h-8" />
              <div>
                <h3 className="text-xl font-semibold">{client.name}</h3>
                <span className="text-green-100 text-sm">{client.document}</span>
              </div>
            </div>
            <button onClick={onClose} className="text-white hover:text-green-200">
              <XMarkIcon className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          <div className="space-y-4">
            <div className="flex items-center space-x-3">
              <EnvelopeIcon className="w-5 h-5 text-gray-400" />
              <div>
                <div className="text-sm font-medium text-gray-900">E-mail</div>
                <div className="text-sm text-gray-600">{client.email}</div>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              <PhoneIcon className="w-5 h-5 text-gray-400" />
              <div>
                <div className="text-sm font-medium text-gray-900">Telefone</div>
                <div className="text-sm text-gray-600">{client.phone}</div>
              </div>
            </div>

            <div className="flex items-start space-x-3">
              <MapPinIcon className="w-5 h-5 text-gray-400 mt-0.5" />
              <div>
                <div className="text-sm font-medium text-gray-900">Endereço</div>
                <div className="text-sm text-gray-600">{client.address}</div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 rounded-b-xl">
          <div className="flex justify-between items-center">
            <div className="text-sm text-gray-600">
              Cliente vinculado ao processo: <span className="font-medium">{process.number}</span>
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

echo "📝 4. Criando ProcessTimelineModal.js..."

# Criar ProcessTimelineModal.js
cat > frontend/src/components/processes/ProcessTimelineModal.js << 'EOF'
import React, { useState, useEffect } from 'react';
import {
  XMarkIcon,
  ClockIcon,
  ScaleIcon,
  DocumentIcon,
  UserIcon
} from '@heroicons/react/24/outline';

const ProcessTimelineModal = ({ isOpen, onClose, process }) => {
  const [timeline, setTimeline] = useState([]);
  const [loading, setLoading] = useState(true);

  // Mock data da timeline
  const getTimelineData = (processId) => {
    const timelines = {
      1: [
        {
          id: 1,
          date: '2024-07-25',
          time: '14:30',
          title: 'Juntada de Petição',
          description: 'Petição de manifestação sobre documentos juntados.',
          icon: 'document',
          color: 'blue'
        },
        {
          id: 2,
          date: '2024-01-15',
          time: '08:00',
          title: 'Distribuição do Processo',
          description: 'Processo distribuído e autuado.',
          icon: 'scale',
          color: 'purple'
        }
      ],
      2: [
        {
          id: 3,
          date: '2024-07-20',
          time: '10:30',
          title: 'Despacho do Juiz',
          description: 'Juiz determinou apresentação de documentos.',
          icon: 'document',
          color: 'blue'
        },
        {
          id: 4,
          date: '2024-01-20',
          time: '09:00',
          title: 'Reclamatória Trabalhista',
          description: 'Reclamatória trabalhista protocolada.',
          icon: 'scale',
          color: 'purple'
        }
      ],
      3: [
        {
          id: 5,
          date: '2024-07-15',
          time: '16:00',
          title: 'Processo Concluído',
          description: 'Divórcio homologado com sucesso.',
          icon: 'check',
          color: 'green'
        },
        {
          id: 6,
          date: '2024-02-01',
          time: '10:00',
          title: 'Ação de Divórcio',
          description: 'Petição inicial de divórcio protocolada.',
          icon: 'scale',
          color: 'purple'
        }
      ]
    };
    return timelines[processId] || timelines[1];
  };

  useEffect(() => {
    if (isOpen && process) {
      setLoading(true);
      setTimeout(() => {
        setTimeline(getTimelineData(process.id));
        setLoading(false);
      }, 800);
    }
  }, [isOpen, process]);

  const getIcon = (iconType) => {
    switch (iconType) {
      case 'scale': return ScaleIcon;
      case 'document': return DocumentIcon;
      case 'users': return UserIcon;
      default: return ClockIcon;
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  if (!isOpen || !process) return null;

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div className="relative top-10 mx-auto p-0 border w-4/5 max-w-4xl shadow-lg rounded-xl bg-white">
        {/* Header */}
        <div className="bg-purple-600 text-white px-6 py-4 rounded-t-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <ClockIcon className="w-6 h-6" />
              <div>
                <h3 className="text-lg font-semibold">Timeline do Processo</h3>
                <p className="text-purple-100 text-sm">{process.number}</p>
              </div>
            </div>
            <button onClick={onClose} className="text-white hover:text-purple-200">
              <XMarkIcon className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {loading ? (
            <div className="flex justify-center items-center py-12">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
              <span className="ml-3 text-gray-600">Carregando timeline...</span>
            </div>
          ) : (
            <div className="max-h-96 overflow-y-auto">
              <div className="flow-root">
                <ul className="-mb-8">
                  {timeline.map((event, eventIdx) => {
                    const Icon = getIcon(event.icon);
                    return (
                      <li key={event.id}>
                        <div className="relative pb-8">
                          {eventIdx !== timeline.length - 1 && (
                            <span className="absolute top-4 left-4 -ml-px h-full w-0.5 bg-gray-200" />
                          )}
                          <div className="relative flex space-x-3">
                            <div>
                              <span className="h-8 w-8 rounded-full bg-purple-100 flex items-center justify-center ring-8 ring-white">
                                <Icon className="h-4 w-4 text-purple-600" />
                              </span>
                            </div>
                            <div className="flex-1 min-w-0">
                              <div className="flex items-center justify-between">
                                <div>
                                  <p className="text-sm font-medium text-gray-900">{event.title}</p>
                                  <p className="text-sm text-gray-500 mt-1">{event.description}</p>
                                </div>
                                <div className="text-right">
                                  <p className="text-sm text-gray-900 font-medium">{formatDate(event.date)}</p>
                                  <p className="text-xs text-gray-500">{event.time}</p>
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </li>
                    );
                  })}
                </ul>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 rounded-b-xl">
          <div className="flex justify-between items-center">
            <div className="text-sm text-gray-600">Timeline completa • {timeline.length} evento(s)</div>
            <button onClick={onClose} className="px-4 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400">
              Fechar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProcessTimelineModal;
EOF

echo "✅ Todos os componentes modais criados!"

echo ""
echo "🎉 SCRIPT 99j CONCLUÍDO!"
echo ""
echo "✅ COMPONENTES CRIADOS:"
echo "   • ProcessDocumentsModal.js - Modal de documentos"
echo "   • ProcessClientModal.js - Modal de dados do cliente"
echo "   • ProcessTimelineModal.js - Modal de timeline"
echo ""
echo "📁 ARQUIVOS CRIADOS:"
echo "   • frontend/src/components/processes/ProcessDocumentsModal.js"
echo "   • frontend/src/components/processes/ProcessClientModal.js"
echo "   • frontend/src/components/processes/ProcessTimelineModal.js"
echo ""
echo "🎯 FUNCIONALIDADES INCLUÍDAS:"
echo "   • Documentos com ícones por tipo (PDF, DOCX)"
echo "   • Cliente com dados básicos (nome, email, telefone, endereço)"
echo "   • Timeline com eventos cronológicos"
echo "   • Loading states em todos os modais"
echo "   • Mock data diferente para cada processo (ID 1, 2, 3)"
echo ""
echo "🧪 AGORA TESTE:"
echo "   1. npm start (reiniciar servidor)"
echo "   2. http://localhost:3000/admin/processos"
echo "   3. Clique nos 3 botões coloridos de qualquer processo"
echo "   4. Verifique se os modais abrem corretamente!"
echo ""
echo "🎯 ERROS RESOLVIDOS:"
echo "   ✅ Module not found: ProcessDocumentsModal"
echo "   ✅ Module not found: ProcessClientModal"
echo "   ✅ Module not found: ProcessTimelineModal"
echo ""
echo "Digite 'continuar' após testar os modais!"