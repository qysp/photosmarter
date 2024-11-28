import { format } from 'date-fns';
import sanitize from 'sanitize-filename';
import fileService from '~/server/services/file-service';
import photosmartService, {
  PhotosmartScanDimensions,
  PhotosmartScanOptions,
  PhotosmartScanResolutions,
  PhotosmartScanResult,
} from '~/server/services/photosmart-service';
import { env } from '../common/util';

export type ScanResult<D = ArrayBuffer> = {
  success: boolean;
  message: string;
  file?: {
    name: string;
    type: string;
    data: D;
  };
};

export const scan = async (form: FormData): Promise<ScanResult> => {
  const type = form.get('type') as PhotosmartScanOptions['type'];
  const dimension = form.get(
    'dimension',
  ) as keyof typeof PhotosmartScanDimensions;
  const resolution = form.get(
    'resolution',
  ) as keyof typeof PhotosmartScanResolutions;
  const quality = Number.parseInt(form.get('quality') as string, 10);
  const color = form.get('color') === 'Color';
  const directDownload =
    env('VITE_ALLOW_DIRECT_DOWNLOAD') === 'only' ||
    form.get('download') === 'on';
  const preferredFileName = form.get('fileName') as string | null;

  const status = await photosmartService.status();
  if (status !== 'Idle') {
    const translatedStatus =
      status === 'BusyWithScanJob' ? 'busy' : 'unavailable';
    return {
      success: false,
      message:
        `Photosmart scanner is ${translatedStatus}, ` +
        'please try again later!',
    };
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
    return {
      success: false,
      message: `Failed to scan ${type === 'PDF' ? 'document' : 'photo'}`,
    };
  }

  const { data, extension, contentType } = result;
  const safeFileName = !!preferredFileName?.trim()
    ? sanitize(preferredFileName)
    : format(new Date(), 'yyyyMMdd_HHmmss');
  const safeExtension = extension ?? 'unknown';
  const name = safeFileName.concat(
    !safeFileName.endsWith(`.${safeExtension}`) ? `.${safeExtension}` : '',
  );

  if (directDownload) {
    return {
      success: true,
      message: 'Scan completed successfully',
      file: {
        name,
        type: contentType,
        data,
      },
    };
  }

  try {
    await fileService.save(name, data);
  } catch (error) {
    return {
      success: false,
      message: 'Failed to save scanned file',
    };
  }

  return {
    success: true,
    message: 'Scan completed successfully',
  };
};
