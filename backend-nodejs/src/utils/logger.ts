import winston from 'winston';

// Configuração do logger
const loggerConfig = {
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'erlene-advogados-api' },
  transports: [
    // Console sempre
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      ),
    }),
  ],
};

// Adicionar arquivo de log em produção
if (process.env.NODE_ENV === 'production') {
  loggerConfig.transports.push(
    new winston.transports.File({
      filename: process.env.LOG_FILE || './logs/error.log',
      level: 'error',
    }),
    new winston.transports.File({
      filename: process.env.LOG_FILE || './logs/combined.log',
    })
  );
}

export const logger = winston.createLogger(loggerConfig);

// Função helper para logs estruturados
export const logError = (message: string, error: any, context?: any) => {
  logger.error(message, {
    error: error.message,
    stack: error.stack,
    context,
  });
};

export const logInfo = (message: string, data?: any) => {
  logger.info(message, data);
};

export const logWarn = (message: string, data?: any) => {
  logger.warn(message, data);
};
