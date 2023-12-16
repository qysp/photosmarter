import { format } from 'date-fns';
import sanitize from 'sanitize-filename';
import { APIEvent } from 'solid-start';
import { json } from 'solid-start/server';
import '~/components/Scan/Scan.css';
import fileService from '~/server/services/file-service';
import photosmartService, {
  PhotosmartScanDimensions,
  PhotosmartScanOptions,
  PhotosmartScanResolutions,
  PhotosmartScanResult,
} from '~/server/services/photosmart-service';

export async function POST({ request }: APIEvent): Promise<Response> {
  const form = await request.formData();

  const type = form.get('type') as PhotosmartScanOptions['type'];
  const dimension = form.get(
    'dimension',
  ) as keyof typeof PhotosmartScanDimensions;
  const resolution = form.get(
    'resolution',
  ) as keyof typeof PhotosmartScanResolutions;
  const quality = Number.parseInt(form.get('quality') as string, 10);
  const color = form.get('color') === 'Color';
  const preferredFileName = form.get('fileName') as string | null;

  const status = await photosmartService.status();
  if (status !== 'Idle') {
    const translatedStatus =
      status === 'BusyWithScanJob' ? 'busy' : 'unavailable';
    return json({
      success: false,
      message:
        `Photosmart scanner is ${translatedStatus}, ` +
        'please try again later!',
    });
  }

  let result: PhotosmartScanResult | undefined;
  try {
    result = await photosmartService.scan({
      type,
      dimension: PhotosmartScanDimensions[dimension],
      resolution: PhotosmartScanResolutions[resolution],
      quality,
      color,
    });
  } catch (error) {
    return json({
      success: false,
      message: `Failed to scan ${type === 'PDF' ? 'document' : 'photo'}`,
    });
  }

  const { data, extension } = result;
  const safeFileName = !!preferredFileName?.trim()
    ? sanitize(preferredFileName)
    : format(new Date(), 'yyyyMMdd_HHmmss');
  const safeExtension = extension ?? 'unknown';

  try {
    const name = safeFileName.concat(
      !safeFileName.includes('.') ? `.${safeExtension}` : '',
    );
    await fileService.save(name, data);
  } catch (error) {
    return json({
      success: false,
      message: 'Failed to save scanned file',
    });
  }

  return json({
    success: true,
    message: 'Scan completed successfully',
  });
}
