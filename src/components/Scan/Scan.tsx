import { format } from 'date-fns';
import { createSignal } from 'solid-js';
import { createServerAction$, json } from 'solid-start/server';
import fileService from '~/lib/services/file-service';
import photosmartService, {
  PhotosmartScanDimensions,
  PhotosmartScanOptions,
  PhotosmartScanResolutions,
} from '~/lib/services/photosmart-service';
import './Scan.css';

export default () => {
  const [quality, setQuality] = createSignal(80);

  const [scan, { Form }] = createServerAction$(async (form: FormData) => {
    const type = form.get('type') as PhotosmartScanOptions['type'];
    const dimension = form.get(
      'dimension',
    ) as keyof typeof PhotosmartScanDimensions;
    const resolution = form.get(
      'resolution',
    ) as keyof typeof PhotosmartScanResolutions;
    const quality = Number.parseInt(form.get('quality') as string, 10);
    const color = form.get('color') === 'on';

    const status = await photosmartService.status();
    if (status !== 'Idle') {
      return json({
        success: false,
        message: `Photosmart status is '${status}', please try again later!`,
      });
    }

    // TODO: handle errors and give updates regarding the state (unvavailable,
    // scanning, saving, ...)
    const { data, extension } = await photosmartService.scan({
      type,
      dimension: PhotosmartScanDimensions[dimension],
      resolution: PhotosmartScanResolutions[resolution],
      quality,
      color,
    });

    const filename = format(new Date(), 'yyyyMMdd_HHmmss').concat(
      '.',
      extension ?? 'unknown',
    );
    await fileService.save(filename, data);

    return json({
      success: true,
      message: 'Scan completed successfully',
    });
  });

  return (
    <Form>
      <label for="type-select">Format</label>
      <select
        id="type-select"
        name="type"
        required={true}
        disabled={scan.pending}
      >
        <option value="PDF" selected={true}>
          PDF
        </option>
        <option value="JPEG">JPEG</option>
      </select>

      <label for="dimension-select">Paper size</label>
      <select
        id="dimension-select"
        name="dimension"
        required={true}
        disabled={scan.pending}
      >
        <option value="A4" selected={true}>
          A4
        </option>
        <option value="Letter">Letter</option>
      </select>

      <label for="resolution-select">Resolution</label>
      <select
        id="resolution-select"
        name="resolution"
        required={true}
        disabled={scan.pending}
      >
        <option value="High">High</option>
        <option value="Text" selected={true}>
          Text
        </option>
        <option value="Photo">Photo</option>
        <option value="Screen">Screen</option>
      </select>

      <label for="quality-range">
        Quality <strong>({quality()}%)</strong>
      </label>
      <input
        type="range"
        name="quality"
        id="quality-range"
        min={0}
        max={100}
        step={5}
        value={quality()}
        oninput={({ currentTarget }) => {
          setQuality(Number(currentTarget.value));
        }}
        required={true}
        disabled={scan.pending}
      />

      <input
        type="checkbox"
        name="color"
        id="color-checkbox"
        checked={true}
        disabled={scan.pending}
      />
      <label for="color-checkbox">Color</label>

      <button type="submit" disabled={scan.pending}>
        Scan
      </button>
    </Form>
  );
};
