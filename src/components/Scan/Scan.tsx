import { createEffect, createSignal } from 'solid-js';
import { createServerAction$ } from 'solid-start/server';
import toast from 'solid-toast';
import '~/components/Scan/Scan.css';
import { scanAndSave } from './Scan.action';

export default () => {
  const [loading, setLoading] = createSignal<string>();
  const [quality, setQuality] = createSignal(80);

  const [scan, { Form }] = createServerAction$(scanAndSave);

  createEffect(() => {
    if (scan.result === undefined || scan.result.bodyUsed) {
      return;
    }

    const loadingId = loading();
    if (loadingId !== undefined) {
      toast.dismiss(loadingId);
      setLoading(undefined);
    }

    void scan.result.json().then(({ success, message }) => {
      if (success) {
        toast.success(message);
      } else {
        toast.error(message);
      }
    });
  });

  const onSubmit = () => {
    const toastId = toast.loading('Scanning ...', {
      iconTheme: {
        primary: 'rgb(100, 100, 100)',
        secondary: 'rgb(180, 180, 180)',
      },
    });
    setLoading(toastId);
  };

  return (
    <Form onSubmit={onSubmit}>
      <fieldset class="options">
        <legend class="options__legend">Options</legend>

        <label for="type-select" class="options__label">
          Format
        </label>
        <select
          id="type-select"
          name="type"
          class="options__select"
          required={true}
          disabled={scan.pending}
        >
          <option value="PDF" selected={true}>
            PDF
          </option>
          <option value="JPEG">JPEG</option>
        </select>

        <label for="dimension-select" class="options__label">
          Paper size
        </label>
        <select
          id="dimension-select"
          name="dimension"
          class="options__select"
          required={true}
          disabled={scan.pending}
        >
          <option value="A4" selected={true}>
            A4
          </option>
          <option value="Letter">Letter</option>
        </select>

        <label for="resolution-select" class="options__label">
          Resolution
        </label>
        <select
          id="resolution-select"
          name="resolution"
          class="options__select"
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

        <label for="color-select" class="options__label">
          Color preference
        </label>
        <select
          id="color-select"
          name="color"
          class="options__select"
          required={true}
          disabled={scan.pending}
        >
          <option value="Color" selected={true}>
            Color
          </option>
          <option value="Black">Black</option>
        </select>

        <label for="quality-range" class="options__label">
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
      </fieldset>

      <button type="submit" class="options__scan" disabled={scan.pending}>
        <span>Scan</span>
      </button>
    </Form>
  );
};
