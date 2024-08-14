import { CustomResponse, json } from '@solidjs/router';
import { APIEvent } from '@solidjs/start/server';
import { scan, ScanResult } from '~/server/api/scan';

export async function POST({
  request,
}: APIEvent): Promise<CustomResponse<ScanResult>> {
  const form = await request.formData();

  const result = await scan(form);

  return json(result);
}
