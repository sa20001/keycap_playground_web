import {
  DEFAULT_GENERATE_CONFIG,
  SESSION_GENERATE_CONFIG_KEY,
  type GenerateConfig,
} from './generate-config';

export function readGenerateConfig(): GenerateConfig | null {
  if (
    typeof window === 'undefined' ||
    !window.sessionStorage
  ) {
    return null;
  }

  try {
    const rawValue = window.sessionStorage.getItem(
      SESSION_GENERATE_CONFIG_KEY,
    );

    if (!rawValue) {
      return null;
    }

    const parsed = JSON.parse(
      rawValue,
    ) as Partial<GenerateConfig>;

    if (
      !parsed ||
      typeof parsed !== 'object'
    ) {
      return null;
    }

    return {
      ...DEFAULT_GENERATE_CONFIG,
      ...parsed,

      keycapToGenerateTasks:
        Array.isArray(
          parsed.keycapToGenerateTasks,
        ) &&
        parsed.keycapToGenerateTasks.length > 0
          ? parsed.keycapToGenerateTasks
          : DEFAULT_GENERATE_CONFIG.keycapToGenerateTasks
    };
  } catch {
    return null;
  }
}

export function saveGenerateConfig(
  config: GenerateConfig,
): void {
  if (
    typeof window === 'undefined' ||
    !window.sessionStorage
  ) {
    return;
  }

  try {
    window.sessionStorage.setItem(
      SESSION_GENERATE_CONFIG_KEY,
      JSON.stringify(config),
    );
  } catch {
    // Ignore storage write failures so the UI still works
    // in restricted browser contexts.
  }
}