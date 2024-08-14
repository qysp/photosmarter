import { action, useSubmission } from '@solidjs/router';
import { createEffect, createSignal, untrack } from 'solid-js';
import toast from 'solid-toast';
import '~/components/Scan/Scan.css';
import { scan, ScanResult } from '~/server/api/scan';

const performScan = action(async (form: FormData): Promise<ScanResult> => {
  'use server';
  return scan(form);
}, 'scan');

export default () => {
  const [loading, setLoading] = createSignal<string>();
  const [quality, setQuality] = createSignal(80);
  const [fileName, setFileName] = createSignal('');
  const scanning = useSubmission(performScan);

  const handleSubmit = (event: Event) => {
    const name = prompt('Enter a file name');
    // Prompt was cancelled!
    if (name === null) {
      event.preventDefault();
      return;
    }

    setFileName(name);
  };

  createEffect(() => {
    if (scanning.pending) {
      const toastId = toast.loading('Scanning ...', {
        iconTheme: {
          primary: 'rgb(100, 100, 100)',
          secondary: 'rgb(180, 180, 180)',
        },
      });
      setLoading(toastId);
    } else {
      const loadingId = untrack(() => loading());
      if (loadingId !== undefined) {
        toast.dismiss(loadingId);
        setLoading(undefined);
      }
    }
  });

  createEffect(() => {
    if (scanning.result === undefined) {
      return;
    }

    if (scanning.result.success) {
      toast.success(scanning.result.message);
    } else {
      toast.error(scanning.result.message);
    }
  });

  createEffect(() => {
    if (!scanning.error) {
      return;
    }

    toast.error(`Scan failed (${scanning.error})`);
    scanning.clear();
  });

  return (
    <form
      method="post"
      action={performScan}
      onSubmit={(event) => handleSubmit(event)}
    >
      <fieldset class="options">
        <legend class="options__legend">Options</legend>

        <input type="hidden" name="fileName" value={fileName()} />

        <label for="type-select" class="options__label">
          Format
        </label>
        <select
          id="type-select"
          name="type"
          class="options__select"
          required={true}
          disabled={scanning.pending}
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
          disabled={scanning.pending}
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
          disabled={scanning.pending}
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
          disabled={scanning.pending}
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
          disabled={scanning.pending}
        />
      </fieldset>

      <button type="submit" class="options__scan" disabled={scanning.pending}>
        <span>Scan</span>
      </button>
    </form>
  );
};
