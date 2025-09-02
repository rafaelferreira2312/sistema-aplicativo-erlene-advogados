#!/bin/bash

# Script 123 - Melhorar Frontend de Clientes
# Sistema de Gestão Jurídica - Erlene Advogados  
# Execução: chmod +x 123-frontend-client-improvements.sh && ./123-frontend-client-improvements.sh
# EXECUTE NA PASTA: backend/ (mas trabalha no frontend)

echo "🎨 Implementando melhorias no frontend de clientes..."

# Verificar se estamos na pasta backend
if [ ! -f "artisan" ]; then
    echo "❌ Execute este script na pasta backend/"
    exit 1
fi

# Verificar se pasta frontend existe
if [ ! -d "../frontend" ]; then
    echo "❌ Pasta frontend não encontrada"
    exit 1
fi

echo ""
echo "=== ANALISANDO ESTRUTURA DO FRONTEND ==="

echo "1. Verificando arquivos existentes de clientes..."
find ../frontend -name "*[Cc]lient*" -type f | grep -E "\.(js|jsx)$" | head -10

CLIENTS_PAGE="../frontend/src/pages/admin/Clients.js"
CLIENTS_SERVICE="../frontend/src/services/api/clientsService.js"

if [ -f "$CLIENTS_PAGE" ]; then
    echo "✅ Arquivo principal encontrado: $CLIENTS_PAGE"
else
    echo "❌ Arquivo principal não encontrado: $CLIENTS_PAGE"
    exit 1
fi

echo ""
echo "2. Analisando estrutura atual do arquivo Clients.js..."
echo "Tamanho atual: $(wc -l < "$CLIENTS_PAGE") linhas"

# Verificar se já tem as melhorias
if grep -q "CPF/CNPJ\|Processos\|Documentos" "$CLIENTS_PAGE"; then
    echo "⚠️  Algumas melhorias já podem existir"
fi

echo ""
echo "3. Fazendo backup dos arquivos..."
cp "$CLIENTS_PAGE" "${CLIENTS_PAGE}.backup-$(date +%Y%m%d-%H%M%S)"

if [ -f "$CLIENTS_SERVICE" ]; then
    cp "$CLIENTS_SERVICE" "${CLIENTS_SERVICE}.backup-$(date +%Y%m%d-%H%M%S)"
    echo "✅ Backup do service criado"
fi

echo ""
echo "4. Atualizando clientsService.js para adicionar novos endpoints..."

if [ -f "$CLIENTS_SERVICE" ]; then
    # Verificar se endpoints já existem
    if ! grep -q "processos\|documentos" "$CLIENTS_SERVICE"; then
        echo "Adicionando métodos processos e documentos no service..."
        
        # Adicionar métodos antes do fechamento do objeto/classe
        cat >> temp_service_methods.js << 'EOF'

  // Obter processos do cliente
  async getClientProcessos(clienteId) {
    try {
      const response = await api.get(`/admin/clients/${clienteId}/processos`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar processos:', error);
      throw error;
    }
  },

  // Obter documentos do cliente
  async getClientDocumentos(clienteId) {
    try {
      const response = await api.get(`/admin/clients/${clienteId}/documentos`);
      return response.data;
    } catch (error) {
      console.error('Erro ao buscar documentos:', error);
      throw error;
    }
  }
EOF

        # Inserir antes da última linha (assumindo que termina com };)
        head -n -1 "$CLIENTS_SERVICE" > temp_service.js
        cat temp_service_methods.js >> temp_service.js
        echo "};" >> temp_service.js
        
        mv temp_service.js "$CLIENTS_SERVICE"
        rm temp_service_methods.js
        
        echo "✅ Métodos adicionados ao service"
    else
        echo "✅ Métodos já existem no service"
    fi
else
    echo "⚠️  clientsService.js não encontrado - pulando"
fi

echo ""
echo "5. Criando componente de abas para cliente..."

TABS_COMPONENT="../frontend/src/components/clients/ClientTabs.js"
mkdir -p "$(dirname "$TABS_COMPONENT")"

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
            className="text-gray-500 hover:text-gray-700"
          >
            ✕
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
            <div className="text-center text-gray-600">
              <p>Informações básicas do cliente</p>
              <p className="text-sm mt-2">Esta aba pode ser desenvolvida posteriormente</p>
            </div>
          )}

          {activeTab === 'processos' && (
            <div>
              <h3 className="text-lg font-semibold mb-4">
                Processos Relacionados ({processos.length})
              </h3>
              
              {loading ? (
                <p>Carregando processos...</p>
              ) : processos.length > 0 ? (
                <div className="space-y-3">
                  {processos.map((processo) => (
                    <div key={processo.id} className="border rounded-lg p-4">
                      <div className="flex justify-between items-start">
                        <div>
                          <h4 className="font-semibold">{processo.numero}</h4>
                          <p className="text-gray-600">{processo.tipo_acao}</p>
                          <p className="text-sm text-gray-500">
                            {processo.tribunal} - {processo.vara}
                          </p>
                        </div>
                        <span className={`px-2 py-1 rounded-full text-xs ${
                          processo.status === 'em_andamento' 
                            ? 'bg-yellow-100 text-yellow-800'
                            : processo.status === 'ativo'
                            ? 'bg-green-100 text-green-800'
                            : 'bg-gray-100 text-gray-800'
                        }`}>
                          {processo.status}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-gray-500 text-center">
                  Nenhum processo encontrado para este cliente.
                </p>
              )}
            </div>
          )}

          {activeTab === 'documentos' && (
            <div>
              <h3 className="text-lg font-semibold mb-4">
                Documentos Relacionados ({documentos.length})
              </h3>
              
              {loading ? (
                <p>Carregando documentos...</p>
              ) : documentos.length > 0 ? (
                <div className="space-y-3">
                  {documentos.map((documento) => (
                    <div key={documento.id} className="border rounded-lg p-4 flex justify-between items-center">
                      <div className="flex items-center">
                        <FileText className="text-gray-500 mr-3" size={20} />
                        <div>
                          <h4 className="font-medium">{documento.nome}</h4>
                          <p className="text-sm text-gray-500">
                            Tipo: {documento.tipo} • Tamanho: {documento.tamanho}
                          </p>
                          <p className="text-xs text-gray-400">
                            Criado em: {documento.created_at}
                          </p>
                        </div>
                      </div>
                      <button className="text-blue-600 hover:text-blue-800 text-sm">
                        Visualizar
                      </button>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-gray-500 text-center">
                  Nenhum documento encontrado para este cliente.
                </p>
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

echo "✅ Componente ClientTabs.js criado"

echo ""
echo "6. Modificando listagem principal para mostrar CPF/CNPJ..."

# Fazer substituição no arquivo principal
if grep -q "Documento" "$CLIENTS_PAGE"; then
    echo "Substituindo 'Documento' por 'CPF/CNPJ'..."
    sed -i 's/Documento/CPF\/CNPJ/g' "$CLIENTS_PAGE"
    echo "✅ Label alterado para CPF/CNPJ"
else
    echo "⚠️  Label 'Documento' não encontrado - pode já estar correto"
fi

echo ""
echo "7. Criando funcionalidade de detalhes do cliente..."

# Procurar padrão de botão de ações e adicionar botão de detalhes
if grep -q "Ações\|AÇÕES\|ações" "$CLIENTS_PAGE"; then
    echo "✅ Coluna de ações encontrada - funcionalidade pode ser integrada"
else
    echo "⚠️  Coluna de ações não encontrada claramente"
fi

echo ""
echo "8. Verificando resultado das alterações..."

echo "Novo tamanho do arquivo principal: $(wc -l < "$CLIENTS_PAGE") linhas"

# Verificar se importações são necessárias
if ! grep -q "ClientTabs" "$CLIENTS_PAGE"; then
    echo ""
    echo "9. Adicionando importação do ClientTabs..."
    
    # Adicionar importação (procurar por outras importações)
    if grep -q "import.*from.*components" "$CLIENTS_PAGE"; then
        # Adicionar após outras importações de componentes
        sed -i '/import.*from.*components/a import ClientTabs from "../components/clients/ClientTabs";' "$CLIENTS_PAGE"
    else
        # Adicionar após imports do React
        sed -i '/import React/a import ClientTabs from "../components/clients/ClientTabs";' "$CLIENTS_PAGE"
    fi
    
    echo "✅ Importação do ClientTabs adicionada"
fi

echo ""
echo "=== RESUMO DAS MELHORIAS ==="
echo ""
echo "✅ IMPLEMENTAÇÕES FRONTEND:"
echo "- Componente ClientTabs.js criado"
echo "- Label 'Documento' → 'CPF/CNPJ'"
echo "- Endpoints integrados no service"
echo "- Abas: Informações, Processos, Documentos"
echo ""
echo "📋 FUNCIONALIDADES:"
echo "- Processos: Lista processos do cliente com status"  
echo "- Documentos: Mostra documentos (dados de exemplo)"
echo "- Modal responsivo com abas"
echo ""
echo "🎯 PRÓXIMOS PASSOS:"
echo "1. Integrar botão 'Detalhes' na listagem"
echo "2. Testar funcionalidade no navegador"
echo "3. Ajustar estilos se necessário"
echo ""
echo "🔧 PARA TESTAR:"
echo "1. cd ../frontend && npm start"
echo "2. Acesse /admin/clientes"
echo "3. Verifique se aparece 'CPF/CNPJ' em vez de 'Documento'"