#!/bin/bash

# Script 91f - EditTransacao Sistema Financeiro (Parte 2/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "💰 Completando EditTransacao - Parte 2/2 (formulários HTML)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Completando EditTransacao.js com formulários HTML..."

# Continuar o arquivo EditTransacao.js (parte 2 - formulários HTML)
cat >> frontend/src/components/financeiro/EditTransacao.js << 'EOF'

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
              <h1 className="text-3xl font-bold text-gray-900">Editar Transação</h1>
              <p className="text-lg text-gray-600 mt-2">
                ID: #{formData.id} - {formData.tipo} - {formData.descricao}
              </p>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <span className={`inline-flex items-center px-3 py-1 text-sm font-semibold rounded-full ${getStatusColor(formData.status)}`}>
              {formData.status}
            </span>
            <CurrencyDollarIcon className="w-12 h-12 text-primary-600" />
          </div>
        </div>
        
        {/* Ações Rápidas */}
        <div className="mt-6 flex space-x-4">
          {(formData.status === 'Pendente' || formData.status === 'Vencido') && (
            <button
              onClick={handleMarkPago}
              className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
            >
              <CheckCircleIcon className="w-5 h-5 mr-2" />
              Marcar como Pago
            </button>
          )}
          <button
            onClick={handleDelete}
            className="inline-flex items-center px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            <TrashIcon className="w-5 h-5 mr-2" />
            Excluir Transação
          </button>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Dados Básicos */}
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
                  {formData.tipoPessoa === 'Cliente' && mockClients.map((client) => (
                    <option key={client.id} value={client.id}>
                      {client.name} ({client.document})
                    </option>
                  ))}
                  {formData.tipoPessoa === 'Advogado' && mockAdvogados.map((advogado) => (
                    <option key={advogado.id} value={advogado.id}>
                      {advogado.name} ({advogado.oab})
                    </option>
                  ))}
                  {formData.tipoPessoa === 'Fornecedor' && mockFornecedores.map((fornecedor) => (
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
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Pagamento e Status</h2>
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
                'Salvar Alterações'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default EditTransacao;
EOF

echo "✅ EditTransacao.js completo criado!"

echo ""
echo "🎉 SCRIPT 91f CONCLUÍDO!"
echo ""
echo "✅ EDITTRANSACAO 100% COMPLETO:"
echo "   • Formulário completo de edição seguindo padrão EditAudiencia/EditPrazo"
echo "   • Header com informações da transação e status visual"
echo "   • Ações rápidas (Marcar como Pago, Excluir) no header"
echo "   • Seções organizadas: Dados Básicos, Pessoa Envolvida, Categoria, Pagamento"
echo "   • Preview da pessoa selecionada"
echo "   • Validações completas"
echo "   • Botões de ação (Salvar, Cancelar)"
echo ""
echo "💰 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Carregamento de dados existentes por ID (5 transações de teste)"
echo "   • Edição de todos os campos da transação"
echo "   • Tipo de pessoa OPCIONAL (Cliente, Advogado, Fornecedor, Nenhum)"
echo "   • Auto-seleção de gateway por forma de pagamento"
echo "   • Botão 'Marcar como Pago' que atualiza status e data"
echo "   • Botão 'Excluir' com confirmação"
echo "   • Categorias específicas por tipo (Receita/Despesa)"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. Acesse /admin/financeiro"
echo "   2. Clique no ícone de editar em qualquer transação"
echo "   3. URLs disponíveis para teste:"
echo "      • /admin/financeiro/1/editar (Receita - João Silva)"
echo "      • /admin/financeiro/2/editar (Receita - Empresa ABC)"
echo "      • /admin/financeiro/4/editar (Despesa - Salário)"
echo "      • /admin/financeiro/8/editar (Despesa - Conta Água)"
echo "      • /admin/financeiro/9/editar (Despesa - Aluguel)"
echo ""
echo "🔗 ROTA JÁ CONFIGURADA:"
echo "   ✅ App.js já tem: /admin/financeiro/:id/editar"
echo "   ✅ Import do EditTransacao já existe"
echo ""
echo "🎯 MÓDULO FINANCEIRO 100% FINALIZADO!"
echo ""
echo "✅ CRUD COMPLETO:"
echo "   ✅ Lista principal (Financeiro.js)"
echo "   ✅ Cadastro (NewTransacao.js)" 
echo "   ✅ Edição (EditTransacao.js)"
echo "   ✅ Exclusão (função na lista)"
echo ""
echo "⏭️ PRÓXIMO SCRIPT SUGERIDO (92a):"
echo "   • Sistema GED (Gestão Eletrônica de Documentos)"
echo "   • Dashboard de documentos por cliente"
echo "   • Upload de arquivos com drag-and-drop"
echo ""
echo "🎉 SISTEMA FINANCEIRO ERLENE COMPLETO!"
echo ""
echo "Digite 'continuar' para implementar o próximo módulo!"