#!/bin/bash

# Script 128d - Completar campos opcionais NewProcess.js
# Sistema Erlene Advogados - Campos opcionais, enums e botões finais
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 128d - Completando campos opcionais do NewProcess.js..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 128d-complete-newprocess-fields.sh && ./128d-complete-newprocess-fields.sh"
    exit 1
fi

echo "1️⃣ Verificando se primeira parte foi executada..."

# Verificar se arquivo existe e tem estrutura esperada
if [ ! -f "src/components/processes/NewProcess.js" ] || ! grep -q "Dados Básicos (Obrigatórios)" src/components/processes/NewProcess.js; then
    echo "❌ Erro: Execute primeiro o script 128c-complete-newprocess.sh"
    exit 1
fi

echo "2️⃣ Completando NewProcess.js com campos opcionais e botões..."

# Continuar adicionando ao arquivo existente
cat >> src/components/processes/NewProcess.js << 'EOF'

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

        {/* Resumo do Processo */}
        {(formData.numero || formData.cliente_id || formData.advogado_id) && (
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-6">
            <h3 className="text-lg font-semibold text-blue-900 mb-4">Resumo do Processo</h3>
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
                <div className="text-sm font-medium text-blue-700">Status:</div>
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
              {formData.data_distribuicao && (
                <div>
                  <div className="text-sm font-medium text-blue-700">Data de Distribuição:</div>
                  <div className="text-blue-900">{new Date(formData.data_distribuicao).toLocaleDateString('pt-BR')}</div>
                </div>
              )}
            </div>
          </div>
        )}

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
              <DocumentTextIcon className="w-4 h-4 mr-2" />
              Validar Dados
            </button>
            
            <button
              type="submit"
              disabled={loading}
              className="inline-flex items-center justify-center px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Criando Processo...
                </>
              ) : (
                <>
                  <ScaleIcon className="w-4 h-4 mr-2" />
                  Criar Processo
                </>
              )}
            </button>
          </div>
          
          {/* Informações de ajuda */}
          <div className="mt-6 p-4 bg-gray-50 rounded-lg">
            <h4 className="text-sm font-medium text-gray-900 mb-2">Dicas para Cadastro:</h4>
            <ul className="text-xs text-gray-600 space-y-1">
              <li>• Campos marcados com * são obrigatórios</li>
              <li>• O número do processo deve seguir o padrão CNJ</li>
              <li>• Certifique-se de selecionar o cliente e advogado corretos</li>
              <li>• O valor da causa é formatado automaticamente em moeda brasileira</li>
              <li>• Use o botão "Validar Dados" para verificar se está tudo correto</li>
            </ul>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewProcess;
EOF

echo "3️⃣ Verificando se arquivo foi completado..."

# Verificar se arquivo tem estrutura completa
if grep -q "export default NewProcess" src/components/processes/NewProcess.js && grep -q "Criar Processo" src/components/processes/NewProcess.js; then
    echo "✅ NewProcess.js completo e funcional"
    echo "📊 Linhas totais: $(wc -l < src/components/processes/NewProcess.js)"
else
    echo "❌ Arquivo NewProcess.js incompleto"
    exit 1
fi

echo "4️⃣ Verificando se todos os campos da tabela foram implementados..."

# Verificar campos obrigatórios
if grep -q 'name="numero"' src/components/processes/NewProcess.js && \
   grep -q 'name="tribunal"' src/components/processes/NewProcess.js && \
   grep -q 'name="cliente_id"' src/components/processes/NewProcess.js && \
   grep -q 'name="tipo_acao"' src/components/processes/NewProcess.js && \
   grep -q 'name="data_distribuicao"' src/components/processes/NewProcess.js && \
   grep -q 'name="advogado_id"' src/components/processes/NewProcess.js; then
    echo "✅ Todos os campos obrigatórios implementados"
else
    echo "❌ Campos obrigatórios faltando"
    exit 1
fi

# Verificar campos opcionais
if grep -q 'name="vara"' src/components/processes/NewProcess.js && \
   grep -q 'name="valor_causa"' src/components/processes/NewProcess.js && \
   grep -q 'name="proximo_prazo"' src/components/processes/NewProcess.js && \
   grep -q 'name="observacoes"' src/components/processes/NewProcess.js; then
    echo "✅ Todos os campos opcionais implementados"
else
    echo "❌ Campos opcionais faltando"
    exit 1
fi

echo ""
echo "✅ SCRIPT 128d CONCLUÍDO COM SUCESSO!"
echo ""
echo "🔧 TODOS OS CAMPOS DA TABELA PROCESSOS IMPLEMENTADOS:"
echo ""
echo "📋 CAMPOS OBRIGATÓRIOS (NOT NULL):"
echo "   ✅ numero - varchar(25) UNIQUE"
echo "   ✅ tribunal - varchar(255) NOT NULL" 
echo "   ✅ cliente_id - FK OBRIGATÓRIA"
echo "   ✅ tipo_acao - varchar(255) NOT NULL"
echo "   ✅ data_distribuicao - date NOT NULL"
echo "   ✅ advogado_id - FK OBRIGATÓRIA"
echo ""
echo "📋 CAMPOS OPCIONAIS (NULL permitido):"
echo "   ✅ vara - varchar(255) NULL"
echo "   ✅ valor_causa - decimal(15,2) NULL"
echo "   ✅ proximo_prazo - date NULL"
echo "   ✅ observacoes - text NULL"
echo ""
echo "📋 ENUMS COM DEFAULTS:"
echo "   ✅ status - enum DEFAULT 'distribuido'"
echo "   ✅ prioridade - enum DEFAULT 'media'"
echo ""
echo "🎯 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   ✅ Validações baseadas na estrutura da tabela"
echo "   ✅ Formatação automática de moeda"
echo "   ✅ Preview do cliente e advogado selecionados"
echo "   ✅ Resumo visual do processo"
echo "   ✅ Botão de validação de dados"
echo "   ✅ Estados de loading durante envio"
echo "   ✅ Integração com processesService e clientsService"
echo "   ✅ Tratamento de erros da API"
echo ""
echo "⏳ PRÓXIMO PASSO:"
echo "Digite 'continuar' para criar o EditProcess.js com a mesma estrutura"