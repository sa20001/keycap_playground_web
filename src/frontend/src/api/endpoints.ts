const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000').replace(/\/$/, '');

export const API_ENDPOINTS = {
  generate: `${API_BASE_URL}/generate`,
  export: `${API_BASE_URL}/export`,
};
