import './styles.css';
import { Viewer } from './viewer';

const container = document.getElementById('app') || document.body;
const viewer = new Viewer(container as HTMLElement);

// expose to window for debugging from devtools
(window as any).__viewer = viewer;
