# CORREÇÃO 3: Downgrade Tailwind CSS para versão compatível
# TIPO: Mudança de versão de dependência
# IMPACTO: Resolve erro de compilação, mantém funcionalidades
# RISCO: Baixo

echo "🔧 Corrigindo versão do Tailwind CSS..."

# 1. Desinstalar versão incompatível
npm uninstall tailwindcss

# 2. Instalar versão compatível
npm install -D tailwindcss@^3.4.0

echo "✅ Tailwind CSS versão 3.4.0 instalado"
echo ""
echo "📝 MUDANÇAS:"
echo "   - Removido: tailwindcss@^4.1.11"  
echo "   - Instalado: tailwindcss@^3.4.0"
echo ""
echo "▶️ PRÓXIMO: Execute 'npm start' para testar"