export abstract class Adapter {
  abstract init(): void;
  abstract saveFile(name: string, data: ArrayBuffer): Promise<void>;
}
