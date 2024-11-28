import { Adapter } from '~/server/adapters/adapter';

class MockAdapter extends Adapter {
  init(): void {
    this.logger.debug('Initialized!');
  }

  async saveFile(name: string, data: ArrayBuffer): Promise<void> {
    this.logger.debug(
      'Save file called for %s with %d bytes of data',
      name,
      data.byteLength,
    );
  }
}

export default new MockAdapter();
