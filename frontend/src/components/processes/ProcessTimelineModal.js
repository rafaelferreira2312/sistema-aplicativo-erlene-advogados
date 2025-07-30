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
