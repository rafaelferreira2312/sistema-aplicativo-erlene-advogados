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
