#!/bin/bash

# Script 128e - Criar EditProcess.js com TODOS os campos da tabela
# Sistema Erlene Advogados - Formulário de edição completo conforme estrutura da tabela processos
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 128e - Criando EditProcess.js com TODOS os campos da tabela..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 128e-complete-editprocess.sh && ./128e-complete-editprocess.sh"
    exit 1
fi

echo "1️⃣ DIAGNÓSTICO DO PROBLEMA:"
echo "   • EditProcess.js atual: campos incompletos ❌"
echo "   • Falta carregamento de dados do processo existente"
echo "   • Falta integração com processesService"
echo "   • Solução: implementar TODOS os campos + carregamento de dados"

echo ""
echo "2️⃣ Fazendo backup do EditProcess.js atual..."

# Criar diretório se não existir
mkdir -p src/components/processes

# Backup do arquivo atual
if [ -f "src/components/processes/EditProcess.js" ]; then
    cp src/components/processes/EditProcess.js src/components/processes/EditProcess.js.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backup criado: EditProcess.js.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo ""
echo "3️⃣ Criando EditProcess.js completo com carregamento de dados..."

cat > src/components/processes/EditProcess.js << 'EOF'
import React, { useState, useEffect } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import { processesService } from '../../services/processesService';
import { clientsService } from '../../services/clientsService';
import {
  ArrowLeftIcon,
  ScaleIcon,
  UserIcon,
  DocumentTextIcon,
  CurrencyDollarIcon,
  BuildingLibraryIcon,
  CalendarIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon,
  TrashIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline';

const EditProcess = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(true);
  const [clients, setClients] = useState([]);
  const [advogados, setAdvogados] = useState([]);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  
  // TODOS os campos da tabela processos
  const [formData, setFormData] = useState({
    // CAMPOS OBRIGATÓRIOS (NOT NULL na tabela)
    numero: '',               // varchar(25) UNIQUE
    tribunal: '',             // varchar(255) NOT NULL
    cliente_id: '',           // FK OBRIGATÓRIA
    tipo_acao: '',            // varchar(255) NOT NULL
    data_distribuicao: '',    // date NOT NULL
    advogado_id: '',          // FK OBRIGATÓRIA
    
    // CAMPOS OPCIONAIS (NULL permitido)
    vara: '',                 // varchar(255) NULL
    valor_causa: '',          // decimal(15,2) NULL
    proximo_prazo: '',        // date NULL
    observacoes: '',          // text NULL
    
    // ENUMS com defaults
    status: 'distribuido',    // enum DEFAULT 'distribuido'
    prioridade: 'media'       // enum DEFAULT 'media'
  });

  const [originalData, setOriginalData] = useState({});
  const [errors, setErrors] = useState({});

  // Carregar dados do processo e listas necessárias
  useEffect(() => {
    const loadData = async () => {
      try {
        setLoadingData(true);
        
        console.log('🔄 Carregando dados do processo ID:', id);
        
        // Carregar dados do processo
        const processResponse = await processesService.getProcess(id);
        
        if (processResponse && processResponse.success) {
          const process = processResponse.data;
          console.log('✅ Processo carregado:', process);
          
          // Preencher formulário com dados do processo
          const processData = {
            numero: process.numero || '',
            tribunal: process.tribunal || '',
            vara: process.vara || '',
            cliente_id: process.cliente_id || '',
            tipo_acao: process.tipo_acao || '',
            status: process.status || 'distribuido',
            valor_causa: process.valor_causa ? formatCurrency(process.valor_causa.toString()) : '',
            data_distribuicao: process.data_distribuicao ? process.data_distribuicao.split('T')[0] : '',
            advogado_id: process.advogado_id || '',
            proximo_prazo: process.proximo_prazo ? process.proximo_prazo.split('T')[0] : '',
            observacoes: process.observacoes || '',
            prioridade: process.prioridade || 'media'
          };
          
          setFormData(processData);
          setOriginalData(processData);
          
        } else {
          console.error('❌ Erro na resposta do processo:', processResponse);
          alert('Processo não encontrado');
          navigate('/admin/processos');
          return;
        }

        // Carregar clientes
        try {
          const clientsResponse = await clientsService.getClients({ per_page: 100 });
          if (clientsResponse && clientsResponse.success) {
            const clientData = clientsResponse.data?.data || clientsResponse.data || [];
            setClients(Array.isArray(clientData) ? clientData : []);
            console.log('✅ Clientes carregados:', clientData.length);
          } else {
            throw new Error('Resposta inválida do serviço de clientes');
          }
        } catch (clientError) {
          console.warn('⚠️ Erro ao carregar clientes, usando dados mock:', clientError);
          // Dados mock como fallback
          setClients([
            { id: 1, nome: 'João Silva Santos', tipo_pessoa: 'PF', cpf_cnpj: '123.456.789-00' },
            { id: 2, nome: 'Empresa ABC Ltda', tipo_pessoa: 'PJ', cpf_cnpj: '12.345.678/0001-90' },
            { id: 3, nome: 'Maria Oliveira Costa', tipo_pessoa: 'PF', cpf_cnpj: '987.654.321-00' }
          ]);
        }

        // Carregar advogados (dados mock por enquanto)
        const mockAdvogados = [
          { id: 1, name: 'Dr. Carlos Oliveira', oab: 'OAB/SP 123456' },
          { id: 2, name: 'Dra. Maria Santos', oab: 'OAB/SP 234567' },
          { id: 3, name: 'Dr. Pedro Costa', oab: 'OAB/SP 345678' },
          { id: 4, name: 'Dra. Ana Silva', oab: 'OAB/SP 456789' },
          { id: 5, name: 'Dra. Erlene Chaves Silva', oab: 'OAB/SP 567890' }
        ];
        setAdvogados(mockAdvogados);
        console.log('✅ Advogados carregados:', mockAdvogados.length);

      } catch (error) {
        console.error('💥 Erro ao carregar dados:', error);
        alert('Erro ao carregar dados do processo');
        navigate('/admin/processos');
      } finally {
        setLoadingData(false);
      }
    };

    if (id) {
      loadData();
    } else {
      navigate('/admin/processos');
    }
  }, [id, navigate]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    // Limpar erro do campo
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  // Validações baseadas na estrutura real da tabela
  const validateForm = () => {
    const newErrors = {};
    
    // CAMPOS OBRIGATÓRIOS (NOT NULL na tabela)
    if (!formData.numero.trim()) newErrors.numero = 'Número do processo é obrigatório';
    if (!formData.tribunal.trim()) newErrors.tribunal = 'Tribunal é obrigatório';
    if (!formData.cliente_id) newErrors.cliente_id = 'Cliente é obrigatório';
    if (!formData.tipo_acao.trim()) newErrors.tipo_acao = 'Tipo de ação é obrigatório';
    if (!formData.data_distribuicao) newErrors.data_distribuicao = 'Data de distribuição é obrigatória';
    if (!formData.advogado_id) newErrors.advogado_id = 'Advogado responsável é obrigatório';
    
    // Validações de formato
    if (formData.numero && formData.numero.length > 25) {
      newErrors.numero = 'Número do processo deve ter no máximo 25 caracteres';
    }
    
    if (formData.valor_causa && isNaN(parseFloat(formData.valor_causa.replace(/[^\d,.-]/g, '').replace(',', '.')))) {
      newErrors.valor_causa = 'Valor da causa deve ser um número válido';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      console.log('❌ Formulário inválido:', errors);
      return;
    }
    
    setLoading(true);
    
    try {
      // Preparar dados para envio
      const submitData = {
        ...formData,
        // Converter valor_causa para número se preenchido
        valor_causa: formData.valor_causa ? 
          parseFloat(formData.valor_causa.replace(/[^\d,.-]/g, '').replace(',', '.')) : 
          null,
        // Garantir que IDs sejam números
        cliente_id: parseInt(formData.cliente_id),
        advogado_id: parseInt(formData.advogado_id)
      };
      
      console.log('📤 Atualizando processo:', submitData);
      
      const response = await processesService.updateProcess(id, submitData);
      
      if (response && response.success) {
        console.log('✅ Processo atualizado com sucesso');
        alert('Processo atualizado com sucesso!');
        navigate('/admin/processos');
      } else {
        console.error('❌ Erro na resposta:', response);
        alert(response?.message || 'Erro ao atualizar processo');
      }
    } catch (error) {
      console.error('💥 Erro ao atualizar processo:', error);
      alert('Erro ao atualizar processo. Verifique sua conexão.');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    try {
      console.log('🗑️ Excluindo processo ID:', id);
      
      const response = await processesService.deleteProcess(id);
      
      if (response && response.success) {
        console.log('✅ Processo excluído com sucesso');
        alert('Processo excluído com sucesso!');
        navigate('/admin/processos');
      } else {
        console.error('❌ Erro ao excluir:', response);
        alert('Erro ao excluir processo');
      }
    } catch (error) {
      console.error('💥 Erro ao excluir processo:', error);
      alert('Erro ao excluir processo');
    }
    setShowDeleteModal(false);
  };

  const formatCurrency = (value) => {
    if (!value) return '';
    
    // Remove caracteres não numéricos
    const numbers = value.replace(/\D/g, '');
    
    if (!numbers) return '';
    
    // Converte para número com 2 casas decimais
    const amount = parseInt(numbers) / 100;
    
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(amount);
  };

  const handleCurrencyChange = (e) => {
    const formatted = formatCurrency(e.target.value);
    setFormData(prev => ({
      ...prev,
      valor_causa: formatted
    }));
  };

  const getSelectedClient = () => {
    return clients.find(c => c.id.toString() === formData.cliente_id.toString());
  };

  const getSelectedAdvogado = () => {
    return advogados.find(a => a.id.toString() === formData.advogado_id.toString());
  };

  // Verificar se houve mudanças
  const hasChanges = () => {
    return JSON.stringify(formData) !== JSON.stringify(originalData);
  };

  const selectedClient = getSelectedClient();
  const selectedAdvogado = getSelectedAdvogado();

  if (loadingData) {
    return (
      <div className="space-y-8">
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-6 animate-pulse">
          <div className="h-6 bg-gray-200 rounded mb-4 w-1/3"></div>
          <div className="grid grid-cols-2 gap-4">
            <div className="h-12 bg-gray-200 rounded"></div>
            <div className="h-12 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="space-y-8">
        {/* Header */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Link
                to="/admin/processos"
                className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <ArrowLeftIcon className="w-5 h-5" />
              </Link>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Editar Processo</h1>
                <p className="text-lg text-gray-600 mt-2">
                  Atualize as informações do processo
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              {hasChanges() && (
                <div className="flex items-center space-x-2 text-amber-600 bg-amber-50 px-3 py-1 rounded-lg">
                  <ExclamationTriangleIcon className="w-4 h-4" />
                  <span className="text-sm font-medium">Alterações não salvas</span>
                </div>
              )}
              <button
                onClick={() => setShowDeleteModal(true)}
                className="inline-flex items-center px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
              >
                <TrashIcon className="w-4 h-4 mr-2" />
                Excluir
              </button>
            </div>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Dados Básicos - Campos OBRIGATÓRIOS */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center space-x-3 mb-6">
              <ExclamationTriangleIcon className="w-5 h-5 text-red-500" />
              <h2 className="text-xl font-semibold text-gray-900">Dados Básicos (Obrigatórios)</h2>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Número do Processo */}
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Número do Processo *
                </label>
                <input
                  type="text"
                  name="numero"
                  value={formData.numero}
                  onChange={handleChange}
                  maxLength="25"
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.numero ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="0000000-00.0000.0.00.0000"
                />
                {errors.numero && <p className="text-red-500 text-sm mt-1">{errors.numero}</p>}
                <p className="text-xs text-gray-500 mt-1">Formato CNJ: 7 dígitos-2 dígitos.4 dígitos.1 dígito.2 dígitos.4 dígitos</p>
              </div>

              {/* Cliente */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Cliente *
                </label>
                <select
                  name="cliente_id"
                  value={formData.cliente_id}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.cliente_id ? 'border-red-300' : 'border-gray-300'
                  }`}
                >
                  <option value="">Selecione o cliente...</option>
                  {clients.map((client) => (
                    <option key={client.id} value={client.id}>
                      {client.nome} ({client.tipo_pessoa}) - {client.cpf_cnpj}
                    </option>
                  ))}
                </select>
                {errors.cliente_id && <p className="text-red-500 text-sm mt-1">{errors.cliente_id}</p>}
              </div>

              {/* Advogado Responsável */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Advogado Responsável *
                </label>
                <select
                  name="advogado_id"
                  value={formData.advogado_id}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.advogado_id ? 'border-red-300' : 'border-gray-300'
                  }`}
                >
                  <option value="">Selecione o advogado...</option>
                  {advogados.map((advogado) => (
                    <option key={advogado.id} value={advogado.id}>
                      {advogado.name} ({advogado.oab})
                    </option>
                  ))}
                </select>
                {errors.advogado_id && <p className="text-red-500 text-sm mt-1">{errors.advogado_id}</p>}
              </div>

              {/* Tribunal */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tribunal *
                </label>
                <select
                  name="tribunal"
                  value={formData.tribunal}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.tribunal ? 'border-red-300' : 'border-gray-300'
                  }`}
                >
                  <option value="">Selecione o tribunal...</option>
                  <option value="TJSP">TJSP - Tribunal de Justiça de São Paulo</option>
                  <option value="TJRJ">TJRJ - Tribunal de Justiça do Rio de Janeiro</option>
                  <option value="TJMG">TJMG - Tribunal de Justiça de Minas Gerais</option>
                  <option value="TRT02">TRT02 - Tribunal Regional do Trabalho 2ª Região</option>
                  <option value="TRF03">TRF03 - Tribunal Regional Federal 3ª Região</option>
                  <option value="STJ">STJ - Superior Tribunal de Justiça</option>
                  <option value="STF">STF - Supremo Tribunal Federal</option>
                </select>
                {errors.tribunal && <p className="text-red-500 text-sm mt-1">{errors.tribunal}</p>}
              </div>

              {/* Tipo de Ação */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tipo de Ação *
                </label>
                <select
                  name="tipo_acao"
                  value={formData.tipo_acao}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.tipo_acao ? 'border-red-300' : 'border-gray-300'
                  }`}
                >
                  <option value="">Selecione o tipo de ação...</option>
                  <option value="Ação de Cobrança">Ação de Cobrança</option>
                  <option value="Ação de Indenização">Ação de Indenização</option>
                  <option value="Ação de Execução Fiscal">Ação de Execução Fiscal</option>
                  <option value="Reclamatória Trabalhista">Reclamatória Trabalhista</option>
                  <option value="Ação de Divórcio">Ação de Divórcio</option>
                  <option value="Ação de Inventário">Ação de Inventário</option>
                  <option value="Mandado de Segurança">Mandado de Segurança</option>
                  <option value="Ação Consignatória">Ação Consignatória</option>
                  <option value="Ação Anulatória">Ação Anulatória</option>
                  <option value="Embargos de Terceiro">Embargos de Terceiro</option>
                </select>
                {errors.tipo_acao && <p className="text-red-500 text-sm mt-1">{errors.tipo_acao}</p>}
              </div>

              {/* Data de Distribuição */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Data de Distribuição *
                </label>
                <input
                  type="date"
                  name="data_distribuicao"
                  value={formData.data_distribuicao}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.data_distribuicao ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
                {errors.data_distribuicao && <p className="text-red-500 text-sm mt-1">{errors.data_distribuicao}</p>}
              </div>
            </div>
          </div>
EOF

echo "4️⃣ Verificando se primeira parte foi criada..."

if [ -f "src/components/processes/EditProcess.js" ] && grep -q "Dados Básicos (Obrigatórios)" src/components/processes/EditProcess.js; then
    echo "✅ EditProcess.js - primeira parte criada com sucesso"
    echo "📊 Linhas atuais: $(wc -l < src/components/processes/EditProcess.js)"
else
    echo "❌ Erro ao criar primeira parte do EditProcess.js"
    exit 1
fi

echo ""
echo "✅ SCRIPT 128e - PRIMEIRA PARTE CONCLUÍDA!"
echo ""
echo "🔧 O que foi implementado:"
echo "   • Carregamento de dados do processo existente via API"
echo "   • Backup do arquivo original criado"
echo "   • TODOS os campos obrigatórios da tabela processos"
echo "   • Validações baseadas na estrutura real da tabela"
echo "   • Detecção de alterações não salvas"
echo "   • Estados de loading durante carregamento"
echo "   • Integração com processesService.getProcess()"
echo ""
echo "📋 CAMPOS OBRIGATÓRIOS IMPLEMENTADOS:"
echo "   ✅ numero (varchar(25) UNIQUE) - preenchido com dados existentes"
echo "   ✅ tribunal (varchar(255) NOT NULL) - dropdown pré-selecionado"
echo "   ✅ cliente_id (FK OBRIGATÓRIA) - carrega e pré-seleciona cliente"
echo "   ✅ tipo_acao (varchar(255) NOT NULL) - pré-selecionado"
echo "   ✅ data_distribuicao (date NOT NULL) - formato date"
echo "   ✅ advogado_id (FK OBRIGATÓRIA) - pré-selecionado"
echo ""
echo "⏳ AGUARDANDO CONFIRMAÇÃO:"
echo "Digite 'continuar' para implementar:"
echo "   • Campos opcionais (vara, valor_causa, prazo, observações)"
echo "   • Status e prioridade (enums) - pré-selecionados"
echo "   • Modal de confirmação de exclusão"
echo "   • Botões de ação (salvar, cancelar, excluir)"