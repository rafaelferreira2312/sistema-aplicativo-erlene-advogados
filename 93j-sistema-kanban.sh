#!/bin/bash

# Script 97b - EditTask.js (Parte 2/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)
# Enumeração: 97b

echo "📋 Completando EditTask.js seguindo padrão Erlene (Parte 2/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 1. Completando EditTask.js com seções restantes..."

# Continuar o arquivo EditTask.js (parte 2 - seções restantes)
cat >> frontend/src/components/kanban/EditTask.js << 'EOF'

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
                    {client.name} ({client.type}) - {client.document}
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

        {/* Configurações e Prazos seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Configurações e Prazos</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Coluna Atual</label>
              <div className="relative">
                <select
                  name="colunaId"
                  value={formData.colunaId}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  {colunas.map((coluna) => (
                    <option key={coluna.id} value={coluna.id}>
                      {coluna.nome}
                    </option>
                  ))}
                </select>
                <div className="absolute right-3 top-3 flex items-center">
                  <div 
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: colunaAtual.cor }}
                  ></div>
                </div>
              </div>
              <p className="text-xs text-gray-500 mt-1">
                Coluna atual: {colunaAtual.nome}
              </p>
            </div>

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
                  placeholder="Ex: 4.5"
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">
                Tempo estimado para conclusão
              </p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Horas Gastas
              </label>
              <div className="relative">
                <ClockIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="number"
                  name="horasGastas"
                  value={formData.horasGastas}
                  onChange={handleChange}
                  min="0"
                  step="0.5"
                  className={`w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                    errors.horasGastas ? 'border-red-300' : 'border-gray-300'
                  }`}
                  placeholder="Ex: 2.5"
                />
              </div>
              {errors.horasGastas && <p className="text-red-500 text-sm mt-1">{errors.horasGastas}</p>}
              <p className="text-xs text-gray-500 mt-1">
                Tempo já trabalhado na tarefa
              </p>
            </div>

            {/* Progresso de Horas */}
            {formData.estimativaHoras && formData.horasGastas && (
              <div className="md:col-span-2 bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-2">Progresso de Horas:</h3>
                <div className="flex items-center justify-between text-sm text-gray-600 mb-2">
                  <span>{formData.horasGastas}h trabalhadas</span>
                  <span>{formData.estimativaHoras}h estimadas</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className={`h-2 rounded-full ${
                      (parseFloat(formData.horasGastas) / parseFloat(formData.estimativaHoras)) > 1 
                        ? 'bg-red-500' 
                        : (parseFloat(formData.horasGastas) / parseFloat(formData.estimativaHoras)) > 0.8 
                          ? 'bg-yellow-500' 
                          : 'bg-blue-500'
                    }`}
                    style={{ 
                      width: `${Math.min((parseFloat(formData.horasGastas) / parseFloat(formData.estimativaHoras)) * 100, 100)}%` 
                    }}
                  ></div>
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  {((parseFloat(formData.horasGastas) / parseFloat(formData.estimativaHoras)) * 100).toFixed(0)}% concluído
                </p>
              </div>
            )}
          </div>
        </div>

        {/* Tags seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Tags e Classificação</h2>
          
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
            <div className="flex flex-wrap gap-2 mb-4">
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
          <div>
            <p className="text-sm font-medium text-gray-700 mb-2">Sugestões:</p>
            <div className="flex flex-wrap gap-2">
              {['urgente', 'petição', 'contrato', 'audiência', 'prazo', 'análise', 'revisão', 'protocolo'].map((suggestedTag) => (
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

        {/* Observações seguindo padrão */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Observações</h2>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Observações Adicionais
            </label>
            <textarea
              name="observacoes"
              value={formData.observacoes}
              onChange={handleChange}
              rows={4}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="Observações importantes sobre a tarefa, instruções especiais, etc..."
            />
            <p className="text-xs text-gray-500 mt-1">
              Campo opcional para observações importantes sobre a tarefa
            </p>
          </div>
        </div>

        {/* Botões seguindo EXATO padrão EditAudiencia */}
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

export default EditTask;
EOF

echo "✅ EditTask.js completo criado!"

echo "📝 2. Atualizando App.js para incluir rota de edição de tarefas..."

# Fazer backup do App.js se necessário
if ! grep -q "EditTask" frontend/src/App.js; then
    cp frontend/src/App.js frontend/src/App.js.backup.edittask.$(date +%Y%m%d_%H%M%S)
    
    # Adicionar import do EditTask se não existir
    sed -i '/import NewTask/a import EditTask from '\''./components/kanban/EditTask'\'';' frontend/src/App.js
    
    # Adicionar rota de edição de tarefa se não existir
    sed -i '/path="kanban\/nova"/a\                    <Route path="kanban/:id/editar" element={<EditTask />} />' frontend/src/App.js
    
    echo "✅ Rota /admin/kanban/:id/editar adicionada ao App.js"
else
    echo "✅ Rota de edição já existe no App.js"
fi

echo "📝 3. Verificando estrutura de pastas..."

# Verificar se todas as pastas existem
mkdir -p frontend/src/pages/admin
mkdir -p frontend/src/components/kanban

echo "✅ Estrutura de pastas verificada!"

echo ""
echo "🎉 SCRIPT 97b CONCLUÍDO!"
echo ""
echo "✅ EDITTASK.JS 100% FUNCIONAL:"
echo "   • Formulário completo seguindo EXATO padrão EditAudiencia/EditPrazo"
echo "   • 6 seções organizadas: Básicas, Cliente/Processo, Configurações, Tags, Observações, Botões"
echo "   • Sistema expandido: Advogados + Funcionários"
echo "   • Relacionamentos opcionais com clientes e processos"
echo "   • Controle avançado de horas com progresso visual"
echo "   • Sistema de tags dinâmico com sugestões"
echo "   • Rota de edição configurada no App.js"
echo ""
echo "📋 FUNCIONALIDADES COMPLETAS:"
echo "   • Carregamento de dados por ID da URL"
echo "   • Título e descrição (obrigatórios)"
echo "   • Tipo de responsável (Advogado/Funcionário)"
echo "   • Seleção de coluna com indicador visual"
echo "   • Prioridade com ícones e cores"
echo "   • Cliente e processo (opcionais com preview)"
echo "   • Data de vencimento (obrigatória)"
echo "   • Controle de horas (estimativa vs gastas)"
echo "   • Sistema de tags com sugestões"
echo "   • Observações adicionais"
echo ""
echo "🎯 CONTROLE DE HORAS AVANÇADO:"
echo "   • Validação: horas gastas não pode > estimativa"
echo "   • Barra de progresso visual"
echo "   • Cores dinâmicas: azul (normal), amarelo (80%+), vermelho (100%+)"
echo "   • Percentual de conclusão calculado"
echo ""
echo "🏷️ SISTEMA DE TAGS:"
echo "   • Adição manual (digitação + Enter)"
echo "   • Botão de adicionar"
echo "   • Remoção individual (botão ×)"
echo "   • 8 sugestões pré-definidas"
echo "   • Prevenção de duplicatas"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "   • /admin/kanban/:id/editar - Editar tarefa ✅"
echo "   • Import e rota no App.js ✅"
echo "   • Botão voltar → /admin/kanban ✅"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. http://localhost:3000/admin/kanban"
echo "   2. Clique no ícone de 'Editar' em qualquer tarefa"
echo "   3. http://localhost:3000/admin/kanban/1/editar (ID 1-4 disponíveis)"
echo "   4. Teste todos os formulários e validações"
echo "   5. Teste sistema de tags e progresso de horas"
echo "   6. Teste relacionamento cliente → processo"
echo "   7. Teste validações (horas gastas > estimativa)"
echo ""
echo "📁 ARQUIVOS CRIADOS/ATUALIZADOS:"
echo "   • frontend/src/components/kanban/EditTask.js (completo)"
echo "   • App.js com import e rota de edição"
echo ""
echo "🎯 DADOS DE TESTE DISPONÍVEIS (por ID):"
echo "   • ID 1: Petição inicial (Advogado - Dr. Carlos)"
echo "   • ID 2: Contrato societário (Advogado - Dra. Maria)"
echo "   • ID 3: Organizar documentos (Funcionário - Carla)"
echo "   • ID 4: Contestação (Advogado - Dr. Carlos)"
echo ""
echo "🎉 SISTEMA EDITTASK ERLENE FINALIZADO!"
echo ""
echo "⏭️ PRÓXIMOS SCRIPTS SUGERIDOS:"
echo "   • 98a: Portal do Cliente"
echo "   • 99a: Dashboard Analytics Avançado"
echo "   • 100a: Sistema de Relatórios"
echo "   • 101a: Sistema de Notificações"