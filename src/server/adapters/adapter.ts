import { createLogger } from '../common/logger';

export abstract class Adapter {
  protected readonly logger = createLogger(this.constructor.name);

  abstract init(): void;
  abstract saveFile(name: string, data: ArrayBuffer): Promise<void>;
}
