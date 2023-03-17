export abstract class Adapter {
  abstract saveFile(name: string, data: ArrayBuffer): Promise<void>;
}
