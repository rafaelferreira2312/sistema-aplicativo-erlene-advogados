import React, { useState, useEffect } from 'react';
import PortalLayout from '../../components/portal/layout/PortalLayout';
import {
  UserCircleIcon,
  PencilIcon,
  CheckIcon,
  XMarkIcon
} from '@heroicons/react/24/outline';

const PortalPerfil = () => {
  const [clienteData, setClienteData] = useState(null);
  const [editando, setEditando] = useState(false);
  const [dadosEdicao, setDadosEdicao] = useState({});

  useEffect(() => {
    const data = localStorage.getItem('clienteData');
    if (data) {
      const cliente = JSON.parse(data);
      setClienteData(cliente);
      setDadosEdicao(cliente);
    }
  }, []);

  const handleSalvar = () => {
    setClienteData(dadosEdicao);
    localStorage.setItem('clienteData', JSON.stringify(dadosEdicao));
    setEditando(false);
    alert('Dados atualizados com sucesso!');
  };

  if (!clienteData) {
    return (
      <PortalLayout>
        <div className="flex items-center justify-center h-full">
          <div className="animate-spin rounded-full h-8 w-8 border-2 border-red-700 border-t-transparent"></div>
        </div>
      </PortalLayout>
    );
  }

  return (
    <PortalLayout>
      <div className="p-6">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-gray-900">Meu Perfil</h1>
          <p className="text-gray-600 mt-1">Gerencie suas informações pessoais</p>
        </div>

        <div className="bg-white shadow-lg shadow-red-100 rounded-lg p-6">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center">
              <div className="h-16 w-16 bg-gray-300 rounded-full flex items-center justify-center">
                <UserCircleIcon className="h-10 w-10 text-gray-600" />
              </div>
              <div className="ml-4">
                <h2 className="text-xl font-bold text-gray-900">{clienteData.nome}</h2>
                <p className="text-gray-600">{clienteData.cpf || clienteData.cnpj}</p>
              </div>
            </div>
            
            {!editando ? (
              <button
                onClick={() => setEditando(true)}
                className="flex items-center text-red-600 hover:text-red-700"
              >
                <PencilIcon className="h-4 w-4 mr-1" />
                Editar
              </button>
            ) : (
              <div className="flex space-x-2">
                <button
                  onClick={handleSalvar}
                  className="flex items-center text-green-600 hover:text-green-700"
                >
                  <CheckIcon className="h-4 w-4 mr-1" />
                  Salvar
                </button>
                <button
                  onClick={() => {
                    setEditando(false);
                    setDadosEdicao(clienteData);
                  }}
                  className="flex items-center text-gray-600 hover:text-gray-700"
                >
                  <XMarkIcon className="h-4 w-4 mr-1" />
                  Cancelar
                </button>
              </div>
            )}
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nome Completo
              </label>
              {editando ? (
                <input
                  type="text"
                  value={dadosEdicao.nome}
                  onChange={(e) => setDadosEdicao({...dadosEdicao, nome: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-red-500 focus:border-red-500"
                />
              ) : (
                <p className="text-gray-900">{clienteData.nome}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                {clienteData.cpf ? 'CPF' : 'CNPJ'}
              </label>
              <p className="text-gray-900">{clienteData.cpf || clienteData.cnpj}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Email
              </label>
              <p className="text-gray-900">cliente@exemplo.com</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Telefone
              </label>
              <p className="text-gray-900">(11) 99999-9999</p>
            </div>
          </div>

          <div className="mt-6 pt-6 border-t">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Estatísticas</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="text-center">
                <p className="text-2xl font-bold text-red-600">{clienteData.processos}</p>
                <p className="text-sm text-gray-600">Processos</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-blue-600">{clienteData.documentos}</p>
                <p className="text-sm text-gray-600">Documentos</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-green-600">
                  R$ {clienteData.valor_pendente?.toLocaleString('pt-BR') || '0,00'}
                </p>
                <p className="text-sm text-gray-600">Valor Pendente</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </PortalLayout>
  );
};

export default PortalPerfil;
