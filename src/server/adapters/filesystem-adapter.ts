import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { Adapter } from '~/server/adapters/adapter';
import { env } from '~/server/common/util';

class FilesystemAdapter extends Adapter {
  private directory!: string;

  init(): void {
    this.directory = env('FILESYSTEM_DIR');
  }

  async saveFile(name: string, data: ArrayBuffer): Promise<void> {
    await mkdir(this.directory, { recursive: true });

    const filepath = join(this.directory, name);
    try {
      await writeFile(filepath, Buffer.from(data), {
        encoding: 'binary',
        flag: 'wx',
      });
    } catch (error) {
      console.error(
        `[FilesystemAdapter] Failed to save file '${name}' ` +
          `in directory '${this.directory}'!`,
      );
      console.error('[FilesystemAdapter] Original error:', error);
      throw error;
    }
  }
}

export default new FilesystemAdapter();
