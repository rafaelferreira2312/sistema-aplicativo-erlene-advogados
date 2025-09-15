// Arquivo para testar conexão com API
import audienciasService from '../services/audienciasService';

export const testarConexaoAPI = async () => {
  console.log('🧪 Testando conexão com API...');
  
  try {
    // Testar estatísticas
    const stats = await audienciasService.obterEstatisticas();
    console.log('📊 Stats:', stats);
    
    // Testar lista
    const lista = await audienciasService.listarAudiencias();
    console.log('📋 Lista:', lista);
    
    return { success: true, stats, lista };
  } catch (error) {
    console.error('❌ Erro na conexão:', error);
    return { success: false, error: error.message };
  }
};

// Executar teste automaticamente
if (window.location.pathname.includes('/admin/audiencias')) {
  setTimeout(() => {
    testarConexaoAPI();
  }, 2000);
}
