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
