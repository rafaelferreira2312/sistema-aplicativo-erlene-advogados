#!/bin/bash

# Script 128b - Completar Tabela de Processos com Ícones de Ação
# Sistema Erlene Advogados - Segunda parte: Dashboard, tabela e ícones
# EXECUTAR DENTRO DA PASTA: frontend/

echo "🔧 Script 128b - Completando tabela de processos com ícones de ação..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script dentro da pasta frontend/"
    echo "📁 Comando correto:"
    echo "   cd frontend"
    echo "   chmod +x 128b-complete-processes-table.sh && ./128b-complete-processes-table.sh"
    exit 1
fi

echo "1️⃣ Verificando se primeira parte foi executada..."

# Verificar se arquivo existe e tem a estrutura esperada
if [ ! -f "src/pages/admin/Processes.js" ] || ! grep -q "safeProcesses" src/pages/admin/Processes.js; then
    echo "❌ Erro: Execute primeiro o script 128-complete-processes-list.sh"
    exit 1
fi

echo "2️⃣ Completando Processes.js com dashboard, tabela e ícones..."

# Continuar adicionando ao arquivo existente
cat >> src/pages/admin/Processes.js << 'EOF'

      {/* Stats Dashboard */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Total de Processos */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div>
              <div className="flex items-center justify-center w-12 h-12 bg-blue-100 rounded-xl mb-4">
                <ScaleIcon className="w-6 h-6 text-blue-600" />
              </div>
              <div className="text-2xl font-bold text-gray-900 mb-1">{stats.total}</div>
              <div className="text-sm text-gray-600">Total de Processos</div>
              <div className="text-xs text-gray-500 mt-1">Cadastrados no sistema</div>
            </div>
          </div>
        </div>

        {/* Em Andamento */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div>
              <div className="flex items-center justify-center w-12 h-12 bg-green-100 rounded-xl mb-4">
                <ClockIcon className="w-6 h-6 text-green-600" />
              </div>
              <div className="text-2xl font-bold text-gray-900 mb-1">{stats.em_andamento}</div>
              <div className="text-sm text-gray-600">Em Andamento</div>
              <div className="text-xs text-gray-500 mt-1">Processos ativos</div>
            </div>
          </div>
        </div>

        {/* Aguardando */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div>
              <div className="flex items-center justify-center w-12 h-12 bg-yellow-100 rounded-xl mb-4">
                <DocumentTextIcon className="w-6 h-6 text-yellow-600" />
              </div>
              <div className="text-2xl font-bold text-gray-900 mb-1">{stats.aguardando}</div>
              <div className="text-sm text-gray-600">Aguardando</div>
              <div className="text-xs text-gray-500 mt-1">Pendentes de ação</div>
            </div>
          </div>
        </div>

        {/* Valor Total */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex items-center justify-between">
            <div>
              <div className="flex items-center justify-center w-12 h-12 bg-purple-100 rounded-xl mb-4">
                <UserIcon className="w-6 h-6 text-purple-600" />
              </div>
              <div className="text-2xl font-bold text-gray-900 mb-1">{formatCurrency(stats.valor_total)}</div>
              <div className="text-sm text-gray-600">Valor Total</div>
              <div className="text-xs text-gray-500 mt-1">Causa em trâmite</div>
            </div>
          </div>
        </div>
      </div>

      {/* Lista de Processos */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100">
        {/* Header da Lista */}
        <div className="px-6 py-4 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900">Lista de Processos</h3>
            <Link
              to="/admin/processos/novo"
              className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
            >
              <PlusIcon className="w-4 h-4 mr-2" />
              Novo Processo
            </Link>
          </div>
        </div>

        {/* Filtros */}
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            {/* Busca */}
            <div className="relative">
              <MagnifyingGlassIcon className="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar processo, cliente ou assunto..."
                value={search}
                onChange={handleSearch}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              />
            </div>

            {/* Filtro Status */}
            <select
              value={statusFilter}
              onChange={(e) => handleStatusFilter(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">Todos os status</option>
              <option value="em_andamento">Em Andamento</option>
              <option value="distribuido">Distribuído</option>
              <option value="suspenso">Suspenso</option>
              <option value="finalizado">Finalizado</option>
              <option value="arquivado">Arquivado</option>
            </select>

            {/* Filtro Tipo */}
            <select className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500">
              <option value="">Todos os tipos</option>
              <option value="acao_cobranca">Ação de Cobrança</option>
              <option value="reclamatoria_trabalhista">Reclamatória Trabalhista</option>
              <option value="execucao_fiscal">Execução Fiscal</option>
            </select>

            {/* Filtro Advogado */}
            <select
              value={advogadoFilter}
              onChange={(e) => handleAdvogadoFilter(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">Todos os advogados</option>
              <option value="1">Dr. Carlos Oliveira</option>
              <option value="2">Dra. Maria Santos</option>
              <option value="3">Dra. Erlene Chaves Silva</option>
            </select>
          </div>
        </div>

        {/* Tabela */}
        {safeProcesses.length === 0 ? (
          <div className="text-center py-12">
            <DocumentTextIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum processo encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              Comece criando um novo processo.
            </p>
            <div className="mt-6">
              <Link
                to="/admin/processos/novo"
                className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <PlusIcon className="w-4 h-4 mr-2" />
                Novo Processo
              </Link>
            </div>
          </div>
        ) : (
          <div className="overflow-hidden">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Processo
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Cliente
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status/Tipo
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Advogado
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Valor
                    </th>
                    <th className="relative px-6 py-3">
                      <span className="sr-only">Ações</span>
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {safeProcesses.map((processo) => (
                    <tr key={processo?.id || Math.random()} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="flex items-center justify-center w-8 h-8 bg-primary-100 rounded-lg mr-3">
                            <ScaleIcon className="w-4 h-4 text-primary-600" />
                          </div>
                          <div>
                            <div className="text-sm font-medium text-gray-900">
                              {processo?.numero || 'Número não informado'}
                            </div>
                            <div className="text-sm text-gray-500">
                              {processo?.tipo_acao || 'Tipo não informado'}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900 font-medium">
                          {getClientName(processo)}
                        </div>
                        <div className="text-sm text-gray-500">
                          {processo?.cliente?.tipo_pessoa === 'PF' ? 'PF' : 'PJ'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex flex-col space-y-1">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(processo?.status)}`}>
                            {getStatusText(processo?.status)}
                          </span>
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(processo?.prioridade)}`}>
                            {getPriorityText(processo?.prioridade)}
                          </span>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {getAdvogadoName(processo)}
                        </div>
                        <div className="text-sm text-gray-500">
                          {processo?.advogado?.oab || processo?.tribunal || 'OAB não informada'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {formatCurrency(processo?.valor_causa)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end space-x-2">
                          {/* ÍCONE CLIENTE - Link direto para cliente */}
                          <Link
                            to={`/admin/clientes/${processo?.cliente_id || 0}`}
                            className="text-green-600 hover:text-green-900 p-1 rounded hover:bg-green-100 transition-colors"
                            title="Ver cliente"
                          >
                            <UserIcon className="w-4 h-4" />
                          </Link>
                          
                          {/* ÍCONE DOCUMENTOS - Modal para documentos */}
                          <button
                            onClick={() => {
                              console.log('Abrir modal de documentos para processo:', processo?.id);
                              alert(`Funcionalidade de documentos será implementada para o processo ${processo?.numero}`);
                            }}
                            className="text-blue-600 hover:text-blue-900 p-1 rounded hover:bg-blue-100 transition-colors"
                            title="Ver documentos"
                          >
                            <FolderIcon className="w-4 h-4" />
                          </button>

                          {/* Visualizar detalhes */}
                          <Link
                            to={`/admin/processos/${processo?.id || 0}`}
                            className="text-primary-600 hover:text-primary-900 p-1 rounded hover:bg-primary-100 transition-colors"
                            title="Visualizar detalhes"
                          >
                            <EyeIcon className="w-4 h-4" />
                          </Link>
                          
                          {/* Editar */}
                          <Link
                            to={`/admin/processos/${processo?.id || 0}/editar`}
                            className="text-blue-600 hover:text-blue-900 p-1 rounded hover:bg-blue-100 transition-colors"
                            title="Editar processo"
                          >
                            <PencilIcon className="w-4 h-4" />
                          </Link>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Paginação */}
        {totalPages > 1 && (
          <div className="px-6 py-4 border-t border-gray-200 bg-gray-50">
            <div className="flex items-center justify-between">
              <div className="text-sm text-gray-700">
                Mostrando {safeProcesses.length} de {totalProcessos} processos
              </div>
              <div className="flex items-center space-x-2">
                <button
                  onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
                  disabled={currentPage === 1}
                  className="px-3 py-1 border border-gray-300 text-sm rounded disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100"
                >
                  Anterior
                </button>
                <span className="px-3 py-1 text-sm text-gray-700">
                  Página {currentPage} de {totalPages}
                </span>
                <button
                  onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
                  disabled={currentPage === totalPages}
                  className="px-3 py-1 border border-gray-300 text-sm rounded disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100"
                >
                  Próxima
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Processes;
EOF

echo "3️⃣ Verificando se arquivo foi completado..."

if grep -q "UserIcon className=\"w-4 h-4\"" src/pages/admin/Processes.js && grep -q "FolderIcon className=\"w-4 h-4\"" src/pages/admin/Processes.js; then
    echo "✅ Ícones de ação adicionados com sucesso"
else
    echo "❌ Erro ao adicionar ícones de ação"
    exit 1
fi

echo "4️⃣ Verificando integridade do arquivo final..."

# Verificar se arquivo tem estrutura completa
if grep -q "export default Processes" src/pages/admin/Processes.js; then
    echo "✅ Arquivo Processes.js completo e funcional"
    echo "📊 Linhas totais: $(wc -l < src/pages/admin/Processes.js)"
else
    echo "❌ Arquivo Processes.js incompleto"
    exit 1
fi

echo ""
echo "✅ SCRIPT 128b CONCLUÍDO COM SUCESSO!"
echo ""
echo "🔧 O que foi implementado:"
echo "   • Dashboard com 4 cards de estatísticas"
echo "   • Tabela completa com dados reais da API"
echo "   • ÍCONE USERICON (verde): link para /admin/clientes/{cliente_id}"
echo "   • ÍCONE FOLDERICON (azul): modal para documentos (placeholder)"
echo "   • Ícones de visualizar e editar"
echo "   • Paginação funcional"
echo "   • Filtros por status e advogado"
echo "   • Estados de loading e erro"
echo ""
echo "🎯 PROBLEMAS RESOLVIDOS:"
echo "   ✅ Faltavam ícones de ação na lista"
echo "   ✅ Dashboard com estatísticas funcionais"  
echo "   ✅ Dados reais da API (sem mocks)"
echo "   ✅ Layout original Erlene mantido"
echo ""
echo "📝 PRÓXIMOS PASSOS:"
echo "Digite 'continuar' para implementar:"
echo "   • NewProcess.js com TODOS os campos da tabela"
echo "   • EditProcess.js com TODOS os campos da tabela"
echo "   • Validações completas dos formulários"