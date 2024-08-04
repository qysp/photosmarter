import { Adapter } from '~/server/adapters/adapter';

class MockAdapter extends Adapter {
  init(): void {}

  async saveFile(name: string, data: ArrayBuffer): Promise<void> {}
}

export default new MockAdapter();
