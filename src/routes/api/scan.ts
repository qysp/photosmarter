import { CustomResponse, json } from '@solidjs/router';
import { APIEvent } from '@solidjs/start/server';
import { scan, ScanResult } from '~/server/api/scan';

export async function POST({
  request,
}: APIEvent): Promise<Response | CustomResponse<ScanResult>> {
  const form = await request.formData();

  const { file, ...result } = await scan(form);

  // No automatic upload desired - instead download the scanned document.
  if (file !== undefined && form.get('download') === 'on') {
    return new Response(file.data, {
      headers: new Headers({
        'Content-Type': file.type,
        'Content-Disposition': `attachment; filename="${file.name}"`,
        'Content-Length': file.data.byteLength.toString(10),
        'X-Photosmarter-Filename': file.name,
      }),
    });
  }

  return json(result);
}
