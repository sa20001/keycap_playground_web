export type AdaptiveLayerHeightConfig = {
  first_layer_height: number;
  layer_height: number;
  min_layer_height: number;
  max_layer_height: number;
  quality_speed_factor: number;
};

export type ExportConfig = {
  filename: string;
  adaptiveLayerHeightConfig: AdaptiveLayerHeightConfig;
};

export const DEFAULT_EXPORT_CONFIG: ExportConfig = {
  filename: 'keycaps-export',
  adaptiveLayerHeightConfig: {
    first_layer_height: 0.2,
    layer_height: 0.05,
    min_layer_height: 0.05,
    max_layer_height: 0.3,
    quality_speed_factor: 0.5,
  },
};


export const SESSION_EXPORT_CONFIG_KEY =
  'keycap-playground.export-config';
