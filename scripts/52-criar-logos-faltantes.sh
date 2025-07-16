# CORREÇÃO 4: Criar logos faltantes (opcional)
# TIPO: Adição de arquivos estáticos
# IMPACTO: Remove erro 404 dos logos
# RISCO: Zero

echo "📁 Criando logos faltantes..."

# Criar logos temporários simples (SVG)
cat > frontend/public/logo192.png << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="192" height="192" viewBox="0 0 192 192" xmlns="http://www.w3.org/2000/svg">
  <rect width="192" height="192" fill="#8B1538"/>
  <text x="96" y="120" font-family="Arial, sans-serif" font-size="72" font-weight="bold" text-anchor="middle" fill="white">E</text>
</svg>
EOF

cat > frontend/public/logo512.png << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <rect width="512" height="512" fill="#8B1538"/>
  <text x="256" y="320" font-family="Arial, sans-serif" font-size="200" font-weight="bold" text-anchor="middle" fill="white">E</text>
</svg>
EOF

# Criar favicon.ico simples
cat > frontend/public/favicon.ico << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
  <rect width="32" height="32" fill="#8B1538"/>
  <text x="16" y="22" font-family="Arial" font-size="18" font-weight="bold" text-anchor="middle" fill="white">E</text>
</svg>
EOF

echo "✅ Logos criados!"
echo ""
echo "📝 Arquivos criados:"
echo "   • public/logo192.png"
echo "   • public/logo512.png" 
echo "   • public/favicon.ico"