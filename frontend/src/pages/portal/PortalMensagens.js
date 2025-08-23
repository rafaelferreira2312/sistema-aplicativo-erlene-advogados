import React, { useState, useEffect } from 'react';
import PortalLayout from '../../components/portal/layout/PortalLayout';
import {
  ChatBubbleLeftIcon,
  PaperClipIcon,
  PaperAirplaneIcon
} from '@heroicons/react/24/outline';

const PortalMensagens = () => {
  const [clienteData, setClienteData] = useState(null);
  const [mensagem, setMensagem] = useState('');

  useEffect(() => {
    const data = localStorage.getItem('clienteData');
    if (data) {
      setClienteData(JSON.parse(data));
    }
  }, []);

  const mensagens = [
    {
      id: 1,
      remetente: 'Dra. Erlene Silva',
      conteudo: 'Olá! Informo que seu processo teve uma nova movimentação. Vou enviar os documentos em breve.',
      data: '2024-01-15T10:30:00',
      tipo: 'recebida'
    },
    {
      id: 2,
      remetente: clienteData?.nome || 'Você',
      conteudo: 'Obrigado pela informação. Aguardo os documentos.',
      data: '2024-01-15T11:00:00',
      tipo: 'enviada'
    }
  ];

  const handleEnviar = () => {
    if (mensagem.trim()) {
      alert(`Mensagem enviada: ${mensagem}`);
      setMensagem('');
    }
  };

  return (
    <PortalLayout>
      <div className="p-6">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-gray-900">Mensagens</h1>
          <p className="text-gray-600 mt-1">Converse com nosso escritório</p>
        </div>

        <div className="bg-white shadow-lg shadow-red-100 rounded-lg h-96 flex flex-col">
          <div className="flex-1 p-4 overflow-y-auto space-y-4">
            {mensagens.map((msg) => (
              <div key={msg.id} className={`flex ${msg.tipo === 'enviada' ? 'justify-end' : 'justify-start'}`}>
                <div className={`max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${
                  msg.tipo === 'enviada' 
                    ? 'bg-red-600 text-white' 
                    : 'bg-gray-200 text-gray-900'
                }`}>
                  <p className="text-sm">{msg.conteudo}</p>
                  <p className="text-xs mt-1 opacity-70">
                    {new Date(msg.data).toLocaleString('pt-BR')}
                  </p>
                </div>
              </div>
            ))}
          </div>
          
          <div className="border-t p-4">
            <div className="flex items-center space-x-2">
              <input
                type="text"
                value={mensagem}
                onChange={(e) => setMensagem(e.target.value)}
                placeholder="Digite sua mensagem..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:ring-red-500 focus:border-red-500"
                onKeyPress={(e) => e.key === 'Enter' && handleEnviar()}
              />
              <button className="p-2 text-gray-400 hover:text-gray-600">
                <PaperClipIcon className="h-5 w-5" />
              </button>
              <button 
                onClick={handleEnviar}
                className="p-2 bg-red-600 text-white rounded-md hover:bg-red-700"
              >
                <PaperAirplaneIcon className="h-5 w-5" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </PortalLayout>
  );
};

export default PortalMensagens;
