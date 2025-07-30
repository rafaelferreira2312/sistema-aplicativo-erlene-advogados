#!/bin/bash

# Script 92d - Upload Multi-Categoria GED (Parte 2/2)
# Autor: Sistema Erlene Advogados
# Data: $(date +%Y-%m-%d)

echo "📋 Completando Upload Multi-Categoria GED (Parte 2/2)..."

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

echo "📝 Completando NewDocumento.js com formulários HTML..."

# Continuar o arquivo NewDocumento.js (parte 2 - formulários HTML)
cat >> frontend/src/components/documentos/NewDocumento.js << 'EOF'

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
              <h1 className="text-3xl font-bold text-gray-900">Upload de Documento</h1>
              <p className="text-lg text-gray-600 mt-2">
                Faça upload de documentos com classificação automática
              </p>
            </div>
          </div>
          <DocumentTextIcon className="w-12 h-12 text-primary-600" />
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Upload de Arquivo */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Arquivo</h2>
          
          {/* Área de Drop */}
          <div
            className={`relative border-2 border-dashed rounded-xl p-8 text-center transition-colors ${
              dragActive 
                ? 'border-primary-500 bg-primary-50' 
                : errors.arquivo 
                  ? 'border-red-300 bg-red-50' 
                  : 'border-gray-300 hover:border-gray-400'
            }`}
            onDragEnter={handleDrag}
            onDragLeave={handleDrag}
            onDragOver={handleDrag}
            onDrop={handleDrop}
          >
            <input
              type="file"
              onChange={(e) => handleFileSelect(e.target.files[0])}
              className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
              accept=".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png,.gif,.mp3,.wav,.mp4,.avi,.xml"
            />
            
            {formData.arquivo ? (
              <div className="space-y-4">
                <div className="flex items-center justify-center">
                  {previewUrl ? (
                    <img src={previewUrl} alt="Preview" className="w-24 h-24 object-cover rounded-lg" />
                  ) : (
                    getFileIcon(formData.arquivo)
                  )}
                </div>
                <div>
                  <p className="text-lg font-medium text-gray-900">{formData.arquivo.name}</p>
                  <p className="text-sm text-gray-500">{formatFileSize(formData.arquivo.size)}</p>
                  <div className="flex items-center justify-center mt-2">
                    <CheckCircleIcon className="w-5 h-5 text-green-500 mr-2" />
                    <span className="text-sm text-green-600">Arquivo carregado com sucesso</span>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => {
                    setFormData(prev => ({ ...prev, arquivo: null, nome: '' }));
                    setPreviewUrl(null);
                  }}
                  className="text-sm text-red-600 hover:text-red-800"
                >
                  Remover arquivo
                </button>
              </div>
            ) : (
              <div className="space-y-4">
                <CloudArrowUpIcon className="mx-auto h-12 w-12 text-gray-400" />
                <div>
                  <p className="text-lg font-medium text-gray-900">
                    Arraste e solte seu arquivo aqui
                  </p>
                  <p className="text-sm text-gray-500">
                    ou clique para selecionar
                  </p>
                </div>
                <div className="text-xs text-gray-400">
                  Tipos aceitos: PDF, DOC, XLS, IMG, AUDIO, VIDEO, XML (máx. 50MB)
                </div>
              </div>
            )}
          </div>
          {errors.arquivo && <p className="text-red-500 text-sm mt-2">{errors.arquivo}</p>}
          
          {/* Nome do Documento */}
          <div className="mt-6">
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
              placeholder="Ex: Contrato_Honorarios_Joao_Silva.pdf"
            />
            {errors.nome && <p className="text-red-500 text-sm mt-1">{errors.nome}</p>}
            <p className="text-xs text-gray-500 mt-1">
              O sistema tentará classificar automaticamente com base no nome
            </p>
          </div>
        </div>

        {/* Classificação */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Classificação</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
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
                disabled={!formData.categoria}
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

        {/* Relacionamentos (Opcional) */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Relacionamentos (Opcional)</h2>
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
              <p className="text-xs text-gray-500 mt-1">
                Para documentos gerais pode deixar sem pessoa vinculada
              </p>
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

            {/* Processo (só para Cliente) */}
            {formData.vinculadoTipo === 'Cliente' && availableProcesses.length > 0 && (
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
                {formData.processoId && (
                  <div className="mt-2 flex items-center">
                    <ScaleIcon className="w-4 h-4 text-primary-600 mr-2" />
                    <div className="text-sm text-gray-700">
                      Processo: {availableProcesses.find(p => p.id.toString() === formData.processoId)?.number}
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        {/* Tags e Metadados */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Tags e Metadados</h2>
          
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
            
            {/* Tags Adicionadas */}
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
            <p className="text-xs text-gray-500 mt-1">
              Tags ajudam na busca e organização dos documentos
            </p>
          </div>
          
          {/* Observações */}
          <div>
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
        </div>

        {/* Configurações */}
        <div className="bg-white shadow-erlene rounded-xl border border-gray-100 p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-6">Configurações</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Privacidade */}
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
              <p className="text-xs text-gray-500 mt-1">
                Para documentos temporários ou com validade
              </p>
            </div>
          </div>
          
          {/* Configurações Adicionais */}
          <div className="mt-6 space-y-4">
            <label className="flex items-center">
              <input
                type="checkbox"
                name="notificarPessoa"
                checked={formData.notificarPessoa}
                onChange={handleChange}
                className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
              />
              <span className="ml-3 text-sm font-medium text-gray-700">
                Notificar pessoa vinculada sobre o documento
              </span>
            </label>
            
            <label className="flex items-center">
              <input
                type="checkbox"
                name="criarPasta"
                checked={formData.criarPasta}
                onChange={handleChange}
                className="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
              />
              <span className="ml-3 text-sm font-medium text-gray-700">
                Criar pasta automaticamente se não existir
              </span>
            </label>
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
              disabled={loading || !formData.arquivo}
              className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Enviando...
                </div>
              ) : (
                'Enviar Documento'
              )}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default NewDocumento;
EOF

echo "✅ NewDocumento.js completo criado!"

echo "📝 2. Atualizando App.js para incluir rota de novo documento..."

# Adicionar import do NewDocumento se não existir
if ! grep -q "import NewDocumento" frontend/src/App.js; then
    sed -i '/import Documentos/a import NewDocumento from '\''./components/documentos/NewDocumento'\'';' frontend/src/App.js
fi

# Adicionar rota de novo documento se não existir
if ! grep -q 'path="documentos/novo"' frontend/src/App.js; then
    sed -i '/path="documentos"/a\                    <Route path="documentos/novo" element={<NewDocumento />} />' frontend/src/App.js
fi

echo "✅ App.js atualizado!"

echo "📝 3. Criando estrutura final do módulo GED..."

# Verificar se todas as pastas existem
echo "📂 Verificando estrutura de pastas..."
mkdir -p frontend/src/pages/admin
mkdir -p frontend/src/components/documentos

echo "📝 4. Resumo final do módulo Upload GED..."

echo ""
echo "🎉 SCRIPT 92d CONCLUÍDO!"
echo ""
echo "✅ UPLOAD MULTI-CATEGORIA GED 100% COMPLETO:"
echo "   • Formulário completo de upload seguindo padrão Erlene"
echo "   • Drag-and-drop com validações avançadas"
echo "   • Auto-classificação inteligente baseada no nome"
echo "   • Relacionamentos opcionais (Cliente, Advogado, Fornecedor, Nenhum)"
echo "   • Sistema de tags dinâmico"
echo "   • Preview para imagens"
echo "   • Configurações de privacidade e expiração"
echo ""
echo "📋 FUNCIONALIDADES IMPLEMENTADAS:"
echo "   • Upload por drag-and-drop ou clique"
echo "   • Validação de tipo (PDF, DOC, XLS, IMG, AUDIO, VIDEO, XML)"
echo "   • Validação de tamanho (máximo 50MB)"
echo "   • Auto-classificação em 5 categorias com subcategorias"
echo "   • Preview de imagens com thumbnail"
echo "   • Ícones específicos por tipo de arquivo"
echo "   • Tags com adição/remoção dinâmica"
echo "   • Relacionamentos opcionais com pessoas"
echo "   • Vinculação com processos (para clientes)"
echo "   • Configurações de privacidade (Público, Privado, Restrito)"
echo ""
echo "🤖 AUTO-CLASSIFICAÇÃO INTELIGENTE:"
echo "   • 'contrato_honorarios' → Clientes/Contratos"
echo "   • 'rg_maria' → Clientes/Documentos Pessoais"
echo "   • 'peticao_inicial' → Clientes/Documentos Processuais"
echo "   • 'nota_fiscal' → Financeiros/Notas Fiscais"
echo "   • 'boleto_aluguel' → Financeiros/Boletos"
echo "   • 'oab_carlos' → Funcionários/Carteira OAB"
echo "   • 'manual_sistema' → Fornecedores/Manuais"
echo "   • 'regulamento_interno' → Administrativos/Documentos Internos"
echo ""
echo "📂 CATEGORIAS E SUBCATEGORIAS:"
echo "   👥 Clientes: Contratos, Pessoais, Processuais, Procurações, Certidões"
echo "   💰 Financeiros: Notas Fiscais, Boletos, Comprovantes, Extratos, Recibos"
echo "   👨‍💼 Funcionários: Pessoais, OAB, Currículos, Contratos, Trabalhistas"
echo "   🏢 Fornecedores: Contratos, Manuais, Notas Fiscais, Certificados"
echo "   📋 Administrativos: Internos, Correspondências, Licenças, Seguros"
echo ""
echo "🔗 ROTAS CONFIGURADAS:"
echo "   • /admin/documentos - Lista completa"
echo "   • /admin/documentos/novo - Upload (funcionando)"
echo "   • Link 'Upload Documento' na lista principal"
echo ""
echo "📁 ARQUIVOS CRIADOS:"
echo "   • frontend/src/components/documentos/NewDocumento.js (completo)"
echo "   • App.js atualizado com rota"
echo ""
echo "🧪 TESTE AGORA:"
echo "   • http://localhost:3000/admin/documentos"
echo "   • Clique em 'Upload Documento'"
echo "   • http://localhost:3000/admin/documentos/novo"
echo "   • Teste drag-and-drop de arquivos"
echo "   • Teste auto-classificação com nomes sugestivos"
echo ""
echo "⏭️ PRÓXIMO SCRIPT (92e):"
echo "   • EditDocumento.js (edição de metadados)"
echo "   • Preview avançado por tipo de arquivo"
echo "   • Finalização do módulo GED"
echo ""
echo "🎯 PROGRESSO GED:"
echo "   ✅ Dashboard GED (Lista, filtros, estatísticas)"
echo "   ✅ Upload Multi-Categoria (Drag-drop, auto-classificação)"
echo "   ⏳ Edição de Documentos (próximo)"
echo "   ⏳ Preview Avançado (próximo)"
echo ""
echo "🎉 SISTEMA GED UPLOAD COMPLETO!"
echo ""
echo "Digite 'continuar' para implementar edição de documentos (Script 92e)!"