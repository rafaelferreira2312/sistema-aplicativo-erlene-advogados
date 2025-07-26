import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  ArrowLeftIcon,
  CurrencyDollarIcon,
  CalendarIcon,
  UserIcon,
  ScaleIcon,
  BuildingOfficeIcon,
  DocumentTextIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  UsersIcon
} from '@heroicons/react/24/outline';

const NewTransacao = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [clients, setClients] = useState([]);
  const [processes, setProcesses] = useState([]);
  const [advogados, setAdvogados] = useState([]);
  const [fornecedores, setFornecedores] = useState([]);
  
  const [formData, setFormData] = useState({
    // Dados básicos
    tipo: '',
    descricao: '',
    valor: '',
    
    // Pessoa envolvida (OPCIONAL)
    tipoPessoa: '', // Cliente, Advogado, Fornecedor, Nenhum
    pessoaId: '',
    processoId: '',
    
    // Datas
    dataVencimento: '',
    dataPagamento: '',
    
    // Pagamento
    status: 'Pendente',
    formaPagamento: '',
    gateway: '',
    categoria: '',
    
    // Responsável
    responsavel: '',
    observacoes: '',
    
    // Configurações
    recorrente: false,
    notificar: false
  });

  const [errors, setErrors] = useState({});

  // Mock data expandido
  const mockClients = [
    { id: 1, name: 'João Silva Santos', type: 'PF', document: '123.456.789-00' },
    { id: 2, name: 'Empresa ABC Ltda', type: 'PJ', document: '12.345.678/0001-90' },
    { id: 3, name: 'Maria Oliveira Costa', type: 'PF', document: '987.654.321-00' }
  ];

  const mockProcesses = [
    { id: 1, number: '1001234-56.2024.8.26.0001', client: 'João Silva Santos', clientId: 1 },
    { id: 2, number: '2002345-67.2024.8.26.0002', client: 'Empresa ABC Ltda', clientId: 2 },
    { id: 3, number: '3003456-78.2024.8.26.0003', client: 'Maria Oliveira Costa', clientId: 3 }
  ];

  const mockAdvogados = [
    { id: 1, name: 'Dr. Carlos Oliveira', oab: 'OAB/SP 123456' },
    { id: 2, name: 'Dra. Maria Santos', oab: 'OAB/SP 234567' },
    { id: 3, name: 'Dra. Erlene Chaves Silva', oab: 'OAB/SP 567890' }
  ];

  const mockFornecedores = [
    { id: 1, name: 'Papelaria Central', cnpj: '11.111.111/0001-11', tipo: 'Material' },
    { id: 2, name: 'Elektro Distribuidora', cnpj: '22.222.222/0001-22', tipo: 'Energia' },
    { id: 3, name: 'Sabesp', cnpj: '33.333.333/0001-33', tipo: 'Água' },
    { id: 4, name: 'Imobiliária São Paulo', cnpj: '44.444.444/0001-44', tipo: 'Imóveis' }
  ];

  useEffect(() => {
    setTimeout(() => {
      setClients(mockClients);
      setProcesses(mockProcesses);
      setAdvogados(mockAdvogados);
      setFornecedores(mockFornecedores);
    }, 500);
  }, []);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }

    // Limpar pessoaId quando tipo de pessoa mudar
    if (name === 'tipoPessoa') {
      setFormData(prev => ({ ...prev, pessoaId: '', processoId: '' }));
    }

    // Auto-selecionar gateway baseado na forma de pagamento
    if (name === 'formaPagamento') {
      let gateway = '';
      if (value === 'PIX' || value === 'Boleto') {
        gateway = 'Mercado Pago';
      } else if (value === 'Cartão de Crédito' || value === 'Cartão de Débito') {
        gateway = 'Stripe';
      }
      setFormData(prev => ({ ...prev, gateway: gateway }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.tipo.trim()) newErrors.tipo = 'Tipo é obrigatório';
    if (!formData.descricao.trim()) newErrors.descricao = 'Descrição é obrigatória';
    if (!formData.valor || parseFloat(formData.valor) <= 0) newErrors.valor = 'Valor deve ser maior que zero';
    if (!formData.dataVencimento) newErrors.dataVencimento = 'Data de vencimento é obrigatória';
    if (!formData.formaPagamento.trim()) newErrors.formaPagamento = 'Forma de pagamento é obrigatória';
    if (!formData.categoria.trim()) newErrors.categoria = 'Categoria é obrigatória';
    if (!formData.responsavel.trim()) newErrors.responsavel = 'Responsável é obrigatório';
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;
    
    setLoading(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 1500));
      alert('Transação cadastrada com sucesso!');
      navigate('/admin/financeiro');
    } catch (error) {
      alert('Erro ao cadastrar transação');
    } finally {
      setLoading(false);
    }
  };

  // Obter pessoa selecionada baseada no tipo
  const getSelectedPerson = () => {
    if (!formData.tipoPessoa || !formData.pessoaId) return null;
    
    switch (formData.tipoPessoa) {
      case 'Cliente': return clients.find(c => c.id.toString() === formData.pessoaId);
      case 'Advogado': return advogados.find(a => a.id.toString() === formData.pessoaId);
      case 'Fornecedor': return fornecedores.find(f => f.id.toString() === formData.pessoaId);
      default: return null;
    }
  };

  const getAvailableProcesses = () => {
    if (formData.tipoPessoa === 'Cliente' && formData.pessoaId) {
      return processes.filter(p => p.clientId.toString() === formData.pessoaId);
    }
    return [];
  };

  const selectedPerson = getSelectedPerson();
  const availableProcesses = getAvailableProcesses();

  const tiposTransacao = ['Receita', 'Despesa'];
  const tiposPessoa = [
    { value: '', label: 'Nenhuma pessoa vinculada' },
    { value: 'Cliente', label: 'Cliente' },
    { value: 'Advogado', label: 'Advogado/Funcionário' },
    { value: 'Fornecedor', label: 'Fornecedor' }
  ];

  const formasPagamento = [
    'PIX', 'Cartão de Crédito', 'Cartão de Débito', 'Boleto', 
    'Transferência', 'Dinheiro', 'Cheque', 'Débito Automático'
  ];

  const categoriasReceita = [
    'Honorários Advocatícios', 'Honorários de Êxito', 'Consulta Jurídica',
    'Parecer Jurídico', 'Assessoria Jurídica', 'Comissões', 'Outros'
  ];

  const categoriasDespesa = [
    // Pessoal
    'Salários e Ordenados', 'Férias e 13º Salário', 'FGTS e INSS',
    'Vale Transporte', 'Vale Refeição', 'Plano de Saúde',
    // Operacionais  
    'Aluguel', 'Condomínio', 'Energia Elétrica', 'Água e Esgoto',
    'Telefone e Internet', 'Material de Escritório', 'Serviços de Limpeza',
    // Jurídicas
    'Custas Judiciais', 'Taxas Cartório', 'Despesas Processuais',
    // Tecnologia
    'Software e Licenças', 'Hardware e Equipamentos',
    // Outras
    'Impostos e Taxas', 'Viagens', 'Marketing', 'Outros'
  ];

  const responsaveis = [
    'Dr. Carlos Oliveira', 'Dra. Maria Santos', 'Dr. Pedro Costa',
    'Dra. Ana Silva', 'Dra. Erlene Chaves Silva', 'Administrativo', 'Financeiro'
  ];

  const gateways = ['Mercado Pago', 'Stripe', 'PagSeguro', 'PayPal', ''];

  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'Receita': return <ArrowUpIcon className="w-5 h-5 text-green-600" />;
      case 'Despesa': return <ArrowDownIcon className="w-5 h-5 text-red-600" />;
      default: return <CurrencyDollarIcon className="w-5 h-5" />;
    }
  };

  const getTipoPessoaIcon = (tipo) => {
    switch (tipo) {
      case 'Cliente': return <UserIcon className="w-4 h-4 text-primary-600" />;
      case 'Advogado': return <UsersIcon className="w-4 h-4 text-blue-600" />;
      case 'Fornecedor': return <BuildingOfficeIcon className="w-4 h-4 text-orange-600" />;
      default: return <UserIcon className="w-4 h-4 text-gray-600" />;
    }
  };

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/financeiro"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Nova Transação</h1>
              <p className="text-lg text-gray-600 mt-2">Receitas, despesas, salários, contas do escritório</p>
            </div>
          </div>
          <CurrencyDollarIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Tipo e Dados Básicos */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Dados Básicos</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Transação *
              </label>
              <select
                name="tipo"
                value={formData.tipo}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.tipo ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o tipo...</option>
                {tiposTransacao.map((tipo) => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
              {errors.tipo && <p className="text-red-500 text-sm mt-1">{errors.tipo}</p>}
              {formData.tipo && (
                <div className="mt-2 flex items-center text-sm text-gray-600">
                  {getTipoIcon(formData.tipo)}
                  <span className="ml-2">
                    {formData.tipo === 'Receita' ? 'Entrada de dinheiro' : 'Saída de dinheiro'}
                  </span>
                </div>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Valor *</label>
              <div className="relative">
                <CurrencyDollarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="number"
                  name="valor"
                  value={formData.valor}
                  onChange={handleChange}
                  step="0.01"
                  min="0"
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.valor ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="0,00"
                />
              </div>
              {errors.valor && <p className="text-red-500 text-sm mt-1">{errors.valor}</p>}
              {formData.valor && (
                <p className="text-sm text-gray-600 mt-1">
                  R$ {parseFloat(formData.valor || 0).toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                </p>
              )}
            </div>
            
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">Descrição *</label>
              <input
                type="text"
                name="descricao"
                value={formData.descricao}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.descricao ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="Ex: Salário Julho/2024, Conta de Luz, Honorários - Divórcio"
              />
              {errors.descricao && <p className="text-red-500 text-sm mt-1">{errors.descricao}</p>}
            </div>
          </div>
        </div>

        {/* Pessoa Envolvida (Opcional) */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Pessoa Envolvida (Opcional)</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Tipo de Pessoa</label>
              <select
                name="tipoPessoa"
                value={formData.tipoPessoa}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                {tiposPessoa.map((tipo) => (
                  <option key={tipo.value} value={tipo.value}>{tipo.label}</option>
                ))}
              </select>
              <p className="text-xs text-gray-500 mt-1">
                Para contas como água, luz, pode deixar sem pessoa vinculada
              </p>
            </div>

            {formData.tipoPessoa && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Selecionar {formData.tipoPessoa}
                </label>
                <select
                  name="pessoaId"
                  value={formData.pessoaId}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="">Selecione...</option>
                  {formData.tipoPessoa === 'Cliente' && clients.map((client) => (
                    <option key={client.id} value={client.id}>
                      {client.name} ({client.document})
                    </option>
                  ))}
                  {formData.tipoPessoa === 'Advogado' && advogados.map((advogado) => (
                    <option key={advogado.id} value={advogado.id}>
                      {advogado.name} ({advogado.oab})
                    </option>
                  ))}
                  {formData.tipoPessoa === 'Fornecedor' && fornecedores.map((fornecedor) => (
                    <option key={fornecedor.id} value={fornecedor.id}>
                      {fornecedor.name} - {fornecedor.tipo}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Processo (só para Cliente) */}
            {formData.tipoPessoa === 'Cliente' && availableProcesses.length > 0 && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">Processo (opcional)</label>
                <select
                  name="processoId"
                  value={formData.processoId}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="">Selecione o processo...</option>
                  {availableProcesses.map((process) => (
                    <option key={process.id} value={process.id}>
                      {process.number}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Preview da Pessoa Selecionada */}
            {selectedPerson && (
              <div className="md:col-span-2 bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-3">Selecionado:</h3>
                <div className="flex items-center">
                  {getTipoPessoaIcon(formData.tipoPessoa)}
                  <div className="ml-3">
                    <div className="font-medium text-gray-900">{selectedPerson.name}</div>
                    <div className="text-sm text-gray-500">
                      {selectedPerson.document || selectedPerson.oab || selectedPerson.cnpj || ''}
                      {selectedPerson.tipo && ` - ${selectedPerson.tipo}`}
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Categoria e Datas */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Categoria e Datas</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Categoria *</label>
              <select
                name="categoria"
                value={formData.categoria}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.categoria ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione a categoria...</option>
                {formData.tipo === 'Receita' 
                  ? categoriasReceita.map((cat) => (
                      <option key={cat} value={cat}>{cat}</option>
                    ))
                  : categoriasDespesa.map((cat) => (
                      <option key={cat} value={cat}>{cat}</option>
                    ))
                }
              </select>
              {errors.categoria && <p className="text-red-500 text-sm mt-1">{errors.categoria}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Data de Vencimento *</label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="dataVencimento"
                  value={formData.dataVencimento}
                  onChange={handleChange}
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.dataVencimento ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
              </div>
              {errors.dataVencimento && <p className="text-red-500 text-sm mt-1">{errors.dataVencimento}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Data de Pagamento</label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="dataPagamento"
                  value={formData.dataPagamento}
                  onChange={handleChange}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">Deixe vazio se ainda não foi pago</p>
            </div>
          </div>
        </div>

        {/* Forma de Pagamento e Status */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Pagamento</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Forma de Pagamento *</label>
              <select
                name="formaPagamento"
                value={formData.formaPagamento}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.formaPagamento ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione a forma...</option>
                {formasPagamento.map((forma) => (
                  <option key={forma} value={forma}>{forma}</option>
                ))}
              </select>
              {errors.formaPagamento && <p className="text-red-500 text-sm mt-1">{errors.formaPagamento}</p>}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Gateway</label>
              <select
                name="gateway"
                value={formData.gateway}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Selecione o gateway...</option>
                {gateways.map((gateway) => (
                  <option key={gateway} value={gateway}>{gateway || 'Sem gateway'}</option>
                ))}
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <select
                name="status"
                value={formData.status}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Pendente">Pendente</option>
                <option value="Pago">Pago</option>
                <option value="Vencido">Vencido</option>
                <option value="Cancelado">Cancelado</option>
              </select>
            </div>
          </div>
        </div>

        {/* Responsável e Observações */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Responsável e Observações</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Responsável *</label>
              <select
                name="responsavel"
                value={formData.responsavel}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.responsavel ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione o responsável...</option>
                {responsaveis.map((responsavel) => (
                  <option key={responsavel} value={responsavel}>{responsavel}</option>
                ))}
              </select>
              {errors.responsavel && <p className="text-red-500 text-sm mt-1">{errors.responsavel}</p>}
            </div>
            
            <div className="space-y-4">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  name="recorrente"
                  checked={formData.recorrente}
                  onChange={handleChange}
                  className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                />
                <span className="ml-3 text-sm font-medium text-gray-700">
                  Transação recorrente (mensal)
                </span>
              </label>
              
              <label className="flex items-center">
                <input
                  type="checkbox"
                  name="notificar"
                  checked={formData.notificar}
                  onChange={handleChange}
                  className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                />
                <span className="ml-3 text-sm font-medium text-gray-700">
                  Enviar notificação de vencimento
                </span>
              </label>
            </div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Observações</label>
            <div className="relative">
              <DocumentTextIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
              <textarea
                name="observacoes"
                value={formData.observacoes}
                onChange={handleChange}
                rows={4}
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Observações sobre a transação..."
              />
            </div>
          </div>
        </div>

        {/* Botões */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/financeiro"
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
            >
              Cancelar
            </Link>
            <button
              type="submit"
              disabled={loading}
              className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Salvando...
                </div>
              ) : (
                'Cadastrar Transação'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewTransacao;
