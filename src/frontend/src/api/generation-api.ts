import type { GenerateConfig } from '../generation/generate-config';

export async function generateModelsAPI(
  url: string,
  config: GenerateConfig,
): Promise<Blob> {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(config),
  });

  if (!response.ok) {
    throw new Error(
      `API request failed with status ${response.status}`,
    );
  }

  const contentType =
    response.headers.get('content-type') || '';

  if (!contentType.includes('application/x-7z-compressed')) {
    throw new Error(
      `Expected 7z file from API, got ${
        contentType || 'unknown content type'
      }`,
    );
  }

  return await response.blob();
}