import { format } from 'date-fns';
import { json } from 'solid-start/server';
import '~/components/Scan/Scan.css';
import fileService from '~/server/services/file-service';
import photosmartService, {
    PhotosmartScanDimensions,
    PhotosmartScanOptions,
    PhotosmartScanResolutions,
    PhotosmartScanResult
} from '~/server/services/photosmart-service';

export const scanAndSave = async (form: FormData): Promise<Response> => {
    const type = form.get('type') as PhotosmartScanOptions['type'];
    const dimension = form.get(
      'dimension',
    ) as keyof typeof PhotosmartScanDimensions;
    const resolution = form.get(
      'resolution',
    ) as keyof typeof PhotosmartScanResolutions;
    const quality = Number.parseInt(form.get('quality') as string, 10);
    const color = form.get('color') === 'Color';
  
    const status = await photosmartService.status();
    if (status !== 'Idle') {
      return json({
        success: false,
        message: `Photosmart status is '${status}', please try again later!`,
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
    const filename = format(new Date(), 'yyyyMMdd_HHmmss').concat(
      '.',
      extension ?? 'unknown',
    );
  
    try {
      await fileService.save(filename, data);
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
  };