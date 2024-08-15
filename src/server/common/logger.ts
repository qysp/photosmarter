import { env } from './util';

enum LogLevel {
  DEBUG,
  INFO,
  WARN,
  ERROR,
}

class Logger {
  private readonly level: LogLevel;

  constructor(private readonly scope: string) {
    this.level = this.toLogLevel(env('LOG_LEVEL', 'error'));
  }

  debug(message: string, ...params: any[]): void {
    if (this.level >= LogLevel.DEBUG) {
      console.debug(`[${this.scope}] ${message}`, ...params);
    }
  }

  info(message: string, ...params: any[]): void {
    if (this.level >= LogLevel.INFO) {
      console.info(`[${this.scope}] ${message}`, ...params);
    }
  }

  warn(message: string, ...params: any[]): void {
    if (this.level >= LogLevel.WARN) {
      console.warn(`[${this.scope}] ${message}`, ...params);
    }
  }

  error(message: string, ...params: any[]): void {
    if (this.level >= LogLevel.ERROR) {
      console.error(`[${this.scope}] ${message}`, ...params);
    }
  }

  private toLogLevel(level: string) {
    switch (level.toLowerCase()) {
      case 'debug':
        return LogLevel.DEBUG;
      case 'info':
        return LogLevel.INFO;
      case 'warn':
        return LogLevel.WARN;
      case 'error':
      default:
        return LogLevel.ERROR;
    }
  }
}

export const createLogger = (scope: string): Logger => {
  return new Logger(scope);
};
