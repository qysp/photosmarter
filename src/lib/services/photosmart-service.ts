import assert from 'assert';
import axios from 'axios';
import { load } from 'cheerio';
import { clamp } from '~/lib/common/util';

export const PhotosmartScanResolutions = {
  High: 600,
  Text: 300,
  Photo: 200,
  Screen: 75,
};

export const PhotosmartScanDimensions = {
  A4: {
    width: 2_480,
    height: 3_508,
  },
  Letter: {
    width: 2_550,
    height: 3_300,
  },
};

export const PhotosmartScanQualities = {
  Low: 25,
  Medium: 65,
  High: 85,
  Maximum: 95,
};

export type PhotosmartScanOptions = {
  /**
   * Defaults to {@link PhotosmartScanResolutions.Text}.
   */
  resolution?: number;
  /**
   * Defaults to {@link PhotosmartScanDimensions.A4}.
   */
  dimension?: {
    width: number;
    height: number;
  };
  /**
   * Defaults to `true`.
   */
  color?: boolean;
  /**
   * Defaults to `PDF`.
   */
  type?: 'PDF' | 'JPEG';
  /**
   * Defaults to {@link PhotosmartScanQualities.Medium}.
   */
  quality?: number;
};

export type PhotosmartStatus = 'Idle' | 'Unknown';

export class PhotosmartService {
  constructor(readonly baseUrl: string) {}

  async status(): Promise<PhotosmartStatus> {
    const url = this.baseUrl.concat('/Scan/Status');

    try {
      const response = await axios.get<string>(url);

      const $ = load(response.data);
      const status = $('ScannerState').first().text();
      return status as PhotosmartStatus;
    } catch (error) {
      console.error(error);
      return 'Unknown';
    }
  }

  async scan(options?: PhotosmartScanOptions): Promise<ArrayBuffer> {
    const url = this.baseUrl.concat('/Scan/Jobs');

    const normalizedOptions: Required<PhotosmartScanOptions> = {
      resolution: options?.resolution ?? PhotosmartScanResolutions.Text,
      dimension: options?.dimension ?? PhotosmartScanDimensions.A4,
      type: options?.type ?? 'PDF',
      quality: clamp(
        0,
        options?.quality ?? PhotosmartScanQualities.Medium,
        100,
      ),
      color: options?.color ?? true,
    };

    const xml = this.createScanJob(normalizedOptions);

    const response = await axios.post<void>(url, {
      body: xml,
      headers: {
        'Content-Type': 'application/xml',
        'Content-Length': Buffer.byteLength(xml, 'utf-8').toString(),
      },
    });
    if (response.status !== 201) {
      throw new Error(
        `Failed sending scan job (${response.status} ${response.statusText})`,
      );
    }

    // The location header tells us where we can fetch metadata of the
    // created job from.
    const location = response.headers['location'];
    if (location === null) {
      throw new Error('Response is missing location header');
    }

    // The binary URL should always exist and since we just requested a scan,
    // there should be only a single scan job.
    const [binaryUrl] = await this.fetchIncompleteBinaryUrls();
    if (binaryUrl === undefined) {
      throw new Error('Binary URL could not be determined');
    }

    const binaryResponse = await axios.get<ArrayBuffer>(
      this.baseUrl.concat(binaryUrl),
      {
        responseType: 'arraybuffer',
      },
    );
    return binaryResponse.data;
  }

  private async fetchIncompleteBinaryUrls() {
    const url = this.baseUrl.concat('/Jobs/JobList');

    const response = await fetch(url, {
      method: 'GET',
    });
    const xml = await response.text();
    const $ = load(xml);

    const urls: string[] = [];

    for (const element of $('ScanJob')) {
      const $element = $(element);

      const state = $element.find('PageState').first().text();
      if (state === 'Completed') {
        continue;
      }

      const url = $element.find('BinaryURL').first().text();
      if (url) {
        urls.push(url);
      }
    }

    return urls;
  }

  private createScanJob(options: Required<PhotosmartScanOptions>): string {
    const format = options.type === 'PDF' ? 'Pdf' : 'Jpeg';
    const contentType = options.type === 'PDF' ? 'Document' : 'Photo';
    const compressionFactor = 100 - options.quality;
    const color = options.color ? 'Color' : 'Black';

    return `
      <scan:ScanJob xmlns:scan="http://www.hp.com/schemas/imaging/con/cnx/scan/2008/08/19"
        xmlns:dd="http://www.hp.com/schemas/imaging/con/dictionaries/1.0/">
        <scan:XResolution>${options.resolution}</scan:XResolution>
        <scan:YResolution>${options.resolution}</scan:YResolution>
        <scan:XStart>0</scan:XStart>
        <scan:YStart>0</scan:YStart>
        <scan:Width>${options.dimension.width}</scan:Width>
        <scan:Height>${options.dimension.height}</scan:Height>
        <scan:Format>${format}</scan:Format>
        <scan:CompressionQFactor>${compressionFactor}</scan:CompressionQFactor>
        <scan:ColorSpace>${color}</scan:ColorSpace>
        <scan:BitDepth>8</scan:BitDepth>
        <scan:InputSource>Platen</scan:InputSource>
        <scan:GrayRendering>NTSC</scan:GrayRendering>
        <scan:ToneMap>
            <scan:Gamma>1000</scan:Gamma>
            <scan:Brightness>800</scan:Brightness>
            <scan:Contrast>800</scan:Contrast>
            <scan:Highlite>179</scan:Highlite>
            <scan:Shadow>25</scan:Shadow>
        </scan:ToneMap>
        <scan:ContentType>${contentType}</scan:ContentType>
      </scan:ScanJob>
    `;
  }
}

const PHOTOSMART_URL = process.env['PHOTOSMART_URL'];
assert(
  PHOTOSMART_URL !== undefined,
  'Make sure to set the environment variable `PHOTOSMART_URL`',
);
export default new PhotosmartService(PHOTOSMART_URL);
