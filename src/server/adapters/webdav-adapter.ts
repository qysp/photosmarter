import { join } from 'node:path';
import { AuthType, createClient, WebDAVClient } from 'webdav';
import { Adapter } from '~/server/adapters/adapter';
import { env } from '~/server/common/util';

class WebDavAdapter extends Adapter {
  private directory!: string;
  private client!: WebDAVClient;

  init(): void {
    this.directory = env('WEBDAV_DIR');

    const remoteUrl = env('WEBDAV_REMOTE_URL');
    const username = env('WEBDAV_USERNAME');
    const password = env('WEBDAV_PASSWORD');

    this.client = createClient(remoteUrl, {
      authType: AuthType.Password,
      username,
      password,
    });
  }

  async saveFile(name: string, data: ArrayBuffer): Promise<void> {
    if (!(await this.client.exists(this.directory))) {
      await this.client.createDirectory(this.directory, { recursive: true });
    }

    const filepath = join(this.directory, name);
    try {
      await this.client.putFileContents(filepath, data, {
        overwrite: false,
      });
    } catch (error) {
      console.error(
        `[WebDavAdapter] Failed to save file '${name}' ` +
          `in directory '${this.directory}'!`,
      );
      throw error;
    }
  }
}

export default new WebDavAdapter();
