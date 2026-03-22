import type { ExportConfig } from '../export/export-config';

export async function export2ZipApi(
  url: string,
  config: ExportConfig,
): Promise<{
  blob: Blob;
  filename: string | null;
}> {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(config),
  });

  if (!response.ok) {
    throw new Error(
      `Export request failed with status ${response.status}`,
    );
  }

  return {
    blob: await response.blob(),
    filename: extractFilename(
      response.headers.get('content-disposition'),
    ),
  };
}

function extractFilename(
  contentDisposition: string | null,
): string | null {
  if (!contentDisposition) {
    return null;
  }

  const utf8Match = contentDisposition.match(
    /filename\*=UTF-8''([^;]+)/i,
  );

  if (utf8Match?.[1]) {
    return decodeURIComponent(utf8Match[1]);
  }

  const basicMatch = contentDisposition.match(
    /filename="?([^";]+)"?/i,
  );

  if (basicMatch?.[1]) {
    return basicMatch[1];
  }

  return null;
}