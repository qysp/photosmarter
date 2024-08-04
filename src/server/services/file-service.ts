import { Adapter } from '~/server/adapters/adapter';
import filesystemAdapter from '~/server/adapters/filesystem-adapter';
import webDavAdapter from '~/server/adapters/webdav-adapter';
import { env } from '~/server/common/util';
import mockAdapter from '../adapters/mock-adapter';

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
      case 'mock':
        this.adapter = mockAdapter;
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
