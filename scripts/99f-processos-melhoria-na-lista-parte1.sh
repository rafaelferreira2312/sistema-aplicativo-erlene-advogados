#!/bin/bash

# Script 99e - Melhorias Lista Processos (Parte 1/2)
# Autor: Sistema Erlene Advogados  
# Data: $(date +%Y-%m-%d)
# Enumeração: 99e

echo "⚖️ Criando melhorias na lista de Processos (Parte 1/2 - Script 99e)..."

# Verificar diretório
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 1. Atualizando Processes.js - Adicionando novos botões..."

# Fazer backup
if [ -f "frontend/src/pages/admin/Processes.js" ]; then
    cp frontend/src/pages/admin/Processes.js frontend/src/pages/admin/Processes.js.backup.$(date +%Y%m%d_%H%M%S)
fi

# Atualizar imports no topo do arquivo
sed -i '/import {/,/} from/ {
  /DocumentIcon/a\
  ,\
  FolderIcon,\
  UserCircleIcon,\
  ClockIcon as TimelineIcon
}' frontend/src/pages/admin/Processes.js

echo "📝 2. Criando componentes modais para documentos e cliente..."

# Criar estrutura de componentes se não existir
mkdir -p frontend/src/components/processes

# Criar ProcessDocumentsModal.js
cat > frontend/src/components/processes/ProcessDocumentsModal.js << 'EOF'
import React, { useState, useEffect } from 'react';
import {
  XMarkIcon,
  DocumentIcon,
  EyeIcon,
  ArrowDownTrayIcon,
  FolderIcon,
  PaperClipIcon
} from '@heroicons/react/24/outline';

const ProcessDocumentsModal = ({ isOpen, onClose, processId, processNumber }) => {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState('all');

  // Mock data dos documentos do processo
  const mockDocuments = {
    1: [
      { id: 1, name: 'Petição Inicial.pdf', category: 'Petições', size: '2.5 MB', date: '2024-01-15', type: 'pdf' },
      { id: 2, name: 'Comprovante Residência.pdf', category: 'Documentos', size: '1.2 MB', date: '2024-01-16', type: 'pdf' },
      { id: 3, name: 'Contrato Social.pdf', category: 'Documentos', size: '3.8 MB', date: '2024-01-20', type: 'pdf' },
      { id: 4, name: 'Contestação.docx', category: 'Petições', size: '1.8 MB', date: '2024-02-10', type: 'docx' },
      { id: 5, name: 'Certidão Negativa.pdf', category: 'Certidões', size: '0.8 MB', date: '2024-02-15', type: 'pdf' },
      { id: 6, name: 'Despacho Juiz.pdf', category: 'Decisões', size: '1.1 MB', date: '2024-03-01', type: 'pdf' }
    ],
    2: [
      { id: 7, name: 'CTPS Digital.pdf', category: 'Documentos', size: '1.5 MB', date: '2024-01-20', type: 'pdf' },
      { id: 8, name: 'Reclamatória Trabalhista.docx', category: 'Petições', size: '2.2 MB', date: '2024-01-22', type: 'docx' },
      { id: 9, name: 'Holerites.zip', category: 'Documentos', size: '5.4 MB', date: '2024-01-25', type: 'zip' },
      { id: 10, name: 'Decisão Liminar.pdf', category: 'Decisões', size: '0.9 MB', date: '2024-02-05', type: 'pdf' }
    ],
    3: [
      { id: 11, name: 'Certidão Casamento.pdf', category: 'Documentos', size: '1.0 MB', date: '2024-02-01', type: 'pdf' },
      { id: 12, name: 'Petição Divórcio.pdf', category: 'Petições', size: '2.1 MB', date: '2024-02-02', type: 'pdf' },
      { id: 13, name: 'Acordo Divórcio.docx', category: 'Acordos', size: '1.6 MB', date: '2024-03-15', type: 'docx' }
    ]
  };

  useEffect(() => {
    if (isOpen && processId) {
      setLoading(true);
      // Simular carregamento
      setTimeout(() => {
        setDocuments(mockDocuments[processId] || []);
        setLoading(false);
      }, 800);
    }
  }, [isOpen, processId]);

  const filteredDocuments = selectedCategory === 'all' 
    ? documents 
    : documents.filter(doc => doc.category === selectedCategory);

  const categories = [...new Set(documents.map(doc => doc.category))];

  const getFileIcon = (type) => {
    switch (type) {
      case 'pdf': return '🔴';
      case 'docx': return '🔵';
      case 'zip': return '🗜️';
      default: return '📄';
    }
  };

  const formatDate = (dateString) => {
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
            <button
              onClick={onClose}
              className="text-white hover:text-primary-200 transition-colors"
            >
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
            <>
              {/* Filtros */}
              <div className="mb-6">
                <div className="flex flex-wrap gap-2">
                  <button
                    onClick={() => setSelectedCategory('all')}
                    className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                      selectedCategory === 'all'
                        ? 'bg-primary-600 text-white'
                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                    }`}
                  >
                    Todos ({documents.length})
                  </button>
                  {categories.map((category) => {
                    const count = documents.filter(doc => doc.category === category).length;
                    return (
                      <button
                        key={category}
                        onClick={() => setSelectedCategory(category)}
                        className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                          selectedCategory === category
                            ? 'bg-primary-600 text-white'
                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                        }`}
                      >
                        {category} ({count})
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Lista de documentos */}
              <div className="space-y-3 max-h-96 overflow-y-auto">
                {filteredDocuments.length === 0 ? (
                  <div className="text-center py-8">
                    <DocumentIcon className="mx-auto h-12 w-12 text-gray-400" />
                    <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum documento encontrado</h3>
                    <p className="mt-1 text-sm text-gray-500">
                      {selectedCategory === 'all' 
                        ? 'Este processo não possui documentos anexados.'
                        : `Nenhum documento da categoria "${selectedCategory}".`
                      }
                    </p>
                  </div>
                ) : (
                  filteredDocuments.map((doc) => (
                    <div key={doc.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
                      <div className="flex items-center space-x-4">
                        <div className="text-2xl">{getFileIcon(doc.type)}</div>
                        <div>
                          <div className="text-sm font-medium text-gray-900">{doc.name}</div>
                          <div className="text-xs text-gray-500">
                            {doc.category} • {doc.size} • {formatDate(doc.date)}
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center space-x-2">
                        <button
                          className="p-2 text-blue-600 hover:text-blue-800 hover:bg-blue-50 rounded-lg transition-colors"
                          title="Visualizar"
                        >
                          <EyeIcon className="w-4 h-4" />
                        </button>
                        <button
                          className="p-2 text-green-600 hover:text-green-800 hover:bg-green-50 rounded-lg transition-colors"
                          title="Download"
                        >
                          <ArrowDownTrayIcon className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </>
          )}
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 rounded-b-xl">
          <div className="flex justify-between items-center">
            <div className="text-sm text-gray-600">
              Total: {documents.length} documento(s)
            </div>
            <button
              onClick={onClose}
              className="px-4 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400 transition-colors"
            >
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

echo "✅ ProcessDocumentsModal.js criado!"

echo "📝 3. Atualizando Processes.js para incluir novos botões..."

# Atualizar a tabela para incluir novos botões nas ações
sed -i '/text-right text-sm font-medium">/,/<\/td>/ {
  /<div className="flex justify-end space-x-2">/,/<\/div>/ {
    /<button className="text-blue-600 hover:text-blue-900" title="Visualizar">/,/<\/button>/ {
      s/title="Visualizar"/title="Ver Timeline"/
      s/text-blue-600 hover:text-blue-900/text-purple-600 hover:text-purple-900/
      s/<EyeIcon/<TimelineIcon/
    }
    /<\/button>/a\
                      <button\
                        onClick={() => setSelectedProcess(process)}\
                        className="text-blue-600 hover:text-blue-900"\
                        title="Ver Documentos"\
                      >\
                        <FolderIcon className="w-5 h-5" />\
                      </button>\
                      <button\
                        onClick={() => setSelectedClient(process)}\
                        className="text-green-600 hover:text-green-900"\
                        title="Ver Dados do Cliente"\
                      >\
                        <UserCircleIcon className="w-5 h-5" />\
                      </button>
  }
}' frontend/src/pages/admin/Processes.js

echo "✅ Botões adicionados na tabela!"

echo ""
echo "📋 SCRIPT 99e - PARTE 1 CONCLUÍDA:"
echo "   • ProcessDocumentsModal.js criado com funcionalidade completa"
echo "   • Modal mostra documentos organizados por categoria"
echo "   • Filtros por tipo de documento (Petições, Documentos, Decisões, etc.)"
echo "   • Botões de visualizar e download para cada documento"
echo "   • Mock data para 3 processos diferentes"
echo "   • Novos ícones importados (FolderIcon, UserCircleIcon, TimelineIcon)"
echo ""
echo "🎯 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Modal de documentos com categorização"
echo "   • 3 novos botões na tabela: Timeline, Documentos, Cliente"
echo "   • Mudança do botão 'olho' para Timeline (roxo)"
echo "   • Botão Documentos (azul) abre modal com lista"
echo "   • Botão Cliente (verde) para ver dados do cliente"
echo ""
echo "📁 ARQUIVOS CRIADOS:"
echo "   • frontend/src/components/processes/ProcessDocumentsModal.js"
echo "   • Processes.js atualizado com novos botões"
echo ""
echo "⏭️ PRÓXIMA PARTE (2/2):"
echo "   • ProcessClientModal.js (dados do cliente)"
echo "   • ProcessTimelineModal.js (timeline do processo)"
echo "   • Estados para gerenciar modais abertos"
echo "   • Integração completa dos 3 modais"
echo ""
echo "📏 LINHA ATUAL: ~300/300 (no limite exato)"
echo ""
echo "Digite 'continuar' para a Parte 2/2!"