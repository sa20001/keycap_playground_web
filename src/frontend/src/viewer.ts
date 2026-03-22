import { ModelLoader } from './viewer/model-loader';
import { API_ENDPOINTS } from './api/endpoints';
import { GenerateForm } from './generation/generate-form';
import { ExportForm } from './export/export-form';
import { ModelFitter } from './viewer/model-fitter';
import { ViewerHelpers } from './viewer/viewer-helpers';
import { ViewerEngine } from './viewer/viewer-engine';

import {
  readGenerateConfig,
  saveGenerateConfig,
} from './generation/generate-config-storage';

import {
  DEFAULT_GENERATE_CONFIG,
  type GenerateConfig,
} from './generation/generate-config';

import {
  readExportConfig,
  saveExportConfig,
} from './export/export-config-storage';

import {
  DEFAULT_EXPORT_CONFIG,
  type ExportConfig,
} from './export/export-config';


import {
  generateModelsAPI,
} from './api/generation-api';

import {
  export2ZipApi,
} from './api/export-api';


type Options = {
  apiUrl?: string;
  generateUrl?: string;
  exportUrl?: string;
  showGrid?: boolean;
  showAxes?: boolean;
};

export class Viewer {
  container: HTMLElement;

  engine: ViewerEngine;
  modelLoader: ModelLoader;
  modelFitter: ModelFitter;
  helpers: ViewerHelpers;

  animationId?: number;
  resizeHandler: () => void;

  loadButton?: HTMLButtonElement;
  exportButton?: HTMLButtonElement;
  generateForm?: GenerateForm;
  exportForm?: ExportForm;

  isLoadingModel = false;
  isFirstRun = true;
  isExportingZip = false;

  options: Options;

  constructor(
    container: HTMLElement,
    options: Options = {},
  ) {
    this.container = container;

    const resolvedGenerateUrl =
      options.generateUrl ??
      options.apiUrl ??
      API_ENDPOINTS.generate;

    this.options = Object.assign(
      {
        apiUrl: API_ENDPOINTS.generate,
        generateUrl: resolvedGenerateUrl,
        exportUrl: API_ENDPOINTS.export,
        showGrid: true,
        showAxes: true,
      },
      options,
    );

    // Three.js engine
    this.engine = new ViewerEngine(
      this.container,
    );

    // Model loading
    this.modelLoader =
      new ModelLoader();

    // Helpers
    this.helpers =
      new ViewerHelpers(
        this.engine.scene,
        this.options.showGrid!,
        this.options.showAxes!,
      );

    // DOM
    this.resizeHandler =
      () => this.onWindowResize();

    this.initDOM();

    // Camera/model fitting
    this.modelFitter =
      new ModelFitter(
        this.engine.camera,
        this.engine.controls,
      );

    window.addEventListener(
      'resize',
      this.resizeHandler,
    );

    this.onWindowResize();
    this.animate();
  }

  initDOM() {
    this.container.classList.add(
      'viewer-container',
    );

    this.container.appendChild(
      this.engine.renderer.domElement,
    );

    const ui =
      document.createElement('div');

    ui.className = 'viewer-ui';

    ui.innerHTML = `
      <button
        id="loadBtn"
        title="Configure and generate model"
      >
        Generate Keycaps
      </button>

      <button
        id="exportBtn"
        title="Export generated files as zip"
      >
        Export ZIP
      </button>

      <button
        id="fitBtn"
        title="Fit model"
      >
        Fit
      </button>

      <button
        id="gridBtn"
        title="Toggle grid"
      >
        Grid
      </button>

      <button
        id="axesBtn"
        title="Toggle axes"
      >
        Axes
      </button>
    `;

    this.container.appendChild(ui);

    this.loadButton =
      ui.querySelector(
        '#loadBtn',
      ) as HTMLButtonElement;

    this.exportButton =
      ui.querySelector(
        '#exportBtn',
      ) as HTMLButtonElement;

    this.loadButton.addEventListener(
      'click',
      () => this.openGenerateForm(),
    );

    this.exportButton.addEventListener(
      'click',
      () => this.openExportForm(),
    );

    ui
      .querySelector('#fitBtn')!
      .addEventListener(
        'click',
        () => this.fitToView(),
      );

    ui
      .querySelector('#gridBtn')!
      .addEventListener(
        'click',
        () => this.toggleGrid(),
      );

    ui
      .querySelector('#axesBtn')!
      .addEventListener(
        'click',
        () => this.toggleAxes(),
      );

    this.generateForm =
      new GenerateForm(
        this.container,
        {
          onSubmit: () => {
            void this.submitGenerateForm();
          },

          onClose: () => {
            this.hideGenerateForm();
          },
        },
      );

    this.exportForm =
      new ExportForm(
        this.container,
        {
          onSubmit: (config) => {
            void this.submitExportForm();
          },

          onClose: () => {
            this.hideExportForm();
          },
        },
      );
  }

  setLoadingState(
    isLoading: boolean,
  ) {
    this.isLoadingModel =
      isLoading;

    this.generateForm?.setLoading(
      isLoading,
    );
  }

  setExportLoadingState(
    isLoading: boolean,
  ) {
    this.isExportingZip =
      isLoading;

    if (this.exportButton) {
      this.exportButton.disabled =
        isLoading;

      this.exportButton.classList.toggle(
        'is-loading',
        isLoading,
      );

      this.exportButton.setAttribute(
        'aria-busy',
        String(isLoading),
      );

      this.exportButton.textContent =
        isLoading
          ? 'Exporting...'
          : 'Export ZIP';
    }
  }

  openGenerateForm() {
    if (!this.generateForm) {
      return;
    }

    const config =
      readGenerateConfig() ??
      DEFAULT_GENERATE_CONFIG;

    this.generateForm.show(
      config,
    );
  }

  hideGenerateForm() {
    this.generateForm?.hide();
  }

  async submitGenerateForm() {
    if (!this.generateForm) {
      return;
    }

    const payload = this.generateForm.read();

    saveGenerateConfig(payload);

    const success =
      await this.loadModelFromApi(
        payload,
      );

    if (success) {
      this.hideGenerateForm();
    }
  }

  openExportForm() {
    if (!this.exportForm) {
      return;
    }
    const config =
      readExportConfig() ??
      DEFAULT_EXPORT_CONFIG;


    this.exportForm.show();
  }

  hideExportForm() {
    this.exportForm?.hide();
  }

  async submitExportForm() {

    if (!this.exportForm) {
      return;
    }

    const payload = this.exportForm.read();
    saveExportConfig(payload);

    const success = await this.exportGeneratedZip(payload);

    if (success) {
      this.hideExportForm();
    }

  }

  async loadModelFromApi(
    payload: GenerateConfig,
  ) {
    if (this.isLoadingModel) {
      return false;
    }

    this.setLoadingState(
      true,
    );

    try {
      const sevenZFile = await generateModelsAPI(this.options.generateUrl!, payload,);
      await this.loadModelsFrom7z(sevenZFile);

      return true;
    } catch (error) {
      console.error(
        'Model API error',
        error,
      );

      return false;
    } finally {
      this.setLoadingState(
        false,
      );
    }
  }

  downloadBlob(
    blob: Blob,
    filename: string,
  ) {
    const objectUrl =
      window.URL.createObjectURL(
        blob,
      );

    const anchor =
      document.createElement('a');

    anchor.href =
      objectUrl;

    anchor.download =
      filename;

    document.body.appendChild(
      anchor,
    );

    anchor.click();

    anchor.remove();

    window.URL.revokeObjectURL(
      objectUrl,
    );
  }

  async exportGeneratedZip(
    config: ExportConfig,
  ) {
    if (this.isExportingZip) {
      return;
    }

    this.setExportLoadingState(
      true,
    );

    console.log(
      'Exporting with config:',
      config,
    );

    try {
      const { blob, filename } = await export2ZipApi(this.options.exportUrl!, config);

      const fallbackName =
        config?.filename
          ? `${config.filename}.zip`
          : `keycaps-export-${Date.now()}.zip`;

      this.downloadBlob(
        blob,
        filename || fallbackName,
      );
      return true;
    } catch (error) {
      console.error(
        'Model export error',
        error,
      );
      return false;
    } finally {
      this.setExportLoadingState(
        false,
      );
    }
  }

  async loadModelsFrom7z(file: Blob) {
    const parsedModels = await this.modelLoader.parse7z(file);

    this.engine.modelGroup.clear();

    for (const model of parsedModels) {
      this.engine.modelGroup.add(model);
    }

    if (this.isFirstRun) {
      this.fitToView();
      this.isFirstRun = false;
    }
  }

  fitToView() {
    this.modelFitter.fit(
      this.engine.modelGroup,
    );
  }

  toggleGrid() {
    this.helpers.toggleGrid();
  }

  toggleAxes() {
    this.helpers.toggleAxes();
  }

  onWindowResize() {
    const width =
      this.container.clientWidth ||
      window.innerWidth;

    const height =
      this.container.clientHeight ||
      window.innerHeight;

    this.engine.resize(
      width,
      height,
    );
  }

  animate() {
    this.animationId =
      requestAnimationFrame(
        () => this.animate(),
      );

    this.engine.render();
  }

  dispose() {
    if (this.animationId) {
      cancelAnimationFrame(
        this.animationId,
      );
    }

    window.removeEventListener(
      'resize',
      this.resizeHandler,
    );

    this.engine.dispose();
  }
}