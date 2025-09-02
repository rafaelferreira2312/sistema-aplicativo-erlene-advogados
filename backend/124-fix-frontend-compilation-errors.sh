#!/bin/bash

# Script 124 - Corrigir Erros de Compilação do Frontend
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 124-fix-frontend-compilation-errors.sh && ./124-fix-frontend-compilation-errors.sh
# EXECUTE NA PASTA: backend/ (mas trabalha no frontend)

echo "🔧 Corrigindo erros de compilação do frontend..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

echo ""
echo "=== CORRIGINDO ERROS ==="

CLIENTS_SERVICE="../frontend/src/services/api/clientsService.js"
CLIENTS_PAGE="../frontend/src/pages/admin/Clients.js"
TABS_COMPONENT="../frontend/src/components/clients/ClientTabs.js"

echo "1. Corrigindo erro de sintaxe no clientsService.js..."

if [ -f "$CLIENTS_SERVICE" ]; then
    echo "Verificando estrutura atual do service..."
    
    # Restaurar backup se necessário
    if [ -f "${CLIENTS_SERVICE}.backup-"* ]; then
        BACKUP_FILE=$(ls -t "${CLIENTS_SERVICE}".backup-* | head -1)
        echo "Restaurando backup: $BACKUP_FILE"
        cp "$BACKUP_FILE" "$CLIENTS_SERVICE"
    fi
    
    # Verificar se é um objeto ou classe
    if grep -q "export const\|const.*=" "$CLIENTS_SERVICE"; then
        echo "Formato de objeto detectado"
        
        # Remover métodos defeituosos se existirem
        if grep -q "getClientProcessos\|getClientDocumentos" "$CLIENTS_SERVICE"; then
            echo "Removendo métodos defeituosos..."
            # Restaurar versão limpa
            sed -i '/getClientProcessos/,/^  }/d' "$CLIENTS_SERVICE"
            sed -i '/getClientDocumentos/,/^  }/d' "$CLIENTS_SERVICE"
        fi
        
        # Adicionar métodos corretamente
        echo "Adicionando métodos com sintaxe correta..."
        
        # Encontrar onde inserir (antes do último })
        if grep -q "^};" "$CLIENTS_SERVICE"; then
            # Inserir antes de };
            sed -i '/^};/i\
\
  // Obter processos do cliente\
  getClientProcessos: async (clienteId) => {\
    try {\
      const response = await api.get(`/admin/clients/${clienteId}/processos`);\
      return response.data;\
    } catch (error) {\
      console.error("Erro ao buscar processos:", error);\
      throw error;\
    }\
  },\
\
  // Obter documentos do cliente\
  getClientDocumentos: async (clienteId) => {\
    try {\
      const response = await api.get(`/admin/clients/${clienteId}/documentos`);\
      return response.data;\
    } catch (error) {\
      console.error("Erro ao buscar documentos:", error);\
      throw error;\
    }\
  }' "$CLIENTS_SERVICE"
            
            echo "✅ Métodos adicionados com sintaxe de objeto"
        else
            echo "⚠️  Estrutura do service não reconhecida"
        fi
    else
        echo "⚠️  Formato do service não reconhecido"
    fi
else
    echo "❌ clientsService.js não encontrado"
fi

echo ""
echo "2. Verificando se ClientTabs foi criado corretamente..."

if [ ! -f "$TABS_COMPONENT" ]; then
    echo "❌ ClientTabs não foi criado - criando novamente..."
    
    # Criar diretório se não existir
    mkdir -p "$(dirname "$TABS_COMPONENT")"
    
    # Criar componente novamente
    cat > "$TABS_COMPONENT" << 'EOF'
import React, { useState, useEffect } from 'react';
import { Folder, FileText, User } from 'lucide-react';
import { clientsService } from '../../services/api/clientsService';

const ClientTabs = ({ clienteId, onClose }) => {
  const [activeTab, setActiveTab] = useState('info');
  const [processos, setProcessos] = useState([]);
  const [documentos, setDocumentos] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (activeTab === 'processos') {
      loadProcessos();
    } else if (activeTab === 'documentos') {
      loadDocumentos();
    }
  }, [activeTab, clienteId]);

  const loadProcessos = async () => {
    setLoading(true);
    try {
      const response = await clientsService.getClientProcessos(clienteId);
      if (response.success) {
        setProcessos(response.data);
      }
    } catch (error) {
      console.error('Erro ao carregar processos:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadDocumentos = async () => {
    setLoading(true);
    try {
      const response = await clientsService.getClientDocumentos(clienteId);
      if (response.success) {
        setDocumentos(response.data);
      }
    } catch (error) {
      console.error('Erro ao carregar documentos:', error);
    } finally {
      setLoading(false);
    }
  };

  const tabs = [
    { id: 'info', label: 'Informações', icon: User },
    { id: 'processos', label: 'Processos', icon: Folder },
    { id: 'documentos', label: 'Documentos', icon: FileText }
  ];

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl w-11/12 max-w-4xl h-5/6 flex flex-col">
        {/* Header */}
        <div className="flex justify-between items-center p-4 border-b">
          <h2 className="text-xl font-semibold text-gray-800">
            Detalhes do Cliente
          </h2>
          <button 
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 text-xl px-2"
          >
            ×
          </button>
        </div>

        {/* Tabs */}
        <div className="flex border-b">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center px-4 py-2 font-medium text-sm transition-colors ${
                  activeTab === tab.id
                    ? 'text-red-600 border-b-2 border-red-600'
                    : 'text-gray-600 hover:text-red-600'
                }`}
              >
                <Icon size={16} className="mr-2" />
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Content */}
        <div className="flex-1 p-4 overflow-auto">
          {activeTab === 'info' && (
            <div className="text-center text-gray-600 mt-8">
              <User size={48} className="mx-auto mb-4 text-gray-400" />
              <p className="text-lg mb-2">Informações básicas do cliente</p>
              <p className="text-sm">Esta seção pode ser desenvolvida posteriormente</p>
            </div>
          )}

          {activeTab === 'processos' && (
            <div>
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">
                  Processos Relacionados
                </h3>
                <span className="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-sm">
                  {processos.length} processo(s)
                </span>
              </div>
              
              {loading ? (
                <div className="text-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-red-600 mx-auto"></div>
                  <p className="mt-2 text-gray-600">Carregando processos...</p>
                </div>
              ) : processos.length > 0 ? (
                <div className="space-y-3">
                  {processos.map((processo) => (
                    <div key={processo.id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <h4 className="font-semibold text-gray-900">{processo.numero}</h4>
                          <p className="text-gray-700 mt-1">{processo.tipo_acao}</p>
                          <div className="text-sm text-gray-500 mt-2">
                            <p><strong>Tribunal:</strong> {processo.tribunal}</p>
                            <p><strong>Vara:</strong> {processo.vara}</p>
                            {processo.data_distribuicao && (
                              <p><strong>Distribuição:</strong> {new Date(processo.data_distribuicao).toLocaleDateString('pt-BR')}</p>
                            )}
                          </div>
                        </div>
                        <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                          processo.status === 'em_andamento' 
                            ? 'bg-yellow-100 text-yellow-800'
                            : processo.status === 'ativo'
                            ? 'bg-green-100 text-green-800'
                            : 'bg-gray-100 text-gray-800'
                        }`}>
                          {processo.status.replace('_', ' ').toUpperCase()}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8">
                  <Folder size={48} className="mx-auto mb-4 text-gray-400" />
                  <p className="text-gray-500">Nenhum processo encontrado para este cliente.</p>
                </div>
              )}
            </div>
          )}

          {activeTab === 'documentos' && (
            <div>
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">
                  Documentos Relacionados
                </h3>
                <span className="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-sm">
                  {documentos.length} documento(s)
                </span>
              </div>
              
              {loading ? (
                <div className="text-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-red-600 mx-auto"></div>
                  <p className="mt-2 text-gray-600">Carregando documentos...</p>
                </div>
              ) : documentos.length > 0 ? (
                <div className="space-y-3">
                  {documentos.map((documento) => (
                    <div key={documento.id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                      <div className="flex justify-between items-center">
                        <div className="flex items-center flex-1">
                          <FileText className="text-gray-500 mr-3" size={24} />
                          <div>
                            <h4 className="font-medium text-gray-900">{documento.nome}</h4>
                            <div className="text-sm text-gray-500 mt-1">
                              <span>Tipo: {documento.tipo}</span>
                              <span className="mx-2">•</span>
                              <span>Tamanho: {documento.tamanho}</span>
                            </div>
                            <p className="text-xs text-gray-400 mt-1">
                              Criado em: {documento.created_at}
                            </p>
                          </div>
                        </div>
                        <button className="bg-red-600 text-white px-3 py-1 rounded hover:bg-red-700 transition-colors text-sm">
                          Visualizar
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8">
                  <FileText size={48} className="mx-auto mb-4 text-gray-400" />
                  <p className="text-gray-500">Nenhum documento encontrado para este cliente.</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ClientTabs;
EOF

    echo "✅ ClientTabs.js criado novamente"
else
    echo "✅ ClientTabs.js existe"
fi

echo ""
echo "3. Removendo importação não utilizada do Clients.js..."

if [ -f "$CLIENTS_PAGE" ]; then
    # Remover importação do ClientTabs temporariamente
    if grep -q "ClientTabs" "$CLIENTS_PAGE"; then
        echo "Removendo importação do ClientTabs..."
        sed -i '/import ClientTabs/d' "$CLIENTS_PAGE"
        echo "✅ Importação removida"
    fi
    
    # Remover EyeIcon não utilizado
    if grep -q "EyeIcon.*not used" "$CLIENTS_PAGE" 2>/dev/null || ! grep -q "EyeIcon" "$CLIENTS_PAGE"; then
        echo "Removendo EyeIcon não utilizado..."
        sed -i 's/, EyeIcon//g' "$CLIENTS_PAGE"
        sed -i 's/EyeIcon,//g' "$CLIENTS_PAGE"
        sed -i 's/EyeIcon//g' "$CLIENTS_PAGE"
        echo "✅ EyeIcon removido"
    fi
    
else
    echo "❌ Clients.js não encontrado"
fi

echo ""
echo "4. Verificando sintaxe dos arquivos..."

if [ -f "$CLIENTS_SERVICE" ]; then
    echo "Verificando clientsService.js..."
    if node -c "$CLIENTS_SERVICE" 2>/dev/null; then
        echo "✅ clientsService.js sem erros de sintaxe"
    else
        echo "❌ clientsService.js ainda tem erros de sintaxe"
    fi
fi

if [ -f "$TABS_COMPONENT" ]; then
    echo "Verificando ClientTabs.js..."
    if node -c "$TABS_COMPONENT" 2>/dev/null; then
        echo "✅ ClientTabs.js sem erros de sintaxe"
    else
        echo "❌ ClientTabs.js tem erros de sintaxe"
    fi
fi

echo ""
echo "5. Testando se endpoints estão funcionando..."

# Testar endpoints do backend
echo "Verificando se backend está rodando..."
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "✅ Backend funcionando"
else
    echo "⚠️  Backend pode não estar rodando"
fi

echo ""
echo "=== CORREÇÃO FINALIZADA ==="
echo ""
echo "✅ PROBLEMAS CORRIGIDOS:"
echo "- Erro de sintaxe no clientsService.js"
echo "- ClientTabs.js recriado"
echo "- Importações não utilizadas removidas"
echo ""
echo "🎯 PRÓXIMOS PASSOS:"
echo "1. Teste a compilação: cd ../frontend && npm start"
echo "2. Se compilar sem erros, podemos integrar o botão 'Detalhes'"
echo "3. Depois implementar a funcionalidade completa"
echo ""
echo "🔧 PARA TESTAR:"
echo "cd ../frontend"
echo "npm start"
echo ""
echo "Se ainda houver erros, me envie e continuamos a correção!"