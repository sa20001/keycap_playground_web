import {
  DEFAULT_EXPORT_CONFIG,
  type ExportConfig,
} from './export-config';

export type ExportFormCallbacks = {
  onSubmit: (config: ExportConfig) => void;
  onClose: () => void;
};


export class ExportForm {
  readonly overlay: HTMLDivElement;
  readonly form: HTMLFormElement;

  constructor(
    private readonly container: HTMLElement,
    private readonly callbacks: ExportFormCallbacks,
  ) {
    this.overlay = this.createOverlay();

    this.form = this.overlay.querySelector(
      'form',
    ) as HTMLFormElement;

    this.bindEvents();
  }

  private createOverlay(): HTMLDivElement {
    const overlay =
      document.createElement('div');

    overlay.className =
      'export-overlay is-hidden';

    overlay.innerHTML = `
      <div
        class="export-panel"
        role="dialog"
        aria-modal="true"
        aria-labelledby="exportTitle"
      >
        <div class="export-panel__header">
          <div>
            <h2 id="exportTitle">
              Export Keycaps
            </h2>

            <p>
              Configure the ZIP export.
            </p>
          </div>

          <button
            type="button"
            class="export-close"
            title="Close"
          >
            &times;
          </button>
        </div>

        <form class="export-form">
          <label>
            <span>Filename</span>

            <input
              name="filename"
              type="text"
              value="${DEFAULT_EXPORT_CONFIG.filename}"
            >
          </label>

          <details open>
            <summary>Adaptive layer height</summary>

            <label>
              <span class="first_layer_height_label">First layer height</span>
              <input
                name="first_layer_height"
                type="number"
                step="0.01"
                min="0"
                value="${DEFAULT_EXPORT_CONFIG.adaptiveLayerHeightConfig.first_layer_height}"
              >
            </label>

            <label>
              <span class="layer_height_label">Layer height</span>
              <input
                name="layer_height"
                type="number"
                step="0.01"
                min="0"
                value="${DEFAULT_EXPORT_CONFIG.adaptiveLayerHeightConfig.layer_height}"
              >
            </label>

            <label>
              <span class="min_layer_height_label">Min layer height</span>
              <input
                name="min_layer_height"
                type="number"
                step="0.01"
                min="0"
                value="${DEFAULT_EXPORT_CONFIG.adaptiveLayerHeightConfig.min_layer_height}"
              >
            </label>

            <label>
              <span class="max_layer_height_label">Max layer height</span>
              <input
                name="max_layer_height"
                type="number"
                step="0.01"
                min="0"
                value="${DEFAULT_EXPORT_CONFIG.adaptiveLayerHeightConfig.max_layer_height}"
              >
            </label>

            <label>
              <span class="quality_speed_factor_label">Quality speed factor</span>
              <input
                name="quality_speed_factor"
                type="number"
                step="0.01"
                min="0"
                value="${DEFAULT_EXPORT_CONFIG.adaptiveLayerHeightConfig.quality_speed_factor}"
              >
            </label>
          </details>

          <div class="export-form__actions">
            <button
              type="button"
              class="secondary-btn"
              data-action="cancel"
            >
              Cancel
            </button>

            <button
              type="submit"
              class="primary-btn"
            >
              Export ZIP
            </button>
          </div>
        </form>
      </div>
    `;

    this.container.appendChild(
      overlay,
    );

    return overlay;
  }

  private bindEvents() {
    this.overlay
      .querySelector('.export-close')
      ?.addEventListener(
        'click',
        () => {
          this.callbacks.onClose();
        },
      );

    this.overlay
      .querySelector('[data-action="cancel"]')
      ?.addEventListener(
        'click',
        () => {
          this.callbacks.onClose();
        },
      );

    // Close when clicking outside the panel
    this.overlay.addEventListener(
      'click',
      (event) => {
        if (
          event.target === this.overlay
        ) {
          this.callbacks.onClose();
        }
      },
    );

    this.form.addEventListener(
      'submit',
      (event) => {
        event.preventDefault();

        this.callbacks.onSubmit(
          this.read(),
        );
      },
    );
  }

  show() {
    this.overlay.classList.remove(
      'is-hidden',
    );
  }

  hide() {
    this.overlay.classList.add(
      'is-hidden',
    );
  }

read(): ExportConfig {
  const textValue = (name: string): string => {
    const input = this.form.elements.namedItem(
      name,
    ) as HTMLInputElement | null;

    return input?.value.trim() ?? '';
  };

  const numberValue = (name: string): number => {
    const input = this.form.elements.namedItem(
      name,
    ) as HTMLInputElement | null;

    return input
      ? Number.parseFloat(input.value)
      : 0;
  };

  return {
    filename:
      textValue('filename') ||
      'keycaps-export',

    adaptiveLayerHeightConfig: {
      first_layer_height:
        numberValue('first_layer_height'),

      layer_height:
        numberValue('layer_height'),

      min_layer_height:
        numberValue('min_layer_height'),

      max_layer_height:
        numberValue('max_layer_height'),

      quality_speed_factor:
        numberValue('quality_speed_factor'),
    },
  };
}
}