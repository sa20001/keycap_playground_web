import {
  DEFAULT_EXPORT_CONFIG,
  SESSION_EXPORT_CONFIG_KEY,
  type ExportConfig,
} from './export-config';

export function readExportConfig(): ExportConfig | null {
  if (
    typeof window === 'undefined' ||
    !window.sessionStorage
  ) {
    return null;
  }

  try {
    const rawValue = window.sessionStorage.getItem(
      SESSION_EXPORT_CONFIG_KEY,
    );

    if (!rawValue) {
      return null;
    }

    const parsed = JSON.parse(
      rawValue,
    ) as Partial<ExportConfig>;

    if (
      !parsed ||
      typeof parsed !== 'object'
    ) {
      return null;
    }

    return {
      ...DEFAULT_EXPORT_CONFIG,
      ...parsed
    };
  } catch {
    return null;
  }
}

export function saveExportConfig(
  config: ExportConfig,
): void {
  if (
    typeof window === 'undefined' ||
    !window.sessionStorage
  ) {
    return;
  }

  try {
    window.sessionStorage.setItem(
      SESSION_EXPORT_CONFIG_KEY,
      JSON.stringify(config),
    );
  } catch {
    // Ignore storage write failures so the UI still works
    // in restricted browser contexts.
  }
}