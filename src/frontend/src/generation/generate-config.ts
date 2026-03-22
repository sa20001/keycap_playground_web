export type AdaptiveLayerHeightConfig = {
  first_layer_height: number;
  layer_height: number;
  min_layer_height: number;
  max_layer_height: number;
  quality_speed_factor: number;
};

export type GenerateConfig = {
  stemInsideTolerance: number;
  legendHeight: number;
  outputFolder: string;
  keycapToGenerateTasks: string[];
  templatePath: string;
  preprocessing: boolean;
};

export const DEFAULT_GENERATE_CONFIG: GenerateConfig = {
  stemInsideTolerance: 0.18,
  legendHeight: 0.5,
  outputFolder: 'generated',
  keycapToGenerateTasks: ['multi'],
  templatePath: 'templates/think',
  preprocessing: true,
};

export const SESSION_GENERATE_CONFIG_KEY =
  'keycap-playground.generate-config';