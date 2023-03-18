import { Adapter } from '~/lib/adapters/adapter';
import filesystemAdapter from '~/lib/adapters/filesystem-adapter';
import webDavAdapter from '~/lib/adapters/webdav-adapter';
import { env } from '~/lib/common/util';

class FileService {
  private readonly adapter: Adapter;

  constructor() {
    const adapterName = env('ADAPTER');
    switch (adapterName) {
      case 'filesystem':
        this.adapter = filesystemAdapter;
        break;
      case 'webdav':
        this.adapter = webDavAdapter;
        break;
      default:
        throw new Error(`Adapter '${adapterName}' does not exist!`);
    }

    this.adapter.init();
  }

  async save(name: string, data: ArrayBuffer): Promise<void> {
    await this.adapter.saveFile(name, data);
  }
}

export default new FileService();
