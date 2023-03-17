import { writeFile } from 'fs/promises';
import { Adapter } from '~/lib/adapters/adapter';

export class FilesystemAdapter extends Adapter {
  async saveFile(name: string, data: ArrayBuffer): Promise<void> {
    await writeFile(name, Buffer.from(data), {
      encoding: 'binary',
    });
  }
}
