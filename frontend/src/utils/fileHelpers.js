// Converter bytes para formato legível
export const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// Obter extensão do arquivo
export const getFileExtension = (filename) => {
  if (!filename) return '';
  return filename.split('.').pop().toLowerCase();
};

// Verificar se é imagem
export const isImageFile = (filename) => {
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp'];
  return imageExtensions.includes(getFileExtension(filename));
};

// Verificar se é PDF
export const isPDFFile = (filename) => {
  return getFileExtension(filename) === 'pdf';
};

// Verificar se é documento
export const isDocumentFile = (filename) => {
  const docExtensions = ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf', 'txt', 'rtf'];
  return docExtensions.includes(getFileExtension(filename));
};

// Verificar se é áudio
export const isAudioFile = (filename) => {
  const audioExtensions = ['mp3', 'wav', 'm4a', 'ogg', 'flac', 'aac'];
  return audioExtensions.includes(getFileExtension(filename));
};

// Verificar se é vídeo
export const isVideoFile = (filename) => {
  const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'webm', 'mkv', 'flv'];
  return videoExtensions.includes(getFileExtension(filename));
};

// Download de arquivo
export const downloadFile = (blob, filename) => {
  const url = window.URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  window.URL.revokeObjectURL(url);
};

// Download de arquivo via URL
export const downloadFileFromUrl = (url, filename) => {
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.target = '_blank';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

// Converter arquivo para base64
export const fileToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result);
    reader.onerror = error => reject(error);
  });
};

// Redimensionar imagem
export const resizeImage = (file, maxWidth, maxHeight, quality = 0.8) => {
  return new Promise((resolve) => {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    const img = new Image();
    
    img.onload = () => {
      // Calcular novas dimensões
      let { width, height } = img;
      
      if (width > height) {
        if (width > maxWidth) {
          height = (height * maxWidth) / width;
          width = maxWidth;
        }
      } else {
        if (height > maxHeight) {
          width = (width * maxHeight) / height;
          height = maxHeight;
        }
      }
      
      canvas.width = width;
      canvas.height = height;
      
      // Desenhar imagem redimensionada
      ctx.drawImage(img, 0, 0, width, height);
      
      // Converter para blob
      canvas.toBlob(resolve, file.type, quality);
    };
    
    img.src = URL.createObjectURL(file);
  });
};

// Obter ícone para tipo de arquivo
export const getFileIcon = (filename) => {
  const extension = getFileExtension(filename);
  
  const iconMap = {
    // Imagens
    jpg: '🖼️', jpeg: '🖼️', png: '🖼️', gif: '🖼️', webp: '🖼️', svg: '🖼️',
    // Documentos
    pdf: '📄', doc: '📝', docx: '📝', txt: '📝', rtf: '📝',
    // Planilhas
    xls: '📊', xlsx: '📊', csv: '📊',
    // Apresentações
    ppt: '📽️', pptx: '📽️',
    // Áudio
    mp3: '🎵', wav: '🎵', m4a: '🎵', ogg: '🎵',
    // Vídeo
    mp4: '🎬', avi: '🎬', mov: '🎬', wmv: '🎬',
    // Arquivo genérico
    default: '📎'
  };
  
  return iconMap[extension] || iconMap.default;
};
