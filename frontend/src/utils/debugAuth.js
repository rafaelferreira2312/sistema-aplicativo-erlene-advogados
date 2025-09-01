// Debug simples para verificar autenticação
export const debugAuth = () => {
  const authData = {
    tokens: {
      authToken: !!localStorage.getItem('authToken'),
      erleneToken: !!localStorage.getItem('erlene_token'),
      token: !!localStorage.getItem('token')
    },
    flags: {
      isAuthenticated: localStorage.getItem('isAuthenticated') === 'true',
      portalAuth: localStorage.getItem('portalAuth') === 'true',
      userType: localStorage.getItem('userType')
    },
    status: 'unknown'
  };
  
  const hasAnyToken = Object.values(authData.tokens).some(Boolean);
  const isAuth = hasAnyToken || authData.flags.isAuthenticated;
  
  authData.status = isAuth ? 'authenticated' : 'not authenticated';
  
  console.table(authData);
  return authData;
};

if (typeof window !== 'undefined') {
  window.debugAuth = debugAuth;
}
