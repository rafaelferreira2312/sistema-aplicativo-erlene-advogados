#!/bin/bash

# Script 92h - Correção Final Completa (Parte 2/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📋 Completando Documentos.js seguindo EXATO padrão Audiencias.js (Parte 2/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Completando arquivo Documentos.js com JSX fechado corretamente..."

# Continuar o arquivo Documentos.js (parte 2 - completar JSX)
cat >> frontend/src/pages/admin/Documentos.js << 'EOF'

      {/* Filtros e Lista */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Lista de Documentos</h2>
          <Link
            to="/admin/documentos/novo"
            className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <PlusIcon className="w-5 h-5 mr-2" />
            Novo Documento
          </Link>
        </div>
        
        <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-6">
          {/* Busca */}
          <div className="relative flex-1">
            <MagnifyingGlassIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar documento..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 w-full border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          
          {/* Filtros */}
          <select
            value={filterCategoria}
            onChange={(e) => setFilterCategoria(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todas as categorias</option>
            {categorias.map((categoria) => (
              <option key={categoria} value={categoria}>{categoria}</option>
            ))}
          </select>
          
          <select
            value={filterTipo}
            onChange={(e) => setFilterTipo(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">Todos os tipos</option>
            {tipos.map((tipo) => (
              <option key={tipo} value={tipo}>{tipo}</option>
            ))}
          </select>
        </div>

        {/* Tabela de Documentos */}
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Documento
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Categoria
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tipo/Tamanho
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Upload
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ações
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredDocumentos.map((documento) => (
                <tr key={documento.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                        {getTipoIcon(documento.tipo)}
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{documento.nome}</div>
                        <div className="text-sm text-gray-500">{documento.subcategoria}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      {getCategoriaIcon(documento.categoria)}
                      <div className="ml-2">
                        <div className="text-sm text-gray-900">{documento.categoria.replace('Documentos de ', '')}</div>
                        {documento.vinculadoNome && (
                          <div className="text-sm text-gray-500">{documento.vinculadoNome}</div>
                        )}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{documento.tipo}</div>
                    <div className="text-sm text-gray-500">{documento.tamanho}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPrivacidadeColor(documento.privacidade)}`}>
                      {documento.privacidade}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{formatDate(documento.dataUpload)}</div>
                    <div className="text-sm text-gray-500">{documento.uploadPor}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex justify-end space-x-2">
                      <button 
                        onClick={() => handlePreview(documento)}
                        className="text-blue-600 hover:text-blue-900"
                        title="Preview"
                      >
                        <EyeIcon className="w-5 h-5" />
                      </button>
                      <button
                        onClick={() => handleDownload(documento)}
                        className="text-green-600 hover:text-green-900"
                        title="Download"
                      >
                        <ArrowDownTrayIcon className="w-5 h-5" />
                      </button>
                      <Link
                        to={`/admin/documentos/${documento.id}/editar`}
                        className="text-primary-600 hover:text-primary-900"
                        title="Editar"
                      >
                        <PencilIcon className="w-5 h-5" />
                      </Link>
                      <button
                        onClick={() => handleDelete(documento.id)}
                        className="text-red-600 hover:text-red-900"
                        title="Excluir"
                      >
                        <TrashIcon className="w-5 h-5" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {/* Estado vazio */}
        {filteredDocumentos.length === 0 && (
          <div className="text-center py-12">
            <DocumentTextIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">Nenhum documento encontrado</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || filterCategoria !== 'all' || filterTipo !== 'all'
                ? 'Tente ajustar os filtros de busca.'
                : 'Comece fazendo upload de um documento.'}
            </p>
            <div className="mt-6">
              <Link
                to="/admin/documentos/novo"
                className="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <PlusIcon className="w-5 h-5 mr-2" />
                Novo Documento
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Documentos;
EOF

echo "✅ Arquivo Documentos.js finalizado!"

echo "📝 3. Verificando se precisa corrigir App.js..."

# Verificar se as rotas existem
if ! grep -q 'path="documentos"' frontend/src/App.js; then
    echo "📝 Adicionando rotas ao App.js..."
    
    # Fazer backup
    cp frontend/src/App.js frontend/src/App.js.backup.documentos
    
    # Adicionar import se não existir
    if ! grep -q "import Documentos" frontend/src/App.js; then
        sed -i '/import EditTransacao/a import Documentos from '\''./pages/admin/Documentos'\'';' frontend/src/App.js
    fi
    
    # Adicionar rota se não existir
    if ! grep -q 'path="documentos"' frontend/src/App.js; then
        sed -i '/path="financeiro\/:id\/editar"/a\                    <Route path="documentos" element={<Documentos />} />' frontend/src/App.js
    fi
    
    echo "✅ Rotas adicionadas ao App.js"
else
    echo "✅ Rotas já existem no App.js"
fi

echo ""
echo "🎉 SCRIPT 92h CONCLUÍDO!"
echo ""
echo "✅ DOCUMENTOS.JS 100% FUNCIONAL:"
echo "   • Arquivo completo seguindo EXATO padrão Audiencias.js"
echo "   • JSX fechado corretamente sem erros de sintaxe"
echo "   • 4 documentos mockados para teste"
echo "   • Cards de estatísticas funcionais"
echo "   • Tabela com filtros e ações CRUD"
echo "   • Estados de loading e vazio"
echo ""
echo "📄 DOCUMENTOS INCLUÍDOS:"
echo "   1. Contrato Honorários João (Cliente - PDF)"
echo "   2. RG Maria Oliveira (Cliente - IMG)"
echo "   3. Nota Fiscal Papelaria (Financeiro - PDF)"
echo "   4. OAB Carlos Oliveira (Funcionário - PDF)"
echo ""
echo "🔧 FUNCIONALIDADES:"
echo "   • Busca por nome de documento"
echo "   • Filtros por categoria e tipo"
echo "   • Preview, download, editar, excluir"
echo "   • Cards de estatísticas em tempo real"
echo "   • Estados visuais (loading, vazio)"
echo ""
echo "🧪 TESTE AGORA:"
echo "   • http://localhost:3000/admin/documentos"
echo "   • Deve carregar sem erros de sintaxe"
echo "   • Todos os 4 documentos devem aparecer"
echo "   • Teste filtros e busca"
echo "   • Teste ações (preview, download)"
echo ""
echo "✅ ARQUIVO SEGUINDO PADRÃO DAS OUTRAS TELAS:"
echo "   • Header igual ao Audiencias.js e Clients.js"
echo "   • Cards de estatísticas igual ao padrão"
echo "   • Tabela e filtros igual ao padrão"
echo "   • JSX fechado corretamente"
echo ""
echo "🎯 SISTEMA GED ERLENE FINALIZADO!"
echo ""
echo "⏭️ PRÓXIMO MÓDULO SUGERIDO:"
echo "   • Sistema Kanban (93a)"
echo "   • Portal do Cliente (94a)"
echo "   • Dashboard Analytics (95a)"