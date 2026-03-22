import {
  DEFAULT_GENERATE_CONFIG,
  type GenerateConfig,
} from './generate-config';

export type GenerateFormCallbacks = {
  onSubmit: () => void;
  onClose: () => void;
};

export class GenerateForm {
  readonly overlay: HTMLDivElement;
  readonly form: HTMLFormElement;
  readonly submitButton: HTMLButtonElement;

  constructor(
    private readonly container: HTMLElement,
    private readonly callbacks: GenerateFormCallbacks,
  ) {
    this.overlay = this.createOverlay();

    this.form = this.overlay.querySelector(
      'form',
    ) as HTMLFormElement;

    this.submitButton = this.overlay.querySelector(
      '[data-action="submit"]',
    ) as HTMLButtonElement;

    this.bindEvents();
    this.updateLegendHeightConstraint();
  }

  private createOverlay(): HTMLDivElement {
    const overlay = document.createElement('div');

    overlay.className = 'generate-overlay is-hidden';

    overlay.innerHTML = `
      <div class="generate-panel" role="dialog" aria-modal="true" aria-labelledby="generateTitle">
        <div class="generate-panel__header">
          <div>
            <h2 id="generateTitle">Configure model generation</h2>
            <p>Defaults match the current hardcoded backend values.</p>
          </div>
          <button type="button" class="generate-close" title="Close">&times;</button>
        </div>

        <form class="generate-form">
          <label>
            <span>Stem inside tolerance [mm]</span>
            <input
              name="stemInsideTolerance"
              type="number"
              step="0.01"
              min="0"
              value="${DEFAULT_GENERATE_CONFIG.stemInsideTolerance}"
            >
          </label>

          <label>
            <span>Legend height [mm]</span>
            <input
              name="legendHeight"
              type="number"
              step="0.01"
              value="${DEFAULT_GENERATE_CONFIG.legendHeight}"
            >
          </label>

          <label>
            <span>Output folder</span>
            <input
              name="outputFolder"
              type="text"
              value="${DEFAULT_GENERATE_CONFIG.outputFolder}"
            >
          </label>

          <label>
            <span>Template path</span>
            <input
              name="templatePath"
              type="text"
              value="${DEFAULT_GENERATE_CONFIG.templatePath}"
            >
          </label>

          <label>
            <span>Keycap task</span>
            <select name="keycapToGenerateTasks">
              <option value="carved">Carved</option>
              <option value="multi" selected>Multi</option>
              <option value="embossed">Embossed</option>
            </select>
          </label>

          <label class="checkbox-row">
            <input
              name="preprocessing"
              type="checkbox"
              checked
            >
            <span class="support-blockers-label">Support Blockers</span>
          </label>

          <div class="generate-form__actions">
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
              data-action="submit"
            >
              <span class="button-label">Generate</span>
              <span class="button-spinner" aria-hidden="true"></span>
            </button>
          </div>
        </form>
      </div>
    `;

    this.container.appendChild(overlay);

    return overlay;
  }

  private bindEvents() {
    this.overlay
      .querySelector('.generate-close')
      ?.addEventListener('click', () => {
        this.callbacks.onClose();
      });

    this.overlay
      .querySelector('[data-action="cancel"]')
      ?.addEventListener('click', () => {
        this.callbacks.onClose();
      });

    this.overlay.addEventListener('click', (event) => {
      if (event.target === this.overlay) {
        this.callbacks.onClose();
      }
    });

    this.form.addEventListener('submit', (event) => {
      event.preventDefault();
      this.callbacks.onSubmit();
    });

    const taskSelect = this.form.elements.namedItem(
      'keycapToGenerateTasks',
    ) as HTMLSelectElement | null;

    const legendInput = this.form.elements.namedItem(
      'legendHeight',
    ) as HTMLInputElement | null;

    taskSelect?.addEventListener('change', () => {
      this.updateLegendHeightConstraint();
    });

    legendInput?.addEventListener('input', () => {
      if (!taskSelect || taskSelect.value === 'multi') {
        return;
      }

      const value = Number.parseFloat(legendInput.value);

      if (!Number.isNaN(value) && value < 0) {
        legendInput.value = String(Math.abs(value));
      }
    });
  }

  show(config: GenerateConfig) {
    this.populate(config);
    this.updateLegendHeightConstraint();
    this.overlay.classList.remove('is-hidden');
  }

  hide() {
    this.overlay.classList.add('is-hidden');
  }

  setLoading(isLoading: boolean) {
    this.submitButton.disabled = isLoading;
    this.submitButton.classList.toggle('is-loading', isLoading);
    this.submitButton.setAttribute(
      'aria-busy',
      String(isLoading),
    );

    const label = this.submitButton.querySelector('.button-label');

    if (label) {
      label.textContent = isLoading
        ? 'Generating...'
        : 'Generate';
    }
  }

  read(): GenerateConfig {
    const numberValue = (name: string): number => {
      const input = this.form.elements.namedItem(
        name,
      ) as HTMLInputElement | null;

      return input
        ? Number.parseFloat(input.value)
        : 0;
    };

    const textValue = (name: string): string => {
      const input = this.form.elements.namedItem(
        name,
      ) as HTMLInputElement | null;

      return input?.value ?? '';
    };

    const preprocessing = this.form.elements.namedItem(
      'preprocessing',
    ) as HTMLInputElement | null;

    const taskSelect = this.form.elements.namedItem(
      'keycapToGenerateTasks',
    ) as HTMLSelectElement | null;

    return {
      stemInsideTolerance: numberValue('stemInsideTolerance'),
      legendHeight: numberValue('legendHeight'),
      outputFolder: textValue('outputFolder'),

      keycapToGenerateTasks: [
        taskSelect?.value ?? 'multi',
      ],

      templatePath: textValue('templatePath'),

      preprocessing: preprocessing
        ? preprocessing.checked
        : true,

    };
  }

  populate(config: GenerateConfig) {
    const setValue = (
      name: string,
      value: string,
    ) => {
      const element = this.form.elements.namedItem(
        name,
      ) as HTMLInputElement | null;

      if (element) {
        element.value = value;
      }
    };

    setValue(
      'stemInsideTolerance',
      String(config.stemInsideTolerance),
    );

    setValue(
      'legendHeight',
      String(config.legendHeight),
    );

    setValue(
      'outputFolder',
      config.outputFolder,
    );

    setValue(
      'templatePath',
      config.templatePath,
    );

    setValue(
      'keycapToGenerateTasks',
      JSON.stringify(config.keycapToGenerateTasks),
    );

    setValue(
      'preprocessing',
      String(config.preprocessing),
    );

    const taskSelect = this.form.elements.namedItem(
      'keycapToGenerateTasks',
    ) as HTMLSelectElement | null;

    if (taskSelect) {
      taskSelect.value =
        config.keycapToGenerateTasks[0] ?? 'multi';
    }

    const preprocessing = this.form.elements.namedItem(
      'preprocessing',
    ) as HTMLInputElement | null;

    if (preprocessing) {
      preprocessing.checked = config.preprocessing;
    }

    this.updateLegendHeightConstraint();
  }

  private updateLegendHeightConstraint() {
    const taskSelect = this.form.elements.namedItem(
      'keycapToGenerateTasks',
    ) as HTMLSelectElement | null;

    const legendInput = this.form.elements.namedItem(
      'legendHeight',
    ) as HTMLInputElement | null;

    if (!taskSelect || !legendInput) {
      return;
    }

    if (taskSelect.value === 'multi') {
      legendInput.removeAttribute('min');
      return;
    }

    legendInput.setAttribute('min', '0');

    const currentValue = Number.parseFloat(
      legendInput.value,
    );

    if (
      !Number.isNaN(currentValue) &&
      currentValue < 0
    ) {
      legendInput.value = String(
        Math.abs(currentValue),
      );
    }
  }
}