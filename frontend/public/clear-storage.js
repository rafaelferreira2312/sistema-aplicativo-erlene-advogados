// Script para limpar localStorage problemático
if (typeof Storage !== "undefined") {
    // Limpar chaves problemáticas
    localStorage.removeItem('portalAuth');
    localStorage.removeItem('userType');
    localStorage.removeItem('user');
    localStorage.removeItem('isAuthenticated');
    
    console.log('localStorage limpo!');
}
