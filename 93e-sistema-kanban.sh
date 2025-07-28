#!/bin/bash

# Script 94b - NewTask Padrão Erlene (Parte 2/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)
# Enumeração: 94b

echo "📋 Completando NewTask Padrão Erlene (Parte 2/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Completando NewTask.js com formulários restantes..."

# Continuar o arquivo NewTask.js (parte 2 - seções restantes)
cat >> frontend/src/components/kanban/NewTask.js << 'EOF'

        {/* Cliente e Processo (Opcional) seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Cliente e Processo (Opcional)</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Cliente</label>
              <select
                name="clienteId"
                value={formData.clienteId}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Selecione o cliente...</option>
                {clients.map((client) => (
                  <option key={client.id} value={client.id}>
                    {client.name} ({client.type})
                  </option>
                ))}
              </select>
              <p className="text-xs text-gray-500 mt-1">
                Para tarefas gerais pode deixar sem cliente
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Processo</label>
              <select
                name="processoId"
                value={formData.processoId}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                disabled={!formData.clienteId}
              >
                <option value="">Selecione o processo...</option>
                {availableProcesses.map((process) => (
                  <option key={process.id} value={process.id}>
                    {process.number}
                  </option>
                ))}
              </select>
              {formData.clienteId && availableProcesses.length === 0 && (
                <p className="text-sm text-gray-500 mt-1">Nenhum processo encontrado para este cliente</p>
              )}
              {!formData.clienteId && (
                <p className="text-xs text-gray-500 mt-1">Selecione um cliente primeiro</p>
              )}
            </div>

            {/* Preview do relacionamento */}
            {formData.clienteId && (
              <div className="md:col-span-2 bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-2">Relacionamento:</h3>
                <div className="flex items-center">
                  <UserIcon className="w-4 h-4 text-primary-600 mr-2" />
                  <span className="text-sm text-gray-900">
                    {clients.find(c => c.id.toString() === formData.clienteId)?.name}
                  </span>
                  {formData.processoId && (
                    <>
                      <ScaleIcon className="w-4 h-4 text-blue-600 mx-2" />
                      <span className="text-sm text-blue-600">
                        {availableProcesses.find(p => p.id.toString() === formData.processoId)?.number}
                      </span>
                    </>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Configurações seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Configurações</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Prioridade</label>
              <select
                name="prioridade"
                value={formData.prioridade}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="Baixa">Baixa</option>
                <option value="Média">Média</option>
                <option value="Alta">Alta</option>
              </select>
              <div className={`text-sm mt-2 flex items-center ${getPrioridadeColor(formData.prioridade)}`}>
                {getPrioridadeIcon(formData.prioridade)}
                <span className="ml-1">Prioridade: {formData.prioridade}</span>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Data de Vencimento *
              </label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="dataVencimento"
                  value={formData.dataVencimento}
                  onChange={handleChange}
                  min={new Date().toISOString().split('T')[0]}
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.dataVencimento ? 'border-red-300' : 'border-gray-300'
                  }`}
                />
              </div>
              {errors.dataVencimento && <p className="text-red-500 text-sm mt-1">{errors.dataVencimento}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Estimativa (horas)
              </label>
              <div className="relative">
                <ClockIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="number"
                  name="estimativaHoras"
                  value={formData.estimativaHoras}
                  onChange={handleChange}
                  min="0"
                  step="0.5"
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="Ex: 4"
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">
                Tempo estimado para conclusão
              </p>
            </div>
          </div>
        </div>

        {/* Tags seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Tags</h2>
          
          <div className="mb-4">
            <div className="flex space-x-2">
              <input
                type="text"
                name="novaTag"
                value={formData.novaTag}
                onChange={handleChange}
                onKeyPress={handleKeyPress}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Digite uma tag e pressione Enter"
              />
              <button
                type="button"
                onClick={addTag}
                className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <TagIcon className="w-5 h-5" />
              </button>
            </div>
            <p className="text-xs text-gray-500 mt-1">
              Tags ajudam na organização e busca das tarefas
            </p>
          </div>
          
          {/* Tags adicionadas */}
          {formData.tags.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {formData.tags.map((tag, index) => (
                <span key={index} className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-primary-100 text-primary-800">
                  {tag}
                  <button
                    type="button"
                    onClick={() => removeTag(tag)}
                    className="ml-2 text-primary-600 hover:text-primary-800"
                  >
                    ×
                  </button>
                </span>
              ))}
            </div>
          )}

          {/* Sugestões de tags */}
          <div className="mt-4">
            <p className="text-sm font-medium text-gray-700 mb-2">Sugestões:</p>
            <div className="flex flex-wrap gap-2">
              {['urgente', 'petição', 'contrato', 'audiência', 'prazo', 'análise'].map((suggestedTag) => (
                <button
                  key={suggestedTag}
                  type="button"
                  onClick={() => {
                    if (!formData.tags.includes(suggestedTag)) {
                      setFormData(prev => ({
                        ...prev,
                        tags: [...prev.tags, suggestedTag]
                      }));
                    }
                  }}
                  className="px-3 py-1 text-xs bg-gray-100 text-gray-700 rounded-full hover:bg-gray-200 transition-colors"
                  disabled={formData.tags.includes(suggestedTag)}
                >
                  + {suggestedTag}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Botões seguindo EXATO padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/kanban"
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
                  Criando...
                </div>
              ) : (
                'Criar Tarefa'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewTask;
EOF

echo "✅ NewTask.js completo criado!"

echo "📝 2. Atualizando App.js para incluir rota de nova tarefa..."

# Fazer backup do App.js se necessário
if ! grep -q "NewTask" frontend/src/App.js; then
    cp frontend/src/App.js frontend/src/App.js.backup.newtask.$(date +%Y%m%d_%H%M%S)
    
    # Adicionar import do NewTask se não existir
    sed -i '/import EditDocumento/a import NewTask from '\''./components/kanban/NewTask'\'';' frontend/src/App.js
    
    # Adicionar rota de nova tarefa se não existir
    sed -i '/path="kanban"/a\                    <Route path="kanban/nova" element={<NewTask />} />' frontend/src/App.js
    
    echo "✅ Rota /admin/kanban/nova adicionada ao App.js"
else
    echo "✅ Rota já existe no App.js"
fi

echo "📝 3. Verificando estrutura de pastas..."

# Verificar se todas as pastas existem
mkdir -p frontend/src/pages/admin
mkdir -p frontend/src/components/kanban

echo "✅ Estrutura de pastas verificada!"

echo ""
echo "🎉 SCRIPT 94b CONCLUÍDO!"
echo ""
echo "✅ NEWTASK.JS 100% FUNCIONAL:"
echo "   • Formulário completo seguindo EXATO padrão Erlene"
echo "   • 4 seções organizadas: Básicas, Cliente/Processo, Configurações, Tags"
echo "   • Relacionamentos opcionais com clientes e processos"
echo "   • Sistema de tags dinâmico com sugestões"
echo "   • Validações completas e estados de erro"
echo "   • Botões de ação seguindo padrão do projeto"
echo ""
echo "📋 FUNCIONALIDADES COMPLETAS:"
echo "   • Título e descrição (obrigatórios)"
echo "   • Advogado responsável (obrigatório)"
echo "   • Coluna inicial (A Fazer padrão)"
echo "   • Cliente e processo (opcionais)"
echo "   • Prioridade com ícones visuais"
echo "   • Data de vencimento (obrigatória)"
echo "   • Estimativa de horas (opcional)"
echo "   • Sistema de tags com sugestões"
echo ""
echo "🎯 RELACIONAMENTOS IMPLEMENTADOS:"
echo "   • Cliente → Filtra processos disponíveis"
echo "   • Processo → Vinculado ao cliente selecionado"
echo "   • Preview visual do relacionamento"
echo "   • Validação de dependências"
echo ""
echo "🏷️ SISTEMA DE TAGS:"
echo "   • Adição manual (digitação + Enter)"
echo "   • Botão de adicionar"
echo "   • Remoção individual (botão ×)"
echo "   • Sugestões pré-definidas"
echo "   • Prevenção de duplicatas"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "   • /admin/kanban/nova - Nova tarefa ✅"
echo "   • Botão voltar → /admin/kanban ✅"
echo "   • Import e rota no App.js ✅"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. http://localhost:3000/admin/kanban"
echo "   2. Clique em 'Nova Tarefa'"
echo "   3. http://localhost:3000/admin/kanban/nova"
echo "   4. Teste preenchimento dos campos"
echo "   5. Teste relacionamento cliente → processo"
echo "   6. Teste sistema de tags"
echo "   7. Teste validações (deixar campos obrigatórios vazios)"
echo ""
echo "📁 ARQUIVOS CRIADOS/ATUALIZADOS:"
echo "   • frontend/src/components/kanban/NewTask.js (completo)"
echo "   • App.js com import e rota"
echo ""
echo "🎯 PADRÃO MANTIDO 100%:"
echo "   ✅ Header idêntico a NewAudiencia/NewPrazo"
echo "   ✅ Seções em cards com shadow-erlene"
echo "   ✅ Grid responsivo e campos padronizados"
echo "   ✅ Validações com estados visuais"
echo "   ✅ Botões de ação seguindo layout"
echo "   ✅ Loading state com spinner"
echo ""
echo "🎉 SISTEMA NEWTASK ERLENE FINALIZADO!"
echo ""
echo "⏭️ PRÓXIMOS SCRIPTS SUGERIDOS:"
echo "   • 95a: EditTask (edição de tarefas)"
echo "   • 96a: Portal do Cliente"
echo "   • 97a: Dashboard Analytics avançado"
echo "   • 98a: Sistema de Relatórios"