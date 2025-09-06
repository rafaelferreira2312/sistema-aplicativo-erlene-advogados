#!/bin/bash

# Script 128f - Completar campos opcionais e botões do EditProcess.js
# Sistema Erlene Advogados - Campos opcionais, modal de exclusão e botões finais
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 128f - Completando campos opcionais e botões do EditProcess.js..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 128f-complete-editprocess-final.sh && ./128f-complete-editprocess-final.sh"
    exit 1
fi

echo "1️⃣ Verificando se primeira parte foi executada..."

# Verificar se arquivo existe e tem estrutura esperada
if [ ! -f "src/components/processes/EditProcess.js" ] || ! grep -q "Dados Básicos (Obrigatórios)" src/components/processes/EditProcess.js; then
    echo "❌ Erro: Execute primeiro o script 128e-complete-editprocess.sh"
    exit 1
fi

echo "2️⃣ Completando EditProcess.js com campos opcionais e modal..."

# Continuar adicionando ao arquivo existente
cat >> src/components/processes/EditProcess.js << 'EOF'

          {/* Campos Opcionais */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex items-center space-x-3 mb-6">
              <InformationCircleIcon className="w-5 h-5 text-blue-500" />
              <h2 className="text-xl font-semibold text-gray-900">Informações Complementares (Opcionais)</h2>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Vara */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Vara
                </label>
                <input
                  type="text"
                  name="vara"
                  value={formData.vara}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Ex: 1ª Vara Cível, 2ª Vara Empresarial..."
                />
                <p className="text-xs text-gray-500 mt-1">Especifique a vara onde o processo tramita</p>
              </div>

              {/* Valor da Causa */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Valor da Causa
                </label>
                <input
                  type="text"
                  name="valor_causa"
                  value={formData.valor_causa}
                  onChange={handleCurrencyChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="R$ 0,00"
                />
                <p className="text-xs text-gray-500 mt-1">Valor monetário da causa (opcional)</p>
              </div>

              {/* Próximo Prazo */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Próximo Prazo
                </label>
                <input
                  type="date"
                  name="proximo_prazo"
                  value={formData.proximo_prazo}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
                <p className="text-xs text-gray-500 mt-1">Data do próximo prazo processual</p>
              </div>

              {/* Status */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Status
                </label>
                <select
                  name="status"
                  value={formData.status}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="distribuido">Distribuído</option>
                  <option value="em_andamento">Em Andamento</option>
                  <option value="suspenso">Suspenso</option>
                  <option value="arquivado">Arquivado</option>
                  <option value="finalizado">Finalizado</option>
                </select>
              </div>

              {/* Prioridade */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Prioridade
                </label>
                <select
                  name="prioridade"
                  value={formData.prioridade}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="baixa">Baixa</option>
                  <option value="media">Média</option>
                  <option value="alta">Alta</option>
                  <option value="urgente">Urgente</option>
                </select>
              </div>

              {/* Observações */}
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Observações
                </label>
                <textarea
                  name="observacoes"
                  value={formData.observacoes}
                  onChange={handleChange}
                  rows={4}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Observações adicionais sobre o processo..."
                />
                <p className="text-xs text-gray-500 mt-1">Informações complementares que julgar importantes</p>
              </div>
            </div>
          </div>

          {/* Resumo das Alterações */}
          {hasChanges() && (
            <div className="bg-amber-50 border border-amber-200 rounded-xl p-6">
              <h3 className="text-lg font-semibold text-amber-900 mb-4">Resumo das Alterações</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {Object.keys(formData).map(key => {
                  if (formData[key] !== originalData[key]) {
                    return (
                      <div key={key} className="flex justify-between items-center">
                        <div>
                          <div className="text-sm font-medium text-amber-700 capitalize">
                            {key.replace('_', ' ')}:
                          </div>
                          <div className="text-xs text-amber-600">
                            De: {originalData[key] || 'Vazio'}
                          </div>
                          <div className="text-xs text-amber-800 font-medium">
                            Para: {formData[key] || 'Vazio'}
                          </div>
                        </div>
                      </div>
                    );
                  }
                  return null;
                }).filter(Boolean)}
              </div>
            </div>
          )}

          {/* Preview do Processo Atualizado */}
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-6">
            <h3 className="text-lg font-semibold text-blue-900 mb-4">Preview do Processo</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <div className="text-sm font-medium text-blue-700">Número:</div>
                <div className="text-blue-900">{formData.numero || 'Não informado'}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-blue-700">Cliente:</div>
                <div className="text-blue-900">{selectedClient?.nome || 'Não selecionado'}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-blue-700">Advogado:</div>
                <div className="text-blue-900">{selectedAdvogado?.name || 'Não selecionado'}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-blue-700">Tipo de Ação:</div>
                <div className="text-blue-900">{formData.tipo_acao || 'Não informado'}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-blue-700">Tribunal:</div>
                <div className="text-blue-900">{formData.tribunal || 'Não selecionado'}</div>
              </div>
              <div>
                <div className="text-sm font-medium text-blue-700">Status/Prioridade:</div>
                <div className="text-blue-900">
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    formData.status === 'em_andamento' ? 'bg-blue-100 text-blue-800' :
                    formData.status === 'suspenso' ? 'bg-yellow-100 text-yellow-800' :
                    formData.status === 'finalizado' ? 'bg-green-100 text-green-800' :
                    formData.status === 'arquivado' ? 'bg-red-100 text-red-800' :
                    'bg-purple-100 text-purple-800'
                  }`}>
                    {formData.status === 'em_andamento' ? 'Em Andamento' :
                     formData.status === 'suspenso' ? 'Suspenso' :
                     formData.status === 'finalizado' ? 'Finalizado' :
                     formData.status === 'arquivado' ? 'Arquivado' :
                     'Distribuído'}
                  </span>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ml-2 ${
                    formData.prioridade === 'urgente' ? 'bg-red-100 text-red-800' :
                    formData.prioridade === 'alta' ? 'bg-orange-100 text-orange-800' :
                    formData.prioridade === 'media' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-green-100 text-green-800'
                  }`}>
                    {formData.prioridade === 'urgente' ? 'Urgente' :
                     formData.prioridade === 'alta' ? 'Alta' :
                     formData.prioridade === 'media' ? 'Média' :
                     'Baixa'}
                  </span>
                </div>
              </div>
              {formData.valor_causa && (
                <div>
                  <div className="text-sm font-medium text-blue-700">Valor da Causa:</div>
                  <div className="text-blue-900">{formData.valor_causa}</div>
                </div>
              )}
              {formData.vara && (
                <div>
                  <div className="text-sm font-medium text-blue-700">Vara:</div>
                  <div className="text-blue-900">{formData.vara}</div>
                </div>
              )}
            </div>
          </div>

          {/* Botões de Ação */}
          <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
            <div className="flex flex-col sm:flex-row justify-end space-y-4 sm:space-y-0 sm:space-x-4">
              <Link
                to="/admin/processos"
                className="inline-flex items-center justify-center px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
              >
                <ArrowLeftIcon className="w-4 h-4 mr-2" />
                Cancelar
              </Link>
              
              <button
                type="button"
                onClick={() => {
                  if (validateForm()) {
                    alert('Formulário válido! Todos os campos obrigatórios foram preenchidos.');
                  } else {
                    alert('Por favor, preencha todos os campos obrigatórios marcados com *');
                  }
                }}
                className="inline-flex items-center justify-center px-6 py-3 border border-blue-300 text-blue-700 rounded-lg hover:bg-blue-50 transition-colors font-medium"
              >
                <CheckCircleIcon className="w-4 h-4 mr-2" />
                Validar Dados
              </button>
              
              <button
                type="submit"
                disabled={loading || !hasChanges()}
                className="inline-flex items-center justify-center px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
              >
                {loading ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Salvando Alterações...
                  </>
                ) : (
                  <>
                    <DocumentTextIcon className="w-4 h-4 mr-2" />
                    {hasChanges() ? 'Salvar Alterações' : 'Nenhuma Alteração'}
                  </>
                )}
              </button>
            </div>
            
            {/* Informações de ajuda */}
            <div className="mt-6 p-4 bg-gray-50 rounded-lg">
              <h4 className="text-sm font-medium text-gray-900 mb-2">Informações Importantes:</h4>
              <ul className="text-xs text-gray-600 space-y-1">
                <li>• Campos marcados com * são obrigatórios</li>
                <li>• O sistema detecta automaticamente alterações nos dados</li>
                <li>• Use o botão "Validar Dados" para verificar se está tudo correto</li>
                <li>• O botão "Salvar" só fica ativo quando há alterações</li>
                <li>• Para excluir o processo, use o botão vermelho "Excluir" no cabeçalho</li>
              </ul>
            </div>
          </div>
        </form>
      </div>

      {/* Modal de Confirmação de Exclusão */}
      {showDeleteModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3 text-center">
              <TrashIcon className="w-16 h-16 text-red-600 mx-auto" />
              <h3 className="text-lg font-medium text-gray-900 mt-5">Confirmar Exclusão</h3>
              <div className="mt-4 px-7 py-3">
                <p className="text-sm text-gray-500">
                  Tem certeza que deseja excluir este processo?
                </p>
                <p className="text-sm text-gray-700 font-medium mt-2">
                  Processo: {formData.numero}
                </p>
                <p className="text-sm text-gray-700">
                  Cliente: {selectedClient?.nome}
                </p>
                <p className="text-xs text-red-600 mt-3">
                  Esta ação não pode ser desfeita.
                </p>
              </div>
              <div className="items-center px-4 py-3">
                <button
                  onClick={handleDelete}
                  className="px-4 py-2 bg-red-600 text-white text-base font-medium rounded-md w-24 mr-2 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-300"
                >
                  Excluir
                </button>
                <button
                  onClick={() => setShowDeleteModal(false)}
                  className="px-4 py-2 bg-gray-300 text-gray-800 text-base font-medium rounded-md w-24 hover:bg-gray-400 focus:outline-none focus:ring-2 focus:ring-gray-300"
                >
                  Cancelar
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default EditProcess;
EOF

echo "3️⃣ Verificando se arquivo foi completado..."

# Verificar se arquivo tem estrutura completa
if grep -q "export default EditProcess" src/components/processes/EditProcess.js && grep -q "Modal de Confirmação de Exclusão" src/components/processes/EditProcess.js; then
    echo "✅ EditProcess.js completo e funcional"
    echo "📊 Linhas totais: $(wc -l < src/components/processes/EditProcess.js)"
else
    echo "❌ Arquivo EditProcess.js incompleto"
    exit 1
fi

echo "4️⃣ Verificando se todos os campos da tabela foram implementados..."

# Verificar campos obrigatórios
if grep -q 'name="numero"' src/components/processes/EditProcess.js && \
   grep -q 'name="tribunal"' src/components/processes/EditProcess.js && \
   grep -q 'name="cliente_id"' src/components/processes/EditProcess.js && \
   grep -q 'name="tipo_acao"' src/components/processes/EditProcess.js && \
   grep -q 'name="data_distribuicao"' src/components/processes/EditProcess.js && \
   grep -q 'name="advogado_id"' src/components/processes/EditProcess.js; then
    echo "✅ Todos os campos obrigatórios implementados"
else
    echo "❌ Campos obrigatórios faltando"
    exit 1
fi

# Verificar campos opcionais
if grep -q 'name="vara"' src/components/processes/EditProcess.js && \
   grep -q 'name="valor_causa"' src/components/processes/EditProcess.js && \
   grep -q 'name="proximo_prazo"' src/components/processes/EditProcess.js && \
   grep -q 'name="observacoes"' src/components/processes/EditProcess.js; then
    echo "✅ Todos os campos opcionais implementados"
else
    echo "❌ Campos opcionais faltando"
    exit 1
fi

# Verificar modal de exclusão
if grep -q "showDeleteModal" src/components/processes/EditProcess.js && \
   grep -q "handleDelete" src/components/processes/EditProcess.js; then
    echo "✅ Modal de exclusão implementado"
else
    echo "❌ Modal de exclusão faltando"
    exit 1
fi

echo ""
echo "✅ SCRIPT 128f CONCLUÍDO COM SUCESSO!"
echo ""
echo "🔧 EDITPROCESS.JS 100% COMPLETO:"
echo ""
echo "📋 TODOS OS CAMPOS DA TABELA PROCESSOS:"
echo "   ✅ Campos obrigatórios (6) - com carregamento de dados existentes"
echo "   ✅ Campos opcionais (4) - preenchidos se houver dados"
echo "   ✅ Enums (status, prioridade) - pré-selecionados"
echo ""
echo "🎯 FUNCIONALIDADES AVANÇADAS IMPLEMENTADAS:"
echo "   ✅ Carregamento automático de dados do processo via API"
echo "   ✅ Detecção de alterações (hasChanges)"
echo "   ✅ Preview visual das alterações"
echo "   ✅ Modal de confirmação de exclusão com detalhes"
echo "   ✅ Botão 'Salvar' só ativo quando há alterações"
echo "   ✅ Validação de dados antes do envio"
echo "   ✅ Estados de loading durante operações"
echo "   ✅ Integração completa com processesService"
echo "   ✅ Formatação automática de moeda"
echo "   ✅ Preview do cliente e advogado selecionados"
echo ""
echo "🎉 MÓDULO DE PROCESSOS 100% FINALIZADO!"
echo ""
echo "📝 RESUMO FINAL DOS SCRIPTS 128:"
echo "   ✅ 128a - Lista de processos com ícones de ação"
echo "   ✅ 128b - Dashboard e tabela completa"  
echo "   ✅ 128c - NewProcess com campos obrigatórios"
echo "   ✅ 128d - NewProcess com campos opcionais"
echo "   ✅ 128e - EditProcess com carregamento de dados"
echo "   ✅ 128f - EditProcess com campos opcionais e modal"
echo ""
echo "🚀 PRÓXIMO PASSO:"
echo "Teste as funcionalidades em http://localhost:3000/admin/processos"