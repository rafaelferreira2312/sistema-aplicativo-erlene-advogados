# CORREÇÃO 1: Remover Husky que está causando erro
# TIPO: Remoção de dependência desnecessária
# IMPACTO: Resolve erro de instalação, sem afetar funcionalidade

echo "🔧 Removendo Husky do package.json..."

# Criar backup do package.json atual
cp frontend/package.json frontend/package.json.backup

# Remover linha do husky do package.json
sed -i '/"prepare": "husky install"/d' frontend/package.json

echo "✅ Husky removido do package.json"
echo "📝 Backup criado em package.json.backup"
echo ""
echo "▶️ PRÓXIMO PASSO: Execute 'npm install' novamente"