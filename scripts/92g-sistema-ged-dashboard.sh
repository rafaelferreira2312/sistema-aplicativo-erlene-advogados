#!/bin/bash

# Script 92f - Edição e Preview GED (Parte 2/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📋 Completando Edição e Preview GED (Parte 2/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Completando EditDocumento.js com formulários HTML..."

# Continuar o arquivo EditDocumento.js (parte 2 - formulários HTML)
cat >> frontend/src/components/documentos/EditDocumento.js << 'EOF'

  // Categorias e subcategorias
  const categorias = [
    'Documentos de Clientes',
    'Documentos Financeiros', 
    'Documentos de Funcionários',
    'Documentos de Fornecedores',
    'Documentos Administrativos'
  ];

  const getSubcategorias = (categoria) => {
    switch (categoria) {
      case 'Documentos de Clientes':
        return ['Contratos', 'Documentos Pessoais', 'Documentos Processuais', 'Procurações', 'Certidões'];
      case 'Documentos Financeiros':
        return ['Notas Fiscais', 'Boletos', 'Comprovantes', 'Extratos', 'Contratos', 'Recibos'];
      case 'Documentos de Funcionários':
        return ['Documentos Pessoais', 'Carteira OAB', 'Currículos', 'Contratos', 'Certificados'];
      case 'Documentos de Fornecedores':
        return ['Contratos', 'Manuais', 'Notas Fiscais', 'Certificados', 'Propostas'];
      case 'Documentos Administrativos':
        return ['Documentos Internos', 'Correspondências', 'Licenças', 'Seguros', 'Manuais'];
      default:
        return [];
    }
  };

  const tiposPessoa = [
    { value: '', label: 'Nenhuma pessoa vinculada' },
    { value: 'Cliente', label: 'Cliente' },
    { value: 'Advogado', label: 'Advogado/Funcionário' },
    { value: 'Fornecedor', label: 'Fornecedor' }
  ];

  const privacidadeOptions = [
    { value: 'Público', label: 'Público - Visível para todos', icon: EyeIcon },
    { value: 'Privado', label: 'Privado - Apenas responsáveis', icon: EyeSlashIcon },
    { value: 'Restrito', label: 'Restrito - Acesso limitado', icon: ExclamationTriangleIcon }
  ];

  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'Cliente': return <UserIcon className="w-4 h-4 text-primary-600" />;
      case 'Advogado': return <UsersIcon className="w-4 h-4 text-blue-600" />;
      case 'Fornecedor': return <BuildingOfficeIcon className="w-4 h-4 text-orange-600" />;
      default: return <UserIcon className="w-4 h-4 text-gray-600" />;
    }
  };

  const getFileIcon = (extensao, size = 'w-12 h-12') => {
    switch (extensao.toLowerCase()) {
      case 'pdf': return <DocumentIcon className={`${size} text-red-500`} />;
      case 'jpg':
      case 'jpeg':
      case 'png': return <PhotoIcon className={`${size} text-yellow-500`} />;
      case 'mp3':
      case 'wav': return <SpeakerWaveIcon className={`${size} text-purple-500`} />;
      case 'mp4':
      case 'avi': return <VideoCameraIcon className={`${size} text-pink-500`} />;
      case 'xls':
      case 'xlsx': return <TableCellsIcon className={`${size} text-green-500`} />;
      default: return <DocumentTextIcon className={`${size} text-blue-500`} />;
    }
  };

  const getPrivacidadeColor = (privacidade) => {
    switch (privacidade) {
      case 'Público': return 'bg-green-100 text-green-800';
      case 'Privado': return 'bg-red-100 text-red-800';
      case 'Restrito': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('pt-BR');
  };

  const renderPreview = () => {
    if (!previewMode) return null;

    return (
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900">Preview do Documento</h2>
          <button
            onClick={handlePreview}
            className="text-gray-400 hover:text-gray-600"
          >
            ×
          </button>
        </div>
        
        <div className="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center">
          {formData.extensao === 'jpg' || formData.extensao === 'jpeg' || formData.extensao === 'png' ? (
            <div className="space-y-4">
              <div className="w-64 h-48 mx-auto bg-gray-200 rounded-lg flex items-center justify-center">
                <PhotoIcon className="w-16 h-16 text-gray-400" />
              </div>
              <p className="text-sm text-gray-600">Preview da imagem seria exibido aqui</p>
            </div>
          ) : formData.extensao === 'pdf' ? (
            <div className="space-y-4">
              <DocumentIcon className="w-16 h-16 text-red-500 mx-auto" />
              <div>
                <p className="text-lg font-medium text-gray-900">Preview do PDF</p>
                <p className="text-sm text-gray-600">
                  Documento PDF com {formData.tamanho} - Versão {formData.versao}
                </p>
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              {getFileIcon(formData.extensao, 'w-16 h-16')}
              <div>
                <p className="text-lg font-medium text-gray-900">Preview não disponível</p>
                <p className="text-sm text-gray-600">
                  Arquivo {formData.extensao.toUpperCase()} - {formData.tamanho}
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    );
  };

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <Link
              to="/admin/documentos"
              className="p-2 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5" />
            </Link>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Editar Documento</h1>
              <p className="text-lg text-gray-600 mt-2">
                ID: #{formData.id} - {formData.nome}
              </p>
            </div>
          </div>
          <div className="flex items-center space-x-4">
            <span className={`inline-flex items-center px-3 py-1 text-sm font-semibold rounded-full ${getPrivacidadeColor(formData.privacidade)}`}>
              {formData.privacidade}
            </span>
            {getFileIcon(formData.extensao)}
          </div>
        </div>
        
        {/* Ações Rápidas */}
        <div className="mt-6 flex flex-wrap gap-4">
          <button
            onClick={handlePreview}
            className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <EyeIcon className="w-5 h-5 mr-2" />
            {previewMode ? 'Fechar Preview' : 'Preview'}
          </button>
          <button
            onClick={handleDownload}
            className="inline-flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            <ArrowDownTrayIcon className="w-5 h-5 mr-2" />
            Download
          </button>
          <button
            onClick={handleDelete}
            className="inline-flex items-center px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            <TrashIcon className="w-5 h-5 mr-2" />
            Excluir
          </button>
        </div>

        {/* Informações do Arquivo */}
        <div className="mt-6 grid grid-cols-2 md:grid-cols-4 gap-4 p-4 bg-gray-50 rounded-lg">
          <div className="text-center">
            <div className="text-sm text-gray-500">Tamanho</div>
            <div className="font-semibold text-gray-900">{formData.tamanho}</div>
          </div>
          <div className="text-center">
            <div className="text-sm text-gray-500">Downloads</div>
            <div className="font-semibold text-gray-900">{formData.totalDownloads}</div>
          </div>
          <div className="text-center">
            <div className="text-sm text-gray-500">Versão</div>
            <div className="font-semibold text-gray-900">v{formData.versao}</div>
          </div>
          <div className="text-center">
            <div className="text-sm text-gray-500">Upload</div>
            <div className="font-semibold text-gray-900">{formatDate(formData.dataUpload)}</div>
          </div>
        </div>
      </div>

      {/* Preview */}
      {renderPreview()}

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Informações Básicas */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Informações Básicas</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Nome do Documento *
              </label>
              <input
                type="text"
                name="nome"
                value={formData.nome}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.nome ? 'border-red-300' : 'border-gray-300'
                }`}
              />
              {errors.nome && <p className="text-red-500 text-sm mt-1">{errors.nome}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Arquivo Original</label>
              <div className="flex items-center p-3 border border-gray-300 rounded-lg bg-gray-50">
                {getFileIcon(formData.extensao, 'w-6 h-6')}
                <div className="ml-3">
                  <div className="text-sm font-medium text-gray-900">
                    {formData.extensao.toUpperCase()} - {formData.tamanho}
                  </div>
                  <div className="text-xs text-gray-500">
                    Enviado por {formData.uploadPor}
                  </div>
                </div>
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Categoria *
              </label>
              <select
                name="categoria"
                value={formData.categoria}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.categoria ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione a categoria...</option>
                {categorias.map((categoria) => (
                  <option key={categoria} value={categoria}>{categoria}</option>
                ))}
              </select>
              {errors.categoria && <p className="text-red-500 text-sm mt-1">{errors.categoria}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Subcategoria *
              </label>
              <select
                name="subcategoria"
                value={formData.subcategoria}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                  errors.subcategoria ? 'border-red-300' : 'border-gray-300'
                }`}
              >
                <option value="">Selecione a subcategoria...</option>
                {getSubcategorias(formData.categoria).map((sub) => (
                  <option key={sub} value={sub}>{sub}</option>
                ))}
              </select>
              {errors.subcategoria && <p className="text-red-500 text-sm mt-1">{errors.subcategoria}</p>}
            </div>
          </div>

          {formData.categoria && (
            <div className="mt-4 p-4 bg-blue-50 rounded-lg">
              <div className="flex items-center">
                <FolderIcon className="w-5 h-5 text-blue-600 mr-2" />
                <span className="text-sm font-medium text-blue-900">
                  Pasta: /documentos/{formData.categoria.toLowerCase().replace(/\s+/g, '_')}/
                  {formData.subcategoria.toLowerCase().replace(/\s+/g, '_')}/
                </span>
              </div>
            </div>
          )}
        </div>

        {/* Relacionamentos */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Relacionamentos</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Tipo de Pessoa</label>
              <select
                name="vinculadoTipo"
                value={formData.vinculadoTipo}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                {tiposPessoa.map((tipo) => (
                  <option key={tipo.value} value={tipo.value}>{tipo.label}</option>
                ))}
              </select>
            </div>

            {formData.vinculadoTipo && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Selecionar {formData.vinculadoTipo}
                </label>
                <select
                  name="vinculadoId"
                  value={formData.vinculadoId}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="">Selecione...</option>
                  {formData.vinculadoTipo === 'Cliente' && mockClients.map((client) => (
                    <option key={client.id} value={client.id}>
                      {client.name} ({client.document})
                    </option>
                  ))}
                  {formData.vinculadoTipo === 'Advogado' && mockAdvogados.map((advogado) => (
                    <option key={advogado.id} value={advogado.id}>
                      {advogado.name} ({advogado.oab})
                    </option>
                  ))}
                  {formData.vinculadoTipo === 'Fornecedor' && mockFornecedores.map((fornecedor) => (
                    <option key={fornecedor.id} value={fornecedor.id}>
                      {fornecedor.name} - {fornecedor.tipo}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Preview da Pessoa */}
            {selectedPerson && (
              <div className="md:col-span-2 bg-gray-50 rounded-lg p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-3">Relacionamento:</h3>
                <div className="flex items-center">
                  {getTipoIcon(formData.vinculadoTipo)}
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

        {/* Tags e Configurações */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Tags e Configurações</h2>
          
          {/* Tags */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">Tags</label>
            <div className="flex space-x-2 mb-3">
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
            
            {/* Tags Existentes */}
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
          </div>
          
          {/* Observações */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">Observações</label>
            <textarea
              name="observacoes"
              value={formData.observacoes}
              onChange={handleChange}
              rows={4}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="Observações sobre o documento..."
            />
          </div>

          {/* Privacidade */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-3">Privacidade</label>
              <div className="space-y-3">
                {privacidadeOptions.map((option) => (
                  <label key={option.value} className="flex items-center">
                    <input
                      type="radio"
                      name="privacidade"
                      value={option.value}
                      checked={formData.privacidade === option.value}
                      onChange={handleChange}
                      className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                    />
                    <div className="ml-3 flex items-center">
                      <option.icon className="w-4 h-4 text-gray-600 mr-2" />
                      <div>
                        <div className="text-sm font-medium text-gray-900">{option.value}</div>
                        <div className="text-xs text-gray-500">{option.label.split(' - ')[1]}</div>
                      </div>
                    </div>
                  </label>
                ))}
              </div>
            </div>
            
            {/* Data de Expiração */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Data de Expiração (opcional)
              </label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="date"
                  name="dataExpiracao"
                  value={formData.dataExpiracao}
                  onChange={handleChange}
                  min={new Date().toISOString().split('T')[0]}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>
              {formData.dataExpiracao && (
                <p className="text-xs text-orange-600 mt-1">
                  Expira em: {formatDate(formData.dataExpiracao)}
                </p>
              )}
            </div>
          </div>
        </div>

        {/* Botões */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <div className="flex justify-end space-x-4">
            <Link
              to="/admin/documentos"
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

export default EditDocumento;
EOF

echo "✅ EditDocumento.js completo criado!"

echo "📝 2. Atualizando App.js para incluir rota de edição..."

# Adicionar import do EditDocumento se não existir
if ! grep -q "import EditDocumento" frontend/src/App.js; then
    sed -i '/import NewDocumento/a import EditDocumento from '\''./components/documentos/EditDocumento'\'';' frontend/src/App.js
fi

# Adicionar rota de edição se não existir
if ! grep -q 'path="documentos/:id/editar"' frontend/src/App.js; then
    sed -i '/path="documentos\/novo"/a\                    <Route path="documentos/:id/editar" element={<EditDocumento />} />' frontend/src/App.js
fi

echo "✅ App.js atualizado!"

echo "📝 3. Verificando estrutura final do módulo GED..."

# Verificar se todas as pastas existem
echo "📂 Verificando estrutura de pastas..."
mkdir -p frontend/src/pages/admin
mkdir -p frontend/src/components/documentos

echo ""
echo "🎉 SCRIPT 92f CONCLUÍDO!"
echo ""
echo "✅ EDITDOCUMENTO E PREVIEW 100% COMPLETO:"
echo "   • Formulário completo de edição seguindo padrão EditAudiencia/EditPrazo"
echo "   • Header com informações do documento e ações rápidas"
echo "   • Preview integrado por tipo de arquivo"
echo "   • Ações rápidas (Preview, Download, Excluir) no header"
echo "   • Seções organizadas: Básicas, Relacionamentos, Tags, Configurações"
echo "   • 5 documentos pré-definidos para edição"
echo ""
echo "📋 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Carregamento de dados existentes por ID"
echo "   • Edição de metadados (nome, categoria, tags, observações)"
echo "   • Relacionamentos opcionais (Cliente, Advogado, Fornecedor, Nenhum)"
echo "   • Sistema de tags com adição/remoção dinâmica"
echo "   • Configurações de privacidade (Público, Privado, Restrito)"
echo "   • Data de expiração opcional"
echo "   • Preview diferenciado por tipo de arquivo"
echo "   • Estatísticas (downloads, versão, última visualização)"
echo ""
echo "🎭 PREVIEW POR TIPO DE ARQUIVO:"
echo "   📷 Imagens (JPG): Área de preview simulada"
echo "   📄 PDF: Ícone + informações da versão"
echo "   📊 Outros: Ícone específico + informações básicas"
echo ""
echo "🔧 DOCUMENTOS DISPONÍVEIS PARA EDIÇÃO:"
echo "   ID 1: Contrato João Silva (Cliente - PDF)"
echo "   ID 2: RG Maria Oliveira (Cliente - JPG com preview)"
echo "   ID 7: OAB Carlos (Advogado - PDF v2)"
echo "   ID 10: Manual Sistema (Fornecedor - PDF)"
echo "   ID 13: Regulamento Interno (Administrativo - PDF v4)"
echo ""
echo "🧪 TESTE AGORA:"
echo "   1. Acesse /admin/documentos"
echo "   2. Clique no ícone de editar em qualquer documento"
echo "   3. URLs diretas para teste:"
echo "      • /admin/documentos/1/editar"
echo "      • /admin/documentos/2/editar (teste preview de imagem)"
echo "      • /admin/documentos/7/editar"
echo "   4. Teste o botão 'Preview' para ver diferentes tipos"
echo "   5. Teste edição de tags e relacionamentos"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "   ✅ /admin/documentos - Lista completa"
echo "   ✅ /admin/documentos/novo - Upload"
echo "   ✅ /admin/documentos/:id/editar - Edição"
echo ""
echo "🎯 MÓDULO GED 100% FINALIZADO!"
echo ""
echo "✅ CRUD COMPLETO:"
echo "   ✅ Lista principal (Documentos.js) - 5 categorias, filtros"
echo "   ✅ Upload (NewDocumento.js) - Drag-drop, auto-classificação"
echo "   ✅ Edição (EditDocumento.js) - Preview, metadados"
echo "   ✅ Exclusão (função na lista e edição)"
echo ""
echo "📊 ESTATÍSTICAS GED FINAIS:"
echo "   • 15 documentos em 5 categorias"
echo "   • Auto-classificação inteligente"
echo "   • Preview por tipo de arquivo"
echo "   • Relacionamentos opcionais"
echo "   • Sistema de tags dinâmico"
echo "   • Configurações de privacidade"
echo ""
echo "🎉 SISTEMA GED ERLENE COMPLETO!"
echo ""
echo "⏭️ PRÓXIMO MÓDULO SUGERIDO (Script 93a):"
echo "   • Sistema Kanban (Gestão de Processos e Tarefas)"
echo "   • Dashboard de arrastar e soltar"
echo "   • Colunas personalizáveis"
echo ""
echo "Digite 'continuar' para implementar