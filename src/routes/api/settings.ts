import { CustomResponse, json } from '@solidjs/router';
import { env } from '~/server/common/util';

export type Settings = {
  isDirectDownloadAllowed: boolean;
};

export async function GET(): Promise<CustomResponse<Settings>> {
  console.log('direct download:', env('VITE_ALLOW_DIRECT_DOWNLOAD'));
  return json({
    isDirectDownloadAllowed: env('VITE_ALLOW_DIRECT_DOWNLOAD') === 'yes',
  });
}
