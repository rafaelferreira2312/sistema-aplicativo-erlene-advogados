// Adicionar dias à data
export const addDays = (date, days) => {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
};

// Subtrair dias da data
export const subtractDays = (date, days) => {
  return addDays(date, -days);
};

// Verificar se é fim de semana
export const isWeekend = (date) => {
  const day = new Date(date).getDay();
  return day === 0 || day === 6; // Domingo ou Sábado
};

// Próximo dia útil
export const getNextBusinessDay = (date) => {
  let nextDay = addDays(date, 1);
  
  while (isWeekend(nextDay)) {
    nextDay = addDays(nextDay, 1);
  }
  
  return nextDay;
};

// Diferença em dias
export const getDaysUntil = (targetDate) => {
  const today = new Date();
  const target = new Date(targetDate);
  
  today.setHours(0, 0, 0, 0);
  target.setHours(0, 0, 0, 0);
  
  const diffTime = target - today;
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
};

// Verificar se a data é hoje
export const isToday = (date) => {
  const today = new Date();
  const checkDate = new Date(date);
  
  return today.toDateString() === checkDate.toDateString();
};

// Verificar se a data é ontem
export const isYesterday = (date) => {
  const yesterday = subtractDays(new Date(), 1);
  const checkDate = new Date(date);
  
  return yesterday.toDateString() === checkDate.toDateString();
};

// Verificar se a data é amanhã
export const isTomorrow = (date) => {
  const tomorrow = addDays(new Date(), 1);
  const checkDate = new Date(date);
  
  return tomorrow.toDateString() === checkDate.toDateString();
};

// Obter início do mês
export const getStartOfMonth = (date = new Date()) => {
  return new Date(date.getFullYear(), date.getMonth(), 1);
};

// Obter fim do mês
export const getEndOfMonth = (date = new Date()) => {
  return new Date(date.getFullYear(), date.getMonth() + 1, 0);
};

// Obter início da semana (domingo)
export const getStartOfWeek = (date = new Date()) => {
  const start = new Date(date);
  const day = start.getDay();
  const diff = start.getDate() - day;
  return new Date(start.setDate(diff));
};

// Obter fim da semana (sábado)
export const getEndOfWeek = (date = new Date()) => {
  const start = getStartOfWeek(date);
  return addDays(start, 6);
};

// Gerar array de datas entre duas datas
export const getDateRange = (startDate, endDate) => {
  const dates = [];
  let currentDate = new Date(startDate);
  const end = new Date(endDate);
  
  while (currentDate <= end) {
    dates.push(new Date(currentDate));
    currentDate = addDays(currentDate, 1);
  }
  
  return dates;
};

// Formatar duração em horas e minutos
export const formatDuration = (minutes) => {
  if (minutes < 60) {
    return `${minutes}min`;
  }
  
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  
  if (remainingMinutes === 0) {
    return `${hours}h`;
  }
  
  return `${hours}h ${remainingMinutes}min`;
};

// Verificar se o horário está no intervalo
export const isTimeInRange = (time, startTime, endTime) => {
  const timeMinutes = timeToMinutes(time);
  const startMinutes = timeToMinutes(startTime);
  const endMinutes = timeToMinutes(endTime);
  
  return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
};

// Converter horário para minutos
export const timeToMinutes = (time) => {
  const [hours, minutes] = time.split(':').map(Number);
  return hours * 60 + minutes;
};

// Converter minutos para horário
export const minutesToTime = (minutes) => {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
};
